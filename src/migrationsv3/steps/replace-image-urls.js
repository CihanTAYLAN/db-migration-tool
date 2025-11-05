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
            // Get current image URLs to preview what will be changed
            const existingImages = await this.targetDb.query(
                'SELECT id, image_url FROM product_images WHERE image_url IS NOT NULL'
            );

            if (existingImages.length === 0) {
                logger.warning('No product images found to update');
                return { success: true, count: 0, updated: 0 };
            }

            logger.info(`Found ${existingImages.length} product images to process`);

            // Analyze current URLs to determine replacement patterns
            const { urlsToUpdate, oldDomain } = await this.analyzeUrls(existingImages);

            if (urlsToUpdate.length === 0) {
                logger.info('No URLs need to be updated - all URLs already use the target domain');
                return { success: true, count: existingImages.length, updated: 0 };
            }

            logger.info(`Found ${urlsToUpdate.length} URLs to update from domain: ${oldDomain}`);

            // Preview changes
            logger.info('Preview of changes:');
            urlsToUpdate.slice(0, 5).forEach(({ oldUrl, newUrl }) => {
                logger.info(`  ${oldUrl} -> ${newUrl}`);
            });

            if (urlsToUpdate.length > 5) {
                logger.info(`  ... and ${urlsToUpdate.length - 5} more URLs`);
            }

            // Update URLs in batches
            const result = await this.updateImageUrls(urlsToUpdate);

            logger.success(`Replace image URLs step completed: ${result.updated} URLs updated`);

            return {
                success: true,
                count: existingImages.length,
                updated: result.updated
            };

        } catch (error) {
            logger.error('Replace image URLs step failed', { error: error.message });
            throw error;
        }
    }

    async analyzeUrls(images) {
        const urlsToUpdate = [];
        let oldDomain = null;

        for (const image of images) {
            const currentUrl = image.image_url;

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

    async updateImageUrls(urlsToUpdate) {
        const batchSize = this.config.steps.replaceImageUrls.batchSize || 1000;
        let totalUpdated = 0;

        logger.info(`Updating URLs in batches of ${batchSize}...`);

        // Use bulk update approach with CASE WHEN statements for better performance
        for (let i = 0; i < urlsToUpdate.length; i += batchSize) {
            const batch = urlsToUpdate.slice(i, i + batchSize);

            try {
                // Create bulk update query using CASE WHEN for multiple updates in one query
                const ids = batch.map(u => u.id);
                const whenClauses = batch.map(u => `WHEN '${u.id}' THEN '${u.newUrl.replace(/'/g, "''")}'`).join(' ');

                const query = `
                    UPDATE product_images
                    SET image_url = CASE id ${whenClauses} END,
                        updated_at = NOW()
                    WHERE id IN (${ids.map(id => `'${id}'`).join(',')})
                `;

                logger.debug(`Executing bulk update query for ${batch.length} images`);
                await this.targetDb.query(query);

                totalUpdated += batch.length;

                logger.info(`Progress: ${totalUpdated}/${urlsToUpdate.length} URLs updated (batch ${Math.floor(i/batchSize) + 1})`);

            } catch (error) {
                logger.error(`Failed to update batch starting at index ${i}`, {
                    error: error.message,
                    batchSize: batch.length
                });

                // Fallback to individual updates for this batch
                logger.info('Falling back to individual updates for this batch...');
                for (const urlUpdate of batch) {
                    try {
                        await this.targetDb.query(
                            'UPDATE product_images SET image_url = $1, updated_at = NOW() WHERE id = $2',
                            [urlUpdate.newUrl, urlUpdate.id]
                        );
                        totalUpdated++;
                    } catch (individualError) {
                        logger.error(`Failed to update URL for image ID ${urlUpdate.id}`, {
                            error: individualError.message,
                            oldUrl: urlUpdate.oldUrl,
                            newUrl: urlUpdate.newUrl
                        });
                    }
                }
            }
        }

        logger.info(`Completed URL updates: ${totalUpdated} successful, ${urlsToUpdate.length - totalUpdated} failed`);

        return { updated: totalUpdated };
    }
}

module.exports = ReplaceImageUrlsStep;