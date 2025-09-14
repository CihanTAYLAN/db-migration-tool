#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const commander_1 = require("commander");
const migration_1 = require("../lib/migration");
const database_1 = require("../lib/database");
const program = new commander_1.Command();
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
    .action(async (options) => {
    try {
        console.log('🚀 Starting migration...');
        const migrationOptions = {
            tables: options.tables,
            batchSize: options.batchSize,
            skipExisting: options.skipExisting
        };
        const result = await migration_1.migrationService.migrate(migrationOptions);
        if (result.success) {
            console.log('✅ Migration completed successfully!');
            console.log(`📊 Migrated tables: ${result.migratedTables.length}`);
            console.log(`📈 Total records: ${result.totalRecords}`);
            if (result.migratedTables.length > 0) {
                console.log('📋 Migrated tables:');
                result.migratedTables.forEach(table => console.log(`  - ${table}`));
            }
        }
        else {
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
    }
    catch (error) {
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
        const mysqlClient = database_1.dbManager.getMySQLClient();
        // MySQL'den tabloları listele
        const result = await mysqlClient.$queryRaw `SHOW TABLES`;
        const tables = result.map((row) => Object.values(row)[0]);
        console.log(`📊 Found ${tables.length} tables:`);
        tables.forEach(table => console.log(`  - ${table}`));
        await database_1.dbManager.disconnect();
    }
    catch (error) {
        console.error('💥 Failed to list tables:', error);
        process.exit(1);
    }
});
program
    .command('test-connection')
    .description('Test database connections')
    .action(async () => {
    try {
        console.log('🔍 Testing database connections...');
        const mysqlClient = database_1.dbManager.getMySQLClient();
        const postgresClient = database_1.dbManager.getPostgreSQLClient();
        // MySQL bağlantısını test et
        try {
            await mysqlClient.$queryRaw `SELECT 1`;
            console.log('✅ MySQL connection: OK');
        }
        catch (error) {
            console.log('❌ MySQL connection: FAILED');
            console.error('  Error:', error);
        }
        // PostgreSQL bağlantısını test et
        try {
            await postgresClient.$queryRaw `SELECT 1`;
            console.log('✅ PostgreSQL connection: OK');
        }
        catch (error) {
            console.log('❌ PostgreSQL connection: FAILED');
            console.error('  Error:', error);
        }
        await database_1.dbManager.disconnect();
    }
    catch (error) {
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
//# sourceMappingURL=index.js.map