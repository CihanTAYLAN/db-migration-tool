/*
# Cert Coin Categories Step

Reads cert_coin_categories.csv and maps coins to categories based on cert-number and coin-number.
Performs category assignments for certification data.
*/

const logger = require('../../logger');
const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');

class CertCoinCategoriesStep {
  constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
    this.sourceDb = sourceDb;
    this.targetDb = targetDb;
    this.config = config;
    this.eavMapper = eavMapper;
    this.defaultLanguageId = defaultLanguageId;
    this.csvData = [];
  }

  async run() {
    logger.info('Starting cert coin categories mapping step...');

    try {
      // 1. Read CSV data
      await this.loadCsvData();

      if (this.csvData.length === 0) {
        logger.warning('No CSV data found to process');
        return { success: true, count: 0 };
      }

      logger.info(`Loaded ${this.csvData.length} certification records from CSV`);

      // 2. Process category mappings in batches
      const results = await this.processCertMappings();

      logger.success(`Cert coin categories mapping completed: ${results.totalMapped} mappings created`);

      return {
        success: true,
        count: results.totalMapped,
        productsUpdated: results.productsUpdated
      };

    } catch (error) {
      logger.error('Cert coin categories mapping step failed', { error: error.message });
      throw error;
    }
  }

  async loadCsvData() {
    const csvPath = path.join(__dirname, '../config/cert_coin_categories.csv');

    if (!fs.existsSync(csvPath)) {
      throw new Error(`CSV file not found: ${csvPath}`);
    }

    return new Promise((resolve, reject) => {
      const results = [];

      fs.createReadStream(csvPath)
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', () => {
          this.csvData = results;
          logger.info(`Successfully loaded ${results.length} records from CSV`);
          resolve();
        })
        .on('error', reject);
    });
  }

  async processCertMappings() {
    let totalMapped = 0;
    let productsUpdated = 0;

    // Group CSV data by cert-number and coin-number combinations
    const certCoinGroups = new Map();

    for (const row of this.csvData) {
      const key = `${row['cert-number']}_${row['coin-number']}`;
      if (!certCoinGroups.has(key)) {
        certCoinGroups.set(key, []);
      }
      certCoinGroups.get(key).push(row);
    }

    logger.info(`Processing ${certCoinGroups.size} unique cert-coin combinations`);

    for (const [certCoinKey, rows] of certCoinGroups) {

      try {
        logger.debug(`Processing cert-coin combination: ${certCoinKey}`);
        const [certNumber, coinNumber] = certCoinKey.split('_');

        // Find product by cert-number and coin-number
        const product = await this.findProductByCertAndCoin(certNumber);
        if (!product) {
          logger.debug(`Product not found for cert-number: ${certNumber}, coin-number: ${coinNumber}`);
          continue;
        }

        logger.debug(`Processing product ${product.id} (${product.product_web_sku})`);

        // Process each category mapping for this product
        for (const row of rows) {
          await this.mapProductToCategories(product, row);
          totalMapped++;
        }

        productsUpdated++;

        logger.debug(`Completed category mapping for product ${product.id}`);

      } catch (error) {
        logger.warning(`Failed to process cert-coin combination ${certCoinKey}`, {
          error: error.message
        });
      }
    }

    return { totalMapped, productsUpdated };
  }

  async findProductByCertAndCoin(certNumber) {
    // Find product by LIKE product_identity (as in your original code)
    const query = `
            SELECT id, product_web_sku, cert_number, coin_number, master_category_id
            FROM products
            WHERE product_identity LIKE $1
            LIMIT 1
        `;

    const result = await this.targetDb.query(query, [`%${certNumber}%`]);
    return result.length > 0 ? result[0] : null;
  }

  async mapProductToCategories(product, csvRow) {
    // Extract category names from CSV row
    const categories = [];

    if (csvRow['main-category']) categories.push(csvRow['main-category']);
    if (csvRow['sub-category-1']) categories.push(csvRow['sub-category-1']);
    if (csvRow['main-category-2']) categories.push(csvRow['main-category-2']);
    if (csvRow['sub-category-2']) categories.push(csvRow['sub-category-2']);

    logger.debug(`Product ${product.id}: Mapping categories: ${categories.join(', ')}`);

    if (categories.length === 0) {
      logger.debug(`No categories found in CSV row for product ${product.id}`);
      return;
    }

    // Find target categories by their slugs
    let categoryIds = [];
    for (const categorySlug of categories) {
      const categoryId = await this.findCategoryBySlug(categorySlug);
      if (categoryId) {
        categoryIds.push(categoryId);
      } else {
        logger.warning(`Category not found for slug: ${categorySlug} (product ${product.id})`);
      }
    }

    categoryIds = categoryIds.reverse(); // Reverse to maintain hierarchy order

    if (categoryIds.length === 0) {
      logger.warning(`No valid categories found for product ${product.id}`);
      return;
    }

    // Assign product to categories
    for (const categoryId of categoryIds) {
      await this.assignProductToCategory(product.id, categoryId);
    }

    // Update master category if not set and we found valid categories
    await this.updateProductMasterCategory(product.id, categoryIds[0], csvRow['cert-number'], csvRow['coin-number']);
    logger.debug(`Updated master category for product ${product.id} to ${categoryIds[0]}`);
  }

  async findCategoryBySlug(slug) {
    // Find category by slug in category_translations
    const query = `
            SELECT c.id
            FROM categories c
            JOIN category_translations ct ON c.id = ct.category_id
            WHERE (ct.slug = $1 OR ct.parent_slugs = $1) AND ct.language_id = $2
            LIMIT 1
        `;

    const result = await this.targetDb.query(query, [slug, this.defaultLanguageId]);
    return result.length > 0 ? result[0].id : null;
  }

  async assignProductToCategory(productId, categoryId) {
    // Check if relationship already exists before inserting
    const existsQuery = `
            SELECT 1 FROM product_categories
            WHERE product_id = $1 AND category_id = $2
            LIMIT 1
        `;

    const existing = await this.targetDb.query(existsQuery, [productId, categoryId]);

    if (existing.length === 0) {
      // Insert if not exists
      const insertQuery = `
                INSERT INTO product_categories (id, product_id, category_id, created_at, updated_at)
                VALUES ($1, $2, $3, NOW(), NOW())
            `;

      // Generate UUID for id column
      const id = require('uuid').v4();
      await this.targetDb.query(insertQuery, [id, productId, categoryId]);
      logger.debug(`Assigned product ${productId} to category ${categoryId}`);
    } else {
      logger.debug(`Product ${productId} already assigned to category ${categoryId} (skipping)`);
    }
  }

  async updateProductMasterCategory(productId, categoryId, certNumber, coinNumber) {
    const query = `
            UPDATE products
            SET master_category_id = $1, updated_at = NOW(),
            cert_number = $2,
            coin_number = $3
            WHERE id = $4
        `;

    await this.targetDb.query(query, [categoryId, certNumber, coinNumber, productId]);
  }
}

module.exports = CertCoinCategoriesStep;
