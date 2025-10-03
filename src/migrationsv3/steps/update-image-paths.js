/*
# Update Image Paths Step

Updates product image paths by adding the backend URL prefix.
Processes all product images in the target database using batch processing.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class UpdateImagePathsStep {
    constructor(sourceDb, targetDb, config) {
        this.sourceDb = sourceDb; // Not used but kept for consistency
        this.targetDb = targetDb;
        this.config = config;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.updateImagePaths ? config.steps.updateImagePaths.batchSize : 500,
            parallelLimit: 1, // Sequential processing for updates
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Update image paths progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.imagePrefix = 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream/product';
    }

    async run() {
        logger.info('Starting update image paths step...');

        try {
            // Get total count of product images
            const totalCountResult = await this.targetDb.query('SELECT COUNT(*) as total FROM product_images');
            const totalImageCount = parseInt(totalCountResult[0].total);

            if (totalImageCount === 0) {
                logger.warning('No product images found to update');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${totalImageCount} product images to update`);

            // Get all product images
            const images = await this.fetchProductImages();
            logger.info(`Fetched ${images.length} product images for processing`);

            // Process images in batches
            const result = await this.batchProcessor.process(images, async (batch) => {
                return await this.updateImagePathsBatch(batch);
            });

            logger.success(`Update image paths completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Update image paths step failed', { error: error.message });
            throw error;
        }
    }

    async fetchProductImages() {
        logger.info('Fetching product images from target database...');

        const images = await this.targetDb.query(`
            SELECT id, image_url, updated_at
            FROM product_images
            WHERE image_url IS NOT NULL AND image_url != ''
            ORDER BY id
        `);

        logger.info(`Fetched ${images.length} product images`);
        return images;
    }

    async updateImagePathsBatch(images) {
        try {
            let updatedCount = 0;
            let skippedCount = 0;

            for (const image of images) {
                // Check if the path already has the prefix
                if (image.image_url.startsWith(this.imagePrefix)) {
                    skippedCount++;
                    continue;
                }

                // Add prefix to the image path
                const newImageUrl = `${this.imagePrefix}${image.image_url}`;

                // Update the image path in database
                await this.targetDb.query(
                    'UPDATE product_images SET image_url = $1, updated_at = NOW() WHERE id = $2',
                    [newImageUrl, image.id]
                );

                updatedCount++;

                if (updatedCount <= 3) { // Log first 3 updates for debugging
                    logger.debug(`Updated image path: ${image.image_url} -> ${newImageUrl}`);
                }
            }

            if (skippedCount > 0) {
                logger.info(`Batch: ${skippedCount} images already had the correct prefix, skipping`);
            }

            return { success: updatedCount, failed: 0 };

        } catch (error) {
            logger.error('Failed to update image paths batch', { error: error.message, count: images.length });
            return { success: 0, failed: images.length };
        }
    }
}

module.exports = UpdateImagePathsStep;
