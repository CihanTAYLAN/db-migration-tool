import { PrismaClient as MySQLPrismaClient } from '../generated/prisma-mysql';
import { PrismaClient as PostgreSQLPrismaClient } from '../generated/prisma-postgres';

export class DatabaseManager {
    private mysqlClient: MySQLPrismaClient;
    private postgresClient: PostgreSQLPrismaClient;

    constructor() {
        this.mysqlClient = new MySQLPrismaClient();
        this.postgresClient = new PostgreSQLPrismaClient();
    }

    getMySQLClient(): MySQLPrismaClient {
        return this.mysqlClient;
    }

    getPostgreSQLClient(): PostgreSQLPrismaClient {
        return this.postgresClient;
    }

    async disconnect(): Promise<void> {
        await Promise.all([
            this.mysqlClient.$disconnect(),
            this.postgresClient.$disconnect()
        ]);
    }
}

export const dbManager = new DatabaseManager();
