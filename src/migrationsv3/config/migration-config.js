/*
# Migration V3 Configuration

Centralized configuration for MigrationV3 system.
All migration settings, database configs, and processing parameters.
*/

const config = {
    // Database configurations
    databases: {
        source: {
            url: process.env.SOURCE_DATABASE_URL,
            type: process.env.SOURCE_DB_TYPE || 'mysql'
        },
        target: {
            url: process.env.TARGET_DATABASE_URL,
            type: process.env.TARGET_DB_TYPE || 'postgresql'
        }
    },

    // Migration steps configuration
    steps: {
        prepare: {
            enabled: true,
            description: 'EAV attribute IDs and language setup',
            requiresSource: true,
            requiresTarget: true
        },
        blog_posts: {
            enabled: true,
            description: 'Blog posts migration with translations and content',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        updateBlogDescriptions: {
            enabled: false,
            description: 'Update content_translations description field from Mageplaza blog posts',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        categories: {
            enabled: true,
            description: 'Category migration with translations',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        products: {
            enabled: true,
            description: 'Product migration with translations',
            batchSize: 100,
            parallelLimit: 2,
            requiresSource: true,
            requiresTarget: true
        },
        merge: {
            enabled: true,
            description: 'Subcategory merging',
            batchSize: 100,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        certCoinCategories: {
            enabled: true,
            description: 'Map coins to certification categories from CSV data',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        updateMasterCategoryIds: {
            enabled: true,
            description: 'Fix master_category_id NULL fields after merge',
            batchSize: 1000,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        customers: {
            enabled: true,
            description: 'Customer and address migration',
            batchSize: 500,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        orders: {
            enabled: true,
            description: 'Order migration with customers, items, prices, and addresses',
            batchSize: 50,
            parallelLimit: 2,
            requiresSource: true,
            requiresTarget: true
        },
        translation: {
            enabled: false,
            description: 'Batch translation of all categories and products to all available languages',
            batchSize: 100,
            parallelLimit: 2,
            requiresSource: false,
            requiresTarget: true
        },
        contentTranslation: {
            enabled: false,
            description: 'Batch translation of all content pages to all available languages',
            batchSize: 50,
            parallelLimit: 2,
            requiresSource: false,
            requiresTarget: true
        },
        deduplicateProductTranslations: {
            enabled: false,
            description: 'Deduplicate product translations by adding random suffix to duplicate slugs with same language_id',
            batchSize: 500,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        replaceImageUrls: {
            enabled: false,
            description: 'Replace image URLs for production domain in product_images table',
            batchSize: 200,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        updateProducts: {
            enabled: false,
            description: 'Update product fields (is_active, status, quantity, price, sold_date, archived_at, sold_price) from source database',
            batchSize: 100,
            parallelLimit: 1,
            requiresSource: true,
            requiresTarget: true
        },
        fixContentUrls: {
            enabled: false,
            description: 'Fix swapped slug and description fields in content_translations table for non-English languages',
            batchSize: 200,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        fixJapaneseSlugs: {
            enabled: false,
            description: 'Convert Japanese slugs to Romaji (Latin script) for better URL compatibility',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        },
        fixGermanSlugs: {
            enabled: false,
            description: 'Convert German umlauts and special characters in slugs to URL-friendly format',
            batchSize: 50,
            parallelLimit: 1,
            requiresSource: false,
            requiresTarget: true
        }
    },

    // Data processing settings
    processing: {
        retryAttempts: 3,
        retryDelay: 1000, // ms
        timeout: 300000, // 5 minutes
        memoryLimit: '1GB'
    },

    // EAV attribute mappings
    eavAttributes: {
        catalog_category: [
            'name', 'url_key', 'description', 'meta_title',
            'meta_description', 'meta_keywords', 'is_active'
        ],
        catalog_product: [
            'name', 'price', 'description', 'short_description',
            'image', 'url_key', 'meta_title', 'meta_description',
            'certification_number', 'coin_number', 'grade_prefix',
            'grade_value', 'grade_suffix', 'year'
        ],
        catalog_product_media: [
            'image', 'small_image', 'thumbnail'
        ]
    },

    // Data filters
    filters: {
        excludedCategoryIds: [1, 2, 3, 5, 6, 151], // Root, Default, Coins for sale, Members only, etc.
        excludedProductSkus: ['1956SET-4', '1962SET', '1966SET-2', '1963SET', '1974SET', '1958SET', 'PCGSbox'], // Set products and accessories to exclude
        productTypes: ['simple'],
        orderStatuses: ['complete', 'a_complete']
    },

    // Logging configuration
    logging: {
        level: process.env.LOG_LEVEL || 'info',
        enableProgress: true,
        progressInterval: 5000 // ms
    },

    // Performance tuning
    performance: {
        enableConnectionPooling: true,
        poolSize: 10,
        statementCacheSize: 100,
        fetchSize: 1000
    }
};

module.exports = config;
