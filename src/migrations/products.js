const { MigrationTemplate } = require('./template');
const logger = require('../logger');

class ProductsMigration extends MigrationTemplate {
    async run() {
        logger.info('Starting products migration...');

        try {
            // Read products data from source
            const products = await this.query('source', 'SELECT * FROM products');
            logger.info(`${products.length} products found`);

            if (products.length === 0) {
                logger.warning('Products table is empty or does not exist in source database');
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

            // Insert each product into target
            for (const product of products) {
                await this.query('target', `
                    INSERT INTO products (id, name, price, created_at)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT (id) DO UPDATE SET
                        name = EXCLUDED.name,
                        price = EXCLUDED.price,
                        created_at = EXCLUDED.created_at
                `, [product.id, product.name, product.price, product.created_at]);
            }

            logger.success('Products migration completed');
        } catch (error) {
            logger.error('Products migration failed', { error: error.message });
            // Continue even if error occurs, just log it
            logger.info('Migration continuing...');
        }
    }
}

module.exports = { default: ProductsMigration };
