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
            description: 'EAV attribute IDs and language setup'
        },
        categories: {
            enabled: true,
            description: 'Category migration with translations',
            batchSize: 50,
            parallelLimit: 1
        },
        products: {
            enabled: true,
            description: 'Product migration with translations',
            batchSize: 100,
            parallelLimit: 2
        },
        updateImagePaths: {
            enabled: true,
            description: 'Update product image paths with backend URL prefix',
            batchSize: 500,
            parallelLimit: 1
        },
        productMasterImagesUpdate: {
            enabled: true,
            description: 'Update product master image IDs and is_master flags',
            batchSize: 500,
            parallelLimit: 1
        },
        merge: {
            enabled: true,
            description: 'Subcategory merging',
            batchSize: 100,
            parallelLimit: 1
        },
        updateMasterCategoryIds: {
            enabled: true,
            description: 'Fix master_category_id NULL fields after merge',
            batchSize: 1000,
            parallelLimit: 1
        },
        customers: {
            enabled: true,
            description: 'Customer and address migration',
            batchSize: 500,
            parallelLimit: 1
        },
        orders: {
            enabled: true,
            description: 'Order migration with customers, items, prices, and addresses',
            batchSize: 50,
            parallelLimit: 2
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
