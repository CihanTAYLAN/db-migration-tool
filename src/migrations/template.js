const { DbClient } = require('../db');
const logger = require('../logger');

class MigrationTemplate {
    constructor(sourceConnectionString, sourceDbType, targetConnectionString, targetDbType) {
        this.sourceDb = new DbClient(sourceConnectionString, sourceDbType);
        this.targetDb = new DbClient(targetConnectionString, targetDbType);

        // Bağlantıları constructor'da aç (performans için)
        this.sourceConnected = false;
        this.targetConnected = false;
    }

    async connectAll() {
        try {
            await this.sourceDb.connect();
            this.sourceConnected = true;
            logger.debug('Source database connected');
        } catch (error) {
            logger.error('Source database connection failed', { error: error.message });
            this.sourceConnected = false;
        }

        try {
            await this.targetDb.connect();
            this.targetConnected = true;
            logger.debug('Target database connected');
        } catch (error) {
            logger.error('Target database connection failed', { error: error.message });
            this.targetConnected = false;
        }
    }

    async disconnectAll() {
        if (this.sourceConnected) {
            try {
                await this.sourceDb.close();
                logger.debug('Source database disconnected');
            } catch (error) {
                logger.error('Source database disconnect failed', { error: error.message });
            }
            this.sourceConnected = false;
        }

        if (this.targetConnected) {
            try {
                await this.targetDb.close();
                logger.debug('Target database disconnected');
            } catch (error) {
                logger.error('Target database disconnect failed', { error: error.message });
            }
            this.targetConnected = false;
        }
    }

    async check() {
        try {
            await this.connectAll();

            if (!this.sourceConnected || !this.targetConnected) {
                return false;
            }

            const sourceResult = await this.sourceDb.query('SELECT 1 as test');
            const targetResult = await this.targetDb.query('SELECT 1 as test');

            await this.disconnectAll(); // Check sonrası kapat

            return sourceResult.length > 0 && targetResult.length > 0;
        } catch (error) {
            logger.error('Check failed', { error: error.message });
            await this.disconnectAll();
            return false;
        }
    }

    async query(dbType, sql, params = []) {
        if (!this.sourceConnected && dbType === 'source') {
            throw new Error('Source database not connected. Call connectAll() first.');
        }
        if (!this.targetConnected && dbType === 'target') {
            throw new Error('Target database not connected. Call connectAll() first.');
        }

        try {
            const db = dbType === 'source' ? this.sourceDb : this.targetDb;
            const result = await db.query(sql, params);
            return result;
        } catch (error) {
            logger.error(`Query failed (${dbType})`, { error: error.message });
            throw error;
        }
        // Artık connect/close yok, bağlantılar açık kalıyor
    }

    async run() {
        logger.info('Running migration template...');

        await this.connectAll();

        const isConnected = this.sourceConnected && this.targetConnected;
        if (isConnected) {
            logger.success('Database connections successful');
        } else {
            logger.error('Database connection failed');
            await this.disconnectAll();
            return;
        }

        // Alt sınıflar burada kendi migrasyon mantığını implement etmeli
        // Bu template'in run() metodu artık bağlantıları yönetiyor

        try {
            // Alt sınıfın spesifik run mantığını çağırmak için super.run() kullanılabilir ama şu an yok
            logger.info('Migration template run completed');
        } catch (error) {
            logger.error('Migration template run failed', { error: error.message });
        } finally {
            await this.disconnectAll();
        }
    }
}

module.exports = { MigrationTemplate };
