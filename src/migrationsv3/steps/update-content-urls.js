/*
# Update Content URLs Step

Updates media URLs in content_translations table to use new API format.
Only connects to target database.
Uses processMediaUrls function from blog-posts.js.
*/

const logger = require('../../logger');

class UpdateContentUrlsStep {
    constructor(targetDb, config) {
        this.targetDb = targetDb;
        this.config = config;
    }

    async run() {
        logger.info('Starting update content URLs step');

        try {
            // Find all content translations that contain media URLs
            const records = await this.findContentWithMediaUrls();

            if (records.length === 0) {
                logger.info('No content translations found with media URLs');
                return { success: true, count: 0, updated: 0 };
            }

            logger.info(`Found ${records.length} content translations with media URLs`);

            // Update each record
            let updatedCount = 0;
            for (const record of records) {
                try {
                    const processedDescription = this.processMediaUrls(record.description);
                    
                    if (processedDescription !== record.description) {
                        await this.updateContentTranslation(record.id, processedDescription);
                        updatedCount++;
                        logger.debug(`Updated content translation ${record.id}`);
                    }
                } catch (error) {
                    logger.warning(`Failed to update content translation ${record.id}`, {
                        error: error.message
                    });
                }
            }

            logger.success(`Update content URLs step completed: ${updatedCount} records updated`);

            return {
                success: true,
                count: records.length,
                updated: updatedCount
            };

        } catch (error) {
            logger.error('Update content URLs step failed', { error: error.message });
            throw error;
        }
    }

    async findContentWithMediaUrls() {
        const query = `
            SELECT id, description
            FROM content_translations
            WHERE description LIKE '%media url%'
            ORDER BY id
        `;

        const records = await this.targetDb.query(query);
        return records;
    }

    async updateContentTranslation(id, newDescription) {
        const query = `
            UPDATE content_translations
            SET description = $1, updated_at = NOW()
            WHERE id = $2
        `;

        await this.targetDb.query(query, [newDescription, id]);
    }

    processMediaUrls(content) {
        if (!content) return '';

        // Test with sample content first
        const testContent = '{{media url="wysiwyg/CoinexCoinShow-1.jpg"}}';
        logger.debug('Testing processMediaUrls function', {
            testInput: testContent,
            testOutput: this.testMediaUrlConversion(testContent)
        });

        let processedContent = content;

        // Debug: Log raw content if it contains media url
        if (processedContent.includes('media url')) {
            logger.debug('Raw content sample', {
                sample: processedContent.substring(0, 300),
                hasMediaUrl: processedContent.includes('media url'),
                hasQuotEntity: processedContent.includes('"'),
                hasRegularQuot: processedContent.includes('"'),
                rawSample: processedContent.match(/\{\{media url[^}]+\}\}/)
            });
        }

        // Fixed HTML entity decoding - handle the " -> "; issue properly
        processedContent = processedContent
            .replace(/&#34;/g, '"')  // Numeric &#34; -> "
            .replace(/'/g, "'")  // Numeric ' -> '
            .replace(/&/g, '&') // & -> &
            .replace(/</g, '<')  // < -> <
            .replace(/>/g, '>')  // > -> >
            .replace(/"/g, '"')  // Standard " -> "
            .replace(/'/g, "'") // Standard ' -> '
            .replace(/&quot/g, '"')   // Partial " (without semicolon) -> "
            .replace(/&apos/g, "'"); // Partial &apos (without semicolon) -> '

        // Fix the specific issue: if we have " that became ";", change back
        processedContent = processedContent
            .replace(/";/g, '"')  // Fix back from "; to "
            .replace(/&quot/g, '"')     // Now replace &quot with "
            .replace(/";/g, '"');     // Handle any remaining "; -> "

        // Debug: Log processed content
        if (content.includes('media url')) {
            logger.debug('Processed content sample', {
                sample: processedContent.substring(0, 300),
                hasMediaUrl: processedContent.includes('media url'),
                hasQuotEntity: processedContent.includes('"'),
                hasRegularQuot: processedContent.includes('"'),
                processedSample: processedContent.match(/\{\{media url[^}]+\}\}/)
            });
        }

        const apiBaseUrl = 'https://api.drakesterling.com/api/ecommerce/file-manager/stream/mg-blog-images/';
        
        // Try multiple patterns to catch all variations
        const patterns = [
            /\{\{media url=["'"]([^"'"}]+)["'"]\}\}/g,
            /\{\{media url=["'"]([^}]+)["'"]\}\}/g,
            /\{\{media url=["'"]([^"']+)["'"]\}\}/g,
            /\{\{media url=["'"](.*?)["'"]\}\}/g
        ];
        
        let result = processedContent;
        let totalMatches = 0;
        
        patterns.forEach((pattern, index) => {
            const matches = result.match(pattern);
            if (matches) {
                totalMatches += matches.length;
                logger.debug(`Pattern ${index + 1} found ${matches.length} matches`, {
                    examples: matches.slice(0, 2)
                });
                
                result = result.replace(pattern, (match, mediaPath) => {
                    // Clean path and create new URL
                    const filename = mediaPath
                        .replace(/^wysiwyg\//, '')
                        .replace(/^\/+/, '')
                        .trim();
                    const newUrl = apiBaseUrl + filename;
                    
                    logger.debug('Converting media URL', {
                        patternIndex: index + 1,
                        original: match,
                        path: mediaPath,
                        filename: filename,
                        newUrl: newUrl
                    });
                    
                    return newUrl;
                });
            }
        });

        // Log final summary
        if (processedContent.includes('media url') && totalMatches === 0) {
            logger.warn('Found media url text but no matches', {
                preview: processedContent.substring(0, 200),
                sampleMatch: processedContent.match(/\{\{media url[^}]+\}\}/)
            });
        }
        
        if (totalMatches > 0) {
            logger.info('Total media URL conversions', { count: totalMatches });
        }

        return result;
    }

    // Helper method to test the conversion logic
    testMediaUrlConversion(content) {
        let processed = content
            .replace(/"/g, '"')
            .replace(/&#34;/g, '"');

        const mediaUrlRegex = /\{\{media url=["'"]([^"'"}]+)["'"]\}\}/g;
        const apiBaseUrl = 'https://api.drakesterling.com/api/ecommerce/file-manager/stream/mg-blog-images/';

        return processed.replace(mediaUrlRegex, (match, mediaPath) => {
            const filename = mediaPath.replace(/^wysiwyg\//, '').trim();
            return apiBaseUrl + filename;
        });
    }
}

module.exports = UpdateContentUrlsStep;
