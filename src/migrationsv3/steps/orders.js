/*
# Orders Migration Step

Migrates orders with their customers, items, prices, and addresses using batch processing.
Based on Magento sales_order, sales_order_item, and sales_order_address tables.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');
const DataTransformer = require('../lib/data-transformer');
const { v4: uuidv4 } = require('uuid');

class OrdersStep {
    constructor(sourceDb, targetDb, config, eavMapper, defaultLanguageId) {
        this.sourceDb = sourceDb;
        this.targetDb = targetDb;
        this.config = config;
        this.eavMapper = eavMapper;
        this.defaultLanguageId = defaultLanguageId;
        this.batchProcessor = new BatchProcessor({
            batchSize: config.steps.orders?.batchSize || 50,
            parallelLimit: config.steps.orders?.parallelLimit || 2,
            retryAttempts: config.processing.retryAttempts,
            retryDelay: config.processing.retryDelay,
            timeout: config.processing.timeout,
            onProgress: (progress, stats) => {
                logger.info(`Orders migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
            }
        });
        this.dataTransformer = new DataTransformer();
    }

    async run() {
        logger.info('Starting orders migration step...');

        try {
            // 1. Migrate orders with their relations (tree structure)
            const result = await this.migrateOrdersWithRelations();
            if (!result.success) {
                throw new Error('Orders migration failed');
            }

            logger.success(`Orders migration completed: ${result.orders} orders, ${result.customers} customers, ${result.items} items, ${result.addresses} addresses`);

            return {
                success: true,
                count: result.orders + result.customers + result.items + result.addresses,
                orders: result.orders,
                customers: result.customers,
                items: result.items,
                addresses: result.addresses
            };

        } catch (error) {
            logger.error('Orders migration step failed', { error: error.message });
            throw error;
        }
    }

    async migrateOrdersWithRelations() {
        logger.info('Starting orders migration with relations (tree structure)...');

        try {
            // Query orders with their items and addresses using JOINs
            const ordersQuery = `
                SELECT
                    -- Order fields
                    so.entity_id as order_entity_id,
                    so.increment_id as order_increment_id,
                    so.customer_id as order_customer_id,
                    so.customer_is_guest as order_customer_is_guest,
                    so.customer_email as order_customer_email,
                    so.customer_firstname as order_customer_firstname,
                    so.customer_lastname as order_customer_lastname,
                    so.grand_total as order_grand_total,
                    so.subtotal as order_subtotal,
                    so.shipping_amount as order_shipping_amount,
                    so.tax_amount as order_tax_amount,
                    so.discount_amount as order_discount_amount,
                    so.status as order_status,
                    so.state as order_state,
                    so.created_at as order_created_at,
                    so.updated_at as order_updated_at,
                    so.store_id as order_store_id,
                    so.order_currency_code as order_currency_code,
                    -- Item fields
                    soi.item_id as item_item_id,
                    soi.product_id as item_product_id,
                    soi.sku as item_sku,
                    soi.name as item_name,
                    soi.qty_ordered as item_qty_ordered,
                    soi.price as item_price,
                    soi.base_price as item_base_price,
                    soi.row_total as item_row_total,
                    soi.base_row_total as item_base_row_total,
                    -- Address fields (shipping)
                    soa.entity_id as address_entity_id,
                    soa.parent_id as address_parent_id,
                    soa.address_type as address_address_type,
                    soa.firstname as address_firstname,
                    soa.lastname as address_lastname,
                    soa.company as address_company,
                    soa.street as address_street,
                    soa.city as address_city,
                    soa.region as address_region,
                    soa.postcode as address_postcode,
                    soa.country_id as address_country_id,
                    soa.telephone as address_telephone,
                    soa.email as address_email
                FROM sales_order so
                LEFT JOIN sales_order_item soi ON so.entity_id = soi.order_id
                LEFT JOIN sales_order_address soa ON so.entity_id = soa.parent_id AND soa.address_type = 'shipping'
                WHERE so.status NOT IN ('canceled', 'closed')
                ORDER BY so.entity_id, soi.item_id, soa.entity_id
            `;

            const orderRows = await this.sourceDb.query(ordersQuery);

            if (orderRows.length === 0) {
                logger.warning('No orders found in source database');
                return { success: true, orders: 0, customers: 0, items: 0, addresses: 0 };
            }

            logger.info(`Found ${orderRows.length} order-item-address rows to migrate`);

            // Group by order entity_id to create order objects with their relations
            const ordersMap = new Map();

            for (const row of orderRows) {
                const orderId = row.order_entity_id;

                if (!ordersMap.has(orderId)) {
                    // Create order object
                    ordersMap.set(orderId, {
                        entity_id: row.order_entity_id,
                        increment_id: row.order_increment_id,
                        customer_id: row.order_customer_id,
                        customer_is_guest: row.order_customer_is_guest,
                        customer_email: row.order_customer_email,
                        customer_firstname: row.order_customer_firstname,
                        customer_lastname: row.order_customer_lastname,
                        grand_total: row.order_grand_total,
                        subtotal: row.order_subtotal,
                        shipping_amount: row.order_shipping_amount,
                        tax_amount: row.order_tax_amount,
                        discount_amount: row.order_discount_amount,
                        status: row.order_status,
                        state: row.order_state,
                        created_at: row.order_created_at,
                        updated_at: row.order_updated_at,
                        store_id: row.order_store_id,
                        order_currency_code: row.order_currency_code,
                        items: [],
                        shipping_address: null
                    });
                }

                const order = ordersMap.get(orderId);

                // Add item if it exists and not already added
                if (row.item_item_id && !order.items.find(item => item.item_id === row.item_item_id)) {
                    order.items.push({
                        item_id: row.item_item_id,
                        product_id: row.item_product_id,
                        sku: row.item_sku,
                        name: row.item_name,
                        qty_ordered: row.item_qty_ordered,
                        price: row.item_price,
                        base_price: row.item_base_price,
                        row_total: row.item_row_total,
                        base_row_total: row.item_base_row_total
                    });
                }

                // Add shipping address if it exists
                if (row.address_entity_id && row.address_address_type === 'shipping' && !order.shipping_address) {
                    order.shipping_address = {
                        entity_id: row.address_entity_id,
                        parent_id: row.address_parent_id,
                        address_type: row.address_address_type,
                        firstname: row.address_firstname,
                        lastname: row.address_lastname,
                        company: row.address_company,
                        street: row.address_street,
                        city: row.address_city,
                        region: row.address_region,
                        postcode: row.address_postcode,
                        country_id: row.address_country_id,
                        telephone: row.address_telephone,
                        email: row.address_email
                    };
                }
            }

            const orders = Array.from(ordersMap.values());
            logger.info(`Grouped into ${orders.length} orders with their relations`);

            // Get mappings upfront
            const userCodeToIdMap = await this.getUserMapping();
            const productSkuToIdMap = await this.getProductMapping();
            const countryMap = await this.getCountryMapping();
            const currencyMap = await this.getCurrencyMapping();

            // Transform and migrate orders with relations in batches
            let totalOrders = 0;
            let totalCustomers = 0;
            let totalItems = 0;
            let totalAddresses = 0;
            let totalFailed = 0;

            const batchProcessor = new BatchProcessor({
                batchSize: this.config.steps.orders?.batchSize || 50,
                parallelLimit: this.config.steps.orders?.parallelLimit || 2,
                retryAttempts: this.config.processing.retryAttempts,
                retryDelay: this.config.processing.retryDelay,
                timeout: this.config.processing.timeout,
                onProgress: (progress, stats) => {
                    logger.info(`Orders migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
                }
            });

            await batchProcessor.process(orders, async (batch) => {
                const batchResult = await this.processOrderWithRelationsBatch(
                    batch, userCodeToIdMap, productSkuToIdMap, countryMap, currencyMap
                );
                totalOrders += batchResult.orders;
                totalCustomers += batchResult.customers;
                totalItems += batchResult.items;
                totalAddresses += batchResult.addresses;
                totalFailed += batchResult.failed;
                return { success: batchResult.orders, failed: batchResult.failed };
            });

            logger.success(`Orders migration completed: ${totalOrders} orders, ${totalCustomers} customers, ${totalItems} items, ${totalAddresses} addresses`);

            return {
                success: totalFailed === 0,
                orders: totalOrders,
                customers: totalCustomers,
                items: totalItems,
                addresses: totalAddresses
            };

        } catch (error) {
            logger.error('Orders migration failed', { error: error.message });
            return { success: false, orders: 0, customers: 0, items: 0, addresses: 0 };
        }
    }

    async getUserMapping() {
        const targetUsers = await this.targetDb.query('SELECT id, user_code FROM users WHERE type = $1', ['CUSTOMER']);
        const userCodeToIdMap = new Map();
        targetUsers.forEach(u => {
            if (u.user_code && u.user_code.startsWith('CUST-')) {
                const entityId = u.user_code.replace('CUST-', '');
                userCodeToIdMap.set(entityId, u.id);
            }
        });
        return userCodeToIdMap;
    }

    async getProductMapping() {
        const targetProducts = await this.targetDb.query('SELECT id, product_sku FROM products');
        const productSkuToIdMap = new Map();
        targetProducts.forEach(p => {
            productSkuToIdMap.set(p.product_sku, p.id);
        });
        return productSkuToIdMap;
    }

    async getCountryMapping() {
        const countries = await this.targetDb.query('SELECT id, iso_code_2 FROM countries');
        return new Map(countries.map(c => [c.iso_code_2, c.id]));
    }

    async getCityMapping() {
        const cities = await this.targetDb.query('SELECT id, name, country_id FROM cities');
        const cityMap = new Map();
        cities.forEach(city => {
            const key = `${city.name}-${city.country_id}`;
            cityMap.set(key, city.id);
        });
        return cityMap;
    }

    async getCurrencyMapping() {
        const currencies = await this.targetDb.query('SELECT id, code FROM currencies');
        return new Map(currencies.map(c => [c.code, c.id]));
    }

    async processOrderWithRelationsBatch(orders, userCodeToIdMap, productSkuToIdMap, countryMap, currencyMap) {
        try {
            let ordersInserted = 0;
            let customersInserted = 0;
            let itemsInserted = 0;
            let addressesInserted = 0;

            for (const order of orders) {
                // Validate order has required data
                if (!order.increment_id) {
                    logger.debug(`Skipping order ${order.entity_id}: missing increment_id`);
                    continue;
                }

                if (!order.customer_email) {
                    logger.debug(`Skipping order ${order.entity_id}: missing customer email`);
                    continue;
                }

                if (order.items.length === 0) {
                    logger.debug(`Skipping order ${order.entity_id}: no items`);
                    continue;
                }

                if (!order.shipping_address) {
                    logger.debug(`Skipping order ${order.entity_id}: no shipping address`);
                    continue;
                }

                // Transform order customer
                const orderCustomerId = uuidv4();
                let userId = null;
                let guestId = null;

                if (order.customer_is_guest === 1 || !order.customer_id) {
                    // Guest customer - insert to guests table first
                    guestId = uuidv4();
                    const guestData = {
                        id: guestId,
                        email: order.customer_email,
                        first_name: order.customer_firstname || '',
                        last_name: order.customer_lastname || '',
                        phone: null,
                        phone_code: null,
                        user_agent: null,
                        device: null,
                        device_type: null,
                        device_model: null,
                        ip_address: null,
                        guest_uuid: uuidv4(),
                        created_at: order.created_at,
                        updated_at: order.updated_at
                    };

                    await this.targetDb.query(`
                        INSERT INTO guests (id, email, first_name, last_name, phone, phone_code, user_agent, device, device_type, device_model, ip_address, guest_uuid, created_at, updated_at)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                    `, Object.values(guestData));
                } else {
                    // Registered customer - find user_id by customer entity_id
                    userId = userCodeToIdMap.get(order.customer_id?.toString());
                    if (!userId) {
                        logger.debug(`Order ${order.entity_id}: Customer ${order.customer_id} not found, treating as guest`);
                        // Insert as guest
                        guestId = uuidv4();
                        const guestData = {
                            id: guestId,
                            email: order.customer_email,
                            first_name: order.customer_firstname || '',
                            last_name: order.customer_lastname || '',
                            phone: null,
                            phone_code: null,
                            user_agent: null,
                            device: null,
                            device_type: null,
                            device_model: null,
                            ip_address: null,
                            guest_uuid: uuidv4(),
                            created_at: order.created_at,
                            updated_at: order.updated_at
                        };

                        await this.targetDb.query(`
                            INSERT INTO guests (id, email, first_name, last_name, phone, phone_code, user_agent, device, device_type, device_model, ip_address, guest_uuid, created_at, updated_at)
                            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                        `, Object.values(guestData));
                        userId = null;
                    }
                }

                const orderCustomer = {
                    id: orderCustomerId,
                    user_id: userId,
                    guest_id: guestId,
                    first_name: order.customer_firstname || '',
                    last_name: order.customer_lastname || '',
                    email: order.customer_email,
                    phone: null,
                    phone_code: null,
                    type: userId ? 'LOGIN_USER' : 'GUEST',
                    created_at: order.created_at,
                    updated_at: order.updated_at
                };

                // Transform order price
                const orderPriceId = uuidv4();
                const currencyId = currencyMap.get(order.order_currency_code) || currencyMap.get('USD');
                const currencyCode = order.order_currency_code || 'USD';
                const orderPrice = {
                    id: orderPriceId,
                    total_amount: parseFloat(order.grand_total) || 0,
                    subtotal_fee: parseFloat(order.subtotal) || 0,
                    shipping_fee: parseFloat(order.shipping_amount) || 0,
                    discount_fee: parseFloat(order.discount_amount) || 0,
                    insurance_fee: 0,
                    purchase_method_fee: 0,
                    additional_fee: 0,
                    currency_id: currencyId,
                    currency_code: currencyCode,
                    additional_fee_description: null,
                    final_price: parseFloat(order.grand_total) || 0,
                    created_at: order.created_at,
                    updated_at: order.updated_at
                };

                // Transform order
                const orderId = uuidv4();
                const orderStatus = this.mapOrderStatus(order.status, order.state);
                const orderObj = {
                    id: orderId,
                    order_no: order.increment_id,
                    order_customer_id: orderCustomerId,
                    order_price_id: orderPriceId,
                    status: orderStatus,
                    payment_method: 'BANK_TRANSFER', // Default
                    shipping_method: 'STANDARD', // Default
                    tracking_number: null,
                    invoice_no: null,
                    invoice_url: null,
                    order_manual_id: null,
                    comment: null,
                    note: null,
                    is_insurance: false,
                    is_send_order_confirmation_email: true,
                    invoice_date: null,
                    created_at: order.created_at,
                    updated_at: order.updated_at
                };

                // Transform order items
                const orderItems = [];
                for (const item of order.items) {
                    const productId = productSkuToIdMap.get(item.sku);
                    if (!productId) {
                        logger.debug(`Order ${order.entity_id} item ${item.item_id}: Product ${item.sku} not found, skipping`);
                        continue;
                    }

                    orderItems.push({
                        id: uuidv4(),
                        order_id: orderId,
                        product_id: productId,
                        quantity: parseInt(item.qty_ordered) || 1,
                        price: parseFloat(item.price) || 0,
                        provider_name: null,
                        provider_image: null,
                        coin_degree: null,
                        created_at: order.created_at,
                        updated_at: order.updated_at
                    });
                }

                // Transform shipping address
                const shippingAddressId = uuidv4();
                const countryId = countryMap.get(order.shipping_address.country_id) || countryMap.get('US');

                let addressLine = '';
                if (order.shipping_address.street) {
                    const streetLines = order.shipping_address.street.split('\n').filter(line => line.trim());
                    addressLine = streetLines[0] || '';
                }

                const shippingAddress = {
                    id: shippingAddressId,
                    order_id: orderId,
                    first_name: order.shipping_address.firstname || '',
                    last_name: order.shipping_address.lastname || '',
                    company_name: order.shipping_address.company,
                    phone: order.shipping_address.telephone,
                    phone_code: null,
                    address_line: addressLine,
                    address_line2: null,
                    address_line3: null,
                    post_code: order.shipping_address.postcode,
                    town: order.shipping_address.city,
                    city_name: order.shipping_address.city,
                    country_id: countryId,
                    created_at: order.created_at,
                    updated_at: order.updated_at
                };

                // Insert order customer
                await this.targetDb.query(`
                    INSERT INTO order_customers (id, user_id, guest_id, first_name, last_name, email, phone, phone_code, type, created_at, updated_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                `, Object.values(orderCustomer));
                customersInserted++;

                // Insert order price
                await this.targetDb.query(`
                    INSERT INTO order_prices (id, total_amount, subtotal_fee, shipping_fee, discount_fee, insurance_fee, purchase_method_fee, additional_fee, currency_id, currency_code, additional_fee_description, final_price, created_at, updated_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
                `, Object.values(orderPrice));

                // Insert order with upsert and get the actual order_id
                const orderResult = await this.targetDb.query(`
                    INSERT INTO orders (id, order_no, order_customer_id, order_price_id, status, payment_method, shipping_method, tracking_number, invoice_no, invoice_url, order_manual_id, comment, note, is_insurance, is_send_order_confirmation_email, invoice_date, created_at, updated_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18)
                    ON CONFLICT (order_no) DO UPDATE SET
                        order_customer_id = EXCLUDED.order_customer_id,
                        order_price_id = EXCLUDED.order_price_id,
                        status = EXCLUDED.status,
                        updated_at = NOW()
                    RETURNING id
                `, Object.values(orderObj));

                const actualOrderId = orderResult[0].id;
                ordersInserted++;

                // Insert order items
                for (const item of orderItems) {
                    const itemWithCorrectOrderId = { ...item, order_id: actualOrderId };
                    await this.targetDb.query(`
                        INSERT INTO order_items (id, order_id, product_id, quantity, price, provider_name, provider_image, coin_degree, created_at, updated_at)
                        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                    `, Object.values(itemWithCorrectOrderId));
                    itemsInserted++;
                }

                // Insert shipping address with upsert
                const addressWithCorrectOrderId = { ...shippingAddress, order_id: actualOrderId };
                await this.targetDb.query(`
                    INSERT INTO order_shipping_addresses (id, order_id, first_name, last_name, company_name, phone, phone_code, address_line, address_line2, address_line3, post_code, town, city_name, country_id, created_at, updated_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)
                    ON CONFLICT (order_id) DO UPDATE SET
                        first_name = EXCLUDED.first_name,
                        last_name = EXCLUDED.last_name,
                        company_name = EXCLUDED.company_name,
                        phone = EXCLUDED.phone,
                        phone_code = EXCLUDED.phone_code,
                        address_line = EXCLUDED.address_line,
                        address_line2 = EXCLUDED.address_line2,
                        address_line3 = EXCLUDED.address_line3,
                        post_code = EXCLUDED.post_code,
                        town = EXCLUDED.town,
                        city_name = EXCLUDED.city_name,
                        country_id = EXCLUDED.country_id,
                        updated_at = NOW()
                `, Object.values(addressWithCorrectOrderId));
                addressesInserted++;
            }

            return {
                orders: ordersInserted,
                customers: customersInserted,
                items: itemsInserted,
                addresses: addressesInserted,
                failed: 0
            };

        } catch (error) {
            logger.error('Failed to process order batch', { error: error.message, count: orders.length });
            return {
                orders: 0,
                customers: 0,
                items: 0,
                addresses: 0,
                failed: orders.length
            };
        }
    }

    mapOrderStatus(magentoStatus, magentoState) {
        // Map Magento status/state to target status


        // Source statuses;
        // a_complete,~3852
        // canceled,~445
        // pending,~65
        // paid_to_ship_later,~50
        // complete,~36
        // closed,~8


        // Target statuses;
        // PENDING
        // PROCESSING
        // ON_HOLD
        // SHIPPED
        // CANCELED
        // COMPLETE

        const statusMap = {
            'a_complete': 'COMPLETE',
            'canceled': 'CANCELED',
            'pending': 'PENDING',
            'paid_to_ship_later': 'ON_HOLD',
            'complete': 'COMPLETE',
            'closed': 'CANCELED',
        };

        return statusMap[magentoStatus] || statusMap[magentoState] || 'PENDING';
    }
}

module.exports = OrdersStep;
