/*
# Simple Category Merger - V3 (Clean Slug-based Approach)

Bu script, migration tamamlandıktan sonra çalıştırılır ve aynı slug + parent slug
kombinasyonuna sahip kategori duplicate'larını merge eder.

Simple Business Logic:
- Aynı slug'a sahip kategoriler gruplandırılır
- Aynı parent slug'a sahip olmayanlar farklı gruplarda kalır (farklı parent'lar)
- Her grupta bir kategori kalacak şekilde merge yapılır
- Merge sonucu parent sluglar yeniden hesaplanır

## Yeni Yaklaşım Avantajları:
- Migration kodlarına bağımlı değil (slug-based)
- Basit ve anlaşılır SQL sorguları
- Parent-child ilişkileri korur
- Hiyerarşik yapıya saygılı

## Kullanım
node src/migrationsv3/steps/merge-subcategories.js
*/

const { DbClient } = require('../../db');
const logger = require('../../logger');
const { v4: uuidv4 } = require('uuid');

class SimpleCategoryMergerV3 {
    constructor(targetDb) {
        this.targetDb = targetDb;
    }

    async connectDatabase() {
        // Database already connected, no need to connect again
        logger.info('Using existing database connection...');
    }

    async disconnectDatabase() {
        // Don't close database if it was passed from outside (migration context)
        logger.info('Database connection handling completed');
    }

    async run() {
        try {
            await this.connectDatabase();

            logger.info('🧹 Starting simple category merger process...');

            // Step 1: Find mergeable category groups (same slug + parent slug)
            const mergeGroups = await this.findMergeableGroups();
            if (mergeGroups.length === 0) {
                logger.info('No categories found to merge');
                return { success: true, message: 'No categories to merge' };
            }

            logger.info(`Found ${mergeGroups.length} merge groups`);

            // Step 2: Execute merges for each group
            const mergeResults = await this.executeMerges(mergeGroups);

            // Step 3: Update parent slugs for all remaining categories
            await this.updateParentSlugs();

            logger.success('✅ Simple category merger completed successfully');

            return {
                success: true,
                message: 'Category merger completed successfully',
                stats: mergeResults
            };

        } catch (error) {
            logger.error('❌ Simple category merger failed', { error: error.message, stack: error.stack });
            return {
                success: false,
                message: error.message
            };
        } finally {
            await this.disconnectDatabase();
        }
    }

    // Step 1: Find categories that have same slug + same parent slug (should be merged)
    async findMergeableGroups() {
        logger.info('🔍 Finding mergeable category groups (same slug + same parent slug)...');

        const query = `
            SELECT
                ct.slug as category_slug,
                COALESCE(parent_ct.slug, '') as parent_slug,
                ARRAY_AGG(c.id ORDER BY c.id) as category_ids,
                ARRAY_AGG(ct.title ORDER BY c.id) as titles,
                COUNT(*) as category_count
            FROM categories c
            JOIN category_translations ct ON c.id = ct.category_id AND ct.language_id = 'fc22f4bd-7ad9-4d8a-8504-779741a152e7'
            LEFT JOIN categories parent_c ON c.parent_id = parent_c.id
            LEFT JOIN category_translations parent_ct ON parent_c.id = parent_ct.category_id AND parent_ct.language_id = 'fc22f4bd-7ad9-4d8a-8504-779741a152e7'
            GROUP BY ct.slug, COALESCE(parent_ct.slug, '')
            HAVING COUNT(*) > 1
            ORDER BY category_count DESC, ct.slug
        `;

        const groups = await this.targetDb.query(query);

        logger.info(`Found ${groups.length} merge groups`);

        groups.forEach(group => {
            logger.debug(`Merge group: "${group.category_slug}" (parent: "${group.parent_slug}") - ${group.category_count} categories: ${group.titles.join(', ')}`);
        });

        return groups;
    }

    // Step 2: Execute merges for each group
    async executeMerges(mergeGroups) {
        logger.info('🔄 Executing category merges...');

        const stats = {
            totalGroups: mergeGroups.length,
            processedGroups: 0,
            mergedCategories: 0,
            movedProducts: 0,
            deletedCategories: 0
        };

        for (const group of mergeGroups) {
            try {
                logger.info(`Processing merge group "${group.category_slug}" (parent: "${group.parent_slug}") with ${group.category_count} categories: ${group.titles.join(', ')}`);

                const result = await this.mergeCategoriesInGroup(group.category_ids, group.titles[0]);
                stats.mergedCategories += result.mergedCategories;
                stats.movedProducts += result.movedProducts;
                stats.deletedCategories += result.deletedCategories;

                stats.processedGroups++;

            } catch (error) {
                logger.error(`Failed to process merge group "${group.category_slug}"`, { error: error.message });
            }
        }

        logger.success(`✅ Merge execution completed: ${stats.processedGroups}/${stats.totalGroups} groups processed`);
        logger.success(`📊 Stats: Merged ${stats.mergedCategories} categories, moved ${stats.movedProducts} products, deleted ${stats.deletedCategories} categories`);

        return stats;
    }



    async mergeCategoriesInGroup(categoryIds, groupTitle) {
        logger.info(`Merging category group "${groupTitle}" with ${categoryIds.length} categories`);

        if (categoryIds.length < 2) {
            logger.debug('Only one category in group - no merge needed');
            return { mergedCategories: 0, movedProducts: 0, deletedCategories: 0 };
        }

        // Keep the first category, merge others into it
        const mainCategoryId = categoryIds[0];
        const categoriesToMerge = categoryIds.slice(1);

        logger.debug(`Keeping main category ${mainCategoryId}, merging ${categoriesToMerge.length} categories into it`);

        let movedProducts = 0;
        let deletedCategories = 0;

        // Move products from duplicate categories to main category
        for (const categoryToMergeId of categoriesToMerge) {
            const moveResult = await this.transferProductsToMainCategory(categoryToMergeId, mainCategoryId);
            movedProducts += moveResult.movedCount;
        }

        // Delete duplicate categories
        for (const categoryToMergeId of categoriesToMerge) {
            await this.deleteCategorySafely(categoryToMergeId);
            deletedCategories++;
        }

        logger.debug(`Merged group "${groupTitle}": kept ${mainCategoryId}, moved ${movedProducts} products, deleted ${deletedCategories} categories`);

        return {
            mergedCategories: categoriesToMerge.length,
            movedProducts,
            deletedCategories
        };
    }

    async transferProductsToMainCategory(fromCategoryId, toCategoryId) {
        let movedCount = 0;

        try {
            // Get products from source category
            const sourceProducts = await this.targetDb.query(
                `SELECT product_id FROM product_categories WHERE category_id = $1`,
                [fromCategoryId]
            );

            if (sourceProducts.length === 0) {
                logger.debug(`No products to move from category ${fromCategoryId} to ${toCategoryId}`);
                return { movedCount: 0 };
            }

            logger.debug(`Moving ${sourceProducts.length} products from category ${fromCategoryId} to ${toCategoryId}`);

            // Check existing relations to avoid duplicates
            const existingRelations = await this.targetDb.query(
                `SELECT product_id FROM product_categories WHERE category_id = $1`,
                [toCategoryId]
            );

            const existingProductIds = new Set(existingRelations.map(r => r.product_id));

            // Filter products that are not already in target category
            const productsToMove = sourceProducts.filter(p => !existingProductIds.has(p.product_id));

            if (productsToMove.length === 0) {
                logger.debug('All products already exist in target category');
                return { movedCount: 0 };
            }

            // Insert new relations in batches
            const BATCH_SIZE = 100;
            for (let i = 0; i < productsToMove.length; i += BATCH_SIZE) {
                const batch = productsToMove.slice(i, i + BATCH_SIZE);
                const batchRelations = batch.map(p => ({
                    id: uuidv4(),
                    product_id: p.product_id,
                    category_id: toCategoryId,
                    created_at: new Date(),
                    updated_at: new Date()
                }));

                // Insert relations
                const fieldCount = Object.keys(batchRelations[0]).length;
                const placeholders = batchRelations.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batchRelations.flatMap(r => Object.values(r));
                const fields = Object.keys(batchRelations[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_categories (${fields}) VALUES ${placeholders}`, values);
                movedCount += batch.length;
            }

            logger.debug(`Successfully moved ${movedCount} products to category ${toCategoryId}`);

        } catch (error) {
            logger.error(`Failed to transfer products from ${fromCategoryId} to ${toCategoryId}`, { error: error.message });
        }

        return { movedCount };
    }

    async deleteCategorySafely(categoryId) {
        try {
            // This method only deletes the category itself
            // Product relationships are kept intentionally (transferred to main category)

            // Delete category translations (DO NOT delete product_categories - they're needed!)
            await this.targetDb.query('DELETE FROM category_translations WHERE category_id = $1', [categoryId]);

            // Delete category
            await this.targetDb.query('DELETE FROM categories WHERE id = $1', [categoryId]);

            logger.debug(`Safely deleted category ${categoryId} (relationships preserved)`);

        } catch (error) {
            logger.error(`Failed to delete category ${categoryId}`, { error: error.message });
        }
    }

    async updateParentSlugs() {
        logger.info('🔗 Step 4: Updating parent slugs for all categories...');

        try {
            // This is the same parent slug calculation logic from the old version
            // We'll keep it intact since it was working
            const languages = await this.targetDb.query('SELECT id, code FROM languages ORDER BY id');

            for (const language of languages) {
                await this.calculateParentSlugsForLanguage(language);
            }

            logger.success('✅ Parent slugs updated for all categories');

        } catch (error) {
            logger.error('Failed to update parent slugs', { error: error.message });
        }
    }



    async calculateParentSlugsForLanguage(language) {
        try {
            // Get all categories with their translations for hierarchy
            const categories = await this.targetDb.query(`
                SELECT
                    c.id,
                    c.parent_id,
                    ct.slug
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
                ORDER BY c.id
            `, [language.id]);

            if (categories.length === 0) return;

            // Build category map and calculate parent slugs
            const categoryMap = new Map();
            categories.forEach(cat => categoryMap.set(cat.id, cat));

            // Calculate parent slugs (similar to old version but simplified)
            const parentSlugsCache = new Map();

            // Sort categories by hierarchy depth
            const sortedCategories = categories.sort((a, b) => {
                let aDepth = 0, current = a;
                while (current.parent_id) {
                    aDepth++;
                    current = categoryMap.get(current.parent_id);
                    if (!current) break;
                }

                let bDepth = 0;
                current = b;
                while (current.parent_id) {
                    bDepth++;
                    current = categoryMap.get(current.parent_id);
                    if (!current) break;
                }

                return aDepth - bDepth;
            });

            // Calculate parent slugs bottom-up
            for (const category of sortedCategories) {
                const slugs = [];
                let currentId = category.parent_id;

                while (currentId) {
                    const parent = categoryMap.get(currentId);
                    if (!parent || !parent.slug) break;
                    slugs.unshift(parent.slug);
                    currentId = parent.parent_id;
                }

                const parentSlugs = slugs.length > 0 ? (category.slug ? slugs.join('/') + '/' + category.slug : slugs.join('/')) : null;
                parentSlugsCache.set(category.id, parentSlugs);
            }

            // Update parent_slugs if NULL
            let updatedCount = 0;
            for (const category of categories) {
                const parentSlugs = parentSlugsCache.get(category.id);

                const currentTranslation = await this.targetDb.query(
                    'SELECT parent_slugs FROM category_translations WHERE category_id = $1 AND language_id = $2',
                    [category.id, language.id]
                );

                if (currentTranslation.length > 0 && currentTranslation[0].parent_slugs === null) {
                    await this.targetDb.query(
                        'UPDATE category_translations SET parent_slugs = $1, updated_at = NOW() WHERE category_id = $2 AND language_id = $3',
                        [parentSlugs, category.id, language.id]
                    );
                    updatedCount++;
                }
            }

            logger.debug(`Updated parent slugs for ${updatedCount} categories in ${language.code}`);
        } catch (error) {
            logger.error(`Failed to calculate parent slugs for ${language.code}`, { error: error.message });
        }
    }
}

module.exports = SimpleCategoryMergerV3;

// CLI runner
if (require.main === module) {
    const targetUrl = process.env.TARGET_DB_URL || 'postgresql://postgres:postgres@localhost:5432/drakesterling_new?schema=public';
    const targetType = process.env.TARGET_DB_TYPE || 'postgresql';

    const { DbClient } = require('../../db');
    const targetDb = new DbClient(targetUrl, targetType);

    const merger = new SimpleCategoryMergerV3(targetDb);
    merger.run().catch(error => {
        console.error('Simple category merger V3 failed:', error);
        process.exit(1);
    });
}
