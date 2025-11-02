/*
# Translation Step

Batch translation of all categories and products to all supported languages after migration.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const { TranslateClient, TranslateTextCommand } = require('@aws-sdk/client-translate');

class TranslationStep {
    constructor(targetDb, config, defaultLanguageId) {
        this.targetDb = targetDb;
        this.config = config;
        this.defaultLanguageId = defaultLanguageId;

        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.translation.batchSize || 50,
            parallelLimit: config.steps.translation.parallelLimit || 2,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Translation migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
    }

    async run() {
        logger.info('Starting global translation migration step...');

        try {
            // 1. Get all languages supported by the system
            const languages = await this.getTargetLanguages();

            // 2. Batch translate contents first
            logger.info(`Starting content translation for ${languages.length} languages`);
            const contentResult = await this.translateContents(languages);

            // 3. Batch translate categories
            logger.info(`Starting category translation for ${languages.length} languages`);
            const categoryResult = await this.translateCategories(languages);

            // 4. Calculate parent slugs for all languages (after category translation)
            logger.info('Calculating parent slugs for all translated categories');
            await this.calculateParentSlugs();

            // 5. Batch translate products
            logger.info(`Starting product translation for ${languages.length} languages`);
            const productResult = await this.translateProducts(languages);

            const totalSuccess = (contentResult?.count || 0) + (categoryResult?.count || 0) + (productResult?.count || 0);
            const totalFailed = (contentResult?.failed || 0) + (categoryResult?.failed || 0) + (productResult?.failed || 0);

            logger.success(`Global translation completed: ${totalSuccess} translations created, ${totalFailed} failed`);

            return {
                success: totalFailed === 0,
                count: totalSuccess,
                failed: totalFailed,
                languagesProcessed: languages.length
            };

        } catch (error) {
            logger.error('Global translation migration step failed', { error: error.message });
            throw error;
        }
    }

    async getTargetLanguages() {
        logger.info('Getting target languages...');

        // Get languages from config or from database
        let languages;

        if (this.config.steps.translation.languages && this.config.steps.translation.languages.length > 0) {
            // Use languages from config
            const configuredLanguages = this.config.steps.translation.languages;

            // Get language details from database
            languages = await this.targetDb.query(
                'SELECT id, code, name FROM languages WHERE code = ANY($1)',
                [configuredLanguages]
            );

            // Add English if not already included (default language)
            const englishExists = languages.some(lang => lang.id === this.defaultLanguageId);
            if (!englishExists) {
                const englishLang = await this.targetDb.query(
                    'SELECT id, code, name FROM languages WHERE id = $1',
                    [this.defaultLanguageId]
                );
                if (englishLang.length > 0) {
                    languages.push(englishLang[0]);
                }
            }

            logger.info(`Using configured languages: ${configuredLanguages.join(', ')}`);
        } else {
            // Get all languages from database
            languages = await this.targetDb.query('SELECT id, code, name FROM languages ORDER BY id');
            logger.info(`Using all database languages: ${languages.map(l => l.code).join(', ')}`);
        }

        logger.info(`Found ${languages.length} target languages for translation`);
        languages.forEach(lang => logger.debug(`Language: ${lang.code} (${lang.name}) - ID: ${lang.id}`));

        return languages;
    }

    // Slug generation helper - URL-safe for all languages
    slugify(text) {
        if (!text || text.trim() === '') {
            return '';
        }

        let slug = text
            .toLowerCase()
            .trim()
            // Remove common unsafe characters
            .replace(/[<>\.\"\',\|\?#%+\[\]{}]/g, '')
            // Replace spaces and underscores with dashes
            .replace(/[\s_-]+/g, '-')
            // Remove leading/trailing dashes
            .replace(/^-+|-+$/g, '');

        // If slug became empty (removed all chars) or is just numbers/dashes, create a fallback
        if (!slug || /^[0-9-]+$/.test(slug)) {
            // Use alphanumeric characters from original text, or fallback to 'category'
            const alphaNum = text.replace(/[^A-Za-z0-9]/g, '') || 'category';
            slug = alphaNum.slice(0, 20).toLowerCase() || 'category';
        }

        return slug;
    }

    async translateCategories(languages) {
        logger.info('Fetching categories for translation...');

        // Get all categories with their default language content (from source data)
        // Categories are migrated to category_translations table in default language,
        // so we fetch from there for translation
        const categoriesQuery = `
            SELECT
                ct.category_id,
                c.code,
                ct.title,
                ct.description,
                ct.meta_title,
                ct.meta_description,
                ct.meta_keywords
            FROM categories c
            INNER JOIN category_translations ct ON c.id = ct.category_id AND ct.language_id = $1
            ORDER BY c.id
        `;

        const categories = await this.targetDb.query(categoriesQuery, [this.defaultLanguageId]);
        logger.info(`Found ${categories.length} categories to translate`);

        if (categories.length === 0) {
            logger.info('No categories found for translation');
            return { success: true, count: 0, failed: 0 };
        }

        // Process categories in batches
        const result = await this.batchProcessor.process(categories, async (batch) => {
            return await this.processCategoryBatch(batch, languages);
        });

        logger.info(`Category translation completed: ${result.success} success, ${result.failed} failed`);
        return result;
    }

    async processCategoryBatch(categories, languages) {
        try {
            let successCount = 0;
            let failedCount = 0;

            // Get the default language (English) for translation source
            const defaultLanguage = languages.find(lang => lang.id === this.defaultLanguageId);
            if (!defaultLanguage) {
                logger.error('Default language not found in language list');
                return { success: 0, failed: categories.length };
            }

            // Process each category for each language
            for (const category of categories) {
                // Skip categories without English content
                if (!category.title || category.title.trim() === '') {
                    logger.debug(`Skipping category ${category.category_id} - no English title`);
                    continue;
                }

                // Process translations for each language
                for (const language of languages) {
                    // Skip default language (English) - it's already the source
                    if (language.id === this.defaultLanguageId) {
                        continue;
                    }

                    try {
                        // Check if translation already exists and has meaningful content for ALL fields
                        const existingTranslation = await this.targetDb.query(`
                            SELECT title, description, meta_title, meta_description, meta_keywords
                            FROM category_translations
                            WHERE category_id = $1 AND language_id = $2
                            LIMIT 1
                        `, [category.category_id, language.id]);

                        // Skip if translation exists and has all meaningful content (avoid unnecessary AWS cost)
                        if (existingTranslation.length > 0) {
                            const existing = existingTranslation[0];
                            const hasAllTranslatedContent =
                                existing.title?.trim() &&
                                existing.description?.trim() &&
                                existing.meta_title?.trim() &&
                                existing.meta_description?.trim() &&
                                existing.meta_keywords?.trim() &&
                                // Ensure translations are different from source (not just copied)
                                existing.title.trim() !== category.title?.trim();

                            if (hasAllTranslatedContent) {
                                logger.debug(`Skipping translation for category ${category.category_id} to ${language.code} - all fields already translated`);
                                continue;
                            }
                        }

                        // Prepare content for translation
                        const translationData = {
                            title: category.title || '',
                            description: category.description || '',
                            meta_title: category.meta_title || '',
                            meta_description: category.meta_description || '',
                            meta_keywords: category.meta_keywords || ''
                        };

                        logger.debug(`Translating category ${category.category_id} (${category.title}) from ${defaultLanguage.code} to ${language.code}`);

                        // Call translation API
                        const translatedData = await this.translateContent(translationData, defaultLanguage.code, language.code);

                        if (!translatedData.title || translatedData.title.trim() === '') {
                            logger.warning(`Translation failed for category ${category.category_id} to ${language.code} - empty title result`);
                            failedCount++;
                            continue;
                        }

                        // Insert or update category translation
                        await this.insertCategoryTranslation(category.category_id, language, translatedData);
                        successCount++;

                        logger.debug(`Successfully translated category ${category.category_id} to ${language.code}`);

                    } catch (error) {
                        logger.warning(`Failed to translate category ${category.category_id} to ${language.code}`, {
                            error: error.message,
                            category_id: category.category_id,
                            category_title: category.title,
                            from_lang: defaultLanguage.code,
                            to_lang: language.code
                        });
                        failedCount++;
                    }
                }
            }

            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process category translation batch', {
                error: error.message,
                categoryCount: categories.length,
                languageCount: languages.length
            });
            return { success: 0, failed: categories.length * (languages.length - 1) }; // -1 for default language
        }
    }

    async insertCategoryTranslation(categoryId, language, translationData) {
        const translationRecord = {
            id: require('uuid').v4(),
            title: translationData.title,
            description: translationData.description,
            meta_title: translationData.meta_title,
            meta_description: translationData.meta_description,
            meta_keywords: translationData.meta_keywords,
            slug: this.slugify(translationData.title), // Generate slug from translated title
            parent_slugs: null, // Will be updated after migration
            category_id: categoryId,
            language_id: language.id,
            created_at: new Date(),
            updated_at: new Date()
        };

        // Check if translation already exists
        const existing = await this.targetDb.query(
            'SELECT id FROM category_translations WHERE category_id = $1 AND language_id = $2',
            [categoryId, language.id]
        );

        if (existing.length > 0) {
            // Update existing
            await this.targetDb.query(`
                UPDATE category_translations SET
                    title = $1, description = $2, meta_title = $3, meta_description = $4,
                    meta_keywords = $5, slug = $6, updated_at = NOW()
                WHERE id = $7
            `, [
                translationRecord.title, translationRecord.description,
                translationRecord.meta_title, translationRecord.meta_description,
                translationRecord.meta_keywords, translationRecord.slug, existing[0].id
            ]);
        } else {
            // Insert new
            await this.targetDb.query(`
                INSERT INTO category_translations (
                    id, title, description, meta_title, meta_description, meta_keywords,
                    slug, parent_slugs, category_id, language_id, created_at, updated_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            `, Object.values(translationRecord));
        }
    }

    async translateProducts(languages) {
        logger.info('Fetching products for translation...');

        // Get all products with their default language content (from source data)
        // Products are migrated to product_translations table in default language,
        // so we fetch from there for translation
        const productsQuery = `
            SELECT
                pt.product_id,
                p.product_web_sku,
                pt.title,
                pt.description,
                pt.short_description,
                pt.meta_title,
                pt.meta_description,
                pt.meta_keywords
            FROM products p
            INNER JOIN product_translations pt ON p.id = pt.product_id AND pt.language_id = $1
            ORDER BY p.id
        `;

        const products = await this.targetDb.query(productsQuery, [this.defaultLanguageId]);
        logger.info(`Found ${products.length} products to translate`);

        if (products.length === 0) {
            logger.info('No products found for translation');
            return { success: true, count: 0, failed: 0 };
        }

        // Process products in batches
        const result = await this.batchProcessor.process(products, async (batch) => {
            return await this.processProductBatch(batch, languages);
        });

        logger.info(`Product translation completed: ${result.success} success, ${result.failed} failed`);
        return result;
    }

    async processProductBatch(products, languages) {
        try {
            let successCount = 0;
            let failedCount = 0;

            // Get the default language (English) for translation source
            const defaultLanguage = languages.find(lang => lang.id === this.defaultLanguageId);
            if (!defaultLanguage) {
                logger.error('Default language not found in language list');
                return { success: 0, failed: products.length };
            }

            // Process each product for each language
            for (const product of products) {
                // Skip products without English content
                if (!product.title || product.title.trim() === '') {
                    logger.debug(`Skipping product ${product.product_id} (${product.product_web_sku}) - no English title`);
                    continue;
                }

                // Process translations for each language
                for (const language of languages) {
                    // Skip default language (English) - it's already the source
                    if (language.id === this.defaultLanguageId) {
                        continue;
                    }

                    try {
                        // Check if translation already exists and has meaningful content for ALL fields
                        const existingTranslation = await this.targetDb.query(`
                            SELECT title, description, short_description, meta_title, meta_description, meta_keywords
                            FROM product_translations
                            WHERE product_id = $1 AND language_id = $2
                            LIMIT 1
                        `, [product.product_id, language.id]);

                        // Skip if translation exists and has all meaningful content (avoid unnecessary AWS cost)
                        if (existingTranslation.length > 0) {
                            const existing = existingTranslation[0];
                            const hasAllTranslatedContent =
                                existing.title?.trim() &&
                                existing.description?.trim() &&
                                existing.short_description?.trim() &&
                                existing.meta_title?.trim() &&
                                existing.meta_description?.trim() &&
                                existing.meta_keywords?.trim() &&
                                // Ensure translations are different from source (not just copied)
                                existing.title.trim() !== product.title?.trim();

                            if (hasAllTranslatedContent) {
                                logger.debug(`Skipping translation for product ${product.product_id} to ${language.code} - all fields already translated`);
                                continue;
                            }
                        }

                        // Prepare content for translation
                        const translationData = {
                            title: product.title || '',
                            description: product.description || '',
                            short_description: product.short_description || '',
                            meta_title: product.meta_title || '',
                            meta_description: product.meta_description || '',
                            meta_keywords: product.meta_keywords || ''
                        };

                        logger.debug(`Translating product ${product.product_id} (${product.product_web_sku}) from ${defaultLanguage.code} to ${language.code}`);

                        // Call translation API
                        const translatedData = await this.translateContent(translationData, defaultLanguage.code, language.code);

                        if (!translatedData.title || translatedData.title.trim() === '') {
                            logger.warning(`Translation failed for product ${product.product_id} to ${language.code} - empty title result`);
                            failedCount++;
                            continue;
                        }

                        // Insert or update product translation
                        await this.insertProductTranslation(product.product_id, language, translatedData);
                        successCount++;

                        logger.debug(`Successfully translated product ${product.product_id} to ${language.code}`);

                    } catch (error) {
                        logger.warning(`Failed to translate product ${product.product_id} to ${language.code}`, {
                            error: error.message,
                            product_id: product.product_id,
                            product_web_sku: product.product_web_sku,
                            from_lang: defaultLanguage.code,
                            to_lang: language.code
                        });
                        failedCount++;
                    }
                }
            }

            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process product translation batch', {
                error: error.message,
                productCount: products.length,
                languageCount: languages.length
            });
            return { success: 0, failed: products.length * (languages.length - 1) }; // -1 for default language
        }
    }

    async insertProductTranslation(productId, language, translationData) {
        const translationRecord = {
            id: require('uuid').v4(),
            title: translationData.title,
            description: translationData.description,
            short_description: translationData.short_description,
            slug: this.slugify(translationData.title), // Generate slug from translated title
            meta_title: translationData.meta_title,
            meta_description: translationData.meta_description,
            meta_keywords: translationData.meta_keywords,
            product_id: productId,
            language_id: language.id,
            created_at: new Date(),
            updated_at: new Date()
        };

        // Check if translation already exists
        const existing = await this.targetDb.query(
            'SELECT id FROM product_translations WHERE product_id = $1 AND language_id = $2',
            [productId, language.id]
        );

        if (existing.length > 0) {
            // Update existing
            await this.targetDb.query(`
                UPDATE product_translations SET
                    title = $1, description = $2, short_description = $3,
                    slug = $4, meta_title = $5, meta_description = $6, meta_keywords = $7,
                    updated_at = NOW()
                WHERE id = $8
            `, [
                translationRecord.title, translationRecord.description, translationRecord.short_description,
                translationRecord.slug, translationRecord.meta_title, translationRecord.meta_description,
                translationRecord.meta_keywords, existing[0].id
            ]);
        } else {
            // Insert new
            await this.targetDb.query(`
                INSERT INTO product_translations (
                    id, title, description, short_description, slug,
                    meta_title, meta_description, meta_keywords,
                    product_id, language_id, created_at, updated_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
            `, Object.values(translationRecord));
        }
    }

    async translateContents(languages) {
        logger.info('Fetching contents for translation...');

        // Get all contents with their default language content (from source data)
        // Contents are migrated to content_translations table in default language,
        // so we fetch from there for translation
        const contentsQuery = `
            SELECT
                ct.content_id,
                ct.title,
                ct.description,
                ct.meta_title,
                ct.meta_description,
                ct.meta_keywords
            FROM contents c
            INNER JOIN content_translations ct ON c.id = ct.content_id AND ct.language_id = $1
            WHERE c.published = true AND c.is_allowed = true
            ORDER BY c.id
        `;

        const contents = await this.targetDb.query(contentsQuery, [this.defaultLanguageId]);
        logger.info(`Found ${contents.length} contents to translate`);

        if (contents.length === 0) {
            logger.info('No contents found for translation');
            return { success: true, count: 0, failed: 0 };
        }

        // Process contents in batches
        const result = await this.batchProcessor.process(contents, async (batch) => {
            return await this.processContentBatch(batch, languages);
        });

        logger.info(`Content translation completed: ${result.success} success, ${result.failed} failed`);
        return result;
    }

    async processContentBatch(contents, languages) {
        try {
            let successCount = 0;
            let failedCount = 0;

            // Get the default language (English) for translation source
            const defaultLanguage = languages.find(lang => lang.id === this.defaultLanguageId);
            if (!defaultLanguage) {
                logger.error('Default language not found in language list');
                return { success: 0, failed: contents.length };
            }

            // Process each content for each language
            for (const content of contents) {
                // Skip contents without English content
                if (!content.title || content.title.trim() === '') {
                    logger.debug(`Skipping content ${content.content_id} - no English title`);
                    continue;
                }

                // Process translations for each language
                for (const language of languages) {
                    // Skip default language (English) - it's already the source
                    if (language.id === this.defaultLanguageId) {
                        continue;
                    }

                    try {
                        // Check if translation already exists and has meaningful content for ALL fields
                        const existingTranslation = await this.targetDb.query(`
                            SELECT title, description, meta_title, meta_description, meta_keywords
                            FROM content_translations
                            WHERE content_id = $1 AND language_id = $2
                            LIMIT 1
                        `, [content.content_id, language.id]);

                        // Skip if translation exists and has all meaningful content (avoid unnecessary AWS cost)
                        if (existingTranslation.length > 0) {
                            const existing = existingTranslation[0];
                            const hasAllTranslatedContent =
                                existing.title?.trim() &&
                                existing.description?.trim() &&
                                existing.meta_title?.trim() &&
                                existing.meta_description?.trim() &&
                                existing.meta_keywords?.trim() &&
                                // Ensure translations are different from source (not just copied)
                                existing.title.trim() !== content.title?.trim();

                            if (hasAllTranslatedContent) {
                                logger.debug(`Skipping translation for content ${content.content_id} to ${language.code} - all fields already translated`);
                                continue;
                            }
                        }

                        // Prepare content for translation
                        const translationData = {
                            title: content.title || '',
                            description: content.description || '',
                            meta_title: content.meta_title || '',
                            meta_description: content.meta_description || '',
                            meta_keywords: content.meta_keywords || ''
                        };

                        logger.debug(`Translating content ${content.content_id} (${content.title}) from ${defaultLanguage.code} to ${language.code}`);

                        // Call translation API
                        const translatedData = await this.translateContent(translationData, defaultLanguage.code, language.code);

                        if (!translatedData.title || translatedData.title.trim() === '') {
                            logger.warning(`Translation failed for content ${content.content_id} to ${language.code} - empty title result`);
                            failedCount++;
                            continue;
                        }

                        // Insert or update content translation
                        await this.insertContentTranslation(content.content_id, language, translatedData);
                        successCount++;

                        logger.debug(`Successfully translated content ${content.content_id} to ${language.code}`);

                    } catch (error) {
                        logger.warning(`Failed to translate content ${content.content_id} to ${language.code}`, {
                            error: error.message,
                            content_id: content.content_id,
                            content_title: content.title,
                            from_lang: defaultLanguage.code,
                            to_lang: language.code
                        });
                        failedCount++;
                    }
                }
            }

            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process content translation batch', {
                error: error.message,
                contentCount: contents.length,
                languageCount: languages.length
            });
            return { success: 0, failed: contents.length * (languages.length - 1) }; // -1 for default language
        }
    }

    async insertContentTranslation(contentId, language, translationData) {
        const translationRecord = {
            id: require('uuid').v4(),
            title: translationData.title,
            description: translationData.description,
            slug: this.slugify(translationData.title), // Generate slug from translated title
            meta_title: translationData.meta_title,
            meta_description: translationData.meta_description,
            meta_keywords: translationData.meta_keywords,
            content_id: contentId,
            language_id: language.id,
            created_at: new Date(),
            updated_at: new Date()
        };

        // Check if translation already exists
        const existing = await this.targetDb.query(
            'SELECT id FROM content_translations WHERE content_id = $1 AND language_id = $2',
            [contentId, language.id]
        );

        if (existing.length > 0) {
            // Update existing
            await this.targetDb.query(`
                UPDATE content_translations SET
                    title = $1, description = $2, slug = $3, meta_title = $4,
                    meta_description = $5, meta_keywords = $6, updated_at = NOW()
                WHERE id = $7
            `, [
                translationRecord.title, translationRecord.description, translationRecord.slug,
                translationRecord.meta_title, translationRecord.meta_description,
                translationRecord.meta_keywords, existing[0].id
            ]);
        } else {
            // Insert new
            await this.targetDb.query(`
                INSERT INTO content_translations (
                    id, title, slug, description, meta_title, meta_description, meta_keywords,
                    content_id, language_id, created_at, updated_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            `, Object.values(translationRecord));
        }
    }

    async translateContent(data, fromLanguage, toLanguage) {
        const client = new TranslateClient({
            region: "us-east-1",
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID,
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
            }
        });

        // Data'dan çevirilecek text'leri çıkar
        const textsToTranslate = [
            data.title || '',
            data.description || '',
            data.short_description || '', // Only for products
            data.meta_title || '',
            data.meta_description || '',
            data.meta_keywords || ''
        ];

        // Maksimum 5 paralel istek
        const concurrency = 5;
        const delay = (ms) => new Promise(res => setTimeout(res, ms));

        const results = [];
        for (let i = 0; i < textsToTranslate.length; i += concurrency) {
            const chunk = textsToTranslate.slice(i, i + concurrency);
            const chunkResults = await Promise.all(chunk.map(async (text) => {
                // Skip empty texts to avoid AWS "Text size cannot be zero" error
                if (!text || text.trim() === '') {
                    logger.debug(`Skipping empty text field (index: ${textsToTranslate.indexOf(text)})`);
                    return '';
                }

                try {
                    const command = new TranslateTextCommand({
                        Text: text,
                        SourceLanguageCode: fromLanguage,
                        TargetLanguageCode: toLanguage
                    });
                    const res = await client.send(command);
                    return res.TranslatedText;
                } catch (e) {
                    logger.warning("Error translating:", {
                        text: text,
                        error: e.message,
                        stack: e.stack,
                        fieldIndex: textsToTranslate.indexOf(text)
                    });
                    return "";
                }
            }));
            results.push(...chunkResults);
            await delay(200); // AWS rate limit için kısa bekleme
        }

        // Sonuçları data objesi formatına dönüştür
        return {
            title: results[0] || '',
            description: results[1] || '',
            short_description: results[2] || '', // Only for products
            meta_title: results[3] || '',
            meta_description: results[4] || '',
            meta_keywords: results[5] || ''
        };
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

module.exports = TranslationStep;
