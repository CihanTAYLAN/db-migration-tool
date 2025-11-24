/*
# Content Translation Step

Batch translation of content pages to all supported languages.
*/

const slug = require('limax');
const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const { TranslateClient, TranslateTextCommand } = require('@aws-sdk/client-translate');

class ContentTranslationStep {
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
                logger.info(`Content translation migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
    }

    async run() {
        logger.info('Starting content translation migration step...');

        try {
            // 1. Get all supported languages (excluding default)
            const languages = await this.getTargetLanguages();

            if (languages.length === 0) {
                logger.info('No languages to translate to');
                return { success: true, count: 0, failed: 0 };
            }

            // 2. Get contents in default language
            const contents = await this.getContentsInDefaultLanguage();

            if (contents.length === 0) {
                logger.info('No contents found for translation');
                return { success: true, count: 0, failed: 0 };
            }

            logger.info(`Found ${contents.length} contents to translate to ${languages.length} languages`);

            // 3. Process translations in batches
            const result = await this.batchProcessor.process(contents, async (batch) => {
                return await this.processTranslationBatch(batch, languages);
            });

            logger.success(`Content translation completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed
            };

        } catch (error) {
            logger.error('Content translation migration step failed', { error: error.message });
            throw error;
        }
    }

    async getTargetLanguages() {
        logger.info('Getting target languages for translation...');

        let languages;

        if (this.config.steps.translation.languages && this.config.steps.translation.languages.length > 0) {
            // Use languages from config
            languages = await this.targetDb.query(
                'SELECT id, code, name FROM languages WHERE code = ANY($1) AND id != $2',
                [this.config.steps.translation.languages, this.defaultLanguageId]
            );
            logger.info(`Using configured languages: ${this.config.steps.translation.languages.join(', ')}`);
        } else {
            // Get all languages except default
            languages = await this.targetDb.query(
                'SELECT id, code, name FROM languages WHERE id != $1 ORDER BY id',
                [this.defaultLanguageId]
            );
            logger.info(`Using all database languages except default`);
        }

        logger.info(`Found ${languages.length} target languages for translation`);
        languages.forEach(lang => logger.debug(`Language: ${lang.code} (${lang.name}) - ID: ${lang.id}`));

        return languages;
    }

    async getContentsInDefaultLanguage() {
        logger.info('Fetching contents in default language...');

        const query = `
            SELECT
                ct.content_id,
                ct.title,
                ct.description,
                ct.meta_title,
                ct.meta_description,
                ct.meta_keywords
            FROM contents c
            INNER JOIN content_translations ct ON c.id = ct.content_id AND ct.language_id = $1
            ORDER BY c.id
        `;

        const contents = await this.targetDb.query(query, [this.defaultLanguageId]);
        logger.info(`Found ${contents.length} contents in default language`);

        return contents;
    }

    async processTranslationBatch(contents, languages) {
        try {
            let successCount = 0;
            let failedCount = 0;

            // Get default language for source
            const defaultLanguage = await this.targetDb.query(
                'SELECT code FROM languages WHERE id = $1',
                [this.defaultLanguageId]
            );

            if (!defaultLanguage.length) {
                logger.error('Default language not found');
                return { success: 0, failed: contents.length * languages.length };
            }

            const sourceLangCode = defaultLanguage[0].code;

            // Process each content for each language
            for (const content of contents) {
                // Skip if no title
                if (!content.title || content.title.trim() === '') {
                    logger.debug(`Skipping content ${content.content_id} - no title`);
                    continue;
                }

                for (const language of languages) {
                    try {
                        // Check if translation already exists and is complete
                        const existing = await this.checkExistingTranslation(content.content_id, language.id);

                        if (existing && existing.isComplete) {
                            logger.debug(`Skipping ${content.content_id} to ${language.code} - already translated`);
                            continue;
                        }

                        // Translate content
                        const translatedData = await this.translateContent(content, sourceLangCode, language.code);

                        if (!translatedData || !translatedData.title || translatedData.title.trim() === '') {
                            logger.warning(`Translation failed for ${content.content_id} to ${language.code}`);
                            failedCount++;
                            continue;
                        }

                        // Save translation
                        await this.saveTranslation(content.content_id, language, translatedData);
                        successCount++;

                        logger.debug(`Translated ${content.content_id} to ${language.code}`);

                    } catch (error) {
                        logger.warning(`Failed to translate ${content.content_id} to ${language.code}`, {
                            error: error.message,
                            content_title: content.title
                        });
                        failedCount++;
                    }
                }
            }

            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process translation batch', {
                error: error.message,
                contentCount: contents.length,
                languageCount: languages.length
            });
            return { success: 0, failed: contents.length * languages.length };
        }
    }

    async checkExistingTranslation(contentId, languageId) {
        const result = await this.targetDb.query(`
            SELECT title, description, meta_title, meta_description, meta_keywords
            FROM content_translations
            WHERE content_id = $1 AND language_id = $2
            LIMIT 1
        `, [contentId, languageId]);

        if (result.length === 0) return null;

        const existing = result[0];
        const isComplete = existing.title?.trim() &&
                          existing.description?.trim() &&
                          existing.meta_title?.trim() &&
                          existing.meta_description?.trim() &&
                          existing.meta_keywords?.trim();

        return { ...existing, isComplete };
    }

    async translateContent(content, fromLang, toLang) {
        const fields = ['title', 'description', 'meta_title', 'meta_description', 'meta_keywords'];
        const translated = {};

        for (const field of fields) {
            const text = content[field];
            if (text && text.trim()) {
                translated[field] = await this.translateText(text, fromLang, toLang);
            } else {
                translated[field] = text || '';
            }
        }

        return translated;
    }

    async translateText(text, fromLang, toLang) {
        const client = new TranslateClient({
            region: process.env.AWS_REGION || "us-east-1",
            credentials: {
                accessKeyId: process.env.AWS_ACCESS_KEY_ID,
                secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
            }
        });

        try {
            // Check if text contains HTML tags
            const hasHtml = /<[^>]*>/.test(text);

            const command = new TranslateTextCommand({
                Text: text,
                SourceLanguageCode: fromLang,
                TargetLanguageCode: toLang,
                // Use HTML mode to preserve HTML tags, text mode for plain text
                ContentType: hasHtml ? 'html' : 'text/plain'
            });

            const response = await client.send(command);
            return response.TranslatedText;

        } catch (error) {
            logger.warning('AWS Translate error', {
                text: text.substring(0, 100) + '...',
                error: error.message,
                fromLang,
                toLang
            });
            return text; // Return original on error
        }
    }

    async saveTranslation(contentId, language, translationData) {
        let slugText = translationData.title;

        const translationRecord = {
            id: require('uuid').v7(),
            title: translationData.title,
            description: translationData.description,
            slug: slug(slugText),
            meta_title: translationData.meta_title,
            meta_description: translationData.meta_description,
            meta_keywords: translationData.meta_keywords,
            content_id: contentId,
            language_id: language.id,
            created_at: new Date(),
            updated_at: new Date()
        };

        // Check if exists
        const existing = await this.targetDb.query(
            'SELECT id FROM content_translations WHERE content_id = $1 AND language_id = $2',
            [contentId, language.id]
        );

        if (existing.length > 0) {
            // Update
            await this.targetDb.query(`
                UPDATE content_translations SET
                    title = $1, description = $2, slug = $3, meta_title = $4,
                    meta_description = $5, meta_keywords = $6, updated_at = NOW()
                WHERE id = $7
            `, [
                translationRecord.title,
                translationRecord.description,
                translationRecord.slug,
                translationRecord.meta_title,
                translationRecord.meta_description,
                translationRecord.meta_keywords,
                existing[0].id
            ]);
        } else {
            // Insert
            await this.targetDb.query(`
                INSERT INTO content_translations (
                    id, title, slug, description, meta_title, meta_description, meta_keywords,
                    content_id, language_id, created_at, updated_at
                ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
            `, [
                translationRecord.id,
                translationRecord.title,
                translationRecord.slug,
                translationRecord.description,
                translationRecord.meta_title,
                translationRecord.meta_description,
                translationRecord.meta_keywords,
                translationRecord.content_id,
                translationRecord.language_id,
                translationRecord.created_at,
                translationRecord.updated_at
            ]);
        }
    }
}

module.exports = ContentTranslationStep;
