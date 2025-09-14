"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dbManager = exports.DatabaseManager = void 0;
const prisma_mysql_1 = require("../generated/prisma-mysql");
const prisma_postgres_1 = require("../generated/prisma-postgres");
class DatabaseManager {
    constructor() {
        this.mysqlClient = new prisma_mysql_1.PrismaClient();
        this.postgresClient = new prisma_postgres_1.PrismaClient();
    }
    getMySQLClient() {
        return this.mysqlClient;
    }
    getPostgreSQLClient() {
        return this.postgresClient;
    }
    async disconnect() {
        await Promise.all([
            this.mysqlClient.$disconnect(),
            this.postgresClient.$disconnect()
        ]);
    }
}
exports.DatabaseManager = DatabaseManager;
exports.dbManager = new DatabaseManager();
//# sourceMappingURL=database.js.map