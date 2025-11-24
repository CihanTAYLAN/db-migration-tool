/*
# Update Category Parent Slugs Step

Updates parent_slugs field in category_translations table based on category hierarchy.
Recalculates parent slug chains after category slugs have been updated.
Only connects to target database.
*/

const logger = require('../../logger');

class UpdateCategoryParentSlugsStep {
    constructor(targetDb, config) {
        this.targetDb = targetDb;
        this.config = config;
    }

    async run() {
        logger.info('Starting update category parent slugs step');

        try {
            // Get all non-English language IDs
            const languages = await this.getTargetLanguages();
            
            if (languages.length === 0) {
                logger.info('No non-English languages found for parent slug updating');
                return { success: true, count: 0, updated: 0 };
            }

            let totalProcessed = 0;
            let totalUpdated = 0;

            // Process each language
            for (const language of languages) {
                const result = await this.updateParentSlugsForLanguage(language);
                totalProcessed += result.processed;
                totalUpdated += result.updated;
                logger.info(`Language ${language.code}: ${result.updated}/${result.processed} categories updated`);
            }

            logger.success(`Update category parent slugs step completed: ${totalUpdated}/${totalProcessed} total parent slugs updated`);

            return {
                success: true,
                count: totalProcessed,
                updated: totalUpdated
            };

        } catch (error) {
            logger.error('Update category parent slugs step failed', { error: error.message });
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
        logger.info(`Found ${languages.length} non-English target languages for parent slug updating: ${languages.map(l => l.code).join(', ')}`);
        
        return languages;
    }

    async updateParentSlugsForLanguage(language) {
        try {
            // Get all categories for this language with their current slugs
            const query = `
                SELECT 
                    c.id as category_id,
                    c.parent_id,
                    ct.slug,
                    ct.parent_slugs
                FROM categories c
                JOIN category_translations ct ON c.id = ct.category_id
                WHERE ct.language_id = $1
                ORDER BY c.id
            `;

            const categories = await this.targetDb.query(query, [language.id]);

            if (categories.length === 0) {
                logger.debug(`No categories found for language: ${language.code}`);
                return { processed: 0, updated: 0 };
            }

            logger.info(`Processing ${categories.length} categories for ${language.code}`);

            // Create a map for quick lookup
            const categoryMap = new Map();
            categories.forEach(cat => {
                categoryMap.set(cat.category_id, cat);
            });

            let processedCount = 0;
            let updatedCount = 0;

            // Process each category
            for (const category of categories) {
                try {
                    processedCount++;
                    
                    const newParentSlugs = this.calculateParentSlugs(category.category_id, categoryMap, language.id);
                    
                    // Update only if changed
                    if (newParentSlugs !== category.parent_slugs) {
                        await this.updateCategoryParentSlugs(category.category_id, language.id, newParentSlugs);
                        updatedCount++;
                        
                        // Log only a sample to avoid too much noise
                        if (updatedCount <= 5) {
                            logger.debug(`Updated parent slugs for category ${category.category_id}: "${category.parent_slugs || 'NULL'}" -> "${newParentSlugs || 'NULL'}"`);
                        }
                    }

                } catch (error) {
                    logger.warning(`Failed to update parent slugs for category ${category.category_id}`, {
                        error: error.message,
                        categoryId: category.category_id
                    });
                }
            }

            logger.info(`Language ${language.code}: ${updatedCount}/${processedCount} parent slugs updated`);

            return { processed: processedCount, updated: updatedCount };

        } catch (error) {
            logger.error(`Failed to update parent slugs for language ${language.code}`, {
                error: error.message
            });
            return { processed: 0, updated: 0 };
        }
    }

    calculateParentSlugs(categoryId, categoryMap, languageId) {
        const category = categoryMap.get(categoryId);
        if (!category || !category.parent_id) {
            return null; // No parent, return null
        }

        const slugChain = [];
        
        // Start with current category's slug
        if (category.slug) {
            slugChain.unshift(category.slug);
        }

        // Walk up the parent chain
        let currentParentId = category.parent_id;
        let safetyCounter = 0; // Prevent infinite loops
        const maxDepth = 50; // Reasonable maximum depth

        while (currentParentId && safetyCounter < maxDepth) {
            const parentCategory = categoryMap.get(currentParentId);
            if (!parentCategory || !parentCategory.slug) {
                break; // Parent not found or no slug
            }

            slugChain.unshift(parentCategory.slug);
            currentParentId = parentCategory.parent_id;
            safetyCounter++;
        }

        return slugChain.length > 0 ? slugChain.join('/') : null;
    }

    async updateCategoryParentSlugs(categoryId, languageId, parentSlugs) {
        const query = `
            UPDATE category_translations
            SET parent_slugs = $1, updated_at = NOW()
            WHERE category_id = $2 AND language_id = $3
        `;

        await this.targetDb.query(query, [parentSlugs, categoryId, languageId]);
    }
}

module.exports = UpdateCategoryParentSlugsStep;
