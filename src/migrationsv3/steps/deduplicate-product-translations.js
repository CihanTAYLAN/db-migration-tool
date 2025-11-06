/*
# Deduplicate Product Translations Step

Handles deduplication of product translations by finding records with the same
language_id and slug, then appending a random 8-character suffix to duplicate slugs.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class DeduplicateProductTranslationsStep {
    constructor(targetDb, config) {
        this.targetDb = targetDb;
        this.config = config;

        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.deduplicateProductTranslations.batchSize,
            parallelLimit: config.steps.deduplicateProductTranslations.parallelLimit || 1,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Deduplicate product translations progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
    }

    async run() {
        logger.info('Starting deduplicate product translations step...');

        try {
            // 1. Find all duplicate slugs with same language_id
            const duplicates = await this.findDuplicateSlugs();

            if (duplicates.length === 0) {
                logger.info('No duplicate slugs found');
                return {
                    success: true,
                    count: 0,
                    duplicatesFound: 0
                };
            }

            logger.info(`Found ${duplicates.length} duplicate slug groups to process`);

            // 2. Process duplicates in batches
            const result = await this.batchProcessor.process(duplicates, async (batch) => {
                return await this.processDuplicateBatch(batch);
            });

            logger.success(`Deduplicate product translations completed: ${result.success} success, ${result.failed} failed`);

            return {
                success: result.failed === 0,
                count: result.success,
                failed: result.failed,
                duplicatesFound: duplicates.length
            };

        } catch (error) {
            logger.error('Deduplicate product translations step failed', { error: error.message });
            throw error;
        }
    }

    async findDuplicateSlugs() {
        logger.info('Finding duplicate slugs with same language_id...');

        try {
            // Query to find groups of product_translations with same language_id and slug
            const query = `
                SELECT
                    language_id,
                    slug,
                    COUNT(*) as count,
                    ARRAY_AGG(id) as translation_ids,
                    ARRAY_AGG(product_id) as product_ids
                FROM product_translations
                GROUP BY language_id, slug
                HAVING COUNT(*) > 1
                ORDER BY language_id, slug
            `;

            const duplicateGroups = await this.targetDb.query(query);

            logger.info(`Found ${duplicateGroups.length} groups of duplicate slugs`);

            // Transform to flat array of duplicate records (skip first one in each group)
            const duplicates = [];
            let totalDuplicateRecords = 0;

            for (const group of duplicateGroups) {
                const translationIds = group.translation_ids;
                const productIds = group.product_ids;

                // Skip the first record (keep original), mark rest as duplicates
                for (let i = 1; i < translationIds.length; i++) {
                    duplicates.push({
                        id: translationIds[i],
                        product_id: productIds[i],
                        language_id: group.language_id,
                        slug: group.slug,
                        groupSize: translationIds.length,
                        positionInGroup: i + 1 // 1-indexed position
                    });
                    totalDuplicateRecords++;
                }

                logger.debug(`Language ${group.language_id}, slug "${group.slug}": ${group.count} records found, ${group.count - 1} will be deduplicated`);
            }

            logger.info(`Total duplicate records to process: ${totalDuplicateRecords}`);
            return duplicates;

        } catch (error) {
            logger.error('Failed to find duplicate slugs', { error: error.message });
            throw error;
        }
    }

    async processDuplicateBatch(duplicates) {
        try {
            if (!duplicates || !Array.isArray(duplicates) || duplicates.length === 0) {
                logger.warning('Empty or invalid duplicates batch, skipping');
                return { success: 0, failed: 0 };
            }

            let successCount = 0;
            let failedCount = 0;
            const totalInBatch = duplicates.length;

            // Process each duplicate record
            for (let index = 0; index < duplicates.length; index++) {
                const duplicate = duplicates[index];
                const progressPercent = Math.round(((index + 1) / totalInBatch) * 100);

                try {
                    // Generate random 8-character suffix
                    const randomSuffix = this.generateRandomSuffix();
                    const newSlug = `${duplicate.slug}-${randomSuffix}`;

                    // Update the slug
                    await this.targetDb.query(
                        'UPDATE product_translations SET slug = $1, updated_at = NOW() WHERE id = $2',
                        [newSlug, duplicate.id]
                    );

                    successCount++;
                    logger.debug(`[${progressPercent}%] Updated translation ${duplicate.id} (product ${duplicate.product_id}): "${duplicate.slug}" → "${newSlug}"`);

                } catch (error) {
                    failedCount++;
                    logger.error(`[${progressPercent}%] Failed to update translation ${duplicate.id}`, { error: error.message });
                }
            }

            logger.info(`Batch processed: ${successCount} updated, ${failedCount} failed (100%)`);
            return { success: successCount, failed: failedCount };

        } catch (error) {
            logger.error('Failed to process duplicate batch', { error: error.message, count: duplicates.length });
            return { success: 0, failed: duplicates.length };
        }
    }

    generateRandomSuffix() {
        // Generate random 8-character alphanumeric string (lowercase)
        const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
        let result = '';
        for (let i = 0; i < 8; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }
}

module.exports = DeduplicateProductTranslationsStep;
