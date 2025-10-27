/*
# Prepare Step

Handles initial setup: EAV attribute IDs loading and language setup.
*/

const logger = require('../../logger');
const EavMapper = require('../lib/eav-mapper');

class PrepareStep {
    constructor(sourceDb, targetDb, config) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = new EavMapper(sourceDb);
    }

    async run() {
        logger.info('Starting prepare step...');

        try {
            // 1. Preload EAV attribute IDs
            await this.preloadEavAttributes();

            // 2. Ensure default language exists
            const defaultLanguageId = await this.ensureDefaultLanguage();

            // 3. Ensure countries exist (NEW)
            await this.ensureCountries();

            // 4. Validate database connections
            await this.validateConnections();

            logger.success('Prepare step completed successfully');

            return {
                success: true,
                eavMapper: this.eavMapper,
                defaultLanguageId: defaultLanguageId
            };

        } catch (error) {
            logger.error('Prepare step failed', { error: error.message });
            throw error;
        }
    }

    async preloadEavAttributes() {
        logger.info('Preloading EAV attribute IDs...');

        const entityTypes = Object.keys(this.config.eavAttributes);

        for (const entityType of entityTypes) {
            const attributes = this.config.eavAttributes[entityType];
            logger.info(`Loading ${attributes.length} attributes for ${entityType}...`);

            const attributeIds = await this.eavMapper.getMultipleAttributeIds(attributes, entityType);

            // Check for missing attributes
            const missingAttributes = attributes.filter(attr => !attributeIds[attr]);
            if (missingAttributes.length > 0) {
                logger.warn(`Missing attributes for ${entityType}: ${missingAttributes.join(', ')}`);
            }

            const loadedCount = attributes.length - missingAttributes.length;
            logger.info(`Loaded ${loadedCount}/${attributes.length} attributes for ${entityType}`);
        }

        const cacheStats = this.eavMapper.getCacheStats();
        logger.info(`EAV attribute cache: ${cacheStats.totalCached} attributes cached`);
    }

    async ensureDefaultLanguage() {
        logger.info('Ensuring default language exists...');

        const languages = await this.targetDb.query('SELECT id FROM languages WHERE code = $1', ['en']);

        if (!languages || languages.length === 0) {
            logger.info('Creating default English language...');

            const { v4: uuidv4 } = require('uuid');
            const languageId = uuidv4();

            await this.targetDb.query(
                'INSERT INTO languages (id, code, name, created_at, updated_at) VALUES ($1, $2, $3, NOW(), NOW())',
                [languageId, 'en', 'English']
            );

            logger.success('Created default English language');
            return languageId;
        }

        logger.info('Default English language already exists');
        return languages[0].id;
    }

    async ensureCountries() {
        logger.info('Ensuring countries exist in target database...');

        try {
            // Load countries data from JSON file
            const fs = require('fs');
            const path = require('path');
            const countriesData = JSON.parse(fs.readFileSync(path.join(__dirname, '../config/countries-data.json'), 'utf8'));

            logger.info(`Loaded ${countriesData.countries.length} countries from JSON data`);

            // Get existing countries in target
            const existingCountries = await this.targetDb.query('SELECT id, name, iso_code_2 FROM countries');
            const existingCountryMap = new Map(existingCountries.map(c => [c.name, c.id]));

            logger.info(`Found ${existingCountries.length} countries in target database`);

            // Find missing countries
            const missingCountries = countriesData.countries.filter(country => !existingCountryMap.has(country.name));

            if (missingCountries.length === 0) {
                logger.info('All countries from JSON data already exist in target database');
                return;
            }

            logger.info(`Found ${missingCountries.length} missing countries to create`);

            // Create missing countries with proper ISO codes
            const { v4: uuidv4 } = require('uuid');
            let createdCount = 0;

            for (const country of missingCountries) {
                const countryId = uuidv4();

                try {
                    await this.targetDb.query(`
                        INSERT INTO countries (id, name, iso_code_2, iso_code_3, postal_code_format, postal_code_regex, is_active)
                        VALUES ($1, $2, $3, $4, $5, $6, $7)
                    `, [
                        countryId,
                        country.name,
                        country.iso2,
                        country.iso3,
                        'XXXXX', // Default postal code format
                        '.*', // Default postal code regex (matches anything)
                        true  // is_active
                    ]);

                    createdCount++;
                    logger.debug(`Created country: ${country.name} (${country.iso2})`);
                } catch (error) {
                    logger.warn(`Failed to create country ${country.name}: ${error.message}`);
                }
            }

            logger.success(`Countries ensured: ${createdCount} new countries created from JSON data`);

        } catch (error) {
            logger.error('Failed to ensure countries', { error: error.message });
            throw error;
        }
    }

    async validateConnections() {
        logger.info('Validating database connections...');

        try {
            // Test source connection
            await this.sourceDb.query('SELECT 1 as test');
            logger.info('Source database connection validated');

            // Test target connection
            await this.targetDb.query('SELECT 1 as test');
            logger.info('Target database connection validated');

        } catch (error) {
            logger.error('Database connection validation failed', { error: error.message });
            throw error;
        }
    }

    getResults() {
        return {
            eavMapper: this.eavMapper,
            cacheStats: this.eavMapper.getCacheStats()
        };
    }
}

module.exports = PrepareStep;
