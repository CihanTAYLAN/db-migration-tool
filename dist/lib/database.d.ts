import { PrismaClient as MySQLPrismaClient } from '../generated/prisma-mysql';
import { PrismaClient as PostgreSQLPrismaClient } from '../generated/prisma-postgres';
export declare class DatabaseManager {
    private mysqlClient;
    private postgresClient;
    constructor();
    getMySQLClient(): MySQLPrismaClient;
    getPostgreSQLClient(): PostgreSQLPrismaClient;
    disconnect(): Promise<void>;
}
export declare const dbManager: DatabaseManager;
//# sourceMappingURL=database.d.ts.map