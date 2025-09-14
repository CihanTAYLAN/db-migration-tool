import { dbManager } from './database';

export interface MigrationOptions {
    tables?: string[];
    batchSize?: number;
    skipExisting?: boolean;
}

export interface MigrationResult {
    success: boolean;
    migratedTables: string[];
    failedTables: string[];
    totalRecords: number;
    errors: string[];
}

export class MigrationService {
    async migrate(options: MigrationOptions = {}): Promise<MigrationResult> {
        const result: MigrationResult = {
            success: true,
            migratedTables: [],
            failedTables: [],
            totalRecords: 0,
            errors: []
        };

        try {
            const mysqlClient = dbManager.getMySQLClient();
            const postgresClient = dbManager.getPostgreSQLClient();

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
                } catch (error) {
                    const errorMessage = `Failed to migrate table ${tableName}: ${error}`;
                    result.errors.push(errorMessage);
                    result.failedTables.push(tableName);
                    console.error(errorMessage);
                }
            }

            if (result.failedTables.length > 0) {
                result.success = false;
            }

        } catch (error) {
            result.success = false;
            result.errors.push(`Migration failed: ${error}`);
        } finally {
            await dbManager.disconnect();
        }

        return result;
    }

    private async getMySQLTables(client: any, tableFilter?: string[]): Promise<string[]> {
        // MySQL'den tabloları listele
        const result = await client.$queryRaw`SHOW TABLES`;
        const tables = result.map((row: any) => Object.values(row)[0] as string);

        if (tableFilter && tableFilter.length > 0) {
            return tables.filter((table: string) => tableFilter.includes(table));
        }

        return tables;
    }

    private async getTableStructure(client: any, tableName: string): Promise<any[]> {
        // Tablo yapısını al
        const result = await client.$queryRaw`DESCRIBE ${tableName}`;
        return result;
    }

    private async getTableData(client: any, tableName: string, batchSize: number): Promise<any[]> {
        // Verileri oku
        const result = await client.$queryRaw`SELECT * FROM ${tableName} LIMIT ${batchSize}`;
        return result;
    }

    private async createTableInPostgres(client: any, tableName: string, structure: any[]): Promise<void> {
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

    private async insertDataToPostgres(client: any, tableName: string, data: any[]): Promise<number> {
        if (data.length === 0) return 0;

        // Verileri PostgreSQL'e yaz
        const columns = Object.keys(data[0]);
        const values = data.map(row =>
            `(${columns.map(col => `'${row[col]}'`).join(', ')})`
        ).join(', ');

        const insertSQL = `INSERT INTO ${tableName} (${columns.join(', ')}) VALUES ${values}`;

        await client.$executeRawUnsafe(insertSQL);
        return data.length;
    }

    private mapMySQLTypeToPostgres(mysqlType: string): string {
        // MySQL tiplerini PostgreSQL tiplerine dönüştür
        const typeMapping: { [key: string]: string } = {
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

export const migrationService = new MigrationService();
