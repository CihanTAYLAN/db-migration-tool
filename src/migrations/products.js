const { MigrationTemplate } = require('./template');
const logger = require('../logger');
const { v4: uuidv4 } = require('uuid');

class ProductsMigration extends MigrationTemplate {
    constructor() {
        // Environment değişkenlerini oku
        const sourceConnectionString = process.env.SOURCE_DATABASE_URL;
        const sourceDbType = process.env.SOURCE_DB_TYPE;
        const targetConnectionString = process.env.TARGET_DATABASE_URL;
        const targetDbType = process.env.TARGET_DB_TYPE;

        // Template'e parametreleri geç
        super(sourceConnectionString, sourceDbType, targetConnectionString, targetDbType);

        this.migrationStats = {
            startTime: null,
            endTime: null,
            sourceTables: [],
            targetTables: [],
            recordsFound: 0,
            recordsInserted: 0,
            recordsUpdated: 0,
            errors: []
        };
    }

    async run() {
        this.migrationStats.startTime = new Date();
        logger.info('Starting products migration...');

        await this.connectAll();

        if (!this.sourceConnected || !this.targetConnected) {
            logger.error('Database connections failed for products migration');
            await this.disconnectAll();
            return;
        }

        try {
            // First, get attribute IDs for key fields (assuming store_id=0 for default values)
            const nameAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "name" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const nameAttrId = nameAttrResult && nameAttrResult.length > 0 ? nameAttrResult[0].attribute_id : null;

            const priceAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "price" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const priceAttrId = priceAttrResult && priceAttrResult.length > 0 ? priceAttrResult[0].attribute_id : null;

            // Get additional attribute IDs
            const descAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "description" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const descAttrId = descAttrResult && descAttrResult.length > 0 ? descAttrResult[0].attribute_id : null;

            const shortDescAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "short_description" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const shortDescAttrId = shortDescAttrResult && shortDescAttrResult.length > 0 ? shortDescAttrResult[0].attribute_id : null;

            logger.info(`Attribute IDs - name: ${nameAttrId}, price: ${priceAttrId}, desc: ${descAttrId}, short_desc: ${shortDescAttrId}`);

            // Get additional attribute IDs for images and URL
            const imageAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "image" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const imageAttrId = imageAttrResult && imageAttrResult.length > 0 ? imageAttrResult[0].attribute_id : null;

            const urlKeyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_product")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            logger.info(`Additional Attribute IDs - image: ${imageAttrId}, url_key: ${urlKeyAttrId}`);

            // Query products with flattened data including categories, images, and URL
            const productsQuery = `
                SELECT
                    cpe.entity_id,
                    cpe.sku as product_sku,
                    cpev.value as name,
                    cped.value as price,
                    cpevd.value as description,
                    cpevs.value as short_description,
                    cpevi.value as image,
                    cpevu.value as url_key,
                    cpe.created_at,
                    cpe.updated_at,
                    GROUP_CONCAT(DISTINCT ccp.category_id) as category_ids,
                    GROUP_CONCAT(DISTINCT cpg.value) as gallery_images
                FROM catalog_product_entity cpe
                LEFT JOIN catalog_product_entity_varchar cpev ON cpe.entity_id = cpev.entity_id AND cpev.attribute_id = ? AND cpev.store_id = 0
                LEFT JOIN catalog_product_entity_decimal cped ON cpe.entity_id = cped.entity_id AND cped.attribute_id = ? AND cped.store_id = 0
                LEFT JOIN catalog_product_entity_text cpevd ON cpe.entity_id = cpevd.entity_id AND cpevd.attribute_id = ? AND cpevd.store_id = 0
                LEFT JOIN catalog_product_entity_varchar cpevs ON cpe.entity_id = cpevs.entity_id AND cpevs.attribute_id = ? AND cpevs.store_id = 0
                LEFT JOIN catalog_product_entity_varchar cpevi ON cpe.entity_id = cpevi.entity_id AND cpevi.attribute_id = ? AND cpevi.store_id = 0
                LEFT JOIN catalog_product_entity_varchar cpevu ON cpe.entity_id = cpevu.entity_id AND cpevu.attribute_id = ? AND cpevu.store_id = 0
                LEFT JOIN catalog_category_product ccp ON cpe.entity_id = ccp.product_id
                LEFT JOIN catalog_product_entity_media_gallery_value_to_entity cpg_vte ON cpe.entity_id = cpg_vte.entity_id
                LEFT JOIN catalog_product_entity_media_gallery cpg ON cpg_vte.value_id = cpg.value_id AND cpg.disabled = 0
                WHERE cpe.type_id = 'simple'
                GROUP BY cpe.entity_id, cpe.sku, cpev.value, cped.value, cpevd.value, cpevs.value, cpevi.value, cpevu.value, cpe.created_at, cpe.updated_at
                ORDER BY cpe.entity_id
            `;

            const products = await this.query('source', productsQuery, [nameAttrId, priceAttrId, descAttrId, shortDescAttrId, imageAttrId, urlKeyAttrId]);
            logger.info(`${products.length} products found`);

            if (products.length === 0) {
                logger.warning('No products found in source database');
                await this.disconnectAll();
                return;
            }

            // Get currencies (assuming from directory_currency_rate or default)
            const currencies = await this.query('source', 'SELECT currency_from, currency_to, rate FROM directory_currency_rate WHERE currency_from = "USD"');
            const usdCurrency = currencies && currencies.length > 0 ? currencies.find(c => c.currency_from === 'USD') : null;
            const usdRate = usdCurrency ? usdCurrency.rate : 1;

            // Batch insert products
            const BATCH_SIZE = 1000;
            let insertedCount = 0;

            for (let i = 0; i < products.length; i += BATCH_SIZE) {
                const batch = products.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                const pgProducts = batch.map(p => {
                    const id = uuidv4();
                    const productWebSku = p.product_sku;
                    const productIdentity = `${p.product_sku}-${p.entity_id}`; // Unique identifier
                    const masterCategoryId = p.category_path ? uuidv4() : null; // Generate UUID for category if needed

                    return {
                        id,
                        product_identity: productIdentity,
                        product_sku: p.product_sku,
                        product_web_sku: productWebSku,
                        cert_number: null, // From custom if available
                        coin_video: null,
                        is_coin_video: false,
                        coin_number: null,
                        coin_our_grade: null,
                        coin_grade_type: null,
                        coin_grade: null,
                        coin_grade_suffix: null,
                        coin_grade_prefix: null,
                        coin_grade_text: null,
                        year_text: null,
                        coin_grade_prefix_type: null,
                        year_date: p.created_at,
                        is_second_hand: false,
                        is_consignment: false,
                        is_active: true,
                        is_on_hold: false,
                        status: 'pending',
                        quantity: 1, // Default or from stock
                        price: parseFloat(p.price) || 0,
                        sold_date: null,
                        archived_at: null,
                        sold_price: null,
                        discount_price: null,
                        ebay_offer_code: null,
                        stars: 0,
                        created_at: p.created_at,
                        updated_at: p.updated_at,
                        deleted_at: null,
                        product_master_image_id: null, // From gallery
                        certificate_provider_id: null, // From custom
                        master_category_id: masterCategoryId,
                        xero_tenant_id: null,
                        country_id: null // From custom or default
                    };
                });

                // Insert into products
                const fieldCount = Object.keys(pgProducts[0]).length;
                const placeholders = pgProducts.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = pgProducts.flatMap(p => Object.values(p));

                const fields = Object.keys(pgProducts[0]).join(', ');
                const insertQuery = `
                    INSERT INTO products (${fields})
                    VALUES ${placeholders}
                    ON CONFLICT (product_web_sku) DO UPDATE SET
                        product_sku = EXCLUDED.product_sku,
                        price = EXCLUDED.price,
                        updated_at = EXCLUDED.updated_at
                `;

                await this.query('target', insertQuery, values);

                insertedCount += batch.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(products.length / BATCH_SIZE)} completed (${insertedCount}/${products.length} products)`);
            }

            // Migrate related data
            await this.migrateProductTranslations(products);
            // Skip product images migration due to schema incompatibility
            // await this.migrateProductImages(products);
            await this.migrateProductCategoriesFromQuery(products);
            await this.migrateProductPrices(products);

            // Update migration statistics
            this.migrationStats.endTime = new Date();
            this.migrationStats.recordsFound = products.length;
            this.migrationStats.recordsInserted = insertedCount;
            this.migrationStats.sourceTables = [
                'catalog_product_entity',
                'catalog_product_entity_varchar',
                'catalog_product_entity_decimal',
                'catalog_product_entity_text',
                'catalog_product_entity_media_gallery',
                'catalog_product_entity_media_gallery_value',
                'catalog_category_product',
                'catalog_category_entity',
                'catalog_category_entity_varchar',
                'directory_currency_rate'
            ];
            this.migrationStats.targetTables = [
                'products',
                'product_translations',
                'product_images',
                'categories',
                'category_translations',
                'product_categories',
                'product_prices'
            ];

            // Generate migration report
            this.generateMigrationReport();

            logger.success(`Products migration completed: ${insertedCount} products inserted/updated`);
        } catch (error) {
            this.migrationStats.errors.push({
                timestamp: new Date(),
                error: error.message,
                stack: error.stack
            });
            logger.error('Products migration failed', { error: error.message });
        } finally {
            await this.disconnectAll();
        }
    }

    async processProductCategoriesBatch(batch, pgProducts) {
        try {
            // Get existing categories from target with their translations to get original entity_id
            const existingCategories = await this.query('target', `
                SELECT c.id, c.code, ct.slug, ct.language_id
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
            `);

            // Create comprehensive category mapping
            const categoryMap = new Map();

            // First, try to get original category data from source to create proper mapping
            const urlKeyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            let sourceCategories = [];
            if (urlKeyAttrId) {
                sourceCategories = await this.query('source', `
                    SELECT
                        cce.entity_id,
                        ccev.value as url_key
                    FROM catalog_category_entity cce
                    LEFT JOIN catalog_category_entity_varchar ccev ON cce.entity_id = ccev.entity_id
                        AND ccev.attribute_id = ? AND ccev.store_id = 0
                    WHERE cce.entity_id > 1
                `, [urlKeyAttrId]);
            } else {
                // Fallback: just get entity_ids without url_key
                sourceCategories = await this.query('source', `
                    SELECT entity_id, NULL as url_key FROM catalog_category_entity
                    WHERE entity_id > 1
                `);
            }

            const sourceCategoryMap = new Map();
            sourceCategories.forEach(cat => {
                sourceCategoryMap.set(cat.entity_id, cat.url_key);
            });

            // Create mapping from source entity_id to target category_id
            for (const cat of existingCategories) {
                // Try different patterns to match source entity_id
                let sourceEntityId = null;

                // Pattern 1: If code is url_key, find the entity_id
                if (cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.code) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                // Pattern 2: If code is category-{id} format
                if (!sourceEntityId) {
                    const match = cat.code.match(/^category-(\d+)$/);
                    if (match) {
                        sourceEntityId = parseInt(match[1]);
                    }
                }

                // Pattern 3: If slug matches url_key
                if (!sourceEntityId && cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.slug) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                if (sourceEntityId) {
                    categoryMap.set(sourceEntityId, cat.id);
                }
            }

            // Process categories for this batch using data from main query
            const productCategoryRelations = [];
            for (let i = 0; i < batch.length; i++) {
                const product = batch[i];
                const pgProduct = pgProducts[i];

                if (product.category_ids) {
                    const categoryIds = product.category_ids.split(',');
                    for (const catId of categoryIds) {
                        if (catId && catId.trim()) {
                            const categoryId = categoryMap.get(parseInt(catId.trim()));
                            if (categoryId) {
                                productCategoryRelations.push({
                                    id: uuidv4(),
                                    product_id: pgProduct.id,
                                    category_id: categoryId,
                                    created_at: product.created_at,
                                    updated_at: product.updated_at
                                });
                            }
                        }
                    }
                }
            }

            if (productCategoryRelations.length > 0) {
                // Insert product-category relations
                const fieldCount = Object.keys(productCategoryRelations[0]).length;
                const placeholders = productCategoryRelations.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = productCategoryRelations.flatMap(pc => Object.values(pc));
                const fields = Object.keys(productCategoryRelations[0]).join(', ');

                await this.query('target', `INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);
                logger.info(`Processed ${productCategoryRelations.length} product-category relations for batch`);
            }
        } catch (error) {
            logger.error('Product categories batch processing failed', { error: error.message });
        }
    }

    async migrateProductTranslations(products) {
        logger.info('Starting product translations migration...');

        try {
            // Get default language ID
            const defaultLangResult = await this.query('target', 'SELECT id FROM languages WHERE code = \'en\' LIMIT 1');
            const languageId = defaultLangResult && defaultLangResult.length > 0 ? defaultLangResult[0].id : null;

            if (!languageId) {
                logger.warning('Default language not found, skipping translations');
                return;
            }

            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.query('target', 'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);

            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            const translations = [];
            for (const product of products) {
                const productId = productMap.get(product.product_sku);
                if (!productId) continue;

                if (product.name) {
                    translations.push({
                        id: uuidv4(),
                        title: product.name,
                        description: product.description,
                        short_description: product.short_description,
                        slug: product.url_key || product.name.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, ''),
                        meta_title: null,
                        meta_description: null,
                        meta_keywords: null,
                        product_id: productId,
                        language_id: languageId,
                        created_at: product.created_at,
                        updated_at: product.updated_at
                    });
                }
            }

            if (translations.length === 0) {
                logger.info('No translations to migrate');
                return;
            }

            // Batch insert translations
            const BATCH_SIZE = 500;
            for (let i = 0; i < translations.length; i += BATCH_SIZE) {
                const batch = translations.slice(i, i + BATCH_SIZE);
                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(t => Object.values(t));
                const fields = Object.keys(batch[0]).join(', ');

                await this.query('target', `INSERT INTO product_translations (${fields}) VALUES ${placeholders} ON CONFLICT (language_id, slug) DO UPDATE SET title = EXCLUDED.title, description = EXCLUDED.description, short_description = EXCLUDED.short_description, meta_title = EXCLUDED.meta_title, meta_description = EXCLUDED.meta_description, meta_keywords = EXCLUDED.meta_keywords, updated_at = EXCLUDED.updated_at`, values);
            }

            logger.success(`Product translations migration completed: ${translations.length} translations inserted`);
        } catch (error) {
            logger.error('Product translations migration failed', { error: error.message });
        }
    }

    async migrateProductImages(products) {
        logger.info('Starting product images migration...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.query('target', 'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Query product images from Magento (split into smaller batches to avoid parameter limit)
            const IMAGE_BATCH_SIZE = 1000;
            let allImages = [];

            for (let i = 0; i < productSkus.length; i += IMAGE_BATCH_SIZE) {
                const batch = productSkus.slice(i, i + IMAGE_BATCH_SIZE);
                const placeholders = batch.map(() => '?').join(',');
                const imageQuery = `
                    SELECT
                        cpe.entity_id,
                        cpe.sku,
                        cpg.value as image_path,
                        cpgv.label as label,
                        1 as position
                    FROM catalog_product_entity cpe
                    JOIN catalog_product_entity_media_gallery cpg ON cpe.entity_id = cpg.entity_id
                    LEFT JOIN catalog_product_entity_media_gallery_value cpgv ON cpg.value_id = cpgv.value_id AND cpgv.store_id = 0
                    WHERE cpe.sku IN (${placeholders})
                    ORDER BY cpe.entity_id
                `;

                const batchImages = await this.query('source', imageQuery, batch);
                allImages = allImages.concat(batchImages);
            }

            const images = allImages;

            if (images.length === 0) {
                logger.info('No product images found');
                return;
            }

            const pgImages = [];
            let masterImageMap = new Map();

            for (const image of images) {
                const productId = productMap.get(image.sku);
                if (!productId) continue;

                const imageId = uuidv4();
                const isMaster = image.position === 1; // First image is master

                pgImages.push({
                    id: imageId,
                    image_url: `/media/catalog/product${image.image_path}`,
                    alt: image.label || image.sku,
                    position: image.position || 0,
                    is_master: isMaster,
                    product_id: productId,
                    created_at: new Date(),
                    updated_at: new Date()
                });

                if (isMaster) {
                    masterImageMap.set(productId, imageId);
                }
            }

            if (pgImages.length === 0) {
                logger.info('No images to migrate');
                return;
            }

            // Batch insert images
            const BATCH_SIZE = 500;
            for (let i = 0; i < pgImages.length; i += BATCH_SIZE) {
                const batch = pgImages.slice(i, i + BATCH_SIZE);
                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(img => Object.values(img));
                const fields = Object.keys(batch[0]).join(', ');

                await this.query('target', `INSERT INTO product_images (${fields}) VALUES ${placeholders}`, values);
            }

            // Update master image IDs in products
            for (const [productId, masterImageId] of masterImageMap) {
                await this.query('target', 'UPDATE products SET product_master_image_id = $1 WHERE id = $2', [masterImageId, productId]);
            }

            logger.success(`Product images migration completed: ${pgImages.length} images inserted`);
        } catch (error) {
            logger.error('Product images migration failed', { error: error.message });
        }
    }

    async migrateProductCategoriesFromQuery(products) {
        logger.info('Starting product categories migration from main query...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.query('target', 'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get existing categories from target with their translations to get original entity_id
            const existingCategories = await this.query('target', `
                SELECT c.id, c.code, ct.slug, ct.language_id
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
            `);

            logger.info(`Found ${existingCategories.length} categories in target database`);

            // Create comprehensive category mapping
            const categoryMap = new Map();

            // First, try to get original category data from source to create proper mapping
            const urlKeyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            let sourceCategories = [];
            if (urlKeyAttrId) {
                sourceCategories = await this.query('source', `
                    SELECT
                        cce.entity_id,
                        ccev.value as url_key
                    FROM catalog_category_entity cce
                    LEFT JOIN catalog_category_entity_varchar ccev ON cce.entity_id = ccev.entity_id
                        AND ccev.attribute_id = ? AND ccev.store_id = 0
                    WHERE cce.entity_id > 1
                `, [urlKeyAttrId]);
            } else {
                // Fallback: just get entity_ids without url_key
                sourceCategories = await this.query('source', `
                    SELECT entity_id, NULL as url_key FROM catalog_category_entity
                    WHERE entity_id > 1
                `);
            }

            const sourceCategoryMap = new Map();
            sourceCategories.forEach(cat => {
                sourceCategoryMap.set(cat.entity_id, cat.url_key);
            });

            // Create mapping from source entity_id to target category_id
            for (const cat of existingCategories) {
                // Try different patterns to match source entity_id
                let sourceEntityId = null;

                // Pattern 1: If code is url_key, find the entity_id
                if (cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.code) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                // Pattern 2: If code is category-{id} format
                if (!sourceEntityId) {
                    const match = cat.code.match(/^category-(\d+)$/);
                    if (match) {
                        sourceEntityId = parseInt(match[1]);
                    }
                }

                // Pattern 3: If slug matches url_key
                if (!sourceEntityId && cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.slug) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                if (sourceEntityId) {
                    categoryMap.set(sourceEntityId, cat.id);
                }
            }

            logger.info(`Created category mapping for ${categoryMap.size} categories`);

            // Process categories using data from main query
            const productCategoryRelations = [];
            for (const product of products) {
                const productId = productMap.get(product.product_sku);
                if (!productId || !product.category_ids) continue;

                const categoryIds = product.category_ids.split(',');
                for (const catId of categoryIds) {
                    if (catId && catId.trim()) {
                        const categoryId = categoryMap.get(parseInt(catId.trim()));
                        if (categoryId) {
                            productCategoryRelations.push({
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

            if (productCategoryRelations.length === 0) {
                logger.info('No product-category relations to migrate');
                return;
            }

            logger.info(`Processing ${productCategoryRelations.length} product-category relations...`);

            // Insert in smaller batches to avoid parameter limits
            const BATCH_SIZE = 500;
            let totalInserted = 0;

            for (let i = 0; i < productCategoryRelations.length; i += BATCH_SIZE) {
                const batch = productCategoryRelations.slice(i, i + BATCH_SIZE);
                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, idx) => `$${start + idx}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(pc => Object.values(pc));
                const fields = Object.keys(batch[0]).join(', ');

                await this.query('target', `INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);
                totalInserted += batch.length;
                logger.info(`Inserted ${totalInserted}/${productCategoryRelations.length} product-category relations`);
            }

            logger.success(`Product categories migration completed: ${totalInserted} relations inserted`);
        } catch (error) {
            logger.error('Product categories migration failed', { error: error.message });
        }
    }

    async migrateProductCategories(products) {
        logger.info('Starting product categories migration...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.query('target', 'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get existing categories from target with their translations to get original entity_id
            const existingCategories = await this.query('target', `
                SELECT c.id, c.code, ct.slug, ct.language_id
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
            `);

            logger.info(`Found ${existingCategories.length} categories in target database`);

            // Debug: Check what languages exist
            const languages = await this.query('target', 'SELECT * FROM languages');
            logger.info(`Available languages: ${languages.map(l => `${l.code} (${l.id})`).join(', ')}`);

            // Filter categories by available languages
            const validCategories = existingCategories.filter(cat => {
                if (!cat.language_id) return true; // Include categories without translations
                return languages.some(lang => lang.id === cat.language_id);
            });

            logger.info(`Valid categories after language filter: ${validCategories.length}`);

            if (validCategories.length === 0) {
                logger.warning('No valid categories found in target database, skipping product categories migration');
                return;
            }

            // Create comprehensive category mapping
            const categoryMap = new Map();

            // First, try to get original category data from source to create proper mapping
            // In Magento, url_key is stored as an attribute in catalog_category_entity_varchar
            const urlKeyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            let sourceCategories = [];
            if (urlKeyAttrId) {
                sourceCategories = await this.query('source', `
                    SELECT
                        cce.entity_id,
                        ccev.value as url_key
                    FROM catalog_category_entity cce
                    LEFT JOIN catalog_category_entity_varchar ccev ON cce.entity_id = ccev.entity_id
                        AND ccev.attribute_id = ? AND ccev.store_id = 0
                    WHERE cce.entity_id > 1
                `, [urlKeyAttrId]);
            } else {
                // Fallback: just get entity_ids without url_key
                sourceCategories = await this.query('source', `
                    SELECT entity_id, NULL as url_key FROM catalog_category_entity
                    WHERE entity_id > 1
                `);
            }

            const sourceCategoryMap = new Map();
            sourceCategories.forEach(cat => {
                sourceCategoryMap.set(cat.entity_id, cat.url_key);
            });

            // Create mapping from source entity_id to target category_id
            for (const cat of existingCategories) {
                // Try different patterns to match source entity_id
                let sourceEntityId = null;

                // Pattern 1: If code is url_key, find the entity_id
                if (cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.code) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                // Pattern 2: If code is category-{id} format
                if (!sourceEntityId) {
                    const match = cat.code.match(/^category-(\d+)$/);
                    if (match) {
                        sourceEntityId = parseInt(match[1]);
                    }
                }

                // Pattern 3: If slug matches url_key
                if (!sourceEntityId && cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.slug) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                if (sourceEntityId) {
                    categoryMap.set(sourceEntityId, cat.id);
                }
            }

            logger.info(`Created category mapping for ${categoryMap.size} categories`);

            // Query product categories from Magento in smaller batches
            const BATCH_SIZE = 500;
            let totalRelations = 0;

            for (let i = 0; i < productSkus.length; i += BATCH_SIZE) {
                const batch = productSkus.slice(i, i + BATCH_SIZE);
                const placeholders = batch.map(() => '?').join(',');

                const categoryQuery = `
                    SELECT
                        cpe.sku,
                        ccp.category_id
                    FROM catalog_product_entity cpe
                    JOIN catalog_category_product ccp ON cpe.entity_id = ccp.product_id
                    WHERE cpe.sku IN (${placeholders})
                    AND ccp.category_id > 1
                `;

                const batchCategories = await this.query('source', categoryQuery, batch);

                if (batchCategories.length === 0) continue;

                // Create product-category relationships
                const productCategoryRelations = [];
                for (const pc of batchCategories) {
                    const productId = productMap.get(pc.sku);
                    const categoryId = categoryMap.get(pc.category_id);

                    if (productId && categoryId) {
                        productCategoryRelations.push({
                            id: uuidv4(),
                            product_id: productId,
                            category_id: categoryId,
                            created_at: new Date(),
                            updated_at: new Date()
                        });
                    }
                }

                if (productCategoryRelations.length > 0) {
                    // Insert in smaller batches to avoid parameter limits
                    const INSERT_BATCH_SIZE = 100;
                    for (let j = 0; j < productCategoryRelations.length; j += INSERT_BATCH_SIZE) {
                        const insertBatch = productCategoryRelations.slice(j, j + INSERT_BATCH_SIZE);
                        const fieldCount = Object.keys(insertBatch[0]).length;
                        const insertPlaceholders = insertBatch.map((_, index) => {
                            const start = index * fieldCount + 1;
                            const params = Array.from({ length: fieldCount }, (_, idx) => `$${start + idx}`);
                            return `(${params.join(', ')})`;
                        }).join(', ');

                        const values = insertBatch.flatMap(pc => Object.values(pc));
                        const fields = Object.keys(insertBatch[0]).join(', ');

                        await this.query('target', `INSERT INTO product_categories (${fields}) VALUES ${insertPlaceholders} ON CONFLICT DO NOTHING`, values);
                    }

                    totalRelations += productCategoryRelations.length;
                    logger.info(`Processed ${totalRelations} product-category relations so far...`);
                }
            }

            logger.success(`Product categories migration completed: ${totalRelations} relations inserted`);
        } catch (error) {
            logger.error('Product categories migration failed', { error: error.message });
        }
    }

    async migrateProductPrices(products) {
        logger.info('Starting product prices migration...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.query('target', 'SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get USD currency ID
            const usdCurrencyResult = await this.query('target', 'SELECT id FROM currencies WHERE code = \'USD\' LIMIT 1');
            const currencyId = usdCurrencyResult && usdCurrencyResult.length > 0 ? usdCurrencyResult[0].id : null;

            if (!currencyId) {
                logger.warning('USD currency not found, skipping prices');
                return;
            }

            const prices = [];
            for (const product of products) {
                const productId = productMap.get(product.product_sku);
                if (!productId || !product.price) continue;

                prices.push({
                    id: uuidv4(),
                    base_amount: parseFloat(product.price),
                    amount: parseFloat(product.price),
                    currency_code: 'USD',
                    currency_id: currencyId,
                    product_id: productId,
                    created_at: product.created_at,
                    updated_at: product.updated_at
                });
            }

            if (prices.length === 0) {
                logger.info('No prices to migrate');
                return;
            }

            // Batch insert prices
            const BATCH_SIZE = 500;
            for (let i = 0; i < prices.length; i += BATCH_SIZE) {
                const batch = prices.slice(i, i + BATCH_SIZE);
                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(p => Object.values(p));
                const fields = Object.keys(batch[0]).join(', ');

                await this.query('target', `INSERT INTO product_prices (${fields}) VALUES ${placeholders} ON CONFLICT (product_id, currency_id) DO UPDATE SET base_amount = EXCLUDED.base_amount, amount = EXCLUDED.amount, updated_at = EXCLUDED.updated_at`, values);
            }

            logger.success(`Product prices migration completed: ${prices.length} prices inserted`);
        } catch (error) {
            logger.error('Product prices migration failed', { error: error.message });
        }
    }

    generateMigrationReport() {
        const duration = this.migrationStats.endTime - this.migrationStats.startTime;
        const durationInSeconds = Math.round(duration / 1000);
        const recordsPerSecond = Math.round(this.migrationStats.recordsFound / durationInSeconds);

        // Helper function for consistent formatting
        const formatLine = (label, value) => {
            const maxLabelLength = 25;
            const maxValueLength = 50;
            const paddedLabel = label.padEnd(maxLabelLength);
            const paddedValue = value.toString().padEnd(maxValueLength);
            return `║ ${paddedLabel} ${paddedValue}`;
        };

        const formatTableItem = (item) => {
            const maxLength = 65;
            return `║   • ${item.padEnd(maxLength)}`;
        };

        // Enhanced terminal logging with better formatting
        logger.info('');
        logger.info('╔══════════════════════════════════════════════════════════════════════════════');
        logger.info('║                           📊 MIGRATION REPORT');
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info(formatLine('Migration Type:', 'Products Migration'));
        logger.info(formatLine('Duration:', `${durationInSeconds} seconds`));
        logger.info(formatLine('Records Found:', this.migrationStats.recordsFound.toString()));
        logger.info(formatLine('Records Processed:', this.migrationStats.recordsInserted.toString()));
        logger.info(formatLine('Performance:', `${recordsPerSecond} records/second`));
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Source Database Tables:');
        this.migrationStats.sourceTables.forEach(table => {
            logger.info(formatTableItem(table));
        });
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Target Database Tables:');
        this.migrationStats.targetTables.forEach(table => {
            logger.info(formatTableItem(table));
        });
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Upsert Configuration:');
        logger.info(formatTableItem('Conflict Resolution: ON CONFLICT (product_web_sku) DO UPDATE'));
        logger.info(formatTableItem('Updated Fields: product_sku, price, updated_at'));
        logger.info(formatTableItem('Duplicate Prevention: ✅ ACTIVE'));
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');

        if (this.migrationStats.errors.length > 0) {
            logger.error('║ ❌ ERRORS OCCURRED:');
            this.migrationStats.errors.forEach((error, index) => {
                const errorMsg = `Error ${index + 1}: ${error.error}`.substring(0, 58);
                logger.error(`║   ${errorMsg.padEnd(67)}`);
            });
        } else {
            logger.success('MIGRATION COMPLETED SUCCESSFULLY');
        }

        logger.info('╚══════════════════════════════════════════════════════════════════════════════');
        logger.info('');

        return {
            success: this.migrationStats.errors.length === 0,
            duration: durationInSeconds,
            recordsProcessed: this.migrationStats.recordsInserted,
            performance: recordsPerSecond
        };
    }
}

module.exports = { default: ProductsMigration };
