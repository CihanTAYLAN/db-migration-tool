/*
# Data Transformer Library

Handles data format conversions and transformations for migration.
*/

const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');
const logger = require('../../logger');

class DataTransformer {
    constructor(targetDb = null) {
        this.targetDb = targetDb;
        // NGC grading scale mapping
        this.ngcScaleMapping = {
            70: 10, 69: 9.9, 68: 9.8, 67: 9.7, 66: 9.6, 65: 9.5,
            64: 9.4, 63: 9.3, 62: 9.2, 61: 9.1, 60: 9,
            58: 8.8, 55: 8.5, 53: 8.3, 50: 8, 45: 7.5, 40: 7,
            35: 6.5, 30: 6, 25: 5.5, 20: 5, 15: 4.5, 12: 4,
            10: 3.5, 8: 3, 6: 2.5, 4: 2, 3: 1.5, 2: 1.5, 1: 1
        };

        // Country mapping from source to target - loaded from countries-data.json
        this.countryMapping = this.loadCountryMapping();

        // Cache for certificate provider lookups (providerName -> providerId)
        this.certificateProviderCache = new Map();

        // Cache for language lookups (languageCode -> languageId)
        this.languageCache = new Map();
    }

    // Category transformations
    transformCategory(sourceCategory, defaultLanguageId) {
        const categoryId = uuidv4();

        // Include parent_id in code to handle duplicate category names under different parents
        // Format: url_key_parentId_entityId or category-parentId-entityId
        const code = sourceCategory.url_key
            ? `${sourceCategory.url_key}_${sourceCategory.parent_id}_${sourceCategory.entity_id}`
            : `category-${sourceCategory.parent_id}-${sourceCategory.entity_id}`;

        return {
            id: categoryId,
            code: code,
            sort: sourceCategory.position || 0,
            is_hidden: sourceCategory.is_active === 0 || sourceCategory.is_active === '0',
            created_at: new Date(),
            updated_at: new Date()
        };
    }

    transformCategoryTranslation(category, categoryId, languageId) {
        const slug = category.url_key || `category-${category.entity_id}`;

        return {
            id: uuidv4(),
            title: category.name,
            description: category.description,
            meta_title: category.meta_title,
            meta_description: category.meta_description,
            meta_keywords: category.meta_keywords,
            slug: slug,
            parent_slugs: null,
            category_id: categoryId,
            language_id: languageId,
            created_at: new Date(),
            updated_at: new Date()
        };
    }

    // Certificate provider cache resolver
    async resolveCertificateProvider(providerName) {
        if (this.certificateProviderCache.has(providerName)) {
            logger.debug(`Certificate provider ${providerName} found in cache: ${this.certificateProviderCache.get(providerName)}`);
            return this.certificateProviderCache.get(providerName);
        }

        if (!this.targetDb || typeof this.targetDb.query !== 'function') {
            logger.debug(`Certificate provider ${providerName}: targetDb not available for resolution`);
            return null;
        }

        try {
            const providers = await this.targetDb.query(
                'SELECT id FROM certificate_providers WHERE name = $1',
                [providerName]
            );

            if (providers && providers.length > 0) {
                const providerId = providers[0].id;
                this.certificateProviderCache.set(providerName, providerId);
                logger.debug(`Resolved and cached certificate provider ${providerName}: ${providerId}`);
                return providerId;
            } else {
                logger.debug(`Certificate provider ${providerName} not found in target DB`);
                this.certificateProviderCache.set(providerName, null); // Cache negative result
                return null;
            }
        } catch (error) {
            logger.warning(`Failed to resolve certificate provider ${providerName}`, { error: error.message });
            return null;
        }
    }

    // Language cache resolver
    async resolveLanguageId(languageCode) {
        if (this.languageCache.has(languageCode)) {
            return this.languageCache.get(languageCode);
        }

        if (!this.targetDb || typeof this.targetDb.query !== 'function') {
            return null;
        }

        try {
            const languages = await this.targetDb.query('SELECT id FROM languages WHERE code = $1', [languageCode]);
            if (languages.length > 0) {
                const languageId = languages[0].id;
                this.languageCache.set(languageCode, languageId);
                return languageId;
            }
        } catch (error) {
            logger.warning(`Failed to resolve language ${languageCode}`, { error: error.message });
        }

        return null;
    }

    // Product transformations
    async transformProduct(sourceProduct) {
        const productId = uuidv4();
        const timestamp = Math.floor(new Date(sourceProduct.created_at) / 1000);
        const productWebSku = sourceProduct.product_sku + '-' + timestamp.toString(36);

        // Map country to country_id - use country_int first, then country_value, then country_of_manufacture as fallback
        let countryId = null;

        // Prefer country_int (INT table) if available, otherwise country_value (flat), otherwise country_of_manufacture (EAV)
        const countrySource = sourceProduct.country_int || sourceProduct.country_value || sourceProduct.country_of_manufacture;

        if (countrySource) {
            // Trim whitespace and handle empty/null values
            const trimmedSource = String(countrySource).trim();

            // Handle Magento's "None" values as null
            if (trimmedSource &&
                trimmedSource !== 'NULL' &&
                trimmedSource !== 'null' &&
                trimmedSource !== 'None' &&
                trimmedSource !== 'none' &&
                trimmedSource !== '') {

                // If it's already an ISO code (AU, US, etc.), use it directly
                if (trimmedSource.length === 2) {
                    countryId = trimmedSource.toUpperCase();
                } else if (trimmedSource.length === 3) {
                    // Handle 3-letter ISO codes by looking up in mapping
                    const isoMapping = {
                        'AUS': 'AU', 'GBR': 'GB', 'CAN': 'CA', 'USA': 'US',
                        'DEU': 'DE', 'ZAF': 'ZA', 'MEX': 'MX', 'IND': 'IN',
                        'NLD': 'NL', 'NZL': 'NZ', 'SAU': 'SA', 'FJI': 'FJ'
                    };
                    countryId = isoMapping[trimmedSource];
                } else {
                    // Try to map from country name
                    const isoCode = this.countryMapping[trimmedSource];
                    if (isoCode) {
                        countryId = isoCode;
                    }
                }

                if (countryId) {
                    logger.debug(`Mapped country for product ${sourceProduct.product_sku}: "${trimmedSource}" -> "${countryId}"`);
                } else {
                    logger.debug(`Failed to map country for product ${sourceProduct.product_sku}: "${trimmedSource}" - no mapping found`);
                }
            } else {
                // "None", "null", empty string treated as no country
                logger.debug(`Product ${sourceProduct.product_sku} has invalid country_value: "${trimmedSource}" - treated as null`);
            }
        } else {
            // No country_value means country is null
            logger.debug(`No country_value for product ${sourceProduct.product_sku} - country remains null`);
        }

        // Map certification_type to certificate_provider_id with caching
        // If no certification_type but has certification_number, default to PCGS
        let certificateProviderId = null;

        // First, try certification_type mapping
        if (sourceProduct.certification_type) {
            const certType = String(sourceProduct.certification_type).trim();

            try {
                // Map of certification_type to provider name
                const typeToNameMap = {
                    '4': 'PCGS',
                    '5': 'NGC',
                    '262': 'PMG',
                    '6': 'Other'
                };

                const providerName = typeToNameMap[certType];
                if (providerName) {
                    certificateProviderId = await this.resolveCertificateProvider(providerName);
                    logger.debug(`Resolved certificate provider for certType ${certType} (${providerName}): ${certificateProviderId} for product ${sourceProduct.product_sku}`);
                } else {
                    // Unknown certification_type: use Uncertified instead of default
                    certificateProviderId = await this.resolveCertificateProvider('Uncertified');
                    logger.debug(`Unknown certification_type ${certType}, applied Uncertified for product ${sourceProduct.product_sku}: ${certificateProviderId}`);
                }
            } catch (error) {
                logger.warning(`Failed to resolve certificate provider for type ${certType}`, { error: error.message, product: sourceProduct.product_sku });
            }
        }

        // Fallback: If no certification_type but has certification_number, use Uncertified
        // (having a certification number but unknown provider)
        if (!certificateProviderId && sourceProduct.certification_number && sourceProduct.certification_number.trim()) {
            try {
                certificateProviderId = await this.resolveCertificateProvider('Uncertified');
                logger.debug(`Applied Uncertified for certification_number ${sourceProduct.certification_number}: ${certificateProviderId} for product ${sourceProduct.product_sku}`);
            } catch (error) {
                logger.warning(`Failed to apply Uncertified for certification_number ${sourceProduct.certification_number}`, { error: error.message, product: sourceProduct.product_sku });
            }
        }

        if (!certificateProviderId) {
            logger.debug(`No certificate provider set for product ${sourceProduct.product_sku} (cert_type: ${sourceProduct.certification_type}, cert_num: ${sourceProduct.certification_number})`);
        }

        // Parse grade from meta_title if EAV fields are empty
        let gradePrefix = sourceProduct.grade_prefix || null;
        let gradeSuffix = sourceProduct.grade_suffix || null;

        if ((!gradePrefix || gradePrefix.trim() === '') && sourceProduct.meta_title) {
            const parsedGrade = this.parseGradeFromMetaTitle(sourceProduct.meta_title);
            if (parsedGrade) {
                gradePrefix = parsedGrade.prefix || gradePrefix;
                gradeSuffix = parsedGrade.suffix || gradeSuffix;
                // Update grade_value if also empty and parsed
                if (!sourceProduct.grade_value && parsedGrade.value) {
                    sourceProduct.grade_value = parsedGrade.value;
                }
            }
        }

        return {
            id: productId,
            product_identity: `${sourceProduct.product_sku}-${sourceProduct.entity_id}`,
            product_sku: sourceProduct.product_sku,
            product_web_sku: productWebSku,
            cert_number: sourceProduct.certification_number || null,
            coin_video: null,
            is_coin_video: false,
            coin_number: sourceProduct.coin_number || null,
            coin_our_grade: this.convertTo10PointScale(sourceProduct.grade_value),
            coin_grade_type: sourceProduct.grade_value ? parseInt(sourceProduct.grade_value).toString() : null,
            coin_grade_prefix: gradePrefix,
            coin_grade_suffix: gradeSuffix,
            coin_grade: sourceProduct.grade_value || null,
            coin_grade_text: this.buildGradeText({ grade_prefix: gradePrefix, grade_value: sourceProduct.grade_value, grade_suffix: gradeSuffix }),
            year_text: this.parseValidYear(sourceProduct.year, sourceProduct.sort_string, sourceProduct.name),
            coin_grade_prefix_type: gradePrefix,
            year_date: this.parseValidYearDate(sourceProduct.year, sourceProduct.sort_string, sourceProduct.name),
            is_second_hand: false,
            is_consignment: false,
            // Determine is_active from source status and visibility attributes - MAGENTO RULES:
            // status=1 (Enabled) AND visibility=2 (Catalog) OR 4 (Catalog, Search) = ACTIVE
            // status=2 (Disabled) OR visibility=1 (Not Visible Individually) = INACTIVE
            is_active: (
                sourceProduct.status !== null &&
                sourceProduct.status !== undefined &&
                String(sourceProduct.status) === '1' &&
                sourceProduct.visibility !== null &&
                sourceProduct.visibility !== undefined &&
                (String(sourceProduct.visibility) === '2' || String(sourceProduct.visibility) === '4')
            ),
            is_on_hold: false,
            status: this.determineProductStatus(sourceProduct),
            quantity: 1,
            price: parseFloat(sourceProduct.price) || 0,
            sold_date: sourceProduct.eav_sold_date || sourceProduct.sold_date || null,
            archived_at: this.calculateArchivedAt(sourceProduct),
            sold_price: sourceProduct.eav_sold_price || sourceProduct.last_sold_price || null,
            discount_price: null,
            ebay_offer_code: null,
            stars: 0,
            created_at: sourceProduct.created_at,
            updated_at: sourceProduct.updated_at,
            deleted_at: null,
            product_master_image_id: null,
            certificate_provider_id: certificateProviderId,
            master_category_id: null, // Will be set later
            xero_account_id: null,
            xero_tenant_id: null,
            country_id: countryId
        };
    }

    transformProductTranslation(product, productWebSku, languageId) {
        const title = product.name || product.product_sku;
        const slug = product.url_key || title.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

        // Transform description for target format
        let description = product.description;
        if (description && description.trim()) {
            description = `<div class=\"tiptap-summary\"><p><span style=\"color: rgb(0, 0, 0)\">${description.replace(/"/g, '"')}</span></p></div>`;
        }

        return {
            id: uuidv4(),
            title: title,
            description: description,
            short_description: product.short_description,
            slug: slug,
            meta_title: product.meta_title || null,
            meta_description: product.meta_description || null,
            meta_keywords: null,
            product_id: productWebSku, // Use product_web_sku instead of UUID
            language_id: languageId,
            created_at: product.created_at,
            updated_at: product.updated_at
        };
    }

    // Helper methods
    convertTo10PointScale(grade70) {
        if (!grade70) return null;

        const gradeFloat = parseFloat(grade70);
        if (this.ngcScaleMapping[gradeFloat]) {
            return this.ngcScaleMapping[gradeFloat];
        }

        // Find closest grade
        const allowedValues = Object.keys(this.ngcScaleMapping).map(Number);
        const closestGrade = allowedValues.reduce((prev, curr) =>
            Math.abs(curr - gradeFloat) < Math.abs(prev - gradeFloat) ? curr : prev
        );

        return this.ngcScaleMapping[closestGrade];
    }

    parseGradeFromMetaTitle(metaTitle) {
        if (!metaTitle || typeof metaTitle !== 'string') return null;

        // Match PCGS/NGC/AU... grading service patterns: Service PrefixValueSuffix
        // Example: "PCGS XF45BN" → prefix: 'XF', value: 45, suffix: 'BN'
        const pcgsMatch = metaTitle.match(/PCGS\s+([A-Z]+)(\d+)([A-Z]+)?/);
        if (pcgsMatch) {
            return {
                prefix: pcgsMatch[1] || null,
                value: pcgsMatch[2] ? parseInt(pcgsMatch[2]) : null,
                suffix: pcgsMatch[3] || null
            };
        }

        const ngcMatch = metaTitle.match(/NGC\s+([A-Z]+)(\d+)([A-Z]+)?/);
        if (ngcMatch) {
            return {
                prefix: ngcMatch[1] || null,
                value: ngcMatch[2] ? parseInt(ngcMatch[2]) : null,
                suffix: ngcMatch[3] || null
            };
        }

        const anacsMatch = metaTitle.match(/ANACS\s+([A-Z]+)(\d+)([A-Z]+)?/);
        if (anacsMatch) {
            return {
                prefix: anacsMatch[1] || null,
                value: anacsMatch[2] ? parseInt(anacsMatch[2]) : null,
                suffix: anacsMatch[3] || null
            };
        }

        return null;
    }

    buildGradeText(product) {
        let text = '';
        if (product.grade_prefix) text += product.grade_prefix;
        if (product.grade_value) text += parseInt(product.grade_value).toString();
        if (product.grade_suffix) text += product.grade_suffix;

        return text.trim() || null;
    }

    determineProductStatus(product) {
        // Primary source: archived_status from source
        if (product.archived_status !== null && product.archived_status !== undefined) {
            const archivedStatus = parseInt(product.archived_status);
            if (archivedStatus === 1) {
                return 'archived';
            }
        }

        // Secondary source: if not archived and has sold_date (EAV or sales order), then 'sold'
        if (product.eav_sold_date || product.sold_date) {
            return 'sold';
        }

        // Default: pending
        return 'pending';
    }

    calculateArchivedAt(product) {
        // Only calculate archived_at if product is archived (archived_status = 1)
        // and has a sold_date (EAV sold_on takes priority)
        const soldDateValue = product.eav_sold_date || product.sold_date;
        if (product.archived_status === 1 && soldDateValue) {
            const soldDate = new Date(soldDateValue);
            const archivedDate = new Date(soldDate.getTime() + (21 * 24 * 60 * 60 * 1000)); // 21 days
            return archivedDate;
        }
        return null;
    }

    parseValidYear(yearValue, sortString, productName) {
        // Primary: Use year field if valid
        const yearString = this.extractYearFromString(yearValue);
        if (yearString) return yearString;

        // Fallback 1: Extract from sort_string (97.9% success rate)
        const sortYear = this.extractYearFromString(sortString);
        if (sortYear) return sortYear;

        // Fallback 2: Extract from product name
        const nameYear = this.extractYearFromString(productName);
        if (nameYear) return nameYear;

        return null;
    }

    parseValidYearDate(yearValue, sortString, productName) {
        // Use same fallback logic as parseValidYear, but return Date object
        const yearString = this.parseValidYear(yearValue, sortString, productName);
        if (yearString && !isNaN(parseInt(yearString))) {
            const year = parseInt(yearString);
            if (year >= 1000 && year <= 2100) {
                return new Date(year, 0, 1); // January 1st of the year
            }
        }
        return null;
    }

    extractYearFromString(input) {
        if (!input) return null;

        const inputString = String(input).trim();

        // Common invalid values in Magento
        const invalidValues = ['none', 'None', 'NONE', '', 'null', 'NULL', '0', '(199'];
        if (invalidValues.includes(inputString) || inputString.length < 4) return null;

        // Try exact 4-digit match first
        const exactMatch = inputString.match(/^(\d{4})/);
        if (exactMatch) {
            const year = parseInt(exactMatch[1]);
            if (year >= 1000 && year <= 2100) {
                return String(year);
            }
        }

        // Try to find any 4 consecutive digits
        const fourDigitMatch = inputString.match(/\b(\d{4})\b/);
        if (fourDigitMatch) {
            const year = parseInt(fourDigitMatch[1]);
            if (year >= 1000 && year <= 2100) {
                return String(year);
            }
        }

        return null;
    }

    loadCountryMapping() {
        try {
            const countriesFilePath = path.join(__dirname, '../config/countries-data.json');
            const countriesData = fs.readFileSync(countriesFilePath, 'utf8');
            const data = JSON.parse(countriesData);

            // Handle both direct array format and object with countries array
            let countries;
            if (Array.isArray(data)) {
                countries = data;
            } else if (data && Array.isArray(data.countries)) {
                countries = data.countries;
            } else {
                logger.error('countries-data.json does not contain a countries array');
                throw new Error('Invalid countries data format');
            }

            // Create name -> iso2 mapping
            const countryMapping = {};
            for (const country of countries) {
                if (country && country.name && country.iso2) {
                    countryMapping[country.name] = country.iso2;
                }
            }

            // Handle common variations not in the JSON
            // These are based on existing hard-coded mappings
            countryMapping['United States'] = 'US'; // JSON only has "United States of America"

            logger.debug(`Loaded ${Object.keys(countryMapping).length} countries from countries-data.json`);
            return countryMapping;
        } catch (error) {
            logger.error('Failed to load country mapping from countries-data.json', { error: error.message });
            // Fallback to minimal mapping
            return {
                'Australia': 'AU',
                'Canada': 'CA',
                'United States': 'US',
                'United Kingdom': 'GB',
                'Germany': 'DE',
                'France': 'FR'
            };
        }
    }

    // Batch transformation methods
    transformCategories(categories, defaultLanguageId) {
        const transformedCategories = [];
        const transformedTranslations = [];

        for (const category of categories) {
            const transformedCategory = this.transformCategory(category, defaultLanguageId);
            const transformedTranslation = this.transformCategoryTranslation(category, transformedCategory.id, defaultLanguageId);

            transformedCategories.push(transformedCategory);
            transformedTranslations.push(transformedTranslation);
        }

        return { categories: transformedCategories, translations: transformedTranslations };
    }

    async transformProducts(products, defaultLanguageId) {
        if (!Array.isArray(products)) {
            throw new Error('products parameter must be an array');
        }

        const transformedProducts = [];
        const transformedTranslations = [];

        for (const product of products) {
            const transformedProduct = await this.transformProduct(product);
            const transformedTranslation = this.transformProductTranslation(product, transformedProduct.product_web_sku, defaultLanguageId);

            transformedProducts.push(transformedProduct);
            transformedTranslations.push(transformedTranslation);
        }

        return { products: transformedProducts, translations: transformedTranslations };
    }
}

module.exports = DataTransformer;
