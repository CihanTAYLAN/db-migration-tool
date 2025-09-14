# MySQL to PostgreSQL Migration Tool

Bu araç, MySQL veritabanlarından PostgreSQL'e veri ve yapı migrasyonu yapmak için tasarlanmış CLI tabanlı bir uygulamadır.

## Özellikler

- 🔄 MySQL'den PostgreSQL'e tam veri migrasyonu
- 📊 Otomatik tip dönüşümü (MySQL → PostgreSQL)
- 🎯 Belirli tabloları seçerek migrasyon
- 📦 Batch işleme desteği
- 🔍 Bağlantı testleri
- 📋 Tablo listeleme
- 🛡️ Hata yönetimi ve raporlama
- 📁 **Özel Migrasyon Dosyaları**: Her tablo için ayrı migrasyon dosyası
- 🔗 **Çoklu Tablo Birleştirme**: Birden fazla source tablosundan veri çekme
- ⚡ **Dependency Yönetimi**: Migrasyon sıralaması ve bağımlılıklar
- 🎨 **Veri Dönüştürme**: Özel transform fonksiyonları

## Kurulum

```bash
# Bağımlılıkları yükle
yarn install

# Prisma client'larını oluştur
yarn generate

# Projeyi derle
yarn build
```

## Kullanım

### 1. Veritabanı Bağlantılarını Yapılandır

`.env` dosyasını düzenleyin:

```env
# MySQL bağlantısı (kaynak veritabanı)
MYSQL_DATABASE_URL="mysql://username:password@localhost:3306/source_db"

# PostgreSQL bağlantısı (hedef veritabanı)
POSTGRES_DATABASE_URL="postgresql://username:password@localhost:5432/target_db"
```

### 2. Bağlantıları Test Et

```bash
yarn start test-connection
```

### 3. MySQL Tablolarını Listele

```bash
yarn start list-tables
```

### 4. Migrasyon Başlat

#### Tüm tabloları migrate et:
```bash
yarn start migrate
```

#### Belirli tabloları migrate et:
```bash
yarn start migrate --tables users,products,orders
```

#### Batch size ile migrate et:
```bash
yarn start migrate --batch-size 500
```

#### Mevcut tabloları atlayarak migrate et:
```bash
yarn start migrate --skip-existing
```

## Komutlar

| Komut | Açıklama |
|-------|----------|
| `migrate` | Migrasyon işlemini başlatır |
| `list-tables` | MySQL'deki tabloları listeler |
| `list-migrations` | Özel migrasyon dosyalarını listeler |
| `test-connection` | Veritabanı bağlantılarını test eder |

## Seçenekler

### Migrate Komutu

- `-t, --tables <tables>`: Migrate edilecek tablolar (virgülle ayrılmış)
- `-b, --batch-size <size>`: Batch boyutu (varsayılan: 1000)
- `-s, --skip-existing`: Mevcut tabloları oluşturma

## Tip Dönüşümleri

Araç aşağıdaki tip dönüşümlerini otomatik olarak gerçekleştirir:

| MySQL Tipi | PostgreSQL Tipi |
|------------|-----------------|
| `INT` | `INTEGER` |
| `VARCHAR(n)` | `VARCHAR(n)` |
| `TEXT` | `TEXT` |
| `DATETIME` | `TIMESTAMP` |
| `DATE` | `DATE` |
| `DECIMAL` | `DECIMAL` |
| `FLOAT` | `REAL` |
| `DOUBLE` | `DOUBLE PRECISION` |
| `BIGINT` | `BIGINT` |
| `BLOB` | `BYTEA` |

## Geliştirme

### Development modunda çalıştırma:
```bash
yarn dev --help
```

### Kod derleme:
```bash
yarn build
```

### Prisma client'larını yeniden oluşturma:
```bash
yarn generate
```

## Özel Migrasyon Dosyaları

Bu araç, her tablo için ayrı migrasyon dosyası oluşturma özelliğine sahiptir. Bu sayede:

- **Çoklu Tablo Birleştirme**: Birden fazla MySQL tablosundan veri çekerek PostgreSQL'de tek tablo oluşturabilirsiniz
- **Veri Dönüştürme**: Özel transform fonksiyonları ile veriyi istediğiniz şekilde değiştirebilirsiniz
- **Dependency Yönetimi**: Migrasyonların birbirine bağımlı olduğu durumlarda sıralama yapabilirsiniz

### Migrasyon Dosyası Örneği

```typescript
// src/migrations/users.ts
import { MigrationConfig } from '../lib/migration-config';

export const config: MigrationConfig = {
    targetTable: 'users',
    description: 'Users tablosu için migrasyon',
    sourceTables: [
        {
            table: 'user_profiles',
            columns: ['id', 'first_name', 'last_name', 'email']
        },
        {
            table: 'user_accounts',
            columns: ['user_id', 'username', 'status'],
            join: {
                table: 'user_profiles',
                on: 'user_accounts.user_id = user_profiles.id',
                type: 'LEFT'
            }
        }
    ],
    transform: async (data: any[]) => {
        return data.map(row => ({
            id: row.id,
            username: row.username,
            full_name: `${row.first_name} ${row.last_name}`,
            email: row.email,
            status: row.status || 'active'
        }));
    }
};

export const execute = async (mysqlClient: any, postgresClient: any) => {
    // Özel migrasyon mantığı
};
```

### Özel Migrasyonları Listeleme

```bash
yarn start list-migrations
```

## Proje Yapısı

```
migration/
├── src/
│   ├── cli/
│   │   └── index.ts          # CLI arayüzü
│   ├── lib/
│   │   ├── database.ts       # Veritabanı bağlantıları
│   │   ├── migration.ts      # Migrasyon mantığı
│   │   └── migration-config.ts # Migrasyon yapılandırması
│   ├── migrations/           # Özel migrasyon dosyaları
│   │   ├── users.ts
│   │   └── products.ts
│   └── generated/            # Prisma client'ları
├── prisma/
│   ├── schema-mysql.prisma   # MySQL schema
│   └── schema-postgres.prisma # PostgreSQL schema
├── dist/                     # Derlenmiş kod
├── package.json
├── tsconfig.json
└── .env                      # Ortam değişkenleri
```

## Gereksinimler

- Node.js 16+
- MySQL 5.7+
- PostgreSQL 12+
- Yarn

## Lisans

ISC
