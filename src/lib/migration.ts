import { dbManager } from './database';
import { migrationLoader } from './migration-config';

export interface MigrationOptions {
    tables?: string[];
    batchSize?: number;
    skipExisting?: boolean;
    useCustomMigrations?: boolean; // Özel migrasyon dosyalarını kullan
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

            // Özel migrasyon dosyalarını kullan
            if (options.useCustomMigrations !== false) {
                await migrationLoader.loadMigrations();
                const availableMigrations = migrationLoader.getAvailableTables();

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
                            const migrationFile = migrationLoader.getMigration(tableName);
                            if (!migrationFile) continue;

                            console.log(`🚀 Migrating table: ${tableName} (${migrationFile.config.description || 'No description'})`);

                            const migrationResult = await migrationFile.execute(mysqlClient, postgresClient);

                            if (migrationResult.success) {
                                result.migratedTables.push(tableName);
                                result.totalRecords += migrationResult.recordsProcessed;
                                console.log(`✅ Migrated ${tableName}: ${migrationResult.recordsProcessed} records`);
                            } else {
                                result.failedTables.push(tableName);
                                result.errors.push(...migrationResult.errors);
                                console.error(`❌ Failed to migrate ${tableName}:`, migrationResult.errors);
                            }
                        } catch (error) {
                            const errorMessage = `Failed to migrate table ${tableName}: ${error}`;
                            result.errors.push(errorMessage);
                            result.failedTables.push(tableName);
                            console.error(errorMessage);
                        }
                    }
                } else {
                    console.log('⚠️  No custom migration files found, falling back to auto-migration');
                    return await this.autoMigrate(mysqlClient, postgresClient, options, result);
                }
            } else {
                // Otomatik migrasyon kullan
                return await this.autoMigrate(mysqlClient, postgresClient, options, result);
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

    private async autoMigrate(
        mysqlClient: any,
        postgresClient: any,
        options: MigrationOptions,
        result: MigrationResult
    ): Promise<MigrationResult> {
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
            } catch (error) {
                const errorMessage = `Failed to migrate table ${tableName}: ${error}`;
                result.errors.push(errorMessage);
                result.failedTables.push(tableName);
                console.error(errorMessage);
            }
        }

        return result;
    }

    private orderByDependencies(tables: string[]): string[] {
        // Dependency'lere göre sırala (basit topological sort)
        const visited = new Set<string>();
        const result: string[] = [];

        const visit = (table: string) => {
            if (visited.has(table)) return;
            visited.add(table);

            const migration = migrationLoader.getMigration(table);
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
