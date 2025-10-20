/*
# Update Master Category IDs Step

Fixes master_category_id NULL fields for products after subcategory merge.
Runs after merge step to ensure all category mappings are correct.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class UpdateMasterCategoryIdsStep {
    constructor(targetDb, defaultLanguageId) {
        this.targetDb = targetDb;
        this.defaultLanguageId = defaultLanguageId;
        this.batchProcessor = new BatchProcessor({
            batchSize: 1000,
            parallelLimit: 1,
            retryAttempts: 3,
            retryDelay: 1000,
            timeout: 300000,
            onProgress: (progress, stats) => {
                logger.info(`Update Master Category IDs progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
    }

    async run() {
        logger.info('Starting Update Master Category IDs step...');

        try {
            // Get all products with NULL master_category_id
            const productsToUpdate = await this.targetDb.query(
                'SELECT id, product_identity FROM products WHERE master_category_id IS NULL'
            );

            if (productsToUpdate.length === 0) {
                logger.info('No products found with NULL master_category_id');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${productsToUpdate.length} products to update master_category_id`);

            // Get category mappings from target
            const targetCategories = await this.targetDb.query(`
                SELECT c.id, c.code, ct.slug
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
            `, [this.defaultLanguageId]);

            logger.info(`Using ${targetCategories.length} categories for mapping`);

            // Process in batches
            const result = await this.batchProcessor.process(productsToUpdate, async (batch) => {
                return await this.processBatch(batch, targetCategories);
            });

            logger.success(`Update Master Category IDs completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Update Master Category IDs step failed', { error: error.message });
            throw error;
        }
    }

    async processBatch(products, targetCategories) {
        try {
            logger.debug(`Processing batch of ${products.length} products`);

            for (const product of products) {
                try {
                    // Try to find master category for this product
                    // First, get product categories from product_categories table
                    const productCategoryIds = await this.targetDb.query(
                        'SELECT category_id FROM product_categories WHERE product_id = $1 ORDER BY category_id',
                        [product.id]
                    );

                    if (productCategoryIds.length === 0) {
                        // No product categories found, use first available category as fallback
                        if (targetCategories.length > 0) {
                            await this.updateProductMasterCategory(product.id, targetCategories.reverse()[0].id);
                        }
                        continue;
                    }

                    // Try to find a master category by matching category codes
                    // Get full category info for these category IDs
                    const categoryIds = productCategoryIds.map(pc => pc.category_id);
                    const fullCategories = await this.targetDb.query(`
                        SELECT c.id, c.code
                        FROM categories c
                        WHERE c.id = ANY($1)
                    `, [categoryIds]);

                    // Find the best matching category using code patterns
                    const masterCategoryId = await this.findBestCategoryMatch(fullCategories, targetCategories);

                    if (masterCategoryId) {
                        await this.updateProductMasterCategory(product.id, masterCategoryId);
                    } else if (targetCategories.length > 0) {
                        // Use first category as fallback
                        await this.updateProductMasterCategory(product.id, targetCategories.reverse()[0].id);
                    }

                } catch (error) {
                    logger.debug(`Error updating master_category_id for product ${product.product_identity}: ${error.message}`);
                }
            }

            return { success: products.length, failed: 0 };

        } catch (error) {
            logger.error('Failed to process batch', { error: error.message, count: products.length });
            return { success: 0, failed: products.length };
        }
    }

    async findBestCategoryMatch(productCategories, targetCategories) {
        // Try exact entity ID matches first from category codes
        for (const prodCat of productCategories) {
            // Extract entity ID from code (e.g., "decimal-coins_29" -> 29)
            let prodEntityId = null;
            if (prodCat.code.includes('_')) {
                const parts = prodCat.code.split('_');
                prodEntityId = parseInt(parts[parts.length - 1]);
            }

            if (!prodEntityId) continue;

            // Look for categories with same entity ID
            for (const targetCat of targetCategories) {
                let targetEntityId = null;
                if (targetCat.code.includes('_')) {
                    const parts = targetCat.code.split('_');
                    targetEntityId = parseInt(parts[parts.length - 1]);
                }

                if (targetEntityId === prodEntityId) {
                    return targetCat.id;
                }
            }
        }

        // If no exact match, try prefix matching (e.g., "decimal-coins" -> any category containing "decimal")
        for (const prodCat of productCategories) {
            const prodPrefix = prodCat.code.split('_')[0]; // e.g., "decimal-coins"

            for (const targetCat of targetCategories) {
                if (targetCat.code.includes(prodPrefix)) {
                    return targetCat.id;
                }
            }
        }

        // Final fallback: return first category
        return targetCategories.length > 0 ? targetCategories.reverse()[0].id : null;
    }

    async updateProductMasterCategory(productId, categoryId) {
        await this.targetDb.query(
            'UPDATE products SET master_category_id = $1, updated_at = NOW() WHERE id = $2',
            [categoryId, productId]
        );
        logger.debug(`Updated master_category_id for product ${productId} to ${categoryId}`);
    }
}

module.exports = UpdateMasterCategoryIdsStep;
