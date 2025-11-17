/*
# Fix Content URLs Step

Fixes swapped slug and description fields in content_translations table for non-English languages.
Only connects to target database.
*/

const logger = require('../../logger');

class FixContentUrlsStep {
    constructor(targetDb, config, domain) {
        this.targetDb = targetDb;
        this.config = config;
        this.domain = domain;
    }

    async run() {
        logger.info('Starting fix content URLs step');

        try {
            let totalProcessed = 0;
            let totalUpdated = 0;

            // Fix swapped slug and description fields in content_translations table for non-English languages
            logger.info('Processing content_translations table for swapped fields...');

            const result = await this.fixSwappedFields();
            totalProcessed = result.processed;
            totalUpdated = result.updated;

            logger.info(`Content translations: ${result.updated} records fixed`);

            logger.success(`Fix content URLs step completed: ${totalUpdated} total records updated`);

            return {
                success: true,
                count: totalProcessed,
                updated: totalUpdated
            };

        } catch (error) {
            logger.error('Fix content URLs step failed', { error: error.message });
            throw error;
        }
    }

    // Slug generation helper - URL-safe for all languages (same as TranslationStep)
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

    async fixSwappedFields() {
        try {
            // First, get the default language ID (English) to exclude it
            const defaultLangQuery = "SELECT id FROM languages WHERE code = 'en' LIMIT 1";
            const defaultLangResult = await this.targetDb.query(defaultLangQuery);

            if (defaultLangResult.length === 0) {
                throw new Error('Default English language not found');
            }

            const englishLanguageId = defaultLangResult[0].id;
            logger.debug(`English language ID: ${englishLanguageId}`);

            // Get all content_translations records where language_id is NOT English
            const query = `
                SELECT id, language_id, slug, description
                FROM content_translations
                WHERE language_id != $1
                AND (slug IS NOT NULL AND slug != '')
                AND (description IS NOT NULL AND description != '')
            `;

            const records = await this.targetDb.query(query, [englishLanguageId]);

            if (records.length === 0) {
                logger.info('No records found with swapped fields to fix');
                return { processed: 0, updated: 0 };
            }

            logger.info(`Found ${records.length} non-English content translation records to check`);

            // Identify records where slug and description are swapped
            // Check if slug field is NOT URL-friendly (contains characters that shouldn't be in a slug)
            const recordsToFix = [];

            for (const record of records) {
                const slug = record.slug;
                const description = record.description;

                // Check if slug is NOT URL-friendly (contains uppercase, spaces, special chars, etc.)
                const slugIsUrlFriendly = /^[a-z0-9-]+$/.test(slug);

                if (!slugIsUrlFriendly) {
                    logger.debug(`Detected swapped fields for record ${record.id}: slug="${slug}" is not URL-friendly`);
                    recordsToFix.push({
                        id: record.id,
                        correctedSlug: this.slugify(description), // slugify the description to create proper slug
                        correctedDescription: slug // current slug content becomes description
                    });
                }
            }

            if (recordsToFix.length === 0) {
                logger.info('No records found that need field swapping');
                return { processed: records.length, updated: 0 };
            }

            logger.info(`Found ${recordsToFix.length} records that need field swapping`);

            // Update the records in batches
            const batchSize = this.config.steps.fixContentUrls.batchSize || 200;
            let totalUpdated = 0;

            for (let i = 0; i < recordsToFix.length; i += batchSize) {
                const batch = recordsToFix.slice(i, i + batchSize);

                try {
                    // Bulk update using individual queries for safety
                    for (const record of batch) {
                        const updateQuery = `
                            UPDATE content_translations
                            SET slug = $1, description = $2, updated_at = NOW()
                            WHERE id = $3
                        `;
                        await this.targetDb.query(updateQuery, [
                            record.correctedSlug,
                            record.correctedDescription,
                            record.id
                        ]);
                        totalUpdated++;
                    }

                    logger.debug(`Updated batch of ${batch.length} records`);

                } catch (error) {
                    logger.error(`Failed to update batch starting at index ${i}`, { error: error.message });

                    // Continue with individual updates for failed batch
                    for (const record of batch) {
                        try {
                            const updateQuery = `
                                UPDATE content_translations
                                SET slug = $1, description = $2, updated_at = NOW()
                                WHERE id = $3
                            `;
                            await this.targetDb.query(updateQuery, [
                                record.correctedSlug,
                                record.correctedDescription,
                                record.id
                            ]);
                            totalUpdated++;
                        } catch (individualError) {
                            logger.error(`Failed to update record ${record.id}`, {
                                error: individualError.message
                            });
                        }
                    }
                }
            }

            return { processed: records.length, updated: totalUpdated };

        } catch (error) {
            logger.error('Failed to fix swapped fields', { error: error.message });
            return { processed: 0, updated: 0 };
        }
    }
}

module.exports = FixContentUrlsStep;
