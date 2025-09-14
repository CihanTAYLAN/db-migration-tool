#!/usr/bin/env node

import { Command } from 'commander';
import { migrationService } from '../lib/migration';
import { dbManager } from '../lib/database';
import { migrationLoader } from '../lib/migration-config';

const program = new Command();

program
    .name('migration-cli')
    .description('MySQL to PostgreSQL Migration Tool')
    .version('1.0.0');

program
    .command('migrate')
    .description('Start migration from MySQL to PostgreSQL')
    .option('-t, --tables <tables>', 'Comma-separated list of tables to migrate', (value) => value.split(','))
    .option('-b, --batch-size <size>', 'Batch size for data migration', parseInt, 1000)
    .option('-s, --skip-existing', 'Skip creating tables if they already exist', false)
    .option('-a, --auto-only', 'Use only auto-migration (skip custom migration files)', false)
    .action(async (options) => {
        try {
            console.log('🚀 Starting migration...');

            const migrationOptions = {
                tables: options.tables,
                batchSize: options.batchSize,
                skipExisting: options.skipExisting,
                useCustomMigrations: !options.autoOnly
            };

            const result = await migrationService.migrate(migrationOptions);

            if (result.success) {
                console.log('✅ Migration completed successfully!');
                console.log(`📊 Migrated tables: ${result.migratedTables.length}`);
                console.log(`📈 Total records: ${result.totalRecords}`);

                if (result.migratedTables.length > 0) {
                    console.log('📋 Migrated tables:');
                    result.migratedTables.forEach(table => console.log(`  - ${table}`));
                }
            } else {
                console.error('❌ Migration completed with errors!');
                console.log(`📊 Migrated tables: ${result.migratedTables.length}`);
                console.log(`📈 Total records: ${result.totalRecords}`);
                console.log(`❌ Failed tables: ${result.failedTables.length}`);

                if (result.failedTables.length > 0) {
                    console.log('📋 Failed tables:');
                    result.failedTables.forEach(table => console.log(`  - ${table}`));
                }

                if (result.errors.length > 0) {
                    console.log('🚨 Errors:');
                    result.errors.forEach(error => console.log(`  - ${error}`));
                }

                process.exit(1);
            }
        } catch (error) {
            console.error('💥 Migration failed:', error);
            process.exit(1);
        }
    });

program
    .command('list-tables')
    .description('List all tables in MySQL database')
    .action(async () => {
        try {
            console.log('📋 Listing MySQL tables...');

            const mysqlClient = dbManager.getMySQLClient();

            // MySQL'den tabloları listele
            const result = await mysqlClient.$queryRaw`SHOW TABLES`;
            const tables = (result as any[]).map((row: any) => Object.values(row)[0] as string);

            console.log(`📊 Found ${tables.length} tables:`);
            tables.forEach(table => console.log(`  - ${table}`));

            await dbManager.disconnect();
        } catch (error) {
            console.error('💥 Failed to list tables:', error);
            process.exit(1);
        }
    });

program
    .command('list-migrations')
    .description('List all custom migration files')
    .action(async () => {
        try {
            console.log('📋 Listing custom migration files...');

            await migrationLoader.loadMigrations();
            const availableMigrations = migrationLoader.getAvailableTables();

            if (availableMigrations.length === 0) {
                console.log('⚠️  No custom migration files found');
                return;
            }

            console.log(`📊 Found ${availableMigrations.length} migration files:`);

            for (const tableName of availableMigrations) {
                const migration = migrationLoader.getMigration(tableName);
                if (migration) {
                    console.log(`  - ${tableName}: ${migration.config.description || 'No description'}`);
                    if (migration.config.dependencies && migration.config.dependencies.length > 0) {
                        console.log(`    Dependencies: ${migration.config.dependencies.join(', ')}`);
                    }
                }
            }
        } catch (error) {
            console.error('💥 Failed to list migrations:', error);
            process.exit(1);
        }
    });

program
    .command('test-connection')
    .description('Test database connections')
    .action(async () => {
        try {
            console.log('🔍 Testing database connections...');

            const mysqlClient = dbManager.getMySQLClient();
            const postgresClient = dbManager.getPostgreSQLClient();

            // MySQL bağlantısını test et
            try {
                await mysqlClient.$queryRaw`SELECT 1`;
                console.log('✅ MySQL connection: OK');
            } catch (error) {
                console.log('❌ MySQL connection: FAILED');
                console.error('  Error:', error);
            }

            // PostgreSQL bağlantısını test et
            try {
                await postgresClient.$queryRaw`SELECT 1`;
                console.log('✅ PostgreSQL connection: OK');
            } catch (error) {
                console.log('❌ PostgreSQL connection: FAILED');
                console.error('  Error:', error);
            }

            await dbManager.disconnect();
        } catch (error) {
            console.error('💥 Connection test failed:', error);
            process.exit(1);
        }
    });

// Hata yakalama
process.on('uncaughtException', (error) => {
    console.error('💥 Uncaught Exception:', error);
    process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
    process.exit(1);
});

program.parse();
