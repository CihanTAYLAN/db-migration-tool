/*
# Sluggify Product and Category URLs Step

Fixes German and Japanese slug character issues in category_translations and product_translations tables.
Uses limax library to properly slugify content URLs.
Only connects to target database.
*/

const logger = require('../../logger');

class SluggifyProductCategoryUrlsStep {
    constructor(targetDb, config) {
        this.targetDb = targetDb;
        this.config = config;
        this.slug = require('limax');
    }

    async run() {
        logger.info('Starting sluggify product and category URLs step');

        try {
            // Get all non-English language IDs
            const languages = await this.getTargetLanguages();
            
            if (languages.length === 0) {
                logger.info('No non-English languages found for slug fixing');
                return { success: true, count: 0, updated: 0 };
            }

            let totalProcessed = 0;
            let totalUpdated = 0;

            // Process category translations
            for (const language of languages) {
                const categoryResult = await this.fixCategorySlugs(language);
                totalProcessed += categoryResult.processed;
                totalUpdated += categoryResult.updated;
                logger.info(`Categories for ${language.code}: ${categoryResult.updated}/${categoryResult.processed} slugs updated`);
            }

            // Process product translations
            for (const language of languages) {
                const productResult = await this.fixProductSlugs(language);
                totalProcessed += productResult.processed;
                totalUpdated += productResult.updated;
                logger.info(`Products for ${language.code}: ${productResult.updated}/${productResult.processed} slugs updated`);
            }

            logger.success(`Sluggify product and category URLs step completed: ${totalUpdated}/${totalProcessed} total slugs regenerated`);

            return {
                success: true,
                count: totalProcessed,
                updated: totalUpdated
            };

        } catch (error) {
            logger.error('Sluggify product and category URLs step failed', { error: error.message });
            throw error;
        }
    }

    async getTargetLanguages() {
        const query = `
            SELECT id, code, name
            FROM languages
            WHERE code != 'en'
            ORDER BY code
        `;

        const languages = await this.targetDb.query(query);
        logger.info(`Found ${languages.length} non-English target languages for slug fixing: ${languages.map(l => l.code).join(', ')}`);
        
        return languages;
    }

    async fixCategorySlugs(language) {
        try {
            // Get all category translations for this language
            const query = `
                SELECT ct.id, ct.slug, ct.title, ct.category_id
                FROM category_translations ct
                WHERE ct.language_id = $1
                AND (ct.slug IS NOT NULL AND ct.slug != '')
                ORDER BY ct.id
            `;

            const translations = await this.targetDb.query(query, [language.id]);

            if (translations.length === 0) {
                logger.debug(`No category translations found for language: ${language.code}`);
                return { processed: 0, updated: 0 };
            }

            logger.info(`Processing ${translations.length} category translations for ${language.code}`);

            let processedCount = 0;
            let updatedCount = 0;

            // Process translations in batches for better performance
            const batchSize = 500;
            for (let i = 0; i < translations.length; i += batchSize) {
                const batch = translations.slice(i, i + batchSize);
                
                for (const translation of batch) {
                    try {
                        processedCount++;
                        
                        // Always regenerate slug for consistency
                        const newSlug = this.slug(translation.title, {
                            lang: language.code,
                            maintainCase: false,
                            replacement: '-'
                        });

                        await this.updateCategorySlug(translation.id, newSlug);
                        updatedCount++;
                        
                        // Log only a sample to avoid too much noise
                        if (updatedCount <= 5 || (i === Math.floor(translations.length / batchSize) * batchSize)) {
                            logger.debug(`Updated category slug ${translation.category_id}: "${translation.slug}" -> "${newSlug}"`);
                        }

                    } catch (error) {
                        logger.warning(`Failed to update category slug ${translation.id}`, {
                            error: error.message,
                            oldSlug: translation.slug,
                            title: translation.title?.substring(0, 50)
                        });
                    }
                }
                
                logger.debug(`Processed batch ${Math.floor(i/batchSize) + 1} for ${language.code} (${Math.min(i + batchSize, translations.length)}/${translations.length})`);
            }

            logger.info(`Categories for ${language.code}: ${updatedCount}/${processedCount} slugs regenerated`);

            return { processed: processedCount, updated: updatedCount };

        } catch (error) {
            logger.error(`Failed to fix category slugs for language ${language.code}`, {
                error: error.message
            });
            return { processed: 0, updated: 0 };
        }
    }

    async fixProductSlugs(language) {
        try {
            // Get all product translations for this language
            const query = `
                SELECT pt.id, pt.slug, pt.title, pt.product_id
                FROM product_translations pt
                WHERE pt.language_id = $1
                AND (pt.slug IS NOT NULL AND pt.slug != '')
                ORDER BY pt.id
            `;

            const translations = await this.targetDb.query(query, [language.id]);

            if (translations.length === 0) {
                logger.debug(`No product translations found for language: ${language.code}`);
                return { processed: 0, updated: 0 };
            }

            logger.info(`Processing ${translations.length} product translations for ${language.code}`);

            let processedCount = 0;
            let updatedCount = 0;

            // Process translations in batches for better performance
            const batchSize = 500;
            for (let i = 0; i < translations.length; i += batchSize) {
                const batch = translations.slice(i, i + batchSize);
                
                for (const translation of batch) {
                    try {
                        processedCount++;
                        
                        // Always regenerate slug for consistency
                        const newSlug = this.slug(translation.title, {
                            lang: language.code,
                            maintainCase: false,
                            replacement: '-'
                        });

                        await this.updateProductSlug(translation.id, newSlug);
                        updatedCount++;
                        
                        // Log only a sample to avoid too much noise
                        if (updatedCount <= 5 || (i === Math.floor(translations.length / batchSize) * batchSize)) {
                            logger.debug(`Updated product slug ${translation.product_id}: "${translation.slug}" -> "${newSlug}"`);
                        }

                    } catch (error) {
                        logger.warning(`Failed to update product slug ${translation.id}`, {
                            error: error.message,
                            oldSlug: translation.slug,
                            title: translation.title?.substring(0, 50)
                        });
                    }
                }
                
                logger.debug(`Processed batch ${Math.floor(i/batchSize) + 1} for ${language.code} (${Math.min(i + batchSize, translations.length)}/${translations.length})`);
            }

            logger.info(`Products for ${language.code}: ${updatedCount}/${processedCount} slugs regenerated`);

            return { processed: processedCount, updated: updatedCount };

        } catch (error) {
            logger.error(`Failed to fix product slugs for language ${language.code}`, {
                error: error.message
            });
            return { processed: 0, updated: 0 };
        }
    }

    async updateCategorySlug(id, newSlug) {
        const query = `
            UPDATE category_translations
            SET slug = $1, updated_at = NOW()
            WHERE id = $2
        `;

        await this.targetDb.query(query, [newSlug, id]);
    }

    async updateProductSlug(id, newSlug) {
        const query = `
            UPDATE product_translations
            SET slug = $1, updated_at = NOW()
            WHERE id = $2
        `;

        await this.targetDb.query(query, [newSlug, id]);
    }
}

module.exports = SluggifyProductCategoryUrlsStep;
