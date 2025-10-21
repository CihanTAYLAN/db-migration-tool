/*
# Coins for Sale vs Sold Archive Category Merger - V3 (CLEAN VERSION)

Bu script, migration tamamlandıktan sonra çalıştırılır ve Magento'daki
"Coins for Sale" ve "Sold Archive" tree'lerinin alt kategorilerini birleştirir.

V3 Business Logic:
- Source'da paralel tree'ler var: Coins for Sale (1/2/3) + Sold Archive (1/2/5)
- Alt kategoriler aynı isimlerde olabilir (örn: Sovereigns altında George III)
- Bu kategori çiflerini merge ederek tek tree'e düşürmek gerekiyor

## New Clean Merge Logic (Step-by-Step):
1. Collect categories with migration codes from target DB
2. Analyze source parent entity ID mapping (active vs archive trees)
3. Create merge groups for categories with same slug prefix
4. Execute category merges with proper product relationship transfer
5. Clean up and update parent slugs

## Kullanım
node src/migrationsv3/steps/merge-subcategories.js
*/

const { DbClient } = require('../../db');
const logger = require('../../logger');
const { v4: uuidv4 } = require('uuid');

class CleanSubcategoryMergerV3 {
    constructor(targetDb) {
        this.targetDb = targetDb;
        this.sourceParentMapping = {
            3: 5,    // ANACATEGORY: Coins for Sale Ana → Sold Archive Ana
            5: 3,    // Inverse: Sold Archive Ana → Coins for Sale Ana
            9: 20,   // Rarities <-> Rarities (Archive)
            10: 21,  // Sovereigns <-> Sovereigns (Archive)
            11: 22,  // Half Sovereigns <-> Half Sovereigns (Archive)
            12: 23,  // Gold £5 and £2 <-> Gold £5 and £2 (Archive)
            13: 24,  // World Coins <-> World Coins (Archive)
            14: 25,  // Gold Guineas <-> Gold Guineas (Archive)
            15: 26,  // Commonwealth Coins <-> Commonwealth Coins (Archive)
            16: 27,  // Pre-decimal Proofs <-> Pre-decimal Proofs (Archive)
            18: 29,  // Decimal Coins <-> Decimal Coins (Archive)
            19: 30,  // Banknotes <-> Banknotes (Archive)
            20: 9,   // Inverse mappings
            21: 10,
            22: 11,
            23: 12,
            24: 13,
            25: 14,
            26: 15,
            27: 16,
            28: 28,  // Colonial Coins (Archive only, no active counterpart)
            29: 18,
            30: 19
        };
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

            logger.info('🧹 Starting clean Coins for Sale vs Sold Archive merge process...');

            // Step 1: Collect all categories that need merging
            const categoriesToMerge = await this.collectCategoriesToMerge();
            if (categoriesToMerge.length === 0) {
                logger.info('No categories found to merge');
                return { success: true, message: 'No categories to merge' };
            }

            // Step 2: Analyze source parent mapping and create merge groups
            const mergeGroups = await this.createMergeGroups(categoriesToMerge);
            if (mergeGroups.length === 0) {
                logger.info('No mergeable category groups found');
                return { success: true, message: 'No mergeable groups found' };
            }

            // Step 3: Execute merges
            const mergeResults = await this.executeCategoryMerges(mergeGroups);

            // Step 4: Update parent slugs
            await this.updateParentSlugs();

            logger.success('✅ Clean subcategory merger completed successfully');

            return {
                success: true,
                message: 'Subcategory merger completed successfully',
                stats: mergeResults
            };

        } catch (error) {
            logger.error('❌ Clean subcategory merger failed', { error: error.message, stack: error.stack });
            return {
                success: false,
                message: error.message
            };
        } finally {
            await this.disconnectDatabase();
        }
    }

    // Step 1: Collect all categories with migration codes
    async collectCategoriesToMerge() {
        logger.info('📊 Step 1: Collecting categories with migration codes...');

        const query = `
            SELECT
                c.id as category_id,
                c.code,
                ct.slug,
                ct.title,
                c.parent_id
            FROM categories c
            LEFT JOIN category_translations ct ON c.id = ct.category_id
            WHERE c.code LIKE '%_%'
            ORDER BY c.code
        `;

        const categories = await this.targetDb.query(query);
        logger.info(`Found ${categories.length} categories with migration codes`);

        return categories;
    }

    // Step 2: Create merge groups based on parallel category analysis
    async createMergeGroups(categories) {
        logger.info('🔍 Step 2: Analyzing parallel categories and creating merge groups...');

        const mergeGroups = [];

        // Group categories by parent entity ID and slug prefix
        const entitySlugMap = new Map(); // entityId_slugPrefix → categoryList

        for (const category of categories) {
            const parts = category.code.split('_');
            if (parts.length !== 3) continue;

            const parentEntityId = parseInt(parts[1]);
            const slugPrefix = parts[0];

            const key = `${parentEntityId}_${slugPrefix}`;

            if (!entitySlugMap.has(key)) {
                entitySlugMap.set(key, []);
            }
            entitySlugMap.get(key).push({
                ...category,
                parentEntityId,
                slugPrefix,
                originalEntityId: parseInt(parts[2])
            });
        }

        // For each category, check if it has a parallel counterpart
        for (const [key, categoryList] of entitySlugMap) {
            const [entityId, slugPrefix] = key.split('_');
            const correspondingEntityId = this.sourceParentMapping[entityId];

            if (!correspondingEntityId) continue;

            const counterpartKey = `${correspondingEntityId}_${slugPrefix}`;
            const counterpartList = entitySlugMap.get(counterpartKey);

            if (!counterpartList || counterpartList.length === 0) continue;

            // Combine both groups for merging
            const allCategories = [...categoryList, ...counterpartList];
            mergeGroups.push({
                mergeKey: `${slugPrefix}_${Math.min(entityId, correspondingEntityId)}_${Math.max(entityId, correspondingEntityId)}`,
                categories: allCategories,
                categoryCount: allCategories.length
            });
        }

        logger.info(`Created ${mergeGroups.length} merge groups from ${categories.length} total categories`);

        mergeGroups.forEach(group => {
            logger.debug(`Merge group "${group.mergeKey}": ${group.categoryCount} categories`);
        });

        return mergeGroups;
    }

    // Step 3: Execute category merges
    async executeCategoryMerges(mergeGroups) {
        logger.info('🔄 Step 3: Executing category merges...');

        const stats = {
            totalGroups: mergeGroups.length,
            processedGroups: 0,
            mergedCategories: 0,
            movedProducts: 0,
            deletedCategories: 0
        };

        for (const group of mergeGroups) {
            try {
                logger.info(`Processing merge group "${group.mergeKey}" with ${group.categories.length} categories`);

                if (group.categories.length < 2) {
                    logger.debug(`Skipping merge group "${group.mergeKey}" - only ${group.categories.length} category`);
                    continue;
                }

                // Separate main categories vs subcategories
                const mainCategories = group.categories.filter(cat => cat.parent_id === null);
                const subCategories = group.categories.filter(cat => cat.parent_id !== null);

                if (mainCategories.length > 0) {
                    const result = await this.mergeCategoriesInGroup(mainCategories, 'main');
                    stats.mergedCategories += result.mergedCategories;
                    stats.movedProducts += result.movedProducts;
                    stats.deletedCategories += result.deletedCategories;
                }

                if (subCategories.length > 1) {
                    const result = await this.mergeCategoriesInGroup(subCategories, 'sub');
                    stats.mergedCategories += result.mergedCategories;
                    stats.movedProducts += result.movedProducts;
                    stats.deletedCategories += result.deletedCategories;
                }

                stats.processedGroups++;

            } catch (error) {
                logger.error(`Failed to process merge group "${group.mergeKey}"`, { error: error.message });
            }
        }

        logger.success(`✅ Merge execution completed: ${stats.processedGroups}/${stats.totalGroups} groups processed`);
        logger.success(`📊 Stats: ${stats.mergedCategories} merged, ${stats.movedProducts} products moved, ${stats.deletedCategories} categories deleted`);

        return stats;
    }

    async mergeCategoriesInGroup(categories, categoryType = 'sub') {
        // Sort to prioritize active categories (lower entity IDs for active)
        const sortedCategories = categories.sort((a, b) => {
            // Active categories (10-19) come first
            const aIsActive = a.parentEntityId < 20;
            const bIsActive = b.parentEntityId < 20;

            if (aIsActive === bIsActive) {
                return a.originalEntityId - b.originalEntityId; // Smaller entity ID first
            }
            return bIsActive ? 1 : -1; // Active categories first
        });

        const mainCategory = sortedCategories[0];
        const categoriesToMerge = sortedCategories.slice(1);

        logger.info(`Keeping ${categoryType} category: ${mainCategory.title} (${mainCategory.code})`);

        let movedProducts = 0;
        let deletedCategories = 0;

        // Move products from duplicate categories to main category
        for (const categoryToMerge of categoriesToMerge) {
            const moveResult = await this.transferProductsToMainCategory(categoryToMerge.category_id, mainCategory.category_id);
            movedProducts += moveResult.movedCount;
        }

        // Delete duplicate categories
        for (const categoryToMerge of categoriesToMerge) {
            await this.deleteCategorySafely(categoryToMerge.category_id);
            deletedCategories++;
            logger.debug(`Deleted ${categoryType} category: ${categoryToMerge.title} (${categoryToMerge.code})`);
        }

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

module.exports = CleanSubcategoryMergerV3;

// CLI runner (unchanged)
if (require.main === module) {
    const targetUrl = process.env.TARGET_DB_URL || 'postgresql://postgres:postgres@localhost:5432/drakesterling_new?schema=public';
    const targetType = process.env.TARGET_DB_TYPE || 'postgresql';

    const { DbClient } = require('../../db');
    const targetDb = new DbClient(targetUrl, targetType);

    const merger = new CleanSubcategoryMergerV3(targetDb);
    merger.run().catch(error => {
        console.error('Clean subcategory merger V3 failed:', error);
        process.exit(1);
    });
}
