/*
# Replace Image URLs Step

Replaces image URLs in product_images table for production domain.
*/

const logger = require('../../logger');

class ReplaceImageUrlsStep {
    constructor(targetDb, config, domain) {
        this.targetDb = targetDb;
        this.config = config;
        this.domain = domain;

        if (!domain) {
            throw new Error('Domain parameter is required for replaceImageUrls step');
        }

        // Validate domain format
        if (!this.isValidDomain(domain)) {
            throw new Error('Invalid domain format. Expected format: https://example.com');
        }
    }

    isValidDomain(domain) {
        // Basic domain validation - should start with https:// and contain valid domain characters
        const domainRegex = /^https:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        return domainRegex.test(domain);
    }

    async run() {
        logger.info(`Starting replace image URLs step for domain: ${this.domain}`);

        try {
            let totalProcessed = 0;
            let totalUpdated = 0;

            // Define all tables and their image columns to process
            const imageTables = [
                {
                    table: 'product_images',
                    column: 'image_url',
                    description: 'Product images'
                },
                {
                    table: 'contents',
                    column: 'image',
                    description: 'Content images'
                },
                {
                    table: 'certificate_providers',
                    column: 'image',
                    description: 'Certificate provider images'
                },
                {
                    table: 'certificate_provider_badges',
                    column: 'icon',
                    description: 'Certificate provider badge icons'
                }
            ];

            // Process each table
            for (const tableInfo of imageTables) {
                logger.info(`Processing ${tableInfo.description}...`);

                const result = await this.processTable(tableInfo);
                totalProcessed += result.processed;
                totalUpdated += result.updated;

                logger.info(`${tableInfo.description}: ${result.updated} URLs updated`);
            }

            logger.success(`Replace image URLs step completed: ${totalUpdated} total URLs updated`);

            return {
                success: true,
                count: totalProcessed,
                updated: totalUpdated
            };

        } catch (error) {
            logger.error('Replace image URLs step failed', { error: error.message });
            throw error;
        }
    }

    async analyzeUrls(images, columnName) {
        const urlsToUpdate = [];
        let oldDomain = null;

        for (const image of images) {
            const currentUrl = image[columnName];

            // Skip null/empty values
            if (!currentUrl || currentUrl.trim() === '') {
                continue;
            }

            // Extract domain from current URL
            const currentDomain = this.extractDomain(currentUrl);

            if (currentDomain && currentDomain !== this.domain) {
                // URL needs to be updated
                const newUrl = currentUrl.replace(currentDomain, this.domain);

                urlsToUpdate.push({
                    id: image.id,
                    oldUrl: currentUrl,
                    newUrl: newUrl
                });

                // Track the old domain for logging
                if (!oldDomain) {
                    oldDomain = currentDomain;
                }
            }
        }

        return { urlsToUpdate, oldDomain };
    }

    extractDomain(url) {
        try {
            // Handle URLs that start with https://
            if (url.startsWith('https://')) {
                const withoutProtocol = url.substring(8); // Remove 'https://'
                const domainEnd = withoutProtocol.indexOf('/');
                return domainEnd !== -1
                    ? 'https://' + withoutProtocol.substring(0, domainEnd)
                    : 'https://' + withoutProtocol;
            }
            return null;
        } catch (error) {
            logger.debug(`Failed to extract domain from URL: ${url}`, { error: error.message });
            return null;
        }
    }

    async processTable(tableInfo) {
        try {
            // Get current image URLs for this table
            const query = `SELECT id, ${tableInfo.column} FROM ${tableInfo.table} WHERE ${tableInfo.column} IS NOT NULL AND ${tableInfo.column} != ''`;
            const existingImages = await this.targetDb.query(query);

            if (existingImages.length === 0) {
                return { processed: 0, updated: 0 };
            }

            // Analyze current URLs to determine replacement patterns
            const { urlsToUpdate, oldDomain } = await this.analyzeUrls(existingImages, tableInfo.column);

            if (urlsToUpdate.length === 0) {
                return { processed: existingImages.length, updated: 0 };
            }

            // Update URLs for this table
            const result = await this.updateImageUrls(urlsToUpdate, tableInfo);

            return { processed: existingImages.length, updated: result.updated };

        } catch (error) {
            logger.error(`Failed to process table ${tableInfo.table}`, { error: error.message });
            return { processed: 0, updated: 0 };
        }
    }

    async updateImageUrls(urlsToUpdate, tableInfo) {
        const batchSize = this.config.steps.replaceImageUrls.batchSize || 1000;
        let totalUpdated = 0;

        // Use bulk update approach with CASE WHEN statements for better performance
        for (let i = 0; i < urlsToUpdate.length; i += batchSize) {
            const batch = urlsToUpdate.slice(i, i + batchSize);

            try {
                // Create bulk update query using CASE WHEN for multiple updates in one query
                const ids = batch.map(u => u.id);
                const whenClauses = batch.map(u => `WHEN '${u.id}' THEN '${u.newUrl.replace(/'/g, "''")}'`).join(' ');

                const query = `
                    UPDATE ${tableInfo.table}
                    SET ${tableInfo.column} = CASE id ${whenClauses} END,
                        updated_at = NOW()
                    WHERE id IN (${ids.map(id => `'${id}'`).join(',')})
                `;

                logger.debug(`Executing bulk update query for ${batch.length} images in ${tableInfo.table}`);
                await this.targetDb.query(query);

                totalUpdated += batch.length;

            } catch (error) {
                logger.error(`Failed to update batch starting at index ${i} in ${tableInfo.table}`, {
                    error: error.message,
                    batchSize: batch.length
                });

                // Fallback to individual updates for this batch
                logger.info('Falling back to individual updates for this batch...');
                for (const urlUpdate of batch) {
                    try {
                        await this.targetDb.query(
                            `UPDATE ${tableInfo.table} SET ${tableInfo.column} = $1, updated_at = NOW() WHERE id = $2`,
                            [urlUpdate.newUrl, urlUpdate.id]
                        );
                        totalUpdated++;
                    } catch (individualError) {
                        logger.error(`Failed to update URL for ${tableInfo.table} ID ${urlUpdate.id}`, {
                            error: individualError.message,
                            oldUrl: urlUpdate.oldUrl,
                            newUrl: urlUpdate.newUrl
                        });
                    }
                }
            }
        }

        return { updated: totalUpdated };
    }
}

module.exports = ReplaceImageUrlsStep;