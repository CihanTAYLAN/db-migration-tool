/*
# Product Master Images Update Step

Updates product_master_image_id in products table and is_master flag in product_images table.
Sets the first image of each product as the master image.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class ProductMasterImagesUpdateStep {
    constructor(sourceDb, targetDb, config) {
        this.sourceDb = sourceDb; // Not used but kept for consistency
        this.targetDb = targetDb;
        this.config = config;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.productMasterImagesUpdate ? config.steps.productMasterImagesUpdate.batchSize : 500,
            parallelLimit: 1, // Sequential processing for updates
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Product master images update progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
    }

    async run() {
        logger.info('Starting product master images update step...');

        try {
            // Get total count of products with images
            const totalCountResult = await this.targetDb.query(`
                SELECT COUNT(DISTINCT pi.product_id) as total
                FROM product_images pi
                JOIN products p ON pi.product_id = p.id
                WHERE p.archived_at IS NULL
            `);
            const totalProductCount = parseInt(totalCountResult[0].total);

            if (totalProductCount === 0) {
                logger.warning('No products found with images to update');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${totalProductCount} products to update master images`);

            // Get all products with their images
            const productsWithImages = await this.fetchProductsWithImages();
            logger.info(`Fetched ${productsWithImages.length} products for processing`);

            // Process products in batches
            const result = await this.batchProcessor.process(productsWithImages, async (batch) => {
                return await this.updateMasterImagesBatch(batch);
            });

            logger.success(`Product master images update completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Product master images update step failed', { error: error.message });
            throw error;
        }
    }

    async fetchProductsWithImages() {
        logger.info('Fetching products with their images from target database...');

        // Get all products that have images
        const productsWithImages = await this.targetDb.query(`
            SELECT DISTINCT pi.product_id
            FROM product_images pi
            JOIN products p ON pi.product_id = p.id
            WHERE p.archived_at IS NULL
            ORDER BY pi.product_id
        `);

        logger.info(`Found ${productsWithImages.length} products with images`);
        return productsWithImages.map(row => ({ product_id: row.product_id, images: [] }));
    }

    async updateMasterImagesBatch(products) {
        try {
            let updatedProductsCount = 0;

            // Process each product in the batch
            for (const product of products) {
                // Get the first image for this product (by position, then created_at)
                const masterImageResult = await this.targetDb.query(`
                    SELECT id as image_id, position
                    FROM product_images
                    WHERE product_id = $1
                    ORDER BY position ASC, created_at ASC
                    LIMIT 1
                `, [product.product_id]);

                if (masterImageResult.length === 0) {
                    logger.warning(`Product ${product.product_id}: No images found`);
                    continue;
                }

                const masterImage = masterImageResult[0];
                const masterImageId = masterImage.image_id;

                // Update product's master image ID
                await this.targetDb.query(
                    'UPDATE products SET product_master_image_id = $1, updated_at = NOW() WHERE id = $2',
                    [masterImageId, product.product_id]
                );

                // Update is_master flag for all images of this product
                // First, set all to false, then set master to true
                await this.targetDb.query(
                    'UPDATE product_images SET is_master = false, updated_at = NOW() WHERE product_id = $1',
                    [product.product_id]
                );

                await this.targetDb.query(
                    'UPDATE product_images SET is_master = true, updated_at = NOW() WHERE id = $1',
                    [masterImageId]
                );

                updatedProductsCount++;

                if (updatedProductsCount <= 5) { // Log first 5 updates for debugging
                    logger.debug(`Updated product ${product.product_id}: master image set to ${masterImageId}`);
                }
            }

            return { success: updatedProductsCount, failed: 0 };

        } catch (error) {
            logger.error('Failed to update master images batch', { error: error.message, count: products.length });
            return { success: 0, failed: products.length };
        }
    }
}

module.exports = ProductMasterImagesUpdateStep;
