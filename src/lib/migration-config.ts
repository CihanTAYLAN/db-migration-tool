export interface SourceTable {
    table: string;
    columns?: string[];
    where?: string;
    join?: {
        table: string;
        on: string;
        type?: 'LEFT' | 'INNER' | 'RIGHT';
    };
}

export interface MigrationConfig {
    targetTable: string;
    description?: string;
    sourceTables: SourceTable[];
    transform?: (data: any[]) => Promise<any[]>;
    batchSize?: number;
    dependencies?: string[]; // Bu migrasyonun çalışması için gerekli diğer tablolar
}

export interface MigrationFile {
    config: MigrationConfig;
    execute: (mysqlClient: any, postgresClient: any) => Promise<{
        success: boolean;
        recordsProcessed: number;
        errors: string[];
    }>;
}

export class MigrationLoader {
    private migrations: Map<string, MigrationFile> = new Map();

    async loadMigrations(): Promise<void> {
        // src/migrations klasöründeki tüm dosyaları yükle
        const fs = require('fs');
        const path = require('path');

        const migrationsPath = path.join(__dirname, '../migrations');

        if (!fs.existsSync(migrationsPath)) {
            console.warn('Migrations directory not found:', migrationsPath);
            return;
        }

        const files = fs.readdirSync(migrationsPath).filter((file: string) =>
            file.endsWith('.ts') || file.endsWith('.js')
        );

        for (const file of files) {
            try {
                const filePath = path.join(migrationsPath, file);
                const migrationModule = require(filePath);

                if (migrationModule.config && migrationModule.execute) {
                    const tableName = migrationModule.config.targetTable;
                    this.migrations.set(tableName, migrationModule);
                    console.log(`✓ Loaded migration for table: ${tableName}`);
                }
            } catch (error) {
                console.error(`Failed to load migration file ${file}:`, error);
            }
        }
    }

    getMigration(tableName: string): MigrationFile | undefined {
        return this.migrations.get(tableName);
    }

    getAllMigrations(): Map<string, MigrationFile> {
        return this.migrations;
    }

    getAvailableTables(): string[] {
        return Array.from(this.migrations.keys());
    }
}

export const migrationLoader = new MigrationLoader();
