/*
# Data Transformer Library

Handles data format conversions and transformations for migration.
*/

const { v4: uuidv4 } = require('uuid');
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

        // Country mapping from source to target
        this.countryMapping = {
            'Australia': 'AU',
            'Great Britain': 'GB',
            'Canada': 'CA',
            'United States of America': 'US',
            'United States': 'US',
            'United Kingdom': 'GB',
            'Fiji': 'FJ',
            'Germany': 'DE',
            'South Africa': 'ZA',
            'Mexico': 'MX',
            'India': 'IN',
            'Netherlands': 'NL',
            'New Zealand': 'NZ',
            'Isle of Man': 'IM',
            'Saudi Arabia': 'SA'
        };
    }

    // Category transformations
    transformCategory(sourceCategory, defaultLanguageId) {
        const categoryId = uuidv4();
        const code = sourceCategory.url_key
            ? `${sourceCategory.url_key}_${sourceCategory.entity_id}`
            : `category-${sourceCategory.entity_id}`;

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

    // Product transformations
    async transformProduct(sourceProduct) {
        const productId = uuidv4();
        const timestamp = Math.floor(new Date(sourceProduct.created_at) / 1000);
        const productWebSku = sourceProduct.product_sku + '-' + timestamp.toString(36);

        // Map country to country_id
        let countryId = null;
        if (sourceProduct.country_value) {
            const isoCode = this.countryMapping[sourceProduct.country_value];
            if (isoCode) {
                // This will be resolved later in the migration step
                countryId = isoCode; // Store ISO code temporarily, will be replaced with actual ID
            }
        }

        // Map certification_type to certificate_provider_id (dynamically from target DB)
        let certificateProviderId = null;
        if (sourceProduct.certification_type) {
            const certType = String(sourceProduct.certification_type).trim();

            // If targetDb available, dynamically resolve from target database
            if (this.targetDb && typeof this.targetDb.query === 'function') {
                try {
                    // Map of certification_type to provider name suffix
                    const typeToNameMap = {
                        '4': 'PCGS',
                        '5': 'NGC',
                        '262': 'PMG',
                        '6': 'Other'
                    };

                    const providerName = typeToNameMap[certType];
                    if (providerName) {
                        // Query certificate provider by name from target database
                        const providers = await this.targetDb.query(
                            'SELECT id FROM certificate_providers WHERE name = $1',
                            [providerName]
                        );
                        if (providers && providers.length > 0) {
                            certificateProviderId = providers[0].id;
                            logger.debug(`Resolved certificate provider ${providerName}: ${certificateProviderId}`);
                        } else {
                            logger.debug(`Certificate provider ${providerName} not found in target DB`);
                        }
                    }
                } catch (error) {
                    logger.warning(`Failed to resolve certificate provider for type ${certType}`, { error: error.message });
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
            coin_grade_prefix: sourceProduct.grade_prefix || null,
            coin_grade_suffix: sourceProduct.grade_suffix || null,
            coin_grade: sourceProduct.grade_value || null,
            coin_grade_text: this.buildGradeText(sourceProduct),
            year_text: sourceProduct.year || null,
            coin_grade_prefix_type: sourceProduct.grade_prefix || null,
            year_date: sourceProduct.year && !isNaN(parseInt(sourceProduct.year))
                ? new Date(parseInt(sourceProduct.year), 0, 1)
                : null,
            is_second_hand: false,
            is_consignment: false,
            is_active: true,
            is_on_hold: false,
            status: this.determineProductStatus(sourceProduct),
            quantity: 1,
            price: parseFloat(sourceProduct.price) || 0,
            sold_date: sourceProduct.sold_date || null,
            archived_at: this.calculateArchivedAt(sourceProduct),
            sold_price: sourceProduct.last_sold_price || null,
            discount_price: null,
            ebay_offer_code: null,
            stars: 0,
            created_at: sourceProduct.created_at,
            updated_at: sourceProduct.updated_at,
            deleted_at: null,
            product_master_image_id: null,
            certificate_provider_id: certificateProviderId,
            master_category_id: null, // Will be set later
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

        // Secondary source: if not archived and has sold_date, then 'sold'
        if (product.sold_date) {
            return 'sold';
        }

        // Default: pending
        return 'pending';
    }

    calculateArchivedAt(product) {
        // Only calculate archived_at if product is archived (archived_status = 1)
        // and has a sold_date
        if (product.archived_status === 1 && product.sold_date) {
            const soldDate = new Date(product.sold_date);
            const archivedDate = new Date(soldDate.getTime() + (21 * 24 * 60 * 60 * 1000)); // 21 days
            return archivedDate;
        }
        return null;
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
