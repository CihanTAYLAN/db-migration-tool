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
    dependencies?: string[];
}
export interface MigrationFile {
    config: MigrationConfig;
    execute: (mysqlClient: any, postgresClient: any) => Promise<{
        success: boolean;
        recordsProcessed: number;
        errors: string[];
    }>;
}
export declare class MigrationLoader {
    private migrations;
    loadMigrations(): Promise<void>;
    getMigration(tableName: string): MigrationFile | undefined;
    getAllMigrations(): Map<string, MigrationFile>;
    getAvailableTables(): string[];
}
export declare const migrationLoader: MigrationLoader;
//# sourceMappingURL=migration-config.d.ts.map