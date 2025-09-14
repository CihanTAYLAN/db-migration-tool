export const usersConfig: any = {
    targetTable: 'users',
    description: 'Users tablosu için migrasyon - user_profiles ve user_accounts tablolarından veri birleştirerek',
    sourceTables: [
        {
            table: 'user_profiles',
            columns: ['id', 'first_name', 'last_name', 'email', 'phone', 'created_at', 'updated_at']
        },
        {
            table: 'user_accounts',
            columns: ['user_id', 'username', 'status', 'role'],
            join: {
                table: 'user_profiles',
                on: 'user_accounts.user_id = user_profiles.id',
                type: 'LEFT'
            }
        }
    ],
    batchSize: 1000,
    transform: async (data: any[]) => {
        // Verileri dönüştür ve birleştir
        return data.map(row => ({
            id: row.id,
            username: row.username,
            first_name: row.first_name,
            last_name: row.last_name,
            email: row.email,
            phone: row.phone,
            status: row.status || 'active',
            role: row.role || 'user',
            full_name: `${row.first_name} ${row.last_name}`.trim(),
            created_at: row.created_at,
            updated_at: row.updated_at
        }));
    }
};

export async function execute(mysqlClient: any, postgresClient: any) {
    try {
        console.log('🚀 Starting users migration...');

        // SQL sorgusu oluştur - birden fazla tablodan veri çek
        const query = `
            SELECT
                up.id,
                up.first_name,
                up.last_name,
                up.email,
                up.phone,
                up.created_at,
                up.updated_at,
                ua.username,
                ua.status,
                ua.role
            FROM user_profiles up
            LEFT JOIN user_accounts ua ON ua.user_id = up.id
            ORDER BY up.id
        `;

        const data = await mysqlClient.$queryRawUnsafe(query);

        if (data.length === 0) {
            console.log('⚠️  No data found for users migration');
            return {
                success: true,
                recordsProcessed: 0,
                errors: []
            };
        }

        // Transform uygula
        const transformedData = await usersConfig.transform!(data);

        // PostgreSQL'de tablo oluştur (eğer yoksa)
        const createTableSQL = `
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY,
                username VARCHAR(255),
                first_name VARCHAR(255),
                last_name VARCHAR(255),
                email VARCHAR(255) UNIQUE,
                phone VARCHAR(50),
                status VARCHAR(50) DEFAULT 'active',
                role VARCHAR(50) DEFAULT 'user',
                full_name VARCHAR(255),
                created_at TIMESTAMP,
                updated_at TIMESTAMP
            )
        `;

        await postgresClient.$executeRawUnsafe(createTableSQL);

        // Verileri ekle
        const columns = Object.keys(transformedData[0]);
        const values = transformedData.map((row: any) =>
            `(${columns.map(col => {
                const value = row[col];
                if (value === null || value === undefined) return 'NULL';
                if (typeof value === 'string') return `'${value.replace(/'/g, "''")}'`;
                return value;
            }).join(', ')})`
        ).join(', ');

        const insertSQL = `INSERT INTO users (${columns.join(', ')}) VALUES ${values} ON CONFLICT (id) DO NOTHING`;

        await postgresClient.$executeRawUnsafe(insertSQL);

        console.log(`✅ Users migration completed: ${transformedData.length} records processed`);

        return {
            success: true,
            recordsProcessed: transformedData.length,
            errors: []
        };

    } catch (error) {
        console.error('❌ Users migration failed:', error);
        return {
            success: false,
            recordsProcessed: 0,
            errors: [error instanceof Error ? error.message : String(error)]
        };
    }
};
