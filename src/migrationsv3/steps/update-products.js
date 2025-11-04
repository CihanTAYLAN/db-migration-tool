/*
# Update Products Step

Updates existing products with latest field values from source database.
This step is designed to be run manually after initial migration to sync changes.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const DataTransformer = require('../lib/data-transformer');

class UpdateProductsStep {
    constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = eavMapper;
        this.defaultLanguageId = defaultLanguageId;

        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.updateProducts.batchSize,
            parallelLimit: config.steps.updateProducts.parallelLimit || 1,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Update products progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.dataTransformer = new DataTransformer(this.targetDb);
    }

    async run() {
        logger.info('Starting update products step...');

        try {
            // 1. Fetch source product updates
            const sourceUpdates = await this.fetchSourceProductUpdates();

            if (sourceUpdates.length === 0) {
                logger.warning('No product updates found');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${sourceUpdates.length} products to update`);

            // 2. Transform updates and apply them in batches
            const result = await this.batchProcessor.process(sourceUpdates, async (batch) => {
                return await this.processUpdateBatch(batch);
            });

            logger.success(`Update products step completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Update products step failed', { error: error.message });
            throw error;
        }
    }

    async fetchSourceProductUpdates() {
        logger.info('Fetching source product updates...');

        const query = `
            SELECT
                cpe.entity_id,
                cpe.sku as product_sku,
                cpf.price,
                cpe.created_at,
                cpe.updated_at,
                cpei_status.value as status,
                cpei_visibility.value as visibility,
                cped_sold_on.value as eav_sold_date,
                cped_sold_price.value as eav_sold_price,
                cpei_archived.value as archived_status,
                sold_dates.first_sale_date as sold_date,
                sold_prices.last_sold_price as last_sold_price
            FROM catalog_product_entity cpe
            LEFT JOIN catalog_product_flat_1 cpf ON cpe.entity_id = cpf.entity_id
            LEFT JOIN catalog_product_entity_int cpei_status ON cpe.entity_id = cpei_status.entity_id AND cpei_status.attribute_id = 97 AND cpei_status.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_visibility ON cpe.entity_id = cpei_visibility.entity_id AND cpei_visibility.attribute_id = 99 AND cpei_visibility.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_sold_on ON cpe.entity_id = cped_sold_on.entity_id AND cped_sold_on.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_on' AND entity_type_id = 4) AND cped_sold_on.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_sold_price ON cpe.entity_id = cped_sold_price.entity_id AND cped_sold_price.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_price' AND entity_type_id = 4) AND cped_sold_price.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_archived ON cpe.entity_id = cpei_archived.entity_id AND cpei_archived.attribute_id = 144 AND cpei_archived.store_id = 0
            LEFT JOIN (
                SELECT
                    soi.product_id,
                    MIN(so.created_at) as first_sale_date
                FROM sales_order_item soi
                JOIN sales_order so ON soi.order_id = so.entity_id
                WHERE so.status IN ('complete', 'a_complete')
                GROUP BY soi.product_id
            ) sold_dates ON cpe.entity_id = sold_dates.product_id
            LEFT JOIN (
                SELECT
                    soi.product_id,
                    MAX(soi.price) as last_sold_price
                FROM sales_order_item soi
                JOIN sales_order so ON soi.order_id = so.entity_id
                WHERE so.status IN ('complete', 'a_complete')
                GROUP BY soi.product_id
            ) sold_prices ON cpe.entity_id = sold_prices.product_id
            WHERE cpe.type_id = 'simple'
            ORDER BY cpe.entity_id
        `;

        const updates = await this.sourceDb.query(query);
        logger.info(`Fetched ${updates.length} product updates from source`);
        return updates;
    }

    async processUpdateBatch(products) {
        try {
            // Get target product mappings by SKU
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.targetDb.query(
                'SELECT id, product_sku FROM products WHERE product_sku = ANY($1)',
                [productSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_sku, p.id]));

            let successCount = 0;
            let failedCount = 0;

            // Process each product update
            for (const product of products) {
                try {
                    const targetProductId = productMap.get(product.product_sku);

                    if (!targetProductId) {
                        logger.debug(`Product ${product.product_sku} not found in target database, skipping`);
                        failedCount++;
                        continue;
                    }

                    // Transform the update data
                    const updateData = this.transformProductUpdate(product);

                    // Apply the update
                    await this.updateProduct(targetProductId, updateData);
                    successCount++;

                } catch (error) {
                    logger.error(`Failed to update product ${product.product_sku}`, { error: error.message });
                    failedCount++;
                }
            }

            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process update batch', { error: error.message });
            return { success: 0, failed: products.length };
        }
    }

    transformProductUpdate(sourceProduct) {
        // Transform the source data to match target schema
        const updateData = {};

        // is_active: status=1 (Enabled) AND visibility=2 (Catalog) OR 4 (Catalog, Search) = ACTIVE
        updateData.is_active = (
            sourceProduct.status !== null &&
            sourceProduct.status !== undefined &&
            String(sourceProduct.status) === '1' &&
            sourceProduct.visibility !== null &&
            sourceProduct.visibility !== undefined &&
            (String(sourceProduct.visibility) === '2' || String(sourceProduct.visibility) === '4')
        );

        // status: based on archived_status and sold_date
        updateData.status = this.determineProductStatus(sourceProduct);

        // quantity: always 1 for simple products
        updateData.quantity = 1;

        // price: parse from source
        updateData.price = parseFloat(sourceProduct.price) || 0;

        // sold_date: prefer EAV sold_on, fallback to sales order date
        updateData.sold_date = sourceProduct.eav_sold_date || sourceProduct.sold_date || null;

        // archived_at: calculate if product is archived and has sold_date
        updateData.archived_at = this.calculateArchivedAt(sourceProduct);

        // sold_price: prefer EAV sold_price, fallback to sales order price
        updateData.sold_price = sourceProduct.eav_sold_price || sourceProduct.last_sold_price || null;

        return updateData;
    }

    determineProductStatus(product) {
        // Primary source: archived_status from source
        if (product.archived_status !== null && product.archived_status !== undefined) {
            const archivedStatus = parseInt(product.archived_status);
            if (archivedStatus === 1) {
                return 'archived';
            }
        }

        // Secondary source: if not archived and has sold_date (EAV or sales order), then 'sold'
        if (product.eav_sold_date || product.sold_date) {
            return 'sold';
        }

        // Default: pending
        return 'pending';
    }

    calculateArchivedAt(product) {
        // Only calculate archived_at if product is archived (archived_status = 1)
        // and has a sold_date (EAV sold_on takes priority)
        const soldDateValue = product.eav_sold_date || product.sold_date;
        if (product.archived_status === 1 && soldDateValue) {
            const soldDate = new Date(soldDateValue);
            const archivedDate = new Date(soldDate.getTime() + (21 * 24 * 60 * 60 * 1000)); // 21 days
            return archivedDate;
        }
        return null;
    }

    async updateProduct(productId, updateData) {
        const fields = [];
        const values = [];
        let paramIndex = 1;

        // Build dynamic UPDATE query based on available fields
        Object.keys(updateData).forEach(key => {
            if (updateData[key] !== undefined) {
                fields.push(`${key} = $${paramIndex}`);
                values.push(updateData[key]);
                paramIndex++;
            }
        });

        if (fields.length === 0) {
            logger.debug(`No fields to update for product ID ${productId}`);
            return;
        }

        fields.push(`updated_at = NOW()`);

        const query = `
            UPDATE products
            SET ${fields.join(', ')}
            WHERE id = $${paramIndex}
        `;

        values.push(productId);

        await this.targetDb.query(query, values);
        logger.debug(`Updated product ${productId} with fields: ${Object.keys(updateData).join(', ')}`);
    }
}

module.exports = UpdateProductsStep;