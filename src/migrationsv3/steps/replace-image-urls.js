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
                },
                {
                    table: 'pages',
                    column: 'data',
                    description: 'Json data content',
                    isJson: true
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

    async analyzeUrls(images, columnName, isJson = false) {
        const urlsToUpdate = [];
        let oldDomain = null;

        for (const image of images) {
            let currentValue = image[columnName];

            // Skip null/empty values
            if (!currentValue || currentValue === '') {
                continue;
            }

            if (isJson) {
                // Handle JSON fields - parse and find URLs within the JSON structure
                const jsonUrls = this.extractUrlsFromJson(currentValue);
                if (jsonUrls.length === 0) {
                    continue;
                }

                // Check if any URLs need updating
                let needsUpdate = false;
                const updatedJson = this.updateUrlsInJson(currentValue, jsonUrls, (url) => {
                    const currentDomain = this.extractDomain(url);
                    if (currentDomain && currentDomain !== this.domain) {
                        needsUpdate = true;
                        if (!oldDomain) {
                            oldDomain = currentDomain;
                        }
                        return url.replace(currentDomain, this.domain);
                    }
                    return url;
                });

                if (needsUpdate) {
                    urlsToUpdate.push({
                        id: image.id,
                        oldValue: currentValue,
                        newValue: updatedJson
                    });
                }
            } else {
                // Handle regular string fields
                const currentDomain = this.extractDomain(currentValue);

                if (currentDomain && currentDomain !== this.domain) {
                    // URL needs to be updated
                    const newUrl = currentValue.replace(currentDomain, this.domain);

                    urlsToUpdate.push({
                        id: image.id,
                        oldUrl: currentValue,
                        newUrl: newUrl
                    });

                    // Track the old domain for logging
                    if (!oldDomain) {
                        oldDomain = currentDomain;
                    }
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

    extractUrlsFromJson(jsonData) {
        const urls = [];
        try {
            // Handle both string and object inputs
            const data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;

            // Recursively find all string values that look like URLs
            const findUrls = (obj) => {
                if (typeof obj === 'string' && obj.startsWith('https://')) {
                    urls.push(obj);
                } else if (typeof obj === 'object' && obj !== null) {
                    for (const key in obj) {
                        findUrls(obj[key]);
                    }
                }
            };

            findUrls(data);
        } catch (error) {
            logger.debug(`Failed to parse JSON for URL extraction`, { error: error.message });
        }
        return urls;
    }

    updateUrlsInJson(jsonData, urls, updateFunction) {
        try {
            // Handle both string and object inputs
            const data = typeof jsonData === 'string' ? JSON.parse(jsonData) : JSON.parse(JSON.stringify(jsonData));

            // Recursively update URLs in the JSON structure
            const updateUrls = (obj) => {
                if (typeof obj === 'string' && obj.startsWith('https://')) {
                    return updateFunction(obj);
                } else if (typeof obj === 'object' && obj !== null) {
                    for (const key in obj) {
                        obj[key] = updateUrls(obj[key]);
                    }
                }
                return obj;
            };

            const updatedData = updateUrls(data);
            return JSON.stringify(updatedData);
        } catch (error) {
            logger.debug(`Failed to update URLs in JSON`, { error: error.message });
            // Return stringified version of original if parsing fails
            return typeof jsonData === 'string' ? jsonData : JSON.stringify(jsonData);
        }
    }

    async processTable(tableInfo) {
        try {
            // Get current image URLs for this table
            let query;
            if (tableInfo.isJson) {
                // For JSON fields, don't compare with empty string
                query = `SELECT id, ${tableInfo.column} FROM ${tableInfo.table} WHERE ${tableInfo.column} IS NOT NULL`;
            } else {
                // For string fields, exclude empty strings
                query = `SELECT id, ${tableInfo.column} FROM ${tableInfo.table} WHERE ${tableInfo.column} IS NOT NULL AND ${tableInfo.column} != ''`;
            }
            const existingImages = await this.targetDb.query(query);

            if (existingImages.length === 0) {
                return { processed: 0, updated: 0 };
            }

            logger.debug(`Found ${existingImages.length} records in ${tableInfo.table}`);

            // Analyze current URLs to determine replacement patterns
            const { urlsToUpdate, oldDomain } = await this.analyzeUrls(existingImages, tableInfo.column, tableInfo.isJson);

            if (urlsToUpdate.length === 0) {
                return { processed: existingImages.length, updated: 0 };
            }

            logger.debug(`Found ${urlsToUpdate.length} URLs to update in ${tableInfo.table}`);

            // Update URLs for this table
            const result = await this.updateImageUrls(urlsToUpdate, tableInfo);

            return { processed: existingImages.length, updated: result.updated };

        } catch (error) {
            logger.error(`Failed to process table ${tableInfo.table}`, { error: error.message, stack: error.stack });
            return { processed: 0, updated: 0 };
        }
    }

    async updateImageUrls(urlsToUpdate, tableInfo) {
        const batchSize = this.config.steps.replaceImageUrls.batchSize || 1000;
        let totalUpdated = 0;

        // For JSON fields, use parameterized queries to avoid SQL injection and JSON parsing issues
        if (tableInfo.isJson) {
            // Process JSON fields with individual parameterized queries
            for (const urlUpdate of urlsToUpdate) {
                try {
                    const query = `UPDATE ${tableInfo.table} SET ${tableInfo.column} = $1::jsonb, updated_at = NOW() WHERE id = $2`;
                    await this.targetDb.query(query, [urlUpdate.newValue, urlUpdate.id]);
                    totalUpdated++;
                } catch (error) {
                    logger.error(`Failed to update JSON field for ${tableInfo.table} ID ${urlUpdate.id}`, {
                        error: error.message,
                        oldValue: urlUpdate.oldValue,
                        newValue: urlUpdate.newValue
                    });
                }
            }
        } else {
            // Use bulk update approach with CASE WHEN statements for non-JSON fields
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
                            const query = `UPDATE ${tableInfo.table} SET ${tableInfo.column} = $1, updated_at = NOW() WHERE id = $2`;
                            await this.targetDb.query(query, [urlUpdate.newUrl, urlUpdate.id]);
                            totalUpdated++;
                        } catch (individualError) {
                            logger.error(`Failed to update URL for ${tableInfo.table} ID ${urlUpdate.id}`, {
                                error: individualError.message,
                                oldValue: urlUpdate.oldUrl,
                                newValue: urlUpdate.newUrl
                            });
                        }
                    }
                }
            }
        }

        return { updated: totalUpdated };
    }
}

module.exports = ReplaceImageUrlsStep;
