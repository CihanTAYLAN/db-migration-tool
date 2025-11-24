/*
# Migration V3 - Main Orchestrator

Step-by-step migration system with improved architecture.
*/

const { DbClient } = require('../db');
const logger = require('../logger');
const config = require('./config/migration-config');

// Import steps
const PrepareStep = require('./steps/prepare');
const BlogPostsStep = require('./steps/blog-posts');
const UpdateBlogDescriptionsStep = require('./steps/update-blog-descriptions');
const CategoriesStep = require('./steps/categories');
const ProductsStep = require('./steps/products');
const MergeStep = require('./steps/merge-subcategories');
const CertCoinCategoriesStep = require('./steps/cert-coin-categories');
const UpdateMasterCategoryIdsStep = require('./steps/update-master-category-ids');
const CustomersStep = require('./steps/customers');
const OrdersStep = require('./steps/orders');
const TranslationStep = require('./steps/translation');
const DeduplicateProductTranslationsStep = require('./steps/deduplicate-product-translations');
const UpdateProductsStep = require('./steps/update-products');
const FixContentUrlsStep = require('./steps/fix-content-urls');
const FixJapaneseSlugsStep = require('./steps/fix-japanese-slugs');
const FixGermanSlugsStep = require('./steps/fix-german-slugs');
const ContentTranslationStep = require('./steps/content-translation');

class MigrationV3 {
    constructor(sourceUrl, sourceType, targetUrl, targetType, domain = 'https://drakesterling.online') {
        this.sourceUrl = sourceUrl;
        this.sourceType = sourceType;
        this.targetUrl = targetUrl;
        this.targetType = targetType;
        this.domain = domain;
        this.sourceDb = null;
        this.targetDb = null;
        this.context = {}; // Shared context between steps
    }

    async connectDatabases() {
        logger.info('Connecting to databases...');
        this.sourceDb = new DbClient(this.sourceUrl, this.sourceType);
        this.targetDb = new DbClient(this.targetUrl, this.targetType);
        await this.sourceDb.connect();
        await this.targetDb.connect();
        logger.success('Databases connected successfully');
    }

    async connectSourceDatabase() {
        if (!this.sourceDb) {
            logger.info('Connecting to source database...');
            this.sourceDb = new DbClient(this.sourceUrl, this.sourceType);
            await this.sourceDb.connect();
            logger.success('Source database connected successfully');
        }
    }

    async connectTargetDatabase() {
        if (!this.targetDb) {
            logger.info('Connecting to target database...');
            this.targetDb = new DbClient(this.targetUrl, this.targetType);
            await this.targetDb.connect();
            logger.success('Target database connected successfully');
        }
    }

    async connectRequiredDatabases(stepName) {
        const stepConfig = config.steps[stepName];
        if (!stepConfig) {
            throw new Error(`Unknown step: ${stepName}`);
        }

        if (stepConfig.requiresSource) {
            await this.connectSourceDatabase();
        }

        if (stepConfig.requiresTarget) {
            await this.connectTargetDatabase();
        }
    }

    async disconnectDatabases() {
        logger.info('Disconnecting from databases...');
        if (this.sourceDb) await this.sourceDb.close();
        if (this.targetDb) await this.targetDb.close();
        logger.success('Databases disconnected');
    }

    async run() {
        const startTime = Date.now();

        try {
            logger.info('🚀 Starting Migration V3...');
            await this.connectDatabases();

            // Execute steps in order
            const results = {};

            // Step 1: Prepare
            // EAV attributes preload + default language setup + database validation
            if (config.steps.prepare.enabled) {
                logger.info('📋 Step 1: Prepare');
                const prepareStep = new PrepareStep(this.sourceDb, this.targetDb, config);
                results.prepare = await prepareStep.run();

                // Store context for next steps
                this.context.eavMapper = results.prepare.eavMapper;
                this.context.defaultLanguageId = results.prepare.defaultLanguageId;
            }

            // Step 2: Blog Posts
            // Migrate blog posts from Mageplaza Blog module
            if (config.steps.blog_posts.enabled) {
                logger.info('📝 Step 2: Blog Posts');
                const blogPostsStep = new BlogPostsStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.defaultLanguageId
                );
                results.blog_posts = await blogPostsStep.run();
            }

            // Step 2.1: Update Blog Descriptions
            // Update content_translations description field from blog posts
            if (config.steps.updateBlogDescriptions.enabled) {
                logger.info('📝 Step 2.1: Update Blog Descriptions');
                const updateBlogDescriptionsStep = new UpdateBlogDescriptionsStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.defaultLanguageId,
                    this.domain
                );
                results.updateBlogDescriptions = await updateBlogDescriptionsStep.run();
            }

            // Step 3: Categories
            // Migrate all categories from catalog_category_flat_store_1
            if (config.steps.categories.enabled) {
                logger.info('📂 Step 3: Categories');
                const categoriesStep = new CategoriesStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.categories = await categoriesStep.run();
            }

            // Step 4: Products
            // Migrate products + translations + prices + images + certificate badges + master_category_id update
            if (config.steps.products.enabled) {
                logger.info('📦 Step 4: Products');
                const productsStep = new ProductsStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.products = await productsStep.run();
            }

            // Step 5: Merge
            // Merge duplicate subcategories based on URL key prefixes + calculate parent slugs
            if (config.steps.merge.enabled) {
                logger.info('🔗 Step 5: Merge Subcategories');
                const mergeStep = new MergeStep(this.targetDb, this.context.defaultLanguageId);
                results.merge = await mergeStep.run();
            }

            // Step 6: Cert Coin Categories
            // Map coins to certification categories from CSV data based on cert-number and coin-number
            if (config.steps.certCoinCategories.enabled) {
                logger.info('🏆 Step 6: Cert Coin Categories');
                const certCoinCategoriesStep = new CertCoinCategoriesStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.certCoinCategories = await certCoinCategoriesStep.run();
            }

            // Step 7: Update Master Category IDs
            // Fix master_category_id NULL fields after category assignments
            if (config.steps.updateMasterCategoryIds.enabled) {
                logger.info('📂 Step 7: Update Master Category IDs');
                const updateMasterCategoryIdsStep = new UpdateMasterCategoryIdsStep(this.targetDb, this.context.defaultLanguageId);
                results.updateMasterCategoryIds = await updateMasterCategoryIdsStep.run();
            }

            // Step 8: Customers
            // Migrate customers and addresses with tree structure relationships
            if (config.steps.customers.enabled) {
                logger.info('👥 Step 8: Customers');
                const customersStep = new CustomersStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.customers = await customersStep.run();
            }

            // Step 9: Orders
            // Migrate orders + order items + shipping/billing addresses in tree structure
            if (config.steps.orders.enabled) {
                logger.info('📋 Step 9: Orders');
                const ordersStep = new OrdersStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.orders = await ordersStep.run();
            }

            // Step 10: Translation
            // Batch translation of all categories and products to all supported languages
            if (config.steps.translation.enabled) {
                logger.info('🌐 Step 10: Translation');
                const translationStep = new TranslationStep(this.targetDb, config, this.context.defaultLanguageId);
                results.translation = await translationStep.run();
            }

            // Step 11: Deduplicate Product Translations
            // Remove duplicate slugs with same language_id by appending random suffix
            if (config.steps.deduplicateProductTranslations.enabled) {
                logger.info('🔄 Step 11: Deduplicate Product Translations');
                const deduplicateStep = new DeduplicateProductTranslationsStep(this.targetDb, config);
                results.deduplicateProductTranslations = await deduplicateStep.run();
            }

            // Step 12: Replace Image URLs
            // Replace image URLs for production domain in product_images table
            if (config.steps.replaceImageUrls.enabled) {
                logger.info('🖼️ Step 12: Replace Image URLs');
                const ReplaceImageUrlsStep = require('./steps/replace-image-urls');
                const replaceImageUrlsStep = new ReplaceImageUrlsStep(this.targetDb, config, this.domain);
                results.replaceImageUrls = await replaceImageUrlsStep.run();
            }

            // Step 13: Update Products
            // Update product fields from source database (manual step)
            if (config.steps.updateProducts.enabled) {
                logger.info('🔄 Step 13: Update Products');
                const updateProductsStep = new UpdateProductsStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.updateProducts = await updateProductsStep.run();
            }

            // Step 14: Fix Content URLs
            // Fix and standardize URLs in content fields across various tables
            if (config.steps.fixContentUrls.enabled) {
                logger.info('🔗 Step 14: Fix Content URLs');
                const fixContentUrlsStep = new FixContentUrlsStep(this.targetDb, config, this.domain);
                results.fixContentUrls = await fixContentUrlsStep.run();
            }

            // Step 15: Fix Japanese Slugs
            // Convert Japanese slugs to Romaji (Latin script) for better URL compatibility
            if (config.steps.fixJapaneseSlugs.enabled) {
                logger.info('🗾 Step 15: Fix Japanese Slugs');
                const fixJapaneseSlugsStep = new FixJapaneseSlugsStep(this.targetDb, config, this.domain);
                results.fixJapaneseSlugs = await fixJapaneseSlugsStep.run();
            }

            // Step 16: Fix German Slugs
            // Convert German umlauts and special characters in slugs to URL-friendly format
            if (config.steps.fixGermanSlugs.enabled) {
                logger.info('🇩🇪 Step 16: Fix German Slugs');
                const fixGermanSlugsStep = new FixGermanSlugsStep(this.targetDb, config, this.domain);
                results.fixGermanSlugs = await fixGermanSlugsStep.run();
            }

            // Calculate execution time
            const executionTime = Date.now() - startTime;
            const executionTimeFormatted = this.formatExecutionTime(executionTime);

            // Summary
            this.printSummary(results, executionTimeFormatted);

        } catch (error) {
            logger.error('Migration V3 failed', { error: error.message, stack: error.stack });
            throw error;
        } finally {
            await this.disconnectDatabases();
        }
    }

    // Run specific step
    async runStep(stepName, domain = null) {
        try {
            logger.info(`Running specific step: ${stepName}`);
            
            // Use provided domain or fallback to instance domain
            const effectiveDomain = domain || this.domain;
            
            await this.connectRequiredDatabases(stepName);

            // Prepare context if needed for steps that require defaultLanguageId
            if (!this.context.defaultLanguageId) {
                logger.info('Preparing context (defaultLanguageId)...');
                if (!this.sourceDb) {
                    await this.connectSourceDatabase();
                }
                if (!this.targetDb) {
                    await this.connectTargetDatabase();
                }
                const prepareStep = new PrepareStep(this.sourceDb, this.targetDb, config);
                const prepareResult = await prepareStep.run();
                this.context.eavMapper = prepareResult.eavMapper;
                this.context.defaultLanguageId = prepareResult.defaultLanguageId;
            }

            // Run requested step
            switch (stepName) {
                case 'prepare':
                    const prepareStep = new PrepareStep(this.sourceDb, this.targetDb, config);
                    return await prepareStep.run();

                case 'blog_posts':
                    const blogPostsStep = new BlogPostsStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.defaultLanguageId
                    );
                    return await blogPostsStep.run();

                case 'updateBlogDescriptions':
                    const updateBlogDescriptionsStep = new UpdateBlogDescriptionsStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.defaultLanguageId,
                        effectiveDomain
                    );
                    return await updateBlogDescriptionsStep.run();

                case 'categories':
                    const categoriesStep = new CategoriesStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await categoriesStep.run();

                case 'products':
                    const productsStep = new ProductsStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await productsStep.run();

                case 'merge':
                    const mergeStep = new MergeStep(this.targetDb, this.context.defaultLanguageId);
                    return await mergeStep.run();

                case 'certCoinCategories':
                    const certCoinCategoriesStep = new CertCoinCategoriesStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await certCoinCategoriesStep.run();

                case 'updateMasterCategoryIds':
                    const updateMasterCategoryIdsStep = new UpdateMasterCategoryIdsStep(this.targetDb, this.context.defaultLanguageId);
                    return await updateMasterCategoryIdsStep.run();

                case 'customers':
                    const customersStep = new CustomersStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await customersStep.run();

                case 'orders':
                    const ordersStep = new OrdersStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await ordersStep.run();

                case 'translation':
                    const translationStep = new TranslationStep(this.targetDb, config, this.context.defaultLanguageId);
                    return await translationStep.run();

                case 'contentTranslation':
                    const contentTranslationStep = new ContentTranslationStep(this.targetDb, config, this.context.defaultLanguageId);
                    return await contentTranslationStep.run();

                case 'deduplicateProductTranslations':
                    const deduplicateStep = new DeduplicateProductTranslationsStep(this.targetDb, config);
                    return await deduplicateStep.run();

                case 'replaceImageUrls':
                    const ReplaceImageUrlsStep = require('./steps/replace-image-urls');
                    const replaceImageUrlsStep = new ReplaceImageUrlsStep(this.targetDb, config, effectiveDomain);
                    return await replaceImageUrlsStep.run();

                case 'updateProducts':
                    const updateProductsStep = new UpdateProductsStep(
                        this.sourceDb,
                        this.targetDb,
                        config,
                        this.context.eavMapper,
                        this.context.defaultLanguageId
                    );
                    return await updateProductsStep.run();

                case 'fixContentUrls':
                    const fixContentUrlsStep = new FixContentUrlsStep(this.targetDb, config, effectiveDomain);
                    return await fixContentUrlsStep.run();

                case 'fixJapaneseSlugs':
                    const fixJapaneseSlugsStep = new FixJapaneseSlugsStep(this.targetDb, config, effectiveDomain);
                    return await fixJapaneseSlugsStep.run();

                case 'fixGermanSlugs':
                    const fixGermanSlugsStep = new FixGermanSlugsStep(this.targetDb, config, effectiveDomain);
                    return await fixGermanSlugsStep.run();

                default:
                    throw new Error(`Unknown step: ${stepName}`);
            }

        } catch (error) {
            logger.error(`Step ${stepName} failed`, { error: error.message });
            throw error;
        } finally {
            await this.disconnectDatabases();
        }
    }

    formatExecutionTime(ms) {
        const seconds = Math.floor(ms / 1000);
        const minutes = Math.floor(seconds / 60);
        const hours = Math.floor(minutes / 60);

        if (hours > 0) {
            return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
        } else if (minutes > 0) {
            return `${minutes}m ${seconds % 60}s`;
        } else {
            return `${seconds}s`;
        }
    }

    printSummary(results, executionTime) {
        logger.info('📊 Migration V3 Summary');
        logger.info('='.repeat(50));

        let totalSuccess = 0;
        let totalFailed = 0;

        Object.entries(results).forEach(([step, result]) => {
            const status = result.success ? '✅' : '❌';
            const details = result.count ? ` (${result.count} records)` : '';
            const failed = result.failed ? ` (${result.failed} failed)` : '';

            logger.info(`${status} ${step}: ${result.success ? 'SUCCESS' : 'FAILED'}${details}${failed}`);

            if (result.count) totalSuccess += result.count;
            if (result.failed) totalFailed += result.failed;
        });

        logger.info('='.repeat(50));
        logger.info(`⏱️  Total execution time: ${executionTime}`);
        logger.info(`📈 Total records processed: ${totalSuccess}`);
        if (totalFailed > 0) {
            logger.warn(`⚠️  Total failed records: ${totalFailed}`);
        }
        logger.success('🎉 Migration V3 completed!');
    }
}

module.exports = MigrationV3;

// CLI runner for testing
if (require.main === module) {
    const sourceUrl = process.env.SOURCE_DATABASE_URL;
    const sourceType = process.env.SOURCE_DB_TYPE || 'mysql';
    const targetUrl = process.env.TARGET_DATABASE_URL;
    const targetType = process.env.TARGET_DB_TYPE || 'postgresql';
    const domain = process.env.DOMAIN || 'https://drakesterling.com';

    if (!sourceUrl || !targetUrl) {
        console.error('Please set SOURCE_DATABASE_URL and TARGET_DATABASE_URL environment variables');
        process.exit(1);
    }

    const migration = new MigrationV3(sourceUrl, sourceType, targetUrl, targetType, domain);
    migration.run().catch(error => {
        console.error('Migration V3 failed:', error);
        process.exit(1);
    });
}
