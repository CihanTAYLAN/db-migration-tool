/*
# Category Merger Template - Ultra Minimal

Adım adım gereksinim implementasyonu için minimal şablon.

Gereksinimler:
1. Target DB'deki category_translations.slug değerleri aynı olan kategoriler merge edilmeli
2. Aynı slug'a ait farklı parent altında kategoriler merge olmamalı
3. Hem parent slug'ı hem de kendi slug'ı aynı olan kategoriler merge olmalı
4. Parent slug controlü: parent ilişkisindeki category_translations.slug'dan yapılmalı
5. Merge: Grup içindeki kategorilerden biri silinmeli, ürünleri kalan kategoriye taşınmalı
6. Kalan kategoriler için parent slug hesaplaması ve güncellemesi yapılmalı
*/

const logger = require('../../logger');

class MergeStep {
    constructor(targetDb, defaultLanguageId) {
        this.targetDb = targetDb;
        this.defaultLanguageId = defaultLanguageId;
    }

    async run() {
        try {
            logger.info('Starting merge process...');

            // target veritabanına sql sorgusu gönder. kategori merge gruplarını belirlemek için.
            const sql = `
SELECT ct.slug as category_slug, COALESCE(parent_ct.slug, '') as parent_slug, ARRAY_AGG(c.id ORDER BY 
  (SELECT COUNT(*) FROM product_categories pc WHERE pc.category_id = c.id)
) as category_ids
FROM categories c
JOIN category_translations ct ON c.id = ct.category_id AND ct.language_id = $1
LEFT JOIN categories parent_c ON c.parent_id = parent_c.id
LEFT JOIN category_translations parent_ct ON parent_c.id = parent_ct.category_id AND parent_ct.language_id = $2
GROUP BY ct.slug, COALESCE(parent_ct.slug, '')
HAVING COUNT(*) > 1
ORDER BY COALESCE(parent_ct.slug, '') desc, ct.slug
`;

            const result = await this.targetDb.query(sql, [this.defaultLanguageId, this.defaultLanguageId]);
            logger.info(`Found ${result.length} merge groups`);
            const categoriesToDelete = [];
            for (const group of result) {
                // category_ids bölümünden 0'ıncısını silinecek kategori olarak, 1'sini kalacak kategori olarak değişkene ata
                const categoryIdsToMerge = group.category_ids;
                const categoryToDelete = categoryIdsToMerge[0]; // Silinecek kategori (0'ıncı index)
                const categoryToKeep = categoryIdsToMerge[1]; // Kalacak kategori (1'inc index)

                logger.info(`Merge Group: "${group.category_slug}" (parent: "${group.parent_slug}")`);
                logger.info(`  - Kalacak kategori: ${categoryToKeep}`);
                logger.info(`  - Silinecek kategori: ${categoryToDelete}`);
                logger.info(`  - Total categories: ${categoryIdsToMerge.length}`);

                // Ürün transferi işlemini çağır
                const productsTransferred = await this.transferProducts(categoryToDelete, categoryToKeep);

                // Parent ilişkisini transfer et
                const parentsTransferred = await this.transferParentRelation(categoryToDelete, categoryToKeep);

                // Kategori silme işlemini çağır
                categoriesToDelete.push(categoryToDelete);

                logger.info(`✅ Bu grup için merge tamamlandı: ${productsTransferred} ürün taşındı, ${parentsTransferred} parent ilişkisi güncellendi, kategori silindi`);
            }

            // bulk category delete
            const sqlDelete = `DELETE FROM categories WHERE id = ANY($1)`;
            await this.targetDb.query(sqlDelete, [categoriesToDelete]);
            logger.info(`✅ Toplam ${categoriesToDelete.length} kategori silindi`);

            logger.info('Merge process completed successfully.');

            return { success: true, message: `Found ${result.length} categories groups to merge` };
        } catch (error) {
            logger.error('Merge failed', { error: error.message });
            return { success: false, message: error.message };
        }
    }

    // Ürün transferi fonksiyonu - silinecek kategorinin ürünlerini kalacak kategoriye taşır
    async transferProducts(categoryIdFrom, categoryIdTo) {
        try {
            logger.debug(`Ürün transferi başlatılıyor: ${categoryIdFrom} → ${categoryIdTo}`);

            // UPDATE yaklaşımı ile ürünleri transfer et - daha güvenilir ve basit
            const updateResult = await this.targetDb.query(
                'UPDATE product_categories SET category_id = $2 WHERE category_id = $1',
                [categoryIdFrom, categoryIdTo]
            );

            const updatedProductCount = updateResult.rowCount || 0;
            logger.debug(`${updatedProductCount} ürün ${categoryIdFrom}'den ${categoryIdTo}'ye transfer edildi`);
            return updatedProductCount;

        } catch (error) {
            logger.error(`Ürün transferi hatası (${categoryIdFrom} → ${categoryIdTo}):`, { error: error.message });
            throw error;
        }
    }

    // Parent ilişkisini transfer et - silinecek kategoriyi parent olarak gören kategorilerin parent_id'sini güncelle
    async transferParentRelation(categoryIdFrom, categoryIdTo) {
        try {
            logger.debug(`Parent ilişkisi transferi başlatılıyor: ${categoryIdFrom} → ${categoryIdTo}`);

            // Silinecek kategoriyi parent olarak gören kategorilerin parent_id'sini değiştir
            const updateResult = await this.targetDb.query(
                'UPDATE categories SET parent_id = $2 WHERE parent_id = $1',
                [categoryIdFrom, categoryIdTo]
            );

            const updatedParentCount = updateResult.rowCount || 0;
            logger.debug(`${updatedParentCount} parent ilişkisi ${categoryIdFrom}'den ${categoryIdTo}'ye aktarıldı`);
            return updatedParentCount;

        } catch (error) {
            logger.error(`Parent transferi hatası (${categoryIdFrom} → ${categoryIdTo}):`, { error: error.message });
            throw error;
        }
    }
}

module.exports = MergeStep;
