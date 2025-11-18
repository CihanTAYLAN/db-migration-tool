/*
# Fix German Slugs Step

Converts German umlauts and special characters in slugs to URL-friendly format.
Processes all translation tables for German language records.
*/

const logger = require('../../logger');

class FixGermanSlugsStep {
    constructor(targetDb, config, domain) {
        this.targetDb = targetDb;
        this.config = config;
        this.domain = domain;
    }

    async run() {
        logger.info('Starting fix German slugs step');

        try {
            let totalProcessed = 0;
            let totalUpdated = 0;

            // Define all translation tables to process
            const translationTables = [
                {
                    table: 'content_translations',
                    description: 'Content translations'
                },
                {
                    table: 'product_translations',
                    description: 'Product translations'
                },
                {
                    table: 'category_translations',
                    description: 'Category translations'
                },
                {
                    table: 'page_translations',
                    description: 'Page translations'
                }
            ];

            // Process each translation table
            for (const tableInfo of translationTables) {
                logger.info(`Processing German slugs in ${tableInfo.description}...`);

                const result = await this.fixGermanSlugsInTable(tableInfo.table);
                totalProcessed += result.processed;
                totalUpdated += result.updated;

                logger.info(`${tableInfo.description}: ${result.updated} German slugs updated`);
            }

            logger.success(`Fix German slugs step completed: ${totalUpdated} total records updated across all tables`);

            return {
                success: true,
                count: totalProcessed,
                updated: totalUpdated
            };

        } catch (error) {
            logger.error('Fix German slugs step failed', { error: error.message });
            throw error;
        }
    }

    // German umlaut conversion mapping
    getGermanUmlautMap() {
        return {
            // Lowercase umlauts
            'ä': 'ae',
            'ö': 'oe',
            'ü': 'ue',
            'ß': 'ss',

            // Uppercase umlauts
            'Ä': 'ae',
            'Ö': 'oe',
            'Ü': 'ue',

            // Other special characters that might appear in German
            'é': 'e',
            'è': 'e',
            'à': 'a',
            'â': 'a',
            'ê': 'e',
            'î': 'i',
            'ô': 'o',
            'û': 'u',
            'ç': 'c',
            'ñ': 'n'
        };
    }

    convertGermanToUrlFriendly(text) {
        if (!text || typeof text !== 'string') {
            return text;
        }

        let converted = text;
        const umlautMap = this.getGermanUmlautMap();

        // Replace German umlauts and special characters
        for (const [german, replacement] of Object.entries(umlautMap)) {
            // Use word boundaries to avoid partial replacements
            const regex = new RegExp(german.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
            converted = converted.replace(regex, replacement);
        }

        // Convert to lowercase
        converted = converted.toLowerCase();

        // Remove any remaining non-ASCII characters (keep only a-z, 0-9, hyphens, underscores)
        converted = converted.replace(/[^a-z0-9\-_]/g, '-');

        // Remove multiple consecutive hyphens
        converted = converted.replace(/-+/g, '-');

        // Remove leading/trailing hyphens
        converted = converted.replace(/^-+|-+$/g, '');

        return converted;
    }

    async fixGermanSlugsInTable(tableName) {
        try {
            // First, get the German language ID
            const langQuery = "SELECT id FROM languages WHERE code = 'de' LIMIT 1";
            const langResult = await this.targetDb.query(langQuery);

            if (langResult.length === 0) {
                logger.debug('German language not found, skipping table');
                return { processed: 0, updated: 0 };
            }

            const germanLanguageId = langResult[0].id;
            logger.debug(`German language ID: ${germanLanguageId}`);

            // Get all German records with non-empty slugs for this table
            // Note: Some tables might not have 'title' column, so we select only what's available
            let selectFields = 'id, slug';
            if (tableName === 'content_translations') {
                selectFields = 'id, slug, title'; // content_translations has title
            }

            const query = `
                SELECT ${selectFields}
                FROM ${tableName}
                WHERE language_id = $1
                AND (slug IS NOT NULL AND slug != '')
                ORDER BY id
            `;

            const records = await this.targetDb.query(query, [germanLanguageId]);

            if (records.length === 0) {
                logger.debug(`No German ${tableName} records found`);
                return { processed: 0, updated: 0 };
            }

            logger.debug(`Found ${records.length} German ${tableName} records to check`);

            // Identify records where slug contains German umlauts or special characters
            const recordsToFix = [];

            for (const record of records) {
                const slug = record.slug;

                // Check if slug contains German umlauts or special characters that need conversion
                const hasGermanChars = /[äöüßÄÖÜéèàâêîôûçñ]/i.test(slug);

                if (hasGermanChars) {
                    // Convert to URL-friendly format
                    const urlFriendlySlug = this.convertGermanToUrlFriendly(slug);

                    // If conversion resulted in a different slug, we need to update
                    if (urlFriendlySlug && urlFriendlySlug !== slug) {
                        logger.debug(`Converting German slug in ${tableName}: "${slug}" -> "${urlFriendlySlug}"`);
                        recordsToFix.push({
                            id: record.id,
                            oldSlug: slug,
                            newSlug: urlFriendlySlug
                        });
                    }
                }
            }

            if (recordsToFix.length === 0) {
                logger.debug(`No German slugs found that need conversion in ${tableName}`);
                return { processed: records.length, updated: 0 };
            }

            logger.debug(`Found ${recordsToFix.length} German slugs that need conversion in ${tableName}`);

            // Update the records in batches
            const batchSize = this.config.steps.fixGermanSlugs.batchSize || 50;
            let totalUpdated = 0;

            for (let i = 0; i < recordsToFix.length; i += batchSize) {
                const batch = recordsToFix.slice(i, i + batchSize);

                try {
                    // Individual updates for safety (since we're dealing with slug changes)
                    for (const record of batch) {
                        const updateQuery = `
                            UPDATE ${tableName}
                            SET slug = $1, updated_at = NOW()
                            WHERE id = $2
                        `;
                        await this.targetDb.query(updateQuery, [record.newSlug, record.id]);
                        totalUpdated++;
                    }

                    logger.debug(`Updated batch of ${batch.length} German slugs in ${tableName}`);

                } catch (error) {
                    logger.error(`Failed to update batch starting at index ${i} in ${tableName}`, { error: error.message });

                    // Continue with individual updates for failed batch
                    for (const record of batch) {
                        try {
                            const updateQuery = `
                                UPDATE ${tableName}
                                SET slug = $1, updated_at = NOW()
                                WHERE id = $2
                            `;
                            await this.targetDb.query(updateQuery, [record.newSlug, record.id]);
                            totalUpdated++;
                        } catch (individualError) {
                            logger.error(`Failed to update German slug for ${tableName} record ${record.id}`, {
                                error: individualError.message,
                                oldSlug: record.oldSlug,
                                newSlug: record.newSlug
                            });
                        }
                    }
                }
            }

            return { processed: records.length, updated: totalUpdated };

        } catch (error) {
            logger.error(`Failed to fix German slugs in ${tableName}`, { error: error.message });
            return { processed: 0, updated: 0 };
        }
    }
}

module.exports = FixGermanSlugsStep;