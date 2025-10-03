/*
# Customers Migration Step

Migrates customers and their addresses using batch processing.
Based on V1 customer migration logic adapted for V3 architecture.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const DataTransformer = require('../lib/data-transformer');
const { v4: uuidv4 } = require('uuid');

class CustomersStep {
    constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = eavMapper;
        this.defaultLanguageId = defaultLanguageId;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.customers.batchSize,
            parallelLimit: config.steps.customers.parallelLimit,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Customers migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.dataTransformer = new DataTransformer();
    }

    async run() {
        logger.info('Starting customers migration step...');

        try {
            // 1. Migrate customers with their addresses (tree structure)
            const result = await this.migrateCustomersWithAddresses();
            if (!result.success) {
                throw new Error('Customers and addresses migration failed');
            }

            // 2. Extract customer emails for password reset
            await this.extractCustomerEmails();

            logger.success(`Customers migration completed: ${result.customers} customers, ${result.addresses} addresses`);

            return {
                success: true,
                count: result.customers + result.addresses,
                customers: result.customers,
                addresses: result.addresses
            };

        } catch (error) {
            logger.error('Customers migration step failed', { error: error.message });
            throw error;
        }
    }

    async migrateCustomersWithAddresses() {
        logger.info('Starting customers and addresses migration (tree structure)...');

        try {
            // Query customers with their addresses using LEFT JOIN
            const customersWithAddressesQuery = `
                SELECT
                    ce.entity_id as customer_entity_id,
                    ce.email as customer_email,
                    ce.created_at as customer_created_at,
                    ce.updated_at as customer_updated_at,
                    ce.is_active as customer_is_active,
                    ce.firstname as customer_first_name,
                    ce.lastname as customer_last_name,
                    ce.middlename as customer_middlename,
                    ce.prefix as customer_prefix,
                    ce.suffix as customer_suffix,
                    ce.dob as customer_dob,
                    ce.gender as customer_gender,
                    ce.store_id as customer_store_id,
                    ce.website_id as customer_website_id,
                    ce.group_id as customer_group_id,
                    -- Address fields (will be NULL if no address exists)
                    cae.entity_id as address_entity_id,
                    cae.parent_id as address_parent_id,
                    cae.created_at as address_created_at,
                    cae.updated_at as address_updated_at,
                    cae.firstname as address_first_name,
                    cae.lastname as address_last_name,
                    cae.company as address_company,
                    cae.street as address_street,
                    cae.city as address_city,
                    cae.region as address_region,
                    cae.region_id as address_region_id,
                    cae.postcode as address_postcode,
                    cae.country_id as address_country_id,
                    cae.telephone as address_telephone,
                    cae.fax as address_fax
                FROM customer_entity ce
                LEFT JOIN customer_address_entity cae ON ce.entity_id = cae.parent_id
                ORDER BY ce.entity_id, cae.entity_id
            `;

            const customerAddressRows = await this.sourceDb.query(customersWithAddressesQuery);

            if (customerAddressRows.length === 0) {
                logger.warning('No customers found in source database');
                return { success: true, customers: 0, addresses: 0 };
            }

            logger.info(`Found ${customerAddressRows.length} customer-address rows to migrate`);

            // Group by customer entity_id to create customer objects with their addresses
            const customersMap = new Map();

            for (const row of customerAddressRows) {
                const customerId = row.customer_entity_id;

                if (!customersMap.has(customerId)) {
                    // Create customer object
                    customersMap.set(customerId, {
                        entity_id: row.customer_entity_id,
                        email: row.customer_email,
                        created_at: row.customer_created_at,
                        updated_at: row.customer_updated_at,
                        is_active: row.customer_is_active,
                        first_name: row.customer_first_name,
                        last_name: row.customer_last_name,
                        middlename: row.customer_middlename,
                        prefix: row.customer_prefix,
                        suffix: row.customer_suffix,
                        dob: row.customer_dob,
                        gender: row.customer_gender,
                        store_id: row.customer_store_id,
                        website_id: row.customer_website_id,
                        group_id: row.customer_group_id,
                        addresses: []
                    });
                }

                // Add address if it exists
                if (row.address_entity_id) {
                    customersMap.get(customerId).addresses.push({
                        entity_id: row.address_entity_id,
                        parent_id: row.address_parent_id,
                        created_at: row.address_created_at,
                        updated_at: row.address_updated_at,
                        firstname: row.address_first_name,
                        lastname: row.address_last_name,
                        company: row.address_company,
                        street: row.address_street,
                        city: row.address_city,
                        region: row.address_region,
                        region_id: row.address_region_id,
                        postcode: row.address_postcode,
                        country_id: row.address_country_id,
                        telephone: row.address_telephone,
                        fax: row.address_fax
                    });
                }
            }

            const customers = Array.from(customersMap.values());
            logger.info(`Grouped into ${customers.length} customers with their addresses`);

            // Get country mapping upfront (city mapping'i kaldırıyoruz çünkü city_name kullanacağız)
            const countries = await this.targetDb.query('SELECT id, iso_code_2 FROM countries');
            const countryMap = new Map(countries.map(c => [c.iso_code_2, c.id]));

            // Clean up duplicates before creating unique index for addresses
            await this.targetDb.query('DROP INDEX IF EXISTS idx_addresses_user_address');
            await this.targetDb.query('DELETE FROM addresses a USING (SELECT MIN(id) as min_id, user_id, address_line, COALESCE(post_code, \'\') as pc FROM addresses GROUP BY user_id, address_line, COALESCE(post_code, \'\') HAVING COUNT(*) > 1) b WHERE a.user_id = b.user_id AND a.address_line = b.pc AND a.id > b.min_id');

            // Create unique index for upsert functionality
            await this.targetDb.query('CREATE UNIQUE INDEX IF NOT EXISTS idx_addresses_user_address ON addresses (user_id, address_line, COALESCE(post_code, \'\'))');

            // Transform and migrate customers with addresses in batches
            let totalCustomers = 0;
            let totalAddresses = 0;
            let totalFailed = 0;

            const batchProcessor = new BatchProcessor({
                batchSize: this.config.steps.customers.batchSize,
                parallelLimit: this.config.steps.customers.parallelLimit,
                retryAttempts: this.config.processing.retryAttempts,
                retryDelay: this.config.processing.retryDelay,
                timeout: this.config.processing.timeout,
                onProgress: (progress, stats) => {
                    logger.info(`Customers migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
                }
            });

            await batchProcessor.process(customers, async (batch) => {
                const batchResult = await this.processCustomerWithAddressesBatch(batch, countryMap);
                totalCustomers += batchResult.customers;
                totalAddresses += batchResult.addresses;
                totalFailed += batchResult.failed;
                return { success: batchResult.customers + batchResult.addresses, failed: batchResult.failed };
            });

            logger.success(`Customers and addresses migration completed: ${totalCustomers} customers, ${totalAddresses} addresses migrated`);

            return {
                success: totalFailed === 0,
                customers: totalCustomers,
                addresses: totalAddresses
            };

        } catch (error) {
            logger.error('Customers and addresses migration failed', { error: error.message });
            return { success: false, customers: 0, addresses: 0 };
        }
    }

    async processCustomerWithAddressesBatch(customers, countryMap) {
        try {
            const transformedCustomers = [];
            const transformedAddresses = [];
            let skippedAddressesCount = 0;

            for (const customer of customers) {
                // Transform customer
                const transformedCustomer = {
                    id: uuidv4(),
                    user_code: `CUST-${customer.entity_id}`,
                    email: customer.email,
                    first_name: customer.first_name + (customer.middlename ? ` ${customer.middlename}` : ''),
                    last_name: customer.last_name || '',
                    company_name: null,
                    phone: null,
                    phone_code: null,
                    password: null,
                    is_view_price: true,
                    is_approved_for_credit_card: false,
                    is_approved_for_mailing: false,
                    is_locked_account: customer.is_active === 0 || customer.is_active === '0',
                    type: 'CUSTOMER',
                    created_at: customer.created_at,
                    updated_at: customer.updated_at,
                    last_signed_in: null,
                    password_reset_token: null,
                    password_reset_token_expires_at: null,
                    password_create_token: null,
                    password_create_token_expires_at: null,
                    signout: false,
                    is_subscribe_email: false,
                    language_id: this.defaultLanguageId,
                    is_mailchimp_subscribed: false
                };

                transformedCustomers.push(transformedCustomer);

                // Transform addresses for this customer
                for (const address of customer.addresses) {
                    // Lookup country ID from ISO code
                    const countryId = countryMap.get(address.country_id) || countryMap.get('US');
                    if (!countryId) {
                        skippedAddressesCount++;
                        continue;
                    }

                    // Parse street address
                    let addressLine = '';
                    let addressLine2 = null;
                    let addressLine3 = null;

                    if (address.street) {
                        const streetLines = address.street.split('\n').filter(line => line.trim());
                        addressLine = streetLines[0] || '';
                        addressLine2 = streetLines[1] || null;
                        addressLine3 = streetLines[2] || null;
                    }

                    transformedAddresses.push({
                        id: uuidv4(),
                        first_name: address.firstname || '',
                        last_name: address.lastname || '',
                        company_name: address.company,
                        phone: address.telephone,
                        phone_code: null,
                        address_line: addressLine,
                        address_line2: addressLine2,
                        address_line3: addressLine3,
                        post_code: address.postcode,
                        state_province: address.region,
                        town: address.city,
                        city_name: address.city, // city_name'e şehir adını doğrudan yazıyoruz
                        is_default: false,
                        user_id: transformedCustomer.id, // Reference the transformed customer
                        country_id: countryId,
                        created_at: address.created_at,
                        updated_at: address.updated_at
                    });
                }
            }

            // Insert customers first
            let insertedCustomers = 0;
            if (transformedCustomers.length > 0) {
                // Check for existing emails first to avoid conflicts
                const emails = transformedCustomers.map(c => c.email).filter(e => e);
                if (emails.length > 0) {
                    const existingUsers = await this.targetDb.query('SELECT email FROM users WHERE email = ANY($1)', [emails]);
                    const existingEmails = new Set(existingUsers.map(u => u.email));

                    // Filter out customers with existing emails
                    const newCustomers = transformedCustomers.filter(c => !existingEmails.has(c.email));

                    if (newCustomers.length > 0) {
                        const fieldCount = Object.keys(newCustomers[0]).length;
                        const placeholders = newCustomers.map((_, index) => {
                            const start = index * fieldCount + 1;
                            const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                            return `(${params.join(', ')})`;
                        }).join(', ');

                        const values = newCustomers.flatMap(c => Object.values(c));
                        const fields = Object.keys(newCustomers[0]).join(', ');
                        const insertQuery = `INSERT INTO users (${fields}) VALUES ${placeholders}`;

                        await this.targetDb.query(insertQuery, values);
                        insertedCustomers = newCustomers.length;
                        logger.info(`Inserted ${newCustomers.length} new customers, skipped ${transformedCustomers.length - newCustomers.length} existing`);
                    } else {
                        logger.info('All customers already exist, skipping insertion');
                    }
                }
            }

            // Get user_id mapping for all transformed customers (both inserted and existing)
            const userCodeToIdMap = new Map();
            if (transformedCustomers.length > 0) {
                const userCodes = transformedCustomers.map(c => c.user_code);
                const targetUsers = await this.targetDb.query('SELECT id, user_code FROM users WHERE user_code = ANY($1)', [userCodes]);
                targetUsers.forEach(u => {
                    userCodeToIdMap.set(u.user_code, u.id);
                });
            }

            // Insert addresses - filter duplicates within batch first
            let insertedAddresses = 0;
            if (transformedAddresses.length > 0) {
                // Update user_id in addresses to use actual target user_id
                const addressesWithCorrectUserId = transformedAddresses.map(address => {
                    // Find the customer that this address belongs to
                    const customer = transformedCustomers.find(c => c.id === address.user_id);
                    if (customer) {
                        const actualUserId = userCodeToIdMap.get(customer.user_code);
                        if (actualUserId) {
                            return { ...address, user_id: actualUserId };
                        }
                    }
                    return null; // Skip if user not found
                }).filter(a => a !== null);

                // Remove duplicates within this batch based on user_id, address_line, post_code
                const uniqueAddresses = [];
                const seen = new Set();

                for (const address of addressesWithCorrectUserId) {
                    const key = `${address.user_id}-${address.address_line}-${address.post_code || ''}`;
                    if (!seen.has(key)) {
                        seen.add(key);
                        uniqueAddresses.push(address);
                    }
                }

                if (uniqueAddresses.length > 0) {
                    const fieldCount = Object.keys(uniqueAddresses[0]).length;
                    const placeholders = uniqueAddresses.map((_, index) => {
                        const start = index * fieldCount + 1;
                        const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                        return `(${params.join(', ')})`;
                    }).join(', ');

                    const values = uniqueAddresses.flatMap(a => Object.values(a));
                    const fields = Object.keys(uniqueAddresses[0]).join(', ');
                    const insertQuery = `
                        INSERT INTO addresses (${fields})
                        VALUES ${placeholders}
                        ON CONFLICT (user_id, address_line, COALESCE(post_code, '')) DO NOTHING
                    `;

                    await this.targetDb.query(insertQuery, values);
                    insertedAddresses = uniqueAddresses.length;
                }
            }

            if (skippedAddressesCount > 0) {
                logger.info(`Batch skipped ${skippedAddressesCount} addresses due to missing country/city data`);
            }

            return {
                customers: insertedCustomers,
                addresses: insertedAddresses,
                failed: 0
            };

        } catch (error) {
            logger.error('Failed to process customer with addresses batch', { error: error.message, count: customers.length });
            return {
                customers: 0,
                addresses: 0,
                failed: customers.length
            };
        }
    }

    async extractCustomerEmails() {
        logger.info('Starting customer email extraction...');

        try {
            // Get all customer emails from target database
            const customers = await this.targetDb.query(
                'SELECT email, first_name, last_name FROM users WHERE type = $1 ORDER BY email',
                ['CUSTOMER']
            );

            if (customers.length === 0) {
                logger.warning('No customers found for email extraction');
                return;
            }

            // Create CSV content
            const csvHeader = 'Email,First Name,Last Name\n';
            const csvContent = customers.map(c =>
                `"${c.email}","${c.first_name || ''}","${c.last_name || ''}"`
            ).join('\n');
            const csvData = csvHeader + csvContent;

            // Write to file
            const fs = require('fs');
            const path = require('path');
            const outputPath = path.join(process.cwd(), 'customer_emails_for_password_reset.csv');
            fs.writeFileSync(outputPath, csvData, 'utf8');

            logger.success(`Customer emails extracted: ${customers.length} emails written to ${outputPath}`);

        } catch (error) {
            logger.error('Customer email extraction failed', { error: error.message });
        }
    }
}

module.exports = CustomersStep;
