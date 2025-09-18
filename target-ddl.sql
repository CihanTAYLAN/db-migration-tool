-- public.capitals definition

-- Drop table

-- DROP TABLE public.capitals;

CREATE TABLE public.capitals ( id text NOT NULL, "name" text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT capitals_pkey PRIMARY KEY (id));


-- public.certificate_providers definition

-- Drop table

-- DROP TABLE public.certificate_providers;

CREATE TABLE public.certificate_providers ( id text NOT NULL, "name" text NOT NULL, image text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT certificate_providers_pkey PRIMARY KEY (id));


-- public.contents definition

-- Drop table

-- DROP TABLE public.contents;

CREATE TABLE public.contents ( id text NOT NULL, sort int4 DEFAULT 0 NOT NULL, image text NULL, "type" public."ContentPageType" DEFAULT 'blog'::"ContentPageType" NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, published bool DEFAULT false NOT NULL, is_allowed bool DEFAULT false NOT NULL, CONSTRAINT contents_pkey PRIMARY KEY (id));


-- public.currencies definition

-- Drop table

-- DROP TABLE public.currencies;

CREATE TABLE public.currencies ( id text NOT NULL, code text NOT NULL, symbol text NULL, "name" text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, bank_rate numeric(16, 4) DEFAULT 0 NULL, system_rate numeric(16, 4) DEFAULT 0 NULL, CONSTRAINT currencies_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX currencies_code_key ON public.currencies USING btree (code);


-- public.ebay_settings definition

-- Drop table

-- DROP TABLE public.ebay_settings;

CREATE TABLE public.ebay_settings ( id text NOT NULL, client_id text NULL, client_secret text NULL, base_url text DEFAULT 'https://api.sandbox.ebay.com'::text NOT NULL, redirect_ru_name text DEFAULT 'Drakesterling-Drakeste-drakes-iwflihwu'::text NULL, "scope" text DEFAULT '[]'::text NOT NULL, env_type public."EbayEnvType" DEFAULT 'SANDBOX'::"EbayEnvType" NOT NULL, access_token text NULL, refresh_token text NULL, fulfillment_policy_id text NULL, payment_policy_id text NULL, return_policy_id text NULL, token_expires_at timestamp(3) NULL, refresh_token_expires_at timestamp(3) NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT ebay_settings_pkey PRIMARY KEY (id));


-- public.guests definition

-- Drop table

-- DROP TABLE public.guests;

CREATE TABLE public.guests ( id text NOT NULL, guest_uuid text NOT NULL, first_name text NULL, last_name text NULL, email text NULL, phone text NULL, phone_code text NULL, ip_address text NULL, user_agent text NULL, device text NULL, device_type text NULL, device_model text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT guests_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX guests_guest_uuid_key ON public.guests USING btree (guest_uuid);


-- public.language_keyword_groups definition

-- Drop table

-- DROP TABLE public.language_keyword_groups;

CREATE TABLE public.language_keyword_groups ( id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, "key" text NOT NULL, title text NOT NULL, description text NULL, CONSTRAINT language_keyword_groups_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX language_keyword_groups_key_key ON public.language_keyword_groups USING btree (key);


-- public.languages definition

-- Drop table

-- DROP TABLE public.languages;

CREATE TABLE public.languages ( id text NOT NULL, code text NOT NULL, local_code text NULL, "name" text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT languages_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX languages_code_key ON public.languages USING btree (code);
CREATE UNIQUE INDEX languages_local_code_key ON public.languages USING btree (local_code);


-- public.mail_lists definition

-- Drop table

-- DROP TABLE public.mail_lists;

CREATE TABLE public.mail_lists ( id text NOT NULL, "name" text NULL, email text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT mail_lists_pkey PRIMARY KEY (id));


-- public.mail_settings definition

-- Drop table

-- DROP TABLE public.mail_settings;

CREATE TABLE public.mail_settings ( id text NOT NULL, smtp_host text NOT NULL, smtp_port int4 NOT NULL, smtp_username text NOT NULL, smtp_password text NOT NULL, from_email text NOT NULL, from_name text NULL, use_ssl bool DEFAULT true NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT mail_settings_pkey PRIMARY KEY (id));


-- public.mailchimp_settings definition

-- Drop table

-- DROP TABLE public.mailchimp_settings;

CREATE TABLE public.mailchimp_settings ( id text NOT NULL, api_key text NULL, server_prefix text NULL, audience_id text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT mailchimp_settings_pkey PRIMARY KEY (id));


-- public.pages definition

-- Drop table

-- DROP TABLE public.pages;

CREATE TABLE public.pages ( id text NOT NULL, "key" text NULL, is_dynamic bool DEFAULT true NOT NULL, "data" jsonb NULL, published bool DEFAULT false NOT NULL, is_not_delete bool DEFAULT false NOT NULL, is_allowed bool DEFAULT false NOT NULL, show_on_header bool DEFAULT false NOT NULL, show_on_footer bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT pages_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX pages_key_key ON public.pages USING btree (key);


-- public.payment_settings definition

-- Drop table

-- DROP TABLE public.payment_settings;

CREATE TABLE public.payment_settings ( id text NOT NULL, eft_transfer bool DEFAULT false NOT NULL, stripe_enabled bool DEFAULT false NOT NULL, stripe_public_key text NULL, stripe_secret_key text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT payment_settings_pkey PRIMARY KEY (id));


-- public.permissions definition

-- Drop table

-- DROP TABLE public.permissions;

CREATE TABLE public.permissions ( id text NOT NULL, title text NOT NULL, description text NULL, "permission" public."PermissiotonType" NOT NULL, CONSTRAINT permissions_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX permissions_permission_key ON public.permissions USING btree (permission);


-- public.product_autocomplete_data definition

-- Drop table

-- DROP TABLE public.product_autocomplete_data;

CREATE TABLE public.product_autocomplete_data ( id text NOT NULL, coin_code text NULL, sort int4 NULL, description text NULL, country text NULL, date_mint text NULL, denomination text NULL, description_1 text NULL, special_attributes text NULL, method_of_manufacture text NULL, grade_suffix text NULL, country_1 text NULL, "year" text NULL, mint text NULL, description_2 text NULL, proof_specimen text NULL, description_3 text NULL, denomination_1 text NULL, description_4 text NULL, display_on_website text NULL, product_id_prefix text NULL, category_1 text NULL, sub_category_1 text NULL, category_2 text NULL, sub_category_2 text NULL, xero_sales_account text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT product_autocomplete_data_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX product_autocomplete_data_coin_code_key ON public.product_autocomplete_data USING btree (coin_code);


-- public.records definition

-- Drop table

-- DROP TABLE public.records;

CREATE TABLE public.records ( id text NOT NULL, entity text NOT NULL, entity_id text NOT NULL, entity_data jsonb NOT NULL, deleted_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, user_id text NULL, user_first_name text NULL, user_last_name text NULL, CONSTRAINT records_pkey PRIMARY KEY (id));


-- public.regions definition

-- Drop table

-- DROP TABLE public.regions;

CREATE TABLE public.regions ( id text NOT NULL, "name" text NOT NULL, is_active bool DEFAULT true NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT regions_pkey PRIMARY KEY (id));


-- public.roles definition

-- Drop table

-- DROP TABLE public.roles;

CREATE TABLE public.roles ( id text NOT NULL, title text NOT NULL, description text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT roles_pkey PRIMARY KEY (id));


-- public.shipping_settings definition

-- Drop table

-- DROP TABLE public.shipping_settings;

CREATE TABLE public.shipping_settings ( id text NOT NULL, cover_fee float8 DEFAULT 0 NOT NULL, domestic_shipping_fee float8 DEFAULT 0 NOT NULL, express_domestic_shipping_fee float8 DEFAULT 0 NOT NULL, international_shipping_fee float8 DEFAULT 0 NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT shipping_settings_pkey PRIMARY KEY (id));


-- public.site_configs definition

-- Drop table

-- DROP TABLE public.site_configs;

CREATE TABLE public.site_configs ( id text NOT NULL, "key" text NOT NULL, "data" jsonb NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT site_configs_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX site_configs_key_key ON public.site_configs USING btree (key);


-- public.timezones definition

-- Drop table

-- DROP TABLE public.timezones;

CREATE TABLE public.timezones ( id text NOT NULL, country_code text NOT NULL, utc_offset text NOT NULL, "name" text NOT NULL, dst_offset text NOT NULL, is_active bool DEFAULT true NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT timezones_pkey PRIMARY KEY (id));


-- public.xero_integrations definition

-- Drop table

-- DROP TABLE public.xero_integrations;

CREATE TABLE public.xero_integrations ( id text NOT NULL, access_token text NOT NULL, refresh_token text NOT NULL, token_expires_at timestamp(3) NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, client_id text NOT NULL, client_secret text NOT NULL, "name" text NOT NULL, redirect_uri text NOT NULL, CONSTRAINT xero_integrations_pkey PRIMARY KEY (id));


-- public.xero_invoice_logs definition

-- Drop table

-- DROP TABLE public.xero_invoice_logs;

CREATE TABLE public.xero_invoice_logs ( id text NOT NULL, request text NOT NULL, response text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, CONSTRAINT xero_invoice_logs_pkey PRIMARY KEY (id));


-- public.bank_transfers definition

-- Drop table

-- DROP TABLE public.bank_transfers;

CREATE TABLE public.bank_transfers ( id text NOT NULL, bank_name text NULL, bank_address text NULL, account_name text NULL, account_no text NULL, bsb_code text NULL, sort_code text NULL, swift_code text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, currency_id text NOT NULL, CONSTRAINT bank_transfers_pkey PRIMARY KEY (id), CONSTRAINT bank_transfers_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.categories definition

-- Drop table

-- DROP TABLE public.categories;

CREATE TABLE public.categories ( id text NOT NULL, code text NOT NULL, sort int4 DEFAULT 0 NOT NULL, is_hidden bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, parent_id text NULL, CONSTRAINT categories_pkey PRIMARY KEY (id), CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX categories_code_key ON public.categories USING btree (code);


-- public.category_translations definition

-- Drop table

-- DROP TABLE public.category_translations;

CREATE TABLE public.category_translations ( id text NOT NULL, title text NULL, description text NULL, meta_title text NULL, meta_description text NULL, meta_keywords text NULL, slug text NOT NULL, parent_slugs text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, category_id text NOT NULL, language_id text NOT NULL, CONSTRAINT category_translations_pkey PRIMARY KEY (id), CONSTRAINT category_translations_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT category_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX category_translations_language_id_slug_key ON public.category_translations USING btree (language_id, slug);


-- public.certificate_provider_badges definition

-- Drop table

-- DROP TABLE public.certificate_provider_badges;

CREATE TABLE public.certificate_provider_badges ( id text NOT NULL, icon text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, certificate_provider_id text NOT NULL, CONSTRAINT certificate_provider_badges_pkey PRIMARY KEY (id), CONSTRAINT certificate_provider_badges_certificate_provider_id_fkey FOREIGN KEY (certificate_provider_id) REFERENCES public.certificate_providers(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.certificate_provider_translations definition

-- Drop table

-- DROP TABLE public.certificate_provider_translations;

CREATE TABLE public.certificate_provider_translations ( id text NOT NULL, description text NULL, authenticity text NULL, our_grade text NULL, note_on_taxes text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, certificate_provider_id text NOT NULL, language_id text NOT NULL, CONSTRAINT certificate_provider_translations_pkey PRIMARY KEY (id), CONSTRAINT certificate_provider_translations_certificate_provider_id_fkey FOREIGN KEY (certificate_provider_id) REFERENCES public.certificate_providers(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT certificate_provider_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX certificate_provider_translations_language_id_certificate_p_key ON public.certificate_provider_translations USING btree (language_id, certificate_provider_id);


-- public.content_translations definition

-- Drop table

-- DROP TABLE public.content_translations;

CREATE TABLE public.content_translations ( id text NOT NULL, title text NOT NULL, slug text NULL, description text NULL, meta_title text NULL, meta_description text NULL, meta_keywords text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, content_id text NOT NULL, language_id text NOT NULL, CONSTRAINT content_translations_pkey PRIMARY KEY (id), CONSTRAINT content_translations_content_id_fkey FOREIGN KEY (content_id) REFERENCES public.contents(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT content_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.countries definition

-- Drop table

-- DROP TABLE public.countries;

CREATE TABLE public.countries ( id text NOT NULL, "name" text NOT NULL, iso_code_2 text NOT NULL, iso_code_3 text NOT NULL, phone_code text NOT NULL, postal_code_format text NOT NULL, postal_code_regex text NOT NULL, is_active bool DEFAULT true NOT NULL, region_id text NOT NULL, capital_id text NULL, time_zone_id text NULL, CONSTRAINT countries_pkey PRIMARY KEY (id), CONSTRAINT countries_capital_id_fkey FOREIGN KEY (capital_id) REFERENCES public.capitals(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT countries_region_id_fkey FOREIGN KEY (region_id) REFERENCES public.regions(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT countries_time_zone_id_fkey FOREIGN KEY (time_zone_id) REFERENCES public.timezones(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.currency_translations definition

-- Drop table

-- DROP TABLE public.currency_translations;

CREATE TABLE public.currency_translations ( id text NOT NULL, "name" text NULL, description text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, currency_id text NOT NULL, language_id text NOT NULL, CONSTRAINT currency_translations_pkey PRIMARY KEY (id), CONSTRAINT currency_translations_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT currency_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.language_keywords definition

-- Drop table

-- DROP TABLE public.language_keywords;

CREATE TABLE public.language_keywords ( id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, language_keyword_group_id text NOT NULL, description text NULL, "key" text NOT NULL, CONSTRAINT language_keywords_pkey PRIMARY KEY (id), CONSTRAINT language_keywords_language_keyword_group_id_fkey FOREIGN KEY (language_keyword_group_id) REFERENCES public.language_keyword_groups(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.order_prices definition

-- Drop table

-- DROP TABLE public.order_prices;

CREATE TABLE public.order_prices ( id text NOT NULL, subtotal_fee numeric(16, 4) NOT NULL, shipping_fee numeric(16, 4) NOT NULL, purchase_method_fee numeric(16, 4) NOT NULL, additional_fee numeric(16, 4) NOT NULL, additional_fee_description text NULL, total_amount numeric(16, 4) NOT NULL, insurance_fee numeric(16, 4) NOT NULL, discount_fee numeric(16, 4) DEFAULT 0 NOT NULL, currency_code text NULL, final_price numeric(16, 4) NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, currency_id text NULL, CONSTRAINT order_prices_pkey PRIMARY KEY (id), CONSTRAINT order_prices_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.page_form_answer definition

-- Drop table

-- DROP TABLE public.page_form_answer;

CREATE TABLE public.page_form_answer ( id text NOT NULL, page_id text NULL, form_name text NOT NULL, "data" jsonb NULL, email text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT page_form_answer_pkey PRIMARY KEY (id), CONSTRAINT page_form_answer_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.page_translations definition

-- Drop table

-- DROP TABLE public.page_translations;

CREATE TABLE public.page_translations ( id text NOT NULL, slug text NOT NULL, meta_title text NULL, meta_description text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, page_id text NOT NULL, language_id text NOT NULL, CONSTRAINT page_translations_pkey PRIMARY KEY (id), CONSTRAINT page_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT page_translations_page_id_fkey FOREIGN KEY (page_id) REFERENCES public.pages(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.role_permissions definition

-- Drop table

-- DROP TABLE public.role_permissions;

CREATE TABLE public.role_permissions ( id text NOT NULL, role_id text NOT NULL, permission_id text NOT NULL, CONSTRAINT role_permissions_pkey PRIMARY KEY (id), CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.settings definition

-- Drop table

-- DROP TABLE public.settings;

CREATE TABLE public.settings ( id text NOT NULL, notification_emails text DEFAULT ''::text NOT NULL, shop_without_membership bool DEFAULT false NOT NULL, can_be_ordered bool DEFAULT true NOT NULL, archive_coins_x_days int4 DEFAULT 30 NOT NULL, default_language_code text DEFAULT 'en'::text NULL, just_added_day int4 DEFAULT 21 NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, payment_setting_id text NULL, shipping_setting_id text NULL, mailchimp_setting_id text NULL, ebay_setting_id text NULL, mail_setting_id text NULL, foreign_currency_margin_percentage float8 DEFAULT 0 NOT NULL, insurance_fee float8 DEFAULT 0 NOT NULL, manual_credit_card_payment_fee float8 DEFAULT 0 NOT NULL, CONSTRAINT settings_pkey PRIMARY KEY (id), CONSTRAINT settings_ebay_setting_id_fkey FOREIGN KEY (ebay_setting_id) REFERENCES public.ebay_settings(id) ON DELETE SET NULL ON UPDATE CASCADE, CONSTRAINT settings_mail_setting_id_fkey FOREIGN KEY (mail_setting_id) REFERENCES public.mail_settings(id) ON DELETE SET NULL ON UPDATE CASCADE, CONSTRAINT settings_mailchimp_setting_id_fkey FOREIGN KEY (mailchimp_setting_id) REFERENCES public.mailchimp_settings(id) ON DELETE SET NULL ON UPDATE CASCADE, CONSTRAINT settings_payment_setting_id_fkey FOREIGN KEY (payment_setting_id) REFERENCES public.payment_settings(id) ON DELETE SET NULL ON UPDATE CASCADE, CONSTRAINT settings_shipping_setting_id_fkey FOREIGN KEY (shipping_setting_id) REFERENCES public.shipping_settings(id) ON DELETE SET NULL ON UPDATE CASCADE);
CREATE UNIQUE INDEX settings_ebay_setting_id_key ON public.settings USING btree (ebay_setting_id);
CREATE UNIQUE INDEX settings_mail_setting_id_key ON public.settings USING btree (mail_setting_id);
CREATE UNIQUE INDEX settings_mailchimp_setting_id_key ON public.settings USING btree (mailchimp_setting_id);
CREATE UNIQUE INDEX settings_payment_setting_id_key ON public.settings USING btree (payment_setting_id);
CREATE UNIQUE INDEX settings_shipping_setting_id_key ON public.settings USING btree (shipping_setting_id);


-- public.users definition

-- Drop table

-- DROP TABLE public.users;

CREATE TABLE public.users ( id text NOT NULL, user_code text NOT NULL, first_name text NULL, last_name text NULL, company_name text NULL, email text NOT NULL, phone text NULL, phone_code text NULL, "password" text NULL, is_view_price bool DEFAULT true NOT NULL, is_approved_for_credit_card bool DEFAULT false NOT NULL, is_approved_for_mailing bool DEFAULT false NOT NULL, is_locked_account bool DEFAULT false NOT NULL, "type" public."UserType" DEFAULT 'CUSTOMER'::"UserType" NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, last_signed_in timestamp(3) NULL, password_reset_token text NULL, password_reset_token_expires_at timestamp(3) NULL, password_create_token text NULL, password_create_token_expires_at timestamp(3) NULL, signout bool DEFAULT false NOT NULL, is_subscribe_email bool DEFAULT false NOT NULL, language_id text NULL, is_mailchimp_subscribed bool DEFAULT false NOT NULL, CONSTRAINT users_pkey PRIMARY KEY (id), CONSTRAINT users_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);
CREATE UNIQUE INDEX users_user_code_key ON public.users USING btree (user_code);


-- public.xero_tenants definition

-- Drop table

-- DROP TABLE public.xero_tenants;

CREATE TABLE public.xero_tenants ( id text NOT NULL, tenant_id text NOT NULL, "name" text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, integration_id text NOT NULL, CONSTRAINT xero_tenants_pkey PRIMARY KEY (id), CONSTRAINT xero_tenants_integration_id_fkey FOREIGN KEY (integration_id) REFERENCES public.xero_integrations(id) ON DELETE RESTRICT ON UPDATE CASCADE);
CREATE UNIQUE INDEX xero_tenants_tenant_id_key ON public.xero_tenants USING btree (tenant_id);


-- public.certificate_provider_badge_translations definition

-- Drop table

-- DROP TABLE public.certificate_provider_badge_translations;

CREATE TABLE public.certificate_provider_badge_translations ( id text NOT NULL, "name" text NULL, description text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, certificate_provider_badge_id text NOT NULL, language_id text NOT NULL, CONSTRAINT certificate_provider_badge_translations_pkey PRIMARY KEY (id), CONSTRAINT certificate_provider_badge_translations_certificate_provid_fkey FOREIGN KEY (certificate_provider_badge_id) REFERENCES public.certificate_provider_badges(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT certificate_provider_badge_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX certificate_provider_badge_translations_language_id_certifi_key ON public.certificate_provider_badge_translations USING btree (language_id, certificate_provider_badge_id);


-- public.cities definition

-- Drop table

-- DROP TABLE public.cities;

CREATE TABLE public.cities ( id text NOT NULL, "name" text NOT NULL, latitude float8 NOT NULL, longitude float8 NOT NULL, population float8 NOT NULL, time_zone_id text NOT NULL, country_id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT cities_pkey PRIMARY KEY (id), CONSTRAINT cities_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT cities_time_zone_id_fkey FOREIGN KEY (time_zone_id) REFERENCES public.timezones(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.language_keyword_translations definition

-- Drop table

-- DROP TABLE public.language_keyword_translations;

CREATE TABLE public.language_keyword_translations ( id text NOT NULL, value text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, language_keyword_id text NOT NULL, language_id text NOT NULL, CONSTRAINT language_keyword_translations_pkey PRIMARY KEY (id), CONSTRAINT language_keyword_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT language_keyword_translations_language_keyword_id_fkey FOREIGN KEY (language_keyword_id) REFERENCES public.language_keywords(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.order_customers definition

-- Drop table

-- DROP TABLE public.order_customers;

CREATE TABLE public.order_customers ( id text NOT NULL, first_name text NOT NULL, last_name text NOT NULL, email text NOT NULL, phone text NULL, phone_code text NULL, "type" public."OrderCustomerType" DEFAULT 'LOGIN_USER'::"OrderCustomerType" NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, user_id text NULL, guest_id text NULL, CONSTRAINT order_customers_pkey PRIMARY KEY (id), CONSTRAINT order_customers_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.guests(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT order_customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.order_manuals definition

-- Drop table

-- DROP TABLE public.order_manuals;

CREATE TABLE public.order_manuals ( id text NOT NULL, admin_first_name text NULL, admin_last_name text NULL, admin_email text NULL, user_id text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT order_manuals_pkey PRIMARY KEY (id), CONSTRAINT order_manuals_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.orders definition

-- Drop table

-- DROP TABLE public.orders;

CREATE TABLE public.orders ( order_no text NOT NULL, payment_method public."PaymentMethod" NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, "comment" text NULL, id text NOT NULL, note text NULL, order_customer_id text NULL, tracking_number text NULL, order_manual_id text NULL, order_price_id text NOT NULL, status public."OrderStatus" DEFAULT 'PENDING'::"OrderStatus" NOT NULL, invoice_date timestamp(3) NULL, invoice_no text NULL, invoice_url text NULL, shipping_method public."ShippingMethod" NOT NULL, is_insurance bool DEFAULT false NOT NULL, is_send_order_confirmation_email bool DEFAULT false NOT NULL, CONSTRAINT orders_pkey PRIMARY KEY (id), CONSTRAINT orders_order_customer_id_fkey FOREIGN KEY (order_customer_id) REFERENCES public.order_customers(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT orders_order_manual_id_fkey FOREIGN KEY (order_manual_id) REFERENCES public.order_manuals(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT orders_order_price_id_fkey FOREIGN KEY (order_price_id) REFERENCES public.order_prices(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX orders_order_no_key ON public.orders USING btree (order_no);
CREATE UNIQUE INDEX orders_order_price_id_key ON public.orders USING btree (order_price_id);


-- public.user_roles definition

-- Drop table

-- DROP TABLE public.user_roles;

CREATE TABLE public.user_roles ( user_id text NOT NULL, role_id text NOT NULL, CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id), CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.addresses definition

-- Drop table

-- DROP TABLE public.addresses;

CREATE TABLE public.addresses ( id text NOT NULL, first_name text NOT NULL, last_name text NOT NULL, company_name text NULL, phone text NULL, phone_code text NULL, address_line text NOT NULL, address_line2 text NULL, address_line3 text NULL, post_code text NULL, state_province text NULL, town text NULL, is_default bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, user_id text NULL, country_id text NOT NULL, city_id text NOT NULL, CONSTRAINT addresses_pkey PRIMARY KEY (id), CONSTRAINT addresses_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT addresses_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.cart_shipping_addresses definition

-- Drop table

-- DROP TABLE public.cart_shipping_addresses;

CREATE TABLE public.cart_shipping_addresses ( id text NOT NULL, first_name text NULL, last_name text NULL, email text NULL, phone text NULL, phone_code text NULL, address_line text NULL, address_line2 text NULL, address_line3 text NULL, post_code text NULL, state_province text NULL, town text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, country_id text NOT NULL, city_id text NOT NULL, CONSTRAINT cart_shipping_addresses_pkey PRIMARY KEY (id), CONSTRAINT cart_shipping_addresses_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT cart_shipping_addresses_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE ON UPDATE CASCADE);


-- public.carts definition

-- Drop table

-- DROP TABLE public.carts;

CREATE TABLE public.carts ( id text NOT NULL, is_shipping_cover bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, user_id text NULL, guest_id text NULL, select_shipping_address_id text NULL, cart_shipping_address_id text NULL, shipping_method public."ShippingMethod" NULL, payment_method public."PaymentMethod" NULL, CONSTRAINT carts_pkey PRIMARY KEY (id), CONSTRAINT carts_cart_shipping_address_id_fkey FOREIGN KEY (cart_shipping_address_id) REFERENCES public.cart_shipping_addresses(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT carts_guest_id_fkey FOREIGN KEY (guest_id) REFERENCES public.guests(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT carts_select_shipping_address_id_fkey FOREIGN KEY (select_shipping_address_id) REFERENCES public.addresses(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT carts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX carts_guest_id_key ON public.carts USING btree (guest_id);
CREATE UNIQUE INDEX carts_user_id_key ON public.carts USING btree (user_id);


-- public.order_shipping_addresses definition

-- Drop table

-- DROP TABLE public.order_shipping_addresses;

CREATE TABLE public.order_shipping_addresses ( id text NOT NULL, order_id text NULL, address_line text NOT NULL, address_line2 text NULL, address_line3 text NULL, city_id text NOT NULL, company_name text NULL, country_id text NOT NULL, first_name text NOT NULL, last_name text NOT NULL, phone text NULL, phone_code text NULL, post_code text NULL, town text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT order_shipping_addresses_pkey PRIMARY KEY (id), CONSTRAINT order_shipping_addresses_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT order_shipping_addresses_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE ON UPDATE CASCADE, CONSTRAINT order_shipping_addresses_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE UNIQUE INDEX order_shipping_addresses_order_id_key ON public.order_shipping_addresses USING btree (order_id);


-- public.cart_items definition

-- Drop table

-- DROP TABLE public.cart_items;

CREATE TABLE public.cart_items ( id text NOT NULL, quantity int4 DEFAULT 1 NOT NULL, cart_id text NOT NULL, product_id text NOT NULL, CONSTRAINT cart_items_pkey PRIMARY KEY (id));


-- public.messages definition

-- Drop table

-- DROP TABLE public.messages;

CREATE TABLE public.messages ( id text NOT NULL, "name" text NOT NULL, email text NOT NULL, phone text NULL, message text NULL, "joinEmailList" bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, product_id text NULL, CONSTRAINT messages_pkey PRIMARY KEY (id));


-- public.order_items definition

-- Drop table

-- DROP TABLE public.order_items;

CREATE TABLE public.order_items ( id text NOT NULL, provider_name text NULL, provider_image text NULL, coin_degree text NULL, quantity int4 NOT NULL, price numeric(16, 4) NOT NULL, order_id text NOT NULL, product_id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT order_items_pkey PRIMARY KEY (id));


-- public.product_categories definition

-- Drop table

-- DROP TABLE public.product_categories;

CREATE TABLE public.product_categories ( id text NOT NULL, product_id text NOT NULL, category_id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT product_categories_pkey PRIMARY KEY (id));


-- public.product_certificate_provider_badges definition

-- Drop table

-- DROP TABLE public.product_certificate_provider_badges;

CREATE TABLE public.product_certificate_provider_badges ( id text NOT NULL, is_active bool DEFAULT true NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, certificate_provider_badge_id text NOT NULL, product_id text NOT NULL, CONSTRAINT product_certificate_provider_badges_pkey PRIMARY KEY (id));


-- public.product_images definition

-- Drop table

-- DROP TABLE public.product_images;

CREATE TABLE public.product_images ( id text NOT NULL, image_url text NOT NULL, alt text NULL, "position" int4 DEFAULT 0 NOT NULL, is_master bool DEFAULT false NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, product_id text NOT NULL, CONSTRAINT product_images_pkey PRIMARY KEY (id));


-- public.product_prices definition

-- Drop table

-- DROP TABLE public.product_prices;

CREATE TABLE public.product_prices ( id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, base_amount numeric(16, 4) NOT NULL, amount numeric(16, 4) NOT NULL, currency_code text NOT NULL, currency_id text NOT NULL, product_id text NOT NULL, CONSTRAINT product_prices_pkey PRIMARY KEY (id));


-- public.product_stars definition

-- Drop table

-- DROP TABLE public.product_stars;

CREATE TABLE public.product_stars ( id text NOT NULL, product_id text NOT NULL, user_id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, CONSTRAINT product_stars_pkey PRIMARY KEY (id));


-- public.product_translations definition

-- Drop table

-- DROP TABLE public.product_translations;

CREATE TABLE public.product_translations ( id text NOT NULL, slug text NOT NULL, title text NULL, description text NULL, short_description text NULL, meta_title text NULL, meta_description text NULL, meta_keywords text NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, product_id text NOT NULL, language_id text NOT NULL, CONSTRAINT product_translations_pkey PRIMARY KEY (id));


-- public.products definition

-- Drop table

-- DROP TABLE public.products;

CREATE TABLE public.products ( id text NOT NULL, product_identity text NOT NULL, product_sku text NOT NULL, product_web_sku text NOT NULL, cert_number text NULL, coin_video text NULL, is_coin_video bool DEFAULT false NOT NULL, coin_number text NULL, coin_our_grade float8 DEFAULT 0.0 NULL, coin_grade_type text NULL, coin_grade float8 DEFAULT 0.0 NULL, coin_grade_suffix text NULL, coin_grade_prefix text NULL, coin_grade_text text NULL, year_text text NULL, coin_grade_prefix_type text NULL, year_date timestamp(3) NULL, is_second_hand bool DEFAULT false NOT NULL, is_consignment bool DEFAULT false NOT NULL, is_active bool DEFAULT true NOT NULL, is_on_hold bool DEFAULT false NOT NULL, status public."ProductStatus" DEFAULT 'pending'::"ProductStatus" NOT NULL, quantity int4 DEFAULT 1 NOT NULL, price numeric(16, 4) NOT NULL, sold_date timestamp(3) NULL, archived_at timestamp(3) NULL, sold_price numeric(16, 4) NULL, discount_price numeric(16, 4) NULL, ebay_offer_code text NULL, stars int4 DEFAULT 0 NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, updated_at timestamp(3) NOT NULL, deleted_at timestamp(3) NULL, product_master_image_id text NULL, certificate_provider_id text NULL, master_category_id text NULL, xero_tenant_id text NULL, country_id text NULL, CONSTRAINT products_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX products_product_web_sku_key ON public.products USING btree (product_web_sku);


-- public.similar_products definition

-- Drop table

-- DROP TABLE public.similar_products;

CREATE TABLE public.similar_products ( id text NOT NULL, created_at timestamp(3) DEFAULT CURRENT_TIMESTAMP NOT NULL, product_id text NOT NULL, similar_product_id text NOT NULL, CONSTRAINT similar_products_pkey PRIMARY KEY (id));
CREATE UNIQUE INDEX similar_products_product_id_similar_product_id_key ON public.similar_products USING btree (product_id, similar_product_id);


-- public.cart_items foreign keys

ALTER TABLE public.cart_items ADD CONSTRAINT cart_items_cart_id_fkey FOREIGN KEY (cart_id) REFERENCES public.carts(id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.cart_items ADD CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.messages foreign keys

ALTER TABLE public.messages ADD CONSTRAINT messages_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.order_items foreign keys

ALTER TABLE public.order_items ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.order_items ADD CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_categories foreign keys

ALTER TABLE public.product_categories ADD CONSTRAINT product_categories_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.product_categories ADD CONSTRAINT product_categories_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_certificate_provider_badges foreign keys

ALTER TABLE public.product_certificate_provider_badges ADD CONSTRAINT product_certificate_provider_badges_certificate_provider_b_fkey FOREIGN KEY (certificate_provider_badge_id) REFERENCES public.certificate_provider_badges(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.product_certificate_provider_badges ADD CONSTRAINT product_certificate_provider_badges_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_images foreign keys

ALTER TABLE public.product_images ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_prices foreign keys

ALTER TABLE public.product_prices ADD CONSTRAINT product_prices_currency_id_fkey FOREIGN KEY (currency_id) REFERENCES public.currencies(id) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE public.product_prices ADD CONSTRAINT product_prices_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_stars foreign keys

ALTER TABLE public.product_stars ADD CONSTRAINT product_stars_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.product_stars ADD CONSTRAINT product_stars_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.product_translations foreign keys

ALTER TABLE public.product_translations ADD CONSTRAINT product_translations_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.languages(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.product_translations ADD CONSTRAINT product_translations_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.products foreign keys

ALTER TABLE public.products ADD CONSTRAINT products_certificate_provider_id_fkey FOREIGN KEY (certificate_provider_id) REFERENCES public.certificate_providers(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.products ADD CONSTRAINT products_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.products ADD CONSTRAINT products_master_category_id_fkey FOREIGN KEY (master_category_id) REFERENCES public.categories(id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.products ADD CONSTRAINT products_product_master_image_id_fkey FOREIGN KEY (product_master_image_id) REFERENCES public.product_images(id) ON DELETE SET NULL ON UPDATE CASCADE;
ALTER TABLE public.products ADD CONSTRAINT products_xero_tenant_id_fkey FOREIGN KEY (xero_tenant_id) REFERENCES public.xero_tenants(id) ON DELETE CASCADE ON UPDATE CASCADE;


-- public.similar_products foreign keys

ALTER TABLE public.similar_products ADD CONSTRAINT similar_products_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE public.similar_products ADD CONSTRAINT similar_products_similar_product_id_fkey FOREIGN KEY (similar_product_id) REFERENCES public.products(id) ON DELETE CASCADE ON UPDATE CASCADE;