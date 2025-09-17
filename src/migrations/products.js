const { MigrationTemplate } = require('./template');
const logger = require('../logger');

class ProductsMigration extends MigrationTemplate {
    async run() {
        logger.info('Starting products migration...');

        await this.connectAll();

        if (!this.sourceConnected || !this.targetConnected) {
            logger.error('Database connections failed for products migration');
            await this.disconnectAll();
            return;
        }

        try {
            // Read products data from source
            const products = await this.query('source', 'SELECT * FROM products');
            logger.info(`${products.length} products found`);

            if (products.length === 0) {
                logger.warning('Products table is empty or does not exist in source database');
                await this.disconnectAll();
                return;
            }

            // Create products table in target (if not exists)
            await this.query('target', `
                CREATE TABLE IF NOT EXISTS products (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    price DECIMAL(10,2),
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            `);

            // Batch insert for better performance (chunks of 1000)
            const BATCH_SIZE = 1000;
            const totalBatches = Math.ceil(products.length / BATCH_SIZE);
            let insertedCount = 0;

            for (let i = 0; i < products.length; i += BATCH_SIZE) {
                const batch = products.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                // PostgreSQL için $1, $2, ... placeholder'ları oluştur
                const placeholders = batch.map((_, index) => `($${(index * 4) + 1}, $${(index * 4) + 2}, $${(index * 4) + 3}, $${(index * 4) + 4}`).join(', ');
                const values = batch.flatMap(product => [product.id, product.name, product.price || 0, product.created_at || new Date()]);

                const insertQuery = `
                    INSERT INTO products (id, name, price, created_at)
                    VALUES ${placeholders}
                    ON CONFLICT (id) DO UPDATE SET
                        name = EXCLUDED.name,
                        price = EXCLUDED.price,
                        created_at = EXCLUDED.created_at
                `;

                await this.query('target', insertQuery, values);
                insertedCount += batch.length;
                logger.info(`Batch ${batchIndex}/${totalBatches} completed (${insertedCount}/${products.length} products)`);
            }

            logger.success(`Products migration completed: ${insertedCount} products inserted/updated`);
        } catch (error) {
            logger.error('Products migration failed', { error: error.message });
            // Continue even if error occurs, just log it
            logger.info('Migration continuing...');
        } finally {
            await this.disconnectAll();
        }
    }
}

module.exports = { default: ProductsMigration };
