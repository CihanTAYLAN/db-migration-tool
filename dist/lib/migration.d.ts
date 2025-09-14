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
export declare class MigrationService {
    migrate(options?: MigrationOptions): Promise<MigrationResult>;
    private getMySQLTables;
    private getTableStructure;
    private getTableData;
    private createTableInPostgres;
    private insertDataToPostgres;
    private mapMySQLTypeToPostgres;
}
export declare const migrationService: MigrationService;
//# sourceMappingURL=migration.d.ts.map