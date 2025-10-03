/*
# Products Migration Step

Migrates products and their translations using batch processing.
*/

const { v4: uuidv4 } = require('uuid');
const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const DataTransformer = require('../lib/data-transformer');

class ProductsStep {
    constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = eavMapper;
        this.defaultLanguageId = defaultLanguageId;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.products.batchSize,
            parallelLimit: 1, // Sequential processing to avoid transaction conflicts
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Products migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.dataTransformer = new DataTransformer(this.targetDb);
    }

    async ensureCertificateProviders() {
        logger.info('Ensuring certificate providers exist...');

        try {
            // Check existing providers
            const existingProviders = await this.targetDb.query('SELECT id, name FROM certificate_providers');
            const providerMap = new Map(existingProviders.map(p => [p.name, p.id]));

            // Ensure PMG exists
            if (!providerMap.has('PMG')) {
                const pmgId = uuidv4();
                await this.targetDb.query(
                    'INSERT INTO certificate_providers (id, name, image, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                    [pmgId, 'PMG', 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream//Grading%20Services/pmg.png']
                );
                logger.info('Created PMG certificate provider');
            } else {
                logger.info('PMG certificate provider already exists');
            }

            // Ensure Other exists
            if (!providerMap.has('Other')) {
                const otherId = uuidv4();
                await this.targetDb.query(
                    'INSERT INTO certificate_providers (id, name, image, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                    [otherId, 'Other', null]
                );
                logger.info('Created Other certificate provider');
            } else {
                logger.info('Other certificate provider already exists');
            }

            // Ensure translations exist for PMG and Other
            await this.ensureCertificateProviderTranslations();

            logger.success('Certificate providers ensured');
        } catch (error) {
            logger.error('Failed to ensure certificate providers', { error: error.message });
            throw error;
        }
    }

    async ensureCertificateProviderTranslations() {
        logger.info('Ensuring certificate provider translations exist...');

        try {
            // Get PMG and Other provider IDs
            const providers = await this.targetDb.query('SELECT id, name FROM certificate_providers WHERE name IN ($1, $2)', ['PMG', 'Other']);
            const providerMap = new Map(providers.map(p => [p.name, p.id]));

            const pmgId = providerMap.get('PMG');
            const otherId = providerMap.get('Other');

            if (!pmgId || !otherId) {
                logger.warning('PMG or Other certificate providers not found');
                return;
            }

            // Get English language ID
            const languages = await this.targetDb.query('SELECT id FROM languages WHERE code = $1', ['en']);
            const englishLanguageId = languages.length > 0 ? languages[0].id : this.defaultLanguageId;

            // Check existing translations
            const existingTranslations = await this.targetDb.query(
                'SELECT certificate_provider_id FROM certificate_provider_translations WHERE certificate_provider_id IN ($1, $2)',
                [pmgId, otherId]
            );

            const existingProviderIds = new Set(existingTranslations.map(t => t.certificate_provider_id));

            // Add PMG translation if not exists
            if (!existingProviderIds.has(pmgId)) {
                await this.targetDb.query(`
                    INSERT INTO certificate_provider_translations (
                        id, description, authenticity, our_grade, note_on_taxes, created_at, updated_at, certificate_provider_id, language_id
                    ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW(), $6, $7)
                `, [
                    uuidv4(),
                    'Professional Coin Grading Service',
                    'PMG certified authenticity',
                    'PMG grading standards',
                    null,
                    pmgId,
                    englishLanguageId
                ]);
                logger.info('Created PMG certificate provider translation');
            }

            // Add Other translation if not exists
            if (!existingProviderIds.has(otherId)) {
                await this.targetDb.query(`
                    INSERT INTO certificate_provider_translations (
                        id, description, authenticity, our_grade, note_on_taxes, created_at, updated_at, certificate_provider_id, language_id
                    ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW(), $6, $7)
                `, [
                    uuidv4(),
                    'Other grading service',
                    'Alternative certification',
                    'Various grading standards',
                    null,
                    otherId,
                    englishLanguageId
                ]);
                logger.info('Created Other certificate provider translation');
            }

            logger.success('Certificate provider translations ensured');
        } catch (error) {
            logger.error('Failed to ensure certificate provider translations', { error: error.message });
            throw error;
        }
    }

    async run() {
        logger.info('Starting products migration step...');

        try {
            // 0. Ensure certificate providers exist
            await this.ensureCertificateProviders();

            // 1. Fetch source products
            const products = await this.fetchSourceProducts();

            if (products.length === 0) {
                logger.warning('No products found to migrate');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${products.length} products to migrate`);

            // 2. Transform and migrate products in batches
            const result = await this.batchProcessor.process(products, async (batch) => {
                return await this.processProductBatch(batch);
            });

            // 3. Migrate product translations (after products are inserted)
            await this.migrateProductTranslations(products);

            // 4. Migrate product prices separately (after products are inserted)
            await this.migrateProductPrices(products);

            // 5. Migrate product images
            await this.migrateProductImages(products);

            // 6. Migrate product certificate provider badges
            await this.migrateProductCertificateProviderBadges(products);

            // 7. Update master category IDs for all products
            await this.updateMasterCategoryIds(products);

            // 8. Ensure Xero tenants exist
            await this.ensureXeroTenants();

            // 9. Set Xero tenant IDs for products (based on categories or default)
            await this.updateXeroTenantIds(products);

            logger.success(`Products migration completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Products migration step failed', { error: error.message });
            throw error;
        }
    }

    async fetchSourceProducts() {
        logger.info('Fetching source products...');

        const query = `
            SELECT
                cpe.entity_id,
                cpe.sku as product_sku,
                COALESCE(cpevs_name.value, cpf.name, cpe.sku) as name,
                COALESCE(cped.value, cpf.price) as price,
                cpf.description as description,
                cpf.short_description as short_description,
                cpf.image as image,
                cpf.url_key as url_key,
                cpe.created_at,
                cpe.updated_at,
                cpevs_meta_title.value as meta_title,
                cpevs_meta_desc.value as meta_description,
                cpet_cert.value as certification_number,
                cpet_coin.value as coin_number,
                COALESCE(cpevs_grade_prefix.value, cpf.grade_prefix) as grade_prefix,
                COALESCE(cped_grade_value.value, cpf.grade_value) as grade_value,
                COALESCE(cpevs_grade_suffix.value, cpf.grade_suffix) as grade_suffix,
                cpf.year,
                cpf.country,
                cpf.country_value,
                cpei_cert_type.value as certification_type,
                cpei_archived.value as archived_status,
                sold_dates.first_sale_date as sold_date,
                sold_prices.last_sold_price as last_sold_price,
                GROUP_CONCAT(DISTINCT ccp.category_id) as category_ids
            FROM catalog_product_entity cpe
            LEFT JOIN catalog_product_flat_1 cpf ON cpe.entity_id = cpf.entity_id
            LEFT JOIN catalog_product_entity_varchar cpevs_name ON cpe.entity_id = cpevs_name.entity_id AND cpevs_name.attribute_id = 73 AND cpevs_name.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped ON cpe.entity_id = cped.entity_id AND cped.attribute_id = 77 AND cped.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_meta_title ON cpe.entity_id = cpevs_meta_title.entity_id AND cpevs_meta_title.attribute_id = 84 AND cpevs_meta_title.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_meta_desc ON cpe.entity_id = cpevs_meta_desc.entity_id AND cpevs_meta_desc.attribute_id = 86 AND cpevs_meta_desc.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_cert ON cpe.entity_id = cpet_cert.entity_id AND cpet_cert.attribute_id = 165 AND cpet_cert.store_id = 0
            LEFT JOIN catalog_product_entity_text cpet_coin ON cpe.entity_id = cpet_coin.entity_id AND cpet_coin.attribute_id = 166 AND cpet_coin.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_grade_prefix ON cpe.entity_id = cpevs_grade_prefix.entity_id AND cpevs_grade_prefix.attribute_id = 167 AND cpevs_grade_prefix.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_grade_value ON cpe.entity_id = cped_grade_value.entity_id AND cped_grade_value.attribute_id = 168 AND cped_grade_value.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpevs_grade_suffix ON cpe.entity_id = cpevs_grade_suffix.entity_id AND cpevs_grade_suffix.attribute_id = 169 AND cpevs_grade_suffix.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_cert_type ON cpe.entity_id = cpei_cert_type.entity_id AND cpei_cert_type.attribute_id = 147 AND cpei_cert_type.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_archived ON cpe.entity_id = cpei_archived.entity_id AND cpei_archived.attribute_id = 144 AND cpei_archived.store_id = 0
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
            WHERE cpe.type_id = ?
            GROUP BY cpe.entity_id, cpe.sku, cpevs_name.value, cped.value, cpf.name, cpf.price, cpf.description, cpf.short_description,
                     cpf.image, cpf.url_key, cpe.created_at, cpe.updated_at, cpevs_meta_title.value,
                     cpevs_meta_desc.value, cpet_cert.value, cpet_coin.value, cpevs_grade_prefix.value,
                     cped_grade_value.value, cpevs_grade_suffix.value, cpf.year, cpf.country, cpf.country_value, cpei_cert_type.value, sold_dates.first_sale_date, sold_prices.last_sold_price
            ORDER BY cpe.entity_id
        `;

        const products = await this.sourceDb.query(query, [
            this.config.filters.productTypes[0] // 'simple'
        ]);

        // Fetch URL keys separately and add to products (workaround for GROUP BY issue)
        if (products.length > 0) {
            const entityIds = products.map(p => p.entity_id);
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
            products.forEach(product => {
                const eavUrlKey = urlKeyMap.get(product.entity_id);
                if (eavUrlKey) {
                    product.url_key = eavUrlKey;
                }
                // Keep flat table url_key as fallback if EAV is empty
            });
        }

        // Ensure category_ids is a string (GROUP_CONCAT may return NULL)
        products.forEach(product => {
            if (!product.category_ids) {
                product.category_ids = '';
            }
        });

        logger.info(`Fetched ${products.length} products from source`);
        return products;
    }

    async processProductBatch(products) {
        try {
            // Validate input
            if (!products || !Array.isArray(products) || products.length === 0) {
                logger.warning('Empty or invalid products batch, skipping');
                return { success: 0, failed: 0 };
            }

            // Check first product for validity
            if (!products[0] || typeof products[0] !== 'object') {
                logger.warning('Invalid first product in batch, skipping');
                return { success: 0, failed: products.length };
            }

            // Transform products and translations
            const transformed = await this.dataTransformer.transformProducts(products, this.defaultLanguageId);

            // Validate transformed data
            if (!transformed || !transformed.products || !Array.isArray(transformed.products)) {
                logger.warning('Transform failed, skipping batch');
                return { success: 0, failed: products.length };
            }

            // Resolve country_id from ISO codes to actual IDs
            if (transformed.products.length > 0) {
                await this.resolveCountryIds(transformed.products);
            }

            // Insert products only (translations will be inserted separately)
            if (transformed.products.length > 0) {
                await this.insertProducts(transformed.products);
            }

            // Create product-category relations
            await this.createProductCategoryRelations(products);

            return { success: products.length, failed: 0 };

        } catch (error) {
            logger.error('Failed to process product batch', { error: error.message, count: products.length });
            return { success: 0, failed: products.length };
        }
    }

    async resolveCountryIds(products) {
        // Get unique ISO codes from products
        const isoCodes = [...new Set(products.map(p => p.country_id).filter(code => code))];

        if (isoCodes.length === 0) {
            logger.info('No country codes to resolve');
            return;
        }

        // Get country mappings from target database
        const countries = await this.targetDb.query('SELECT id, iso_code_2 FROM countries WHERE iso_code_2 = ANY($1)', [isoCodes]);
        const countryMap = new Map(countries.map(c => [c.iso_code_2, c.id]));

        logger.info(`Resolved ${countryMap.size} country codes to IDs`);

        // Update products with actual country IDs
        for (const product of products) {
            if (product.country_id && countryMap.has(product.country_id)) {
                product.country_id = countryMap.get(product.country_id);
            } else {
                product.country_id = null; // Set to null if no mapping found
            }
        }
    }

    async insertProducts(products) {
        const fieldCount = Object.keys(products[0]).length;
        const placeholders = products.map((_, index) => {
            const start = index * fieldCount + 1;
            const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
            return `(${params.join(', ')})`;
        }).join(', ');

        const values = products.flatMap(product => Object.values(product));
        const fields = Object.keys(products[0]).join(', ');

        const query = `
            INSERT INTO products (${fields})
            VALUES ${placeholders}
            ON CONFLICT (product_web_sku) DO UPDATE SET
                price = EXCLUDED.price,
                sold_date = EXCLUDED.sold_date,
                sold_price = EXCLUDED.sold_price,
                certificate_provider_id = EXCLUDED.certificate_provider_id,
                country_id = EXCLUDED.country_id,
                updated_at = NOW()
        `;

        await this.targetDb.query(query, values);
    }

    async insertProductTranslations(translations) {
        // Process translations individually to handle upserts properly
        for (const translation of translations) {
            const existing = await this.targetDb.query(
                'SELECT id FROM product_translations WHERE product_id = $1 AND language_id = $2',
                [translation.product_id, translation.language_id]
            );

            if (existing.length > 0) {
                // Update existing
                await this.targetDb.query(`
                    UPDATE product_translations SET
                        title = $1, description = $2, short_description = $3,
                        slug = $4, meta_title = $5, meta_description = $6,
                        meta_keywords = $7, updated_at = NOW()
                    WHERE id = $8
                `, [
                    translation.title, translation.description, translation.short_description,
                    translation.slug, translation.meta_title, translation.meta_description,
                    translation.meta_keywords, existing[0].id
                ]);
            } else {
                // Insert new
                await this.targetDb.query(`
                    INSERT INTO product_translations (
                        id, title, description, short_description, slug,
                        meta_title, meta_description, meta_keywords,
                        product_id, language_id, created_at, updated_at
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                `, Object.values(translation));
            }
        }
    }

    async createProductCategoryRelations(products) {
        // Get product mappings
        const productWebSkus = products.map(p => {
            const timestamp = Math.floor(new Date(p.created_at) / 1000);
            return p.product_sku + '-' + timestamp.toString(36);
        });

        const targetProducts = await this.targetDb.query(
            'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
            [productWebSkus]
        );

        const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

        // Get category mappings
        const targetCategories = await this.targetDb.query(`
            SELECT c.id, c.code, ct.slug
            FROM categories c
            LEFT JOIN category_translations ct ON c.id = ct.category_id
            WHERE ct.language_id = $1
        `, [this.defaultLanguageId]);

        const categoryMap = new Map();
        for (const cat of targetCategories) {
            if (cat.code.includes('_')) {
                const parts = cat.code.split('_');
                const entityId = parseInt(parts[parts.length - 1]);
                if (!isNaN(entityId)) {
                    categoryMap.set(entityId, cat.id);
                }
            }
        }

        // Create relations
        const relations = [];
        for (const product of products) {
            const productWebSku = product.product_sku + '-' + Math.floor(new Date(product.created_at) / 1000).toString(36);
            const productId = productMap.get(productWebSku);

            if (!productId || !product.category_ids) continue;

            const categoryIds = product.category_ids.split(',');
            for (const catId of categoryIds) {
                if (catId && catId.trim()) {
                    const categoryId = categoryMap.get(parseInt(catId.trim()));
                    if (categoryId) {
                        relations.push({
                            id: uuidv4(),
                            product_id: productId,
                            category_id: categoryId,
                            created_at: product.created_at,
                            updated_at: product.updated_at
                        });
                    }
                }
            }
        }

        if (relations.length > 0) {
            const fieldCount = Object.keys(relations[0]).length;
            const placeholders = relations.map((_, index) => {
                const start = index * fieldCount + 1;
                const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                return `(${params.join(', ')})`;
            }).join(', ');

            const values = relations.flatMap(rel => Object.values(rel));
            const fields = Object.keys(relations[0]).join(', ');

            await this.targetDb.query(`INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);
        }
    }

    async migrateProductTranslations(products) {
        logger.info('Starting product translations migration...');

        try {
            // Transform all products to get translations
            const transformed = await this.dataTransformer.transformProducts(products, this.defaultLanguageId);

            if (transformed.translations.length === 0) {
                logger.info('No translations to migrate');
                return;
            }

            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Update translation product_ids with actual target IDs
            const translationsWithIds = transformed.translations.map(translation => {
                const productWebSku = products.find(p => {
                    const timestamp = Math.floor(new Date(p.created_at) / 1000);
                    return p.product_sku + '-' + timestamp.toString(36) === translation.product_id;
                });

                if (productWebSku) {
                    const timestamp = Math.floor(new Date(productWebSku.created_at) / 1000);
                    const actualProductWebSku = productWebSku.product_sku + '-' + timestamp.toString(36);
                    const actualProductId = productMap.get(actualProductWebSku);

                    if (actualProductId) {
                        return {
                            ...translation,
                            product_id: actualProductId
                        };
                    }
                }

                return null;
            }).filter(t => t !== null);

            if (translationsWithIds.length === 0) {
                logger.info('No valid translations to migrate');
                return;
            }

            // Insert translations in batches
            const batchSize = 100;
            for (let i = 0; i < translationsWithIds.length; i += batchSize) {
                const batch = translationsWithIds.slice(i, i + batchSize);

                // Process each translation individually to handle upserts
                for (const translation of batch) {
                    const existing = await this.targetDb.query(
                        'SELECT id FROM product_translations WHERE product_id = $1 AND language_id = $2',
                        [translation.product_id, translation.language_id]
                    );

                    if (existing.length > 0) {
                        // Update existing
                        await this.targetDb.query(`
                            UPDATE product_translations SET
                                title = $1, description = $2, short_description = $3,
                                slug = $4, meta_title = $5, meta_description = $6,
                                meta_keywords = $7, updated_at = NOW()
                            WHERE id = $8
                        `, [
                            translation.title, translation.description, translation.short_description,
                            translation.slug, translation.meta_title, translation.meta_description,
                            translation.meta_keywords, existing[0].id
                        ]);
                    } else {
                        // Insert new
                        await this.targetDb.query(`
                            INSERT INTO product_translations (
                                id, title, description, short_description, slug,
                                meta_title, meta_description, meta_keywords,
                                product_id, language_id, created_at, updated_at
                            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                        `, Object.values(translation));
                    }
                }
            }

            logger.success(`Product translations migration completed: ${translationsWithIds.length} translations processed`);
        } catch (error) {
            logger.error('Product translations migration failed', { error: error.message });
        }
    }

    async migrateProductPrices(products) {
        logger.info('Starting product prices migration...');

        try {
            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get target currencies
            const targetCurrencies = await this.targetDb.query('SELECT id, code FROM currencies');
            const currencyMap = new Map(targetCurrencies.map(c => [c.code, c.id]));

            // Get source currency rates
            const currencyRates = await this.sourceDb.query('SELECT * FROM directory_currency_rate WHERE currency_from = "AUD"');

            const prices = [];
            let nullPriceCount = 0;
            for (const product of products) {
                const productWebSku = product.product_sku + '-' + Math.floor(new Date(product.created_at) / 1000).toString(36);
                const productId = productMap.get(productWebSku);

                if (!productId) continue;

                let audPrice = 0.00; // Default price
                if (product.price && product.price !== 'NULL' && product.price !== 'null') {
                    audPrice = parseFloat(product.price);
                    if (!isNaN(audPrice) && audPrice > 0) {
                        // Valid positive price
                    } else {
                        nullPriceCount++;
                        logger.debug(`Product ${productWebSku} has invalid price: ${product.price}, using 0.00`);
                        audPrice = 0.00;
                    }
                } else {
                    nullPriceCount++;
                    logger.debug(`Product ${productWebSku} has NULL/undefined price, using 0.00`);
                    audPrice = 0.00;
                }

                // Calculate prices for all currencies
                currencyRates.forEach(rate => {
                    const currencyId = currencyMap.get(rate.currency_to);
                    if (currencyId) {
                        prices.push({
                            id: uuidv4(),
                            base_amount: audPrice,
                            amount: audPrice * parseFloat(rate.rate),
                            currency_code: rate.currency_to,
                            currency_id: currencyId,
                            product_id: productId,
                            created_at: product.created_at,
                            updated_at: product.updated_at
                        });
                    }
                });
            }

            if (prices.length === 0) {
                logger.info('No prices to migrate');
                return;
            }

            // Batch insert prices with conflict handling
            const batchSize = 500;
            for (let i = 0; i < prices.length; i += batchSize) {
                const batch = prices.slice(i, i + batchSize);

                // Check existing prices to avoid duplicates
                const productIds = batch.map(p => p.product_id);
                const currencyIds = batch.map(p => p.currency_id);

                const existingPrices = await this.targetDb.query(`
                    SELECT product_id, currency_id
                    FROM product_prices
                    WHERE product_id = ANY($1) AND currency_id = ANY($2)
                `, [productIds, currencyIds]);

                const existingMap = new Map();
                existingPrices.forEach(ep => {
                    const key = `${ep.product_id}-${ep.currency_id}`;
                    existingMap.set(key, true);
                });

                // Filter out existing prices
                const newPrices = batch.filter(p => {
                    const key = `${p.product_id}-${p.currency_id}`;
                    return !existingMap.has(key);
                });

                if (newPrices.length > 0) {
                    const fieldCount = Object.keys(newPrices[0]).length;
                    const placeholders = newPrices.map((_, index) => {
                        const start = index * fieldCount + 1;
                        const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                        return `(${params.join(', ')})`;
                    }).join(', ');

                    const values = newPrices.flatMap(p => Object.values(p));
                    const fields = Object.keys(newPrices[0]).join(', ');

                    await this.targetDb.query(`INSERT INTO product_prices (${fields}) VALUES ${placeholders}`, values);
                }
            }

            logger.success(`Product prices migration completed: ${prices.length} prices processed`);
        } catch (error) {
            logger.error('Product prices migration failed', { error: error.message });
        }
    }

    async migrateProductImages(products) {
        logger.info('Starting product images migration...');

        try {
            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));
            logger.info(`Found ${productMap.size} products in target database for image migration`);

            // Get source product entity IDs
            const sourceEntityIds = products.map(p => p.entity_id);

            // Fetch product images from source
            const imagesQuery = `
                SELECT
                    mg.value_id,
                    mg.value as image_path,
                    mg.media_type,
                    mg.disabled,
                    mgv2e.entity_id as product_entity_id,
                    mgv.position,
                    mgv.label
                FROM catalog_product_entity_media_gallery mg
                JOIN catalog_product_entity_media_gallery_value_to_entity mgv2e ON mg.value_id = mgv2e.value_id
                LEFT JOIN catalog_product_entity_media_gallery_value mgv ON mg.value_id = mgv.value_id AND mgv.store_id = 0
                WHERE mgv2e.entity_id IN (${sourceEntityIds.join(',')})
                AND mg.disabled = 0
                AND mg.media_type = 'image'
                ORDER BY mgv2e.entity_id, mgv.position
            `;

            const sourceImages = await this.sourceDb.query(imagesQuery);
            logger.info(`Found ${sourceImages.length} images in source database`);

            if (sourceImages.length === 0) {
                logger.info('No product images to migrate');
                return;
            }

            // Transform and prepare images for target
            const targetImages = [];
            for (const image of sourceImages) {
                const productWebSku = products.find(p => p.entity_id === image.product_entity_id);
                if (!productWebSku) continue;

                const timestamp = Math.floor(new Date(productWebSku.created_at) / 1000);
                const actualProductWebSku = productWebSku.product_sku + '-' + timestamp.toString(36);
                const productId = productMap.get(actualProductWebSku);

                if (!productId) continue;

                // Determine if this is the master image (position = 1 or first image)
                const isMaster = image.position === 1 || image.position === '1' ||
                    (targetImages.filter(img => img.product_id === productId).length === 0);

                targetImages.push({
                    id: uuidv4(),
                    image_url: image.image_path,
                    alt: image.label || null,
                    position: parseInt(image.position) || 1,
                    is_master: isMaster,
                    created_at: productWebSku.created_at,
                    updated_at: productWebSku.updated_at,
                    product_id: productId
                });
            }

            logger.info(`Prepared ${targetImages.length} images for migration`);

            if (targetImages.length === 0) {
                logger.info('No valid images to migrate');
                return;
            }

            // Insert images in batches
            const batchSize = 200;
            let totalInserted = 0;

            for (let i = 0; i < targetImages.length; i += batchSize) {
                const batch = targetImages.slice(i, i + batchSize);

                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(img => Object.values(img));
                const fields = Object.keys(batch[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_images (${fields}) VALUES ${placeholders}`, values);
                totalInserted += batch.length;
            }

            logger.success(`Product images migration completed: ${totalInserted} images inserted`);
        } catch (error) {
            logger.error('Product images migration failed', { error: error.message });
        }
    }

    async migrateProductCertificateProviderBadges(products) {
        logger.info('Starting product certificate provider badges migration...');

        try {
            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));
            logger.info(`Found ${productMap.size} products in target database for badge migration`);

            // Get valid target product IDs (avoid null values)
            const validProductIds = Array.from(productMap.values()).filter(id => id);

            if (validProductIds.length === 0) {
                logger.info('No valid products found for badge migration');
                return;
            }

            // Get all certificate provider badges from target
            const targetBadges = await this.targetDb.query('SELECT id FROM certificate_provider_badges');
            logger.info(`Found ${targetBadges.length} certificate provider badges in target database`);

            if (targetBadges.length === 0) {
                logger.info('No certificate provider badges found in target database');
                return;
            }

            // Check existing product-badge relations to avoid duplicates
            logger.info('Checking existing product-badge relations to prevent duplicates...');
            const existingRelations = await this.targetDb.query(`
                SELECT product_id, certificate_provider_badge_id
                FROM product_certificate_provider_badges
                WHERE product_id = ANY($1)
            `, [validProductIds]);

            // Create a set for fast lookup of existing relations
            const existingRelationsSet = new Set();
            existingRelations.forEach(rel => {
                const key = `${rel.product_id}-${rel.certificate_provider_badge_id}`;
                existingRelationsSet.add(key);
            });

            logger.info(`Found ${existingRelations.length} existing product-badge relations`);

            // Create many-to-many relations: every product with every badge (only missing ones)
            const badgeRelations = [];
            let skippedExisting = 0;

            for (const [productWebSku, productId] of productMap.entries()) {
                if (!productId) continue;

                for (const badge of targetBadges) {
                    const relationKey = `${productId}-${badge.id}`;

                    // Skip if relation already exists
                    if (existingRelationsSet.has(relationKey)) {
                        skippedExisting++;
                        continue;
                    }

                    // Find the original product for created_at timestamp
                    const originalProduct = products.find(p => {
                        const timestamp = Math.floor(new Date(p.created_at) / 1000);
                        return p.product_sku + '-' + timestamp.toString(36) === productWebSku;
                    });

                    badgeRelations.push({
                        id: uuidv4(),
                        is_active: true,
                        created_at: originalProduct ? originalProduct.created_at : new Date(),
                        certificate_provider_badge_id: badge.id,
                        product_id: productId
                    });
                }
            }

            logger.info(`Prepared ${badgeRelations.length} new product-badge relations for migration`);
            logger.info(`Skipped ${skippedExisting} existing relations to prevent duplicates`);
            logger.info(`Total relations considered: ${validProductIds.length * targetBadges.length} (${validProductIds.length} products × ${targetBadges.length} badges)`);

            if (badgeRelations.length === 0) {
                logger.info('No new badge relations to migrate');
                return;
            }

            // Insert new relations in batches
            const batchSize = 1000; // Larger batch size for many-to-many relations
            let totalInserted = 0;

            for (let i = 0; i < badgeRelations.length; i += batchSize) {
                const batch = badgeRelations.slice(i, i + batchSize);

                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(rel => Object.values(rel));
                const fields = Object.keys(batch[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_certificate_provider_badges (${fields}) VALUES ${placeholders}`, values);
                totalInserted += batch.length;
            }

            logger.success(`Product certificate provider badges migration completed: ${totalInserted} new relations inserted (${skippedExisting} existing relations skipped)`);
        } catch (error) {
            logger.error('Product certificate provider badges migration failed', { error: error.message });
        }
    }

    async updateMasterCategoryIds(products) {
        logger.info('Updating master category IDs for products...');

        try {
            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));
            logger.info(`Found ${productMap.size} products in target database`);

            // Get category mappings from target
            const targetCategories = await this.targetDb.query(`
                SELECT c.id, c.code, ct.slug
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
            `, [this.defaultLanguageId]);

            logger.info(`Found ${targetCategories.length} categories in target database`);

            // Update master category IDs for each product - improved logic
            let updatedCount = 0;
            let processedCount = 0;
            let fallbackCount = 0;

            for (const product of products) {
                processedCount++;
                const productWebSku = product.product_sku + '-' + Math.floor(new Date(product.created_at) / 1000).toString(36);
                const productId = productMap.get(productWebSku);

                if (!productId) {
                    if (processedCount <= 5) { // Log first 5 missing products
                        logger.debug(`Product not found in target: ${productWebSku}`);
                    }
                    continue;
                }

                if (!product.category_ids) {
                    if (processedCount <= 5) { // Log first 5 products without categories
                        logger.debug(`Product has no category_ids: ${productWebSku}`);
                    }
                    continue;
                }

                // Get all category IDs for this product
                const sourceCategoryIds = product.category_ids.split(',').map(id => parseInt(id.trim())).filter(id => !isNaN(id));

                if (sourceCategoryIds.length === 0) {
                    if (processedCount <= 5) { // Log first 5 products with invalid category_ids
                        logger.debug(`Product has invalid category_ids: ${productWebSku} -> "${product.category_ids}"`);
                    }
                    continue;
                }

                // Find the master category - enhanced logic with fallbacks
                let masterCategoryId = await this.findMasterCategoryId(targetCategories, sourceCategoryIds);

                if (!masterCategoryId) {
                    // Fallback: Pick the first available category (any category that exists)
                    if (targetCategories.length > 0) {
                        masterCategoryId = targetCategories[0].id;
                        fallbackCount++;
                        if (fallbackCount <= 5) {
                            logger.debug(`Using fallback category ${targetCategories[0].code} for product ${productWebSku}`);
                        }
                    }
                }

                if (!masterCategoryId) {
                    if (processedCount <= 5) { // Log first 5 products with no master category
                        logger.debug(`No master category could be determined for product ${productWebSku}`);
                    }
                    continue;
                }

                await this.targetDb.query(
                    'UPDATE products SET master_category_id = $1, updated_at = NOW() WHERE id = $2',
                    [masterCategoryId, productId]
                );
                updatedCount++;

                if (updatedCount <= 5) { // Log first 5 successful updates
                    logger.debug(`Updated master_category_id for product ${productWebSku}: ${masterCategoryId}`);
                }
            }

            logger.info(`Processed ${processedCount} products, updated ${updatedCount} master category IDs (${fallbackCount} with fallback)`);
            logger.success(`Updated master category IDs for ${updatedCount} products`);
        } catch (error) {
            logger.error('Failed to update master category IDs', { error: error.message });
        }
    }

    async findMasterCategoryId(targetCategories, sourceCategoryIds) {
        // Try to find exact matches first
        for (const sourceCategoryId of sourceCategoryIds) {
            for (const targetCategory of targetCategories) {
                let entityId = null;

                if (targetCategory.code.includes('_')) {
                    // url_key_entity_id format
                    const parts = targetCategory.code.split('_');
                    entityId = parseInt(parts[parts.length - 1]);
                } else if (targetCategory.code.startsWith('category-')) {
                    // category-entity_id format
                    const parts = targetCategory.code.split('-');
                    entityId = parseInt(parts[parts.length - 1]);
                }

                if (!isNaN(entityId) && entityId === sourceCategoryId) {
                    return targetCategory.id;
                }
            }
        }

        // If no exact match, try to find similar categories (same prefix)
        for (const sourceCategoryId of sourceCategoryIds) {
            for (const targetCategory of targetCategories) {
                // Check if this category might be a parent/sibling of the source category
                // For example, if source has category 29 and 134, and we have category 18 (decimal-coins_18),
                // category 18 might be the parent
                if (targetCategory.code.includes('decimal') && sourceCategoryId === 29) {
                    return targetCategory.id;
                }
                if (targetCategory.code.includes('coins') && (sourceCategoryId === 29 || sourceCategoryId === 134)) {
                    return targetCategory.id;
                }
                if (targetCategory.code.includes('latest') && sourceCategoryId === 6) {
                    return targetCategory.id;
                }
            }
        }

        return null;
    }

    async ensureXeroTenants() {
        logger.info('Ensuring Xero tenants exist for account mapping...');

        try {
            // Xero account mapping from source - codes as IDs, names as tenant names
            const xeroAccountMapping = {
                '41051': 'Sales PCGS fees',
                '41055': 'Sales - Pre-grade fees',
                '41100': 'Sales - Sovereigns and Halves',
                '41200': 'Sales - Commonwealth Coins',
                '41320': 'Sales - Rarities',
                '41400': 'Sales - Pre-decimal Proofs',
                '41450': 'Sales - Decimal Coins',
                '41500': 'Sales - World Coins',
                '41510': 'Sales - Canada',
                '41520': 'Sales - Fiji',
                '41530': 'Sales - Great Britain',
                '41540': 'Sales - India',
                '41550': 'Sales - South Africa',
                '41560': 'Sales - United States',
                '41600': 'Sales - Bullion',
                '41800': 'Sales - Pre-decimal Banknotes',
                '41850': 'Sales - Decimal Banknotes',
                '41900': 'Sales - Accessories',
                '41925': 'Sales - Sovereign exonumia',
                '41950': 'Sales - PCGS-grading fees',
                '41951': 'Sales - NGC-grading fees',
                '42000': 'Sales - Proclamation Coins',
                '43000': 'Consignment commissions earned',
                '44000': 'Insurance on sales collected',
                '44001': 'Insurance on PCGS submissions collected',
                '45000': 'Postage/shipping collected',
                '45500': 'Credit card fees collected',
                '45600': 'Paypal fees collected',
                '45700': 'Stripe fees collected',
                '46000': 'General interest charges collected and deposits withheld',
                '47000': 'Foreign exchange gains',
                '48000': 'Miscellaneous Income',
                '49000': 'Lot transfers suspense account',
                '49997': 'Sales - Collaborative deals',
                '49998': 'Sales - Agent bids',
                '49999': 'Sales - Commission refund',
                '50001': 'Unfranked portfolio income',
                '50002': 'Discounted capital gains and CGT concession from portfolio investments',
                '9998test': 'Comm (test account)'
            };

            // Get existing tenants
            const existingTenants = await this.targetDb.query('SELECT id FROM xero_tenants');
            const existingTenantIds = new Set(existingTenants.map(t => t.id));

            // Get integration ID (assuming there's only one)
            const integrations = await this.targetDb.query('SELECT id FROM xero_integrations LIMIT 1');
            const integrationId = integrations.length > 0 ? integrations[0].id : null;

            if (!integrationId) {
                logger.warning('No Xero integration found, skipping tenant creation');
                return;
            }

            // Create missing tenants (using account codes as IDs, names as tenant names)
            const tenantsToCreate = [];
            for (const [accountCode, accountName] of Object.entries(xeroAccountMapping)) {
                if (!existingTenantIds.has(accountCode)) {
                    tenantsToCreate.push({
                        id: accountCode,
                        tenant_id: accountCode, // Same as ID for now
                        name: accountName,
                        integration_id: integrationId,
                        created_at: new Date(),
                        updated_at: new Date()
                    });
                }
            }

            if (tenantsToCreate.length > 0) {
                // Bulk insert tenants
                const fieldCount = Object.keys(tenantsToCreate[0]).length;
                const placeholders = tenantsToCreate.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = tenantsToCreate.flatMap(tenant => Object.values(tenant));
                const fields = Object.keys(tenantsToCreate[0]).join(', ');

                await this.targetDb.query(`INSERT INTO xero_tenants (${fields}) VALUES ${placeholders}`, values);
                logger.success(`Created ${tenantsToCreate.length} Xero tenants`);
            } else {
                logger.info('All Xero tenants already exist');
            }

        } catch (error) {
            logger.error('Failed to ensure Xero tenants', { error: error.message });
            throw error;
        }
    }

    async updateXeroTenantIds(products) {
        logger.info('Setting Xero tenant IDs for products based on category mapping...');

        try {
            // Xero account mapping from user's list (codes as keys, identifiers)
            const xeroAccountMapping = {
                'Sales PCGS fees': '41051',
                'Sales - Pre-grade fees': '41055',
                'Sales - Sovereigns and Halves': '41100',
                'Sales - Commonwealth Coins': '41200',
                'Sales - Rarities': '41320',
                'Sales - Pre-decimal Proofs': '41400',
                'Sales - Decimal Coins': '41450',
                'Sales - World Coins': '41500',
                'Sales - Canada': '41510',
                'Sales - Fiji': '41520',
                'Sales - Great Britain': '41530',
                'Sales - India': '41540',
                'Sales - South Africa': '41550',
                'Sales - United States': '41560',
                'Sales - Bullion': '41600',
                'Sales - Pre-decimal Banknotes': '41800',
                'Sales - Decimal Banknotes': '41850',
                'Sales - Accessories': '41900',
                'Sales - Sovereign exonumia': '41925',
                'Sales - PCGS-grading fees': '41950',
                'Sales - NGC-grading fees': '41951',
                'Sales - Proclamation Coins': '42000',
                'Consignment commissions earned': '43000',
                'Insurance on sales collected': '44000',
                'Insurance on PCGS submissions collected': '44001',
                'Postage/shipping collected': '45000',
                'Credit card fees collected': '45500',
                'Paypal fees collected': '45600',
                'Stripe fees collected': '45700',
                'General interest charges collected and deposits withheld': '46000',
                'Foreign exchange gains': '47000',
                'Miscellaneous Income': '48000',
                'Lot transfers suspense account': '49000',
                'Sales - Collaborative deals': '49997',
                'Sales - Agent bids': '49998',
                'Sales - Commission refund': '49999',
                'Unfranked portfolio income': '50001',
                'Discounted capital gains and CGT concession from portfolio investments': '50002',
                'Comm (test account)': '9998test'
            };

            // Get product mappings
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));
            logger.info(`Found ${productMap.size} products in target database for Xero tenant ID update`);

            // Get category mappings for account lookup
            const targetCategories = await this.targetDb.query(`
                SELECT c.id, c.code, ct.slug, ct.title
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
            `, [this.defaultLanguageId]);

            logger.info(`Found ${targetCategories.length} categories in target database`);

            // Create category ID to name mapping for Xero account lookup
            const categoryToAccountMap = new Map();
            for (const cat of targetCategories) {
                if (cat.code.includes('_')) {
                    const parts = cat.code.split('_');
                    const entityId = parseInt(parts[parts.length - 1]);
                    if (!isNaN(entityId) && cat.title) {
                        // Try to find matching Xero account based on category name
                        for (const [accountName, accountCode] of Object.entries(xeroAccountMapping)) {
                            if (cat.title.toLowerCase().includes(accountName.toLowerCase().split(' - ')[0]) ||
                                accountName.toLowerCase().includes(cat.title.toLowerCase())) {
                                categoryToAccountMap.set(entityId, accountCode);
                                break;
                            }
                        }
                    }
                }
            }

            logger.info(`Created Xero account mapping for ${categoryToAccountMap.size} categories`);

            // Update Xero tenant IDs for each product based on master_category_id
            let updatedCount = 0;
            let processedCount = 0;

            for (const product of products) {
                processedCount++;
                const productWebSku = product.product_sku + '-' + Math.floor(new Date(product.created_at) / 1000).toString(36);
                const productId = productMap.get(productWebSku);

                if (!productId) {
                    if (processedCount <= 5) { // Log first 5 missing products
                        logger.debug(`Product not found in target: ${productWebSku}`);
                    }
                    continue;
                }

                if (!product.category_ids) {
                    if (processedCount <= 5) { // Log first 5 products without categories
                        logger.debug(`Product has no category_ids: ${productWebSku}`);
                    }
                    continue;
                }

                // Get all category IDs for this product
                const sourceCategoryIds = product.category_ids.split(',').map(id => parseInt(id.trim())).filter(id => !isNaN(id));

                // Find Xero account (use first category that has a mapping)
                let xeroTenantId = null;
                for (const sourceCategoryId of sourceCategoryIds) {
                    xeroTenantId = categoryToAccountMap.get(sourceCategoryId);
                    if (xeroTenantId) {
                        break; // Use first valid Xero account found
                    }
                }

                // If no category mapping found, use default "Sales - Commission refund"
                if (!xeroTenantId) {
                    xeroTenantId = xeroAccountMapping['Sales - Commission refund'];
                }

                if (!xeroTenantId) {
                    if (processedCount <= 5) { // Log first 5 products with unmapped categories
                        logger.debug(`Using default Xero account for product ${productWebSku} (categories: ${sourceCategoryIds.join(',')})`);
                    }
                    xeroTenantId = '49999'; // Hard-coded default
                }

                await this.targetDb.query(
                    'UPDATE products SET xero_tenant_id = $1, updated_at = NOW() WHERE id = $2',
                    [xeroTenantId, productId]
                );
                updatedCount++;

                if (updatedCount <= 5) { // Log first 5 successful updates
                    logger.debug(`Set xero_tenant_id to ${xeroTenantId} for product ${productWebSku}`);
                }
            }

            logger.info(`Processed ${processedCount} products, updated ${updatedCount} Xero tenant IDs`);
            logger.success(`Updated Xero tenant IDs for ${updatedCount} products`);
        } catch (error) {
            logger.error('Failed to update Xero tenant IDs', { error: error.message });
        }
    }
}

module.exports = ProductsStep;
