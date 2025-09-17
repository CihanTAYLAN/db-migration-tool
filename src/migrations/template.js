const { DbClient } = require('../db');
const logger = require('../logger');

class MigrationTemplate {
    constructor(sourceConnectionString, sourceDbType, targetConnectionString, targetDbType) {
        this.sourceDb = new DbClient(sourceConnectionString, sourceDbType);
        this.targetDb = new DbClient(targetConnectionString, targetDbType);
    }

    async check() {
        try {
            await this.sourceDb.connect();
            await this.targetDb.connect();

            const sourceResult = await this.sourceDb.query('SELECT 1 as test');
            const targetResult = await this.targetDb.query('SELECT 1 as test');

            return sourceResult.length > 0 && targetResult.length > 0;
        } catch (error) {
            logger.error('Check failed', { error: error.message });
            return false;
        } finally {
            await this.sourceDb.close();
            await this.targetDb.close();
        }
    }

    async query(dbType, sql, params = []) {
        try {
            const db = dbType === 'source' ? this.sourceDb : this.targetDb;
            await db.connect();
            const result = await db.query(sql, params);
            return result;
        } catch (error) {
            logger.error(`Query failed (${dbType})`, { error: error.message });
            throw error;
        } finally {
            const db = dbType === 'source' ? this.sourceDb : this.targetDb;
            await db.close();
        }
    }

    async run() {
        logger.info('Running migration template...');
        const isConnected = await this.check();
        if (isConnected) {
            logger.success('Database connections successful');
        } else {
            logger.error('Database connection failed');
        }
    }
}

module.exports = { MigrationTemplate };
