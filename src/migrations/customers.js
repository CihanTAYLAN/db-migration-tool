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

            // Order migration
            await this.migrateOrders();

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
                'sales_order_item',
                'sales_order_address'
            ];
            this.migrationStats.targetTables = [
                'users',
                'addresses',
                'orders',
                'order_items',
                'order_prices',
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

            // Clean up duplicates before creating unique index
            await this.query('target', 'DELETE FROM addresses a USING (SELECT MIN(id) as min_id, user_id, address_line, COALESCE(post_code, \'\') as pc FROM addresses GROUP BY user_id, address_line, COALESCE(post_code, \'\') HAVING COUNT(*) > 1) b WHERE a.user_id = b.user_id AND a.address_line = b.address_line AND COALESCE(a.post_code, \'\') = b.pc AND a.id > b.min_id');

            // Create unique index for upsert functionality
            await this.query('target', 'DROP INDEX IF EXISTS idx_addresses_user_address');
            await this.query('target', 'CREATE UNIQUE INDEX idx_addresses_user_address ON addresses (user_id, address_line, COALESCE(post_code, \'\'))');

            // Batch insert addresses
            const BATCH_SIZE = 500;
            let insertedCount = 0;

            for (let i = 0; i < addresses.length; i += BATCH_SIZE) {
                const batch = addresses.slice(i, i + BATCH_SIZE);
                const batchIndex = Math.floor(i / BATCH_SIZE) + 1;

                const addressMap = new Map();
                let skippedCount = 0;

                batch.forEach(a => {
                    const userData = userMap.get(a.customer_email);
                    if (!userData) {
                        skippedCount++;
                        return;
                    }

                    // Lookup country ID from ISO code
                    const countryId = countryMap.get(a.country_id) || countryMap.get('US'); // Default to US if not found
                    if (!countryId) {
                        skippedCount++;
                        return; // Skip if no valid country
                    }

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

                    if (!cityId) {
                        skippedCount++;
                        return; // Skip if no valid city
                    }

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

                    const postCode = a.postcode || '';
                    const key = `${userData.id}-${addressLine}-${postCode}`;

                    if (!addressMap.has(key)) {
                        addressMap.set(key, {
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
                        });
                    }
                });

                if (skippedCount > 0) {
                    logger.info(`Batch ${batchIndex}: ${skippedCount} addresses skipped due to missing user/country/city data`);
                }

                const pgAddresses = Array.from(addressMap.values());

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
                    ON CONFLICT (user_id, address_line, COALESCE(post_code, '')) DO UPDATE SET
                        first_name = EXCLUDED.first_name,
                        last_name = EXCLUDED.last_name,
                        company_name = EXCLUDED.company_name,
                        phone = EXCLUDED.phone,
                        phone_code = EXCLUDED.phone_code,
                        address_line2 = EXCLUDED.address_line2,
                        address_line3 = EXCLUDED.address_line3,
                        state_province = EXCLUDED.state_province,
                        town = EXCLUDED.town,
                        is_default = EXCLUDED.is_default,
                        country_id = EXCLUDED.country_id,
                        city_id = EXCLUDED.city_id,
                        updated_at = EXCLUDED.updated_at
                `;

                await this.query('target', insertQuery, values);

                insertedCount += pgAddresses.length;
                logger.info(`Batch ${batchIndex}/${Math.ceil(addresses.length / BATCH_SIZE)} completed (${insertedCount} addresses)`);
            }

            this.migrationStats.addressesFound = addresses.length;
            this.migrationStats.addressesInserted = insertedCount;
            logger.success(`Address migration completed: ${insertedCount} addresses inserted/updated`);
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
        logger.info('Starting order migration...');

        try {
            // Get customer mapping from target database
            const targetUsers = await this.query('target', 'SELECT id, email FROM users');
            const userMap = new Map(targetUsers.map(u => [u.email, u.id]));

            // Get existing guest mapping from target database
            const targetGuests = await this.query('target', 'SELECT id, guest_uuid FROM guests');
            const guestMap = new Map(targetGuests.map(g => [g.guest_uuid, g.id]));

            // Get currency mapping from target database
            const targetCurrencies = await this.query('target', 'SELECT id, code FROM currencies');
            const currencyMap = new Map(targetCurrencies.map(c => [c.code, c.id]));

            // Get product mapping from target database (SKU -> ID)
            const targetProducts = await this.query('target', 'SELECT id, product_sku FROM products');
            const productMap = new Map(targetProducts.map(p => [p.product_sku, p.id]));

            // Query orders with customer information
            const ordersQuery = `
                SELECT
                    so.entity_id,
                    so.increment_id,
                    so.customer_id,
                    ce.email as customer_email,
                    ce.firstname as customer_firstname,
                    ce.lastname as customer_lastname,
                    so.created_at,
                    so.updated_at,
                    so.status,
                    so.grand_total,
                    so.subtotal,
                    so.tax_amount,
                    so.shipping_amount,
                    so.discount_amount,
                    so.total_qty_ordered,
                    so.shipping_method,
                    so.payment_authorization_amount,
                    so.base_grand_total,
                    so.base_subtotal,
                    so.base_tax_amount,
                    so.base_shipping_amount,
                    so.base_discount_amount,
                    so.order_currency_code,
                    so.base_currency_code
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

                const pgOrders = [];
                const guestInserts = [];

                for (const o of batch) {
                    let userId = userMap.get(o.customer_email);
                    let guestId = null;
                    let customerType = 'LOGIN_USER';

                    // If no registered user found and email is not null, create/use guest
                    if (!userId && o.customer_email) {
                        guestId = await this.ensureGuestExists(o.customer_email, o.customer_firstname, o.customer_lastname, o.created_at, guestMap);
                        customerType = 'GUEST';
                    } else if (!userId && !o.customer_email) {
                        // Skip orders without email (likely test data or invalid guest orders)
                        continue;
                    }

                    // Create order customer record
                    const orderCustomerId = uuidv4();
                    const orderCustomer = {
                        id: orderCustomerId,
                        first_name: o.customer_firstname || '',
                        last_name: o.customer_lastname || '',
                        email: o.customer_email,
                        phone: null,
                        phone_code: null,
                        type: customerType,
                        created_at: o.created_at,
                        updated_at: o.updated_at,
                        user_id: userId,
                        guest_id: guestId
                    };

                    // Get currency information
                    const orderCurrencyCode = o.order_currency_code || 'AUD'; // Default to AUD if not found
                    const currencyId = currencyMap.get(orderCurrencyCode);

                    // Create order price record
                    const orderPriceId = uuidv4();
                    const orderPrice = {
                        id: orderPriceId,
                        subtotal_fee: parseFloat(o.base_subtotal) || 0,
                        shipping_fee: parseFloat(o.base_shipping_amount) || 0,
                        purchase_method_fee: 0,
                        additional_fee: 0,
                        additional_fee_description: null,
                        total_amount: parseFloat(o.base_grand_total) || 0,
                        insurance_fee: 0,
                        discount_fee: Math.abs(parseFloat(o.base_discount_amount) || 0),
                        currency_code: orderCurrencyCode,
                        final_price: parseFloat(o.base_grand_total) || 0,
                        created_at: o.created_at,
                        updated_at: o.updated_at,
                        currency_id: currencyId || null
                    };

                    pgOrders.push({
                        id: uuidv4(),
                        order_no: o.increment_id,
                        payment_method: 'BANK_TRANSFER', // Default payment method
                        comment: null,
                        note: null,
                        order_customer_id: orderCustomerId,
                        tracking_number: null,
                        order_manual_id: null,
                        order_price_id: orderPriceId,
                        status: this.mapOrderStatus(o.status),
                        invoice_date: null,
                        invoice_no: null,
                        invoice_url: null,
                        shipping_method: 'STANDARD', // Default shipping method
                        is_insurance: false,
                        is_send_order_confirmation_email: false,
                        created_at: o.created_at,
                        updated_at: o.updated_at,
                        _orderCustomer: orderCustomer, // Temporary storage for order customer
                        _orderPrice: orderPrice, // Temporary storage for order price
                        _sourceOrderId: o.entity_id // For order items lookup
                    });
                }

                if (pgOrders.length === 0) continue;

                // Insert order prices first
                const orderPrices = pgOrders.map(o => o._orderPrice);
                const priceFieldCount = Object.keys(orderPrices[0]).length;
                const pricePlaceholders = orderPrices.map((_, index) => {
                    const start = index * priceFieldCount + 1;
                    const params = Array.from({ length: priceFieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const priceValues = orderPrices.flatMap(p => Object.values(p));
                const priceFields = Object.keys(orderPrices[0]).join(', ');
                const priceInsertQuery = `INSERT INTO order_prices (${priceFields}) VALUES ${pricePlaceholders}`;

                await this.query('target', priceInsertQuery, priceValues);

                // Insert order customers
                const orderCustomers = pgOrders.map(o => o._orderCustomer);
                const customerFieldCount = Object.keys(orderCustomers[0]).length;
                const customerPlaceholders = orderCustomers.map((_, index) => {
                    const start = index * customerFieldCount + 1;
                    const params = Array.from({ length: customerFieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const customerValues = orderCustomers.flatMap(c => Object.values(c));
                const customerFields = Object.keys(orderCustomers[0]).join(', ');
                const customerInsertQuery = `INSERT INTO order_customers (${customerFields}) VALUES ${customerPlaceholders}`;

                await this.query('target', customerInsertQuery, customerValues);

                // Insert orders
                const orderFields = Object.keys(pgOrders[0]).filter(f => !f.startsWith('_'));
                const orderFieldCount = orderFields.length;
                const orderPlaceholders = pgOrders.map((_, index) => {
                    const start = index * orderFieldCount + 1;
                    const params = Array.from({ length: orderFieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const orderValues = pgOrders.flatMap(o => orderFields.map(f => o[f]));
                const orderInsertQuery = `
                    INSERT INTO orders (${orderFields.join(', ')})
                    VALUES ${orderPlaceholders}
                    ON CONFLICT (order_no) DO UPDATE SET
                        status = EXCLUDED.status,
                        updated_at = EXCLUDED.updated_at
                `;

                await this.query('target', orderInsertQuery, orderValues);

                // Migrate order items for this batch
                await this.migrateOrderItemsBatch(pgOrders.map(o => o._sourceOrderId), productMap);

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

    async ensureGuestExists(email, firstName, lastName, createdAt, guestMap) {
        // Generate deterministic UUID from email
        const guestUuid = uuidv4(email + 'guest');

        // Check if guest already exists in our map
        if (guestMap.has(guestUuid)) {
            return guestMap.get(guestUuid);
        }

        // Check if guest exists in database
        const existingGuest = await this.query('target', 'SELECT id FROM guests WHERE guest_uuid = $1', [guestUuid]);

        if (existingGuest && existingGuest.length > 0) {
            const guestId = existingGuest[0].id;
            guestMap.set(guestUuid, guestId); // Add to map for future use
            return guestId;
        }

        // Create new guest
        const guestId = uuidv4();
        const guest = {
            id: guestId,
            guest_uuid: guestUuid,
            first_name: firstName || 'Guest',
            last_name: lastName || 'User',
            email: email,
            phone: null,
            phone_code: null,
            ip_address: null,
            user_agent: null,
            device: null,
            device_type: 'desktop', // Default
            device_model: null,
            created_at: createdAt,
            updated_at: createdAt
        };

        // Insert guest
        const fields = Object.keys(guest).join(', ');
        const placeholders = Object.keys(guest).map((_, i) => `$${i + 1}`).join(', ');
        const values = Object.values(guest);

        await this.query('target', `INSERT INTO guests (${fields}) VALUES (${placeholders})`, values);

        // Add to map
        guestMap.set(guestUuid, guestId);

        logger.info(`Created guest for email: ${email} (ID: ${guestId})`);
        return guestId;
    }

    mapOrderStatus(magentoStatus) {
        const statusMap = {
            'pending': 'PENDING',
            'processing': 'PROCESSING',
            'complete': 'COMPLETE',
            'closed': 'COMPLETE',
            'canceled': 'CANCELED',
            'holded': 'ON_HOLD',
            'payment_review': 'PENDING' // Default to PENDING since PAYMENT_REVIEW doesn't exist
        };
        return statusMap[magentoStatus] || 'PENDING';
    }

    async migrateOrderItemsBatch(orderIds, productMap) {
        if (orderIds.length === 0) return;

        try {
            // Get target orders mapping
            const targetOrders = await this.query('target', `SELECT id, order_no FROM orders WHERE order_no IN (${orderIds.map((_, i) => `$${i + 1}`).join(', ')})`, orderIds);
            const orderIdMap = new Map(targetOrders.map(o => [o.order_no, o.id]));

            // Query order items
            const itemsQuery = `
                SELECT
                    soi.item_id,
                    soi.order_id,
                    so.increment_id as order_increment_id,
                    soi.product_id,
                    soi.sku,
                    soi.name,
                    soi.qty_ordered,
                    soi.price,
                    soi.base_price,
                    soi.row_total,
                    soi.base_row_total,
                    soi.product_type,
                    soi.created_at,
                    soi.updated_at
                FROM sales_order_item soi
                JOIN sales_order so ON soi.order_id = so.entity_id
                WHERE soi.order_id IN (${orderIds.map((_, i) => `$${i + 1}`).join(', ')})
                ORDER BY soi.item_id
            `;

            const orderItems = await this.query('source', itemsQuery, orderIds);

            if (orderItems.length === 0) return;

            // Batch insert order items
            const BATCH_SIZE = 500;
            let insertedCount = 0;

            for (let i = 0; i < orderItems.length; i += BATCH_SIZE) {
                const batch = orderItems.slice(i, i + BATCH_SIZE);

                const pgOrderItems = batch.map(item => {
                    const orderId = orderIdMap.get(item.order_increment_id);
                    const productId = productMap.get(item.sku);

                    if (!orderId || !productId) return null; // Skip if order or product not found

                    return {
                        id: uuidv4(),
                        provider_name: null,
                        provider_image: null,
                        coin_degree: null,
                        quantity: parseInt(item.qty_ordered) || 1,
                        price: parseFloat(item.price) || 0,
                        order_id: orderId,
                        product_id: productId,
                        created_at: item.created_at,
                        updated_at: item.updated_at
                    };
                }).filter(item => item !== null);

                if (pgOrderItems.length === 0) continue;

                // Insert order items
                const fieldCount = Object.keys(pgOrderItems[0]).length;
                const placeholders = pgOrderItems.map((_, index) => {
                    const start = index * fieldCount + 1;
                    const params = Array.from({ length: fieldCount }, (_, i) => `$${start + i}`);
                    return `(${params.join(', ')})`;
                }).join(', ');

                const values = pgOrderItems.flatMap(item => Object.values(item));
                const fields = Object.keys(pgOrderItems[0]).join(', ');
                const insertQuery = `INSERT INTO order_items (${fields}) VALUES ${placeholders}`;

                await this.query('target', insertQuery, values);

                insertedCount += pgOrderItems.length;
            }

            logger.info(`Migrated ${insertedCount} order items for orders: ${orderIds.join(', ')}`);
        } catch (error) {
            logger.error('Order items migration failed', { error: error.message });
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
