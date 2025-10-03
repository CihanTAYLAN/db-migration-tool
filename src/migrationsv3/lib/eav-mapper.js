/*
# EAV Attribute Mapper

Caches and manages EAV attribute IDs for efficient database queries.
*/

const logger = require('../../logger');

class EavMapper {
    constructor(sourceDb) {
        this.sourceDb = sourceDb;
        this.attributeCache = new Map();
    }

    async getAttributeId(attributeCode, entityType = 'catalog_category') {
        const cacheKey = `${entityType}:${attributeCode}`;

        // Check cache first
        if (this.attributeCache.has(cacheKey)) {
            return this.attributeCache.get(cacheKey);
        }

        try {
            const result = await this.sourceDb.query(
                'SELECT attribute_id FROM eav_attribute WHERE attribute_code = ? AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = ?)',
                [attributeCode, entityType]
            );

            const rows = this.sourceDb.dbType === 'postgresql' ? result.rows : result;
            const attributeId = rows && rows.length > 0 ? rows[0].attribute_id : null;

            // Cache the result
            this.attributeCache.set(cacheKey, attributeId);

            if (!attributeId) {
                logger.warn(`Attribute ID not found for ${attributeCode} in ${entityType}`);
            }

            return attributeId;
        } catch (error) {
            logger.error(`Failed to get attribute ID for ${attributeCode}`, { error: error.message });
            return null;
        }
    }

    async getMultipleAttributeIds(attributes, entityType = 'catalog_category') {
        const results = {};

        for (const attributeCode of attributes) {
            results[attributeCode] = await this.getAttributeId(attributeCode, entityType);
        }

        return results;
    }

    async preloadAttributes(entityTypes = ['catalog_category', 'catalog_product']) {
        logger.info('Preloading EAV attribute IDs...');

        const config = require('../config/migration-config');

        for (const entityType of entityTypes) {
            if (config.eavAttributes[entityType]) {
                logger.info(`Loading attributes for ${entityType}...`);
                await this.getMultipleAttributeIds(config.eavAttributes[entityType], entityType);
            }
        }

        logger.info(`Preloaded ${this.attributeCache.size} attribute IDs`);
    }

    getCacheStats() {
        return {
            totalCached: this.attributeCache.size,
            cache: Array.from(this.attributeCache.entries()).map(([key, value]) => ({
                key,
                value
            }))
        };
    }

    clearCache() {
        this.attributeCache.clear();
        logger.info('EAV attribute cache cleared');
    }
}

module.exports = EavMapper;
