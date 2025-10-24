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

class CategoryMergerTemplate {
    constructor(targetDb, defaultLanguageId) {
        this.targetDb = targetDb;
        this.defaultLanguageId = defaultLanguageId;
    }

    async run() {
        try {
            logger.info('Starting merge process...');

            // target veritabanına sql sorgusu gönder. kategori merge gruplarını belirlemek için.
            const sql = `
SELECT ct.slug as category_slug, COALESCE(parent_ct.slug, '') as parent_slug, ARRAY_AGG(c.id) as category_ids
FROM categories c
JOIN category_translations ct ON c.id = ct.category_id AND ct.language_id = $1
LEFT JOIN categories parent_c ON c.parent_id = parent_c.id
LEFT JOIN category_translations parent_ct ON parent_c.id = parent_ct.category_id AND parent_ct.language_id = $2
GROUP BY ct.slug, COALESCE(parent_ct.slug, '')
HAVING COUNT(*) > 1
ORDER BY ct.slug
`;

            const result = await this.targetDb.query(sql, [this.defaultLanguageId, this.defaultLanguageId]);
            logger.info(`Found ${result.length} merge groups`);

            result.forEach(group => {
                logger.info(`Merge Group: "${group.category_slug}" (parent: "${group.parent_slug}") - ${group.category_ids.length} categories: ${group.category_ids.join(', ')}`);
            });

            return { success: true, message: `Found ${result.length} categories groups to merge` };
        } catch (error) {
            logger.error('Merge failed', { error: error.message });
            return { success: false, message: error.message };
        }
    }
}

module.exports = CategoryMergerTemplate;
