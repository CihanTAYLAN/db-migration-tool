/*
# Alt Kategori Birleştirme Scripti

Bu script, migration tamamlandıktan sonra çalıştırılır ve kategoriler tablosunda
code'ların '_' karakterinden split edildiğindeki ilk parçadan 2 tane kategori var ise,
bu kategoriler teke düşürülüp içlerindeki ürünler birleştirilir.

## Mantık
1. categories tablosundan code'u '_' içeren tüm kategorileri al
2. Her code'u '_' ile split et ve ilk parçayı al (prefix)
3. Aynı prefix'e sahip kategorileri grupla
4. Eğer bir prefix altında 2+ kategori varsa:
   - En küçük entity_id'ye sahip olanı "ana kategori" olarak tut
   - Diğer kategorileri ana kategoriye merge et
   - Ürünleri ana kategoriye taşı
   - Eski kategorileri sil

## Kullanım
node src/migrationsv2/merge-subcategories.js
*/

const { DbClient } = require('../db');
const logger = require('../logger');
const { v4: uuidv4 } = require('uuid');

class SubcategoryMerger {
    constructor(targetUrl, targetType) {
        this.targetUrl = targetUrl;
        this.targetType = targetType;
        this.targetDb = null;
    }

    async connectDatabase() {
        logger.info('Connecting to target database...');
        this.targetDb = new DbClient(this.targetUrl, this.targetType);
        await this.targetDb.connect();
        logger.success('Database connected successfully');
    }

    async disconnectDatabase() {
        logger.info('Disconnecting from database...');
        if (this.targetDb) await this.targetDb.close();
        logger.success('Database disconnected');
    }

    async run() {
        try {
            await this.connectDatabase();
            await this.mergeSubcategories();
        } catch (error) {
            logger.error('Subcategory merger failed', { error: error.message, stack: error.stack });
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

            // Yeni ilişkiler oluştur
            const newRelations = productsToMove.map(p => ({
                id: uuidv4(),
                product_id: p.product_id,
                category_id: toCategoryId,
                created_at: new Date(),
                updated_at: new Date()
            }));

            // Batch insert
            const fieldCount = Object.keys(newRelations[0]).length;
            const placeholders = newRelations.map((_, index) => {
                const start = index * fieldCount + 1;
                const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                return `(${params.join(', ')})`;
            }).join(', ');

            const values = newRelations.flatMap(r => Object.values(r));
            const fields = Object.keys(newRelations[0]).join(', ');

            await this.targetDb.query(`INSERT INTO product_categories (${fields}) VALUES ${placeholders} ON CONFLICT DO NOTHING`, values);

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
}

module.exports = SubcategoryMerger;

// CLI runner
if (require.main === module) {
    const targetUrl = process.env.TARGET_DB_URL || 'postgresql://postgres:postgres@localhost:5432/drakesterling_new?schema=public';
    const targetType = process.env.TARGET_DB_TYPE || 'postgresql';

    const merger = new SubcategoryMerger(targetUrl, targetType);
    merger.run().catch(error => {
        console.error('Subcategory merger failed:', error);
        process.exit(1);
    });
}
