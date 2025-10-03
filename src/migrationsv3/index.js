/*
# Migration V3 - Main Orchestrator

Step-by-step migration system with improved architecture.
*/

const { DbClient } = require('../db');
const logger = require('../logger');
const config = require('./config/migration-config');

// Import steps
const PrepareStep = require('./steps/prepare');
const CategoriesStep = require('./steps/categories');
const ProductsStep = require('./steps/products');
const UpdateImagePathsStep = require('./steps/update-image-paths');
const ProductMasterImagesUpdateStep = require('./steps/product-master-images-update');
const MergeStep = require('./steps/merge-subcategories');
const CustomersStep = require('./steps/customers');
const OrdersStep = require('./steps/orders');

class MigrationV3 {
    constructor(sourceUrl, sourceType, targetUrl, targetType) {
        this.sourceUrl = sourceUrl;
        this.sourceType = sourceType;
        this.targetUrl = targetUrl;
        this.targetType = targetType;
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

            // Step 2: Categories
            // Migrate all categories from catalog_category_flat_store_1
            if (config.steps.categories.enabled) {
                logger.info('📂 Step 2: Categories');
                const categoriesStep = new CategoriesStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.categories = await categoriesStep.run();
            }

            // Step 3: Products
            // Migrate products + translations + prices + images + certificate badges + master_category_id update
            if (config.steps.products.enabled) {
                logger.info('📦 Step 3: Products');
                const productsStep = new ProductsStep(
                    this.sourceDb,
                    this.targetDb,
                    config,
                    this.context.eavMapper,
                    this.context.defaultLanguageId
                );
                results.products = await productsStep.run();
            }

            // Step 4: Update Image Paths
            // Convert old media URLs to new format with proper domain
            if (config.steps.updateImagePaths.enabled) {
                logger.info('🖼️  Step 4: Update Image Paths');
                const updateImagePathsStep = new UpdateImagePathsStep(this.sourceDb, this.targetDb, config);
                results.updateImagePaths = await updateImagePathsStep.run();
            }

            // Step 5: Product Master Images Update
            // Set master_image_id for each product based on position = 1 or first image
            if (config.steps.productMasterImagesUpdate.enabled) {
                logger.info('🏷️  Step 5: Product Master Images Update');
                const productMasterImagesUpdateStep = new ProductMasterImagesUpdateStep(this.sourceDb, this.targetDb, config);
                results.productMasterImagesUpdate = await productMasterImagesUpdateStep.run();
            }

            // Step 6: Merge
            // Merge duplicate subcategories based on URL key prefixes + calculate parent slugs
            if (config.steps.merge.enabled) {
                logger.info('🔗 Step 6: Merge Subcategories');
                const mergeStep = new MergeStep(this.targetDb);
                results.merge = await mergeStep.run();
            }

            // Step 7: Update Master Category IDs
            // Fix master_category_id NULL fields after subcategory merge
            if (config.steps.updateMasterCategoryIds.enabled) {
                logger.info('📂 Step 7: Update Master Category IDs');
                const UpdateMasterCategoryIdsStep = require('./steps/update-master-category-ids');
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
    async runStep(stepName) {
        try {
            logger.info(`Running specific step: ${stepName}`);
            await this.connectDatabases();

            // Prepare context first
            if (!this.context.eavMapper || !this.context.defaultLanguageId) {
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

                case 'updateImagePaths':
                    const updateImagePathsStep = new UpdateImagePathsStep(this.sourceDb, this.targetDb, config);
                    return await updateImagePathsStep.run();

                case 'productMasterImagesUpdate':
                    const productMasterImagesUpdateStep = new ProductMasterImagesUpdateStep(this.sourceDb, this.targetDb, config);
                    return await productMasterImagesUpdateStep.run();

                case 'merge':
                    const mergeStep = new MergeStep(this.targetDb);
                    return await mergeStep.run();

                case 'updateMasterCategoryIds':
                    const UpdateMasterCategoryIdsStep = require('./steps/update-master-category-ids');
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

    if (!sourceUrl || !targetUrl) {
        console.error('Please set SOURCE_DATABASE_URL and TARGET_DATABASE_URL environment variables');
        process.exit(1);
    }

    const migration = new MigrationV3(sourceUrl, sourceType, targetUrl, targetType);
    migration.run().catch(error => {
        console.error('Migration V3 failed:', error);
        process.exit(1);
    });
}
