/**
 * Categories Migration Class
 *
 * Bu sınıf Magento'dan PostgreSQL'e kategori verilerini migrate eder.
 * Magento'nun EAV (Entity-Attribute-Value) yapısından düz PostgreSQL tablolarına geçiş yapar.
 *
 * Migrate edilen tablolar:
 * - categories: Ana kategori bilgileri
 * - category_translations: Kategori çevirileri (çok dilli destek)
 */
const { MigrationTemplate } = require('./template');
const logger = require('../logger');
const { v4: uuidv4 } = require('uuid');

class CategoriesMigration extends MigrationTemplate {
    /**
     * Ana migration fonksiyonu
     * Tüm kategori migration sürecini yönetir
     */
    async run() {
        logger.info('Starting categories migration...');

        // Veritabanı bağlantılarını başlat
        await this.connectAll();

        // Bağlantı kontrolü
        if (!this.sourceConnected || !this.targetConnected) {
            logger.error('Database connections failed for categories migration');
            await this.disconnectAll();
            return;
        }

        try {
            /**
             * ADIM 1: Magento EAV Yapısından Attribute ID'lerini Al
             *
             * Magento'nun EAV (Entity-Attribute-Value) yapısında her özellik için benzersiz bir attribute_id vardır.
             * Bu ID'leri kullanarak doğru verileri çekebiliriz.
             *
             * Alınan attribute'lar:
             * - name: Kategori adı
             * - url_key: URL anahtarı (SEO dostu link)
             * - description: Kategori açıklaması
             * - meta_title: SEO başlık
             * - meta_description: SEO açıklaması
             * - meta_keywords: SEO anahtar kelimeler
             * - is_active: Kategori aktif/pasif durumu
             */
            const nameAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "name" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const nameAttrId = nameAttrResult && nameAttrResult.length > 0 ? nameAttrResult[0].attribute_id : null;

            const urlKeyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "url_key" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const urlKeyAttrId = urlKeyAttrResult && urlKeyAttrResult.length > 0 ? urlKeyAttrResult[0].attribute_id : null;

            const descriptionAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "description" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const descriptionAttrId = descriptionAttrResult && descriptionAttrResult.length > 0 ? descriptionAttrResult[0].attribute_id : null;

            const metaTitleAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "meta_title" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const metaTitleAttrId = metaTitleAttrResult && metaTitleAttrResult.length > 0 ? metaTitleAttrResult[0].attribute_id : null;

            const metaDescriptionAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "meta_description" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const metaDescriptionAttrId = metaDescriptionAttrResult && metaDescriptionAttrResult.length > 0 ? metaDescriptionAttrResult[0].attribute_id : null;

            const metaKeywordsAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "meta_keywords" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const metaKeywordsAttrId = metaKeywordsAttrResult && metaKeywordsAttrResult.length > 0 ? metaKeywordsAttrResult[0].attribute_id : null;

            const isActiveAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "is_active" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "catalog_category")');
            const isActiveAttrId = isActiveAttrResult && isActiveAttrResult.length > 0 ? isActiveAttrResult[0].attribute_id : null;

            logger.info(`Attribute IDs - name: ${nameAttrId}, url_key: ${urlKeyAttrId}, description: ${descriptionAttrId}, meta_title: ${metaTitleAttrId}, meta_description: ${metaDescriptionAttrId}, meta_keywords: ${metaKeywordsAttrId}, is_active: ${isActiveAttrId}`);

            // 🔍 DEBUG: Analyze duplicate url_keys in source database
            if (urlKeyAttrId) {
                logger.info('🔍 Analyzing duplicate url_keys in source database...');

                const duplicateUrlKeysQuery = `
                    SELECT
                        ccev.value as url_key,
                        COUNT(*) as count,
                        GROUP_CONCAT(cce.entity_id) as entity_ids,
                        GROUP_CONCAT(cce.parent_id) as parent_ids,
                        GROUP_CONCAT(ccev.store_id) as store_ids
                    FROM catalog_category_entity_varchar ccev
                    JOIN catalog_category_entity cce ON ccev.entity_id = cce.entity_id
                    WHERE ccev.attribute_id = ?
                    AND cce.entity_id > 1
                    GROUP BY ccev.value
                    HAVING COUNT(*) > 1
                    ORDER BY COUNT(*) DESC, ccev.value
                `;

                const duplicateUrlKeys = await this.query('source', duplicateUrlKeysQuery, [urlKeyAttrId]);
                logger.info(`Found ${duplicateUrlKeys.length} duplicate url_key groups in source database`);

                if (duplicateUrlKeys.length > 0) {
                    logger.warn('🚨 DUPLICATE URL KEYS FOUND:');
                    duplicateUrlKeys.slice(0, 10).forEach((dup, index) => {
                        logger.warn(`  ${index + 1}. URL Key: "${dup.url_key}" (${dup.count} times)`);
                        logger.warn(`     Entity IDs: ${dup.entity_ids}`);
                        logger.warn(`     Parent IDs: ${dup.parent_ids}`);
                        logger.warn(`     Store IDs: ${dup.store_ids}`);
                    });

                    if (duplicateUrlKeys.length > 10) {
                        logger.warn(`  ... and ${duplicateUrlKeys.length - 10} more duplicate groups`);
                    }
                } else {
                    logger.info('✅ No duplicate url_keys found in source database');
                }

                // Analyze store-specific url_keys
                const storeSpecificQuery = `
                    SELECT
                        ccev.store_id,
                        COUNT(*) as total_categories,
                        COUNT(DISTINCT ccev.value) as unique_url_keys,
                        (COUNT(*) - COUNT(DISTINCT ccev.value)) as duplicates
                    FROM catalog_category_entity_varchar ccev
                    JOIN catalog_category_entity cce ON ccev.entity_id = cce.entity_id
                    WHERE ccev.attribute_id = ?
                    AND cce.entity_id > 1
                    GROUP BY ccev.store_id
                    ORDER BY ccev.store_id
                `;

                const storeAnalysis = await this.query('source', storeSpecificQuery, [urlKeyAttrId]);
                logger.info('📊 Store-specific URL key analysis:');
                storeAnalysis.forEach(store => {
                    logger.info(`  Store ID ${store.store_id}: ${store.total_categories} categories, ${store.unique_url_keys} unique, ${store.duplicates} duplicates`);
                });
            }

            /**
             * ADIM 2: Ana Kategori Sorgusu - Magento EAV Yapısından Düz Veri Çekme
             *
             * Bu sorgu Magento'nun karmaşık EAV yapısından düz bir veri seti çıkarır.
             * Her kategori için tüm bilgileri tek bir satırda toplar.
             *
             * Kullanılan tablolar:
             * - catalog_category_entity: Ana kategori bilgileri
             * - catalog_category_entity_varchar: Metin alanları (name, url_key, meta_title, meta_description)
             * - catalog_category_entity_text: Uzun metin alanları (description, meta_keywords)
             * - catalog_category_entity_int: Sayısal alanlar (is_active)
             *
             * WHERE koşulu: entity_id > 1 (root category hariç)
             * ORDER BY: level, position, entity_id (hiyerarşik sıralama)
             */
            const categoriesQuery = `
                SELECT
                    cce.entity_id,
                    cce.parent_id,
                    cce.path,
                    cce.position,
                    cce.level,
                    cce.children_count,
                    cce.created_at,
                    cce.updated_at,
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
                WHERE cce.entity_id > 1
                ORDER BY cce.level, cce.position, cce.entity_id
            `;

            const categories = await this.query('source', categoriesQuery, [nameAttrId, urlKeyAttrId, descriptionAttrId, metaTitleAttrId, metaDescriptionAttrId, metaKeywordsAttrId, isActiveAttrId]);
            logger.info(`${categories.length} categories found from Magento EAV structure`);

            if (categories.length === 0) {
                logger.warning('No categories found in source database');
                await this.disconnectAll();
                return;
            }

            /**
             * DEBUG: Kategori verilerini analiz et
             */
            logger.info('🔍 DEBUG: Analyzing category data...');

            const codeMap = new Map();
            const duplicateCodes = [];
            const nullUrlKeys = [];
            const urlKeyMap = new Map();

            for (const category of categories) {
                const code = category.url_key || `category-${category.entity_id}`;

                // Code duplicate kontrolü
                if (codeMap.has(code)) {
                    duplicateCodes.push({
                        code,
                        first_entity_id: codeMap.get(code),
                        second_entity_id: category.entity_id,
                        first_url_key: categories.find(c => c.entity_id === codeMap.get(code))?.url_key,
                        second_url_key: category.url_key
                    });
                } else {
                    codeMap.set(code, category.entity_id);
                }

                // URL key duplicate kontrolü
                if (category.url_key) {
                    if (urlKeyMap.has(category.url_key)) {
                        logger.warn(`⚠️  Duplicate url_key found: ${category.url_key} (entity_ids: ${urlKeyMap.get(category.url_key)}, ${category.entity_id})`);
                    } else {
                        urlKeyMap.set(category.url_key, category.entity_id);
                    }
                } else {
                    nullUrlKeys.push(category.entity_id);
                }

                // Her 50 kategoride bir örnek log
                if (category.entity_id % 50 === 0) {
                    logger.info(`📋 Sample category: entity_id=${category.entity_id}, url_key=${category.url_key}, code=${code}, name=${category.name?.substring(0, 30)}...`);
                }
            }

            logger.info(`📊 DEBUG Summary:
- Total categories: ${categories.length}
- Categories with null url_key: ${nullUrlKeys.length}
- Unique codes generated: ${codeMap.size}
- Duplicate codes found: ${duplicateCodes.length}
- Unique url_keys: ${urlKeyMap.size}`);

            if (duplicateCodes.length > 0) {
                logger.warn('🚨 DUPLICATE CODES FOUND:');
                duplicateCodes.slice(0, 10).forEach((dup, index) => {
                    logger.warn(`  ${index + 1}. Code: ${dup.code}`);
                    logger.warn(`     Entity IDs: ${dup.first_entity_id}, ${dup.second_entity_id}`);
                    logger.warn(`     URL Keys: ${dup.first_url_key}, ${dup.second_url_key}`);
                });
                if (duplicateCodes.length > 10) {
                    logger.warn(`  ... and ${duplicateCodes.length - 10} more duplicates`);
                }
            }

            if (nullUrlKeys.length > 0) {
                logger.info(`ℹ️  Categories with null url_key (first 10): ${nullUrlKeys.slice(0, 10).join(', ')}`);
            }

            /**
             * ADIM 3: Hedef Veritabanından Dil Bilgilerini Al ve Kontrol Et
             *
             * PostgreSQL hedef veritabanında mevcut dilleri kontrol eder.
             * Çok dilli destek için gerekli dil ID'lerini alır.
             * Varsayılan olarak İngilizce (en) kullanılır.
             * Eğer dil mevcut değilse oluşturur.
             */
            let targetLanguages = await this.query('target', 'SELECT id, code FROM languages ORDER BY code');
            logger.info(`Available target languages: ${targetLanguages.map(l => `${l.code} (${l.id})`).join(', ')}`);

            // Eğer hiç dil yoksa varsayılan İngilizce dilini oluştur
            if (!targetLanguages || targetLanguages.length === 0) {
                logger.info('No languages found, creating default English language...');
                await this.query('target', `
                    INSERT INTO languages (id, code, name, created_at, updated_at)
                    VALUES ($1, $2, $3, NOW(), NOW())
                    ON CONFLICT (id) DO NOTHING
                `, ['en', 'en', 'English']);
                targetLanguages = [{ id: 'en', code: 'en' }];
            }

            const defaultLanguage = targetLanguages.find(l => l.code === 'en') || targetLanguages[0];
            const defaultLanguageId = defaultLanguage ? defaultLanguage.id : 'en';
            logger.info(`Using default language: ${defaultLanguage.code} (${defaultLanguageId})`);

            // Dilin gerçekten mevcut olduğundan emin ol
            const languageCheck = await this.query('target', 'SELECT id FROM languages WHERE id = $1', [defaultLanguageId]);
            if (!languageCheck || languageCheck.length === 0) {
                logger.warn(`Default language ${defaultLanguageId} not found, creating it...`);
                await this.query('target', `
                    INSERT INTO languages (id, code, name, created_at, updated_at)
                    VALUES ($1, $2, $3, NOW(), NOW())
                    ON CONFLICT (id) DO NOTHING
                `, [defaultLanguageId, defaultLanguage.code || 'en', 'Default Language']);
            }

            /**
             * ADIM 4: Migration Öncesi Kontrol
             *
             * Hedef veritabanında mevcut kategori sayısını kontrol eder.
             * Bu bilgi migration sonrası karşılaştırma için kullanılır.
             */
            const existingCategoriesBefore = await this.query('target', 'SELECT COUNT(*) as count FROM categories');
            logger.info(`Existing categories before migration: ${existingCategoriesBefore[0].count}`);

            /**
             * ADIM 5: Mapping Hazırlığı
             *
             * Magento'daki entity_id ile PostgreSQL'deki category_id arasındaki eşleşmeyi
             * takip etmek için Map yapısı kullanılır. Bu, parent-child ilişkilerini
             * doğru şekilde kurmak için gereklidir.
             */
            const categoryMapping = new Map();

            /**
             * ADIM 6: Batch Processing - Büyük Veri Setlerini Küçük Gruplara Bölerek İşleme
             *
             * Büyük miktardaki kategori verilerini performans için küçük gruplara böler.
             * Her batch için ayrı transaction işlemleri yapılır.
             *
             * BATCH_SIZE: 500 - Her seferinde 500 kategori işlenir
             * Bu yaklaşım:
             * - Memory kullanımını optimize eder
             * - Transaction'ları kısa tutar
             * - Hata durumunda sadece ilgili batch etkilenir
             */
            const BATCH_SIZE = 500;
            let insertedCount = 0;
            let updatedCount = 0;

            for (let i = 0; i < categories.length; i += BATCH_SIZE) {
                const batch = categories.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                logger.info(`Processing batch ${batchIndex}/${Math.ceil(categories.length / BATCH_SIZE)} (${batch.length} categories)`);

                /**
                 * Batch İçinde Veri Hazırlığı
                 *
                 * Her kategori için PostgreSQL formatına uygun veri yapıları oluşturulur.
                 * İki ana array hazırlanır:
                 * - pgCategories: Ana kategori bilgileri
                 * - pgTranslations: Kategori çevirileri
                 */
                const pgCategories = [];
                const pgTranslations = [];

                for (const category of batch) {
                    const id = uuidv4();
                    // Code'u unique yapmak için entity_id'yi dahil et
                    const code = category.url_key ? `${category.url_key}_${category.entity_id}` : `category-${category.entity_id}`;

                    // Mapping'e kaydet - parent-child ilişkileri için gerekli
                    categoryMapping.set(category.entity_id, { id, code });

                    // Magento'daki is_active değerini PostgreSQL is_hidden'a çevir
                    const isHidden = category.is_active === 0 || category.is_active === '0';

                    // Ana kategori verisi
                    pgCategories.push({
                        id,
                        code,
                        sort: parseInt(category.position) || 0,
                        is_hidden: isHidden,
                        created_at: category.created_at,
                        updated_at: category.updated_at,
                        parent_id: null // Tüm kategoriler eklendikten sonra güncellenecek
                    });

                    // Kategori çevirisi verisi
                    const slug = category.url_key || `category-${category.entity_id}`;
                    pgTranslations.push({
                        id: uuidv4(),
                        title: category.name,
                        description: category.description,
                        meta_title: category.meta_title,
                        meta_description: category.meta_description,
                        meta_keywords: category.meta_keywords,
                        slug,
                        parent_slugs: null, // Parent slug'lar daha sonra hesaplanacak
                        created_at: category.created_at,
                        updated_at: category.updated_at,
                        category_id: id,
                        language_id: defaultLanguageId
                    });
                }

                /**
                 * Ana Kategorileri PostgreSQL'e Ekleme
                 *
                 * Her kategoriyi tek tek işleyerek conflict durumlarını önler.
                 * ON CONFLICT DO UPDATE kullanarak mevcut kayıtları günceller.
                 * Bu yaklaşım duplicate key hatalarını önler.
                 */
                if (pgCategories.length > 0) {
                    let inserted = 0;
                    let updated = 0;

                    for (const category of pgCategories) {
                        try {
                            const categoryColumns = Object.keys(category);
                            const placeholders = categoryColumns.map((_, index) => `$${index + 1}`).join(', ');
                            const values = categoryColumns.map(col => category[col]);

                            const insertQuery = `
                                INSERT INTO categories (${categoryColumns.join(', ')})
                                VALUES (${placeholders})
                                ON CONFLICT (code) DO UPDATE SET
                                    sort = EXCLUDED.sort,
                                    is_hidden = EXCLUDED.is_hidden,
                                    updated_at = EXCLUDED.updated_at
                                RETURNING id
                            `;

                            const result = await this.query('target', insertQuery, values);
                            if (result && result.length > 0) {
                                // Eğer yeni insert yapıldıysa veya güncelleme yapıldıysa, gerçek id'yi al
                                const actualId = result[0].id;
                                // category_id'yi güncelle (eğer değiştiyse)
                                const translationIndex = pgTranslations.findIndex(t => t.category_id === category.id);
                                if (translationIndex !== -1) {
                                    pgTranslations[translationIndex].category_id = actualId;
                                }
                                // Mapping'i güncelle
                                categoryMapping.set(batch[pgCategories.indexOf(category)].entity_id, { id: actualId, code: category.code });
                            }
                            inserted++;
                        } catch (error) {
                            // Bulk insert başarısız olursa tek tek güncelleme dene
                            try {
                                const updateResult = await this.query('target', `
                                    UPDATE categories
                                    SET sort = $1, is_hidden = $2, updated_at = $3
                                    WHERE code = $4
                                    RETURNING id
                                `, [category.sort, category.is_hidden, category.updated_at, category.code]);

                                if (updateResult && updateResult.length > 0) {
                                    const actualId = updateResult[0].id;
                                    // category_id'yi güncelle
                                    const translationIndex = pgTranslations.findIndex(t => t.category_id === category.id);
                                    if (translationIndex !== -1) {
                                        pgTranslations[translationIndex].category_id = actualId;
                                    }
                                    // Mapping'i güncelle
                                    categoryMapping.set(batch[pgCategories.indexOf(category)].entity_id, { id: actualId, code: category.code });
                                }
                                updated++;
                            } catch (updateError) {
                                logger.warn(`Failed to process category ${category.code}: ${updateError.message}`);
                            }
                        }
                    }

                    logger.info(`Batch ${batchIndex}: Inserted ${inserted}, updated ${updated} categories`);
                }

                /**
                 * Kategori Çevirilerini PostgreSQL'e Ekleme
                 *
                 * Kategori çevirilerini tek tek insert ile ekler.
                 * Bu yaklaşım conflict durumlarını önler ve daha güvenilir.
                 * ON CONFLICT kullanarak aynı dil ve slug kombinasyonunda güncelleme yapar.
                 */
                if (pgTranslations.length > 0) {
                    let translationInserted = 0;
                    let translationUpdated = 0;

                    for (const translation of pgTranslations) {
                        try {
                            const translationColumns = Object.keys(translation);
                            const placeholders = translationColumns.map((_, index) => `$${index + 1}`).join(', ');
                            const values = translationColumns.map(col => translation[col]);

                            const translationInsertQuery = `
                                INSERT INTO category_translations (${translationColumns.join(', ')})
                                VALUES (${placeholders})
                                ON CONFLICT DO NOTHING
                            `;

                            const result = await this.query('target', translationInsertQuery, values);
                            if (result && result.rowCount === 0) {
                                // Eğer insert başarısız olduysa (duplicate), update dene
                                const updateQuery = `
                                    UPDATE category_translations
                                    SET title = $1, description = $2, meta_title = $3, meta_description = $4, meta_keywords = $5, updated_at = $6
                                    WHERE category_id = $7 AND language_id = $8
                                `;
                                await this.query('target', updateQuery, [translation.title, translation.description, translation.meta_title, translation.meta_description, translation.meta_keywords, translation.updated_at, translation.category_id, translation.language_id]);
                            }
                            translationInserted++;
                        } catch (error) {
                            logger.warn(`Failed to insert/update category translation for category ${translation.category_id}: ${error.message}`);
                        }
                    }

                    logger.info(`Batch ${batchIndex}: Inserted/updated ${translationInserted} category translations into category_translations table`);
                }

                insertedCount += pgCategories.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(categories.length / BATCH_SIZE)} completed (${insertedCount}/${categories.length} categories)`);
            }

            /**
             * ADIM 7: Parent-Child İlişkilerini Güncelleme ve Hiyerarşik Slug Hesaplama
             *
             * Tüm kategoriler eklendikten sonra parent-child ilişkilerini kurar.
             * Magento'daki hiyerarşik yapıyı PostgreSQL'de yeniden oluşturur.
             *
             * İşlemler:
             * 1. categories tablosunda parent_id alanını güncelle
             * 2. category_translations tablosunda parent_slugs alanını hiyerarşik olarak güncelle
             */
            logger.info('Updating parent relationships and calculating hierarchical parent_slugs...');

            // Önce tüm parent-child ilişkilerini güncelle
            for (const category of categories) {
                if (category.parent_id > 1) { // Root category hariç
                    const currentCategory = categoryMapping.get(category.entity_id);
                    const parentCategory = categoryMapping.get(category.parent_id);

                    if (currentCategory && parentCategory) {
                        // Categories tablosunda parent_id'yi güncelle
                        await this.query('target', `
                            UPDATE categories
                            SET parent_id = $1, updated_at = NOW()
                            WHERE id = $2
                        `, [parentCategory.id, currentCategory.id]);
                    }
                }
            }

            // Helper fonksiyon: Kategorinin hiyerarşik path'ini hesapla
            const getHierarchicalPath = async (categoryId, languageId) => {
                const category = categories.find(c => categoryMapping.get(c.entity_id)?.id === categoryId);
                if (!category) return null;

                if (category.parent_id <= 1) {
                    // Root kategori
                    return null;
                }

                // Parent'ın path'ini al
                const parentMapping = categoryMapping.get(category.parent_id);
                if (!parentMapping) return null;

                const parentPath = await getHierarchicalPath(parentMapping.id, languageId);

                // Parent'ın slug'unu al
                const parentSlugResult = await this.query('target', `
                    SELECT slug FROM category_translations
                    WHERE category_id = $1 AND language_id = $2
                `, [parentMapping.id, languageId]);

                if (parentSlugResult && parentSlugResult.length > 0) {
                    const parentSlug = parentSlugResult[0].slug;
                    return parentPath ? `${parentPath}/${parentSlug}` : parentSlug;
                }

                return null;
            };

            // Şimdi hiyerarşik parent_slugs hesapla
            // Root kategorilerden başlayarak recursive olarak hesapla
            const processedCategories = new Set();

            const calculateParentSlugs = async (categoryId, languageId) => {
                if (processedCategories.has(categoryId)) {
                    return;
                }

                const category = categories.find(c => categoryMapping.get(c.entity_id)?.id === categoryId);
                if (!category) return;

                // Bu kategorinin parent_slugs'unu hesapla (parent'ın hiyerarşik path'i)
                const parentSlugs = await getHierarchicalPath(categoryId, languageId);

                // Bu kategorinin parent_slugs'unu güncelle
                try {
                    // Önce bu parent_slugs'ın zaten kullanılıp kullanılmadığını kontrol et
                    if (parentSlugs) {
                        const existing = await this.query('target', `
                            SELECT id FROM category_translations
                            WHERE language_id = $1 AND parent_slugs = $2 AND category_id != $3
                        `, [languageId, parentSlugs, categoryId]);

                        if (existing && existing.length > 0) {
                            logger.warn(`Skipping duplicate parent_slugs: ${parentSlugs} for category ${categoryId} (already used by category ${existing[0].id})`);
                            parentSlugs = null; // Duplicate ise null bırak
                        }
                    }

                    await this.query('target', `
                        UPDATE category_translations
                        SET parent_slugs = $1, updated_at = NOW()
                        WHERE category_id = $2 AND language_id = $3
                    `, [parentSlugs, categoryId, languageId]);
                } catch (error) {
                    logger.warn(`Failed to update parent_slugs for category ${categoryId}: ${error.message}`);
                    // Continue with next category
                }

                processedCategories.add(categoryId);

                // Bu kategorinin çocuklarını recursive olarak işle
                const children = categories.filter(c => c.parent_id === category.entity_id);
                for (const child of children) {
                    const childMapping = categoryMapping.get(child.entity_id);
                    if (childMapping) {
                        await calculateParentSlugs(childMapping.id, languageId);
                    }
                }
            };

            // Root kategorilerden başla (parent_id = 1 olanlar)
            const rootCategories = categories.filter(c => c.parent_id === 1);
            for (const rootCategory of rootCategories) {
                const rootMapping = categoryMapping.get(rootCategory.entity_id);
                if (rootMapping) {
                    await calculateParentSlugs(rootMapping.id, defaultLanguageId);
                }
            }

            /**
             * ADIM 8: Final Kontrol ve Raporlama
             *
             * Migration sonrası final sayımları yaparak başarıyı doğrular.
             * İki ana tablo için kayıt sayılarını loglar.
             */
            const existingCategoriesAfter = await this.query('target', 'SELECT COUNT(*) as count FROM categories');
            logger.info(`Categories after migration: ${existingCategoriesAfter[0].count}`);

            const existingCategoryTranslationsAfter = await this.query('target', 'SELECT COUNT(*) as count FROM category_translations');
            logger.info(`Category translations after migration: ${existingCategoryTranslationsAfter[0].count}`);

            logger.success(`Categories migration completed: ${insertedCount} categories processed, ${existingCategoryTranslationsAfter[0].count} category translations created`);
        } catch (error) {
            logger.error('Categories migration failed', { error: error.message, stack: error.stack });
        } finally {
            await this.disconnectAll();
        }
    }
}

module.exports = { default: CategoriesMigration };
