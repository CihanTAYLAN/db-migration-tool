#!/usr/bin/env node

require('dotenv').config();
const { Command } = require('commander');
const { DbClient } = require('../db');
const logger = require('../logger');
const fs = require('fs');
const path = require('path');

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
    .command('migrate')
    .description('Run all migrations')
    .action(async () => {
        logger.info('Starting migration process...');

        const migrationDir = path.join(__dirname, '../migrations');

        if (!fs.existsSync(migrationDir)) {
            logger.error('Migration directory not found');
            return;
        }

        const files = fs.readdirSync(migrationDir).filter(file => file.endsWith('.js') && file !== 'template.js');

        for (const file of files) {
            const migrationPath = path.join(migrationDir, file);
            const migrationModule = require(migrationPath);

            if (migrationModule && migrationModule.default) {
                const MigrationClass = migrationModule.default;
                const migrationInstance = new MigrationClass(
                    process.env.SOURCE_DATABASE_URL,
                    process.env.SOURCE_DB_TYPE,
                    process.env.TARGET_DATABASE_URL,
                    process.env.TARGET_DB_TYPE
                );

                logger.info(`Running migration: ${file}`);
                try {
                    await migrationInstance.run();
                    logger.success(`${file} completed`);
                } catch (error) {
                    logger.error(`${file} failed`, { error: error.message });
                }
            }
        }

        logger.success('All migrations completed');
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

program.parse();
