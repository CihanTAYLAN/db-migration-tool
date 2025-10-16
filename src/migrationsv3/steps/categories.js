/*
# Categories Migration Step

Migrates categories and their translations using batch processing.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const DataTransformer = require('../lib/data-transformer');

class CategoriesStep {
    constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = eavMapper;
        this.defaultLanguageId = defaultLanguageId;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.categories.batchSize,
            parallelLimit: config.steps.categories.parallelLimit,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Categories migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.dataTransformer = new DataTransformer();
    }

    async run() {
        logger.info('Starting categories migration step...');

        try {
            // 1. Fetch source categories
            const categories = await this.fetchSourceCategories();

            if (categories.length === 0) {
                logger.warning('No categories found to migrate');
                return { success: true, count: 0 };
            }

            logger.info(`Found ${categories.length} categories to migrate`);

            // 2. Transform and migrate categories in batches
            const result = await this.batchProcessor.process(categories, async (batch) => {
                return await this.processCategoryBatch(batch);
            });

            // 3. Update parent relationships
            await this.updateParentRelationships();

            // Parent slugs will be calculated after migration using a separate script
            logger.info('Parent slugs will be calculated after migration using merge-subcategories script');

            logger.success(`Categories migration completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Categories migration step failed', { error: error.message });
            throw error;
        }
    }

    async fetchSourceCategories() {
        logger.info('Fetching source categories from flat table...');

        // Use flat table for more reliable data
        const query = `
            SELECT
                ccf.entity_id,
                ccf.parent_id,
                ccf.path,
                ccf.level,
                ccf.position,
                ccf.name,
                ccf.url_key,
                ccf.description,
                ccf.meta_title,
                ccf.meta_description,
                ccf.meta_keywords,
                ccf.is_active
            FROM catalog_category_flat_store_1 ccf
            WHERE ccf.entity_id NOT IN (${this.config.filters.excludedCategoryIds.join(',')})
            ORDER BY ccf.level, ccf.position, ccf.entity_id
        `;

        const categories = await this.sourceDb.query(query);

        return categories;
    }

    async processCategoryBatch(categories) {
        try {
            // Transform categories and translations
            const transformed = this.dataTransformer.transformCategories(categories, this.defaultLanguageId);

            // Insert categories and get the actual IDs
            let insertedCategories = [];
            if (transformed.categories.length > 0) {
                insertedCategories = await this.insertCategories(transformed.categories);
            }

            // Create mapping from original ID to actual ID
            const idMapping = new Map();
            insertedCategories.forEach(cat => {
                idMapping.set(cat.originalId, cat.actualId);
            });

            // Update translation category_ids with actual IDs
            const updatedTranslations = transformed.translations.map(translation => ({
                ...translation,
                category_id: idMapping.get(translation.category_id) || translation.category_id
            }));

            // Insert category translations
            if (updatedTranslations.length > 0) {
                await this.insertCategoryTranslations(updatedTranslations);
            }

            return { success: categories.length, failed: 0 };

        } catch (error) {
            logger.error('Failed to process category batch', { error: error.message, count: categories.length });
            return { success: 0, failed: categories.length };
        }
    }

    async insertCategories(categories) {
        // Insert categories one by one to get the actual IDs
        const insertedCategories = [];

        for (const category of categories) {
            const result = await this.targetDb.query(`
                INSERT INTO categories (id, code, sort, is_hidden, created_at, updated_at)
                VALUES ($1, $2, $3, $4, $5, $6)
                ON CONFLICT (code) DO UPDATE SET
                    sort = EXCLUDED.sort,
                    is_hidden = EXCLUDED.is_hidden,
                    updated_at = NOW()
                RETURNING id, code
            `, [category.id, category.code, category.sort, category.is_hidden, category.created_at, category.updated_at]);

            insertedCategories.push({
                originalId: category.id,
                actualId: result[0].id,
                code: result[0].code
            });
        }

        return insertedCategories;
    }

    async insertCategoryTranslations(translations) {
        // Process translations individually to handle upserts properly
        for (const translation of translations) {
            const existing = await this.targetDb.query(
                'SELECT id FROM category_translations WHERE category_id = $1 AND language_id = $2',
                [translation.category_id, translation.language_id]
            );

            if (existing.length > 0) {
                // Update existing
                await this.targetDb.query(`
                    UPDATE category_translations SET
                        title = $1, description = $2, meta_title = $3, meta_description = $4,
                        meta_keywords = $5, slug = $6, updated_at = NOW()
                    WHERE id = $7
                `, [
                    translation.title, translation.description, translation.meta_title,
                    translation.meta_description, translation.meta_keywords, translation.slug,
                    existing[0].id
                ]);
            } else {
                // Insert new
                await this.targetDb.query(`
                    INSERT INTO category_translations (
                        id, title, description, meta_title, meta_description, meta_keywords,
                        slug, parent_slugs, category_id, language_id, created_at, updated_at
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
                `, Object.values(translation));
            }
        }
    }

    async updateParentRelationships() {
        logger.info('Updating parent relationships...');

        // Get all categories with their codes to build mapping
        const categories = await this.targetDb.query(`
            SELECT c.id, c.code, ct.slug
            FROM categories c
            LEFT JOIN category_translations ct ON c.id = ct.category_id
            WHERE ct.language_id = $1
        `, [this.defaultLanguageId]);

        // Build entity_id to category_id mapping from codes
        const categoryMapping = new Map();
        for (const cat of categories) {
            // Updated format: url_key_parentId_entityId or category-parentId-entityId
            if (cat.code.includes('_')) {
                const parts = cat.code.split('_');
                const entityId = parseInt(parts[parts.length - 1]); // Last part is entity_id
                if (!isNaN(entityId)) {
                    categoryMapping.set(entityId, cat.id);
                }
            } else if (cat.code.startsWith('category-')) {
                const parts = cat.code.split('-');
                const entityId = parseInt(parts[parts.length - 1]); // Last part is entity_id
                if (!isNaN(entityId)) {
                    categoryMapping.set(entityId, cat.id);
                }
            }
        }

        // Update parent relationships
        let updatedCount = 0;
        for (const cat of categories) {
            let entityId = null;

            // Extract entity_id from updated code format
            if (cat.code.includes('_')) {
                const parts = cat.code.split('_');
                entityId = parseInt(parts[parts.length - 1]); // Last part is entity_id
            } else if (cat.code.startsWith('category-')) {
                const parts = cat.code.split('-');
                entityId = parseInt(parts[parts.length - 1]); // Last part is entity_id
            }

            if (entityId && !isNaN(entityId)) {
                const parentEntityId = await this.getParentEntityId(entityId);

                if (parentEntityId && parentEntityId > 1) {
                    const parentCategoryId = categoryMapping.get(parentEntityId);
                    if (parentCategoryId) {
                        await this.targetDb.query(`
                            UPDATE categories
                            SET parent_id = $1, updated_at = NOW()
                            WHERE id = $2
                        `, [parentCategoryId, cat.id]);
                        updatedCount++;
                    }
                }
            }
        }

        logger.info(`Updated parent relationships for ${updatedCount} categories`);
    }

    async getParentEntityId(entityId) {
        // This is a simplified version - in real implementation you'd cache this
        const result = await this.sourceDb.query(
            'SELECT parent_id FROM catalog_category_entity WHERE entity_id = ?',
            [entityId]
        );
        return result && result.length > 0 ? result[0].parent_id : null;
    }


}

module.exports = CategoriesStep;
