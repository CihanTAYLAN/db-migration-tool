/*
# MigrationV2 Development - Tree-Based Migration Logic

## Current State (Completed)
✅ Categories Migration: 144 kategori, hierarchical ilişkiler
✅ Products Migration: 15,567 ürün, sold_date/price, translations, prices, categories
✅ Framework: MigrationV2 class, batch processing, error handling
✅ Coin fields: null olarak bırakıldı (source'da karşılığı yok)

## Tree-Based Migration Architecture

### Migration Flow
main()
├── migrateCategories() - Root categories
    ├── processCategoryRecursive() - Her kategori için
        ├── Category migrate et
        ├── processCategoryProducts() - Bu kategorinin product'larını
            ├── Product migrate et (upsert)
            ├── processProductOrders() - Bu product'ın order'larını
                ├── Order migrate et
                ├── Customer migrate et (eğer henüz migrate edilmemişse)

### Key Features
- **Tree-based processing**: Categories → Products → Orders → Customers
- **Batch processing**: Memory efficient, 1000 records per batch
- **Upsert logic**: Duplicate prevention with conflict resolution
- **Multi-category support**: Products can belong to multiple categories
- **Progress tracking**: Detailed logging for each step

### Database Relations
- Categories: hierarchical (parent_id)
- Products: belongs to categories (product_categories)
- Orders: belongs to products (order_items) and customers (order_customers)
- Customers: has many orders

### Technical Implementation
- Source: MySQL EAV structure
- Target: PostgreSQL normalized schema
- Error handling: Try-catch blocks with detailed logging
- Performance: Batch inserts, indexed queries

## Next Steps
1. Implement processCategoryProducts() method
2. Implement processProductOrders() method
3. Remove migrateProducts() from main flow
4. Add product processing to category recursive function
5. Test tree-based migration flow
*/

const { DbClient } = require('../db');
const logger = require('../logger');
const { v4: uuidv4 } = require('uuid');

class MigrationV2 {
    constructor(sourceUrl, sourceType, targetUrl, targetType) {
        this.sourceUrl = sourceUrl;
        this.sourceType = sourceType;
        this.targetUrl = targetUrl;
        this.targetType = targetType;
        this.sourceDb = null;
        this.targetDb = null;
    }

    async connectDatabases() {
        logger.info('Connecting to databases...');
        this.sourceDb = new DbClient(this.sourceUrl, this.sourceType);
        this.targetDb = new DbClient(this.targetUrl, this.targetType);
        await this.sourceDb.connect();
        await this.targetDb.connect();
        logger.success('Databases connected successfully');
    }

    async disconnectDatabases() {
        logger.info('Disconnecting from databases...');
        if (this.sourceDb) await this.sourceDb.close();
        if (this.targetDb) await this.targetDb.close();
        logger.success('Databases disconnected');
    }

    async run() {
        try {
            await this.connectDatabases();
            await this.main();
        } catch (error) {
            logger.error('Migration V2 failed', { error: error.message, stack: error.stack });
        } finally {
            await this.disconnectDatabases();
        }
    }

    async main() {
        logger.info('Starting full migration V2...');

        // Tree-based migration logic
        // 1. Categories (with subcategories and products)
        //    - Products (with orders)
        //        - Orders (with customers)
        // 2. Customers without orders

        await this.migrateCategories();

        // Products are now migrated within category processing
        // Orders and customers are migrated within product processing

        logger.success('Full migration V2 completed');
    }

    async migrateCategories() {
        logger.info('Starting categories migration...');

        // Get attribute IDs for EAV structure
        const nameAttrId = await this.getAttributeId('name');
        const urlKeyAttrId = await this.getAttributeId('url_key');
        const descriptionAttrId = await this.getAttributeId('description');
        const metaTitleAttrId = await this.getAttributeId('meta_title');
        const metaDescriptionAttrId = await this.getAttributeId('meta_description');
        const metaKeywordsAttrId = await this.getAttributeId('meta_keywords');
        const isActiveAttrId = await this.getAttributeId('is_active');

        logger.info(`Attribute IDs loaded: name=${nameAttrId}, url_key=${urlKeyAttrId}, etc.`);

        // Get categories from source (exclude root, Default Category, Coins for sale, Sold coin archive, Latest coins)
        const categoriesQuery = `
            SELECT
                cce.entity_id,
                cce.parent_id,
                cce.path,
                cce.level,
                cce.position,
                ccev.value as name,
                ccevu.value as url_key,
                ccevd.value as description,
                ccevmt.value as meta_title,
                ccevmd.value as meta_description,
                ccevkw.value as meta_keywords,
                ccevia.value as is_active
            FROM catalog_category_entity cce
            LEFT JOIN catalog_category_entity_varchar ccev ON cce.entity_id = ccev.entity_id AND ccev.attribute_id = ? AND (ccev.store_id = 0 OR ccev.store_id IS NULL)
            LEFT JOIN catalog_category_entity_varchar ccevu ON cce.entity_id = ccevu.entity_id AND ccevu.attribute_id = ? AND (ccevu.store_id = 0 OR ccevu.store_id IS NULL)
            LEFT JOIN catalog_category_entity_text ccevd ON cce.entity_id = ccevd.entity_id AND ccevd.attribute_id = ? AND (ccevd.store_id = 0 OR ccevd.store_id IS NULL)
            LEFT JOIN catalog_category_entity_varchar ccevmt ON cce.entity_id = ccevmt.entity_id AND ccevmt.attribute_id = ? AND (ccevmt.store_id = 0 OR ccevmt.store_id IS NULL)
            LEFT JOIN catalog_category_entity_varchar ccevmd ON cce.entity_id = ccevmd.entity_id AND ccevmd.attribute_id = ? AND (ccevmd.store_id = 0 OR ccevmd.store_id IS NULL)
            LEFT JOIN catalog_category_entity_text ccevkw ON cce.entity_id = ccevkw.entity_id AND ccevkw.attribute_id = ? AND (ccevkw.store_id = 0 OR ccevkw.store_id IS NULL)
            LEFT JOIN catalog_category_entity_int ccevia ON cce.entity_id = ccevia.entity_id AND ccevia.attribute_id = ? AND (ccevia.store_id = 0 OR ccevia.store_id IS NULL)
            WHERE cce.entity_id NOT IN (1, 2, 3, 5, 6)
            ORDER BY cce.level, cce.position, cce.entity_id
        `;

        const categories = await this.sourceDb.query(categoriesQuery, [
            nameAttrId, urlKeyAttrId, descriptionAttrId, metaTitleAttrId, metaDescriptionAttrId, metaKeywordsAttrId, isActiveAttrId
        ]);

        logger.info(`Found ${categories.length} categories to migrate`);

        if (categories.length === 0) {
            logger.warning('No categories found in source database');
            return;
        }

        // Ensure target has default language and get its ID
        const defaultLanguageId = await this.ensureDefaultLanguage();

        // Process categories hierarchically
        const categoryMapping = new Map();
        const processedCategories = new Set();

        // Start from root level (level = 3, since level 0-2 are excluded)
        const rootCategories = categories.filter(c => c.level === 3);
        for (const rootCategory of rootCategories) {
            await this.processCategoryRecursive(rootCategory, categories, categoryMapping, processedCategories, defaultLanguageId);
        }

        // Update parent relationships
        logger.info('Updating parent relationships...');

        // Update parent-child relationships
        for (const category of categories) {
            if (category.parent_id > 1) {
                const currentCategory = categoryMapping.get(category.entity_id);
                const parentCategory = categoryMapping.get(category.parent_id);

                if (currentCategory && parentCategory) {
                    await this.targetDb.query(`
                        UPDATE categories
                        SET parent_id = $1, updated_at = NOW()
                        WHERE id = $2
                    `, [parentCategory.id, currentCategory.id]);
                }
            }
        }

        // Skip parent_slugs calculation for now - will be done separately
        logger.info('Skipping parent_slugs calculation (will be done separately)');

        logger.success(`Categories migration completed: ${categoryMapping.size} categories processed`);
    }

    async getAttributeId(attributeCode, entityType = 'catalog_category') {
        const result = await this.sourceDb.query(
            'SELECT attribute_id FROM eav_attribute WHERE attribute_code = ? AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = ?)',
            [attributeCode, entityType]
        );
        const rows = this.sourceDb.dbType === 'postgresql' ? result.rows : result;
        return rows && rows.length > 0 ? rows[0].attribute_id : null;
    }

    async ensureDefaultLanguage() {
        const languages = await this.targetDb.query('SELECT id FROM languages WHERE code = $1', ['en']);
        if (!languages || languages.length === 0) {
            const languageId = uuidv4();
            await this.targetDb.query(
                'INSERT INTO languages (id, code, name, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                [languageId, 'en', 'English']
            );
            logger.info('Created default English language');
            return languageId;
        }
        return languages[0].id;
    }

    async processCategoryRecursive(category, allCategories, categoryMapping, processedCategories, defaultLanguageId) {
        if (processedCategories.has(category.entity_id)) {
            return;
        }

        const categoryId = uuidv4();
        const code = category.url_key ? `${category.url_key}_${category.entity_id}` : `category-${category.entity_id}`;
        const isHidden = category.is_active === 0 || category.is_active === '0';

        // Insert category
        const categoryResult = await this.targetDb.query(`
            INSERT INTO categories (id, code, sort, is_hidden, created_at, updated_at)
            VALUES ($1, $2, $3, $4, NOW(), NOW())
            ON CONFLICT (code) DO UPDATE SET
                sort = EXCLUDED.sort,
                is_hidden = EXCLUDED.is_hidden,
                updated_at = NOW()
            RETURNING id
        `, [categoryId, code, category.position || 0, isHidden]);

        const actualCategoryId = categoryResult[0].id;

        // Insert category translation (upsert approach - check if exists, update or insert)
        const slug = category.url_key || `category-${category.entity_id}`;
        const existingTranslation = await this.targetDb.query(`
            SELECT id FROM category_translations
            WHERE category_id = $1 AND language_id = $2
        `, [actualCategoryId, defaultLanguageId]);

        if (existingTranslation.length > 0) {
            // Update existing translation
            await this.targetDb.query(`
                UPDATE category_translations
                SET title = $1, description = $2, meta_title = $3, meta_description = $4, meta_keywords = $5, slug = $6, updated_at = NOW()
                WHERE category_id = $7 AND language_id = $8
            `, [category.name, category.description, category.meta_title, category.meta_description, category.meta_keywords, slug, actualCategoryId, defaultLanguageId]);
            logger.info(`Updated existing translation for category ${actualCategoryId}`);
        } else {
            // Insert new translation
            await this.targetDb.query(`
                INSERT INTO category_translations (id, title, description, meta_title, meta_description, meta_keywords, slug, parent_slugs, created_at, updated_at, category_id, language_id)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW(), $9, $10)
            `, [uuidv4(), category.name, category.description, category.meta_title, category.meta_description, category.meta_keywords, slug, null, actualCategoryId, defaultLanguageId]);
            logger.info(`Inserted new translation for category ${actualCategoryId}`);
        }

        categoryMapping.set(category.entity_id, { id: categoryId, code });
        processedCategories.add(category.entity_id);

        logger.info(`Processed category: ${category.name} (${category.entity_id}) -> ${code}`);

        // Process subcategories recursively
        const subcategories = allCategories.filter(c => c.parent_id === category.entity_id);
        for (const subcategory of subcategories) {
            await this.processCategoryRecursive(subcategory, allCategories, categoryMapping, processedCategories, defaultLanguageId);
        }

        // Process products in this category (tree-based migration)
        await this.processCategoryProducts(category.entity_id, actualCategoryId, defaultLanguageId);
    }

    async migrateProductTranslations(products, languageId) {
        logger.info('Starting product translations migration...');

        try {
            // Create product_web_sku mapping (same logic as in migrateProductBatch)
            const productWebSkus = products.map(p => {
                const timestamp = Math.floor(new Date(p.created_at) / 1000).toString(36);
                return p.product_sku + '-' + timestamp;
            });

            // Get product IDs from target using correct product_web_sku
            const targetProducts = await this.targetDb.query('SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productWebSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            const translations = [];
            for (const product of products) {
                // Create the same product_web_sku format
                const timestamp = Math.floor(new Date(product.created_at) / 1000).toString(36);
                const productWebSku = product.product_sku + '-' + timestamp;
                const productId = productMap.get(productWebSku);

                if (!productId) {
                    logger.warn(`Product ID not found for ${product.product_sku} (web_sku: ${productWebSku})`);
                    continue;
                }

                // Create translation even if name is null/empty (use SKU as fallback)
                const title = product.name || product.product_sku;
                const slug = product.url_key || title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

                // Manipulate description for target database format
                let manipulatedDescription = product.description;
                if (product.description && product.description.trim()) {
                    manipulatedDescription = `<div class=\"tiptap-summary\"><p><span style=\"color: rgb(0, 0, 0)\">${product.description.replace(/"/g, '"')}</span></p></div>`;
                }

                translations.push({
                    id: uuidv4(),
                    title: title,
                    description: manipulatedDescription,
                    short_description: product.short_description,
                    slug: slug,
                    meta_title: product.meta_title || null,
                    meta_description: product.meta_description || null,
                    meta_keywords: null, // meta_keywords attribute yok
                    product_id: productId,
                    language_id: languageId,
                    created_at: product.created_at,
                    updated_at: product.updated_at
                });
            }

            if (translations.length === 0) {
                logger.info('No translations to migrate');
                return;
            }

            logger.info(`Prepared ${translations.length} translations for migration`);

            // Batch upsert translations (SELECT + INSERT/UPDATE approach)
            for (const translation of translations) {
                // Check if translation already exists
                const existing = await this.targetDb.query(
                    'SELECT id FROM product_translations WHERE product_id = $1 AND language_id = $2',
                    [translation.product_id, translation.language_id]
                );

                if (existing.length > 0) {
                    // UPDATE existing translation
                    await this.targetDb.query(`
                        UPDATE product_translations SET
                            title = $1,
                            description = $2,
                            short_description = $3,
                            slug = $4,
                            meta_title = $5,
                            meta_description = $6,
                            meta_keywords = $7,
                            updated_at = $8
                        WHERE id = $9
                    `, [
                        translation.title,
                        translation.description,
                        translation.short_description,
                        translation.slug,
                        translation.meta_title,
                        translation.meta_description,
                        translation.meta_keywords,
                        translation.updated_at,
                        existing[0].id
                    ]);
                } else {
                    // INSERT new translation
                    await this.targetDb.query(`
                        INSERT INTO product_translations (
                            id, title, description, short_description, slug,
                            meta_title, meta_description, meta_keywords,
                            product_id, language_id, created_at, updated_at
                        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                    `, [
                        translation.id,
                        translation.title,
                        translation.description,
                        translation.short_description,
                        translation.slug,
                        translation.meta_title,
                        translation.meta_description,
                        translation.meta_keywords,
                        translation.product_id,
                        translation.language_id,
                        translation.created_at,
                        translation.updated_at
                    ]);
                }
            }

            logger.success(`Product translations migration completed: ${translations.length} translations inserted`);
        } catch (error) {
            logger.error('Product translations migration failed', { error: error.message });
        }
    }

    async migrateProductCategories(products) {
        logger.info('Starting product categories migration...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.targetDb.query('SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get existing categories from target
            const existingCategories = await this.targetDb.query(`
                SELECT c.id, c.code, ct.slug, ct.language_id
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
            `);

            // Create category mapping
            const categoryMap = new Map();

            // Get source category data for mapping
            const urlKeyAttrResult = await this.sourceDb.query('SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            let sourceCategories = [];
            if (urlKeyAttrId) {
                sourceCategories = await this.sourceDb.query(`
                    SELECT
                        cce.entity_id,
                        ccev.value as url_key
                    FROM catalog_category_entity cce
                    LEFT JOIN catalog_category_entity_varchar ccev ON cce.entity_id = ccev.entity_id
                        AND ccev.attribute_id = ? AND ccev.store_id = 0
                    WHERE cce.entity_id > 1
                `, [urlKeyAttrId]);
            }

            const sourceCategoryMap = new Map();
            sourceCategories.forEach(cat => {
                sourceCategoryMap.set(cat.entity_id, cat.url_key);
            });

            // Create mapping from source entity_id to target category_id
            for (const cat of existingCategories) {
                let sourceEntityId = null;

                if (cat.slug) {
                    for (const [entityId, urlKey] of sourceCategoryMap) {
                        if (urlKey === cat.code) {
                            sourceEntityId = entityId;
                            break;
                        }
                    }
                }

                if (!sourceEntityId) {
                    const match = cat.code.match(/^category-(\d+)$/);
                    if (match) {
                        sourceEntityId = parseInt(match[1]);
                    }
                }

                if (sourceEntityId) {
                    categoryMap.set(sourceEntityId, cat.id);
                }
            }

            // Process categories
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

            // Insert in batches
            const BATCH_SIZE = 500;
            let totalInserted = 0;

            for (let i = 0; i < productCategoryRelations.length; i += BATCH_SIZE) {
                const batch = productCategoryRelations.slice(i, i + BATCH_SIZE);
                const fieldCount = Object.keys(batch[0]).length;
                const placeholders = batch.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batch.flatMap(pc => Object.values(pc));
                const fields = Object.keys(batch[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);
                totalInserted += batch.length;
            }

            logger.success(`Product categories migration completed: ${totalInserted} relations inserted`);
        } catch (error) {
            logger.error('Product categories migration failed', { error: error.message });
        }
    }

    async migrateProductPrices(products) {
        logger.info('Starting product prices migration...');

        try {
            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.targetDb.query('SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Get target currencies
            const targetCurrencies = await this.targetDb.query('SELECT id, code FROM currencies');
            const currencyMap = new Map(targetCurrencies.map(c => [c.code, c.id]));

            // Get source currency rates (AUD as base)
            const currencyRates = await this.sourceDb.query('SELECT * FROM directory_currency_rate WHERE currency_from = "AUD"');

            const prices = [];
            for (const product of products) {
                const productId = productMap.get(product.product_sku);
                if (!productId || !product.price) continue;

                const audPrice = parseFloat(product.price);

                // Calculate prices for all allowed currencies using source rates
                currencyRates.forEach(rate => {
                    const currencyId = currencyMap.get(rate.currency_to);
                    if (currencyId) {
                        prices.push({
                            id: uuidv4(),
                            base_amount: audPrice, // AUD base amount
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

            // Batch insert prices with duplicate prevention
            const BATCH_SIZE = 500;
            for (let i = 0; i < prices.length; i += BATCH_SIZE) {
                const batch = prices.slice(i, i + BATCH_SIZE);

                // Check for existing prices to prevent duplicates (product_id + currency_id combination)
                const productIds = batch.map(p => p.product_id);
                const currencyIds = batch.map(p => p.currency_id);

                // Get all existing combinations
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

                if (newPrices.length === 0) continue;

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

            logger.success(`Product prices migration completed: ${prices.length} prices inserted`);
        } catch (error) {
            logger.error('Product prices migration failed', { error: error.message });
        }
    }

    async processCategoryProducts(sourceCategoryId, targetCategoryId, defaultLanguageId) {
        console.log(`📦 Processing products for category ${sourceCategoryId}...`);
        logger.info(`Processing products for category ${sourceCategoryId}`);

        try {
            // Get attribute IDs for EAV structure (catalog_product)
            const nameAttrId = await this.getAttributeId('name', 'catalog_product');
            const priceAttrId = await this.getAttributeId('price', 'catalog_product');
            const descAttrId = await this.getAttributeId('description', 'catalog_product');
            const shortDescAttrId = await this.getAttributeId('short_description', 'catalog_product');
            const imageAttrId = await this.getAttributeId('image', 'catalog_product');
            const urlKeyAttrId = await this.getAttributeId('url_key', 'catalog_product');
            const metaTitleAttrId = await this.getAttributeId('meta_title', 'catalog_product');
            const metaDescAttrId = await this.getAttributeId('meta_description', 'catalog_product');
            const certNumberAttrId = await this.getAttributeId('certification_number', 'catalog_product');
            const coinNumberAttrId = await this.getAttributeId('coin_number', 'catalog_product');
            const gradePrefixAttrId = await this.getAttributeId('grade_prefix', 'catalog_product');
            const gradeValueAttrId = await this.getAttributeId('grade_value', 'catalog_product');
            const gradeSuffixAttrId = await this.getAttributeId('grade_suffix', 'catalog_product');
            const yearAttrId = await this.getAttributeId('year', 'catalog_product');

            // Query products for this specific category using flat table for grade data
            const productsQuery = `
                SELECT
                    cpe.entity_id,
                    cpe.sku as product_sku,
                    cpf.name as name,
                    cpf.price as price,
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
                    cpf.grade_prefix,
                    cpf.grade_value,
                    cpf.grade_suffix,
                    cpf.year,
                    sold_dates.first_sale_date as sold_date,
                    sold_prices.last_sold_price as last_sold_price
                FROM catalog_product_entity cpe
                LEFT JOIN catalog_product_flat_1 cpf ON cpe.entity_id = cpf.entity_id
                LEFT JOIN catalog_product_entity_varchar cpevs_meta_title ON cpe.entity_id = cpevs_meta_title.entity_id AND cpevs_meta_title.attribute_id = ? AND cpevs_meta_title.store_id = 0
                LEFT JOIN catalog_product_entity_varchar cpevs_meta_desc ON cpe.entity_id = cpevs_meta_desc.entity_id AND cpevs_meta_desc.attribute_id = ? AND cpevs_meta_desc.store_id = 0
                LEFT JOIN catalog_product_entity_text cpet_cert ON cpe.entity_id = cpet_cert.entity_id AND cpet_cert.attribute_id = ? AND cpet_cert.store_id = 0
                LEFT JOIN catalog_product_entity_text cpet_coin ON cpe.entity_id = cpet_coin.entity_id AND cpet_coin.attribute_id = ? AND cpet_coin.store_id = 0
                INNER JOIN catalog_category_product ccp ON cpe.entity_id = ccp.product_id AND ccp.category_id = ?
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

            const products = await this.sourceDb.query(productsQuery, [metaTitleAttrId, metaDescAttrId, certNumberAttrId, coinNumberAttrId, sourceCategoryId]);

            if (products.length === 0) {
                logger.info(`No products found for category ${sourceCategoryId}`);
                return;
            }

            console.log(`📦 Found ${products.length} products in category ${sourceCategoryId}`);
            logger.info(`Found ${products.length} products in category ${sourceCategoryId}`);

            // Process products in batches
            const BATCH_SIZE = 100;
            for (let i = 0; i < products.length; i += BATCH_SIZE) {
                const batch = products.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                console.log(`🔄 Processing product batch ${batchIndex}/${Math.ceil(products.length / BATCH_SIZE)} (${batch.length} products)`);

                // Migrate products (upsert)
                await this.migrateProductBatch(batch, targetCategoryId, defaultLanguageId);

                // Process orders for each product in this batch
                for (const product of batch) {
                    // await this.processProductOrders(product.entity_id, defaultLanguageId);
                }
            }

            logger.info(`Completed processing ${products.length} products for category ${sourceCategoryId}`);

        } catch (error) {
            logger.error(`Failed to process products for category ${sourceCategoryId}`, { error: error.message });
        }
    }

    async getSourceToTargetCategoryMapping() {
        try {
            // Get all target categories (remove language filter to include all categories)
            const targetCategories = await this.targetDb.query(`
                SELECT c.id, c.code, ct.slug
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id AND ct.language_id = (SELECT id FROM languages WHERE code = 'en' LIMIT 1)
            `);

            const mapping = new Map();

            for (const cat of targetCategories) {
                // Extract source entity_id from code (format: url_key_entity_id or category-entity_id)
                let sourceEntityId = null;

                if (cat.code.includes('_')) {
                    const parts = cat.code.split('_');
                    const lastPart = parts[parts.length - 1];
                    if (!isNaN(parseInt(lastPart))) {
                        sourceEntityId = parseInt(lastPart);
                    }
                }

                if (!sourceEntityId) {
                    const match = cat.code.match(/^category-(\d+)$/);
                    if (match) {
                        sourceEntityId = parseInt(match[1]);
                    }
                }

                if (sourceEntityId) {
                    mapping.set(sourceEntityId, cat.id);
                }
            }

            return mapping;
        } catch (error) {
            logger.error('Failed to get source to target category mapping', { error: error.message });
            return new Map();
        }
    }

    async migrateProductBatch(products, targetCategoryId, defaultLanguageId) {
        try {
            // Ana kategorileri belirle
            const masterCategoryMap = await this.determineMasterCategories(products);

            // Get source to target category mapping
            const categoryMapping = await this.getSourceToTargetCategoryMapping();


            const coinOurGrade = (p) => {
                const ngcScaleMapping = {
                    70: 10,
                    69: 9.9,
                    68: 9.8,
                    67: 9.7,
                    66: 9.6,
                    65: 9.5,
                    64: 9.4,
                    63: 9.3,
                    62: 9.2,
                    61: 9.1,
                    60: 9,
                    58: 8.8,
                    55: 8.5,
                    53: 8.3,
                    50: 8,
                    45: 7.5,
                    40: 7,
                    35: 6.5,
                    30: 6,
                    25: 5.5,
                    20: 5,
                    15: 4.5,
                    12: 4,
                    10: 3.5,
                    8: 3,
                    6: 2.5,
                    4: 2,
                    3: 1.5,
                    2: 1.5,
                    1: 1,
                };

                const convertTo10PointScale = (grade70) => {
                    if (ngcScaleMapping[grade70]) {
                        return ngcScaleMapping[grade70];
                    }

                    const closestGrade70 = validateGrade(grade70);
                    return ngcScaleMapping[closestGrade70];
                };

                const validateGrade = (grade) => {
                    const allowedValues = Object.keys(ngcScaleMapping).map(Number);

                    // Get the closest value to the selected range
                    const findClosestValue = (val) => {
                        return allowedValues.reduce((prev, curr) =>
                            Math.abs(curr - val) < Math.abs(prev - val) ? curr : prev,
                        );
                    };
                    // Get the closest min and max values to the selected range
                    const closestGrade = findClosestValue(grade);
                    return closestGrade;
                };

                if (p.grade_value) {
                    const gradeFloat = parseFloat(p.grade_value);
                    return convertTo10PointScale(gradeFloat);
                }
            }


            const pgProducts = products.map(p => {
                // Determine master category with fallback
                let masterCategoryId = null;

                // Try to get master category from mapping
                const masterCategorySourceId = masterCategoryMap.get(p.entity_id);
                if (masterCategorySourceId) {
                    masterCategoryId = categoryMapping.get(masterCategorySourceId);
                }

                // Fallback: if no master category found, use the current category being processed
                if (!masterCategoryId) {
                    masterCategoryId = targetCategoryId;
                    logger.warn(`Using fallback category ${targetCategoryId} for product ${p.product_sku} (${p.entity_id})`);
                }

                return {
                    id: uuidv4(),
                    product_identity: `${p.product_sku}-${p.entity_id}`,
                    product_sku: p.product_sku,
                    product_web_sku: p.product_sku + '-' + (() => { const now = Math.floor(new Date(p.created_at) / 1000); return now.toString(36); })(),
                    cert_number: p.certification_number || null,
                    coin_video: null,
                    is_coin_video: false,
                    coin_number: p.coin_number || null,
                    coin_our_grade: coinOurGrade(p) || null,
                    coin_grade_type: p.grade_value || null,  // 64, 70, etc.
                    coin_grade_prefix: p.grade_prefix || null,  // MS, AU, etc.
                    coin_grade_suffix: p.grade_suffix || null,  // DCAM, CAM, RB, etc.
                    coin_grade: p.grade_value ? parseFloat(p.grade_value) : null,  // 64.00, 70.00, etc.
                    coin_grade_text: p.grade_prefix ? (p.grade_value ? ' ' + p.grade_value : '') + (p.grade_suffix ? ' ' + p.grade_suffix : '') || null : null, // Full grade text
                    year_text: p.year || null,
                    coin_grade_prefix_type: p.grade_prefix || null,
                    year_date: p.year && !isNaN(parseInt(p.year)) ? new Date(parseInt(p.year), 0, 1) : null,
                    is_second_hand: false,
                    is_consignment: false,
                    is_active: true,
                    is_on_hold: false,
                    // bütün ürünler pending tir.
                    // ürün satıldığında yani bir sold date geldiğinde status sold olacaktır.
                    // fakat ürün satıldıktan sonra 14 gün geçmiş ise, status archived olacaktır.
                    status: p.sold_date ? (new Date() - new Date(p.sold_date) > 14 * 24 * 60 * 60 * 1000 ? 'archived' : 'sold') : 'pending',
                    quantity: 1,
                    price: parseFloat(p.price) || 0,
                    sold_date: p.sold_date || null,
                    archived_at: p.sold_date && (new Date() - new Date(p.sold_date) > 14 * 24 * 60 * 60 * 1000) ? new Date(new Date(p.sold_date).getTime() + 14 * 24 * 60 * 60 * 1000) : null,
                    sold_price: p.last_sold_price || null,
                    discount_price: null,
                    ebay_offer_code: null,
                    stars: 0,
                    created_at: p.created_at,
                    updated_at: p.updated_at,
                    deleted_at: null,
                    product_master_image_id: null,
                    certificate_provider_id: null,
                    master_category_id: masterCategoryId,
                    xero_tenant_id: null,
                    country_id: null
                };
            });

            // Insert products with upsert
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
                    price = EXCLUDED.price,
                    sold_date = EXCLUDED.sold_date,
                    sold_price = EXCLUDED.sold_price,
                    updated_at = EXCLUDED.updated_at
            `;

            await this.targetDb.query(insertQuery, values);

            // Create product-category relations
            const productCategoryRelations = products.map(p => ({
                id: uuidv4(),
                product_id: null, // Will be set after getting product IDs
                category_id: targetCategoryId,
                created_at: p.created_at,
                updated_at: p.updated_at
            }));

            // Get product IDs from target
            const productSkus = products.map(p => p.product_sku);
            const targetProducts = await this.targetDb.query('SELECT id, product_web_sku FROM products WHERE product_web_sku = ANY($1)', [productSkus]);
            const productMap = new Map(targetProducts.map(p => [p.product_web_sku, p.id]));

            // Set product IDs and filter valid relations
            const validRelations = productCategoryRelations.filter(rel => {
                const product = products.find(p => p.product_sku === productSkus[productCategoryRelations.indexOf(rel)]);
                rel.product_id = productMap.get(product.product_sku);
                return rel.product_id;
            });

            if (validRelations.length > 0) {
                const relFieldCount = Object.keys(validRelations[0]).length;
                const relPlaceholders = validRelations.map((_, index) => {
                    const start = index * relFieldCount + 1;
                    const params = Array.from({ length: relFieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const relValues = validRelations.flatMap(pc => Object.values(pc));
                const relFields = Object.keys(validRelations[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_categories (${relFields}) VALUES ${relPlaceholders} ON CONFLICT DO NOTHING`, relValues);
            }

            // Migrate product translations
            await this.migrateProductTranslations(products, defaultLanguageId);

        } catch (error) {
            logger.error('Failed to migrate product batch', { error: error.message });
        }
    }

    async processProductOrders(sourceProductId, defaultLanguageId) {
        console.log(`🛒 Processing orders for product ${sourceProductId}...`);

        try {
            // Get orders for this product
            const ordersQuery = `
                SELECT DISTINCT
                    so.entity_id as order_id,
                    so.increment_id,
                    so.created_at,
                    so.updated_at,
                    so.status,
                    so.customer_id,
                    so.customer_email,
                    so.customer_firstname,
                    so.customer_lastname,
                    soi.price,
                    soi.qty_ordered,
                    soi.row_total
                FROM sales_order so
                JOIN sales_order_item soi ON so.entity_id = soi.order_id
                WHERE soi.product_id = ? AND so.status IN ('complete', 'a_complete')
                ORDER BY so.created_at DESC
            `;

            const orders = await this.sourceDb.query(ordersQuery, [sourceProductId]);

            if (orders.length === 0) {
                return; // No orders for this product
            }

            console.log(`🛒 Found ${orders.length} orders for product ${sourceProductId}`);

            // Process each order (migrate order and customer if needed)
            for (const order of orders) {
                await this.migrateOrderAndCustomer(order, defaultLanguageId);
            }

        } catch (error) {
            logger.error(`Failed to process orders for product ${sourceProductId}`, { error: error.message });
        }
    }

    async determineMasterCategories(products) {
        const masterCategoryMap = new Map();

        try {
            // Her ürün için kategorilerini ayrı ayrı al (MySQL IN limit sorunu için)
            for (const product of products) {
                const categoriesQuery = `
                    SELECT
                        ccp.category_id,
                        cce.level,
                        cce.position
                    FROM catalog_category_product ccp
                    JOIN catalog_category_entity cce ON ccp.category_id = cce.entity_id
                    WHERE ccp.product_id = ?
                    ORDER BY cce.level DESC, cce.position ASC
                `;

                const categories = await this.sourceDb.query(categoriesQuery, [product.entity_id]);

                // Ana kategori belirleme: En yüksek level (en derin kategori)
                if (categories.length === 0) {
                    logger.warn(`Product ${product.product_sku} (${product.entity_id}) has no categories`);
                    continue;
                }

                // En yüksek level'ı bul
                const maxLevel = Math.max(...categories.map(c => c.level));
                const highestLevelCategories = categories.filter(c => c.level === maxLevel);

                // Aynı level'da birden fazla varsa position'a göre sırala (en küçük position)
                const masterCategory = highestLevelCategories.sort((a, b) => a.position - b.position)[0];

                masterCategoryMap.set(product.entity_id, masterCategory.category_id);
            }

        } catch (error) {
            logger.error('Failed to determine master categories', { error: error.message });
        }

        return masterCategoryMap;
    }

    async migrateOrderAndCustomer(orderData, defaultLanguageId) {
        try {
            // Check if customer already exists
            let customerId = null;
            if (orderData.customer_email) {
                const existingCustomer = await this.targetDb.query('SELECT id FROM users WHERE email = $1', [orderData.customer_email]);
                if (existingCustomer.length > 0) {
                    customerId = existingCustomer[0].id;
                } else {
                    // Create new customer
                    customerId = uuidv4();
                    const userCode = `CUST-${customerId.substring(0, 8).toUpperCase()}`;
                    await this.targetDb.query(`
                        INSERT INTO users (id, user_code, email, first_name, last_name, created_at, updated_at)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [customerId, userCode, orderData.customer_email, orderData.customer_firstname, orderData.customer_lastname, orderData.created_at, orderData.updated_at]);

                    // Assign default role
                    const defaultRole = await this.targetDb.query('SELECT id FROM roles WHERE name = $1', ['customer']);
                    if (defaultRole.length > 0) {
                        await this.targetDb.query(`
                            INSERT INTO user_roles (id, user_id, role_id, created_at, updated_at)
                            VALUES ($1, $2, $3, NOW(), NOW())
                        `, [uuidv4(), customerId, defaultRole[0].id]);
                    }
                }
            }

            // Check if order already exists
            const existingOrder = await this.targetDb.query('SELECT id FROM orders WHERE order_number = $1', [orderData.increment_id]);
            if (existingOrder.length > 0) {
                return; // Order already exists
            }

            // Create order
            const orderId = uuidv4();
            await this.targetDb.query(`
                INSERT INTO orders (id, order_number, customer_id, status, total_amount, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6, $7)
            `, [orderId, orderData.increment_id, customerId, orderData.status, parseFloat(orderData.row_total) || 0, orderData.created_at, orderData.updated_at]);

            // Create order customer relation
            if (customerId) {
                await this.targetDb.query(`
                    INSERT INTO order_customers (id, order_id, customer_id, created_at, updated_at)
                    VALUES ($1, $2, $3, $4, $5)
                `, [uuidv4(), orderId, customerId, orderData.created_at, orderData.updated_at]);
            }

            console.log(`✅ Migrated order ${orderData.increment_id} with customer ${orderData.customer_email || 'guest'}`);

        } catch (error) {
            logger.error('Failed to migrate order and customer', { error: error.message, order: orderData.increment_id });
        }
    }
}

module.exports = MigrationV2;
