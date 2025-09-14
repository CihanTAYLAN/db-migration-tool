"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrationService = exports.MigrationService = void 0;
const database_1 = require("./database");
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
            // MySQL'den tabloları listele
            const tables = await this.getMySQLTables(mysqlClient, options.tables);
            for (const tableName of tables) {
                try {
                    console.log(`Migrating table: ${tableName}`);
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