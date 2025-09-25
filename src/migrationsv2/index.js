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

        // TODO: Implement products, orders, customers migration

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

        // Get categories from source (exclude root and Latest Coins)
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
            WHERE cce.entity_id > 1 AND cce.entity_id != 6
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

        // Start from root level (parent_id = 1)
        const rootCategories = categories.filter(c => c.parent_id === 1);
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

        // Calculate hierarchical parent_slugs (full path)
        logger.info('Calculating hierarchical parent_slugs...');

        const processedSlugs = new Set();
        const calculateParentSlugs = async (categoryId, languageId, currentPath = '') => {
            if (processedSlugs.has(categoryId)) {
                return;
            }

            const category = categories.find(c => categoryMapping.get(c.entity_id)?.id === categoryId);
            if (!category) return;

            let parentSlugs = currentPath;

            // Update parent_slugs
            logger.info(`Updating parent_slugs for category ${categoryId}: ${parentSlugs}`);
            const checkResult = await this.targetDb.query(`
                SELECT id FROM category_translations
                WHERE category_id = $1 AND language_id = $2
            `, [categoryId, languageId]);
            logger.info(`Found ${checkResult.length} translations for category ${categoryId}`);
            const updateResult = await this.targetDb.query(`
                UPDATE category_translations
                SET parent_slugs = $1, updated_at = NOW()
                WHERE category_id = $2 AND language_id = $3
            `, [parentSlugs, categoryId, languageId]);
            logger.info(`Updated ${updateResult.rowCount} rows for parent_slugs`);

            processedSlugs.add(categoryId);

            // Process children
            const children = categories.filter(c => c.parent_id === category.entity_id);
            for (const child of children) {
                const childMapping = categoryMapping.get(child.entity_id);
                if (childMapping) {
                    // Get child's slug for path
                    const childSlugResult = await this.targetDb.query(`
                        SELECT slug FROM category_translations
                        WHERE category_id = $1 AND language_id = $2
                    `, [childMapping.id, languageId]);
                    if (childSlugResult && childSlugResult.length > 0) {
                        const childSlug = childSlugResult[0].slug;
                        const childPath = parentSlugs ? `${parentSlugs}/${childSlug}` : childSlug;
                        await calculateParentSlugs(childMapping.id, languageId, childPath);
                    }
                }
            }
        };

        // Start from root categories for parent_slugs calculation
        const rootCategoriesForSlugs = categories.filter(c => c.parent_id === 1);
        for (const rootCategory of rootCategoriesForSlugs) {
            const rootMapping = categoryMapping.get(rootCategory.entity_id);
            if (rootMapping) {
                await calculateParentSlugs(rootMapping.id, defaultLanguageId, '');
            }
        }

        logger.success(`Categories migration completed: ${categoryMapping.size} categories processed`);
    }

    async getAttributeId(attributeCode) {
        const result = await this.sourceDb.query(
            'SELECT attribute_id FROM eav_attribute WHERE attribute_code = ? AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")',
            [attributeCode]
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

        // TODO: Process products in this category
        // await this.processCategoryProducts(category.entity_id, categoryId);
    }

    // TODO: Implement product processing
    // async processCategoryProducts(sourceCategoryId, targetCategoryId) {
    //     // Get products in this category
    //     // Process each product
    //     // For each product, process orders and customers
    // }
}

module.exports = MigrationV2;
