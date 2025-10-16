/*
# Coins for Sale vs Sold Archive Category Merger - V3

Bu script, migration tamamlandıktan sonra çalıştırılır ve Magento'daki
"Coins for Sale" ve "Sold Archive" tree'lerinin alt kategorilerini birleştirir.

V3 Business Logic:
- Source'da paralel tree'ler var: Coins for Sale (1/2/3) + Sold Archive (1/2/5)
- Alt kategoriler aynı isimlerde olabilir (örn: Sovereigns altında George III)
- Bu kategori çifilerini merge ederek tek tree'e düşürmek gerekiyor

## New Merge Logic (Path-based instead of Prefix-based)
1. Categories tablosunda migration'dan kalan code'ları al
2. Code'dan parent entity_id'yi çıkar: "george-iii_10_31" → parent: 10
3. Source path'e göre hangi sale type'a aitse belirle:
   - Entity 10-19 arası: Coins for Sale tree (aktif ürünler)
   - Entity 20+ arası: Sold Archive tree (sold/archived ürünler)
4. Aynı parent altında aynı isimli kategorileri merge et
5. Ana kategori: Coins for Sale'dan gelen (aktif ürünleri temsil eden)

## Kullanım
node src/migrationsv3/merge-subcategories.js
*/

const { DbClient } = require('../../db');
const logger = require('../../logger');
const { v4: uuidv4 } = require('uuid');

class SubcategoryMergerV3 {
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
            await this.mergeSubcategories();
            await this.calculateParentSlugs();

            return {
                success: true,
                message: 'Subcategory merger completed successfully'
            };
        } catch (error) {
            logger.error('Subcategory merger V3 failed', { error: error.message, stack: error.stack });
            return {
                success: false,
                message: error.message
            };
        } finally {
            await this.disconnectDatabase();
        }
    }

    async mergeSubcategories() {
        logger.info('Starting Coins for Sale vs Sold Archive merge process...');

        // Target DB'den tüm migration code'larını al (ana kategoriler + alt kategoriler)
        const categoriesQuery = `
            SELECT
                c.id as category_id,
                c.code,
                ct.slug,
                ct.title
            FROM categories c
            LEFT JOIN category_translations ct ON c.id = ct.category_id
            WHERE c.code LIKE '%_%'  -- Tüm '_' içeren code'ları işle
            ORDER BY c.code
        `;

        const categories = await this.targetDb.query(categoriesQuery);
        logger.info(`Found ${categories.length} categories with parent_id in code`);

        if (categories.length === 0) {
            logger.warning('No categories found with parent_id in code format');
            return;
        }

        // Parent entity_id'ye göre groupla: Coins for Sale (10-19) vs Sold Archive (20+)
        const parentGroups = new Map(); // parentEntityId -> categoryList

        for (const category of categories) {
            // Code format: "george-iii_10_31" → parts: ["george-iii", "10", "31"]
            const parts = category.code.split('_');
            if (parts.length !== 3) continue; // Skip invalid format

            const parentEntityId = parseInt(parts[1]); // Parent ID (10 = Sovereigns, 21 = Archive Sovereigns)

            if (!parentGroups.has(parentEntityId)) {
                parentGroups.set(parentEntityId, []);
            }

            parentGroups.get(parentEntityId).push({
                ...category,
                parentEntityId,
                slugPrefix: parts[0], // "george-iii"
                originalEntityId: parseInt(parts[2]) // 31
            });

            logger.debug(`Added category ${category.title} (${category.code}) to parent group ${parentEntityId}`);
        }

        logger.info(`Found ${parentGroups.size} source parent categories`);
        logger.debug(`Parent group keys: ${Array.from(parentGroups.keys()).join(', ')}`);
        for (const [key, group] of parentGroups) {
            logger.debug(`Group ${key}: ${group.map(c => c.code).join(', ')}`);
        }

        // Coins for Sale ve Sold Archive paralel tree'lerini birleştir
        await this.mergeParallelTrees(parentGroups);

        logger.success(`Parallel tree merge completed successfully`);
    }

    async mergeParallelTrees(parentGroups) {
        // Her source parent category altında aynı isimli kategorileri karşılaştır
        // Sovereigns (10) altında George III + Sovereigns (21) altında George III = birleştir

        // Tüm paralel kategori çiftlerini map et: Coins for Sale (1/2/3) vs Sold Archive (1/2/5)
        // Source'da level 3 kategori eşleşmeleri (KEY): Active(Satılık) ↔ Archive(Satılmış)
        const sourceParentMapping = {
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

        const mergeGroups = new Map(); // coinsForSaleCategoryId_soldArchiveCategoryId -> categoryList

        for (const [parentEntityId, categories] of parentGroups) {
            const correspondingParentId = sourceParentMapping[parentEntityId];

            if (!correspondingParentId) continue;

            for (const category of categories) {
                const mergeKey = `${Math.min(parentEntityId, correspondingParentId)}_${Math.max(parentEntityId, correspondingParentId)}_${category.slugPrefix}`;

                if (!mergeGroups.has(mergeKey)) {
                    mergeGroups.set(mergeKey, []);
                }

                mergeGroups.get(mergeKey).push(category);
            }
        }

        logger.info(`Created ${mergeGroups.size} merge groups`);
        logger.debug(`Merge groups keys: ${Array.from(mergeGroups.keys()).join(', ')}`);

        // Her merge grubu içinde 2+ kategori varsa (Coins for Sale + Sold Archive aynı isim) merge et
        let totalMerged = 0;
        for (const [mergeKey, categories] of mergeGroups) {
            if (categories.length >= 2) {
                logger.info(`Merging ${categories.length} parallel categories for "${mergeKey}"`);
                const mergedCount = await this.mergeParallelCategories(categories);
                totalMerged += mergedCount;
            } else {
                logger.debug(`Skipping merge group "${mergeKey}" - only ${categories.length} categories`);
            }
        }

        logger.success(`Merged ${totalMerged} parallel categories`);
        logger.info(`Remaining merge groups: ${mergeGroups.size - totalMerged} did not have duplicates to merge`);
    }

    async mergeParallelCategories(categories) {
        // Ana kategorileri (parent_id null olan) için product count kontrolü
        // Alt kategoriler için mevcut logic devam eder
        const isMainCategories = categories.every(cat => !cat.parent_id);

        if (isMainCategories) {
            return await this.mergeMainCategories(categories);
        } else {
            return await this.mergeSubCategories(categories);
        }
    }

    async mergeMainCategories(categories) {
        logger.info(`Processing ${categories.length} main categories`);

        // Coins for Sale versiyonunu tut, Sold Archive versiyonlarını sil
        // Ürün count kontrolü yapmadan direkt merge et
        const sortedCategories = categories.sort((a, b) => {
            const aIsActive = a.parentEntityId < 20; // Coins for Sale
            const bIsActive = b.parentEntityId < 20;

            if (aIsActive === bIsActive) {
                // Aynı type içindeyse entity_id'ye göre sırala
                return a.originalEntityId - b.originalEntityId;
            }

            return bIsActive ? 1 : -1; // Active öğren önce
        });

        const mainCategory = sortedCategories[0]; // Ana kategori (Coins for Sale'dan olan)
        const categoriesToMerge = sortedCategories.slice(1);

        logger.info(`Main category: ${mainCategory.title} (${mainCategory.code}) - keeping as active`);

        // Diğer versiyonları sil
        for (const categoryToMerge of categoriesToMerge) {
            await this.deleteMainCategory(categoryToMerge.category_id, categoryToMerge.title, categoryToMerge.code);
            logger.info(`Deleted duplicate main category: ${categoryToMerge.title} (${categoryToMerge.code})`);
        }

        return categoriesToMerge.length;
    }

    async mergeMainCategoriesWithProducts(categories) {
        // Priority: Coins for Sale (aktif ürünler) önceki sırada
        const sortedCategories = categories.sort((a, b) => {
            const aIsActive = a.parentEntityId < 20; // Coins for Sale
            const bIsActive = b.parentEntityId < 20;

            if (aIsActive === bIsActive) {
                // Aynı type içindeyse entity_id'ye göre sırala
                return a.originalEntityId - b.originalEntityId;
            }

            return bIsActive ? 1 : -1; // Active öğren önce
        });

        const mainCategory = sortedCategories[0]; // Ana kategori (Coins for Sale'dan olan)
        const categoriesToMerge = sortedCategories.slice(1);

        logger.info(`Main category (with products): ${mainCategory.title} (${mainCategory.code}) - ${mainCategory.productCount} products`);

        // Ürünleri ana kategoriye taşı
        for (const categoryToMerge of categoriesToMerge) {
            await this.moveProductsToMainCategory(categoryToMerge.category_id, mainCategory.category_id);
        }

        // Eski kategorileri sil
        for (const categoryToMerge of categoriesToMerge) {
            await this.deleteMainCategory(categoryToMerge.category_id, categoryToMerge.title, categoryToMerge.code);
        }

        return categoriesToMerge.length;
    }

    async mergeSubCategories(categories) {
        // Mevcut alt kategori merge logic (değişiklik yok)
        const sortedCategories = categories.sort((a, b) => {
            const aIsActive = a.parentEntityId < 20; // Coins for Sale
            const bIsActive = b.parentEntityId < 20;

            if (aIsActive === bIsActive) {
                // Aynı type içindeyse entity_id'ye göre sırala
                return a.originalEntityId - b.originalEntityId;
            }

            return bIsActive ? 1 : -1; // Active öğren önce
        });

        const mainCategory = sortedCategories[0]; // Ana kategori (Coins for Sale'dan olan)
        const categoriesToMerge = sortedCategories.slice(1);

        logger.info(`Main subcategory: ${mainCategory.title} (${mainCategory.code})`);

        // Ürünleri ana kategoriye taşı
        for (const categoryToMerge of categoriesToMerge) {
            await this.moveProductsToMainCategory(categoryToMerge.category_id, mainCategory.category_id);
        }

        // Eski kategorileri sil
        for (const categoryToMerge of categoriesToMerge) {
            await this.deleteCategory(categoryToMerge.category_id);
            logger.info(`Deleted subcategory: ${categoryToMerge.title} (${categoryToMerge.code})`);
        }

        return categoriesToMerge.length;
    }

    async getCategoryProductCount(categoryId) {
        const result = await this.targetDb.query(`
            SELECT COUNT(*) as count FROM product_categories
            WHERE category_id = $1
        `, [categoryId]);

        return parseInt(result[0].count) || 0;
    }

    async deleteMainCategory(categoryId, title, code) {
        logger.info(`Deleting main category: ${title} (${code})`);
        await this.deleteCategory(categoryId);
    }

    async mergeCategoriesForPrefix(prefix, categories) {
        try {
            // Ana kategoriyi seç: En küçük entity_id'ye sahip olan (source'daki orijinal sıralama)
            // Code format: "prefix_entityId" (örn: "george-iii_31")
            const sortedCategories = categories.sort((a, b) => {
                const aEntityId = parseInt(a.code.split('_')[1]) || 0;
                const bEntityId = parseInt(b.code.split('_')[1]) || 0;
                return aEntityId - bEntityId; // Küçük entity_id önce
            });

            const mainCategory = sortedCategories[0];
            const categoriesToMerge = sortedCategories.slice(1);

            logger.info(`Main category: ${mainCategory.title} (${mainCategory.code}) - Entity ID: ${mainCategory.code.split('_')[1]}`);
            logger.info(`Merging ${categoriesToMerge.length} categories into main category`);

            // Her kategorinin ürünlerini ana kategoriye taşı
            for (const categoryToMerge of categoriesToMerge) {
                await this.moveProductsToMainCategory(categoryToMerge.category_id, mainCategory.category_id);
            }

            // Eski kategorileri sil (translations ve categories)
            for (const categoryToMerge of categoriesToMerge) {
                await this.deleteCategory(categoryToMerge.category_id);
                logger.info(`Deleted category: ${categoryToMerge.title} (${categoryToMerge.code})`);
            }

            logger.info(`Successfully merged ${categoriesToMerge.length} categories under "${prefix}" prefix`);
            return categoriesToMerge.length; // Merged kategori sayısı

        } catch (error) {
            logger.error(`Failed to merge categories for prefix "${prefix}"`, { error: error.message });
            return 0;
        }
    }

    async moveProductsToMainCategory(fromCategoryId, toCategoryId) {
        try {
            // Önce mevcut ilişkileri kontrol et (duplicate prevention)
            const existingRelations = await this.targetDb.query(`
                SELECT product_id FROM product_categories
                WHERE category_id = $1
            `, [toCategoryId]);

            const existingProductIds = new Set(existingRelations.map(r => r.product_id));

            // Kaynak kategorideki ürünleri al
            const sourceProducts = await this.targetDb.query(`
                SELECT product_id FROM product_categories
                WHERE category_id = $1
            `, [fromCategoryId]);

            // Henüz ana kategoride olmayan ürünleri taşı
            const productsToMove = sourceProducts.filter(p => !existingProductIds.has(p.product_id));

            if (productsToMove.length === 0) {
                logger.info(`No new products to move from category ${fromCategoryId} to ${toCategoryId}`);
                return;
            }

            // Yeni ilişkiler oluştur ve küçük batch'lerde insert et
            const BATCH_SIZE = 10; // Çok küçük batch'ler kullan
            let insertedCount = 0;

            for (let i = 0; i < productsToMove.length; i += BATCH_SIZE) {
                const batch = productsToMove.slice(i, i + BATCH_SIZE);
                const batchRelations = batch.map(p => ({
                    id: uuidv4(),
                    product_id: p.product_id,
                    category_id: toCategoryId,
                    created_at: new Date(),
                    updated_at: new Date()
                }));

                // Batch insert
                const fieldCount = Object.keys(batchRelations[0]).length;
                const placeholders = batchRelations.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = batchRelations.flatMap(r => Object.values(r));
                const fields = Object.keys(batchRelations[0]).join(', ');

                await this.targetDb.query(`INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);
                insertedCount += batchRelations.length;
            }

            logger.info(`Moved ${productsToMove.length} products from category ${fromCategoryId} to ${toCategoryId}`);

        } catch (error) {
            logger.error(`Failed to move products from category ${fromCategoryId} to ${toCategoryId}`, { error: error.message });
        }
    }

    async deleteCategory(categoryId) {
        try {
            // Önce product_categories ilişkilerini sil
            await this.targetDb.query('DELETE FROM product_categories WHERE category_id = $1', [categoryId]);

            // category_translations'ı sil
            await this.targetDb.query('DELETE FROM category_translations WHERE category_id = $1', [categoryId]);

            // categories'ı sil
            await this.targetDb.query('DELETE FROM categories WHERE id = $1', [categoryId]);

            logger.info(`Deleted category ${categoryId} and all its relations`);

        } catch (error) {
            logger.error(`Failed to delete category ${categoryId}`, { error: error.message });
        }
    }

    async calculateParentSlugs() {
        logger.info('Calculating parent slugs for all categories in all languages...');

        try {
            // Get all languages
            const languages = await this.targetDb.query('SELECT id, code FROM languages ORDER BY id');
            logger.info(`Will calculate parent slugs for ${languages.length} languages`);

            // For each language, calculate parent slugs separately
            for (const language of languages) {
                logger.info(`Calculating parent slugs for language: ${language.code}`);
                await this.calculateParentSlugsForLanguage(language);
            }

            logger.success(`Completed parent slugs calculation for all ${languages.length} languages`);
        } catch (error) {
            logger.error('Failed to calculate parent slugs for all languages', { error: error.message });
            throw error;
        }
    }

    async calculateParentSlugsForLanguage(language) {
        try {
            // Get all categories with their translations for this language and parent relationships
            const categories = await this.targetDb.query(`
                SELECT
                    c.id,
                    c.parent_id,
                    ct.slug,
                    ct.title
                FROM categories c
                LEFT JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
                ORDER BY c.id
            `, [language.id]);

            if (categories.length === 0) {
                logger.debug(`No categories found for language: ${language.code}`);
                return;
            }

            // Create a map for quick lookup
            const categoryMap = new Map();
            categories.forEach(cat => {
                categoryMap.set(cat.id, cat);
            });

            // Pre-calculate parent slugs for all categories to avoid recursion issues
            const parentSlugsCache = new Map();

            // Sort categories by hierarchy level (parents first)
            const sortedCategories = categories.sort((a, b) => {
                // Count how many parents each has
                let aDepth = 0;
                let currentA = a;
                while (currentA.parent_id) {
                    aDepth++;
                    currentA = categoryMap.get(currentA.parent_id);
                    if (!currentA) break;
                }

                let bDepth = 0;
                let currentB = b;
                while (currentB.parent_id) {
                    bDepth++;
                    currentB = categoryMap.get(currentB.parent_id);
                    if (!currentB) break;
                }

                return aDepth - bDepth;
            });

            // Calculate parent slugs for each category (parents first)
            for (const category of sortedCategories) {
                const slugs = [];
                let currentId = category.parent_id;

                // Walk up the hierarchy to build parent slugs
                while (currentId) {
                    const parent = categoryMap.get(currentId);
                    if (!parent || !parent.slug) break;

                    slugs.unshift(parent.slug);
                    currentId = parent.parent_id;
                }

                // If there are parent slugs, format as "parent-slugs/current-slug"
                let parentSlugs = null;
                if (slugs.length > 0) {
                    if (category.slug) {
                        parentSlugs = slugs.join('/') + '/' + category.slug;
                    } else {
                        parentSlugs = slugs.join('/');
                    }
                }

                parentSlugsCache.set(category.id, parentSlugs);
            }

            // Update database with calculated parent slugs (only if parent_slugs is null)
            let updatedCount = 0;
            for (const category of categories) {
                const parentSlugs = parentSlugsCache.get(category.id);

                // Only update if parent_slugs is currently null
                const currentTranslation = await this.targetDb.query(`
                    SELECT parent_slugs FROM category_translations
                    WHERE category_id = $1 AND language_id = $2
                `, [category.id, language.id]);

                if (currentTranslation.length > 0 && currentTranslation[0].parent_slugs === null) {
                    await this.targetDb.query(`
                        UPDATE category_translations
                        SET parent_slugs = $1, updated_at = NOW()
                        WHERE category_id = $2 AND language_id = $3
                    `, [parentSlugs, category.id, language.id]);
                    updatedCount++;
                }
            }

            logger.success(`Updated parent slugs for ${updatedCount} categories in language: ${language.code}`);
        } catch (error) {
            logger.error(`Failed to calculate parent slugs for language ${language.code}`, { error: error.message });
            throw error;
        }
    }
}

module.exports = SubcategoryMergerV3;

// CLI runner
if (require.main === module) {
    const targetUrl = process.env.TARGET_DB_URL || 'postgresql://postgres:postgres@localhost:5432/drakesterling_new?schema=public';
    const targetType = process.env.TARGET_DB_TYPE || 'postgresql';

    const { DbClient } = require('../../db');
    const targetDb = new DbClient(targetUrl, targetType);

    const merger = new SubcategoryMergerV3(targetDb);
    merger.run().catch(error => {
        console.error('Subcategory merger V3 failed:', error);
        process.exit(1);
    });
}
