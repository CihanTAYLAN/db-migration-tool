/**
 * Customers Migration Class
 *
 * Bu sınıf Magento'dan PostgreSQL'e müşteri verilerini migrate eder.
 * Customer bilgileri, adresler ve email extraction işlemlerini yönetir.
 *
 * Migrate edilen tablolar:
 * - users: Ana müşteri bilgileri
 * - addresses: Müşteri adres bilgileri
 * - orders: Sipariş bilgileri (opsiyonel)
 * - order_customers: Sipariş-müşteri ilişkileri (opsiyonel)
 */
const { MigrationTemplate } = require('./template');
const logger = require('../logger');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

class CustomersMigration extends MigrationTemplate {
    constructor() {
        // Environment değişkenlerini oku
        const sourceConnectionString = process.env.SOURCE_DATABASE_URL;
        const sourceDbType = process.env.SOURCE_DB_TYPE;
        const targetConnectionString = process.env.TARGET_DATABASE_URL;
        const targetDbType = process.env.TARGET_DB_TYPE;

        // Template'e parametreleri geç
        super(sourceConnectionString, sourceDbType, targetConnectionString, targetDbType);

        this.migrationStats = {
            startTime: null,
            endTime: null,
            sourceTables: [],
            targetTables: [],
            customersFound: 0,
            customersInserted: 0,
            addressesFound: 0,
            addressesInserted: 0,
            ordersFound: 0,
            ordersInserted: 0,
            emailsExtracted: 0,
            errors: []
        };
    }

    // Helper function to parse phone code from phone number
    parsePhoneCode(phoneNumber) {
        if (!phoneNumber || typeof phoneNumber !== 'string') {
            return null;
        }

        // Remove all non-numeric characters except + and spaces
        const cleaned = phoneNumber.replace(/[^\d+\s]/g, '').trim();

        // Common phone code patterns
        const patterns = [
            /^\+(\d{1,4})\s/,  // +90 555 123 45 67
            /^\+(\d{1,4})/,     // +905551234567
            /^00(\d{1,4})\s/,   // 0090 555 123 45 67
            /^00(\d{1,4})/,     // 00905551234567
        ];

        for (const pattern of patterns) {
            const match = cleaned.match(pattern);
            if (match && match[1]) {
                const code = match[1];
                // Validate common country codes
                const validCodes = ['1', '7', '20', '27', '30', '31', '32', '33', '34', '36', '39', '40', '41', '43', '44', '45', '46', '47', '48', '49', '51', '52', '53', '54', '55', '56', '57', '58', '60', '61', '62', '63', '64', '65', '66', '81', '82', '84', '86', '90', '91', '92', '93', '94', '95', '98'];
                if (validCodes.includes(code) || (code.length >= 2 && code.length <= 4)) {
                    return code;
                }
            }
        }

        return null;
    }

    async run() {
        this.migrationStats.startTime = new Date();
        logger.info('Starting customers migration...');

        await this.connectAll();

        if (!this.sourceConnected || !this.targetConnected) {
            logger.error('Database connections failed for customers migration');
            await this.disconnectAll();
            return;
        }

        try {
            // Customer migration
            await this.migrateCustomers();

            // Address migration
            await this.migrateAddresses();

            // Email extraction for password reset announcement
            await this.extractCustomerEmails();

            // Order migration (optional)
            // await this.migrateOrders();

            // Update migration statistics
            this.migrationStats.endTime = new Date();
            this.migrationStats.sourceTables = [
                'customer_entity',
                'customer_entity_varchar',
                'customer_entity_int',
                'customer_entity_datetime',
                'customer_entity_decimal',
                'customer_entity_text',
                'customer_address_entity',
                'customer_address_entity_varchar',
                'customer_address_entity_int',
                'customer_address_entity_datetime',
                'customer_address_entity_decimal',
                'customer_address_entity_text',
                'sales_order',
                'sales_order_address'
            ];
            this.migrationStats.targetTables = [
                'users',
                'addresses',
                'orders',
                'order_customers'
            ];

            // Generate migration report
            this.generateMigrationReport();

            logger.success('Customers migration completed');
        } catch (error) {
            this.migrationStats.errors.push({
                timestamp: new Date(),
                error: error.message,
                stack: error.stack
            });
            logger.error('Customers migration failed', { error: error.message });
        } finally {
            await this.disconnectAll();
        }
    }

    async migrateCustomers() {
        logger.info('Starting customer migration...');

        try {
            // Get English language ID from target database
            const englishLangResult = await this.query('target', 'SELECT id FROM languages WHERE code = \'en\' LIMIT 1');
            const englishLanguageId = englishLangResult && englishLangResult.length > 0 ? englishLangResult[0].id : null;

            if (!englishLanguageId) {
                logger.warning('English language not found in target database, using null for language_id');
            }

            // Get attribute IDs for customer EAV structure
            const firstNameAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "firstname" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer")');
            const firstNameAttrId = firstNameAttrResult && firstNameAttrResult.length > 0 ? firstNameAttrResult[0].attribute_id : null;

            const lastNameAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "lastname" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer")');
            const lastNameAttrId = lastNameAttrResult && lastNameAttrResult.length > 0 ? lastNameAttrResult[0].attribute_id : null;

            const companyAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "company" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer")');
            const companyAttrId = companyAttrResult && companyAttrResult.length > 0 ? companyAttrResult[0].attribute_id : null;

            // Try different attribute codes for telephone
            let telephoneAttrId = null;
            const telephoneCodes = ['telephone', 'phone', 'mobile', 'cellphone', 'phonenumber'];

            for (const code of telephoneCodes) {
                const result = await this.query('source', `SELECT attribute_id FROM eav_attribute WHERE attribute_code = "${code}" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer")`);
                if (result && result.length > 0) {
                    telephoneAttrId = result[0].attribute_id;
                    logger.info(`Found telephone attribute: ${code} (ID: ${telephoneAttrId})`);
                    break;
                }
            }

            if (!telephoneAttrId) {
                logger.warning('No telephone attribute found in EAV structure, trying direct table field');
            }

            logger.info(`Customer attribute IDs - firstname: ${firstNameAttrId}, lastname: ${lastNameAttrId}, company: ${companyAttrId}, telephone: ${telephoneAttrId}`);
            logger.info(`Target database - English language ID: ${englishLanguageId}`);

            // Query customers - try direct table field first, then EAV
            let customersQuery;
            let queryParams = [];

            if (telephoneAttrId) {
                // Use EAV structure if telephone attribute exists
                customersQuery = `
                    SELECT
                        ce.entity_id,
                        ce.email,
                        ce.created_at,
                        ce.updated_at,
                        ce.is_active,
                        ce.firstname as first_name,
                        ce.lastname as last_name,
                        ce.middlename,
                        ce.prefix,
                        ce.suffix,
                        ce.dob,
                        ce.gender,
                        ce.store_id,
                        ce.website_id,
                        ce.group_id,
                        cev_phone.value as telephone
                    FROM customer_entity ce
                    LEFT JOIN customer_entity_varchar cev_phone ON ce.entity_id = cev_phone.entity_id AND cev_phone.attribute_id = ?
                    ORDER BY ce.entity_id
                `;
                queryParams = [telephoneAttrId];
            } else {
                // Try direct table field if EAV doesn't work
                customersQuery = `
                    SELECT
                        ce.entity_id,
                        ce.email,
                        ce.created_at,
                        ce.updated_at,
                        ce.is_active,
                        ce.firstname as first_name,
                        ce.lastname as last_name,
                        ce.middlename,
                        ce.prefix,
                        ce.suffix,
                        ce.dob,
                        ce.gender,
                        ce.store_id,
                        ce.website_id,
                        ce.group_id,
                        NULL as telephone
                    FROM customer_entity ce
                    ORDER BY ce.entity_id
                `;
                logger.info('Using direct table fields for customer data (no EAV telephone found)');
            }

            const customers = await this.query('source', customersQuery, queryParams);
            logger.info(`${customers.length} customers found`);

            // Debug: Check phone information
            const customersWithPhone = customers.filter(c => c.telephone && c.telephone.trim() !== '');
            logger.info(`Customers with phone: ${customersWithPhone.length}/${customers.length}`);
            if (customersWithPhone.length > 0) {
                logger.info(`Sample phone numbers: ${customersWithPhone.slice(0, 3).map(c => c.telephone).join(', ')}`);
            }

            if (customers.length === 0) {
                logger.warning('No customers found in source database');
                return;
            }

            // Batch insert customers
            const BATCH_SIZE = 500;
            let insertedCount = 0;

            for (let i = 0; i < customers.length; i += BATCH_SIZE) {
                const batch = customers.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                const pgUsers = batch.map(c => {
                    const id = uuidv4();
                    // Parse phone code from phone number
                    const phoneCode = this.parsePhoneCode(c.telephone);

                    return {
                        id,
                        user_code: `CUST-${c.entity_id}`, // Generate user_code from entity_id
                        email: c.email,
                        first_name: c.first_name + (c.middlename ? ` ${c.middlename}` : ''),
                        last_name: c.last_name || '',
                        company_name: c.company_name,
                        phone: c.telephone,
                        phone_code: phoneCode,
                        password: null,
                        is_view_price: true,
                        is_approved_for_credit_card: false,
                        is_approved_for_mailing: false,
                        is_locked_account: c.is_active === 0 || c.is_active === '0',
                        type: 'CUSTOMER', // Use uppercase CUSTOMER as per enum
                        created_at: c.created_at,
                        updated_at: c.updated_at,
                        last_signed_in: null,
                        password_reset_token: null,
                        password_reset_token_expires_at: null,
                        password_create_token: null,
                        password_create_token_expires_at: null,
                        signout: false,
                        is_subscribe_email: false,
                        language_id: englishLanguageId, // Set default English language
                        is_mailchimp_subscribed: false
                    };
                });

                // Insert into users
                const fieldCount = Object.keys(pgUsers[0]).length;
                const placeholders = pgUsers.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = pgUsers.flatMap(u => Object.values(u));

                const fields = Object.keys(pgUsers[0]).join(', ');
                const insertQuery = `
                    INSERT INTO users (${fields})
                    VALUES ${placeholders}
                    ON CONFLICT (email) DO UPDATE SET
                        first_name = EXCLUDED.first_name,
                        last_name = EXCLUDED.last_name,
                        company_name = EXCLUDED.company_name,
                        phone = EXCLUDED.phone,
                        updated_at = EXCLUDED.updated_at
                `;

                await this.query('target', insertQuery, values);

                insertedCount += batch.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(customers.length / BATCH_SIZE)} completed (${insertedCount}/${customers.length} customers)`);
            }

            this.migrationStats.customersFound = customers.length;
            this.migrationStats.customersInserted = insertedCount;
            logger.success(`Customer migration completed: ${insertedCount} customers inserted/updated`);
        } catch (error) {
            logger.error('Customer migration failed', { error: error.message });
        }
    }

    async migrateAddresses() {
        logger.info('Starting address migration...');

        try {
            // Get customer mapping from target database
            const targetUsers = await this.query('target', 'SELECT id, email, first_name, last_name FROM users');
            const userMap = new Map(targetUsers.map(u => [u.email, { id: u.id, firstName: u.first_name, lastName: u.last_name }]));

            // Get country mapping from target database
            const countries = await this.query('target', 'SELECT id, iso_code_2 FROM countries');
            const countryMap = new Map(countries.map(c => [c.iso_code_2, c.id]));

            // Get city mapping from target database (simplified - using name matching)
            const cities = await this.query('target', 'SELECT id, name, country_id FROM cities');
            const cityMap = new Map();
            cities.forEach(city => {
                const key = `${city.name}-${city.country_id}`;
                cityMap.set(key, city.id);
            });

            // Get attribute IDs for address EAV structure
            const streetAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "street" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const streetAttrId = streetAttrResult && streetAttrResult.length > 0 ? streetAttrResult[0].attribute_id : null;

            const cityAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "city" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const cityAttrId = cityAttrResult && cityAttrResult.length > 0 ? cityAttrResult[0].attribute_id : null;

            const regionAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "region" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const regionAttrId = regionAttrResult && regionAttrResult.length > 0 ? regionAttrResult[0].attribute_id : null;

            const postcodeAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "postcode" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const postcodeAttrId = postcodeAttrResult && postcodeAttrResult.length > 0 ? postcodeAttrResult[0].attribute_id : null;

            const countryAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "country_id" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const countryAttrId = countryAttrResult && countryAttrResult.length > 0 ? countryAttrResult[0].attribute_id : null;

            const telephoneAttrResult = await this.query('source', 'SELECT attribute_id FROM eav_attribute WHERE attribute_code = "telephone" AND entity_type_id = (SELECT entity_type_id FROM eav_entity_type WHERE entity_type_code = "customer_address")');
            const telephoneAttrId = telephoneAttrResult && telephoneAttrResult.length > 0 ? telephoneAttrResult[0].attribute_id : null;

            logger.info(`Address attribute IDs - street: ${streetAttrId}, city: ${cityAttrId}, region: ${regionAttrId}, postcode: ${postcodeAttrId}, country: ${countryAttrId}, telephone: ${telephoneAttrId}`);

            // Query addresses directly from customer_address_entity table (Magento standard structure)
            const addressesQuery = `
                SELECT
                    cae.entity_id,
                    cae.parent_id as customer_id,
                    ce.email as customer_email,
                    cae.created_at,
                    cae.updated_at,
                    cae.firstname,
                    cae.lastname,
                    cae.company,
                    cae.street,
                    cae.city,
                    cae.region,
                    cae.region_id,
                    cae.postcode,
                    cae.country_id,
                    cae.telephone,
                    cae.fax
                FROM customer_address_entity cae
                JOIN customer_entity ce ON cae.parent_id = ce.entity_id
                ORDER BY cae.entity_id
            `;

            const addresses = await this.query('source', addressesQuery);
            logger.info(`${addresses.length} addresses found`);

            if (addresses.length === 0) {
                logger.warning('No addresses found in source database');
                return;
            }

            // Batch insert addresses
            const BATCH_SIZE = 500;
            let insertedCount = 0;

            for (let i = 0; i < addresses.length; i += BATCH_SIZE) {
                const batch = addresses.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                const pgAddresses = batch.map(a => {
                    const userData = userMap.get(a.customer_email);
                    if (!userData) return null;

                    // Lookup country ID from ISO code
                    const countryId = countryMap.get(a.country_id) || countryMap.get('US'); // Default to US if not found
                    if (!countryId) return null; // Skip if no valid country

                    // Lookup city ID (simplified - match by name and country)
                    const cityKey = `${a.city}-${countryId}`;
                    let cityId = cityMap.get(cityKey);

                    // If city not found, try to find any city in the country
                    if (!cityId) {
                        const citiesInCountry = cities.filter(c => c.country_id === countryId);
                        if (citiesInCountry.length > 0) {
                            cityId = citiesInCountry[0].id; // Use first city as default
                        }
                    }

                    if (!cityId) return null; // Skip if no valid city

                    // Parse street address - Magento stores it as multi-line or JSON
                    let addressLine = '';
                    let addressLine2 = null;
                    let addressLine3 = null;

                    if (a.street) {
                        // Try to parse multi-line street address
                        const streetLines = a.street.split('\n').filter(line => line.trim());
                        addressLine = streetLines[0] || '';
                        addressLine2 = streetLines[1] || null;
                        addressLine3 = streetLines[2] || null;
                    }

                    return {
                        id: uuidv4(),
                        first_name: a.firstname || userData.firstName || '',
                        last_name: a.lastname || userData.lastName || '',
                        company_name: a.company,
                        phone: a.telephone,
                        phone_code: null,
                        address_line: addressLine,
                        address_line2: addressLine2,
                        address_line3: addressLine3,
                        post_code: a.postcode,
                        state_province: a.region,
                        town: a.city,
                        is_default: false,
                        user_id: userData.id,
                        country_id: countryId,
                        city_id: cityId,
                        created_at: a.created_at,
                        updated_at: a.updated_at
                    };
                }).filter(a => a !== null);

                if (pgAddresses.length === 0) continue;

                // Insert into addresses
                const fieldCount = Object.keys(pgAddresses[0]).length;
                const placeholders = pgAddresses.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = pgAddresses.flatMap(a => Object.values(a));

                const fields = Object.keys(pgAddresses[0]).join(', ');
                const insertQuery = `
                    INSERT INTO addresses (${fields})
                    VALUES ${placeholders}
                    ON CONFLICT DO NOTHING
                `;

                await this.query('target', insertQuery, values);

                insertedCount += pgAddresses.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(addresses.length / BATCH_SIZE)} completed (${insertedCount} addresses)`);
            }

            this.migrationStats.addressesFound = addresses.length;
            this.migrationStats.addressesInserted = insertedCount;
            logger.success(`Address migration completed: ${insertedCount} addresses inserted`);
        } catch (error) {
            logger.error('Address migration failed', { error: error.message });
        }
    }

    async extractCustomerEmails() {
        logger.info('Starting customer email extraction for password reset announcement...');

        try {
            // Get all customer emails from target database
            const customers = await this.query('target', 'SELECT email, first_name, last_name FROM users WHERE type = \'CUSTOMER\' ORDER BY email');

            if (customers.length === 0) {
                logger.warning('No customers found for email extraction');
                return;
            }

            // Create CSV content
            const csvHeader = 'Email,First Name,Last Name\n';
            const csvContent = customers.map(c => `"${c.email}","${c.first_name || ''}","${c.last_name || ''}"`).join('\n');
            const csvData = csvHeader + csvContent;

            // Write to file
            const outputPath = path.join(process.cwd(), 'customer_emails_for_password_reset.csv');
            fs.writeFileSync(outputPath, csvData, 'utf8');

            this.migrationStats.emailsExtracted = customers.length;
            logger.success(`Customer emails extracted: ${customers.length} emails written to ${outputPath}`);
        } catch (error) {
            logger.error('Customer email extraction failed', { error: error.message });
        }
    }

    async migrateOrders() {
        logger.info('Starting order migration (optional)...');

        try {
            // Get customer mapping from target database
            const targetUsers = await this.query('target', 'SELECT id, email FROM users');
            const userMap = new Map(targetUsers.map(u => [u.email, u.id]));

            // Query orders with customer information
            const ordersQuery = `
                SELECT
                    so.entity_id,
                    so.increment_id,
                    so.customer_id,
                    ce.email as customer_email,
                    so.created_at,
                    so.updated_at,
                    so.status,
                    so.grand_total,
                    so.subtotal,
                    so.tax_amount,
                    so.shipping_amount,
                    so.discount_amount,
                    so.total_qty_ordered
                FROM sales_order so
                LEFT JOIN customer_entity ce ON so.customer_id = ce.entity_id
                ORDER BY so.entity_id
            `;

            const orders = await this.query('source', ordersQuery);
            logger.info(`${orders.length} orders found`);

            if (orders.length === 0) {
                logger.info('No orders found in source database');
                return;
            }

            // Batch insert orders
            const BATCH_SIZE = 500;
            let insertedCount = 0;

            for (let i = 0; i < orders.length; i += BATCH_SIZE) {
                const batch = orders.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                const pgOrders = batch.map(o => {
                    const userId = userMap.get(o.customer_email);
                    if (!userId) return null;

                    return {
                        id: uuidv4(),
                        order_no: o.increment_id,
                        payment_method: 'BANK_TRANSFER', // Default payment method
                        comment: null,
                        note: null,
                        order_customer_id: null,
                        tracking_number: null,
                        order_manual_id: null,
                        order_price_id: uuidv4(), // Generate a dummy order_price_id
                        status: o.status || 'PENDING',
                        invoice_date: null,
                        invoice_no: null,
                        invoice_url: null,
                        shipping_method: 'STANDARD', // Default shipping method
                        is_insurance: false,
                        is_send_order_confirmation_email: false,
                        user_id: userId,
                        total_amount: parseFloat(o.grand_total) || 0,
                        subtotal: parseFloat(o.subtotal) || 0,
                        tax_amount: parseFloat(o.tax_amount) || 0,
                        shipping_amount: parseFloat(o.shipping_amount) || 0,
                        discount_amount: parseFloat(o.discount_amount) || 0,
                        quantity: parseInt(o.total_qty_ordered) || 0,
                        created_at: o.created_at,
                        updated_at: o.updated_at
                    };
                }).filter(o => o !== null);

                if (pgOrders.length === 0) continue;

                // Insert into orders
                const fieldCount = Object.keys(pgOrders[0]).length;
                const placeholders = pgOrders.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = pgOrders.flatMap(o => Object.values(o));

                const fields = Object.keys(pgOrders[0]).join(', ');
                const insertQuery = `
                    INSERT INTO orders (${fields})
                    VALUES ${placeholders}
                    ON CONFLICT (order_no) DO UPDATE SET
                        status = EXCLUDED.status,
                        total_amount = EXCLUDED.total_amount,
                        updated_at = EXCLUDED.updated_at
                `;

                await this.query('target', insertQuery, values);

                insertedCount += pgOrders.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(orders.length / BATCH_SIZE)} completed (${insertedCount} orders)`);
            }

            this.migrationStats.ordersFound = orders.length;
            this.migrationStats.ordersInserted = insertedCount;
            logger.success(`Order migration completed: ${insertedCount} orders inserted/updated`);
        } catch (error) {
            logger.error('Order migration failed', { error: error.message });
        }
    }

    generateMigrationReport() {
        const duration = this.migrationStats.endTime - this.migrationStats.startTime;
        const durationInSeconds = Math.round(duration / 1000);

        // Helper function for consistent formatting
        const formatLine = (label, value) => {
            const maxLabelLength = 25;
            const maxValueLength = 50;
            const paddedLabel = label.padEnd(maxLabelLength);
            const paddedValue = value.toString().padEnd(maxValueLength);
            return `║ ${paddedLabel} ${paddedValue}`;
        };

        const formatTableItem = (item) => {
            const maxLength = 65;
            return `║   • ${item.padEnd(maxLength)}`;
        };

        // Enhanced terminal logging with better formatting
        logger.info('');
        logger.info('╔══════════════════════════════════════════════════════════════════════════════');
        logger.info('║                           📊 CUSTOMERS MIGRATION REPORT');
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info(formatLine('Migration Type:', 'Customers Migration'));
        logger.info(formatLine('Duration:', `${durationInSeconds} seconds`));
        logger.info(formatLine('Customers Found:', this.migrationStats.customersFound.toString()));
        logger.info(formatLine('Customers Inserted:', this.migrationStats.customersInserted.toString()));
        logger.info(formatLine('Addresses Found:', this.migrationStats.addressesFound.toString()));
        logger.info(formatLine('Addresses Inserted:', this.migrationStats.addressesInserted.toString()));
        logger.info(formatLine('Orders Found:', this.migrationStats.ordersFound.toString()));
        logger.info(formatLine('Orders Inserted:', this.migrationStats.ordersInserted.toString()));
        logger.info(formatLine('Emails Extracted:', this.migrationStats.emailsExtracted.toString()));
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Source Database Tables:');
        this.migrationStats.sourceTables.forEach(table => {
            logger.info(formatTableItem(table));
        });
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Target Database Tables:');
        this.migrationStats.targetTables.forEach(table => {
            logger.info(formatTableItem(table));
        });
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');
        logger.info('║ Additional Files:');
        logger.info(formatTableItem('customer_emails_for_password_reset.csv'));
        logger.info('╠══════════════════════════════════════════════════════════════════════════════');

        if (this.migrationStats.errors.length > 0) {
            logger.error('║ ❌ ERRORS OCCURRED:');
            this.migrationStats.errors.forEach((error, index) => {
                const errorMsg = `Error ${index + 1}: ${error.error}`.substring(0, 58);
                logger.error(`║   ${errorMsg.padEnd(67)}`);
            });
        } else {
            logger.success('MIGRATION COMPLETED SUCCESSFULLY');
        }

        logger.info('╚══════════════════════════════════════════════════════════════════════════════');
        logger.info('');

        return {
            success: this.migrationStats.errors.length === 0,
            duration: durationInSeconds,
            customersProcessed: this.migrationStats.customersInserted,
            addressesProcessed: this.migrationStats.addressesInserted,
            ordersProcessed: this.migrationStats.ordersInserted,
            emailsExtracted: this.migrationStats.emailsExtracted
        };
    }
}

module.exports = { default: CustomersMigration };
