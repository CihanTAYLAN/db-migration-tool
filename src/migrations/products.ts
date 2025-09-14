export const config: any = {
    targetTable: 'products',
    description: 'Products tablosu için migrasyon - products, categories ve suppliers tablolarından veri birleştirerek',
    sourceTables: [
        {
            table: 'products',
            columns: ['id', 'name', 'description', 'price', 'sku', 'category_id', 'supplier_id', 'created_at']
        },
        {
            table: 'categories',
            columns: ['id', 'name as category_name'],
            join: {
                table: 'products',
                on: 'categories.id = products.category_id',
                type: 'LEFT'
            }
        },
        {
            table: 'suppliers',
            columns: ['id', 'name as supplier_name', 'contact_email'],
            join: {
                table: 'products',
                on: 'suppliers.id = products.supplier_id',
                type: 'LEFT'
            }
        }
    ],
    batchSize: 500,
    dependencies: ['categories', 'suppliers'], // Bu migrasyon için gerekli bağımlılıklar
    transform: async (data: any[]) => {
        // Verileri dönüştür ve zenginleştir
        return data.map(row => ({
            id: row.id,
            name: row.name,
            description: row.description,
            price: parseFloat(row.price) || 0,
            sku: row.sku,
            category_id: row.category_id,
            category_name: row.category_name,
            supplier_id: row.supplier_id,
            supplier_name: row.supplier_name,
            supplier_email: row.contact_email,
            price_category: parseFloat(row.price) > 100 ? 'premium' : 'standard',
            created_at: row.created_at,
            updated_at: new Date().toISOString()
        }));
    }
};

export async function execute(mysqlClient: any, postgresClient: any) {
    try {
        console.log('🚀 Starting products migration...');

        // Karmaşık SQL sorgusu - üç tabloyu birleştir
        const query = `
            SELECT
                p.id,
                p.name,
                p.description,
                p.price,
                p.sku,
                p.category_id,
                p.supplier_id,
                p.created_at,
                c.name as category_name,
                s.name as supplier_name,
                s.contact_email
            FROM products p
            LEFT JOIN categories c ON c.id = p.category_id
            LEFT JOIN suppliers s ON s.id = p.supplier_id
            WHERE p.status = 'active'
            ORDER BY p.id
        `;

        const data = await mysqlClient.$queryRawUnsafe(query);

        if (data.length === 0) {
            console.log('⚠️  No active products found for migration');
            return {
                success: true,
                recordsProcessed: 0,
                errors: []
            };
        }

        // Transform uygula
        const transformedData = await config.transform!(data);

        // PostgreSQL'de tablo oluştur
        const createTableSQL = `
            CREATE TABLE IF NOT EXISTS products (
                id INTEGER PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                description TEXT,
                price DECIMAL(10,2) DEFAULT 0,
                sku VARCHAR(100) UNIQUE,
                category_id INTEGER,
                category_name VARCHAR(255),
                supplier_id INTEGER,
                supplier_name VARCHAR(255),
                supplier_email VARCHAR(255),
                price_category VARCHAR(50),
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            );

            CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
            CREATE INDEX IF NOT EXISTS idx_products_supplier ON products(supplier_id);
            CREATE INDEX IF NOT EXISTS idx_products_price_category ON products(price_category);
        `;

        await postgresClient.$executeRawUnsafe(createTableSQL);

        // Verileri batch'ler halinde ekle
        const batchSize = config.batchSize || 500;
        let totalProcessed = 0;

        for (let i = 0; i < transformedData.length; i += batchSize) {
            const batch = transformedData.slice(i, i + batchSize);

            const columns = Object.keys(batch[0]);
            const values = batch.map((row: any) =>
                `(${columns.map(col => {
                    const value = row[col];
                    if (value === null || value === undefined) return 'NULL';
                    if (typeof value === 'string') return `'${value.replace(/'/g, "''")}'`;
                    if (typeof value === 'number') return value;
                    return `'${String(value)}'`;
                }).join(', ')})`
            ).join(', ');

            const insertSQL = `INSERT INTO products (${columns.join(', ')}) VALUES ${values} ON CONFLICT (id) DO NOTHING`;

            await postgresClient.$executeRawUnsafe(insertSQL);
            totalProcessed += batch.length;

            console.log(`📦 Processed batch ${Math.floor(i / batchSize) + 1}: ${batch.length} products`);
        }

        console.log(`✅ Products migration completed: ${totalProcessed} records processed`);

        return {
            success: true,
            recordsProcessed: totalProcessed,
            errors: []
        };

    } catch (error) {
        console.error('❌ Products migration failed:', error);
        return {
            success: false,
            recordsProcessed: 0,
            errors: [error instanceof Error ? error.message : String(error)]
        };
    }
};