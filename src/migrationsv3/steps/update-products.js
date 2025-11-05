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

        // Build WHERE conditions dynamically based on config
        let whereConditions = ['cpe.type_id = ?'];
        let queryParams = [this.config.filters.productTypes[0]]; // 'simple'

        // Add excluded product SKUs filter if configured
        if (this.config.filters.excludedProductSkus && this.config.filters.excludedProductSkus.length > 0) {
            const excludedSkus = this.config.filters.excludedProductSkus;
            const placeholders = excludedSkus.map(() => '?').join(', ');
            whereConditions.push(`cpe.sku NOT IN (${placeholders})`);
            queryParams.push(...excludedSkus);

            logger.info(`Excluding ${excludedSkus.length} products from migration: ${excludedSkus.join(', ')}`);
        }

        const whereClause = whereConditions.join(' AND ');

        const query = `
            SELECT
                cpe.entity_id,
                cpe.sku as product_sku,
                COALESCE(cpevs_name.value, cpf.name, cpe.sku) as name,
                COALESCE(cped.value, cpf.price) as price,
                COALESCE(cpet_desc.value, cpf.description) as description,
                cpf.short_description as short_description,
                cpf.image as image,
                cpf.url_key as url_key,
                cpe.created_at,
                cpe.updated_at,
                cpevs_meta_title.value as meta_title,
                cpevs_meta_desc.value as meta_description,
                cpet_cert.value as certification_number,
                cpet_coin.value as coin_number,
                cpevs_grade_prefix.value as grade_prefix,
                cped_grade_value.value as grade_value,
                cpet_grade_suffix.value as grade_suffix,
                cpf.year,
                cpf.country,
                cpf.country_value,
                cpevs_country_manuf.value as country_of_manufacture,
                eaov_country.value as country_int,
                cpei_cert_type.value as certification_type,
                cpei_archived.value as archived_status,
                sold_dates.first_sale_date as sold_date,
                sold_prices.last_sold_price as last_sold_price,
                cped_sold_on.value as eav_sold_date,
                cped_sold_price.value as eav_sold_price,
                cpev_sort.value as sort_string,
                cpei_status.value as status,
                cpei_visibility.value as visibility,
                GROUP_CONCAT(DISTINCT ccp.category_id) as category_ids,
                cpet_xero_sale.value as xero_sale_account
            FROM catalog_product_entity cpe
            LEFT JOIN catalog_product_flat_1 cpf ON cpe.entity_id = cpf.entity_id
            LEFT JOIN catalog_product_entity_varchar cpevs_name ON cpe.entity_id = cpevs_name.entity_id AND cpevs_name.attribute_id = 73 AND cpevs_name.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped ON cpe.entity_id = cped.entity_id AND cped.attribute_id = 77 AND cped.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_meta_title ON cpe.entity_id = cpevs_meta_title.entity_id AND cpevs_meta_title.attribute_id = 84 AND cpevs_meta_title.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_meta_desc ON cpe.entity_id = cpevs_meta_desc.entity_id AND cpevs_meta_desc.attribute_id = 86 AND cpevs_meta_desc.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_cert ON cpe.entity_id = cpet_cert.entity_id AND cpet_cert.attribute_id = 138 AND cpet_cert.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_coin ON cpe.entity_id = cpet_coin.entity_id AND cpet_coin.attribute_id = 142 AND cpet_coin.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_desc ON cpe.entity_id = cpet_desc.entity_id AND cpet_desc.attribute_id = 75 AND cpet_desc.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_country_manuf ON cpe.entity_id = cpevs_country_manuf.entity_id AND cpevs_country_manuf.attribute_id = 114 AND cpevs_country_manuf.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_grade_prefix ON cpe.entity_id = cpevs_grade_prefix.entity_id AND cpevs_grade_prefix.attribute_id = 135 AND cpevs_grade_prefix.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_grade_value ON cpe.entity_id = cped_grade_value.entity_id AND cped_grade_value.attribute_id = 148 AND cped_grade_value.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_grade_suffix ON cpe.entity_id = cpet_grade_suffix.entity_id AND cpet_grade_suffix.attribute_id = 153 AND cpet_grade_suffix.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_cert_type ON cpe.entity_id = cpei_cert_type.entity_id AND cpei_cert_type.attribute_id = 147 AND cpei_cert_type.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_archived ON cpe.entity_id = cpei_archived.entity_id AND cpei_archived.attribute_id = 144 AND cpei_archived.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_status ON cpe.entity_id = cpei_status.entity_id AND cpei_status.attribute_id = 97 AND cpei_status.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_visibility ON cpe.entity_id = cpei_visibility.entity_id AND cpei_visibility.attribute_id = 99 AND cpei_visibility.store_id = 0
            LEFT JOIN catalog_product_entity_datetime cped_sold_on ON cpe.entity_id = cped_sold_on.entity_id AND cped_sold_on.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_on' AND entity_type_id = 4) AND cped_sold_on.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_sold_price ON cpe.entity_id = cped_sold_price.entity_id AND cped_sold_price.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_price' AND entity_type_id = 4) AND cped_sold_price.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpev_sort ON cpe.entity_id = cpev_sort.entity_id AND cpev_sort.attribute_id = 141 AND cpev_sort.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_country ON cpe.entity_id = cpei_country.entity_id AND cpei_country.attribute_id = 158 AND cpei_country.store_id = 0
            LEFT JOIN eav_attribute_option_value eaov_country ON cpei_country.value = eaov_country.option_id AND eaov_country.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_xero_sale ON cpe.entity_id = cpet_xero_sale.entity_id AND cpet_xero_sale.attribute_id = 188 AND cpet_xero_sale.store_id = 0
            INNER JOIN catalog_category_product ccp ON cpe.entity_id = ccp.product_id
            LEFT JOIN (
                SELECT
                    soi.product_id,
                    MIN(so.created_at) as first_sale_date
                FROM sales_order_item soi
                JOIN sales_order so ON soi.order_id = so.entity_id
                WHERE so.status IN (${this.config.filters.orderStatuses.map(s => `'${s}'`).join(',')})
                GROUP BY soi.product_id
            ) sold_dates ON cpe.entity_id = sold_dates.product_id
            LEFT JOIN (
                SELECT
                    soi.product_id,
                    MAX(soi.price) as last_sold_price
                FROM sales_order_item soi
                JOIN sales_order so ON soi.order_id = so.entity_id
                WHERE so.status IN (${this.config.filters.orderStatuses.map(s => `'${s}'`).join(',')})
                GROUP BY soi.product_id
            ) sold_prices ON cpe.entity_id = sold_prices.product_id
            WHERE ${whereClause}
            GROUP BY cpe.entity_id, cpe.sku, cpevs_name.value, cped.value, cpf.name, cpf.price, cpf.description, cpf.short_description,
                      cpf.image, cpf.url_key, cpe.created_at, cpe.updated_at, cpevs_meta_title.value,
                      cpevs_meta_desc.value, cpet_cert.value, cpet_coin.value, cpet_desc.value, cpevs_country_manuf.value, cpevs_grade_prefix.value,
                      cped_grade_value.value, cpet_grade_suffix.value, cpf.year, cpf.country, cpf.country_value, eaov_country.value, cpei_cert_type.value, sold_dates.first_sale_date, sold_prices.last_sold_price, cpev_sort.value, cped_sold_on.value, cped_sold_price.value, cpei_status.value, cpei_visibility.value, cpet_xero_sale.value
            ORDER BY cpe.entity_id
        `;

        const updates = await this.sourceDb.query(query, queryParams);

        // Fetch URL keys separately and add to products (workaround for GROUP BY issue)
        if (updates.length > 0) {
            const entityIds = updates.map(p => p.entity_id);
            const urlKeysQuery = `
                SELECT entity_id, value as url_key
                FROM catalog_product_entity_varchar
                WHERE attribute_id = 119 AND store_id = 0 AND entity_id IN (${entityIds.join(',')})
            `;
            const urlKeys = await this.sourceDb.query(urlKeysQuery);

            // Create a map for fast lookup
            const urlKeyMap = new Map();
            urlKeys.forEach(uk => urlKeyMap.set(uk.entity_id, uk.url_key));

            // Add URL keys to products
            updates.forEach(product => {
                const eavUrlKey = urlKeyMap.get(product.entity_id);
                if (eavUrlKey) {
                    product.url_key = eavUrlKey;
                }
                // Keep flat table url_key as fallback if EAV is empty
            });
        }

        // Ensure category_ids is a string (GROUP_CONCAT may return NULL)
        updates.forEach(product => {
            if (!product.category_ids) {
                product.category_ids = '';
            }
        });

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

                    // Transform the update data using the same logic as products step
                    const transformedProduct = await this.dataTransformer.transformProduct(product);

                    // Extract only the fields we want to update
                    const updateData = {
                        is_active: transformedProduct.is_active,
                        status: transformedProduct.status,
                        quantity: transformedProduct.quantity,
                        price: transformedProduct.price,
                        sold_date: transformedProduct.sold_date,
                        archived_at: transformedProduct.archived_at,
                        sold_price: transformedProduct.sold_price
                    };

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