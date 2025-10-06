/*
# Alt Kategori Birleştirme Scripti - V3

Bu script, migration tamamlandıktan sonra çalıştırılır ve kategoriler tablosunda
code'ların '_' karakterinden split edildiğindeki ilk parçadan 2 tane kategori var ise,
bu kategoriler teke düşürülüp içlerindeki ürünler birleştirilir.

V3 Özellikleri:
- Parent slugs hesaplaması da dahil edildi
- Batch processing ile performans iyileştirildi
- Error handling geliştirildi

## Mantık
1. categories tablosundan code'u '_' içeren tüm kategorileri al
2. Her code'u '_' ile split et ve ilk parçayı al (prefix)
3. Aynı prefix'e sahip kategorileri grupla
4. Eğer bir prefix altında 2+ kategori varsa:
   - En küçük entity_id'ye sahip olanı "ana kategori" olarak tut
   - Diğer kategorileri ana kategoriye merge et
   - Ürünleri ana kategoriye taşı
   - Eski kategorileri sil
5. Tüm kategoriler için parent slugs hesapla

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
        logger.info('Starting subcategory merge process...');

        // Tüm kategorileri ve code'larını al (entity_id ile sıralı)
        const categoriesQuery = `
            SELECT
                c.id as category_id,
                c.code,
                ct.slug,
                ct.title,
                SPLIT_PART(c.code, '_', 1) as prefix
            FROM categories c
            LEFT JOIN category_translations ct ON c.id = ct.category_id
            WHERE c.code LIKE '%_%'  -- Sadece '_' içeren code'ları işle
            ORDER BY c.code
        `;

        const categories = await this.targetDb.query(categoriesQuery);
        logger.info(`Found ${categories.length} categories with underscore in code`);

        if (categories.length === 0) {
            logger.warning('No categories found with underscore in code');
            return;
        }

        // Code prefix'lerine göre grupla (george-iii_31 -> george-iii)
        const prefixGroups = new Map();

        for (const category of categories) {
            const prefix = category.prefix;

            if (!prefixGroups.has(prefix)) {
                prefixGroups.set(prefix, []);
            }

            prefixGroups.get(prefix).push(category);
        }

        logger.info(`Found ${prefixGroups.size} unique prefixes`);

        // Sadece 2+ kategorisi olan prefix'leri işle
        let totalMerged = 0;

        for (const [prefix, categoryGroup] of prefixGroups) {
            if (categoryGroup.length >= 2) {
                logger.info(`Processing prefix "${prefix}" with ${categoryGroup.length} categories`);
                const mergedCount = await this.mergeCategoriesForPrefix(prefix, categoryGroup);
                totalMerged += mergedCount;
            }
        }

        logger.success(`Subcategory merge completed: ${totalMerged} categories merged`);
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
