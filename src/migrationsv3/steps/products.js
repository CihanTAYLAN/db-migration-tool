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

        // Cache for repeated lookups (performance optimization)
        this.countryCache = new Map(); // isoCode -> countryId
        this.categoryCache = new Map(); // sourceEntityId -> targetCategoryId
        this.xeroAccountCache = new Map(); // saleAccount -> { accountId, tenantId }

        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.products.batchSize,
            parallelLimit: config.steps.products.parallelLimit || 2, // Parallel processing for performance
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
            }

            // Ensure PCGS exists
            if (!providerMap.has('PCGS')) {
                const pcgsId = uuidv4();
                await this.targetDb.query(
                    'INSERT INTO certificate_providers (id, name, image, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                    [pcgsId, 'PCGS', 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream//Grading%20Services/pcgs.png']
                );
                logger.info('Created PCGS certificate provider');
            }

            // Ensure NGC exists
            if (!providerMap.has('NGC')) {
                const ngcId = uuidv4();
                await this.targetDb.query(
                    'INSERT INTO certificate_providers (id, name, image, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                    [ngcId, 'NGC', 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream//Grading%20Services/ngc.png']
                );
                logger.info('Created NGC certificate provider');
            }

            // Ensure Uncertified exists (for unknown certificate providers)
            if (!providerMap.has('Uncertified')) {
                const uncertifiedId = uuidv4();
                await this.targetDb.query(
                    'INSERT INTO certificate_providers (id, name, image, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                    [uncertifiedId, 'Uncertified', null]
                );
                logger.info('Created Uncertified certificate provider');
            } else {
                logger.info('Uncertified certificate provider already exists');
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

            // Ensure provider badges exist for all providers
            await this.ensureCertificateProviderBadges();

            // Ensure translations exist for PMG and Other
            await this.ensureCertificateProviderTranslations();

            logger.success('Certificate providers ensured');
        } catch (error) {
            logger.error('Failed to ensure certificate providers', { error: error.message });
            throw error;
        }
    }

    async ensureCertificateProviderBadges() {
        logger.info('Ensuring certificate provider badges exist for all providers...');

        try {
            // Get all providers
            const providers = await this.targetDb.query('SELECT id, name FROM certificate_providers');
            const providerMap = new Map(providers.map(p => [p.name, p.id]));

            // Define standard badges for all providers
            const standardBadges = [
                { name: 'Gold shield', description: 'Premium certification shield' },
                { name: 'NFC technology', description: 'Near Field Communication enabled' },
                { name: 'True View images', description: 'High-resolution magnification technology' }
            ];

            // Check existing badges (only provider relationship, no name column in main table)
            const existingBadges = await this.targetDb.query('SELECT id, certificate_provider_id FROM certificate_provider_badges');
            const badgeKeySet = new Set();

            existingBadges.forEach(badge => {
                const key = badge.certificate_provider_id;
                badgeKeySet.add(key); // Track provider IDs that already have badges
            });

            logger.info(`Found ${existingBadges.length} existing badges across all providers`);

            // Also check translations to avoid duplicate badge creation per provider
            const existingTranslations = await this.targetDb.query('SELECT certificate_provider_badge_id, name FROM certificate_provider_badge_translations');

            // Group badges by provider for quick lookup
            const providerBadgeMap = new Map();
            for (const badge of existingBadges) {
                if (!providerBadgeMap.has(badge.certificate_provider_id)) {
                    providerBadgeMap.set(badge.certificate_provider_id, []);
                }
                providerBadgeMap.get(badge.certificate_provider_id).push(badge.id);
            }

            // Get language ID for translations
            const languages = await this.targetDb.query('SELECT id FROM languages WHERE code = $1', ['en']);
            const englishLanguageId = languages.length > 0 ? languages[0].id : 'en'; // fallback

            // Create badges for each provider
            for (const [providerName, providerId] of providerMap) {
                if (!providerId) continue;

                // Check if this provider already has badges
                if (providerBadgeMap.has(providerId)) {
                    logger.debug(`Provider ${providerName} already has badges, skipping`);
                    continue;
                }

                // Create 3 standard badges for this provider
                const providerBadges = [];
                for (const badgeData of standardBadges) {
                    const badgeId = uuidv4();

                    // Insert main badge record
                    await this.targetDb.query(`
                        INSERT INTO certificate_provider_badges (
                            id, icon, certificate_provider_id, created_at, updated_at
                        ) VALUES ($1, $2, $3, NOW(), NOW())
                    `, [
                        badgeId,
                        badgeData.icon || null, // Add icon field (will be null for now)
                        providerId
                    ]);

                    // Insert translation record
                    await this.targetDb.query(`
                        INSERT INTO certificate_provider_badge_translations (
                            id, name, description, certificate_provider_badge_id, language_id, created_at, updated_at
                        ) VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
                    `, [
                        uuidv4(),
                        badgeData.name,
                        badgeData.description,
                        badgeId,
                        englishLanguageId
                    ]);

                    providerBadges.push(badgeData.name);
                    logger.debug(`Created badge "${badgeData.name}" for provider ${providerName}`);
                }

                logger.info(`Created ${providerBadges.length} badges for provider ${providerName}: ${providerBadges.join(', ')}`);
            }

            logger.success('Certificate provider badges ensured for all providers');
        } catch (error) {
            logger.error('Failed to ensure certificate provider badges', { error: error.message });
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

            // 5. Note: Product images are now migrated in the separate combined image processing step

            // 6. Migrate product certificate provider badges
            // await this.migrateProductCertificateProviderBadges(products);

            // 7. Migrate product images and set master image IDs
            await this.migrateProductImages(products);

            // 8. Update master image IDs for all products
            await this.updateMasterImageIds(products);


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
                cpevs_grade_suffix.value as grade_suffix,
                cpf.year,
                cpf.country,
                cpf.country_value,
                cpevs_country_manuf.value as country_of_manufacture,
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
            LEFT JOIN catalog_product_entity_varchar cpevs_grade_suffix ON cpe.entity_id = cpevs_grade_suffix.entity_id AND cpevs_grade_suffix.attribute_id = 153 AND cpevs_grade_suffix.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_cert_type ON cpe.entity_id = cpei_cert_type.entity_id AND cpei_cert_type.attribute_id = 147 AND cpei_cert_type.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_archived ON cpe.entity_id = cpei_archived.entity_id AND cpei_archived.attribute_id = 144 AND cpei_archived.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_status ON cpe.entity_id = cpei_status.entity_id AND cpei_status.attribute_id = 97 AND cpei_status.store_id = 0
            LEFT JOIN catalog_product_entity_int cpei_visibility ON cpe.entity_id = cpei_visibility.entity_id AND cpei_visibility.attribute_id = 99 AND cpei_visibility.store_id = 0
            LEFT JOIN catalog_product_entity_datetime cped_sold_on ON cpe.entity_id = cped_sold_on.entity_id AND cped_sold_on.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_on' AND entity_type_id = 4) AND cped_sold_on.store_id = 0
            LEFT JOIN catalog_product_entity_decimal cped_sold_price ON cpe.entity_id = cped_sold_price.entity_id AND cped_sold_price.attribute_id = (SELECT attribute_id FROM eav_attribute WHERE attribute_code = 'sold_price' AND entity_type_id = 4) AND cped_sold_price.store_id = 0
            LEFT JOIN catalog_product_entity_varchar cpev_sort ON cpe.entity_id = cpev_sort.entity_id AND cpev_sort.attribute_id = 141 AND cpev_sort.store_id = 0
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
                     cped_grade_value.value, cpevs_grade_suffix.value, cpf.year, cpf.country, cpf.country_value, cpei_cert_type.value, sold_dates.first_sale_date, sold_prices.last_sold_price, cpev_sort.value, cped_sold_on.value, cped_sold_price.value, cpei_status.value, cpei_visibility.value, cpet_xero_sale.value
            ORDER BY cpe.entity_id
        `;

        const products = await this.sourceDb.query(query, queryParams);

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

            // Resolve Xero account IDs from source sale_account values
            if (transformed.products.length > 0) {
                await this.resolveXeroAccountIds(products, transformed.products);
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
        // Get unique ISO codes from products that aren't already cached
        const isoCodes = [...new Set(products.map(p => p.country_id).filter(code => code && !this.countryCache.has(code)))];

        if (isoCodes.length > 0) {
            // Get country mappings from target database for uncached codes
            const countries = await this.targetDb.query('SELECT id, iso_code_2 FROM countries WHERE iso_code_2 = ANY($1)', [isoCodes]);
            countries.forEach(c => this.countryCache.set(c.iso_code_2, c.id));
            logger.info(`Resolved and cached ${countries.length} new country codes to IDs`);
        }

        // Update products with cached country IDs
        for (const product of products) {
            if (product.country_id && this.countryCache.has(product.country_id)) {
                product.country_id = this.countryCache.get(product.country_id);
            } else {
                product.country_id = null; // Set to null if no mapping found
            }
        }

        logger.info(`Used country cache for batch: ${products.length} products processed`);
    }

    async resolveXeroAccountIds(sourceProducts, transformedProducts) {
        // Process each product and resolve its Xero account mapping
        let mappedCount = 0;
        let skippedCount = 0;

        for (let i = 0; i < sourceProducts.length; i++) {
            const sourceProduct = sourceProducts[i];
            const transformedProduct = transformedProducts[i];

            const xeroSaleAccount = sourceProduct.xero_sale_account;
            const xeroMapping = await this.resolveXeroAccountId(xeroSaleAccount);

            transformedProduct.xero_account_id = xeroMapping.accountId;
            transformedProduct.xero_tenant_id = xeroMapping.tenantId;

            if (xeroMapping.accountId && xeroMapping.tenantId) {
                mappedCount++;
                logger.debug(`Mapped product ${sourceProduct.product_sku} Xero account: ${xeroSaleAccount} -> account_id: ${xeroMapping.accountId}, tenant_id: ${xeroMapping.tenantId}`);
            } else {
                skippedCount++;
                logger.debug(`No Xero mapping found for product ${sourceProduct.product_sku} (sale_account: ${xeroSaleAccount})`);
            }
        }

        logger.info(`Xero account mapping completed: ${mappedCount} products mapped, ${skippedCount} products without mapping`);
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

                // Apply URL prefix for backend streaming
                const backendUrlPrefix = 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream/product/';
                const fullImageUrl = image.image_path.startsWith('/') ? backendUrlPrefix + image.image_path.slice(1) : backendUrlPrefix + image.image_path;

                // Determine if this is the master image (position = 1 or first image)
                const isMaster = image.position === 1 || image.position === '1' ||
                    (targetImages.filter(img => img.product_id === productId).length === 0);

                targetImages.push({
                    id: uuidv4(),
                    image_url: fullImageUrl,
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
            // Get product mappings with certificate_provider_id
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000);
                return p.product_sku + '-' + timestamp.toString(36);
            });

            const targetProducts = await this.targetDb.query(
                'SELECT id, product_web_sku, certificate_provider_id FROM products WHERE product_web_sku = ANY($1)',
                [productWebSkus]
            );

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, { id: p.id, certificate_provider_id: p.certificate_provider_id }]));
            logger.info(`Found ${productMap.size} products in target database for badge migration`);

            // Filter products that have certificate_provider_id
            const productsWithCertificateProviders = Array.from(productMap.entries())
                .filter(([_, productData]) => productData.certificate_provider_id)
                .map(([webSku, productData]) => ({ webSku, id: productData.id, certificate_provider_id: productData.certificate_provider_id }));

            if (productsWithCertificateProviders.length === 0) {
                logger.info('No products with certificate providers found for badge migration');
                return;
            }

            logger.info(`Found ${productsWithCertificateProviders.length} products with certificate providers out of ${productMap.size} total products`);

            // Get certificate provider to badges mapping
            const targetBadges = await this.targetDb.query(`
                SELECT cpb.id, cpb.certificate_provider_id, cp.name as provider_name
                FROM certificate_provider_badges cpb
                LEFT JOIN certificate_providers cp ON cpb.certificate_provider_id = cp.id
            `);
            logger.info(`Found ${targetBadges.length} certificate provider badges in target database`);

            if (targetBadges.length === 0) {
                logger.info('No certificate provider badges found in target database');
                return;
            }

            // Create provider_id to badges mapping
            const providerBadgeMap = new Map();
            targetBadges.forEach(badge => {
                if (!providerBadgeMap.has(badge.certificate_provider_id)) {
                    providerBadgeMap.set(badge.certificate_provider_id, []);
                }
                providerBadgeMap.get(badge.certificate_provider_id).push({
                    id: badge.id,
                    provider_name: badge.provider_name
                });
            });

            logger.info(`Created badge mappings for ${providerBadgeMap.size} different providers`);

            // Check existing product-badge relations to avoid duplicates
            const validProductIds = productsWithCertificateProviders.map(p => p.id);
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

            // Create relations: each product with only its certificate provider's badges
            const badgeRelations = [];
            let totalRelationsConsidered = 0;
            let skippedExisting = 0;

            for (const productData of productsWithCertificateProviders) {
                const { id: productId, certificate_provider_id, webSku } = productData;

                // Get badges for this product's certificate provider
                const providerBadges = providerBadgeMap.get(certificate_provider_id);
                if (!providerBadges || providerBadges.length === 0) {
                    logger.debug(`No badges found for provider ${certificate_provider_id} of product ${webSku}`);
                    continue;
                }

                totalRelationsConsidered += providerBadges.length;

                for (const badge of providerBadges) {
                    const relationKey = `${productId}-${badge.id}`;

                    // Skip if relation already exists
                    if (existingRelationsSet.has(relationKey)) {
                        skippedExisting++;
                        continue;
                    }

                    // Find the original product for created_at timestamp
                    const originalProduct = products.find(p => {
                        const timestamp = Math.floor(new Date(p.created_at) / 1000);
                        return p.product_sku + '-' + timestamp.toString(36) === webSku;
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
            logger.info(`Total relations considered: ${totalRelationsConsidered} (${productsWithCertificateProviders.length} products × average badges per provider)`);

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

    async updateMasterImageIds(products) {
        logger.info('Updating master image IDs for products...');

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
            logger.info(`Found ${productMap.size} products in target database for master image ID update`);

            // Get all product image relations (only master images is_master = true)
            const productIds = Array.from(productMap.values());
            const masterImages = await this.targetDb.query(
                'SELECT pi.id, pi.product_id FROM product_images pi WHERE pi.product_id = ANY($1) AND pi.is_master = true',
                [productIds]
            );

            logger.info(`Found ${masterImages.length} master images in target database`);

            // Create product_id to master_image_id mapping
            const masterImageMap = new Map();
            masterImages.forEach(img => masterImageMap.set(img.product_id, img.id));

            // Update products with master image IDs
            let updatedCount = 0;
            let processedCount = 0;
            let productsWithoutImages = 0;
            let productsNotFound = 0;

            logger.info(`Processing ${products.length} products for master image ID updates...`);

            for (const product of products) {
                processedCount++;
                const productWebSku = product.product_sku + '-' + Math.floor(new Date(product.created_at) / 1000).toString(36);
                const productId = productMap.get(productWebSku);

                if (!productId) {
                    productsNotFound++;
                    if (productsNotFound <= 5) { // Log first 5 missing products
                        logger.debug(`Product not found in target: ${productWebSku}`);
                    }
                    continue;
                }

                const masterImageId = masterImageMap.get(productId);
                if (!masterImageId) {
                    productsWithoutImages++;

                    // Get source entity_id for context
                    const sourceEntityId = product.entity_id;
                    logger.debug(`No master image found for product ${productWebSku} (source entity_id: ${sourceEntityId})`);

                    continue;
                }

                await this.targetDb.query(
                    'UPDATE products SET product_master_image_id = $1, updated_at = NOW() WHERE id = $2',
                    [masterImageId, productId]
                );
                updatedCount++;

                logger.debug(`Set master_image_id to ${masterImageId} for product ${productWebSku}`);
            }

            // Summary log with actions if there are missing images
            if (productsWithoutImages > 0) {
                logger.warn(`Found ${productsWithoutImages} products without master images:`);
                logger.warn(`- These products have no images in the source database`);
                logger.warn(`- Product_master_image_id field will remain NULL for these products`);
                logger.warn(`- This is normal for some products and doesn't affect system functionality`);
            }

            logger.info(`Processed ${processedCount} products, updated ${updatedCount} master image IDs, ${productsWithoutImages} products without images`);
            logger.success(`Updated master image IDs for ${updatedCount} products`);
        } catch (error) {
            logger.error('Failed to update master image IDs', { error: error.message });
        }
    }

    // Improved: Find master category for a single source category ID
    async findMasterCategoryIdForSingle(targetCategories, firstSourceCategoryId) {
        // Try to find exact match
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

            if (!isNaN(entityId) && entityId === firstSourceCategoryId) {
                return targetCategory.id;
            }
        }

        return null; // No match found
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

    // Resolve Xero account codes to target database IDs with caching
    async resolveXeroAccountId(saleAccount) {
        try {
            if (!saleAccount || typeof saleAccount !== 'string' || saleAccount.trim() === '') {
                logger.debug('Invalid or empty Xero sale account, skipping');
                return { accountId: null, tenantId: null };
            }

            const accountCode = saleAccount.trim();

            // Check cache first for performance
            if (this.xeroAccountCache.has(accountCode)) {
                return this.xeroAccountCache.get(accountCode);
            }

            // Query target database for Xero account mapping
            const result = await this.targetDb.query(
                'SELECT id, tenant_id FROM xero_accounts WHERE account_number = $1',
                [accountCode]
            );

            if (result.length > 0) {
                const mapped = {
                    accountId: result[0].id,
                    tenantId: result[0].tenant_id
                };

                // Cache for future use
                this.xeroAccountCache.set(accountCode, mapped);
                logger.debug(`Mapped Xero account ${accountCode} to ID: ${mapped.accountId}, tenant: ${mapped.tenantId}`);

                return mapped;
            } else {
                logger.warn(`Xero account ${accountCode} not found in target database`);
                // Cache null result to avoid repeated queries
                this.xeroAccountCache.set(accountCode, { accountId: null, tenantId: null });
                return { accountId: null, tenantId: null };
            }

        } catch (error) {
            logger.error(`Failed to resolve Xero account ${saleAccount}`, { error: error.message });
            return { accountId: null, tenantId: null };
        }
    }
}

module.exports = ProductsStep;
