"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrationService = exports.MigrationService = void 0;
const database_1 = require("./database");
const migration_config_1 = require("./migration-config");
class MigrationService {
    async migrate(options = {}) {
        const result = {
            success: true,
            migratedTables: [],
            failedTables: [],
            totalRecords: 0,
            errors: []
        };
        try {
            const mysqlClient = database_1.dbManager.getMySQLClient();
            const postgresClient = database_1.dbManager.getPostgreSQLClient();
            // Özel migrasyon dosyalarını kullan
            if (options.useCustomMigrations !== false) {
                await migration_config_1.migrationLoader.loadMigrations();
                const availableMigrations = migration_config_1.migrationLoader.getAvailableTables();
                if (availableMigrations.length > 0) {
                    console.log(`📋 Found ${availableMigrations.length} custom migration files: ${availableMigrations.join(', ')}`);
                    // Hangi tabloları migrate edeceğimizi belirle
                    const tablesToMigrate = options.tables && options.tables.length > 0
                        ? options.tables.filter(table => availableMigrations.includes(table))
                        : availableMigrations;
                    if (tablesToMigrate.length === 0) {
                        console.log('⚠️  No matching custom migrations found for requested tables');
                        return result;
                    }
                    // Dependency sırasına göre sırala
                    const orderedTables = this.orderByDependencies(tablesToMigrate);
                    for (const tableName of orderedTables) {
                        try {
                            const migrationFile = migration_config_1.migrationLoader.getMigration(tableName);
                            if (!migrationFile)
                                continue;
                            console.log(`🚀 Migrating table: ${tableName} (${migrationFile.config.description || 'No description'})`);
                            const migrationResult = await migrationFile.execute(mysqlClient, postgresClient);
                            if (migrationResult.success) {
                                result.migratedTables.push(tableName);
                                result.totalRecords += migrationResult.recordsProcessed;
                                console.log(`✅ Migrated ${tableName}: ${migrationResult.recordsProcessed} records`);
                            }
                            else {
                                result.failedTables.push(tableName);
                                result.errors.push(...migrationResult.errors);
                                console.error(`❌ Failed to migrate ${tableName}:`, migrationResult.errors);
                            }
                        }
                        catch (error) {
                            const errorMessage = `Failed to migrate table ${tableName}: ${error}`;
                            result.errors.push(errorMessage);
                            result.failedTables.push(tableName);
                            console.error(errorMessage);
                        }
                    }
                }
                else {
                    console.log('⚠️  No custom migration files found, falling back to auto-migration');
                    return await this.autoMigrate(mysqlClient, postgresClient, options, result);
                }
            }
            else {
                // Otomatik migrasyon kullan
                return await this.autoMigrate(mysqlClient, postgresClient, options, result);
            }
            if (result.failedTables.length > 0) {
                result.success = false;
            }
        }
        catch (error) {
            result.success = false;
            result.errors.push(`Migration failed: ${error}`);
        }
        finally {
            await database_1.dbManager.disconnect();
        }
        return result;
    }
    async autoMigrate(mysqlClient, postgresClient, options, result) {
        // Eski otomatik migrasyon mantığı
        const tables = await this.getMySQLTables(mysqlClient, options.tables);
        for (const tableName of tables) {
            try {
                console.log(`Migrating table: ${tableName} (auto)`);
                // Tablo yapısını al
                const tableStructure = await this.getTableStructure(mysqlClient, tableName);
                // Verileri oku
                const data = await this.getTableData(mysqlClient, tableName, options.batchSize || 1000);
                // PostgreSQL'de tablo oluştur (eğer yoksa)
                if (!options.skipExisting) {
                    await this.createTableInPostgres(postgresClient, tableName, tableStructure);
                }
                // Verileri yaz
                const insertedCount = await this.insertDataToPostgres(postgresClient, tableName, data);
                result.migratedTables.push(tableName);
                result.totalRecords += insertedCount;
                console.log(`✓ Migrated ${tableName}: ${insertedCount} records`);
            }
            catch (error) {
                const errorMessage = `Failed to migrate table ${tableName}: ${error}`;
                result.errors.push(errorMessage);
                result.failedTables.push(tableName);
                console.error(errorMessage);
            }
        }
        return result;
    }
    orderByDependencies(tables) {
        // Dependency'lere göre sırala (basit topological sort)
        const visited = new Set();
        const result = [];
        const visit = (table) => {
            if (visited.has(table))
                return;
            visited.add(table);
            const migration = migration_config_1.migrationLoader.getMigration(table);
            if (migration?.config.dependencies) {
                for (const dep of migration.config.dependencies) {
                    if (tables.includes(dep)) {
                        visit(dep);
                    }
                }
            }
            result.push(table);
        };
        for (const table of tables) {
            visit(table);
        }
        return result;
    }
    async getMySQLTables(client, tableFilter) {
        // MySQL'den tabloları listele
        const result = await client.$queryRaw `SHOW TABLES`;
        const tables = result.map((row) => Object.values(row)[0]);
        if (tableFilter && tableFilter.length > 0) {
            return tables.filter((table) => tableFilter.includes(table));
        }
        return tables;
    }
    async getTableStructure(client, tableName) {
        // Tablo yapısını al
        const result = await client.$queryRaw `DESCRIBE ${tableName}`;
        return result;
    }
    async getTableData(client, tableName, batchSize) {
        // Verileri oku
        const result = await client.$queryRaw `SELECT * FROM ${tableName} LIMIT ${batchSize}`;
        return result;
    }
    async createTableInPostgres(client, tableName, structure) {
        // PostgreSQL'de tablo oluştur
        const columns = structure.map(col => {
            const columnName = col.Field;
            let columnType = this.mapMySQLTypeToPostgres(col.Type);
            const constraints = [];
            if (col.Null === 'NO') {
                constraints.push('NOT NULL');
            }
            if (col.Key === 'PRI') {
                constraints.push('PRIMARY KEY');
            }
            if (col.Default !== null) {
                constraints.push(`DEFAULT '${col.Default}'`);
            }
            return `${columnName} ${columnType} ${constraints.join(' ')}`;
        }).join(', ');
        const createTableSQL = `CREATE TABLE IF NOT EXISTS ${tableName} (${columns})`;
        await client.$executeRawUnsafe(createTableSQL);
    }
    async insertDataToPostgres(client, tableName, data) {
        if (data.length === 0)
            return 0;
        // Verileri PostgreSQL'e yaz
        const columns = Object.keys(data[0]);
        const values = data.map(row => `(${columns.map(col => `'${row[col]}'`).join(', ')})`).join(', ');
        const insertSQL = `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES ${values}`;
        await client.$executeRawUnsafe(insertSQL);
        return data.length;
    }
    mapMySQLTypeToPostgres(mysqlType) {
        // MySQL tiplerini PostgreSQL tiplerine dönüştür
        const typeMapping = {
            'int': 'INTEGER',
            'varchar': 'VARCHAR',
            'text': 'TEXT',
            'datetime': 'TIMESTAMP',
            'date': 'DATE',
            'decimal': 'DECIMAL',
            'float': 'REAL',
            'double': 'DOUBLE PRECISION',
            'bigint': 'BIGINT',
            'smallint': 'SMALLINT',
            'tinyint': 'SMALLINT',
            'boolean': 'BOOLEAN',
            'blob': 'BYTEA',
            'longblob': 'BYTEA'
        };
        // VARCHAR(n) gibi tipleri işle
        const match = mysqlType.match(/^(\w+)\((\d+)\)/);
        if (match) {
            const baseType = match[1];
            const size = match[2];
            return typeMapping[baseType] || `${baseType.toUpperCase()}(${size})`;
        }
        return typeMapping[mysqlType] || mysqlType.toUpperCase();
    }
}
exports.MigrationService = MigrationService;
exports.migrationService = new MigrationService();
//# sourceMappingURL=migration.js.map