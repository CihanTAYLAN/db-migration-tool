#!/usr/bin/env node

require('dotenv').config();
const { Command } = require('commander');
const { DbClient } = require('../db');
const logger = require('../logger');
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const { promisify } = require('util');

const program = new Command();

program
    .name('migration-cli')
    .description('Flexible Database Migration CLI Tool')
    .version('1.0.0');

program
    .command('test-source')
    .description('Test source database connection')
    .action(async () => {
        try {
            logger.info('Testing source database connection...');
            const db = new DbClient(process.env.SOURCE_DATABASE_URL, process.env.SOURCE_DB_TYPE);
            await db.connect();
            await db.query('SELECT 1');
            await db.close();
            logger.success('Source database connection successful.');
        } catch (error) {
            logger.error('Source database connection failed', { error: error.message });
            process.exit(1);
        }
    });

program
    .command('test-target')
    .description('Test target database connection')
    .action(async () => {
        try {
            logger.info('Testing target database connection...');
            const db = new DbClient(process.env.TARGET_DATABASE_URL, process.env.TARGET_DB_TYPE);
            await db.connect();
            await db.query('SELECT 1');
            await db.close();
            logger.success('Target database connection successful.');
        } catch (error) {
            logger.error('Target database connection failed', { error: error.message });
            process.exit(1);
        }
    });

program
    .command('source-db-config')
    .description('Show source database configuration')
    .action(() => {
        logger.info('Source Database Configuration');
        logger.info(`URL: ${process.env.SOURCE_DATABASE_URL || 'Not set'}`);
        logger.info(`Type: ${process.env.SOURCE_DB_TYPE || 'Not set'}`);
    });

program
    .command('target-db-config')
    .description('Show target database configuration')
    .action(() => {
        logger.info('Target Database Configuration');
        logger.info(`URL: ${process.env.TARGET_DATABASE_URL || 'Not set'}`);
        logger.info(`Type: ${process.env.TARGET_DB_TYPE || 'Not set'}`);
    });

program
    .command('migration-list')
    .description('List all available migrations')
    .action(() => {
        logger.info('Available Migrations');

        const migrationDir = path.join(__dirname, '../migrations');

        if (!fs.existsSync(migrationDir)) {
            logger.error('Migration directory not found');
            return;
        }

        const files = fs.readdirSync(migrationDir).filter(file => file.endsWith('.js') && file !== 'template.js');

        if (files.length === 0) {
            logger.warning('No migration files found');
            return;
        }

        files.forEach((file, index) => {
            const migrationPath = path.join(migrationDir, file);
            const stats = fs.statSync(migrationPath);
            const size = (stats.size / 1024).toFixed(2);
            logger.info(`${index + 1}. ${file} (${size} KB)`);
        });

        logger.success(`Total ${files.length} migration files found`);
    });

program
    .command('run-migration <migrationName>')
    .description('Run a specific migration by name (without .js extension)')
    .action(async (migrationName) => {
        logger.info(`Running specific migration: ${migrationName}`);

        const migrationDir = path.join(__dirname, '../migrations');
        const migrationFile = `${migrationName}.js`;
        const migrationPath = path.join(migrationDir, migrationFile);

        if (!fs.existsSync(migrationPath)) {
            logger.error(`Migration file not found: ${migrationFile}`);
            return;
        }

        const migrationModule = require(migrationPath);

        if (migrationModule && migrationModule.default) {
            const MigrationClass = migrationModule.default;
            const migrationInstance = new MigrationClass(
                process.env.SOURCE_DATABASE_URL,
                process.env.SOURCE_DB_TYPE,
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );

            try {
                await migrationInstance.run();
                logger.success(`${migrationFile} completed successfully`);
            } catch (error) {
                logger.error(`${migrationFile} failed`, { error: error.message });
                process.exit(1);
            }
        } else {
            logger.error(`Invalid migration file: ${migrationFile} - no default export found`);
            process.exit(1);
        }
    });

program
    .command('merge-subcategories')
    .description('Merge duplicate subcategories based on slug prefixes')
    .action(async () => {
        try {
            logger.info('Starting subcategory merge process...');
            const SubcategoryMerger = require('../migrationsv2/merge-subcategories');
            const mergerInstance = new SubcategoryMerger(
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );
            await mergerInstance.run();
            logger.success('Subcategory merge completed successfully');
        } catch (error) {
            logger.error('Subcategory merge failed', { error: error.message });
            process.exit(1);
        }
    });

program
    .command('migrate')
    .description('Run all migrations in correct order')
    .action(async () => {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });
        // const question = promisify(rl.question).bind(rl);

        try {
            // const answer = await question('Do you want to use the new v2 migration system? (y/n): ');
            // if (answer.toLowerCase() === 'y') {
            const MigrationV2 = require('../migrationsv2');
            const migrationInstance = new MigrationV2(
                process.env.SOURCE_DATABASE_URL,
                process.env.SOURCE_DB_TYPE,
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );
            await migrationInstance.run();

            // Migration V2 tamamlandıktan sonra alt kategori birleştirme işlemini çalıştır
            logger.info('Running subcategory merge after migration V2...');
            const SubcategoryMerger = require('../migrationsv2/merge-subcategories');
            const mergerInstance = new SubcategoryMerger(
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );
            await mergerInstance.run();
            // } else {
            //     logger.info('Starting migration process with legacy system...');

            //     const migrationDir = path.join(__dirname, '../migrations');

            //     if (!fs.existsSync(migrationDir)) {
            //         logger.error('Migration directory not found');
            //         return;
            //     }

            //     // Define migration order for proper dependency handling
            //     const migrationOrder = [
            //         'categories.js',
            //         'customers.js',
            //         'products.js',
            //         'product_categories.js',
            //         'product_images.js',
            //         'product_translations.js',
            //         'product_prices.js'
            //     ];

            //     // Get all available migration files
            //     const availableFiles = fs.readdirSync(migrationDir).filter(file =>
            //         file.endsWith('.js') && file !== 'template.js'
            //     );

            //     // Filter and sort migrations according to defined order
            //     const orderedMigrations = migrationOrder.filter(file => availableFiles.includes(file));
            //     const unorderedMigrations = availableFiles.filter(file => !migrationOrder.includes(file));

            //     // Combine ordered and unordered migrations
            //     const allMigrations = [...orderedMigrations, ...unorderedMigrations];

            //     logger.info(`Found ${allMigrations.length} migration files to run`);

            //     for (const file of allMigrations) {
            //         const migrationPath = path.join(migrationDir, file);
            //         const migrationModule = require(migrationPath);

            //         if (migrationModule && migrationModule.default) {
            //             const MigrationClass = migrationModule.default;
            //             const migrationInstance = new MigrationClass(
            //                 process.env.SOURCE_DATABASE_URL,
            //                 process.env.SOURCE_DB_TYPE,
            //                 process.env.TARGET_DATABASE_URL,
            //                 process.env.TARGET_DB_TYPE
            //             );

            //             logger.info(`Running migration: ${file}`);
            //             try {
            //                 await migrationInstance.run();
            //                 logger.success(`${file} completed successfully`);
            //             } catch (error) {
            //                 logger.error(`${file} failed`, { error: error.message });
            //                 // Continue with next migration instead of stopping
            //                 logger.warning('Continuing with next migration...');
            //             }
            //         } else {
            //             logger.warning(`Skipping ${file} - no default export found`);
            //         }
            //     }

            //     logger.success('All migrations completed');
            // }
        } finally {
            rl.close();
        }
    });

// Migration V3 Commands
program
    .command('migrate:v3')
    .description('Run Migration V3 (step-by-step system)')
    .action(async () => {
        try {
            logger.info('Starting Migration V3...');
            const MigrationV3 = require('../migrationsv3');
            const migrationInstance = new MigrationV3(
                process.env.SOURCE_DATABASE_URL,
                process.env.SOURCE_DB_TYPE,
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );
            await migrationInstance.run();
            logger.success('Migration V3 completed successfully');
        } catch (error) {
            logger.error('Migration V3 failed', { error: error.message });
            process.exit(1);
        }
    });

program
    .command('migrate:v3:step <stepName> [domain]')
    .description('Run specific Migration V3 step (prepare, blog_posts, categories, products, merge, customers, orders, replaceImageUrls)')
    .action(async (stepName, domain) => {
        try {
            logger.info(`Running Migration V3 step: ${stepName}`);
            const MigrationV3 = require('../migrationsv3');
            const migrationInstance = new MigrationV3(
                process.env.SOURCE_DATABASE_URL,
                process.env.SOURCE_DB_TYPE,
                process.env.TARGET_DATABASE_URL,
                process.env.TARGET_DB_TYPE
            );
            const result = await migrationInstance.runStep(stepName, domain);
            logger.success(`Migration V3 step ${stepName} completed successfully`);
        } catch (error) {
            logger.error(`Migration V3 step ${stepName} failed`, { error: error.message });
            process.exit(1);
        }
    });

program.parse();
