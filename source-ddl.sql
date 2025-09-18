-- drakesterling_old.admin_analytics_usage_version_log definition

CREATE TABLE `admin_analytics_usage_version_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `last_viewed_in_version` varchar(50) NOT NULL COMMENT 'Viewer last viewed on product version',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ADMIN_ANALYTICS_USAGE_VERSION_LOG_LAST_VIEWED_IN_VERSION` (`last_viewed_in_version`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Admin Notification Viewer Log Table';


-- drakesterling_old.admin_system_messages definition

CREATE TABLE `admin_system_messages` (
  `identity` varchar(100) NOT NULL COMMENT 'Message ID',
  `severity` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Problem type',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Create date',
  PRIMARY KEY (`identity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Admin System Messages';


-- drakesterling_old.admin_user definition

CREATE TABLE `admin_user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'User ID',
  `firstname` varchar(32) DEFAULT NULL COMMENT 'User First Name',
  `lastname` varchar(32) DEFAULT NULL COMMENT 'User Last Name',
  `email` varchar(128) DEFAULT NULL COMMENT 'User Email',
  `username` varchar(40) DEFAULT NULL COMMENT 'User Login',
  `password` varchar(255) NOT NULL COMMENT 'User Password',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'User Created Time',
  `modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'User Modified Time',
  `logdate` timestamp NULL DEFAULT NULL COMMENT 'User Last Login Time',
  `lognum` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'User Login Number',
  `reload_acl_flag` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Reload ACL',
  `is_active` smallint(6) NOT NULL DEFAULT '1' COMMENT 'User Is Active',
  `extra` text COMMENT 'User Extra Data',
  `rp_token` text COMMENT 'Reset Password Link Token',
  `rp_token_created_at` timestamp NULL DEFAULT NULL COMMENT 'Reset Password Link Token Creation Date',
  `interface_locale` varchar(16) NOT NULL DEFAULT 'en_US' COMMENT 'Backend interface locale',
  `failures_num` smallint(6) DEFAULT '0' COMMENT 'Failure Number',
  `first_failure` timestamp NULL DEFAULT NULL COMMENT 'First Failure',
  `lock_expires` timestamp NULL DEFAULT NULL COMMENT 'Expiration Lock Dates',
  `refresh_token` text COMMENT 'Email connector refresh token',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `ADMIN_USER_USERNAME` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8 COMMENT='Admin User Table';


-- drakesterling_old.adminnotification_inbox definition

CREATE TABLE `adminnotification_inbox` (
  `notification_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Notification ID',
  `severity` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Problem type',
  `date_added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Create date',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `description` text COMMENT 'Description',
  `url` varchar(255) DEFAULT NULL COMMENT 'Url',
  `is_read` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Flag if notification read',
  `is_remove` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Flag if notification might be removed',
  `is_amasty` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Amasty Notification',
  `expiration_date` datetime DEFAULT NULL COMMENT 'Expiration Date',
  `image_url` text COMMENT 'Image Url',
  `is_magenest` smallint(6) DEFAULT '0' COMMENT 'Is Magenest',
  `magenest_id` int(11) DEFAULT NULL COMMENT 'Magenest notification ID',
  PRIMARY KEY (`notification_id`),
  KEY `ADMINNOTIFICATION_INBOX_SEVERITY` (`severity`),
  KEY `ADMINNOTIFICATION_INBOX_IS_READ` (`is_read`),
  KEY `ADMINNOTIFICATION_INBOX_IS_REMOVE` (`is_remove`)
) ENGINE=InnoDB AUTO_INCREMENT=501 DEFAULT CHARSET=utf8 COMMENT='Admin Notification Inbox';


-- drakesterling_old.adobe_stock_category definition

CREATE TABLE `adobe_stock_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  PRIMARY KEY (`id`),
  KEY `ADOBE_STOCK_CATEGORY_ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Adobe Stock Category';


-- drakesterling_old.adobe_stock_creator definition

CREATE TABLE `adobe_stock_creator` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Asset creator''s name',
  PRIMARY KEY (`id`),
  KEY `ADOBE_STOCK_CREATOR_ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Adobe Stock Creator';


-- drakesterling_old.ae_ec definition

CREATE TABLE `ae_ec` (
  `ec_id` bigint(21) NOT NULL AUTO_INCREMENT,
  `ec_track` tinyint(1) DEFAULT NULL COMMENT 'Track flag',
  `ec_order_id` bigint(21) DEFAULT NULL,
  `ec_order_type` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Type',
  `ec_consent_id` bigint(20) DEFAULT '0' COMMENT 'Consent ID',
  `ec_consent_uuid` text COMMENT 'Consent UUID',
  `ec_cookie_ga` varchar(255) DEFAULT NULL,
  `ec_user_agent` text COMMENT 'Track user agent',
  `ec_placed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Track placed timestamp',
  `ec_updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Track placed timestamp',
  PRIMARY KEY (`ec_id`),
  UNIQUE KEY `unique_order_id` (`ec_order_id`),
  KEY `EC_ORDER_ID_EC_ORDER_ID` (`ec_order_id`),
  KEY `EC_TRACK_EC_TRACK_EC_ORDER_TYPE` (`ec_track`,`ec_order_type`)
) ENGINE=InnoDB AUTO_INCREMENT=2383 DEFAULT CHARSET=latin1;


-- drakesterling_old.ae_ec_gdpr definition

CREATE TABLE `ae_ec_gdpr` (
  `consent_id` bigint(21) NOT NULL AUTO_INCREMENT,
  `consent_uuid` varchar(255) DEFAULT NULL,
  `consent_ip` bigint(8) DEFAULT NULL,
  `consent` text,
  `consent_type` tinyint(1) NOT NULL DEFAULT '0',
  `consent_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`consent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.ae_ec_gdpr_cookies definition

CREATE TABLE `ae_ec_gdpr_cookies` (
  `cookie_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `cookie_name` varchar(255) DEFAULT NULL,
  `cookie_description` text,
  `cookie_segment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`cookie_id`),
  UNIQUE KEY `cookie_name` (`cookie_name`),
  KEY `CookieSegment` (`cookie_segment`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Consent Cookies';


-- drakesterling_old.ae_ec_log definition

CREATE TABLE `ae_ec_log` (
  `log_id` bigint(21) NOT NULL AUTO_INCREMENT,
  `log` longtext,
  `log_timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.amasty_fpc_activity definition

CREATE TABLE `amasty_fpc_activity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `rate` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'Number of Visits',
  `url` varchar(255) NOT NULL COMMENT 'Url',
  `store` int(10) unsigned NOT NULL COMMENT 'Store Id',
  `currency` varchar(255) NOT NULL COMMENT 'Currency',
  `customer_group` int(10) unsigned NOT NULL COMMENT 'Customer Group',
  `mobile` tinyint(1) NOT NULL COMMENT 'Mobile',
  `status` int(10) unsigned NOT NULL COMMENT 'Status',
  `date` int(10) unsigned NOT NULL COMMENT 'Date',
  PRIMARY KEY (`id`),
  KEY `AMASTY_FPC_ACTIVITY_URL_MOBILE` (`url`,`mobile`)
) ENGINE=InnoDB AUTO_INCREMENT=7852838 DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Activity Table';


-- drakesterling_old.amasty_fpc_context_debug definition

CREATE TABLE `amasty_fpc_context_debug` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Context Debug Entity ID',
  `url` varchar(255) NOT NULL COMMENT 'Context Debug Entity Url',
  `context_data` text COMMENT 'Context Debug Entity Context Data JSON',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Context Debug';


-- drakesterling_old.amasty_fpc_flushes_log definition

CREATE TABLE `amasty_fpc_flushes_log` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log_id',
  `source` varchar(255) DEFAULT NULL COMMENT 'Source',
  `details` text COMMENT 'Details',
  `tags` text COMMENT 'Tags',
  `subject` varchar(255) DEFAULT NULL COMMENT 'Subject',
  `date` varchar(255) DEFAULT NULL COMMENT 'Date',
  `backtrace` text COMMENT 'Backtrace',
  PRIMARY KEY (`log_id`)
) ENGINE=InnoDB AUTO_INCREMENT=103354 DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Flushes Log Table';


-- drakesterling_old.amasty_fpc_job_queue definition

CREATE TABLE `amasty_fpc_job_queue` (
  `job_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Job ID',
  `job_code` text NOT NULL COMMENT 'Job Code',
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Table with deferred jobs to process in background';


-- drakesterling_old.amasty_fpc_pages_to_flush definition

CREATE TABLE `amasty_fpc_pages_to_flush` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `url` text COMMENT 'Page URL',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Table with pages need to be flushed';


-- drakesterling_old.amasty_fpc_reports definition

CREATE TABLE `amasty_fpc_reports` (
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Visit Time',
  `status` varchar(25) NOT NULL COMMENT 'Page status',
  `response` float(10,0) NOT NULL COMMENT 'Page response time'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='amasty_fpc_reports';


-- drakesterling_old.amazon_pending_authorization definition

CREATE TABLE `amazon_pending_authorization` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity_id',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `payment_id` int(10) unsigned NOT NULL COMMENT 'Payment_id',
  `authorization_id` varchar(255) DEFAULT NULL COMMENT 'Authorization_id',
  `created_at` datetime NOT NULL COMMENT 'Created_at',
  `updated_at` datetime DEFAULT NULL COMMENT 'Updated_at',
  `processed` smallint(5) unsigned DEFAULT '0' COMMENT 'Initial authorization processed',
  `capture` smallint(5) unsigned DEFAULT '0' COMMENT 'Initial authorization has capture',
  `capture_id` varchar(255) DEFAULT NULL COMMENT 'Initial authorization capture id',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `UNQ_E6CCA08713FB32BB136A56837009C371` (`order_id`,`payment_id`,`authorization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='amazon_pending_authorization';


-- drakesterling_old.amazon_pending_capture definition

CREATE TABLE `amazon_pending_capture` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity_id',
  `capture_id` varchar(255) NOT NULL COMMENT 'Capture_id',
  `created_at` datetime NOT NULL COMMENT 'Created_at',
  `order_id` int(10) unsigned NOT NULL COMMENT 'order id',
  `payment_id` int(10) unsigned NOT NULL COMMENT 'payment id',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `AMAZON_PENDING_CAPTURE_ORDER_ID_PAYMENT_ID_CAPTURE_ID` (`order_id`,`payment_id`,`capture_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='amazon_pending_capture';


-- drakesterling_old.amazon_pending_refund definition

CREATE TABLE `amazon_pending_refund` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity_id',
  `refund_id` varchar(255) NOT NULL COMMENT 'Refund_id',
  `created_at` datetime NOT NULL COMMENT 'Created_at',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `payment_id` int(10) unsigned NOT NULL COMMENT 'Payment_id',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `AMAZON_PENDING_REFUND_ORDER_ID_PAYMENT_ID_REFUND_ID` (`order_id`,`payment_id`,`refund_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='amazon_pending_refund';


-- drakesterling_old.authorization_role definition

CREATE TABLE `authorization_role` (
  `role_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Role ID',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Parent Role ID',
  `tree_level` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Role Tree Level',
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Role Sort Order',
  `role_type` varchar(1) NOT NULL DEFAULT '0' COMMENT 'Role Type',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'User ID',
  `user_type` varchar(16) DEFAULT NULL COMMENT 'User Type',
  `role_name` varchar(50) DEFAULT NULL COMMENT 'Role Name',
  PRIMARY KEY (`role_id`),
  KEY `AUTHORIZATION_ROLE_PARENT_ID_SORT_ORDER` (`parent_id`,`sort_order`),
  KEY `AUTHORIZATION_ROLE_TREE_LEVEL` (`tree_level`)
) ENGINE=InnoDB AUTO_INCREMENT=469 DEFAULT CHARSET=utf8 COMMENT='Admin Role Table';


-- drakesterling_old.braintree_credit_prices definition

CREATE TABLE `braintree_credit_prices` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Row ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product Id',
  `term` int(11) NOT NULL COMMENT 'Credit Term',
  `monthly_payment` decimal(12,2) NOT NULL COMMENT 'Monthly Payment',
  `instalment_rate` decimal(12,2) NOT NULL COMMENT 'Instalment Rate',
  `cost_of_purchase` decimal(12,2) NOT NULL COMMENT 'Cost of purchase',
  `total_inc_interest` decimal(12,2) NOT NULL COMMENT 'Total Inc Interest',
  PRIMARY KEY (`id`),
  UNIQUE KEY `BRAINTREE_CREDIT_PRICES_PRODUCT_ID_TERM` (`product_id`,`term`),
  KEY `BRAINTREE_CREDIT_PRICES_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Braintree credit rates';


-- drakesterling_old.cache definition

CREATE TABLE `cache` (
  `id` varchar(200) NOT NULL COMMENT 'Cache Id',
  `data` mediumblob COMMENT 'Cache Data',
  `create_time` int(11) DEFAULT NULL COMMENT 'Cache Creation Time',
  `update_time` int(11) DEFAULT NULL COMMENT 'Time of Cache Updating',
  `expire_time` int(11) DEFAULT NULL COMMENT 'Cache Expiration Time',
  PRIMARY KEY (`id`),
  KEY `CACHE_EXPIRE_TIME` (`expire_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Caches';


-- drakesterling_old.cache_tag definition

CREATE TABLE `cache_tag` (
  `tag` varchar(100) NOT NULL COMMENT 'Tag',
  `cache_id` varchar(200) NOT NULL COMMENT 'Cache Id',
  PRIMARY KEY (`tag`,`cache_id`),
  KEY `CACHE_TAG_CACHE_ID` (`cache_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tag Caches';


-- drakesterling_old.captcha_log definition

CREATE TABLE `captcha_log` (
  `type` varchar(32) NOT NULL COMMENT 'Type',
  `value` varchar(255) NOT NULL COMMENT 'Value',
  `count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Count',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`type`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Count Login Attempts';


-- drakesterling_old.catalog_category_entity definition

CREATE TABLE `catalog_category_entity` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Parent Category ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  `path` varchar(255) NOT NULL COMMENT 'Tree Path',
  `position` int(11) NOT NULL COMMENT 'Position',
  `level` int(11) NOT NULL DEFAULT '0' COMMENT 'Tree Level',
  `children_count` int(11) NOT NULL COMMENT 'Child Count',
  PRIMARY KEY (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_LEVEL` (`level`),
  KEY `CATALOG_CATEGORY_ENTITY_PATH` (`path`)
) ENGINE=InnoDB AUTO_INCREMENT=153 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Table';


-- drakesterling_old.catalog_category_flat_cl definition

CREATE TABLE `catalog_category_flat_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=291 DEFAULT CHARSET=utf8 COMMENT='catalog_category_flat_cl';


-- drakesterling_old.catalog_category_flat_store_1 definition

CREATE TABLE `catalog_category_flat_store_1` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'entity_id',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'parent_id',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'created_at',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'updated_at',
  `path` varchar(255) NOT NULL DEFAULT '' COMMENT 'path',
  `position` int(11) NOT NULL COMMENT 'position',
  `level` int(11) NOT NULL COMMENT 'level',
  `children_count` int(11) NOT NULL COMMENT 'children_count',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `all_children` text COMMENT 'All Children',
  `available_sort_by` text COMMENT 'Available Product Listing Sort By',
  `children` text COMMENT 'Children',
  `custom_apply_to_products` int(11) DEFAULT NULL COMMENT 'Apply To Products',
  `custom_design` varchar(255) DEFAULT NULL COMMENT 'Custom Design',
  `custom_design_from` datetime DEFAULT NULL COMMENT 'Active From',
  `custom_design_to` datetime DEFAULT NULL COMMENT 'Active To',
  `custom_layout_update` text COMMENT 'Custom Layout Update',
  `custom_layout_update_file` varchar(255) DEFAULT NULL COMMENT 'Custom Layout Update',
  `custom_use_parent_settings` int(11) DEFAULT NULL COMMENT 'Use Parent Category Settings',
  `default_sort_by` varchar(255) DEFAULT NULL COMMENT 'Default Product Listing Sort By',
  `description` text COMMENT 'Description',
  `display_mode` varchar(255) DEFAULT NULL COMMENT 'Display Mode',
  `filter_price_range` decimal(12,4) DEFAULT NULL COMMENT 'Layered Navigation Price Step',
  `generate_root_category_subtree` int(11) DEFAULT NULL COMMENT 'Generate Virtual Category Subtree',
  `image` varchar(255) DEFAULT NULL COMMENT 'Image',
  `include_in_menu` int(11) DEFAULT NULL COMMENT 'Include in Navigation Menu',
  `is_active` int(11) DEFAULT NULL COMMENT 'Is Active',
  `is_anchor` int(11) DEFAULT NULL COMMENT 'Is Anchor',
  `is_displayed_in_autocomplete` int(11) DEFAULT NULL COMMENT 'Display Category in Autocomplete',
  `is_virtual_category` int(11) DEFAULT NULL COMMENT 'Is virtual category',
  `landing_page` int(11) DEFAULT NULL COMMENT 'CMS Block',
  `meta_description` text COMMENT 'Meta Description',
  `meta_keywords` text COMMENT 'Meta Keywords',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Page Title',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `page_layout` varchar(255) DEFAULT NULL COMMENT 'Page Layout',
  `path_in_store` text COMMENT 'Path In Store',
  `sort_direction` varchar(255) DEFAULT NULL COMMENT 'Sort Direction',
  `thumbnail` varchar(255) DEFAULT NULL COMMENT 'Thumbnail',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'URL Key',
  `url_path` varchar(255) DEFAULT NULL COMMENT 'Url Path',
  `use_name_in_product_search` int(11) DEFAULT NULL COMMENT 'Use category name in product search',
  `use_store_positions` int(11) DEFAULT NULL COMMENT 'Use store positions',
  `virtual_category_root` int(11) DEFAULT NULL COMMENT 'Virtual category root',
  `virtual_rule` text COMMENT 'Virtual rule',
  PRIMARY KEY (`entity_id`),
  KEY `CATALOG_CATEGORY_FLAT_STORE_1_TMP_STORE_ID` (`store_id`),
  KEY `CATALOG_CATEGORY_FLAT_STORE_1_TMP_PATH` (`path`),
  KEY `CATALOG_CATEGORY_FLAT_STORE_1_TMP_LEVEL` (`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Flat';


-- drakesterling_old.catalog_category_product_cl definition

CREATE TABLE `catalog_category_product_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1142 DEFAULT CHARSET=utf8 COMMENT='catalog_category_product_cl';


-- drakesterling_old.catalog_category_product_index definition

CREATE TABLE `catalog_category_product_index` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Parent',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `visibility` smallint(5) unsigned NOT NULL COMMENT 'Visibility',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `CAT_CTGR_PRD_IDX_PRD_ID_STORE_ID_CTGR_ID_VISIBILITY` (`product_id`,`store_id`,`category_id`,`visibility`),
  KEY `CAT_CTGR_PRD_IDX_STORE_ID_CTGR_ID_VISIBILITY_IS_PARENT_POSITION` (`store_id`,`category_id`,`visibility`,`is_parent`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Product Index';


-- drakesterling_old.catalog_category_product_index_replica definition

CREATE TABLE `catalog_category_product_index_replica` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Parent',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `visibility` smallint(5) unsigned NOT NULL COMMENT 'Visibility',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `CAT_CTGR_PRD_IDX_PRD_ID_STORE_ID_CTGR_ID_VISIBILITY` (`product_id`,`store_id`,`category_id`,`visibility`),
  KEY `CAT_CTGR_PRD_IDX_STORE_ID_CTGR_ID_VISIBILITY_IS_PARENT_POSITION` (`store_id`,`category_id`,`visibility`,`is_parent`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Product Index';


-- drakesterling_old.catalog_category_product_index_store1 definition

CREATE TABLE `catalog_category_product_index_store1` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category Id',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product Id',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Parent',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `visibility` smallint(5) unsigned NOT NULL COMMENT 'Visibility',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `IDX_4B965DC45C352D6E4C9DC0FF50B1FCF5` (`product_id`,`store_id`,`category_id`,`visibility`),
  KEY `IDX_47AB760CD6A893ACEA69A9C2E0112C60` (`store_id`,`category_id`,`visibility`,`is_parent`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Product Index Store1 Replica';


-- drakesterling_old.catalog_category_product_index_store1_replica definition

CREATE TABLE `catalog_category_product_index_store1_replica` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category Id',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product Id',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Parent',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `visibility` smallint(5) unsigned NOT NULL COMMENT 'Visibility',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `CAT_CTGR_PRD_IDX_STORE1_PRD_ID_STORE_ID_CTGR_ID_VISIBILITY` (`product_id`,`store_id`,`category_id`,`visibility`),
  KEY `IDX_216E521C8AD125E066D2B0BAB4A08412` (`store_id`,`category_id`,`visibility`,`is_parent`,`position`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Product Index Store1';


-- drakesterling_old.catalog_category_product_index_tmp definition

CREATE TABLE `catalog_category_product_index_tmp` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  `is_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Parent',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `visibility` smallint(5) unsigned NOT NULL COMMENT 'Visibility',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `CAT_CTGR_PRD_IDX_TMP_PRD_ID_CTGR_ID_STORE_ID` (`product_id`,`category_id`,`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Category Product Indexer temporary table';


-- drakesterling_old.catalog_product_attribute_cl definition

CREATE TABLE `catalog_product_attribute_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=566972 DEFAULT CHARSET=utf8 COMMENT='catalog_product_attribute_cl';


-- drakesterling_old.catalog_product_bundle_stock_index definition

CREATE TABLE `catalog_product_bundle_stock_index` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_id` smallint(5) unsigned NOT NULL COMMENT 'Stock ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `stock_status` smallint(6) DEFAULT '0' COMMENT 'Stock Status',
  PRIMARY KEY (`entity_id`,`website_id`,`stock_id`,`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Stock Index';


-- drakesterling_old.catalog_product_category_cl definition

CREATE TABLE `catalog_product_category_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=279467 DEFAULT CHARSET=utf8 COMMENT='catalog_product_category_cl';


-- drakesterling_old.catalog_product_entity definition

CREATE TABLE `catalog_product_entity` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `type_id` varchar(32) NOT NULL DEFAULT 'simple' COMMENT 'Type ID',
  `sku` varchar(64) NOT NULL COMMENT 'SKU',
  `has_options` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Has Options',
  `required_options` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Required Options',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  PRIMARY KEY (`entity_id`),
  KEY `CATALOG_PRODUCT_ENTITY_ATTRIBUTE_SET_ID` (`attribute_set_id`),
  KEY `CATALOG_PRODUCT_ENTITY_SKU` (`sku`),
  KEY `CATALOG_PRODUCT_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=142215 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Table';


-- drakesterling_old.catalog_product_flat_1 definition

CREATE TABLE `catalog_product_flat_1` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity Id',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `type_id` varchar(32) NOT NULL DEFAULT 'simple' COMMENT 'Type Id',
  `name` varchar(255) DEFAULT NULL COMMENT 'name',
  `sku` varchar(64) NOT NULL COMMENT 'sku',
  `description` longtext COMMENT 'description',
  `short_description` longtext COMMENT 'short_description',
  `price` decimal(12,4) DEFAULT NULL COMMENT 'price',
  `special_price` decimal(12,4) DEFAULT NULL COMMENT 'special_price',
  `special_from_date` datetime DEFAULT NULL COMMENT 'special_from_date',
  `special_to_date` datetime DEFAULT NULL COMMENT 'special_to_date',
  `cost` decimal(12,4) DEFAULT NULL COMMENT 'cost',
  `weight` decimal(12,4) DEFAULT NULL COMMENT 'weight',
  `image` varchar(255) DEFAULT NULL COMMENT 'image',
  `small_image` varchar(255) DEFAULT NULL COMMENT 'small_image',
  `thumbnail` varchar(255) DEFAULT NULL COMMENT 'thumbnail',
  `news_from_date` datetime DEFAULT NULL COMMENT 'news_from_date',
  `news_to_date` datetime DEFAULT NULL COMMENT 'news_to_date',
  `visibility` smallint(5) unsigned DEFAULT NULL COMMENT 'Catalog Product Visibility visibility column',
  `required_options` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'required_options',
  `has_options` smallint(6) NOT NULL DEFAULT '0' COMMENT 'has_options',
  `image_label` varchar(255) DEFAULT NULL COMMENT 'image_label',
  `small_image_label` varchar(255) DEFAULT NULL COMMENT 'small_image_label',
  `thumbnail_label` varchar(255) DEFAULT NULL COMMENT 'thumbnail_label',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'created_at',
  `updated_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'updated_at',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'url_key',
  `url_path` varchar(255) DEFAULT NULL COMMENT 'url_path',
  `msrp` decimal(12,4) DEFAULT NULL COMMENT 'msrp',
  `msrp_display_actual_price_type` text COMMENT 'msrp_display_actual_price_type',
  `price_type` int(11) DEFAULT NULL COMMENT 'price_type',
  `sku_type` int(11) DEFAULT NULL COMMENT 'sku_type',
  `weight_type` int(11) DEFAULT NULL COMMENT 'weight_type',
  `price_view` int(11) DEFAULT NULL COMMENT 'Bundle Price View price_view column',
  `links_purchased_separately` int(11) DEFAULT NULL COMMENT 'links_purchased_separately',
  `links_title` varchar(255) DEFAULT NULL COMMENT 'links_title',
  `links_exist` int(11) DEFAULT NULL COMMENT 'links_exist',
  `gift_message_available` smallint(6) DEFAULT NULL COMMENT 'gift_message_available column',
  `swatch_image` varchar(255) DEFAULT NULL COMMENT 'swatch_image',
  `tax_class_id` int(10) unsigned DEFAULT NULL COMMENT 'tax_class_id tax column',
  `grade_prefix` longtext COMMENT 'grade_prefix',
  `year` varchar(255) DEFAULT NULL COMMENT 'year',
  `sort_string` varchar(255) DEFAULT NULL COMMENT 'sort_string',
  `make_an_offer` smallint(6) DEFAULT NULL COMMENT 'make_an_offer column',
  `archived_status` smallint(6) DEFAULT NULL COMMENT 'archived_status column',
  `hold_status` smallint(6) DEFAULT NULL COMMENT 'hold_status column',
  `certification_type` int(11) DEFAULT NULL COMMENT 'certification_type column',
  `certification_type_value` varchar(255) DEFAULT NULL COMMENT 'certification_type column',
  `grade_value` decimal(12,4) DEFAULT NULL COMMENT 'grade_value',
  `grade_suffix` longtext COMMENT 'grade_suffix',
  `sold_on` datetime DEFAULT NULL COMMENT 'sold_on',
  `sold_price` decimal(12,4) DEFAULT NULL COMMENT 'sold_price',
  `country` int(11) DEFAULT NULL COMMENT 'country column',
  `country_value` varchar(255) DEFAULT NULL COMMENT 'country column',
  `category_type` int(11) DEFAULT NULL COMMENT 'category_type column',
  `category_type_value` varchar(255) DEFAULT NULL COMMENT 'category_type column',
  `searchable_keywords` varchar(255) DEFAULT NULL COMMENT 'searchable_keywords',
  PRIMARY KEY (`entity_id`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_TYPE_ID` (`type_id`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_ATTRIBUTE_SET_ID` (`attribute_set_id`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_NAME` (`name`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_PRICE` (`price`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_YEAR` (`year`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_GRADE_VALUE` (`grade_value`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_COUNTRY` (`country`),
  KEY `CATALOG_PRODUCT_FLAT_1_TMP_INDEXER_COUNTRY_VALUE` (`country_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Flat (Store 1)';


-- drakesterling_old.catalog_product_flat_cl definition

CREATE TABLE `catalog_product_flat_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16236 DEFAULT CHARSET=utf8 COMMENT='catalog_product_flat_cl';


-- drakesterling_old.catalog_product_index_eav definition

CREATE TABLE `catalog_product_index_eav` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` int(10) unsigned NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Index Table';


-- drakesterling_old.catalog_product_index_eav_decimal definition

CREATE TABLE `catalog_product_index_eav_decimal` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` decimal(12,4) NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Decimal Index Table';


-- drakesterling_old.catalog_product_index_eav_decimal_idx definition

CREATE TABLE `catalog_product_index_eav_decimal_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` decimal(12,4) NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_IDX_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_IDX_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_IDX_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Decimal Indexer Index Table';


-- drakesterling_old.catalog_product_index_eav_decimal_replica definition

CREATE TABLE `catalog_product_index_eav_decimal_replica` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` decimal(12,4) NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Decimal Index Table';


-- drakesterling_old.catalog_product_index_eav_decimal_tmp definition

CREATE TABLE `catalog_product_index_eav_decimal_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` decimal(12,4) NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_TMP_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_TMP_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_DECIMAL_TMP_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Decimal Indexer Temp Table';


-- drakesterling_old.catalog_product_index_eav_idx definition

CREATE TABLE `catalog_product_index_eav_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` int(10) unsigned NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_IDX_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_IDX_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_IDX_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Indexer Index Table';


-- drakesterling_old.catalog_product_index_eav_replica definition

CREATE TABLE `catalog_product_index_eav_replica` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` int(10) unsigned NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Index Table';


-- drakesterling_old.catalog_product_index_eav_tmp definition

CREATE TABLE `catalog_product_index_eav_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` int(10) unsigned NOT NULL COMMENT 'Value',
  `source_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Original entity ID for attribute value',
  PRIMARY KEY (`entity_id`,`attribute_id`,`store_id`,`value`,`source_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_TMP_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_TMP_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_INDEX_EAV_TMP_VALUE` (`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product EAV Indexer Temp Table';


-- drakesterling_old.catalog_product_index_price definition

CREATE TABLE `catalog_product_index_price` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `final_price` decimal(20,6) DEFAULT NULL COMMENT 'Final Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_MIN_PRICE` (`min_price`),
  KEY `CAT_PRD_IDX_PRICE_WS_ID_CSTR_GROUP_ID_MIN_PRICE` (`website_id`,`customer_group_id`,`min_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Index Table';


-- drakesterling_old.catalog_product_index_price_bundle_idx definition

CREATE TABLE `catalog_product_index_price_bundle_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price_type` smallint(5) unsigned NOT NULL COMMENT 'Price Type',
  `special_price` decimal(20,6) DEFAULT NULL COMMENT 'Special Price',
  `tier_percent` decimal(20,6) DEFAULT NULL COMMENT 'Tier Percent',
  `orig_price` decimal(20,6) DEFAULT NULL COMMENT 'Orig Price',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `base_tier` decimal(20,6) DEFAULT NULL COMMENT 'Base Tier',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Idx';


-- drakesterling_old.catalog_product_index_price_bundle_opt_idx definition

CREATE TABLE `catalog_product_index_price_bundle_opt_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `alt_price` decimal(20,6) DEFAULT NULL COMMENT 'Alt Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `alt_tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Alt Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Opt Idx';


-- drakesterling_old.catalog_product_index_price_bundle_opt_tmp definition

CREATE TABLE `catalog_product_index_price_bundle_opt_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `alt_price` decimal(20,6) DEFAULT NULL COMMENT 'Alt Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `alt_tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Alt Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Opt Tmp';


-- drakesterling_old.catalog_product_index_price_bundle_sel_idx definition

CREATE TABLE `catalog_product_index_price_bundle_sel_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `selection_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Selection ID',
  `group_type` smallint(5) unsigned DEFAULT '0' COMMENT 'Group Type',
  `is_required` smallint(5) unsigned DEFAULT '0' COMMENT 'Is Required',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`,`selection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Sel Idx';


-- drakesterling_old.catalog_product_index_price_bundle_sel_tmp definition

CREATE TABLE `catalog_product_index_price_bundle_sel_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `selection_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Selection ID',
  `group_type` smallint(5) unsigned DEFAULT '0' COMMENT 'Group Type',
  `is_required` smallint(5) unsigned DEFAULT '0' COMMENT 'Is Required',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`,`selection_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Sel Tmp';


-- drakesterling_old.catalog_product_index_price_bundle_tmp definition

CREATE TABLE `catalog_product_index_price_bundle_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price_type` smallint(5) unsigned NOT NULL COMMENT 'Price Type',
  `special_price` decimal(20,6) DEFAULT NULL COMMENT 'Special Price',
  `tier_percent` decimal(20,6) DEFAULT NULL COMMENT 'Tier Percent',
  `orig_price` decimal(20,6) DEFAULT NULL COMMENT 'Orig Price',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `base_tier` decimal(20,6) DEFAULT NULL COMMENT 'Base Tier',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Index Price Bundle Tmp';


-- drakesterling_old.catalog_product_index_price_cfg_opt_agr_idx definition

CREATE TABLE `catalog_product_index_price_cfg_opt_agr_idx` (
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `child_id` int(10) unsigned NOT NULL COMMENT 'Child ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`parent_id`,`child_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Config Option Aggregate Index Table';


-- drakesterling_old.catalog_product_index_price_cfg_opt_agr_tmp definition

CREATE TABLE `catalog_product_index_price_cfg_opt_agr_tmp` (
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `child_id` int(10) unsigned NOT NULL COMMENT 'Child ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`parent_id`,`child_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Config Option Aggregate Temp Table';


-- drakesterling_old.catalog_product_index_price_cfg_opt_idx definition

CREATE TABLE `catalog_product_index_price_cfg_opt_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Config Option Index Table';


-- drakesterling_old.catalog_product_index_price_cfg_opt_tmp definition

CREATE TABLE `catalog_product_index_price_cfg_opt_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Config Option Temp Table';


-- drakesterling_old.catalog_product_index_price_downlod_idx definition

CREATE TABLE `catalog_product_index_price_downlod_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Minimum price',
  `max_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Maximum price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Indexer Table for price of downloadable products';


-- drakesterling_old.catalog_product_index_price_downlod_tmp definition

CREATE TABLE `catalog_product_index_price_downlod_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(11) NOT NULL,
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Minimum price',
  `max_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Maximum price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Temporary Indexer Table for price of downloadable products';


-- drakesterling_old.catalog_product_index_price_final_idx definition

CREATE TABLE `catalog_product_index_price_final_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `orig_price` decimal(20,6) DEFAULT NULL COMMENT 'Original Price',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `base_tier` decimal(20,6) DEFAULT NULL COMMENT 'Base Tier',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Final Index Table';


-- drakesterling_old.catalog_product_index_price_final_tmp definition

CREATE TABLE `catalog_product_index_price_final_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `orig_price` decimal(20,6) DEFAULT NULL COMMENT 'Original Price',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `base_tier` decimal(20,6) DEFAULT NULL COMMENT 'Base Tier',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Final Temp Table';


-- drakesterling_old.catalog_product_index_price_idx definition

CREATE TABLE `catalog_product_index_price_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `final_price` decimal(20,6) DEFAULT NULL COMMENT 'Final Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_IDX_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_IDX_WEBSITE_ID` (`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_IDX_MIN_PRICE` (`min_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Index Table';


-- drakesterling_old.catalog_product_index_price_opt_agr_idx definition

CREATE TABLE `catalog_product_index_price_opt_agr_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Option Aggregate Index Table';


-- drakesterling_old.catalog_product_index_price_opt_agr_tmp definition

CREATE TABLE `catalog_product_index_price_opt_agr_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`,`option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Option Aggregate Temp Table';


-- drakesterling_old.catalog_product_index_price_opt_idx definition

CREATE TABLE `catalog_product_index_price_opt_idx` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Option Index Table';


-- drakesterling_old.catalog_product_index_price_opt_tmp definition

CREATE TABLE `catalog_product_index_price_opt_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Option Temp Table';


-- drakesterling_old.catalog_product_index_price_replica definition

CREATE TABLE `catalog_product_index_price_replica` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `final_price` decimal(20,6) DEFAULT NULL COMMENT 'Final Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOG_PRODUCT_INDEX_PRICE_MIN_PRICE` (`min_price`),
  KEY `CAT_PRD_IDX_PRICE_WS_ID_CSTR_GROUP_ID_MIN_PRICE` (`website_id`,`customer_group_id`,`min_price`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Index Table';


-- drakesterling_old.catalog_product_index_price_tmp definition

CREATE TABLE `catalog_product_index_price_tmp` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `tax_class_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Tax Class ID',
  `price` decimal(20,6) DEFAULT NULL COMMENT 'Price',
  `final_price` decimal(20,6) DEFAULT NULL COMMENT 'Final Price',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) DEFAULT NULL COMMENT 'Max Price',
  `tier_price` decimal(20,6) DEFAULT NULL COMMENT 'Tier Price',
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Price Indexer Temp Table';


-- drakesterling_old.catalog_product_link_type definition

CREATE TABLE `catalog_product_link_type` (
  `link_type_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Link Type ID',
  `code` varchar(32) DEFAULT NULL COMMENT 'Code',
  PRIMARY KEY (`link_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Link Type Table';


-- drakesterling_old.catalog_product_price_cl definition

CREATE TABLE `catalog_product_price_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=32851 DEFAULT CHARSET=utf8 COMMENT='catalog_product_price_cl';


-- drakesterling_old.cataloginventory_stock definition

CREATE TABLE `cataloginventory_stock` (
  `stock_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Stock ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_name` varchar(255) DEFAULT NULL COMMENT 'Stock Name',
  PRIMARY KEY (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock';


-- drakesterling_old.cataloginventory_stock_cl definition

CREATE TABLE `cataloginventory_stock_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=29137 DEFAULT CHARSET=utf8 COMMENT='cataloginventory_stock_cl';


-- drakesterling_old.cataloginventory_stock_status definition

CREATE TABLE `cataloginventory_stock_status` (
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_id` smallint(5) unsigned NOT NULL COMMENT 'Stock ID',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `stock_status` smallint(5) unsigned NOT NULL COMMENT 'Stock Status',
  PRIMARY KEY (`product_id`,`website_id`,`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_STOCK_ID` (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_WEBSITE_ID` (`website_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_STOCK_STATUS` (`stock_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock Status';


-- drakesterling_old.cataloginventory_stock_status_idx definition

CREATE TABLE `cataloginventory_stock_status_idx` (
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_id` smallint(5) unsigned NOT NULL COMMENT 'Stock ID',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `stock_status` smallint(5) unsigned NOT NULL COMMENT 'Stock Status',
  PRIMARY KEY (`product_id`,`website_id`,`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_IDX_STOCK_ID` (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_IDX_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock Status Indexer Idx';


-- drakesterling_old.cataloginventory_stock_status_replica definition

CREATE TABLE `cataloginventory_stock_status_replica` (
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_id` smallint(5) unsigned NOT NULL COMMENT 'Stock ID',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `stock_status` smallint(5) unsigned NOT NULL COMMENT 'Stock Status',
  PRIMARY KEY (`product_id`,`website_id`,`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_STOCK_ID` (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_WEBSITE_ID` (`website_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_STOCK_STATUS` (`stock_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock Status';


-- drakesterling_old.cataloginventory_stock_status_tmp definition

CREATE TABLE `cataloginventory_stock_status_tmp` (
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `stock_id` smallint(5) unsigned NOT NULL COMMENT 'Stock ID',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `stock_status` smallint(5) unsigned NOT NULL COMMENT 'Stock Status',
  PRIMARY KEY (`product_id`,`website_id`,`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_TMP_STOCK_ID` (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_STATUS_TMP_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock Status Indexer Tmp';


-- drakesterling_old.catalogrule definition

CREATE TABLE `catalogrule` (
  `rule_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `description` text COMMENT 'Description',
  `from_date` date DEFAULT NULL COMMENT 'From',
  `to_date` date DEFAULT NULL COMMENT 'To',
  `is_active` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Active',
  `conditions_serialized` mediumtext COMMENT 'Conditions Serialized',
  `actions_serialized` mediumtext COMMENT 'Actions Serialized',
  `stop_rules_processing` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Stop Rules Processing',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `simple_action` varchar(32) DEFAULT NULL COMMENT 'Simple Action',
  `discount_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Discount Amount',
  PRIMARY KEY (`rule_id`),
  KEY `CATALOGRULE_IS_ACTIVE_SORT_ORDER_TO_DATE_FROM_DATE` (`is_active`,`sort_order`,`to_date`,`from_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule';


-- drakesterling_old.catalogrule_group_website definition

CREATE TABLE `catalogrule_group_website` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website1ae233bf definition

CREATE TABLE `catalogrule_group_website1ae233bf` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website1f78eff9 definition

CREATE TABLE `catalogrule_group_website1f78eff9` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website3a2baa40 definition

CREATE TABLE `catalogrule_group_website3a2baa40` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website3fb60cc7 definition

CREATE TABLE `catalogrule_group_website3fb60cc7` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website61e0be33 definition

CREATE TABLE `catalogrule_group_website61e0be33` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website73f8bcce definition

CREATE TABLE `catalogrule_group_website73f8bcce` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website288f003c definition

CREATE TABLE `catalogrule_group_website288f003c` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website05336145 definition

CREATE TABLE `catalogrule_group_website05336145` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_website_replica definition

CREATE TABLE `catalogrule_group_website_replica` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_websitebcd5eee9 definition

CREATE TABLE `catalogrule_group_websitebcd5eee9` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_group_websitecaed1228 definition

CREATE TABLE `catalogrule_group_websitecaed1228` (
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`,`website_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_GROUP_WEBSITE_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Group Website';


-- drakesterling_old.catalogrule_product definition

CREATE TABLE `catalogrule_product` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product0c6b4268 definition

CREATE TABLE `catalogrule_product0c6b4268` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product5b355771 definition

CREATE TABLE `catalogrule_product5b355771` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product13a35e55 definition

CREATE TABLE `catalogrule_product13a35e55` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product77c07331 definition

CREATE TABLE `catalogrule_product77c07331` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product591d8504 definition

CREATE TABLE `catalogrule_product591d8504` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product3905c913 definition

CREATE TABLE `catalogrule_product3905c913` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product964978c8 definition

CREATE TABLE `catalogrule_product964978c8` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_product_cl definition

CREATE TABLE `catalogrule_product_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=862681 DEFAULT CHARSET=utf8 COMMENT='catalogrule_product_cl';


-- drakesterling_old.catalogrule_product_price definition

CREATE TABLE `catalogrule_product_price` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price2db53141 definition

CREATE TABLE `catalogrule_product_price2db53141` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price41b2b130 definition

CREATE TABLE `catalogrule_product_price41b2b130` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price60d3a64b definition

CREATE TABLE `catalogrule_product_price60d3a64b` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price69b10f4f definition

CREATE TABLE `catalogrule_product_price69b10f4f` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price342d4bfe definition

CREATE TABLE `catalogrule_product_price342d4bfe` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price489ec617 definition

CREATE TABLE `catalogrule_product_price489ec617` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price557c0c68 definition

CREATE TABLE `catalogrule_product_price557c0c68` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price85772124 definition

CREATE TABLE `catalogrule_product_price85772124` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_price_replica definition

CREATE TABLE `catalogrule_product_price_replica` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_pricea977938b definition

CREATE TABLE `catalogrule_product_pricea977938b` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_pricec09d75a4 definition

CREATE TABLE `catalogrule_product_pricec09d75a4` (
  `rule_product_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product PriceId',
  `rule_date` date NOT NULL COMMENT 'Rule Date',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rule_price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Rule Price',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `latest_start_date` date DEFAULT NULL COMMENT 'Latest StartDate',
  `earliest_end_date` date DEFAULT NULL COMMENT 'Earliest EndDate',
  PRIMARY KEY (`rule_product_price_id`),
  UNIQUE KEY `CATRULE_PRD_PRICE_RULE_DATE_WS_ID_CSTR_GROUP_ID_PRD_ID` (`rule_date`,`website_id`,`customer_group_id`,`product_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_PRICE_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product Price';


-- drakesterling_old.catalogrule_product_replica definition

CREATE TABLE `catalogrule_product_replica` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_producte26fdc98 definition

CREATE TABLE `catalogrule_producte26fdc98` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_productec4247b5 definition

CREATE TABLE `catalogrule_productec4247b5` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_productfac3a35f definition

CREATE TABLE `catalogrule_productfac3a35f` (
  `rule_product_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Product ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `from_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'From Time',
  `to_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'To time',
  `customer_group_id` int(11) DEFAULT NULL,
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `action_operator` varchar(10) DEFAULT 'to_fixed' COMMENT 'Action Operator',
  `action_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Action Amount',
  `action_stop` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Action Stop',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_product_id`),
  UNIQUE KEY `UNQ_EAA51B56FF092A0DCB795D1CEF812B7B` (`rule_id`,`from_time`,`to_time`,`website_id`,`customer_group_id`,`product_id`,`sort_order`),
  KEY `CATALOGRULE_PRODUCT_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOGRULE_PRODUCT_WEBSITE_ID` (`website_id`),
  KEY `CATALOGRULE_PRODUCT_FROM_TIME` (`from_time`),
  KEY `CATALOGRULE_PRODUCT_TO_TIME` (`to_time`),
  KEY `CATALOGRULE_PRODUCT_PRODUCT_ID` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CatalogRule Product';


-- drakesterling_old.catalogrule_rule_cl definition

CREATE TABLE `catalogrule_rule_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='catalogrule_rule_cl';


-- drakesterling_old.catalogsearch_fulltext_cl definition

CREATE TABLE `catalogsearch_fulltext_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11770242 DEFAULT CHARSET=utf8 COMMENT='catalogsearch_fulltext_cl';


-- drakesterling_old.catalogsearch_fulltext_scope1 definition

CREATE TABLE `catalogsearch_fulltext_scope1` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `attribute_id` int(10) unsigned NOT NULL COMMENT 'Attribute_id',
  `data_index` longtext COMMENT 'Data index',
  PRIMARY KEY (`entity_id`,`attribute_id`),
  FULLTEXT KEY `FTI_FULLTEXT_DATA_INDEX` (`data_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='catalogsearch_fulltext_scope1_tmp';


-- drakesterling_old.categories_mapping definition

CREATE TABLE `categories_mapping` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `current_categories_tree_path` varchar(200) NOT NULL,
  `current_categories_tree_path_ids` varchar(100) NOT NULL,
  `new_categories_tree_path` varchar(200) NOT NULL,
  `new_categories_tree_path_ids` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=latin1;


-- drakesterling_old.checkout_agreement definition

CREATE TABLE `checkout_agreement` (
  `agreement_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Agreement ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `content` text COMMENT 'Content',
  `content_height` varchar(25) DEFAULT NULL COMMENT 'Content Height',
  `checkbox_text` text COMMENT 'Checkbox Text',
  `is_active` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Active',
  `is_html` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Html',
  `mode` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Applied mode',
  PRIMARY KEY (`agreement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Checkout Agreement';


-- drakesterling_old.cloudflare_data definition

CREATE TABLE `cloudflare_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `key` text NOT NULL COMMENT 'Key',
  `value` text COMMENT 'Value',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='CloudFlare Key/Value Store.';


-- drakesterling_old.cms_block definition

CREATE TABLE `cms_block` (
  `block_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `title` varchar(255) NOT NULL COMMENT 'Block Title',
  `identifier` varchar(255) NOT NULL COMMENT 'Block String Identifier',
  `content` mediumtext COMMENT 'Block Content',
  `creation_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Block Creation Time',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Block Modification Time',
  `is_active` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Is Block Active',
  PRIMARY KEY (`block_id`),
  KEY `CMS_BLOCK_IDENTIFIER` (`identifier`),
  FULLTEXT KEY `CMS_BLOCK_TITLE_IDENTIFIER_CONTENT` (`title`,`identifier`,`content`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='CMS Block Table';


-- drakesterling_old.cms_page definition

CREATE TABLE `cms_page` (
  `page_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Page Title',
  `page_layout` varchar(255) DEFAULT NULL COMMENT 'Page Layout',
  `meta_keywords` text COMMENT 'Page Meta Keywords',
  `meta_description` text COMMENT 'Page Meta Description',
  `identifier` varchar(100) DEFAULT NULL COMMENT 'Page String Identifier',
  `content_heading` varchar(255) DEFAULT NULL COMMENT 'Page Content Heading',
  `content` mediumtext COMMENT 'Page Content',
  `creation_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Page Creation Time',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Page Modification Time',
  `is_active` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Is Page Active',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Page Sort Order',
  `layout_update_xml` text COMMENT 'Page Layout Update Content',
  `custom_theme` varchar(100) DEFAULT NULL COMMENT 'Page Custom Theme',
  `custom_root_template` varchar(255) DEFAULT NULL COMMENT 'Page Custom Template',
  `custom_layout_update_xml` text COMMENT 'Page Custom Layout Update Content',
  `custom_theme_from` date DEFAULT NULL COMMENT 'Page Custom Theme Active From Date',
  `custom_theme_to` date DEFAULT NULL COMMENT 'Page Custom Theme Active To Date',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Page Meta Title',
  `cms_banner` text COMMENT 'Page Banner',
  `layout_update_selected` varchar(128) DEFAULT NULL COMMENT 'Page Custom Layout File',
  PRIMARY KEY (`page_id`),
  KEY `CMS_PAGE_IDENTIFIER` (`identifier`),
  FULLTEXT KEY `CMS_PAGE_TITLE_META_KEYWORDS_META_DESCRIPTION_IDENTIFIER_CONTENT` (`title`,`meta_keywords`,`meta_description`,`identifier`,`content`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8 COMMENT='CMS Page Table';


-- drakesterling_old.codisto_index_category_cl definition

CREATE TABLE `codisto_index_category_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='codisto_index_category_cl';


-- drakesterling_old.codisto_index_order_cl definition

CREATE TABLE `codisto_index_order_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21174 DEFAULT CHARSET=utf8 COMMENT='codisto_index_order_cl';


-- drakesterling_old.codisto_index_product_cl definition

CREATE TABLE `codisto_index_product_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3579 DEFAULT CHARSET=utf8 COMMENT='codisto_index_product_cl';


-- drakesterling_old.core_config_data definition

CREATE TABLE `core_config_data` (
  `config_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Config ID',
  `scope` varchar(8) NOT NULL DEFAULT 'default' COMMENT 'Config Scope',
  `scope_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Config Scope ID',
  `path` varchar(255) NOT NULL DEFAULT 'general' COMMENT 'Config Path',
  `value` text COMMENT 'Config Value',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `CORE_CONFIG_DATA_SCOPE_SCOPE_ID_PATH` (`scope`,`scope_id`,`path`)
) ENGINE=InnoDB AUTO_INCREMENT=1448 DEFAULT CHARSET=utf8 COMMENT='Config Data';


-- drakesterling_old.cron_schedule definition

CREATE TABLE `cron_schedule` (
  `schedule_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Schedule ID',
  `job_code` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Job Code',
  `status` varchar(7) NOT NULL DEFAULT 'pending' COMMENT 'Status',
  `messages` text COMMENT 'Messages',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `scheduled_at` timestamp NULL DEFAULT NULL COMMENT 'Scheduled At',
  `executed_at` timestamp NULL DEFAULT NULL COMMENT 'Executed At',
  `finished_at` timestamp NULL DEFAULT NULL COMMENT 'Finished At',
  `origin` int(11) DEFAULT NULL COMMENT 'Where does the schedule has been triggered? 0:Cron, 1:Backend, 2:CLI, 3:WebAPI',
  `user` varchar(100) DEFAULT NULL COMMENT 'Who triggered the schedule',
  `ip` varchar(40) DEFAULT NULL COMMENT 'From which IP?',
  `error_file` text COMMENT 'Where (file) the error has been triggered?',
  `error_line` varchar(6) DEFAULT NULL COMMENT 'Where (line) the error has been triggered?',
  PRIMARY KEY (`schedule_id`),
  KEY `CRON_SCHEDULE_JOB_CODE_STATUS_SCHEDULED_AT` (`job_code`,`status`,`scheduled_at`)
) ENGINE=InnoDB AUTO_INCREMENT=11720068 DEFAULT CHARSET=utf8 COMMENT='Cron Schedule';


-- drakesterling_old.customer_dummy_cl definition

CREATE TABLE `customer_dummy_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='customer_dummy_cl';


-- drakesterling_old.customer_grid_flat definition

CREATE TABLE `customer_grid_flat` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `name` text COMMENT 'Name',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `group_id` int(11) DEFAULT NULL COMMENT 'Group_id',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created_at',
  `website_id` int(11) DEFAULT NULL COMMENT 'Website_id',
  `confirmation` varchar(255) DEFAULT NULL COMMENT 'Confirmation',
  `created_in` text COMMENT 'Created_in',
  `dob` date DEFAULT NULL COMMENT 'Dob',
  `gender` int(11) DEFAULT NULL COMMENT 'Gender',
  `taxvat` varchar(255) DEFAULT NULL COMMENT 'Taxvat',
  `lock_expires` timestamp NULL DEFAULT NULL COMMENT 'Lock_expires',
  `pc_blacklisted` int(11) DEFAULT NULL COMMENT 'Pc_blacklisted',
  `shipping_full` text COMMENT 'Shipping_full',
  `billing_full` text COMMENT 'Billing_full',
  `billing_firstname` varchar(255) DEFAULT NULL COMMENT 'Billing_firstname',
  `billing_lastname` varchar(255) DEFAULT NULL COMMENT 'Billing_lastname',
  `billing_telephone` varchar(255) DEFAULT NULL COMMENT 'Billing_telephone',
  `billing_postcode` varchar(255) DEFAULT NULL COMMENT 'Billing_postcode',
  `billing_country_id` varchar(255) DEFAULT NULL COMMENT 'Billing_country_id',
  `billing_region` varchar(255) DEFAULT NULL COMMENT 'Billing_region',
  `billing_region_id` int(11) DEFAULT NULL COMMENT 'Billing_region_id',
  `billing_street` varchar(255) DEFAULT NULL COMMENT 'Billing_street',
  `billing_city` varchar(255) DEFAULT NULL COMMENT 'Billing_city',
  `billing_fax` varchar(255) DEFAULT NULL COMMENT 'Billing_fax',
  `billing_vat_id` varchar(255) DEFAULT NULL COMMENT 'Billing_vat_id',
  `billing_company` varchar(255) DEFAULT NULL COMMENT 'Billing_company',
  PRIMARY KEY (`entity_id`),
  KEY `CUSTOMER_GRID_FLAT_GROUP_ID` (`group_id`),
  KEY `CUSTOMER_GRID_FLAT_CREATED_AT` (`created_at`),
  KEY `CUSTOMER_GRID_FLAT_WEBSITE_ID` (`website_id`),
  KEY `CUSTOMER_GRID_FLAT_CONFIRMATION` (`confirmation`),
  KEY `CUSTOMER_GRID_FLAT_DOB` (`dob`),
  KEY `CUSTOMER_GRID_FLAT_GENDER` (`gender`),
  KEY `CUSTOMER_GRID_FLAT_PC_BLACKLISTED` (`pc_blacklisted`),
  KEY `CUSTOMER_GRID_FLAT_BILLING_COUNTRY_ID` (`billing_country_id`),
  FULLTEXT KEY `FTI_8746F705702DD5F6D45B8C7CE7FE9F2F` (`name`,`email`,`created_in`,`taxvat`,`shipping_full`,`billing_full`,`billing_firstname`,`billing_lastname`,`billing_telephone`,`billing_postcode`,`billing_region`,`billing_city`,`billing_fax`,`billing_company`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='customer_grid_flat';


-- drakesterling_old.customer_group definition

CREATE TABLE `customer_group` (
  `customer_group_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `customer_group_code` varchar(32) NOT NULL COMMENT 'Customer Group Code',
  `tax_class_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Tax Class ID',
  PRIMARY KEY (`customer_group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='Customer Group';


-- drakesterling_old.customer_group_excluded_website definition

CREATE TABLE `customer_group_excluded_website` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Excluded Website ID from Customer Group',
  PRIMARY KEY (`entity_id`),
  KEY `CUSTOMER_GROUP_EXCLUDED_WEBSITE_CUSTOMER_GROUP_ID_WEBSITE_ID` (`customer_group_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Excluded Websites From Customer Group';


-- drakesterling_old.customer_log definition

CREATE TABLE `customer_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `customer_id` int(11) NOT NULL COMMENT 'Customer ID',
  `last_login_at` timestamp NULL DEFAULT NULL COMMENT 'Last Login Time',
  `last_logout_at` timestamp NULL DEFAULT NULL COMMENT 'Last Logout Time',
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `CUSTOMER_LOG_CUSTOMER_ID` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9814 DEFAULT CHARSET=utf8 COMMENT='Customer Log Table';


-- drakesterling_old.customer_visitor definition

CREATE TABLE `customer_visitor` (
  `visitor_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Visitor ID',
  `customer_id` int(11) DEFAULT NULL COMMENT 'Customer ID',
  `session_id` varchar(1) DEFAULT NULL COMMENT 'Deprecated: Session ID value no longer used',
  `last_visit_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last Visit Time',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`visitor_id`),
  KEY `CUSTOMER_VISITOR_CUSTOMER_ID` (`customer_id`),
  KEY `CUSTOMER_VISITOR_LAST_VISIT_AT` (`last_visit_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3555220 DEFAULT CHARSET=utf8 COMMENT='Visitor Table';


-- drakesterling_old.data_exporter_uuid definition

CREATE TABLE `data_exporter_uuid` (
  `uuid` varchar(36) NOT NULL COMMENT 'Entity UUID',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `type` varchar(36) NOT NULL COMMENT 'Entity type',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `DATA_EXPORTER_UUID_ENTITY_ID_TYPE` (`entity_id`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Data Export Items UUID References Table';


-- drakesterling_old.design_config_dummy_cl definition

CREATE TABLE `design_config_dummy_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='design_config_dummy_cl';


-- drakesterling_old.design_config_grid_flat definition

CREATE TABLE `design_config_grid_flat` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `store_website_id` int(11) DEFAULT NULL COMMENT 'Store_website_id',
  `store_group_id` int(11) DEFAULT NULL COMMENT 'Store_group_id',
  `store_id` int(11) DEFAULT NULL COMMENT 'Store_id',
  `theme_theme_id` varchar(255) DEFAULT NULL COMMENT 'Theme_theme_id',
  PRIMARY KEY (`entity_id`),
  KEY `DESIGN_CONFIG_GRID_FLAT_STORE_WEBSITE_ID` (`store_website_id`),
  KEY `DESIGN_CONFIG_GRID_FLAT_STORE_GROUP_ID` (`store_group_id`),
  KEY `DESIGN_CONFIG_GRID_FLAT_STORE_ID` (`store_id`),
  FULLTEXT KEY `DESIGN_CONFIG_GRID_FLAT_THEME_THEME_ID` (`theme_theme_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='design_config_grid_flat';


-- drakesterling_old.directory_country definition

CREATE TABLE `directory_country` (
  `country_id` varchar(2) NOT NULL COMMENT 'Country ID in ISO-2',
  `iso2_code` varchar(2) DEFAULT NULL COMMENT 'Country ISO-2 format',
  `iso3_code` varchar(3) DEFAULT NULL COMMENT 'Country ISO-3',
  PRIMARY KEY (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Directory Country';


-- drakesterling_old.directory_country_format definition

CREATE TABLE `directory_country_format` (
  `country_format_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Country Format ID',
  `country_id` varchar(2) DEFAULT NULL COMMENT 'Country ID in ISO-2',
  `type` varchar(30) DEFAULT NULL COMMENT 'Country Format Type',
  `format` text NOT NULL COMMENT 'Country Format',
  PRIMARY KEY (`country_format_id`),
  UNIQUE KEY `DIRECTORY_COUNTRY_FORMAT_COUNTRY_ID_TYPE` (`country_id`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Directory Country Format';


-- drakesterling_old.directory_country_region definition

CREATE TABLE `directory_country_region` (
  `region_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Region ID',
  `country_id` varchar(4) NOT NULL DEFAULT '0' COMMENT 'Country ID in ISO-2',
  `code` varchar(32) DEFAULT NULL COMMENT 'Region code',
  `default_name` varchar(255) DEFAULT NULL COMMENT 'Region Name',
  PRIMARY KEY (`region_id`),
  KEY `DIRECTORY_COUNTRY_REGION_COUNTRY_ID` (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1173 DEFAULT CHARSET=utf8 COMMENT='Directory Country Region';


-- drakesterling_old.directory_currency_rate definition

CREATE TABLE `directory_currency_rate` (
  `currency_from` varchar(3) NOT NULL COMMENT 'Currency Code Convert From',
  `currency_to` varchar(3) NOT NULL COMMENT 'Currency Code Convert To',
  `rate` decimal(24,12) NOT NULL DEFAULT '0.000000000000' COMMENT 'Currency Conversion Rate',
  PRIMARY KEY (`currency_from`,`currency_to`),
  KEY `DIRECTORY_CURRENCY_RATE_CURRENCY_TO` (`currency_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Directory Currency Rate';


-- drakesterling_old.eav_entity_type definition

CREATE TABLE `eav_entity_type` (
  `entity_type_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Type ID',
  `entity_type_code` varchar(50) NOT NULL COMMENT 'Entity Type Code',
  `entity_model` varchar(255) NOT NULL COMMENT 'Entity Model',
  `attribute_model` varchar(255) DEFAULT NULL COMMENT 'Attribute Model',
  `entity_table` varchar(255) DEFAULT NULL COMMENT 'Entity Table',
  `value_table_prefix` varchar(255) DEFAULT NULL COMMENT 'Value Table Prefix',
  `entity_id_field` varchar(255) DEFAULT NULL COMMENT 'Entity ID Field',
  `is_data_sharing` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Defines Is Data Sharing',
  `data_sharing_key` varchar(100) DEFAULT 'default' COMMENT 'Data Sharing Key',
  `default_attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Default Attribute Set ID',
  `increment_model` varchar(255) DEFAULT NULL COMMENT 'Increment Model',
  `increment_per_store` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Increment Per Store',
  `increment_pad_length` smallint(5) unsigned NOT NULL DEFAULT '8' COMMENT 'Increment Pad Length',
  `increment_pad_char` varchar(1) NOT NULL DEFAULT '0' COMMENT 'Increment Pad Char',
  `additional_attribute_table` varchar(255) DEFAULT NULL COMMENT 'Additional Attribute Table',
  `entity_attribute_collection` varchar(255) DEFAULT NULL COMMENT 'Entity Attribute Collection',
  PRIMARY KEY (`entity_type_id`),
  KEY `EAV_ENTITY_TYPE_ENTITY_TYPE_CODE` (`entity_type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='Eav Entity Type';


-- drakesterling_old.ebpearls_makeanoffer_offer definition

CREATE TABLE `ebpearls_makeanoffer_offer` (
  `offer_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `Name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `Email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `Phone` varchar(255) DEFAULT NULL COMMENT 'Phone',
  `AdditionalMessage` text COMMENT 'AdditionalMessage',
  `product_id` int(11) DEFAULT NULL COMMENT 'product_id',
  `customer_id` int(11) DEFAULT NULL COMMENT 'customer_id',
  `offer` varchar(255) DEFAULT NULL COMMENT 'Customer Offer',
  `is_subscribed` varchar(20) DEFAULT NULL COMMENT 'Newsletter Subscribed',
  `hear_info_src_dup` varchar(255) DEFAULT NULL COMMENT 'Hear About Us',
  PRIMARY KEY (`offer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7123 DEFAULT CHARSET=utf8 COMMENT='ebpearls_makeanoffer_offer';


-- drakesterling_old.ebpearls_productinquiry_inquiry definition

CREATE TABLE `ebpearls_productinquiry_inquiry` (
  `inquiry_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `Name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `Email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `Phone` varchar(255) DEFAULT NULL COMMENT 'Phone',
  `Message` text COMMENT 'Message',
  `is_subscribed` varchar(20) DEFAULT NULL COMMENT 'Newsletter Subscribed',
  `hear_info_src_dup` varchar(255) DEFAULT NULL COMMENT 'Hear About Us',
  PRIMARY KEY (`inquiry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4943 DEFAULT CHARSET=utf8 COMMENT='ebpearls_productinquiry_inquiry';


-- drakesterling_old.ebpearls_productmapping_mapping definition

CREATE TABLE `ebpearls_productmapping_mapping` (
  `mapping_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `enabled` tinyint(1) DEFAULT NULL COMMENT 'enabled',
  `file` text COMMENT 'file',
  PRIMARY KEY (`mapping_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='ebpearls_productmapping_mapping';


-- drakesterling_old.elasticsuite_categories_fulltext_cl definition

CREATE TABLE `elasticsuite_categories_fulltext_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4506 DEFAULT CHARSET=utf8 COMMENT='elasticsuite_categories_fulltext_cl';


-- drakesterling_old.elasticsuite_thesaurus_cl definition

CREATE TABLE `elasticsuite_thesaurus_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='elasticsuite_thesaurus_cl';


-- drakesterling_old.elasticsuite_tracker_log_event definition

CREATE TABLE `elasticsuite_tracker_log_event` (
  `event_id` varchar(32) NOT NULL COMMENT 'Event ID',
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Event date',
  `data` text NOT NULL COMMENT 'Event data',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Event date',
  `is_invalid` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Has invalid data',
  PRIMARY KEY (`event_id`),
  KEY `ELASTICSUITE_TRACKER_LOG_EVENT_IS_INVALID` (`is_invalid`),
  KEY `ELASTICSUITE_TRACKER_LOG_EVENT_CREATED_AT` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.email_abandoned_cart definition

CREATE TABLE `email_abandoned_cart` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `quote_id` int(10) unsigned DEFAULT NULL COMMENT 'Quote Id',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store Id',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Email',
  `status` varchar(255) NOT NULL DEFAULT '' COMMENT 'Contact Status',
  `is_active` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Quote Active',
  `quote_updated_at` timestamp NULL DEFAULT NULL COMMENT 'Quote updated at',
  `abandoned_cart_number` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Abandoned Cart number',
  `items_count` smallint(5) unsigned DEFAULT '0' COMMENT 'Quote items count',
  `items_ids` varchar(255) DEFAULT NULL COMMENT 'Quote item ids',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated at',
  PRIMARY KEY (`id`),
  KEY `EMAIL_ABANDONED_CART_QUOTE_ID` (`quote_id`),
  KEY `EMAIL_ABANDONED_CART_STORE_ID` (`store_id`),
  KEY `EMAIL_ABANDONED_CART_CUSTOMER_ID` (`customer_id`),
  KEY `EMAIL_ABANDONED_CART_EMAIL` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Abandoned Carts Table';


-- drakesterling_old.email_automation definition

CREATE TABLE `email_automation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `automation_type` varchar(255) DEFAULT NULL COMMENT 'Automation Type',
  `store_name` varchar(255) DEFAULT NULL COMMENT 'Automation Type',
  `enrolment_status` varchar(255) NOT NULL COMMENT 'Enrolment Status',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `type_id` varchar(255) DEFAULT NULL COMMENT 'Type ID',
  `program_id` varchar(255) DEFAULT NULL COMMENT 'Program ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website Id',
  `message` varchar(255) NOT NULL COMMENT 'Message',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`id`),
  KEY `EMAIL_AUTOMATION_AUTOMATION_TYPE` (`automation_type`),
  KEY `EMAIL_AUTOMATION_ENROLMENT_STATUS` (`enrolment_status`),
  KEY `EMAIL_AUTOMATION_TYPE_ID` (`type_id`),
  KEY `EMAIL_AUTOMATION_EMAIL` (`email`),
  KEY `EMAIL_AUTOMATION_PROGRAM_ID` (`program_id`),
  KEY `EMAIL_AUTOMATION_CREATED_AT` (`created_at`),
  KEY `EMAIL_AUTOMATION_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_AUTOMATION_WEBSITE_ID` (`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Automation Status';


-- drakesterling_old.email_failed_auth definition

CREATE TABLE `email_failed_auth` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `failures_num` int(10) unsigned DEFAULT NULL COMMENT 'Number of fails',
  `first_attempt_date` datetime DEFAULT NULL COMMENT 'First attempt date',
  `last_attempt_date` datetime DEFAULT NULL COMMENT 'Last attempt date',
  `url` varchar(255) DEFAULT NULL COMMENT 'URL',
  `store_id` int(10) unsigned DEFAULT NULL COMMENT 'Store Id',
  PRIMARY KEY (`id`),
  KEY `EMAIL_AUTH_EDC_STORE_ID` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Email Failed Auth Table.';


-- drakesterling_old.email_importer definition

CREATE TABLE `email_importer` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `import_type` varchar(255) NOT NULL DEFAULT '' COMMENT 'Import Type',
  `website_id` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Website Id',
  `import_status` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Import Status',
  `import_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'Import Id',
  `import_data` mediumblob NOT NULL COMMENT 'Import Data',
  `import_mode` varchar(255) NOT NULL DEFAULT '' COMMENT 'Import Mode',
  `import_file` text NOT NULL COMMENT 'Import File',
  `message` varchar(255) NOT NULL DEFAULT '' COMMENT 'Error Message',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  `import_started` timestamp NULL DEFAULT NULL COMMENT 'Import Started',
  `import_finished` timestamp NULL DEFAULT NULL COMMENT 'Import Finished',
  PRIMARY KEY (`id`),
  KEY `EMAIL_IMPORTER_IMPORT_TYPE` (`import_type`),
  KEY `EMAIL_IMPORTER_WEBSITE_ID` (`website_id`),
  KEY `EMAIL_IMPORTER_IMPORT_STATUS` (`import_status`),
  KEY `EMAIL_IMPORTER_IMPORT_MODE` (`import_mode`),
  KEY `EMAIL_IMPORTER_CREATED_AT` (`created_at`),
  KEY `EMAIL_IMPORTER_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_IMPORTER_IMPORT_ID` (`import_id`),
  KEY `EMAIL_IMPORTER_IMPORT_STARTED` (`import_started`),
  KEY `EMAIL_IMPORTER_IMPORT_FINISHED` (`import_finished`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Email Importer';


-- drakesterling_old.email_review definition

CREATE TABLE `email_review` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `review_id` int(10) unsigned NOT NULL COMMENT 'Review Id',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store Id',
  `review_imported` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Review Imported',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`id`),
  KEY `EMAIL_REVIEW_REVIEW_ID` (`review_id`),
  KEY `EMAIL_REVIEW_CUSTOMER_ID` (`customer_id`),
  KEY `EMAIL_REVIEW_STORE_ID` (`store_id`),
  KEY `EMAIL_REVIEW_REVIEW_IMPORTED` (`review_imported`),
  KEY `EMAIL_REVIEW_CREATED_AT` (`created_at`),
  KEY `EMAIL_REVIEW_UPDATED_AT` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Connector Reviews';


-- drakesterling_old.email_rules definition

CREATE TABLE `email_rules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Rule Name',
  `website_ids` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Website Id',
  `type` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Rule Type',
  `status` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Status',
  `combination` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Rule Condition',
  `conditions` blob NOT NULL COMMENT 'Rule Conditions',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Connector Rules';


-- drakesterling_old.email_template definition

CREATE TABLE `email_template` (
  `template_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Template ID',
  `template_code` varchar(150) NOT NULL COMMENT 'Template Name',
  `template_text` text NOT NULL COMMENT 'Template Content',
  `template_styles` text COMMENT 'Templste Styles',
  `template_type` int(10) unsigned DEFAULT NULL COMMENT 'Template Type',
  `template_subject` varchar(200) NOT NULL COMMENT 'Template Subject',
  `template_sender_name` varchar(200) DEFAULT NULL COMMENT 'Template Sender Name',
  `template_sender_email` varchar(200) DEFAULT NULL COMMENT 'Template Sender Email',
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of Template Creation',
  `modified_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date of Template Modification',
  `orig_template_code` varchar(200) DEFAULT NULL COMMENT 'Original Template Code',
  `orig_template_variables` text COMMENT 'Original Template Variables',
  `is_legacy` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Should the template render in legacy mode',
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `EMAIL_TEMPLATE_TEMPLATE_CODE` (`template_code`),
  KEY `EMAIL_TEMPLATE_ADDED_AT` (`added_at`),
  KEY `EMAIL_TEMPLATE_MODIFIED_AT` (`modified_at`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COMMENT='Email Templates';


-- drakesterling_old.flag definition

CREATE TABLE `flag` (
  `flag_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Flag Id',
  `flag_code` varchar(255) NOT NULL COMMENT 'Flag Code',
  `state` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Flag State',
  `flag_data` mediumtext,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date of Last Flag Update',
  PRIMARY KEY (`flag_id`),
  KEY `FLAG_LAST_UPDATE` (`last_update`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COMMENT='Flag';


-- drakesterling_old.gift_message definition

CREATE TABLE `gift_message` (
  `gift_message_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'GiftMessage ID',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `sender` varchar(255) DEFAULT NULL COMMENT 'Sender',
  `recipient` varchar(255) DEFAULT NULL COMMENT 'Registrant',
  `message` text COMMENT 'Message',
  PRIMARY KEY (`gift_message_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Gift Message';


-- drakesterling_old.import_history definition

CREATE TABLE `import_history` (
  `history_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'History record ID',
  `started_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Started at',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'User ID',
  `imported_file` varchar(255) DEFAULT NULL COMMENT 'Imported file',
  `execution_time` varchar(255) DEFAULT NULL COMMENT 'Execution time',
  `summary` varchar(255) DEFAULT NULL COMMENT 'Summary',
  `error_file` varchar(255) NOT NULL COMMENT 'Imported file with errors',
  PRIMARY KEY (`history_id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8 COMMENT='Import history table';


-- drakesterling_old.importexport_importdata definition

CREATE TABLE `importexport_importdata` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `entity` varchar(50) NOT NULL COMMENT 'Entity',
  `behavior` varchar(10) NOT NULL DEFAULT 'append' COMMENT 'Behavior',
  `data` longtext COMMENT 'Data',
  `is_processed` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is Row Processed',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'timestamp of last update',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Import Data Table';


-- drakesterling_old.indexer_state definition

CREATE TABLE `indexer_state` (
  `state_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Indexer State ID',
  `indexer_id` varchar(255) DEFAULT NULL COMMENT 'Indexer ID',
  `status` varchar(16) DEFAULT 'invalid' COMMENT 'Indexer Status',
  `updated` datetime DEFAULT NULL COMMENT 'Indexer Status',
  `hash_config` varchar(32) NOT NULL COMMENT 'Hash of indexer config',
  PRIMARY KEY (`state_id`),
  KEY `INDEXER_STATE_INDEXER_ID` (`indexer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8 COMMENT='Indexer State';


-- drakesterling_old.jwt_auth_revoked definition

CREATE TABLE `jwt_auth_revoked` (
  `user_type_id` int(10) unsigned NOT NULL COMMENT 'User Type ID',
  `user_id` int(10) unsigned NOT NULL COMMENT 'User ID',
  `revoke_before` bigint(20) unsigned NOT NULL COMMENT 'Not accepting tokens issued before this timestamp',
  PRIMARY KEY (`user_type_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Holds revoked JWT authentication data';


-- drakesterling_old.klarna_core_order definition

CREATE TABLE `klarna_core_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `klarna_order_id` varchar(255) DEFAULT NULL COMMENT 'Klarna Order Id',
  `session_id` varchar(255) DEFAULT NULL COMMENT 'Session Id',
  `reservation_id` varchar(255) DEFAULT NULL COMMENT 'Reservation Id',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order Id',
  `is_acknowledged` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Acknowledged',
  PRIMARY KEY (`id`),
  KEY `KLARNA_CORE_ORDER_IS_ACKNOWLEDGED` (`is_acknowledged`),
  KEY `KLARNA_CORE_ORDER_ORDER_ID` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Klarna Order';


-- drakesterling_old.klarna_payments_quote definition

CREATE TABLE `klarna_payments_quote` (
  `payments_quote_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Payments Id',
  `session_id` varchar(255) DEFAULT NULL COMMENT 'Klarna Session Id',
  `client_token` text COMMENT 'Klarna Client Token',
  `authorization_token` varchar(255) DEFAULT NULL COMMENT 'Authorization Token',
  `is_active` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Active',
  `quote_id` int(10) unsigned NOT NULL COMMENT 'Quote Id',
  `payment_methods` varchar(255) DEFAULT NULL COMMENT 'Payment Method Categories',
  `payment_method_info` text COMMENT 'Payment Method Category Info',
  PRIMARY KEY (`payments_quote_id`),
  KEY `KLARNA_PAYMENTS_QUOTE_QUOTE_ID` (`quote_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Klarna Payments Quote';


-- drakesterling_old.layout_update definition

CREATE TABLE `layout_update` (
  `layout_update_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Layout Update ID',
  `handle` varchar(255) DEFAULT NULL COMMENT 'Handle',
  `xml` text COMMENT 'Xml',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `updated_at` timestamp NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last Update Timestamp',
  PRIMARY KEY (`layout_update_id`),
  KEY `LAYOUT_UPDATE_HANDLE` (`handle`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='Layout Updates';


-- drakesterling_old.login_as_customer definition

CREATE TABLE `login_as_customer` (
  `secret` varchar(64) NOT NULL COMMENT 'Login Secret',
  `customer_id` int(11) NOT NULL COMMENT 'Customer ID',
  `admin_id` int(11) NOT NULL COMMENT 'Admin ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  PRIMARY KEY (`secret`),
  KEY `LOGIN_AS_CUSTOMER_CREATED_AT` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Magento Login as Customer Table';


-- drakesterling_old.m2epro_account definition

CREATE TABLE `m2epro_account` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` text COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `title` (`title`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_account';


-- drakesterling_old.m2epro_amazon_account definition

CREATE TABLE `m2epro_amazon_account` (
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `server_hash` varchar(255) NOT NULL COMMENT 'Server_hash',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `merchant_id` varchar(255) NOT NULL COMMENT 'Merchant_id',
  `token` varchar(255) DEFAULT NULL COMMENT 'Token',
  `related_store_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Related_store_id',
  `shipping_mode` int(10) unsigned DEFAULT '1' COMMENT 'Shipping_mode',
  `other_listings_synchronization` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Other_listings_synchronization',
  `other_listings_mapping_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Other_listings_mapping_mode',
  `other_listings_mapping_settings` varchar(255) DEFAULT NULL COMMENT 'Other_listings_mapping_settings',
  `other_listings_move_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Other_listings_move_mode',
  `other_listings_move_settings` varchar(255) DEFAULT NULL COMMENT 'Other_listings_move_settings',
  `magento_orders_settings` text NOT NULL COMMENT 'Magento_orders_settings',
  `is_vat_calculation_service_enabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_vat_calculation_service_enabled',
  `is_magento_invoice_creation_disabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_magento_invoice_creation_disabled',
  `info` text COMMENT 'Info',
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_account';


-- drakesterling_old.m2epro_amazon_account_repricing definition

CREATE TABLE `m2epro_amazon_account_repricing` (
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `token` varchar(255) DEFAULT NULL COMMENT 'Token',
  `total_products` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Total_products',
  `regular_price_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Regular_price_mode',
  `regular_price_attribute` varchar(255) NOT NULL COMMENT 'Regular_price_attribute',
  `regular_price_coefficient` varchar(255) NOT NULL COMMENT 'Regular_price_coefficient',
  `regular_price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_price_variation_mode',
  `min_price_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Min_price_mode',
  `min_price_value` decimal(14,2) unsigned DEFAULT NULL COMMENT 'Min_price_value',
  `min_price_percent` int(10) unsigned DEFAULT NULL COMMENT 'Min_price_percent',
  `min_price_attribute` varchar(255) NOT NULL COMMENT 'Min_price_attribute',
  `min_price_coefficient` varchar(255) NOT NULL COMMENT 'Min_price_coefficient',
  `min_price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Min_price_variation_mode',
  `max_price_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Max_price_mode',
  `max_price_value` decimal(14,2) unsigned DEFAULT NULL COMMENT 'Max_price_value',
  `max_price_percent` int(10) unsigned DEFAULT NULL COMMENT 'Max_price_percent',
  `max_price_attribute` varchar(255) NOT NULL COMMENT 'Max_price_attribute',
  `max_price_coefficient` varchar(255) NOT NULL COMMENT 'Max_price_coefficient',
  `max_price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Max_price_variation_mode',
  `disable_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Disable_mode',
  `disable_mode_attribute` varchar(255) NOT NULL COMMENT 'Disable_mode_attribute',
  `last_checked_listing_product_update_date` datetime DEFAULT NULL COMMENT 'Last_checked_listing_product_update_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_account_repricing';


-- drakesterling_old.m2epro_amazon_dictionary_category definition

CREATE TABLE `m2epro_amazon_dictionary_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `category_id` int(10) unsigned NOT NULL COMMENT 'Category_id',
  `parent_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_category_id',
  `browsenode_id` decimal(20,0) unsigned NOT NULL COMMENT 'Browsenode_id',
  `product_data_nicks` text COMMENT 'Product_data_nicks',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `path` text COMMENT 'Path',
  `keywords` text COMMENT 'Keywords',
  `is_leaf` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_leaf',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `category_id` (`category_id`),
  KEY `parent_category_id` (`parent_category_id`),
  KEY `browsenode_id` (`browsenode_id`),
  KEY `product_data_nicks` (`product_data_nicks`(333)),
  KEY `title` (`title`),
  KEY `path` (`path`(333)),
  KEY `is_leaf` (`is_leaf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_dictionary_category';


-- drakesterling_old.m2epro_amazon_dictionary_category_product_data definition

CREATE TABLE `m2epro_amazon_dictionary_category_product_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `browsenode_id` int(10) unsigned NOT NULL COMMENT 'Browsenode_id',
  `product_data_nick` varchar(255) NOT NULL COMMENT 'Product_data_nick',
  `is_applicable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_applicable',
  `required_attributes` text COMMENT 'Required_attributes',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `browsenode_id` (`browsenode_id`),
  KEY `product_data_nick` (`product_data_nick`),
  KEY `is_applicable` (`is_applicable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_dictionary_category_product_data';


-- drakesterling_old.m2epro_amazon_dictionary_marketplace definition

CREATE TABLE `m2epro_amazon_dictionary_marketplace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `client_details_last_update_date` datetime DEFAULT NULL COMMENT 'Client_details_last_update_date',
  `server_details_last_update_date` datetime DEFAULT NULL COMMENT 'Server_details_last_update_date',
  `product_data` longtext COMMENT 'Product_data',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_dictionary_marketplace';


-- drakesterling_old.m2epro_amazon_dictionary_shipping_override definition

CREATE TABLE `m2epro_amazon_dictionary_shipping_override` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `service` varchar(255) NOT NULL COMMENT 'Service',
  `location` varchar(255) NOT NULL COMMENT 'Location',
  `option` varchar(255) NOT NULL COMMENT 'Option',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_dictionary_shipping_override';


-- drakesterling_old.m2epro_amazon_dictionary_specific definition

CREATE TABLE `m2epro_amazon_dictionary_specific` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `specific_id` int(10) unsigned NOT NULL COMMENT 'Specific_id',
  `parent_specific_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_specific_id',
  `product_data_nick` varchar(255) NOT NULL COMMENT 'Product_data_nick',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `xml_tag` varchar(255) NOT NULL COMMENT 'Xml_tag',
  `xpath` varchar(255) NOT NULL COMMENT 'Xpath',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `values` text COMMENT 'Values',
  `recommended_values` text COMMENT 'Recommended_values',
  `params` text COMMENT 'Params',
  `data_definition` text COMMENT 'Data_definition',
  `min_occurs` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Min_occurs',
  `max_occurs` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Max_occurs',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `specific_id` (`specific_id`),
  KEY `parent_specific_id` (`parent_specific_id`),
  KEY `product_data_nick` (`product_data_nick`),
  KEY `title` (`title`),
  KEY `xml_tag` (`xml_tag`),
  KEY `xpath` (`xpath`),
  KEY `type` (`type`),
  KEY `max_occurs` (`max_occurs`),
  KEY `min_occurs` (`min_occurs`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_dictionary_specific';


-- drakesterling_old.m2epro_amazon_indexer_listing_product_variation_parent definition

CREATE TABLE `m2epro_amazon_indexer_listing_product_variation_parent` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `min_regular_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Min_regular_price',
  `max_regular_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Max_regular_price',
  `min_business_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Min_business_price',
  `max_business_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Max_business_price',
  `create_date` datetime NOT NULL COMMENT 'Create_date',
  PRIMARY KEY (`listing_product_id`),
  KEY `listing_id` (`listing_id`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_indexer_listing_product_variation_parent';


-- drakesterling_old.m2epro_amazon_item definition

CREATE TABLE `m2epro_amazon_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `store_id` int(10) unsigned NOT NULL COMMENT 'Store_id',
  `variation_product_options` text COMMENT 'Variation_product_options',
  `variation_channel_options` text COMMENT 'Variation_channel_options',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `product_id` (`product_id`),
  KEY `sku` (`sku`),
  KEY `store_id` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_item';


-- drakesterling_old.m2epro_amazon_listing definition

CREATE TABLE `m2epro_amazon_listing` (
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `auto_global_adding_description_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_global_adding_description_template_id',
  `auto_website_adding_description_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_website_adding_description_template_id',
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `template_synchronization_id` int(10) unsigned NOT NULL COMMENT 'Template_synchronization_id',
  `sku_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sku_mode',
  `sku_custom_attribute` varchar(255) NOT NULL COMMENT 'Sku_custom_attribute',
  `sku_modification_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sku_modification_mode',
  `sku_modification_custom_value` varchar(255) NOT NULL COMMENT 'Sku_modification_custom_value',
  `generate_sku_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Generate_sku_mode',
  `general_id_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'General_id_mode',
  `general_id_custom_attribute` varchar(255) NOT NULL COMMENT 'General_id_custom_attribute',
  `worldwide_id_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Worldwide_id_mode',
  `worldwide_id_custom_attribute` varchar(255) NOT NULL COMMENT 'Worldwide_id_custom_attribute',
  `search_by_magento_title_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Search_by_magento_title_mode',
  `condition_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Condition_mode',
  `condition_value` varchar(255) NOT NULL COMMENT 'Condition_value',
  `condition_custom_attribute` varchar(255) NOT NULL COMMENT 'Condition_custom_attribute',
  `condition_note_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Condition_note_mode',
  `condition_note_value` text NOT NULL COMMENT 'Condition_note_value',
  `image_main_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_main_mode',
  `image_main_attribute` varchar(255) NOT NULL COMMENT 'Image_main_attribute',
  `gallery_images_mode` smallint(5) unsigned NOT NULL COMMENT 'Gallery_images_mode',
  `gallery_images_limit` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Gallery_images_limit',
  `gallery_images_attribute` varchar(255) NOT NULL COMMENT 'Gallery_images_attribute',
  `gift_wrap_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Gift_wrap_mode',
  `gift_wrap_attribute` varchar(255) NOT NULL COMMENT 'Gift_wrap_attribute',
  `gift_message_mode` smallint(5) unsigned NOT NULL COMMENT 'Gift_message_mode',
  `gift_message_attribute` varchar(255) NOT NULL COMMENT 'Gift_message_attribute',
  `handling_time_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Handling_time_mode',
  `handling_time_value` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'Handling_time_value',
  `handling_time_custom_attribute` varchar(255) NOT NULL COMMENT 'Handling_time_custom_attribute',
  `restock_date_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Restock_date_mode',
  `restock_date_value` datetime NOT NULL COMMENT 'Restock_date_value',
  `restock_date_custom_attribute` varchar(255) NOT NULL COMMENT 'Restock_date_custom_attribute',
  PRIMARY KEY (`listing_id`),
  KEY `auto_global_adding_description_template_id` (`auto_global_adding_description_template_id`),
  KEY `auto_website_adding_description_template_id` (`auto_website_adding_description_template_id`),
  KEY `generate_sku_mode` (`generate_sku_mode`),
  KEY `template_selling_format_id` (`template_selling_format_id`),
  KEY `template_synchronization_id` (`template_synchronization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing';


-- drakesterling_old.m2epro_amazon_listing_auto_category_group definition

CREATE TABLE `m2epro_amazon_listing_auto_category_group` (
  `listing_auto_category_group_id` int(10) unsigned NOT NULL COMMENT 'Listing_auto_category_group_id',
  `adding_description_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Adding_description_template_id',
  PRIMARY KEY (`listing_auto_category_group_id`),
  KEY `adding_description_template_id` (`adding_description_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_auto_category_group';


-- drakesterling_old.m2epro_amazon_listing_other definition

CREATE TABLE `m2epro_amazon_listing_other` (
  `listing_other_id` int(10) unsigned NOT NULL COMMENT 'Listing_other_id',
  `general_id` varchar(255) NOT NULL COMMENT 'General_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `online_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Online_price',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  `is_afn_channel` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_afn_channel',
  `is_isbn_general_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_isbn_general_id',
  `is_repricing` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_repricing',
  `is_repricing_disabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_repricing_disabled',
  PRIMARY KEY (`listing_other_id`),
  KEY `general_id` (`general_id`),
  KEY `sku` (`sku`),
  KEY `title` (`title`),
  KEY `online_price` (`online_price`),
  KEY `online_qty` (`online_qty`),
  KEY `is_afn_channel` (`is_afn_channel`),
  KEY `is_isbn_general_id` (`is_isbn_general_id`),
  KEY `is_repricing` (`is_repricing`),
  KEY `is_repricing_disabled` (`is_repricing_disabled`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_other';


-- drakesterling_old.m2epro_amazon_listing_product definition

CREATE TABLE `m2epro_amazon_listing_product` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `template_description_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_description_id',
  `template_shipping_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_template_id',
  `template_shipping_override_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_override_id',
  `template_product_tax_code_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_product_tax_code_id',
  `is_variation_product` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_product',
  `is_variation_product_matched` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_product_matched',
  `is_variation_channel_matched` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_channel_matched',
  `is_variation_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_parent',
  `variation_parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Variation_parent_id',
  `variation_parent_need_processor` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Variation_parent_need_processor',
  `variation_child_statuses` text COMMENT 'Variation_child_statuses',
  `general_id` varchar(255) DEFAULT NULL COMMENT 'General_id',
  `general_id_search_info` text COMMENT 'General_id_search_info',
  `search_settings_status` smallint(5) unsigned DEFAULT NULL COMMENT 'Search_settings_status',
  `search_settings_data` longtext COMMENT 'Search_settings_data',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `online_regular_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_regular_price',
  `online_regular_sale_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_regular_sale_price',
  `online_regular_sale_price_start_date` datetime DEFAULT NULL COMMENT 'Online_regular_sale_price_start_date',
  `online_regular_sale_price_end_date` datetime DEFAULT NULL COMMENT 'Online_regular_sale_price_end_date',
  `online_business_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_business_price',
  `online_business_discounts` text COMMENT 'Online_business_discounts',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  `is_repricing` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_repricing',
  `is_afn_channel` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_afn_channel',
  `is_isbn_general_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Is_isbn_general_id',
  `is_general_id_owner` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_general_id_owner',
  `variation_parent_afn_state` smallint(5) unsigned DEFAULT NULL COMMENT 'Variation_parent_afn_state',
  `variation_parent_repricing_state` smallint(5) unsigned DEFAULT NULL COMMENT 'Variation_parent_repricing_state',
  `defected_messages` text COMMENT 'Defected_messages',
  PRIMARY KEY (`listing_product_id`),
  KEY `general_id` (`general_id`),
  KEY `search_settings_status` (`search_settings_status`),
  KEY `is_repricing` (`is_repricing`),
  KEY `is_afn_channel` (`is_afn_channel`),
  KEY `is_isbn_general_id` (`is_isbn_general_id`),
  KEY `is_variation_product_matched` (`is_variation_product_matched`),
  KEY `is_variation_channel_matched` (`is_variation_channel_matched`),
  KEY `is_variation_product` (`is_variation_product`),
  KEY `online_regular_price` (`online_regular_price`),
  KEY `online_qty` (`online_qty`),
  KEY `online_regular_sale_price` (`online_regular_sale_price`),
  KEY `online_business_price` (`online_business_price`),
  KEY `sku` (`sku`),
  KEY `is_variation_parent` (`is_variation_parent`),
  KEY `variation_parent_need_processor` (`variation_parent_need_processor`),
  KEY `variation_parent_id` (`variation_parent_id`),
  KEY `is_general_id_owner` (`is_general_id_owner`),
  KEY `template_shipping_override_id` (`template_shipping_override_id`),
  KEY `template_shipping_template_id` (`template_shipping_template_id`),
  KEY `template_description_id` (`template_description_id`),
  KEY `template_product_tax_code_id` (`template_product_tax_code_id`),
  KEY `variation_parent_afn_state` (`variation_parent_afn_state`),
  KEY `variation_parent_repricing_state` (`variation_parent_repricing_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_product';


-- drakesterling_old.m2epro_amazon_listing_product_repricing definition

CREATE TABLE `m2epro_amazon_listing_product_repricing` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `is_online_disabled` smallint(5) unsigned NOT NULL COMMENT 'Is_online_disabled',
  `online_regular_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_regular_price',
  `online_min_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_min_price',
  `online_max_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_max_price',
  `is_process_required` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_process_required',
  `last_synchronization_date` datetime DEFAULT NULL COMMENT 'Last_synchronization_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`listing_product_id`),
  KEY `is_online_disabled` (`is_online_disabled`),
  KEY `is_process_required` (`is_process_required`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_product_repricing';


-- drakesterling_old.m2epro_amazon_listing_product_variation definition

CREATE TABLE `m2epro_amazon_listing_product_variation` (
  `listing_product_variation_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_id',
  PRIMARY KEY (`listing_product_variation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_product_variation';


-- drakesterling_old.m2epro_amazon_listing_product_variation_option definition

CREATE TABLE `m2epro_amazon_listing_product_variation_option` (
  `listing_product_variation_option_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_option_id',
  PRIMARY KEY (`listing_product_variation_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_listing_product_variation_option';


-- drakesterling_old.m2epro_amazon_marketplace definition

CREATE TABLE `m2epro_amazon_marketplace` (
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `developer_key` varchar(255) DEFAULT NULL COMMENT 'Developer_key',
  `default_currency` varchar(255) NOT NULL COMMENT 'Default_currency',
  `is_new_asin_available` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_new_asin_available',
  `is_merchant_fulfillment_available` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_merchant_fulfillment_available',
  `is_business_available` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_business_available',
  `is_vat_calculation_service_available` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_vat_calculation_service_available',
  `is_product_tax_code_policy_available` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_product_tax_code_policy_available',
  `is_automatic_token_retrieving_available` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_automatic_token_retrieving_available',
  PRIMARY KEY (`marketplace_id`),
  KEY `is_new_asin_available` (`is_new_asin_available`),
  KEY `is_merchant_fulfillment_available` (`is_merchant_fulfillment_available`),
  KEY `is_business_available` (`is_business_available`),
  KEY `is_vat_calculation_service_available` (`is_vat_calculation_service_available`),
  KEY `is_product_tax_code_policy_available` (`is_product_tax_code_policy_available`),
  KEY `is_automatic_token_retrieving_available` (`is_automatic_token_retrieving_available`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_marketplace';


-- drakesterling_old.m2epro_amazon_order definition

CREATE TABLE `m2epro_amazon_order` (
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `amazon_order_id` varchar(255) NOT NULL COMMENT 'Amazon_order_id',
  `is_afn_channel` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_afn_channel',
  `is_prime` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_prime',
  `is_business` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_business',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  `buyer_name` varchar(255) NOT NULL COMMENT 'Buyer_name',
  `buyer_email` varchar(255) DEFAULT NULL COMMENT 'Buyer_email',
  `shipping_service` varchar(255) DEFAULT NULL COMMENT 'Shipping_service',
  `shipping_address` text NOT NULL COMMENT 'Shipping_address',
  `shipping_price` decimal(12,4) unsigned NOT NULL COMMENT 'Shipping_price',
  `shipping_dates` text COMMENT 'Shipping_dates',
  `paid_amount` decimal(12,4) unsigned NOT NULL COMMENT 'Paid_amount',
  `tax_details` text COMMENT 'Tax_details',
  `discount_details` text COMMENT 'Discount_details',
  `qty_shipped` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Qty_shipped',
  `qty_unshipped` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Qty_unshipped',
  `currency` varchar(10) NOT NULL COMMENT 'Currency',
  `purchase_update_date` datetime DEFAULT NULL COMMENT 'Purchase_update_date',
  `purchase_create_date` datetime DEFAULT NULL COMMENT 'Purchase_create_date',
  `merchant_fulfillment_data` text COMMENT 'Merchant_fulfillment_data',
  `merchant_fulfillment_label` blob COMMENT 'Merchant_fulfillment_label',
  PRIMARY KEY (`order_id`),
  KEY `amazon_order_id` (`amazon_order_id`),
  KEY `is_prime` (`is_prime`),
  KEY `is_business` (`is_business`),
  KEY `buyer_email` (`buyer_email`),
  KEY `buyer_name` (`buyer_name`),
  KEY `paid_amount` (`paid_amount`),
  KEY `purchase_create_date` (`purchase_create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_order';


-- drakesterling_old.m2epro_amazon_order_item definition

CREATE TABLE `m2epro_amazon_order_item` (
  `order_item_id` int(10) unsigned NOT NULL COMMENT 'Order_item_id',
  `amazon_order_item_id` varchar(255) NOT NULL COMMENT 'Amazon_order_item_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `general_id` varchar(255) DEFAULT NULL COMMENT 'General_id',
  `is_isbn_general_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_isbn_general_id',
  `price` decimal(12,4) unsigned NOT NULL COMMENT 'Price',
  `gift_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Gift_price',
  `gift_message` text COMMENT 'Gift_message',
  `gift_type` varchar(255) DEFAULT NULL COMMENT 'Gift_type',
  `tax_details` text COMMENT 'Tax_details',
  `discount_details` text COMMENT 'Discount_details',
  `currency` varchar(10) NOT NULL COMMENT 'Currency',
  `qty_purchased` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Qty_purchased',
  PRIMARY KEY (`order_item_id`),
  KEY `general_id` (`general_id`),
  KEY `sku` (`sku`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_order_item';


-- drakesterling_old.m2epro_amazon_processing_action definition

CREATE TABLE `m2epro_amazon_processing_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `request_pending_single_id` int(10) unsigned DEFAULT NULL COMMENT 'Request_pending_single_id',
  `related_id` int(10) unsigned DEFAULT NULL COMMENT 'Related_id',
  `type` varchar(12) NOT NULL COMMENT 'Type',
  `request_data` longtext NOT NULL COMMENT 'Request_data',
  `start_date` datetime DEFAULT NULL COMMENT 'Start_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `processing_id` (`processing_id`),
  KEY `request_pending_single_id` (`request_pending_single_id`),
  KEY `related_id` (`related_id`),
  KEY `type` (`type`),
  KEY `start_date` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_processing_action';


-- drakesterling_old.m2epro_amazon_processing_action_list_sku definition

CREATE TABLE `m2epro_amazon_processing_action_list_sku` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_id__sku` (`account_id`,`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_processing_action_list_sku';


-- drakesterling_old.m2epro_amazon_template_description definition

CREATE TABLE `m2epro_amazon_template_description` (
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `is_new_asin_accepted` smallint(5) unsigned DEFAULT '0' COMMENT 'Is_new_asin_accepted',
  `product_data_nick` varchar(255) DEFAULT NULL COMMENT 'Product_data_nick',
  `category_path` varchar(255) DEFAULT NULL COMMENT 'Category_path',
  `browsenode_id` decimal(20,0) unsigned DEFAULT NULL COMMENT 'Browsenode_id',
  `registered_parameter` varchar(25) DEFAULT NULL COMMENT 'Registered_parameter',
  `worldwide_id_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Worldwide_id_mode',
  `worldwide_id_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Worldwide_id_custom_attribute',
  PRIMARY KEY (`template_description_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `is_new_asin_accepted` (`is_new_asin_accepted`),
  KEY `product_data_nick` (`product_data_nick`),
  KEY `browsenode_id` (`browsenode_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_description';


-- drakesterling_old.m2epro_amazon_template_description_definition definition

CREATE TABLE `m2epro_amazon_template_description_definition` (
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `title_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Title_mode',
  `title_template` varchar(255) NOT NULL COMMENT 'Title_template',
  `brand_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Brand_mode',
  `brand_custom_value` varchar(255) DEFAULT NULL COMMENT 'Brand_custom_value',
  `brand_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Brand_custom_attribute',
  `manufacturer_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Manufacturer_mode',
  `manufacturer_custom_value` varchar(255) DEFAULT NULL COMMENT 'Manufacturer_custom_value',
  `manufacturer_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Manufacturer_custom_attribute',
  `manufacturer_part_number_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Manufacturer_part_number_mode',
  `manufacturer_part_number_custom_value` varchar(255) NOT NULL COMMENT 'Manufacturer_part_number_custom_value',
  `manufacturer_part_number_custom_attribute` varchar(255) NOT NULL COMMENT 'Manufacturer_part_number_custom_attribute',
  `msrp_rrp_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Msrp_rrp_mode',
  `msrp_rrp_custom_attribute` varchar(255) NOT NULL COMMENT 'Msrp_rrp_custom_attribute',
  `item_package_quantity_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_package_quantity_mode',
  `item_package_quantity_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_package_quantity_custom_value',
  `item_package_quantity_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_package_quantity_custom_attribute',
  `number_of_items_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Number_of_items_mode',
  `number_of_items_custom_value` varchar(255) DEFAULT NULL COMMENT 'Number_of_items_custom_value',
  `number_of_items_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Number_of_items_custom_attribute',
  `item_dimensions_volume_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_dimensions_volume_mode',
  `item_dimensions_volume_length_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_length_custom_value',
  `item_dimensions_volume_width_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_width_custom_value',
  `item_dimensions_volume_height_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_height_custom_value',
  `item_dimensions_volume_length_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_length_custom_attribute',
  `item_dimensions_volume_width_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_width_custom_attribute',
  `item_dimensions_volume_height_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_height_custom_attribute',
  `item_dimensions_volume_unit_of_measure_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_dimensions_volume_unit_of_measure_mode',
  `item_dimensions_volume_unit_of_measure_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_unit_of_measure_custom_value',
  `item_dimensions_volume_unit_of_measure_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_volume_unit_of_measure_custom_attribute',
  `item_dimensions_weight_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_dimensions_weight_mode',
  `item_dimensions_weight_custom_value` decimal(10,2) unsigned DEFAULT NULL COMMENT 'Item_dimensions_weight_custom_value',
  `item_dimensions_weight_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_weight_custom_attribute',
  `item_dimensions_weight_unit_of_measure_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_dimensions_weight_unit_of_measure_mode',
  `item_dimensions_weight_unit_of_measure_custom_value` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_weight_unit_of_measure_custom_value',
  `item_dimensions_weight_unit_of_measure_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_dimensions_weight_unit_of_measure_custom_attribute',
  `package_dimensions_volume_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Package_dimensions_volume_mode',
  `package_dimensions_volume_length_custom_value` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_length_custom_value',
  `package_dimensions_volume_width_custom_value` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_width_custom_value',
  `package_dimensions_volume_height_custom_value` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_height_custom_value',
  `package_dimensions_volume_length_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_length_custom_attribute',
  `package_dimensions_volume_width_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_width_custom_attribute',
  `package_dimensions_volume_height_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_height_custom_attribute',
  `package_dimensions_volume_unit_of_measure_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Package_dimensions_volume_unit_of_measure_mode',
  `package_dimensions_volume_unit_of_measure_custom_value` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_unit_of_measure_custom_value',
  `package_dimensions_volume_unit_of_measure_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_dimensions_volume_unit_of_measure_custom_attribute',
  `shipping_weight_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Shipping_weight_mode',
  `shipping_weight_custom_value` decimal(10,2) unsigned DEFAULT NULL COMMENT 'Shipping_weight_custom_value',
  `shipping_weight_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Shipping_weight_custom_attribute',
  `shipping_weight_unit_of_measure_mode` smallint(5) unsigned DEFAULT '1' COMMENT 'Shipping_weight_unit_of_measure_mode',
  `shipping_weight_unit_of_measure_custom_value` varchar(255) DEFAULT NULL COMMENT 'Shipping_weight_unit_of_measure_custom_value',
  `shipping_weight_unit_of_measure_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Shipping_weight_unit_of_measure_custom_attribute',
  `package_weight_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Package_weight_mode',
  `package_weight_custom_value` decimal(10,2) unsigned DEFAULT NULL COMMENT 'Package_weight_custom_value',
  `package_weight_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_weight_custom_attribute',
  `package_weight_unit_of_measure_mode` smallint(5) unsigned DEFAULT '1' COMMENT 'Package_weight_unit_of_measure_mode',
  `package_weight_unit_of_measure_custom_value` varchar(255) DEFAULT NULL COMMENT 'Package_weight_unit_of_measure_custom_value',
  `package_weight_unit_of_measure_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Package_weight_unit_of_measure_custom_attribute',
  `target_audience_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Target_audience_mode',
  `target_audience` text NOT NULL COMMENT 'Target_audience',
  `search_terms_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Search_terms_mode',
  `search_terms` text NOT NULL COMMENT 'Search_terms',
  `bullet_points_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Bullet_points_mode',
  `bullet_points` text NOT NULL COMMENT 'Bullet_points',
  `description_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Description_mode',
  `description_template` longtext NOT NULL COMMENT 'Description_template',
  `image_main_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_main_mode',
  `image_main_attribute` varchar(255) NOT NULL COMMENT 'Image_main_attribute',
  `image_variation_difference_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_variation_difference_mode',
  `image_variation_difference_attribute` varchar(255) NOT NULL COMMENT 'Image_variation_difference_attribute',
  `gallery_images_mode` smallint(5) unsigned NOT NULL COMMENT 'Gallery_images_mode',
  `gallery_images_limit` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Gallery_images_limit',
  `gallery_images_attribute` varchar(255) NOT NULL COMMENT 'Gallery_images_attribute',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`template_description_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_description_definition';


-- drakesterling_old.m2epro_amazon_template_description_specific definition

CREATE TABLE `m2epro_amazon_template_description_specific` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `xpath` varchar(255) NOT NULL COMMENT 'Xpath',
  `mode` varchar(25) NOT NULL COMMENT 'Mode',
  `is_required` smallint(5) unsigned DEFAULT '0' COMMENT 'Is_required',
  `recommended_value` varchar(255) DEFAULT NULL COMMENT 'Recommended_value',
  `custom_value` varchar(255) DEFAULT NULL COMMENT 'Custom_value',
  `custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Custom_attribute',
  `type` varchar(25) DEFAULT NULL COMMENT 'Type',
  `attributes` text COMMENT 'Attributes',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `template_description_id` (`template_description_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_description_specific';


-- drakesterling_old.m2epro_amazon_template_product_tax_code definition

CREATE TABLE `m2epro_amazon_template_product_tax_code` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `product_tax_code_mode` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Product_tax_code_mode',
  `product_tax_code_value` varchar(255) DEFAULT NULL COMMENT 'Product_tax_code_value',
  `product_tax_code_attribute` varchar(255) DEFAULT NULL COMMENT 'Product_tax_code_attribute',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_product_tax_code';


-- drakesterling_old.m2epro_amazon_template_selling_format definition

CREATE TABLE `m2epro_amazon_template_selling_format` (
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `qty_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_mode',
  `qty_custom_value` int(10) unsigned NOT NULL COMMENT 'Qty_custom_value',
  `qty_custom_attribute` varchar(255) NOT NULL COMMENT 'Qty_custom_attribute',
  `qty_percentage` int(10) unsigned NOT NULL DEFAULT '100' COMMENT 'Qty_percentage',
  `qty_modification_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_modification_mode',
  `qty_min_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_min_posted_value',
  `qty_max_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_max_posted_value',
  `is_regular_customer_allowed` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_regular_customer_allowed',
  `is_business_customer_allowed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_business_customer_allowed',
  `regular_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_price_mode',
  `regular_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Regular_price_custom_attribute',
  `regular_price_coefficient` varchar(255) NOT NULL COMMENT 'Regular_price_coefficient',
  `regular_map_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_map_price_mode',
  `regular_map_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Regular_map_price_custom_attribute',
  `regular_sale_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_sale_price_mode',
  `regular_sale_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Regular_sale_price_custom_attribute',
  `regular_sale_price_coefficient` varchar(255) NOT NULL COMMENT 'Regular_sale_price_coefficient',
  `regular_price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_price_variation_mode',
  `regular_sale_price_start_date_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_sale_price_start_date_mode',
  `regular_sale_price_start_date_value` datetime NOT NULL COMMENT 'Regular_sale_price_start_date_value',
  `regular_sale_price_start_date_custom_attribute` varchar(255) NOT NULL COMMENT 'Regular_sale_price_start_date_custom_attribute',
  `regular_sale_price_end_date_mode` smallint(5) unsigned NOT NULL COMMENT 'Regular_sale_price_end_date_mode',
  `regular_sale_price_end_date_value` datetime NOT NULL COMMENT 'Regular_sale_price_end_date_value',
  `regular_sale_price_end_date_custom_attribute` varchar(255) NOT NULL COMMENT 'Regular_sale_price_end_date_custom_attribute',
  `regular_price_vat_percent` float(10,0) unsigned DEFAULT NULL COMMENT 'Regular_price_vat_percent',
  `business_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Business_price_mode',
  `business_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Business_price_custom_attribute',
  `business_price_coefficient` varchar(255) NOT NULL COMMENT 'Business_price_coefficient',
  `business_price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Business_price_variation_mode',
  `business_price_vat_percent` float(10,0) unsigned DEFAULT NULL COMMENT 'Business_price_vat_percent',
  `business_discounts_mode` smallint(5) unsigned NOT NULL COMMENT 'Business_discounts_mode',
  `business_discounts_tier_coefficient` varchar(255) NOT NULL COMMENT 'Business_discounts_tier_coefficient',
  `business_discounts_tier_customer_group_id` int(10) unsigned DEFAULT NULL COMMENT 'Business_discounts_tier_customer_group_id',
  PRIMARY KEY (`template_selling_format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_selling_format';


-- drakesterling_old.m2epro_amazon_template_selling_format_business_discount definition

CREATE TABLE `m2epro_amazon_template_selling_format_business_discount` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `qty` int(10) unsigned NOT NULL COMMENT 'Qty',
  `mode` smallint(5) unsigned NOT NULL COMMENT 'Mode',
  `attribute` varchar(255) DEFAULT NULL COMMENT 'Attribute',
  `coefficient` varchar(255) DEFAULT NULL COMMENT 'Coefficient',
  PRIMARY KEY (`id`),
  KEY `template_selling_format_id` (`template_selling_format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_selling_format_business_discount';


-- drakesterling_old.m2epro_amazon_template_shipping_override definition

CREATE TABLE `m2epro_amazon_template_shipping_override` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `title` (`title`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_shipping_override';


-- drakesterling_old.m2epro_amazon_template_shipping_override_service definition

CREATE TABLE `m2epro_amazon_template_shipping_override_service` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_shipping_override_id` int(10) unsigned NOT NULL COMMENT 'Template_shipping_override_id',
  `service` varchar(255) NOT NULL COMMENT 'Service',
  `location` varchar(255) NOT NULL COMMENT 'Location',
  `option` varchar(255) NOT NULL COMMENT 'Option',
  `type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Type',
  `cost_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Cost_mode',
  `cost_value` varchar(255) NOT NULL COMMENT 'Cost_value',
  PRIMARY KEY (`id`),
  KEY `template_shipping_override_id` (`template_shipping_override_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_shipping_override_service';


-- drakesterling_old.m2epro_amazon_template_shipping_template definition

CREATE TABLE `m2epro_amazon_template_shipping_template` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `template_name_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_name_mode',
  `template_name_value` varchar(255) NOT NULL COMMENT 'Template_name_value',
  `template_name_attribute` varchar(255) NOT NULL COMMENT 'Template_name_attribute',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_shipping_template';


-- drakesterling_old.m2epro_amazon_template_synchronization definition

CREATE TABLE `m2epro_amazon_template_synchronization` (
  `template_synchronization_id` int(10) unsigned NOT NULL COMMENT 'Template_synchronization_id',
  `list_mode` smallint(5) unsigned NOT NULL COMMENT 'List_mode',
  `list_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'List_status_enabled',
  `list_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'List_is_in_stock',
  `list_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'List_qty_magento',
  `list_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value',
  `list_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value_max',
  `list_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'List_qty_calculated',
  `list_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value',
  `list_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value_max',
  `list_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'List_advanced_rules_mode',
  `list_advanced_rules_filters` text COMMENT 'List_advanced_rules_filters',
  `revise_update_qty` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty',
  `revise_update_qty_max_applied_value_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty_max_applied_value_mode',
  `revise_update_qty_max_applied_value` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_qty_max_applied_value',
  `revise_update_price` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price',
  `revise_update_price_max_allowed_deviation_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price_max_allowed_deviation_mode',
  `revise_update_price_max_allowed_deviation` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_price_max_allowed_deviation',
  `revise_update_details` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_details',
  `revise_update_images` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_images',
  `revise_change_description_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_description_template',
  `revise_change_shipping_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_shipping_template',
  `revise_change_product_tax_code_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_product_tax_code_template',
  `relist_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_mode',
  `relist_filter_user_lock` smallint(5) unsigned NOT NULL COMMENT 'Relist_filter_user_lock',
  `relist_send_data` smallint(5) unsigned NOT NULL COMMENT 'Relist_send_data',
  `relist_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'Relist_status_enabled',
  `relist_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'Relist_is_in_stock',
  `relist_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_magento',
  `relist_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value',
  `relist_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value_max',
  `relist_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_calculated',
  `relist_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value',
  `relist_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value_max',
  `relist_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_advanced_rules_mode',
  `relist_advanced_rules_filters` text COMMENT 'Relist_advanced_rules_filters',
  `stop_status_disabled` smallint(5) unsigned NOT NULL COMMENT 'Stop_status_disabled',
  `stop_out_off_stock` smallint(5) unsigned NOT NULL COMMENT 'Stop_out_off_stock',
  `stop_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_magento',
  `stop_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value',
  `stop_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value_max',
  `stop_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_calculated',
  `stop_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value',
  `stop_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value_max',
  `stop_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Stop_advanced_rules_mode',
  `stop_advanced_rules_filters` text COMMENT 'Stop_advanced_rules_filters',
  PRIMARY KEY (`template_synchronization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_amazon_template_synchronization';


-- drakesterling_old.m2epro_archived_entity definition

CREATE TABLE `m2epro_archived_entity` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `origin_id` int(10) unsigned NOT NULL COMMENT 'Origin_id',
  `name` varchar(255) NOT NULL COMMENT 'Name',
  `data` longtext NOT NULL COMMENT 'Data',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `origin_id__name` (`origin_id`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_archived_entity';


-- drakesterling_old.m2epro_cache_config definition

CREATE TABLE `m2epro_cache_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `group` varchar(255) DEFAULT NULL COMMENT 'Group',
  `key` varchar(255) NOT NULL COMMENT 'Key',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  `notice` text COMMENT 'Notice',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  KEY `key` (`key`),
  KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='m2epro_cache_config';


-- drakesterling_old.m2epro_connector_pending_requester_partial definition

CREATE TABLE `m2epro_connector_pending_requester_partial` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `request_pending_partial_id` int(10) unsigned NOT NULL COMMENT 'Request_pending_partial_id',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `request_pending_partial_id` (`request_pending_partial_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_connector_pending_requester_partial';


-- drakesterling_old.m2epro_connector_pending_requester_single definition

CREATE TABLE `m2epro_connector_pending_requester_single` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `request_pending_single_id` int(10) unsigned DEFAULT NULL COMMENT 'Request_pending_single_id',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `processing_id` (`processing_id`),
  KEY `request_pending_single_id` (`request_pending_single_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_connector_pending_requester_single';


-- drakesterling_old.m2epro_ebay_account definition

CREATE TABLE `m2epro_ebay_account` (
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `mode` smallint(5) unsigned NOT NULL COMMENT 'Mode',
  `server_hash` varchar(255) NOT NULL COMMENT 'Server_hash',
  `user_id` varchar(255) NOT NULL COMMENT 'User_id',
  `translation_hash` varchar(255) DEFAULT NULL COMMENT 'Translation_hash',
  `translation_info` text COMMENT 'Translation_info',
  `token_session` varchar(255) NOT NULL COMMENT 'Token_session',
  `token_expired_date` datetime NOT NULL COMMENT 'Token_expired_date',
  `marketplaces_data` text COMMENT 'Marketplaces_data',
  `defaults_last_synchronization` datetime DEFAULT NULL COMMENT 'Defaults_last_synchronization',
  `other_listings_synchronization` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Other_listings_synchronization',
  `other_listings_mapping_mode` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Other_listings_mapping_mode',
  `other_listings_mapping_settings` varchar(255) DEFAULT NULL COMMENT 'Other_listings_mapping_settings',
  `other_listings_last_synchronization` datetime DEFAULT NULL COMMENT 'Other_listings_last_synchronization',
  `feedbacks_receive` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Feedbacks_receive',
  `feedbacks_auto_response` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Feedbacks_auto_response',
  `feedbacks_auto_response_only_positive` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Feedbacks_auto_response_only_positive',
  `feedbacks_last_used_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Feedbacks_last_used_id',
  `ebay_store_title` varchar(255) NOT NULL COMMENT 'Ebay_store_title',
  `ebay_store_url` text NOT NULL COMMENT 'Ebay_store_url',
  `ebay_store_subscription_level` varchar(255) NOT NULL COMMENT 'Ebay_store_subscription_level',
  `ebay_store_description` text NOT NULL COMMENT 'Ebay_store_description',
  `info` text COMMENT 'Info',
  `user_preferences` text COMMENT 'User_preferences',
  `ebay_shipping_discount_profiles` text COMMENT 'Ebay_shipping_discount_profiles',
  `job_token` varchar(255) DEFAULT NULL COMMENT 'Job_token',
  `orders_last_synchronization` datetime DEFAULT NULL COMMENT 'Orders_last_synchronization',
  `magento_orders_settings` text NOT NULL COMMENT 'Magento_orders_settings',
  `messages_receive` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Messages_receive',
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_account';


-- drakesterling_old.m2epro_ebay_account_pickup_store definition

CREATE TABLE `m2epro_ebay_account_pickup_store` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `name` varchar(255) NOT NULL COMMENT 'Name',
  `location_id` varchar(255) DEFAULT NULL COMMENT 'Location_id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `phone` varchar(255) NOT NULL COMMENT 'Phone',
  `postal_code` varchar(50) NOT NULL COMMENT 'Postal_code',
  `url` varchar(255) NOT NULL COMMENT 'Url',
  `utc_offset` varchar(50) NOT NULL COMMENT 'Utc_offset',
  `country` varchar(255) NOT NULL COMMENT 'Country',
  `region` varchar(255) NOT NULL COMMENT 'Region',
  `city` varchar(255) NOT NULL COMMENT 'City',
  `address_1` varchar(255) NOT NULL COMMENT 'Address_1',
  `address_2` varchar(255) NOT NULL COMMENT 'Address_2',
  `latitude` float(10,0) DEFAULT NULL COMMENT 'Latitude',
  `longitude` float(10,0) DEFAULT NULL COMMENT 'Longitude',
  `business_hours` text NOT NULL COMMENT 'Business_hours',
  `special_hours` text NOT NULL COMMENT 'Special_hours',
  `pickup_instruction` text NOT NULL COMMENT 'Pickup_instruction',
  `qty_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_mode',
  `qty_custom_value` int(10) unsigned NOT NULL COMMENT 'Qty_custom_value',
  `qty_custom_attribute` varchar(255) NOT NULL COMMENT 'Qty_custom_attribute',
  `qty_percentage` int(10) unsigned NOT NULL DEFAULT '100' COMMENT 'Qty_percentage',
  `qty_modification_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_modification_mode',
  `qty_min_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_min_posted_value',
  `qty_max_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_max_posted_value',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `name` (`name`),
  KEY `location_id` (`location_id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_account_pickup_store';


-- drakesterling_old.m2epro_ebay_account_pickup_store_log definition

CREATE TABLE `m2epro_ebay_account_pickup_store_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_pickup_store_state_id` int(10) unsigned DEFAULT NULL COMMENT 'Account_pickup_store_state_id',
  `location_id` varchar(255) NOT NULL COMMENT 'Location_id',
  `location_title` varchar(255) DEFAULT NULL COMMENT 'Location_title',
  `action_id` int(10) unsigned NOT NULL COMMENT 'Action_id',
  `action` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Action',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `priority` smallint(5) unsigned NOT NULL DEFAULT '3' COMMENT 'Priority',
  `description` text COMMENT 'Description',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_pickup_store_state_id` (`account_pickup_store_state_id`),
  KEY `location_id` (`location_id`),
  KEY `location_title` (`location_title`),
  KEY `action` (`action`),
  KEY `action_id` (`action_id`),
  KEY `priority` (`priority`),
  KEY `type` (`type`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_account_pickup_store_log';


-- drakesterling_old.m2epro_ebay_account_pickup_store_state definition

CREATE TABLE `m2epro_ebay_account_pickup_store_state` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_pickup_store_id` int(10) unsigned NOT NULL COMMENT 'Account_pickup_store_id',
  `is_in_processing` smallint(5) unsigned DEFAULT '0' COMMENT 'Is_in_processing',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `online_qty` int(11) NOT NULL COMMENT 'Online_qty',
  `target_qty` int(11) NOT NULL COMMENT 'Target_qty',
  `is_added` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is_added',
  `is_deleted` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is_deleted',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_pickup_store_id` (`account_pickup_store_id`),
  KEY `is_in_processing` (`is_in_processing`),
  KEY `sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_account_pickup_store_state';


-- drakesterling_old.m2epro_ebay_account_store_category definition

CREATE TABLE `m2epro_ebay_account_store_category` (
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `category_id` decimal(20,0) unsigned NOT NULL COMMENT 'Category_id',
  `parent_id` decimal(20,0) unsigned NOT NULL COMMENT 'Parent_id',
  `title` varchar(200) NOT NULL COMMENT 'Title',
  `is_leaf` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_leaf',
  `sorder` int(10) unsigned NOT NULL COMMENT 'Sorder',
  PRIMARY KEY (`account_id`,`category_id`),
  KEY `parent_id` (`parent_id`),
  KEY `sorder` (`sorder`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_account_store_category';


-- drakesterling_old.m2epro_ebay_dictionary_category definition

CREATE TABLE `m2epro_ebay_dictionary_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `category_id` int(10) unsigned NOT NULL COMMENT 'Category_id',
  `parent_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_category_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `path` text COMMENT 'Path',
  `features` longtext COMMENT 'Features',
  `item_specifics` longtext COMMENT 'Item_specifics',
  `is_leaf` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_leaf',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `category_id` (`category_id`),
  KEY `is_leaf` (`is_leaf`),
  KEY `parent_category_id` (`parent_category_id`),
  KEY `title` (`title`),
  KEY `path` (`path`(333))
) ENGINE=InnoDB AUTO_INCREMENT=12784 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_dictionary_category';


-- drakesterling_old.m2epro_ebay_dictionary_marketplace definition

CREATE TABLE `m2epro_ebay_dictionary_marketplace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `client_details_last_update_date` datetime DEFAULT NULL COMMENT 'Client_details_last_update_date',
  `server_details_last_update_date` datetime DEFAULT NULL COMMENT 'Server_details_last_update_date',
  `dispatch` longtext NOT NULL COMMENT 'Dispatch',
  `packages` longtext NOT NULL COMMENT 'Packages',
  `return_policy` longtext NOT NULL COMMENT 'Return_policy',
  `listing_features` longtext NOT NULL COMMENT 'Listing_features',
  `payments` longtext NOT NULL COMMENT 'Payments',
  `shipping_locations` longtext NOT NULL COMMENT 'Shipping_locations',
  `shipping_locations_exclude` longtext NOT NULL COMMENT 'Shipping_locations_exclude',
  `additional_data` longtext COMMENT 'Additional_data',
  `tax_categories` longtext NOT NULL COMMENT 'Tax_categories',
  `charities` longtext NOT NULL COMMENT 'Charities',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_dictionary_marketplace';


-- drakesterling_old.m2epro_ebay_dictionary_motor_epid definition

CREATE TABLE `m2epro_ebay_dictionary_motor_epid` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `epid` varchar(255) NOT NULL COMMENT 'Epid',
  `product_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Product_type',
  `make` varchar(255) NOT NULL COMMENT 'Make',
  `model` varchar(255) NOT NULL COMMENT 'Model',
  `year` smallint(5) unsigned NOT NULL COMMENT 'Year',
  `trim` varchar(255) DEFAULT NULL COMMENT 'Trim',
  `engine` varchar(255) DEFAULT NULL COMMENT 'Engine',
  `submodel` varchar(255) DEFAULT NULL COMMENT 'Submodel',
  `is_custom` smallint(5) unsigned NOT NULL COMMENT 'Is_custom',
  `scope` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Scope',
  PRIMARY KEY (`id`),
  KEY `epid` (`epid`),
  KEY `engine` (`engine`),
  KEY `make` (`make`),
  KEY `model` (`model`),
  KEY `product_type` (`product_type`),
  KEY `submodel` (`submodel`),
  KEY `trim` (`trim`),
  KEY `year` (`year`),
  KEY `is_custom` (`is_custom`),
  KEY `scope` (`scope`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_dictionary_motor_epid';


-- drakesterling_old.m2epro_ebay_dictionary_motor_ktype definition

CREATE TABLE `m2epro_ebay_dictionary_motor_ktype` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `ktype` int(10) unsigned NOT NULL COMMENT 'Ktype',
  `make` varchar(255) DEFAULT NULL COMMENT 'Make',
  `model` varchar(255) DEFAULT NULL COMMENT 'Model',
  `variant` varchar(255) DEFAULT NULL COMMENT 'Variant',
  `body_style` varchar(255) DEFAULT NULL COMMENT 'Body_style',
  `type` varchar(255) DEFAULT NULL COMMENT 'Type',
  `from_year` int(11) DEFAULT NULL COMMENT 'From_year',
  `to_year` int(11) DEFAULT NULL COMMENT 'To_year',
  `engine` varchar(255) DEFAULT NULL COMMENT 'Engine',
  `is_custom` smallint(5) unsigned NOT NULL COMMENT 'Is_custom',
  PRIMARY KEY (`id`),
  KEY `body_style` (`body_style`),
  KEY `engine` (`engine`),
  KEY `from_year` (`from_year`),
  KEY `ktype` (`ktype`),
  KEY `make` (`make`),
  KEY `model` (`model`),
  KEY `to_year` (`to_year`),
  KEY `type` (`type`),
  KEY `variant` (`variant`),
  KEY `is_custom` (`is_custom`)
) ENGINE=InnoDB AUTO_INCREMENT=49050 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_dictionary_motor_ktype';


-- drakesterling_old.m2epro_ebay_dictionary_shipping definition

CREATE TABLE `m2epro_ebay_dictionary_shipping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `ebay_id` varchar(255) NOT NULL COMMENT 'Ebay_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `category` varchar(255) NOT NULL COMMENT 'Category',
  `is_flat` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_flat',
  `is_calculated` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_calculated',
  `is_international` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_international',
  `data` longtext NOT NULL COMMENT 'Data',
  PRIMARY KEY (`id`),
  KEY `category` (`category`),
  KEY `ebay_id` (`ebay_id`),
  KEY `is_calculated` (`is_calculated`),
  KEY `is_flat` (`is_flat`),
  KEY `is_international` (`is_international`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_dictionary_shipping';


-- drakesterling_old.m2epro_ebay_feedback definition

CREATE TABLE `m2epro_ebay_feedback` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `ebay_item_id` decimal(20,0) unsigned NOT NULL COMMENT 'Ebay_item_id',
  `ebay_item_title` varchar(255) NOT NULL COMMENT 'Ebay_item_title',
  `ebay_transaction_id` varchar(20) NOT NULL COMMENT 'Ebay_transaction_id',
  `buyer_name` varchar(200) NOT NULL COMMENT 'Buyer_name',
  `buyer_feedback_id` decimal(20,0) unsigned NOT NULL COMMENT 'Buyer_feedback_id',
  `buyer_feedback_text` varchar(255) NOT NULL COMMENT 'Buyer_feedback_text',
  `buyer_feedback_date` datetime NOT NULL COMMENT 'Buyer_feedback_date',
  `buyer_feedback_type` varchar(20) NOT NULL COMMENT 'Buyer_feedback_type',
  `seller_feedback_id` decimal(20,0) unsigned NOT NULL COMMENT 'Seller_feedback_id',
  `seller_feedback_text` varchar(255) NOT NULL COMMENT 'Seller_feedback_text',
  `seller_feedback_date` datetime NOT NULL COMMENT 'Seller_feedback_date',
  `seller_feedback_type` varchar(20) NOT NULL COMMENT 'Seller_feedback_type',
  `last_response_attempt_date` datetime DEFAULT NULL COMMENT 'Last_response_attempt_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `buyer_feedback_id` (`buyer_feedback_id`),
  KEY `ebay_item_id` (`ebay_item_id`),
  KEY `ebay_transaction_id` (`ebay_transaction_id`),
  KEY `seller_feedback_id` (`seller_feedback_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_feedback';


-- drakesterling_old.m2epro_ebay_feedback_template definition

CREATE TABLE `m2epro_ebay_feedback_template` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `body` text NOT NULL COMMENT 'Body',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_feedback_template';


-- drakesterling_old.m2epro_ebay_indexer_listing_product_variation_parent definition

CREATE TABLE `m2epro_ebay_indexer_listing_product_variation_parent` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `min_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Min_price',
  `max_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Max_price',
  `create_date` datetime NOT NULL COMMENT 'Create_date',
  PRIMARY KEY (`listing_product_id`),
  KEY `listing_id` (`listing_id`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_indexer_listing_product_variation_parent';


-- drakesterling_old.m2epro_ebay_item definition

CREATE TABLE `m2epro_ebay_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `item_id` decimal(20,0) unsigned NOT NULL COMMENT 'Item_id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `store_id` int(10) unsigned NOT NULL COMMENT 'Store_id',
  `variations` text COMMENT 'Variations',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `item_id` (`item_id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `product_id` (`product_id`),
  KEY `store_id` (`store_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_item';


-- drakesterling_old.m2epro_ebay_listing definition

CREATE TABLE `m2epro_ebay_listing` (
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `products_sold_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Products_sold_count',
  `items_sold_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Items_sold_count',
  `auto_global_adding_template_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_global_adding_template_category_id',
  `auto_global_adding_template_other_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_global_adding_template_other_category_id',
  `auto_website_adding_template_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_website_adding_template_category_id',
  `auto_website_adding_template_other_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_website_adding_template_other_category_id',
  `template_payment_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_payment_mode',
  `template_payment_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_payment_id',
  `template_payment_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_payment_custom_id',
  `template_shipping_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_shipping_mode',
  `template_shipping_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_id',
  `template_shipping_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_custom_id',
  `template_return_policy_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_return_policy_mode',
  `template_return_policy_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_return_policy_id',
  `template_return_policy_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_return_policy_custom_id',
  `template_description_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_description_mode',
  `template_description_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_description_id',
  `template_description_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_description_custom_id',
  `template_selling_format_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_selling_format_mode',
  `template_selling_format_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_selling_format_id',
  `template_selling_format_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_selling_format_custom_id',
  `template_synchronization_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Template_synchronization_mode',
  `template_synchronization_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_synchronization_id',
  `template_synchronization_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_synchronization_custom_id',
  `product_add_ids` text COMMENT 'Product_add_ids',
  `parts_compatibility_mode` varchar(10) DEFAULT NULL COMMENT 'Parts_compatibility_mode',
  PRIMARY KEY (`listing_id`),
  KEY `auto_global_adding_template_category_id` (`auto_global_adding_template_category_id`),
  KEY `auto_global_adding_template_other_category_id` (`auto_global_adding_template_other_category_id`),
  KEY `auto_website_adding_template_category_id` (`auto_website_adding_template_category_id`),
  KEY `auto_website_adding_template_other_category_id` (`auto_website_adding_template_other_category_id`),
  KEY `items_sold_count` (`items_sold_count`),
  KEY `products_sold_count` (`products_sold_count`),
  KEY `template_description_custom_id` (`template_description_custom_id`),
  KEY `template_description_id` (`template_description_id`),
  KEY `template_description_mode` (`template_description_mode`),
  KEY `template_payment_custom_id` (`template_payment_custom_id`),
  KEY `template_payment_id` (`template_payment_id`),
  KEY `template_payment_mode` (`template_payment_mode`),
  KEY `template_return_policy_custom_id` (`template_return_policy_custom_id`),
  KEY `template_return_policy_id` (`template_return_policy_id`),
  KEY `template_return_policy_mode` (`template_return_policy_mode`),
  KEY `template_selling_format_custom_id` (`template_selling_format_custom_id`),
  KEY `template_selling_format_id` (`template_selling_format_id`),
  KEY `template_selling_format_mode` (`template_selling_format_mode`),
  KEY `template_shipping_custom_id` (`template_shipping_custom_id`),
  KEY `template_shipping_id` (`template_shipping_id`),
  KEY `template_shipping_mode` (`template_shipping_mode`),
  KEY `template_synchronization_custom_id` (`template_synchronization_custom_id`),
  KEY `template_synchronization_id` (`template_synchronization_id`),
  KEY `template_synchronization_mode` (`template_synchronization_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing';


-- drakesterling_old.m2epro_ebay_listing_auto_category_group definition

CREATE TABLE `m2epro_ebay_listing_auto_category_group` (
  `listing_auto_category_group_id` int(10) unsigned NOT NULL COMMENT 'Listing_auto_category_group_id',
  `adding_template_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Adding_template_category_id',
  `adding_template_other_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Adding_template_other_category_id',
  PRIMARY KEY (`listing_auto_category_group_id`),
  KEY `adding_template_category_id` (`adding_template_category_id`),
  KEY `adding_template_other_category_id` (`adding_template_other_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_auto_category_group';


-- drakesterling_old.m2epro_ebay_listing_other definition

CREATE TABLE `m2epro_ebay_listing_other` (
  `listing_other_id` int(10) unsigned NOT NULL COMMENT 'Listing_other_id',
  `item_id` decimal(20,0) unsigned NOT NULL COMMENT 'Item_id',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `currency` varchar(255) DEFAULT NULL COMMENT 'Currency',
  `online_duration` int(10) unsigned DEFAULT NULL COMMENT 'Online_duration',
  `online_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Online_price',
  `online_qty` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Online_qty',
  `online_qty_sold` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Online_qty_sold',
  `online_bids` int(10) unsigned DEFAULT NULL COMMENT 'Online_bids',
  `start_date` datetime NOT NULL COMMENT 'Start_date',
  `end_date` datetime DEFAULT NULL COMMENT 'End_date',
  PRIMARY KEY (`listing_other_id`),
  KEY `currency` (`currency`),
  KEY `end_date` (`end_date`),
  KEY `item_id` (`item_id`),
  KEY `online_bids` (`online_bids`),
  KEY `online_price` (`online_price`),
  KEY `online_qty` (`online_qty`),
  KEY `online_qty_sold` (`online_qty_sold`),
  KEY `sku` (`sku`),
  KEY `start_date` (`start_date`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_other';


-- drakesterling_old.m2epro_ebay_listing_product definition

CREATE TABLE `m2epro_ebay_listing_product` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `template_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_category_id',
  `template_other_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_other_category_id',
  `ebay_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Ebay_item_id',
  `item_uuid` varchar(32) DEFAULT NULL COMMENT 'Item_uuid',
  `is_duplicate` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_duplicate',
  `online_is_variation` smallint(5) unsigned DEFAULT NULL COMMENT 'Online_is_variation',
  `online_is_auction_type` smallint(5) unsigned DEFAULT NULL COMMENT 'Online_is_auction_type',
  `online_sku` varchar(255) DEFAULT NULL COMMENT 'Online_sku',
  `online_title` varchar(255) DEFAULT NULL COMMENT 'Online_title',
  `online_duration` int(10) unsigned DEFAULT NULL COMMENT 'Online_duration',
  `online_current_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_current_price',
  `online_start_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_start_price',
  `online_reserve_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_reserve_price',
  `online_buyitnow_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_buyitnow_price',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  `online_qty_sold` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty_sold',
  `online_bids` int(10) unsigned DEFAULT NULL COMMENT 'Online_bids',
  `online_category` varchar(255) DEFAULT NULL COMMENT 'Online_category',
  `translation_status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Translation_status',
  `translation_service` varchar(255) DEFAULT NULL COMMENT 'Translation_service',
  `translated_date` datetime DEFAULT NULL COMMENT 'Translated_date',
  `start_date` datetime DEFAULT NULL COMMENT 'Start_date',
  `end_date` datetime DEFAULT NULL COMMENT 'End_date',
  `template_payment_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_payment_mode',
  `template_payment_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_payment_id',
  `template_payment_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_payment_custom_id',
  `template_shipping_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_shipping_mode',
  `template_shipping_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_id',
  `template_shipping_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_shipping_custom_id',
  `template_return_policy_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_return_policy_mode',
  `template_return_policy_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_return_policy_id',
  `template_return_policy_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_return_policy_custom_id',
  `template_description_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_description_mode',
  `template_description_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_description_id',
  `template_description_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_description_custom_id',
  `template_selling_format_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_selling_format_mode',
  `template_selling_format_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_selling_format_id',
  `template_selling_format_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_selling_format_custom_id',
  `template_synchronization_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Template_synchronization_mode',
  `template_synchronization_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_synchronization_id',
  `template_synchronization_custom_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_synchronization_custom_id',
  PRIMARY KEY (`listing_product_id`),
  KEY `ebay_item_id` (`ebay_item_id`),
  KEY `item_uuid` (`item_uuid`),
  KEY `is_duplicate` (`is_duplicate`),
  KEY `online_is_variation` (`online_is_variation`),
  KEY `online_is_auction_type` (`online_is_auction_type`),
  KEY `end_date` (`end_date`),
  KEY `online_bids` (`online_bids`),
  KEY `online_buyitnow_price` (`online_buyitnow_price`),
  KEY `online_category` (`online_category`),
  KEY `online_qty` (`online_qty`),
  KEY `online_qty_sold` (`online_qty_sold`),
  KEY `online_reserve_price` (`online_reserve_price`),
  KEY `online_sku` (`online_sku`),
  KEY `online_current_price` (`online_current_price`),
  KEY `online_start_price` (`online_start_price`),
  KEY `online_title` (`online_title`),
  KEY `start_date` (`start_date`),
  KEY `translation_status` (`translation_status`),
  KEY `translation_service` (`translation_service`),
  KEY `translated_date` (`translated_date`),
  KEY `template_category_id` (`template_category_id`),
  KEY `template_description_custom_id` (`template_description_custom_id`),
  KEY `template_description_id` (`template_description_id`),
  KEY `template_description_mode` (`template_description_mode`),
  KEY `template_other_category_id` (`template_other_category_id`),
  KEY `template_payment_custom_id` (`template_payment_custom_id`),
  KEY `template_payment_id` (`template_payment_id`),
  KEY `template_payment_mode` (`template_payment_mode`),
  KEY `template_return_policy_custom_id` (`template_return_policy_custom_id`),
  KEY `template_return_policy_id` (`template_return_policy_id`),
  KEY `template_return_policy_mode` (`template_return_policy_mode`),
  KEY `template_selling_format_custom_id` (`template_selling_format_custom_id`),
  KEY `template_selling_format_id` (`template_selling_format_id`),
  KEY `template_selling_format_mode` (`template_selling_format_mode`),
  KEY `template_shipping_custom_id` (`template_shipping_custom_id`),
  KEY `template_shipping_id` (`template_shipping_id`),
  KEY `template_shipping_mode` (`template_shipping_mode`),
  KEY `template_synchronization_custom_id` (`template_synchronization_custom_id`),
  KEY `template_synchronization_id` (`template_synchronization_id`),
  KEY `template_synchronization_mode` (`template_synchronization_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_product';


-- drakesterling_old.m2epro_ebay_listing_product_pickup_store definition

CREATE TABLE `m2epro_ebay_listing_product_pickup_store` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `listing_product_id` int(10) unsigned DEFAULT NULL COMMENT 'Listing_product_id',
  `account_pickup_store_id` int(10) unsigned DEFAULT NULL COMMENT 'Account_pickup_store_id',
  `is_process_required` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_process_required',
  PRIMARY KEY (`id`),
  KEY `listing_product_id` (`listing_product_id`),
  KEY `account_pickup_store_id` (`account_pickup_store_id`),
  KEY `is_process_required` (`is_process_required`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_product_pickup_store';


-- drakesterling_old.m2epro_ebay_listing_product_variation definition

CREATE TABLE `m2epro_ebay_listing_product_variation` (
  `listing_product_variation_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_id',
  `add` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Add',
  `delete` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Delete',
  `online_sku` varchar(255) DEFAULT NULL COMMENT 'Online_sku',
  `online_price` decimal(12,4) DEFAULT NULL COMMENT 'Online_price',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  `online_qty_sold` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty_sold',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  PRIMARY KEY (`listing_product_variation_id`),
  KEY `add` (`add`),
  KEY `delete` (`delete`),
  KEY `online_sku` (`online_sku`),
  KEY `online_price` (`online_price`),
  KEY `online_qty` (`online_qty`),
  KEY `online_qty_sold` (`online_qty_sold`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_product_variation';


-- drakesterling_old.m2epro_ebay_listing_product_variation_option definition

CREATE TABLE `m2epro_ebay_listing_product_variation_option` (
  `listing_product_variation_option_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_option_id',
  PRIMARY KEY (`listing_product_variation_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_listing_product_variation_option';


-- drakesterling_old.m2epro_ebay_marketplace definition

CREATE TABLE `m2epro_ebay_marketplace` (
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `currency` varchar(70) NOT NULL DEFAULT 'USD' COMMENT 'Currency',
  `origin_country` varchar(255) DEFAULT NULL COMMENT 'Origin_country',
  `language_code` varchar(255) DEFAULT NULL COMMENT 'Language_code',
  `translation_service_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Translation_service_mode',
  `is_multivariation` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_multivariation',
  `is_freight_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_freight_shipping',
  `is_calculated_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_calculated_shipping',
  `is_tax_table` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_tax_table',
  `is_vat` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_vat',
  `is_stp` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_stp',
  `is_stp_advanced` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_stp_advanced',
  `is_map` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_map',
  `is_local_shipping_rate_table` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_local_shipping_rate_table',
  `is_international_shipping_rate_table` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_international_shipping_rate_table',
  `is_english_measurement_system` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_english_measurement_system',
  `is_metric_measurement_system` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_metric_measurement_system',
  `is_cash_on_delivery` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_cash_on_delivery',
  `is_global_shipping_program` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_global_shipping_program',
  `is_charity` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_charity',
  `is_click_and_collect` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_click_and_collect',
  `is_in_store_pickup` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_in_store_pickup',
  `is_holiday_return` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_holiday_return',
  `is_epid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_epid',
  `is_ktype` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_ktype',
  PRIMARY KEY (`marketplace_id`),
  KEY `is_calculated_shipping` (`is_calculated_shipping`),
  KEY `is_cash_on_delivery` (`is_cash_on_delivery`),
  KEY `is_charity` (`is_charity`),
  KEY `is_english_measurement_system` (`is_english_measurement_system`),
  KEY `is_freight_shipping` (`is_freight_shipping`),
  KEY `is_international_shipping_rate_table` (`is_international_shipping_rate_table`),
  KEY `is_local_shipping_rate_table` (`is_local_shipping_rate_table`),
  KEY `is_metric_measurement_system` (`is_metric_measurement_system`),
  KEY `is_tax_table` (`is_tax_table`),
  KEY `is_vat` (`is_vat`),
  KEY `is_stp` (`is_stp`),
  KEY `is_stp_advanced` (`is_stp_advanced`),
  KEY `is_map` (`is_map`),
  KEY `is_click_and_collect` (`is_click_and_collect`),
  KEY `is_in_store_pickup` (`is_in_store_pickup`),
  KEY `is_holiday_return` (`is_holiday_return`),
  KEY `is_epid` (`is_epid`),
  KEY `is_ktype` (`is_ktype`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_marketplace';


-- drakesterling_old.m2epro_ebay_motor_filter definition

CREATE TABLE `m2epro_ebay_motor_filter` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `type` smallint(5) unsigned NOT NULL COMMENT 'Type',
  `conditions` text NOT NULL COMMENT 'Conditions',
  `note` text COMMENT 'Note',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_motor_filter';


-- drakesterling_old.m2epro_ebay_motor_filter_to_group definition

CREATE TABLE `m2epro_ebay_motor_filter_to_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `filter_id` int(10) unsigned NOT NULL COMMENT 'Filter_id',
  `group_id` int(10) unsigned NOT NULL COMMENT 'Group_id',
  PRIMARY KEY (`id`),
  KEY `filter_id` (`filter_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_motor_filter_to_group';


-- drakesterling_old.m2epro_ebay_motor_group definition

CREATE TABLE `m2epro_ebay_motor_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `mode` smallint(5) unsigned NOT NULL COMMENT 'Mode',
  `type` smallint(5) unsigned NOT NULL COMMENT 'Type',
  `items_data` text COMMENT 'Items_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `mode` (`mode`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_motor_group';


-- drakesterling_old.m2epro_ebay_order definition

CREATE TABLE `m2epro_ebay_order` (
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `ebay_order_id` varchar(255) NOT NULL COMMENT 'Ebay_order_id',
  `selling_manager_id` int(10) unsigned DEFAULT NULL COMMENT 'Selling_manager_id',
  `buyer_name` varchar(255) NOT NULL COMMENT 'Buyer_name',
  `buyer_email` varchar(255) NOT NULL COMMENT 'Buyer_email',
  `buyer_user_id` varchar(255) NOT NULL COMMENT 'Buyer_user_id',
  `buyer_message` text COMMENT 'Buyer_message',
  `buyer_tax_id` varchar(64) DEFAULT NULL COMMENT 'Buyer_tax_id',
  `paid_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Paid_amount',
  `saved_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Saved_amount',
  `currency` varchar(10) NOT NULL COMMENT 'Currency',
  `checkout_status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Checkout_status',
  `shipping_status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Shipping_status',
  `payment_status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Payment_status',
  `shipping_details` text COMMENT 'Shipping_details',
  `payment_details` text COMMENT 'Payment_details',
  `tax_details` text COMMENT 'Tax_details',
  `purchase_update_date` datetime DEFAULT NULL COMMENT 'Purchase_update_date',
  `purchase_create_date` datetime DEFAULT NULL COMMENT 'Purchase_create_date',
  PRIMARY KEY (`order_id`),
  KEY `ebay_order_id` (`ebay_order_id`),
  KEY `selling_manager_id` (`selling_manager_id`),
  KEY `buyer_email` (`buyer_email`),
  KEY `buyer_name` (`buyer_name`),
  KEY `buyer_user_id` (`buyer_user_id`),
  KEY `paid_amount` (`paid_amount`),
  KEY `checkout_status` (`checkout_status`),
  KEY `payment_status` (`payment_status`),
  KEY `shipping_status` (`shipping_status`),
  KEY `purchase_create_date` (`purchase_create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_order';


-- drakesterling_old.m2epro_ebay_order_external_transaction definition

CREATE TABLE `m2epro_ebay_order_external_transaction` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `transaction_id` varchar(255) NOT NULL COMMENT 'Transaction_id',
  `fee` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Fee',
  `sum` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Sum',
  `is_refund` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_refund',
  `transaction_date` datetime NOT NULL COMMENT 'Transaction_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `order_id` (`order_id`),
  KEY `transaction_id` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_order_external_transaction';


-- drakesterling_old.m2epro_ebay_order_item definition

CREATE TABLE `m2epro_ebay_order_item` (
  `order_item_id` int(10) unsigned NOT NULL COMMENT 'Order_item_id',
  `transaction_id` varchar(20) NOT NULL COMMENT 'Transaction_id',
  `selling_manager_id` int(10) unsigned DEFAULT NULL COMMENT 'Selling_manager_id',
  `item_id` decimal(20,0) unsigned NOT NULL COMMENT 'Item_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `sku` varchar(64) DEFAULT NULL COMMENT 'Sku',
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `qty_purchased` int(10) unsigned NOT NULL COMMENT 'Qty_purchased',
  `tax_details` text COMMENT 'Tax_details',
  `final_fee` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Final_fee',
  `waste_recycling_fee` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Waste_recycling_fee',
  `variation_details` text COMMENT 'Variation_details',
  `tracking_details` text COMMENT 'Tracking_details',
  `unpaid_item_process_state` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Unpaid_item_process_state',
  PRIMARY KEY (`order_item_id`),
  KEY `transaction_id` (`transaction_id`),
  KEY `selling_manager_id` (`selling_manager_id`),
  KEY `item_id` (`item_id`),
  KEY `sku` (`sku`),
  KEY `title` (`title`),
  KEY `unpaid_item_process_state` (`unpaid_item_process_state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_order_item';


-- drakesterling_old.m2epro_ebay_processing_action definition

CREATE TABLE `m2epro_ebay_processing_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `related_id` int(10) unsigned DEFAULT NULL COMMENT 'Related_id',
  `type` varchar(12) NOT NULL COMMENT 'Type',
  `priority` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Priority',
  `request_timeout` int(10) unsigned DEFAULT NULL COMMENT 'Request_timeout',
  `request_data` longtext NOT NULL COMMENT 'Request_data',
  `start_date` datetime DEFAULT NULL COMMENT 'Start_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `processing_id` (`processing_id`),
  KEY `type` (`type`),
  KEY `priority` (`priority`),
  KEY `start_date` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_processing_action';


-- drakesterling_old.m2epro_ebay_template_category definition

CREATE TABLE `m2epro_ebay_template_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `category_main_id` int(10) unsigned NOT NULL COMMENT 'Category_main_id',
  `category_main_path` varchar(255) DEFAULT NULL COMMENT 'Category_main_path',
  `category_main_mode` smallint(5) unsigned NOT NULL DEFAULT '2' COMMENT 'Category_main_mode',
  `category_main_attribute` varchar(255) NOT NULL COMMENT 'Category_main_attribute',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_category';


-- drakesterling_old.m2epro_ebay_template_category_specific definition

CREATE TABLE `m2epro_ebay_template_category_specific` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_category_id` int(10) unsigned NOT NULL COMMENT 'Template_category_id',
  `mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Mode',
  `attribute_title` varchar(255) NOT NULL COMMENT 'Attribute_title',
  `value_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Value_mode',
  `value_ebay_recommended` longtext COMMENT 'Value_ebay_recommended',
  `value_custom_value` varchar(255) DEFAULT NULL COMMENT 'Value_custom_value',
  `value_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Value_custom_attribute',
  PRIMARY KEY (`id`),
  KEY `template_category_id` (`template_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_category_specific';


-- drakesterling_old.m2epro_ebay_template_description definition

CREATE TABLE `m2epro_ebay_template_description` (
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `title_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Title_mode',
  `title_template` varchar(255) NOT NULL COMMENT 'Title_template',
  `subtitle_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Subtitle_mode',
  `subtitle_template` varchar(255) NOT NULL COMMENT 'Subtitle_template',
  `description_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Description_mode',
  `description_template` longtext NOT NULL COMMENT 'Description_template',
  `condition_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Condition_mode',
  `condition_value` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Condition_value',
  `condition_attribute` varchar(255) NOT NULL COMMENT 'Condition_attribute',
  `condition_note_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Condition_note_mode',
  `condition_note_template` text NOT NULL COMMENT 'Condition_note_template',
  `product_details` text COMMENT 'Product_details',
  `cut_long_titles` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Cut_long_titles',
  `hit_counter` varchar(255) NOT NULL COMMENT 'Hit_counter',
  `editor_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Editor_type',
  `enhancement` varchar(255) NOT NULL COMMENT 'Enhancement',
  `gallery_type` smallint(5) unsigned NOT NULL DEFAULT '4' COMMENT 'Gallery_type',
  `image_main_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_main_mode',
  `image_main_attribute` varchar(255) NOT NULL COMMENT 'Image_main_attribute',
  `gallery_images_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Gallery_images_mode',
  `gallery_images_limit` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Gallery_images_limit',
  `gallery_images_attribute` varchar(255) NOT NULL COMMENT 'Gallery_images_attribute',
  `variation_images_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Variation_images_mode',
  `variation_images_limit` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Variation_images_limit',
  `variation_images_attribute` varchar(255) NOT NULL COMMENT 'Variation_images_attribute',
  `default_image_url` varchar(255) DEFAULT NULL COMMENT 'Default_image_url',
  `variation_configurable_images` text COMMENT 'Variation_configurable_images',
  `use_supersize_images` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Use_supersize_images',
  `watermark_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Watermark_mode',
  `watermark_image` longblob COMMENT 'Watermark_image',
  `watermark_settings` text COMMENT 'Watermark_settings',
  PRIMARY KEY (`template_description_id`),
  KEY `is_custom_template` (`is_custom_template`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_description';


-- drakesterling_old.m2epro_ebay_template_other_category definition

CREATE TABLE `m2epro_ebay_template_other_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `category_secondary_id` int(10) unsigned NOT NULL COMMENT 'Category_secondary_id',
  `category_secondary_path` varchar(255) DEFAULT NULL COMMENT 'Category_secondary_path',
  `category_secondary_mode` smallint(5) unsigned NOT NULL DEFAULT '2' COMMENT 'Category_secondary_mode',
  `category_secondary_attribute` varchar(255) NOT NULL COMMENT 'Category_secondary_attribute',
  `store_category_main_id` decimal(20,0) unsigned NOT NULL COMMENT 'Store_category_main_id',
  `store_category_main_path` varchar(255) DEFAULT NULL COMMENT 'Store_category_main_path',
  `store_category_main_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store_category_main_mode',
  `store_category_main_attribute` varchar(255) NOT NULL COMMENT 'Store_category_main_attribute',
  `store_category_secondary_id` decimal(20,0) unsigned NOT NULL COMMENT 'Store_category_secondary_id',
  `store_category_secondary_path` varchar(255) DEFAULT NULL COMMENT 'Store_category_secondary_path',
  `store_category_secondary_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store_category_secondary_mode',
  `store_category_secondary_attribute` varchar(255) NOT NULL COMMENT 'Store_category_secondary_attribute',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_other_category';


-- drakesterling_old.m2epro_ebay_template_payment definition

CREATE TABLE `m2epro_ebay_template_payment` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `pay_pal_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Pay_pal_mode',
  `pay_pal_email_address` varchar(255) NOT NULL COMMENT 'Pay_pal_email_address',
  `pay_pal_immediate_payment` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Pay_pal_immediate_payment',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `is_custom_template` (`is_custom_template`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_payment';


-- drakesterling_old.m2epro_ebay_template_payment_service definition

CREATE TABLE `m2epro_ebay_template_payment_service` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_payment_id` int(10) unsigned NOT NULL COMMENT 'Template_payment_id',
  `code_name` varchar(255) NOT NULL COMMENT 'Code_name',
  PRIMARY KEY (`id`),
  KEY `template_payment_id` (`template_payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_payment_service';


-- drakesterling_old.m2epro_ebay_template_return_policy definition

CREATE TABLE `m2epro_ebay_template_return_policy` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `accepted` varchar(255) NOT NULL COMMENT 'Accepted',
  `option` varchar(255) NOT NULL COMMENT 'Option',
  `within` varchar(255) NOT NULL COMMENT 'Within',
  `holiday_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Holiday_mode',
  `shipping_cost` varchar(255) NOT NULL COMMENT 'Shipping_cost',
  `restocking_fee` varchar(255) NOT NULL COMMENT 'Restocking_fee',
  `description` text NOT NULL COMMENT 'Description',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `is_custom_template` (`is_custom_template`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_return_policy';


-- drakesterling_old.m2epro_ebay_template_selling_format definition

CREATE TABLE `m2epro_ebay_template_selling_format` (
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `listing_type` smallint(5) unsigned NOT NULL COMMENT 'Listing_type',
  `listing_type_attribute` varchar(255) NOT NULL COMMENT 'Listing_type_attribute',
  `listing_is_private` smallint(5) unsigned NOT NULL COMMENT 'Listing_is_private',
  `restricted_to_business` smallint(5) unsigned DEFAULT '0' COMMENT 'Restricted_to_business',
  `duration_mode` smallint(5) unsigned NOT NULL COMMENT 'Duration_mode',
  `duration_attribute` varchar(255) NOT NULL COMMENT 'Duration_attribute',
  `out_of_stock_control` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Out_of_stock_control',
  `qty_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_mode',
  `qty_custom_value` int(10) unsigned NOT NULL COMMENT 'Qty_custom_value',
  `qty_custom_attribute` varchar(255) NOT NULL COMMENT 'Qty_custom_attribute',
  `qty_percentage` int(10) unsigned NOT NULL DEFAULT '100' COMMENT 'Qty_percentage',
  `qty_modification_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_modification_mode',
  `qty_min_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_min_posted_value',
  `qty_max_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_max_posted_value',
  `vat_percent` float(10,0) NOT NULL DEFAULT '0' COMMENT 'Vat_percent',
  `tax_table_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Tax_table_mode',
  `tax_category_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Tax_category_mode',
  `tax_category_value` varchar(255) NOT NULL COMMENT 'Tax_category_value',
  `tax_category_attribute` varchar(255) NOT NULL COMMENT 'Tax_category_attribute',
  `price_increase_vat_percent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Price_increase_vat_percent',
  `price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_variation_mode',
  `fixed_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Fixed_price_mode',
  `fixed_price_coefficient` varchar(255) NOT NULL COMMENT 'Fixed_price_coefficient',
  `fixed_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Fixed_price_custom_attribute',
  `start_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Start_price_mode',
  `start_price_coefficient` varchar(255) NOT NULL COMMENT 'Start_price_coefficient',
  `start_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Start_price_custom_attribute',
  `reserve_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Reserve_price_mode',
  `reserve_price_coefficient` varchar(255) NOT NULL COMMENT 'Reserve_price_coefficient',
  `reserve_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Reserve_price_custom_attribute',
  `buyitnow_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Buyitnow_price_mode',
  `buyitnow_price_coefficient` varchar(255) NOT NULL COMMENT 'Buyitnow_price_coefficient',
  `buyitnow_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Buyitnow_price_custom_attribute',
  `price_discount_stp_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_discount_stp_mode',
  `price_discount_stp_attribute` varchar(255) NOT NULL COMMENT 'Price_discount_stp_attribute',
  `price_discount_stp_type` smallint(5) unsigned NOT NULL COMMENT 'Price_discount_stp_type',
  `price_discount_map_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_discount_map_mode',
  `price_discount_map_attribute` varchar(255) NOT NULL COMMENT 'Price_discount_map_attribute',
  `price_discount_map_exposure_type` smallint(5) unsigned NOT NULL COMMENT 'Price_discount_map_exposure_type',
  `best_offer_mode` smallint(5) unsigned NOT NULL COMMENT 'Best_offer_mode',
  `best_offer_accept_mode` smallint(5) unsigned NOT NULL COMMENT 'Best_offer_accept_mode',
  `best_offer_accept_value` varchar(255) NOT NULL COMMENT 'Best_offer_accept_value',
  `best_offer_accept_attribute` varchar(255) NOT NULL COMMENT 'Best_offer_accept_attribute',
  `best_offer_reject_mode` smallint(5) unsigned NOT NULL COMMENT 'Best_offer_reject_mode',
  `best_offer_reject_value` varchar(255) NOT NULL COMMENT 'Best_offer_reject_value',
  `best_offer_reject_attribute` varchar(255) NOT NULL COMMENT 'Best_offer_reject_attribute',
  `charity` text COMMENT 'Charity',
  `ignore_variations` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Ignore_variations',
  PRIMARY KEY (`template_selling_format_id`),
  KEY `is_custom_template` (`is_custom_template`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_selling_format';


-- drakesterling_old.m2epro_ebay_template_shipping definition

CREATE TABLE `m2epro_ebay_template_shipping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `country_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Country_mode',
  `country_custom_value` varchar(255) NOT NULL COMMENT 'Country_custom_value',
  `country_custom_attribute` varchar(255) NOT NULL COMMENT 'Country_custom_attribute',
  `postal_code_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Postal_code_mode',
  `postal_code_custom_value` varchar(255) NOT NULL COMMENT 'Postal_code_custom_value',
  `postal_code_custom_attribute` varchar(255) NOT NULL COMMENT 'Postal_code_custom_attribute',
  `address_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Address_mode',
  `address_custom_value` varchar(255) NOT NULL COMMENT 'Address_custom_value',
  `address_custom_attribute` varchar(255) NOT NULL COMMENT 'Address_custom_attribute',
  `dispatch_time` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'Dispatch_time',
  `local_shipping_rate_table_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Local_shipping_rate_table_mode',
  `international_shipping_rate_table_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'International_shipping_rate_table_mode',
  `local_shipping_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Local_shipping_mode',
  `local_shipping_discount_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Local_shipping_discount_mode',
  `local_shipping_discount_profile_id` text COMMENT 'Local_shipping_discount_profile_id',
  `click_and_collect_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Click_and_collect_mode',
  `cash_on_delivery_cost` varchar(255) DEFAULT NULL COMMENT 'Cash_on_delivery_cost',
  `international_shipping_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'International_shipping_mode',
  `international_shipping_discount_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'International_shipping_discount_mode',
  `international_shipping_discount_profile_id` text COMMENT 'International_shipping_discount_profile_id',
  `excluded_locations` text COMMENT 'Excluded_locations',
  `cross_border_trade` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Cross_border_trade',
  `global_shipping_program` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Global_shipping_program',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `is_custom_template` (`is_custom_template`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_shipping';


-- drakesterling_old.m2epro_ebay_template_shipping_calculated definition

CREATE TABLE `m2epro_ebay_template_shipping_calculated` (
  `template_shipping_id` int(10) unsigned NOT NULL COMMENT 'Template_shipping_id',
  `measurement_system` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Measurement_system',
  `package_size_mode` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Package_size_mode',
  `package_size_value` text NOT NULL COMMENT 'Package_size_value',
  `package_size_attribute` varchar(255) NOT NULL COMMENT 'Package_size_attribute',
  `dimension_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Dimension_mode',
  `dimension_width_value` text NOT NULL COMMENT 'Dimension_width_value',
  `dimension_width_attribute` varchar(255) NOT NULL COMMENT 'Dimension_width_attribute',
  `dimension_length_value` text NOT NULL COMMENT 'Dimension_length_value',
  `dimension_length_attribute` varchar(255) NOT NULL COMMENT 'Dimension_length_attribute',
  `dimension_depth_value` text NOT NULL COMMENT 'Dimension_depth_value',
  `dimension_depth_attribute` varchar(255) NOT NULL COMMENT 'Dimension_depth_attribute',
  `weight_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Weight_mode',
  `weight_minor` text NOT NULL COMMENT 'Weight_minor',
  `weight_major` text NOT NULL COMMENT 'Weight_major',
  `weight_attribute` varchar(255) NOT NULL COMMENT 'Weight_attribute',
  `local_handling_cost` varchar(255) DEFAULT NULL COMMENT 'Local_handling_cost',
  `international_handling_cost` varchar(255) DEFAULT NULL COMMENT 'International_handling_cost',
  PRIMARY KEY (`template_shipping_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_shipping_calculated';


-- drakesterling_old.m2epro_ebay_template_shipping_service definition

CREATE TABLE `m2epro_ebay_template_shipping_service` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_shipping_id` int(10) unsigned NOT NULL COMMENT 'Template_shipping_id',
  `shipping_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Shipping_type',
  `shipping_value` varchar(255) NOT NULL COMMENT 'Shipping_value',
  `cost_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Cost_mode',
  `cost_value` varchar(255) NOT NULL COMMENT 'Cost_value',
  `cost_additional_value` varchar(255) NOT NULL COMMENT 'Cost_additional_value',
  `cost_surcharge_value` varchar(255) NOT NULL COMMENT 'Cost_surcharge_value',
  `locations` text NOT NULL COMMENT 'Locations',
  `priority` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Priority',
  PRIMARY KEY (`id`),
  KEY `priority` (`priority`),
  KEY `template_shipping_id` (`template_shipping_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_shipping_service';


-- drakesterling_old.m2epro_ebay_template_synchronization definition

CREATE TABLE `m2epro_ebay_template_synchronization` (
  `template_synchronization_id` int(10) unsigned NOT NULL COMMENT 'Template_synchronization_id',
  `is_custom_template` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is_custom_template',
  `list_mode` smallint(5) unsigned NOT NULL COMMENT 'List_mode',
  `list_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'List_status_enabled',
  `list_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'List_is_in_stock',
  `list_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'List_qty_magento',
  `list_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value',
  `list_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value_max',
  `list_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'List_qty_calculated',
  `list_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value',
  `list_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value_max',
  `list_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'List_advanced_rules_mode',
  `list_advanced_rules_filters` text COMMENT 'List_advanced_rules_filters',
  `revise_update_qty` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty',
  `revise_update_qty_max_applied_value_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty_max_applied_value_mode',
  `revise_update_qty_max_applied_value` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_qty_max_applied_value',
  `revise_update_price` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price',
  `revise_update_price_max_allowed_deviation_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price_max_allowed_deviation_mode',
  `revise_update_price_max_allowed_deviation` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_price_max_allowed_deviation',
  `revise_update_title` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_title',
  `revise_update_sub_title` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_sub_title',
  `revise_update_description` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_description',
  `revise_update_images` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_images',
  `revise_update_specifics` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_specifics',
  `revise_update_shipping_services` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_shipping_services',
  `revise_change_category_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_category_template',
  `revise_change_payment_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_payment_template',
  `revise_change_return_policy_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_return_policy_template',
  `revise_change_shipping_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_shipping_template',
  `revise_change_description_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_description_template',
  `relist_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_mode',
  `relist_filter_user_lock` smallint(5) unsigned NOT NULL COMMENT 'Relist_filter_user_lock',
  `relist_send_data` smallint(5) unsigned NOT NULL COMMENT 'Relist_send_data',
  `relist_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'Relist_status_enabled',
  `relist_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'Relist_is_in_stock',
  `relist_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_magento',
  `relist_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value',
  `relist_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value_max',
  `relist_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_calculated',
  `relist_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value',
  `relist_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value_max',
  `relist_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_advanced_rules_mode',
  `relist_advanced_rules_filters` text COMMENT 'Relist_advanced_rules_filters',
  `stop_status_disabled` smallint(5) unsigned NOT NULL COMMENT 'Stop_status_disabled',
  `stop_out_off_stock` smallint(5) unsigned NOT NULL COMMENT 'Stop_out_off_stock',
  `stop_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_magento',
  `stop_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value',
  `stop_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value_max',
  `stop_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_calculated',
  `stop_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value',
  `stop_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value_max',
  `stop_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Stop_advanced_rules_mode',
  `stop_advanced_rules_filters` text COMMENT 'Stop_advanced_rules_filters',
  PRIMARY KEY (`template_synchronization_id`),
  KEY `is_custom_template` (`is_custom_template`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_ebay_template_synchronization';


-- drakesterling_old.m2epro_listing definition

CREATE TABLE `m2epro_listing` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `store_id` int(10) unsigned NOT NULL COMMENT 'Store_id',
  `products_total_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Products_total_count',
  `products_active_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Products_active_count',
  `products_inactive_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Products_inactive_count',
  `items_active_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Items_active_count',
  `source_products` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Source_products',
  `additional_data` longtext COMMENT 'Additional_data',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `auto_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Auto_mode',
  `auto_global_adding_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Auto_global_adding_mode',
  `auto_global_adding_add_not_visible` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Auto_global_adding_add_not_visible',
  `auto_website_adding_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Auto_website_adding_mode',
  `auto_website_adding_add_not_visible` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Auto_website_adding_add_not_visible',
  `auto_website_deleting_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Auto_website_deleting_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `title` (`title`),
  KEY `store_id` (`store_id`),
  KEY `component_mode` (`component_mode`),
  KEY `auto_mode` (`auto_mode`),
  KEY `auto_global_adding_mode` (`auto_global_adding_mode`),
  KEY `auto_website_adding_mode` (`auto_website_adding_mode`),
  KEY `auto_website_deleting_mode` (`auto_website_deleting_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_listing';


-- drakesterling_old.m2epro_listing_auto_category definition

CREATE TABLE `m2epro_listing_auto_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `group_id` int(10) unsigned NOT NULL COMMENT 'Group_id',
  `category_id` int(10) unsigned NOT NULL COMMENT 'Category_id',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `group_id` (`group_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_auto_category';


-- drakesterling_old.m2epro_listing_auto_category_group definition

CREATE TABLE `m2epro_listing_auto_category_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `adding_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Adding_mode',
  `adding_add_not_visible` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Adding_add_not_visible',
  `deleting_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Deleting_mode',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `listing_id` (`listing_id`),
  KEY `title` (`title`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_auto_category_group';


-- drakesterling_old.m2epro_listing_log definition

CREATE TABLE `m2epro_listing_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product_id',
  `listing_product_id` int(10) unsigned DEFAULT NULL COMMENT 'Listing_product_id',
  `parent_listing_product_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_listing_product_id',
  `listing_title` varchar(255) DEFAULT NULL COMMENT 'Listing_title',
  `product_title` varchar(255) DEFAULT NULL COMMENT 'Product_title',
  `action_id` int(10) unsigned NOT NULL COMMENT 'Action_id',
  `action` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Action',
  `initiator` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Initiator',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `priority` smallint(5) unsigned NOT NULL DEFAULT '3' COMMENT 'Priority',
  `description` text COMMENT 'Description',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `action` (`action`),
  KEY `action_id` (`action_id`),
  KEY `component_mode` (`component_mode`),
  KEY `initiator` (`initiator`),
  KEY `listing_id` (`listing_id`),
  KEY `listing_product_id` (`listing_product_id`),
  KEY `parent_listing_product_id` (`parent_listing_product_id`),
  KEY `listing_title` (`listing_title`),
  KEY `priority` (`priority`),
  KEY `product_id` (`product_id`),
  KEY `product_title` (`product_title`),
  KEY `type` (`type`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_log';


-- drakesterling_old.m2epro_listing_other definition

CREATE TABLE `m2epro_listing_other` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product_id',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  `status_changer` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status_changer',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `component_mode` (`component_mode`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `product_id` (`product_id`),
  KEY `status` (`status`),
  KEY `status_changer` (`status_changer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_other';


-- drakesterling_old.m2epro_listing_other_log definition

CREATE TABLE `m2epro_listing_other_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `listing_other_id` int(10) unsigned NOT NULL COMMENT 'Listing_other_id',
  `identifier` varchar(32) DEFAULT NULL COMMENT 'Identifier',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `action_id` int(10) unsigned NOT NULL COMMENT 'Action_id',
  `action` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Action',
  `initiator` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Initiator',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `priority` smallint(5) unsigned NOT NULL DEFAULT '3' COMMENT 'Priority',
  `description` text COMMENT 'Description',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `action` (`action`),
  KEY `action_id` (`action_id`),
  KEY `component_mode` (`component_mode`),
  KEY `initiator` (`initiator`),
  KEY `identifier` (`identifier`),
  KEY `listing_other_id` (`listing_other_id`),
  KEY `priority` (`priority`),
  KEY `title` (`title`),
  KEY `type` (`type`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_other_log';


-- drakesterling_old.m2epro_listing_product definition

CREATE TABLE `m2epro_listing_product` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  `status_changer` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status_changer',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `need_synch_rules_check` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Need_synch_rules_check',
  `tried_to_list` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Tried_to_list',
  `synch_status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Synch_status',
  `synch_reasons` text COMMENT 'Synch_reasons',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `listing_id` (`listing_id`),
  KEY `product_id` (`product_id`),
  KEY `status` (`status`),
  KEY `status_changer` (`status_changer`),
  KEY `tried_to_list` (`tried_to_list`),
  KEY `need_synch_rules_check` (`need_synch_rules_check`),
  KEY `synch_status` (`synch_status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_product';


-- drakesterling_old.m2epro_listing_product_variation definition

CREATE TABLE `m2epro_listing_product_variation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `listing_product_id` (`listing_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_product_variation';


-- drakesterling_old.m2epro_listing_product_variation_option definition

CREATE TABLE `m2epro_listing_product_variation_option` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `listing_product_variation_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_id',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product_id',
  `product_type` varchar(255) NOT NULL COMMENT 'Product_type',
  `attribute` varchar(255) NOT NULL COMMENT 'Attribute',
  `option` varchar(255) NOT NULL COMMENT 'Option',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `attribute` (`attribute`),
  KEY `component_mode` (`component_mode`),
  KEY `listing_product_variation_id` (`listing_product_variation_id`),
  KEY `option` (`option`),
  KEY `product_id` (`product_id`),
  KEY `product_type` (`product_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_listing_product_variation_option';


-- drakesterling_old.m2epro_lock_item definition

CREATE TABLE `m2epro_lock_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `nick` varchar(255) NOT NULL COMMENT 'Nick',
  `parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_id',
  `data` text COMMENT 'Data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `nick` (`nick`),
  KEY `parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_lock_item';


-- drakesterling_old.m2epro_lock_transactional definition

CREATE TABLE `m2epro_lock_transactional` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `nick` varchar(255) NOT NULL COMMENT 'Nick',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `nick` (`nick`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='m2epro_lock_transactional';


-- drakesterling_old.m2epro_marketplace definition

CREATE TABLE `m2epro_marketplace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `native_id` int(10) unsigned NOT NULL COMMENT 'Native_id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `url` varchar(255) NOT NULL COMMENT 'Url',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  `sorder` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sorder',
  `group_title` varchar(255) NOT NULL COMMENT 'Group_title',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COMMENT='m2epro_marketplace';


-- drakesterling_old.m2epro_module_config definition

CREATE TABLE `m2epro_module_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `group` varchar(255) DEFAULT NULL COMMENT 'Group',
  `key` varchar(255) NOT NULL COMMENT 'Key',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  `notice` text COMMENT 'Notice',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  KEY `key` (`key`),
  KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=182 DEFAULT CHARSET=utf8 COMMENT='m2epro_module_config';


-- drakesterling_old.m2epro_operation_history definition

CREATE TABLE `m2epro_operation_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `nick` varchar(255) NOT NULL COMMENT 'Nick',
  `parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_id',
  `initiator` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Initiator',
  `start_date` datetime NOT NULL COMMENT 'Start_date',
  `end_date` datetime DEFAULT NULL COMMENT 'End_date',
  `data` text COMMENT 'Data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `nick` (`nick`),
  KEY `parent_id` (`parent_id`),
  KEY `initiator` (`initiator`),
  KEY `start_date` (`start_date`),
  KEY `end_date` (`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=1175930 DEFAULT CHARSET=utf8 COMMENT='m2epro_operation_history';


-- drakesterling_old.m2epro_order definition

CREATE TABLE `m2epro_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned DEFAULT NULL COMMENT 'Marketplace_id',
  `magento_order_id` int(10) unsigned DEFAULT NULL COMMENT 'Magento_order_id',
  `magento_order_creation_failure` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Magento_order_creation_failure',
  `magento_order_creation_fails_count` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Magento_order_creation_fails_count',
  `magento_order_creation_latest_attempt_date` datetime DEFAULT NULL COMMENT 'Magento_order_creation_latest_attempt_date',
  `store_id` int(10) unsigned DEFAULT NULL COMMENT 'Store_id',
  `reservation_state` smallint(5) unsigned DEFAULT '0' COMMENT 'Reservation_state',
  `reservation_start_date` datetime DEFAULT NULL COMMENT 'Reservation_start_date',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` text COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `component_mode` (`component_mode`),
  KEY `magento_order_id` (`magento_order_id`),
  KEY `magento_order_creation_failure` (`magento_order_creation_failure`),
  KEY `magento_order_creation_fails_count` (`magento_order_creation_fails_count`),
  KEY `magento_order_creation_latest_attempt_date` (`magento_order_creation_latest_attempt_date`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `reservation_state` (`reservation_state`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='m2epro_order';


-- drakesterling_old.m2epro_order_change definition

CREATE TABLE `m2epro_order_change` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `component` varchar(10) NOT NULL COMMENT 'Component',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `action` varchar(50) NOT NULL COMMENT 'Action',
  `params` longtext NOT NULL COMMENT 'Params',
  `creator_type` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Creator_type',
  `processing_attempt_count` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Processing_attempt_count',
  `processing_attempt_date` datetime DEFAULT NULL COMMENT 'Processing_attempt_date',
  `hash` varchar(50) DEFAULT NULL COMMENT 'Hash',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `action` (`action`),
  KEY `creator_type` (`creator_type`),
  KEY `hash` (`hash`),
  KEY `order_id` (`order_id`),
  KEY `processing_attempt_count` (`processing_attempt_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_order_change';


-- drakesterling_old.m2epro_order_item definition

CREATE TABLE `m2epro_order_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product_id',
  `product_details` text COMMENT 'Product_details',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `qty_reserved` int(10) unsigned DEFAULT '0' COMMENT 'Qty_reserved',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `order_id` (`order_id`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='m2epro_order_item';


-- drakesterling_old.m2epro_order_log definition

CREATE TABLE `m2epro_order_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `type` smallint(5) unsigned NOT NULL DEFAULT '2' COMMENT 'Type',
  `initiator` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Initiator',
  `description` text COMMENT 'Description',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `component_mode` (`component_mode`),
  KEY `initiator` (`initiator`),
  KEY `order_id` (`order_id`),
  KEY `type` (`type`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB AUTO_INCREMENT=9577 DEFAULT CHARSET=utf8 COMMENT='m2epro_order_log';


-- drakesterling_old.m2epro_order_matching definition

CREATE TABLE `m2epro_order_matching` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `input_variation_options` text COMMENT 'Input_variation_options',
  `output_variation_options` text COMMENT 'Output_variation_options',
  `hash` varchar(50) DEFAULT NULL COMMENT 'Hash',
  `component` varchar(10) NOT NULL COMMENT 'Component',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component` (`component`),
  KEY `hash` (`hash`),
  KEY `product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_order_matching';


-- drakesterling_old.m2epro_primary_config definition

CREATE TABLE `m2epro_primary_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `group` varchar(255) DEFAULT NULL COMMENT 'Group',
  `key` varchar(255) NOT NULL COMMENT 'Key',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  `notice` text COMMENT 'Notice',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  KEY `key` (`key`),
  KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COMMENT='m2epro_primary_config';


-- drakesterling_old.m2epro_processing definition

CREATE TABLE `m2epro_processing` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `model` varchar(255) NOT NULL COMMENT 'Model',
  `params` longtext COMMENT 'Params',
  `result_data` longtext COMMENT 'Result_data',
  `result_messages` longtext COMMENT 'Result_messages',
  `is_completed` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is_completed',
  `expiration_date` datetime NOT NULL COMMENT 'Expiration_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `model` (`model`),
  KEY `is_completed` (`is_completed`),
  KEY `expiration_date` (`expiration_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_processing';


-- drakesterling_old.m2epro_processing_lock definition

CREATE TABLE `m2epro_processing_lock` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `model_name` varchar(255) NOT NULL COMMENT 'Model_name',
  `object_id` int(10) unsigned NOT NULL COMMENT 'Object_id',
  `tag` varchar(255) DEFAULT NULL COMMENT 'Tag',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `processing_id` (`processing_id`),
  KEY `model_name` (`model_name`),
  KEY `object_id` (`object_id`),
  KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_processing_lock';


-- drakesterling_old.m2epro_product_change definition

CREATE TABLE `m2epro_product_change` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `store_id` int(10) unsigned DEFAULT NULL COMMENT 'Store_id',
  `action` varchar(255) NOT NULL COMMENT 'Action',
  `attribute` varchar(255) DEFAULT NULL COMMENT 'Attribute',
  `value_old` longtext COMMENT 'Value_old',
  `value_new` longtext COMMENT 'Value_new',
  `initiators` varchar(16) NOT NULL COMMENT 'Initiators',
  `count_changes` int(10) unsigned DEFAULT NULL COMMENT 'Count_changes',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `action` (`action`),
  KEY `attribute` (`attribute`),
  KEY `initiators` (`initiators`),
  KEY `product_id` (`product_id`),
  KEY `store_id` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_product_change';


-- drakesterling_old.m2epro_registry definition

CREATE TABLE `m2epro_registry` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `key` varchar(255) NOT NULL COMMENT 'Key',
  `value` longtext COMMENT 'Value',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='m2epro_registry';


-- drakesterling_old.m2epro_request_pending_partial definition

CREATE TABLE `m2epro_request_pending_partial` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `component` varchar(12) NOT NULL COMMENT 'Component',
  `server_hash` varchar(255) NOT NULL COMMENT 'Server_hash',
  `next_part` int(10) unsigned DEFAULT NULL COMMENT 'Next_part',
  `result_messages` longtext COMMENT 'Result_messages',
  `expiration_date` datetime NOT NULL COMMENT 'Expiration_date',
  `is_completed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_completed',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component` (`component`),
  KEY `server_hash` (`server_hash`),
  KEY `next_part` (`next_part`),
  KEY `is_completed` (`is_completed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_request_pending_partial';


-- drakesterling_old.m2epro_request_pending_partial_data definition

CREATE TABLE `m2epro_request_pending_partial_data` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `request_pending_partial_id` int(10) unsigned NOT NULL COMMENT 'Request_pending_partial_id',
  `part_number` int(10) unsigned NOT NULL COMMENT 'Part_number',
  `data` longtext COMMENT 'Data',
  PRIMARY KEY (`id`),
  KEY `part_number` (`part_number`),
  KEY `request_pending_partial_id` (`request_pending_partial_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_request_pending_partial_data';


-- drakesterling_old.m2epro_request_pending_single definition

CREATE TABLE `m2epro_request_pending_single` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `component` varchar(12) NOT NULL COMMENT 'Component',
  `server_hash` varchar(255) NOT NULL COMMENT 'Server_hash',
  `result_data` longtext COMMENT 'Result_data',
  `result_messages` longtext COMMENT 'Result_messages',
  `expiration_date` datetime NOT NULL COMMENT 'Expiration_date',
  `is_completed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_completed',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component` (`component`),
  KEY `server_hash` (`server_hash`),
  KEY `is_completed` (`is_completed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_request_pending_single';


-- drakesterling_old.m2epro_setup definition

CREATE TABLE `m2epro_setup` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `version_from` varchar(32) DEFAULT NULL COMMENT 'Version_from',
  `version_to` varchar(32) NOT NULL COMMENT 'Version_to',
  `is_backuped` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_backuped',
  `is_completed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_completed',
  `profiler_data` text COMMENT 'Profiler_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `version_from` (`version_from`),
  KEY `version_to` (`version_to`),
  KEY `is_backuped` (`is_backuped`),
  KEY `is_completed` (`is_completed`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_setup';


-- drakesterling_old.m2epro_stop_queue definition

CREATE TABLE `m2epro_stop_queue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `item_data` text NOT NULL COMMENT 'Item_data',
  `account_hash` varchar(255) NOT NULL COMMENT 'Account_hash',
  `marketplace_id` int(10) unsigned DEFAULT NULL COMMENT 'Marketplace_id',
  `component_mode` varchar(255) NOT NULL COMMENT 'Component_mode',
  `is_processed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_processed',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_hash` (`account_hash`),
  KEY `component_mode` (`component_mode`),
  KEY `is_processed` (`is_processed`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_stop_queue';


-- drakesterling_old.m2epro_synchronization_config definition

CREATE TABLE `m2epro_synchronization_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `group` varchar(255) DEFAULT NULL COMMENT 'Group',
  `key` varchar(255) NOT NULL COMMENT 'Key',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  `notice` text COMMENT 'Notice',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `group` (`group`),
  KEY `key` (`key`),
  KEY `value` (`value`)
) ENGINE=InnoDB AUTO_INCREMENT=175 DEFAULT CHARSET=utf8 COMMENT='m2epro_synchronization_config';


-- drakesterling_old.m2epro_synchronization_log definition

CREATE TABLE `m2epro_synchronization_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `operation_history_id` int(10) unsigned DEFAULT NULL COMMENT 'Operation_history_id',
  `task` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Task',
  `initiator` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Initiator',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `priority` smallint(5) unsigned NOT NULL DEFAULT '3' COMMENT 'Priority',
  `description` text COMMENT 'Description',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `initiator` (`initiator`),
  KEY `priority` (`priority`),
  KEY `task` (`task`),
  KEY `operation_history_id` (`operation_history_id`),
  KEY `type` (`type`),
  KEY `create_date` (`create_date`)
) ENGINE=InnoDB AUTO_INCREMENT=60019 DEFAULT CHARSET=utf8 COMMENT='m2epro_synchronization_log';


-- drakesterling_old.m2epro_system_log definition

CREATE TABLE `m2epro_system_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `type` varchar(255) DEFAULT NULL COMMENT 'Type',
  `description` longtext COMMENT 'Description',
  `additional_data` longtext COMMENT 'Additional_data',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_system_log';


-- drakesterling_old.m2epro_template_description definition

CREATE TABLE `m2epro_template_description` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_template_description';


-- drakesterling_old.m2epro_template_selling_format definition

CREATE TABLE `m2epro_template_selling_format` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_template_selling_format';


-- drakesterling_old.m2epro_template_synchronization definition

CREATE TABLE `m2epro_template_synchronization` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `revise_change_listing` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_listing',
  `revise_change_selling_format_template` smallint(5) unsigned NOT NULL COMMENT 'Revise_change_selling_format_template',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `component_mode` (`component_mode`),
  KEY `revise_change_listing` (`revise_change_listing`),
  KEY `revise_change_selling_format_template` (`revise_change_selling_format_template`),
  KEY `title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_template_synchronization';


-- drakesterling_old.m2epro_versions_history definition

CREATE TABLE `m2epro_versions_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `version_from` varchar(32) DEFAULT NULL COMMENT 'Version_from',
  `version_to` varchar(32) NOT NULL COMMENT 'Version_to',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='m2epro_versions_history';


-- drakesterling_old.m2epro_walmart_account definition

CREATE TABLE `m2epro_walmart_account` (
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `server_hash` varchar(255) NOT NULL COMMENT 'Server_hash',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `consumer_id` varchar(255) NOT NULL COMMENT 'Consumer_id',
  `old_private_key` text COMMENT 'Old_private_key',
  `client_id` varchar(255) DEFAULT NULL COMMENT 'Client_id',
  `client_secret` text COMMENT 'Client_secret',
  `related_store_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Related_store_id',
  `other_listings_synchronization` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Other_listings_synchronization',
  `other_listings_mapping_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'null',
  `other_listings_mapping_settings` text COMMENT 'Other_listings_mapping_settings',
  `magento_orders_settings` text NOT NULL COMMENT 'Magento_orders_settings',
  `orders_last_synchronization` datetime DEFAULT NULL COMMENT 'Orders_last_synchronization',
  `info` text COMMENT 'Info',
  PRIMARY KEY (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_account';


-- drakesterling_old.m2epro_walmart_dictionary_category definition

CREATE TABLE `m2epro_walmart_dictionary_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `category_id` int(10) unsigned NOT NULL COMMENT 'Category_id',
  `parent_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_category_id',
  `browsenode_id` decimal(20,0) unsigned NOT NULL COMMENT 'Browsenode_id',
  `product_data_nicks` text COMMENT 'Product_data_nicks',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `path` text COMMENT 'Path',
  `keywords` text COMMENT 'Keywords',
  `is_leaf` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_leaf',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `category_id` (`category_id`),
  KEY `browsenode_id` (`browsenode_id`),
  KEY `parent_category_id` (`parent_category_id`),
  KEY `product_data_nicks` (`product_data_nicks`(333)),
  KEY `title` (`title`),
  KEY `path` (`path`(333)),
  KEY `is_leaf` (`is_leaf`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_dictionary_category';


-- drakesterling_old.m2epro_walmart_dictionary_marketplace definition

CREATE TABLE `m2epro_walmart_dictionary_marketplace` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `client_details_last_update_date` datetime DEFAULT NULL COMMENT 'Client_details_last_update_date',
  `server_details_last_update_date` datetime DEFAULT NULL COMMENT 'Server_details_last_update_date',
  `product_data` longtext COMMENT 'Product_data',
  `tax_codes` longtext COMMENT 'Tax_codes',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_dictionary_marketplace';


-- drakesterling_old.m2epro_walmart_dictionary_specific definition

CREATE TABLE `m2epro_walmart_dictionary_specific` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `specific_id` int(10) unsigned NOT NULL COMMENT 'Specific_id',
  `parent_specific_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent_specific_id',
  `product_data_nick` varchar(255) NOT NULL COMMENT 'Product_data_nick',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `xml_tag` varchar(255) NOT NULL COMMENT 'Xml_tag',
  `xpath` varchar(255) NOT NULL COMMENT 'Xpath',
  `type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Type',
  `values` text COMMENT 'Values',
  `recommended_values` text COMMENT 'Recommended_values',
  `params` text COMMENT 'Params',
  `data_definition` text COMMENT 'Data_definition',
  `min_occurs` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Min_occurs',
  `max_occurs` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Max_occurs',
  PRIMARY KEY (`id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `specific_id` (`specific_id`),
  KEY `parent_specific_id` (`parent_specific_id`),
  KEY `product_data_nick` (`product_data_nick`),
  KEY `title` (`title`),
  KEY `xml_tag` (`xml_tag`),
  KEY `xpath` (`xpath`),
  KEY `type` (`type`),
  KEY `min_occurs` (`min_occurs`),
  KEY `max_occurs` (`max_occurs`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_dictionary_specific';


-- drakesterling_old.m2epro_walmart_indexer_listing_product_variation_parent definition

CREATE TABLE `m2epro_walmart_indexer_listing_product_variation_parent` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `component_mode` varchar(10) DEFAULT NULL COMMENT 'Component_mode',
  `min_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Min_price',
  `max_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Max_price',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`listing_product_id`),
  KEY `listing_id` (`listing_id`),
  KEY `component_mode` (`component_mode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_indexer_listing_product_variation_parent';


-- drakesterling_old.m2epro_walmart_item definition

CREATE TABLE `m2epro_walmart_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product_id',
  `store_id` int(10) unsigned NOT NULL COMMENT 'Store_id',
  `variation_product_options` text COMMENT 'Variation_product_options',
  `variation_channel_options` text COMMENT 'Variation_channel_options',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `marketplace_id` (`marketplace_id`),
  KEY `sku` (`sku`),
  KEY `product_id` (`product_id`),
  KEY `store_id` (`store_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_item';


-- drakesterling_old.m2epro_walmart_listing definition

CREATE TABLE `m2epro_walmart_listing` (
  `listing_id` int(10) unsigned NOT NULL COMMENT 'Listing_id',
  `auto_global_adding_category_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_global_adding_category_template_id',
  `auto_website_adding_category_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Auto_website_adding_category_template_id',
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `template_synchronization_id` int(10) unsigned NOT NULL COMMENT 'Template_synchronization_id',
  PRIMARY KEY (`listing_id`),
  KEY `auto_global_adding_category_template_id` (`auto_global_adding_category_template_id`),
  KEY `auto_website_adding_category_template_id` (`auto_website_adding_category_template_id`),
  KEY `template_description_id` (`template_description_id`),
  KEY `template_selling_format_id` (`template_selling_format_id`),
  KEY `template_synchronization_id` (`template_synchronization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing';


-- drakesterling_old.m2epro_walmart_listing_auto_category_group definition

CREATE TABLE `m2epro_walmart_listing_auto_category_group` (
  `listing_auto_category_group_id` int(10) unsigned NOT NULL COMMENT 'Listing_auto_category_group_id',
  `adding_category_template_id` int(10) unsigned DEFAULT NULL COMMENT 'Adding_category_template_id',
  PRIMARY KEY (`listing_auto_category_group_id`),
  KEY `adding_category_template_id` (`adding_category_template_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing_auto_category_group';


-- drakesterling_old.m2epro_walmart_listing_other definition

CREATE TABLE `m2epro_walmart_listing_other` (
  `listing_other_id` int(10) unsigned NOT NULL COMMENT 'Listing_other_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `gtin` varchar(255) DEFAULT NULL COMMENT 'Gtin',
  `upc` varchar(255) DEFAULT NULL COMMENT 'Upc',
  `ean` varchar(255) DEFAULT NULL COMMENT 'Ean',
  `wpid` varchar(255) DEFAULT NULL COMMENT 'Wpid',
  `item_id` varchar(255) DEFAULT NULL COMMENT 'Item_id',
  `channel_url` varchar(255) DEFAULT NULL COMMENT 'Channel_url',
  `publish_status` varchar(255) DEFAULT NULL COMMENT 'Publish_status',
  `lifecycle_status` varchar(255) DEFAULT NULL COMMENT 'Lifecycle_status',
  `status_change_reasons` text COMMENT 'Status_change_reasons',
  `is_online_price_invalid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_online_price_invalid',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `online_price` decimal(12,4) unsigned NOT NULL DEFAULT '0.0000' COMMENT 'Online_price',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  PRIMARY KEY (`listing_other_id`),
  KEY `sku` (`sku`),
  KEY `gtin` (`gtin`),
  KEY `upc` (`upc`),
  KEY `ean` (`ean`),
  KEY `wpid` (`wpid`),
  KEY `item_id` (`item_id`),
  KEY `title` (`title`),
  KEY `online_price` (`online_price`),
  KEY `online_qty` (`online_qty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing_other';


-- drakesterling_old.m2epro_walmart_listing_product definition

CREATE TABLE `m2epro_walmart_listing_product` (
  `listing_product_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_id',
  `template_category_id` int(10) unsigned DEFAULT NULL COMMENT 'Template_category_id',
  `is_variation_product` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_product',
  `is_variation_product_matched` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_product_matched',
  `is_variation_channel_matched` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_channel_matched',
  `is_variation_parent` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_variation_parent',
  `variation_parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Variation_parent_id',
  `variation_parent_need_processor` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Variation_parent_need_processor',
  `variation_child_statuses` text COMMENT 'Variation_child_statuses',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `gtin` varchar(255) DEFAULT NULL COMMENT 'Gtin',
  `upc` varchar(255) DEFAULT NULL COMMENT 'Upc',
  `ean` varchar(255) DEFAULT NULL COMMENT 'Ean',
  `isbn` varchar(255) DEFAULT NULL COMMENT 'Isbn',
  `wpid` varchar(255) DEFAULT NULL COMMENT 'Wpid',
  `item_id` varchar(255) DEFAULT NULL COMMENT 'Item_id',
  `channel_url` varchar(255) DEFAULT NULL COMMENT 'Channel_url',
  `publish_status` varchar(255) DEFAULT NULL COMMENT 'Publish_status',
  `lifecycle_status` varchar(255) DEFAULT NULL COMMENT 'Lifecycle_status',
  `status_change_reasons` text COMMENT 'Status_change_reasons',
  `online_price` decimal(12,4) unsigned DEFAULT NULL COMMENT 'Online_price',
  `is_online_price_invalid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_online_price_invalid',
  `online_promotions` text COMMENT 'Online_promotions',
  `online_qty` int(10) unsigned DEFAULT NULL COMMENT 'Online_qty',
  `online_lag_time` int(10) unsigned DEFAULT NULL COMMENT 'Online_lag_time',
  `online_details_data` text COMMENT 'Online_details_data',
  `is_details_data_changed` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_details_data_changed',
  `online_start_date` datetime DEFAULT NULL COMMENT 'Online_start_date',
  `online_end_date` datetime DEFAULT NULL COMMENT 'Online_end_date',
  `is_missed_on_channel` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_missed_on_channel',
  `list_date` datetime DEFAULT NULL COMMENT 'List_date',
  PRIMARY KEY (`listing_product_id`),
  KEY `template_category_id` (`template_category_id`),
  KEY `is_variation_product` (`is_variation_product`),
  KEY `is_variation_product_matched` (`is_variation_product_matched`),
  KEY `is_variation_channel_matched` (`is_variation_channel_matched`),
  KEY `is_variation_parent` (`is_variation_parent`),
  KEY `variation_parent_id` (`variation_parent_id`),
  KEY `variation_parent_need_processor` (`variation_parent_need_processor`),
  KEY `sku` (`sku`),
  KEY `gtin` (`gtin`),
  KEY `upc` (`upc`),
  KEY `ean` (`ean`),
  KEY `isbn` (`isbn`),
  KEY `wpid` (`wpid`),
  KEY `item_id` (`item_id`),
  KEY `online_price` (`online_price`),
  KEY `online_qty` (`online_qty`),
  KEY `online_start_date` (`online_start_date`),
  KEY `online_end_date` (`online_end_date`),
  KEY `list_date` (`list_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing_product';


-- drakesterling_old.m2epro_walmart_listing_product_variation definition

CREATE TABLE `m2epro_walmart_listing_product_variation` (
  `listing_product_variation_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_id',
  PRIMARY KEY (`listing_product_variation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing_product_variation';


-- drakesterling_old.m2epro_walmart_listing_product_variation_option definition

CREATE TABLE `m2epro_walmart_listing_product_variation_option` (
  `listing_product_variation_option_id` int(10) unsigned NOT NULL COMMENT 'Listing_product_variation_option_id',
  PRIMARY KEY (`listing_product_variation_option_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_listing_product_variation_option';


-- drakesterling_old.m2epro_walmart_marketplace definition

CREATE TABLE `m2epro_walmart_marketplace` (
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `developer_key` varchar(255) DEFAULT NULL COMMENT 'Developer_key',
  `default_currency` varchar(255) NOT NULL COMMENT 'Default_currency',
  PRIMARY KEY (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_marketplace';


-- drakesterling_old.m2epro_walmart_order definition

CREATE TABLE `m2epro_walmart_order` (
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order_id',
  `walmart_order_id` varchar(255) NOT NULL COMMENT 'Walmart_order_id',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status',
  `buyer_name` varchar(255) NOT NULL COMMENT 'Buyer_name',
  `buyer_email` varchar(255) DEFAULT NULL COMMENT 'Buyer_email',
  `shipping_service` varchar(255) DEFAULT NULL COMMENT 'Shipping_service',
  `shipping_address` text NOT NULL COMMENT 'Shipping_address',
  `shipping_price` decimal(12,4) unsigned NOT NULL COMMENT 'Shipping_price',
  `paid_amount` decimal(12,4) unsigned NOT NULL COMMENT 'Paid_amount',
  `tax_details` text COMMENT 'Tax_details',
  `currency` varchar(10) NOT NULL COMMENT 'Currency',
  `is_tried_to_acknowledge` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is_tried_to_acknowledge',
  `purchase_update_date` datetime DEFAULT NULL COMMENT 'Purchase_update_date',
  `purchase_create_date` datetime DEFAULT NULL COMMENT 'Purchase_create_date',
  PRIMARY KEY (`order_id`),
  KEY `walmart_order_id` (`walmart_order_id`),
  KEY `buyer_name` (`buyer_name`),
  KEY `buyer_email` (`buyer_email`),
  KEY `paid_amount` (`paid_amount`),
  KEY `is_tried_to_acknowledge` (`is_tried_to_acknowledge`),
  KEY `purchase_create_date` (`purchase_create_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_order';


-- drakesterling_old.m2epro_walmart_order_item definition

CREATE TABLE `m2epro_walmart_order_item` (
  `order_item_id` int(10) unsigned NOT NULL COMMENT 'Order_item_id',
  `walmart_order_item_id` varchar(255) NOT NULL COMMENT 'Walmart_order_item_id',
  `merged_walmart_order_item_ids` text COMMENT 'Merged_walmart_order_item_ids',
  `status` varchar(30) NOT NULL COMMENT 'Status',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `price` decimal(12,4) unsigned NOT NULL COMMENT 'Price',
  `qty` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Qty',
  PRIMARY KEY (`order_item_id`),
  KEY `title` (`title`),
  KEY `sku` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_order_item';


-- drakesterling_old.m2epro_walmart_processing_action definition

CREATE TABLE `m2epro_walmart_processing_action` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `processing_id` int(10) unsigned NOT NULL COMMENT 'Processing_id',
  `request_pending_single_id` int(10) unsigned DEFAULT NULL COMMENT 'Request_pending_single_id',
  `related_id` int(10) unsigned DEFAULT NULL COMMENT 'Related_id',
  `type` varchar(12) NOT NULL COMMENT 'Type',
  `request_data` longtext NOT NULL COMMENT 'Request_data',
  `start_date` datetime DEFAULT NULL COMMENT 'Start_date',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `account_id` (`account_id`),
  KEY `processing_id` (`processing_id`),
  KEY `request_pending_single_id` (`request_pending_single_id`),
  KEY `related_id` (`related_id`),
  KEY `type` (`type`),
  KEY `start_date` (`start_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_processing_action';


-- drakesterling_old.m2epro_walmart_processing_action_list_sku definition

CREATE TABLE `m2epro_walmart_processing_action_list_sku` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `account_id` int(10) unsigned NOT NULL COMMENT 'Account_id',
  `sku` varchar(255) NOT NULL COMMENT 'Sku',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_id__sku` (`account_id`,`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_processing_action_list_sku';


-- drakesterling_old.m2epro_walmart_template_category definition

CREATE TABLE `m2epro_walmart_template_category` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `product_data_nick` varchar(255) DEFAULT NULL COMMENT 'Product_data_nick',
  `category_path` varchar(255) DEFAULT NULL COMMENT 'Category_path',
  `browsenode_id` decimal(20,0) unsigned DEFAULT NULL COMMENT 'Browsenode_id',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `title` (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_category';


-- drakesterling_old.m2epro_walmart_template_category_specific definition

CREATE TABLE `m2epro_walmart_template_category_specific` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_category_id` int(10) unsigned NOT NULL COMMENT 'Template_category_id',
  `xpath` varchar(255) NOT NULL COMMENT 'Xpath',
  `mode` varchar(25) NOT NULL COMMENT 'Mode',
  `is_required` smallint(5) unsigned DEFAULT '0' COMMENT 'Is_required',
  `custom_value` varchar(255) DEFAULT NULL COMMENT 'Custom_value',
  `custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Custom_attribute',
  `type` varchar(25) DEFAULT NULL COMMENT 'Type',
  `attributes` text COMMENT 'Attributes',
  `update_date` datetime DEFAULT NULL COMMENT 'Update_date',
  `create_date` datetime DEFAULT NULL COMMENT 'Create_date',
  PRIMARY KEY (`id`),
  KEY `template_category_id` (`template_category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_category_specific';


-- drakesterling_old.m2epro_walmart_template_description definition

CREATE TABLE `m2epro_walmart_template_description` (
  `template_description_id` int(10) unsigned NOT NULL COMMENT 'Template_description_id',
  `title_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Title_mode',
  `title_template` varchar(255) NOT NULL COMMENT 'Title_template',
  `brand_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Brand_mode',
  `brand_custom_value` varchar(255) DEFAULT NULL COMMENT 'Brand_custom_value',
  `brand_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Brand_custom_attribute',
  `manufacturer_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Manufacturer_mode',
  `manufacturer_custom_value` varchar(255) DEFAULT NULL COMMENT 'Manufacturer_custom_value',
  `manufacturer_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Manufacturer_custom_attribute',
  `manufacturer_part_number_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Manufacturer_part_number_mode',
  `manufacturer_part_number_custom_value` varchar(255) NOT NULL COMMENT 'Manufacturer_part_number_custom_value',
  `manufacturer_part_number_custom_attribute` varchar(255) NOT NULL COMMENT 'Manufacturer_part_number_custom_attribute',
  `model_number_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Model_number_mode',
  `model_number_custom_value` varchar(255) NOT NULL COMMENT 'Model_number_custom_value',
  `model_number_custom_attribute` varchar(255) NOT NULL COMMENT 'Model_number_custom_attribute',
  `msrp_rrp_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Msrp_rrp_mode',
  `msrp_rrp_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Msrp_rrp_custom_attribute',
  `image_main_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_main_mode',
  `image_main_attribute` varchar(255) NOT NULL COMMENT 'Image_main_attribute',
  `image_variation_difference_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Image_variation_difference_mode',
  `image_variation_difference_attribute` varchar(255) NOT NULL COMMENT 'Image_variation_difference_attribute',
  `gallery_images_mode` smallint(5) unsigned NOT NULL COMMENT 'Gallery_images_mode',
  `gallery_images_limit` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Gallery_images_limit',
  `gallery_images_attribute` varchar(255) NOT NULL COMMENT 'Gallery_images_attribute',
  `description_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Description_mode',
  `description_template` text NOT NULL COMMENT 'Description_template',
  `multipack_quantity_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Multipack_quantity_mode',
  `multipack_quantity_custom_value` varchar(255) DEFAULT NULL COMMENT 'Multipack_quantity_custom_value',
  `multipack_quantity_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Multipack_quantity_custom_attribute',
  `count_per_pack_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Count_per_pack_mode',
  `count_per_pack_custom_value` varchar(255) DEFAULT NULL COMMENT 'Count_per_pack_custom_value',
  `count_per_pack_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Count_per_pack_custom_attribute',
  `total_count_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Total_count_mode',
  `total_count_custom_value` varchar(255) DEFAULT NULL COMMENT 'Total_count_custom_value',
  `total_count_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Total_count_custom_attribute',
  `key_features_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Key_features_mode',
  `key_features` text NOT NULL COMMENT 'Key_features',
  `other_features_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Other_features_mode',
  `other_features` text NOT NULL COMMENT 'Other_features',
  `keywords_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Keywords_mode',
  `keywords_custom_value` varchar(255) DEFAULT NULL COMMENT 'Keywords_custom_value',
  `keywords_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Keywords_custom_attribute',
  `attributes_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attributes_mode',
  `attributes` text NOT NULL COMMENT 'Attributes',
  PRIMARY KEY (`template_description_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_description';


-- drakesterling_old.m2epro_walmart_template_selling_format definition

CREATE TABLE `m2epro_walmart_template_selling_format` (
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `marketplace_id` int(10) unsigned NOT NULL COMMENT 'Marketplace_id',
  `qty_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_mode',
  `qty_custom_value` int(10) unsigned NOT NULL COMMENT 'Qty_custom_value',
  `qty_custom_attribute` varchar(255) NOT NULL COMMENT 'Qty_custom_attribute',
  `qty_percentage` int(10) unsigned NOT NULL DEFAULT '100' COMMENT 'Qty_percentage',
  `qty_modification_mode` smallint(5) unsigned NOT NULL COMMENT 'Qty_modification_mode',
  `qty_min_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_min_posted_value',
  `qty_max_posted_value` int(10) unsigned DEFAULT NULL COMMENT 'Qty_max_posted_value',
  `price_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_mode',
  `price_custom_attribute` varchar(255) NOT NULL COMMENT 'Price_custom_attribute',
  `map_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Map_price_mode',
  `map_price_custom_attribute` varchar(255) NOT NULL COMMENT 'Map_price_custom_attribute',
  `price_coefficient` varchar(255) NOT NULL COMMENT 'Price_coefficient',
  `price_variation_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_variation_mode',
  `price_vat_percent` float(10,0) unsigned DEFAULT NULL COMMENT 'Price_vat_percent',
  `promotions_mode` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Promotions_mode',
  `lag_time_mode` smallint(5) unsigned NOT NULL COMMENT 'Lag_time_mode',
  `lag_time_value` int(10) unsigned NOT NULL COMMENT 'Lag_time_value',
  `lag_time_custom_attribute` varchar(255) NOT NULL COMMENT 'Lag_time_custom_attribute',
  `product_tax_code_mode` smallint(5) unsigned NOT NULL COMMENT 'Product_tax_code_mode',
  `product_tax_code_custom_value` varchar(255) NOT NULL COMMENT 'Product_tax_code_custom_value',
  `product_tax_code_custom_attribute` varchar(255) NOT NULL COMMENT 'Product_tax_code_custom_attribute',
  `item_weight_mode` smallint(5) unsigned DEFAULT '0' COMMENT 'Item_weight_mode',
  `item_weight_custom_value` decimal(10,2) unsigned DEFAULT NULL COMMENT 'Item_weight_custom_value',
  `item_weight_custom_attribute` varchar(255) DEFAULT NULL COMMENT 'Item_weight_custom_attribute',
  `must_ship_alone_mode` smallint(5) unsigned NOT NULL COMMENT 'Must_ship_alone_mode',
  `must_ship_alone_value` smallint(5) unsigned NOT NULL COMMENT 'Must_ship_alone_value',
  `must_ship_alone_custom_attribute` varchar(255) NOT NULL COMMENT 'Must_ship_alone_custom_attribute',
  `ships_in_original_packaging_mode` smallint(5) unsigned NOT NULL COMMENT 'Ships_in_original_packaging_mode',
  `ships_in_original_packaging_value` smallint(5) unsigned NOT NULL COMMENT 'Ships_in_original_packaging_value',
  `ships_in_original_packaging_custom_attribute` varchar(255) NOT NULL COMMENT 'Ships_in_original_packaging_custom_attribute',
  `shipping_override_rule_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Shipping_override_rule_mode',
  `sale_time_start_date_mode` smallint(5) unsigned NOT NULL COMMENT 'Sale_time_start_date_mode',
  `sale_time_start_date_value` datetime NOT NULL COMMENT 'Sale_time_start_date_value',
  `sale_time_start_date_custom_attribute` varchar(255) NOT NULL COMMENT 'Sale_time_start_date_custom_attribute',
  `sale_time_end_date_mode` smallint(5) unsigned NOT NULL COMMENT 'Sale_time_end_date_mode',
  `sale_time_end_date_value` datetime NOT NULL COMMENT 'Sale_time_end_date_value',
  `sale_time_end_date_custom_attribute` varchar(255) NOT NULL COMMENT 'Sale_time_end_date_custom_attribute',
  `attributes_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attributes_mode',
  `attributes` text NOT NULL COMMENT 'Attributes',
  PRIMARY KEY (`template_selling_format_id`),
  KEY `marketplace_id` (`marketplace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_selling_format';


-- drakesterling_old.m2epro_walmart_template_selling_format_promotion definition

CREATE TABLE `m2epro_walmart_template_selling_format_promotion` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `start_date_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Start_date_mode',
  `start_date_attribute` varchar(255) DEFAULT NULL COMMENT 'Start_date_attribute',
  `start_date_value` datetime DEFAULT NULL COMMENT 'Start_date_value',
  `end_date_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'End_date_mode',
  `end_date_attribute` varchar(255) DEFAULT NULL COMMENT 'End_date_attribute',
  `end_date_value` datetime DEFAULT NULL COMMENT 'End_date_value',
  `price_mode` smallint(5) unsigned NOT NULL COMMENT 'Price_mode',
  `price_attribute` varchar(255) NOT NULL COMMENT 'Price_attribute',
  `price_coefficient` varchar(255) NOT NULL COMMENT 'Price_coefficient',
  `comparison_price_mode` smallint(5) unsigned NOT NULL COMMENT 'Comparison_price_mode',
  `comparison_price_attribute` varchar(255) NOT NULL COMMENT 'Comparison_price_attribute',
  `comparison_price_coefficient` varchar(255) NOT NULL COMMENT 'Comparison_price_coefficient',
  `type` varchar(255) NOT NULL COMMENT 'Type',
  PRIMARY KEY (`id`),
  KEY `template_selling_format_id` (`template_selling_format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_selling_format_promotion';


-- drakesterling_old.m2epro_walmart_template_selling_format_shipping_override definition

CREATE TABLE `m2epro_walmart_template_selling_format_shipping_override` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `template_selling_format_id` int(10) unsigned NOT NULL COMMENT 'Template_selling_format_id',
  `method` varchar(255) NOT NULL COMMENT 'Method',
  `is_shipping_allowed` varchar(255) NOT NULL COMMENT 'Is_shipping_allowed',
  `region` varchar(255) NOT NULL COMMENT 'Region',
  `cost_mode` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Cost_mode',
  `cost_value` varchar(255) NOT NULL COMMENT 'Cost_value',
  `cost_attribute` varchar(255) NOT NULL COMMENT 'Cost_attribute',
  PRIMARY KEY (`id`),
  KEY `template_selling_format_id` (`template_selling_format_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_selling_format_shipping_override';


-- drakesterling_old.m2epro_walmart_template_synchronization definition

CREATE TABLE `m2epro_walmart_template_synchronization` (
  `template_synchronization_id` int(10) unsigned NOT NULL COMMENT 'Template_synchronization_id',
  `list_mode` smallint(5) unsigned NOT NULL COMMENT 'List_mode',
  `list_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'List_status_enabled',
  `list_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'List_is_in_stock',
  `list_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'List_qty_magento',
  `list_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value',
  `list_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_magento_value_max',
  `list_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'List_qty_calculated',
  `list_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value',
  `list_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'List_qty_calculated_value_max',
  `list_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'List_advanced_rules_mode',
  `list_advanced_rules_filters` text COMMENT 'List_advanced_rules_filters',
  `revise_update_qty` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty',
  `revise_update_qty_max_applied_value_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_qty_max_applied_value_mode',
  `revise_update_qty_max_applied_value` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_qty_max_applied_value',
  `revise_update_price` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price',
  `revise_update_price_max_allowed_deviation_mode` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_price_max_allowed_deviation_mode',
  `revise_update_price_max_allowed_deviation` int(10) unsigned DEFAULT NULL COMMENT 'Revise_update_price_max_allowed_deviation',
  `revise_update_promotions` smallint(5) unsigned NOT NULL COMMENT 'Revise_update_promotions',
  `relist_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_mode',
  `relist_filter_user_lock` smallint(5) unsigned NOT NULL COMMENT 'Relist_filter_user_lock',
  `relist_status_enabled` smallint(5) unsigned NOT NULL COMMENT 'Relist_status_enabled',
  `relist_is_in_stock` smallint(5) unsigned NOT NULL COMMENT 'Relist_is_in_stock',
  `relist_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_magento',
  `relist_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value',
  `relist_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_magento_value_max',
  `relist_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Relist_qty_calculated',
  `relist_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value',
  `relist_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Relist_qty_calculated_value_max',
  `relist_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Relist_advanced_rules_mode',
  `relist_advanced_rules_filters` text COMMENT 'Relist_advanced_rules_filters',
  `stop_mode` smallint(5) unsigned NOT NULL COMMENT 'Stop_mode',
  `stop_status_disabled` smallint(5) unsigned NOT NULL COMMENT 'Stop_status_disabled',
  `stop_out_off_stock` smallint(5) unsigned NOT NULL COMMENT 'Stop_out_off_stock',
  `stop_qty_magento` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_magento',
  `stop_qty_magento_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value',
  `stop_qty_magento_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_magento_value_max',
  `stop_qty_calculated` smallint(5) unsigned NOT NULL COMMENT 'Stop_qty_calculated',
  `stop_qty_calculated_value` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value',
  `stop_qty_calculated_value_max` int(10) unsigned NOT NULL COMMENT 'Stop_qty_calculated_value_max',
  `stop_advanced_rules_mode` smallint(5) unsigned NOT NULL COMMENT 'Stop_advanced_rules_mode',
  `stop_advanced_rules_filters` text COMMENT 'Stop_advanced_rules_filters',
  PRIMARY KEY (`template_synchronization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='m2epro_walmart_template_synchronization';


-- drakesterling_old.m2epro_wizard definition

CREATE TABLE `m2epro_wizard` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `nick` varchar(255) NOT NULL COMMENT 'Nick',
  `view` varchar(255) NOT NULL COMMENT 'View',
  `status` int(10) unsigned NOT NULL COMMENT 'Status',
  `step` varchar(255) DEFAULT NULL COMMENT 'Step',
  `type` smallint(5) unsigned NOT NULL COMMENT 'Type',
  `priority` int(10) unsigned NOT NULL COMMENT 'Priority',
  PRIMARY KEY (`id`),
  KEY `nick` (`nick`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='m2epro_wizard';


-- drakesterling_old.magebees_productfeed_dynamicattributes definition

CREATE TABLE `magebees_productfeed_dynamicattributes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `name` text COMMENT 'Name',
  `code` text COMMENT 'Code',
  `codeconditions` text COMMENT 'Code Conditions',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='magebees_productfeed_dynamicattributes';


-- drakesterling_old.magebees_productfeed_feed definition

CREATE TABLE `magebees_productfeed_feed` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Feed Id',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `storeview` text COMMENT 'Store View',
  `lastgeneratedate` datetime DEFAULT NULL COMMENT 'Last Generate Date',
  `download_url` text COMMENT 'Download Url',
  `type` text COMMENT 'Template Type',
  `content` text COMMENT 'Template Content',
  `conditions_serialized` mediumtext COMMENT 'Conditions Serialized',
  `format_serialized` mediumtext COMMENT 'Format Serialized',
  `schedule` mediumtext COMMENT 'Schedule Info',
  `enable_schedule` int(11) DEFAULT NULL COMMENT 'Schedule',
  `ftp_settings` mediumtext COMMENT 'Ftp Setttings',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='magebees_productfeed_feed';


-- drakesterling_old.magebees_productfeed_mapping definition

CREATE TABLE `magebees_productfeed_mapping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `name` text COMMENT 'Name',
  `storeview` text COMMENT 'Store View',
  `mappingcontent` text COMMENT 'Mapping Content',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='magebees_productfeed_mapping';


-- drakesterling_old.magebees_productfeed_templates definition

CREATE TABLE `magebees_productfeed_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `name` text COMMENT 'Name',
  `type` text COMMENT 'Template Type',
  `content` text COMMENT 'Template Content',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='magebees_productfeed_templates';


-- drakesterling_old.magenest_xero_payment_account_mapping definition

CREATE TABLE `magenest_xero_payment_account_mapping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `payment_code` text COMMENT 'Date',
  `bank_account_name` text COMMENT 'Xero Bank Account Name',
  `bank_account_id` text COMMENT 'Xero Bank Account ID',
  `updated_at` date DEFAULT NULL COMMENT 'updated at',
  `scope` varchar(11) NOT NULL DEFAULT 'default' COMMENT 'Scope',
  `scope_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Scope ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Xero Payment Account Mapping';


-- drakesterling_old.magenest_xero_queue definition

CREATE TABLE `magenest_xero_queue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `type` varchar(45) DEFAULT NULL COMMENT 'Entity Type',
  `entity_id` text NOT NULL COMMENT 'Entity Id',
  `enqueue_time` datetime DEFAULT NULL COMMENT 'Enqueue Time',
  `priority` smallint(6) NOT NULL COMMENT 'Enqueue Time',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25702 DEFAULT CHARSET=utf8 COMMENT='Xero Sync Queue';


-- drakesterling_old.magenest_xero_request definition

CREATE TABLE `magenest_xero_request` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `date` date DEFAULT NULL COMMENT 'Date',
  `request` int(11) NOT NULL COMMENT 'Request',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2146 DEFAULT CHARSET=utf8 COMMENT='Xero Request Table';


-- drakesterling_old.magenest_xero_tax_rate_mapping definition

CREATE TABLE `magenest_xero_tax_rate_mapping` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `tax_id` text COMMENT 'Tax identifier',
  `xero_tax_code` text COMMENT 'Xero Tax Code',
  `updated_at` date DEFAULT NULL COMMENT 'updated at',
  `scope` varchar(11) NOT NULL DEFAULT 'default' COMMENT 'Scope',
  `scope_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Scope ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Xero Tax Rate Mapping';


-- drakesterling_old.magenest_xero_xml_log definition

CREATE TABLE `magenest_xero_xml_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `xml_log` text COMMENT 'Xml Log',
  `magento_id` varchar(15) DEFAULT NULL COMMENT 'Magento Entity Id',
  `type` varchar(15) NOT NULL COMMENT 'Magento Type',
  `scope` varchar(11) NOT NULL DEFAULT 'default' COMMENT 'Scope',
  `scope_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Scope ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16428 DEFAULT CHARSET=utf8 COMMENT='Xero Xml Log Table';


-- drakesterling_old.magento_bulk definition

CREATE TABLE `magento_bulk` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Bulk Internal ID (must not be exposed)',
  `uuid` varbinary(39) DEFAULT NULL COMMENT 'Bulk UUID (can be exposed to reference bulk entity)',
  `user_id` int(10) unsigned DEFAULT NULL COMMENT 'ID of the WebAPI user that performed an action',
  `user_type` int(11) DEFAULT NULL COMMENT 'Which type of user',
  `description` varchar(255) DEFAULT NULL COMMENT 'Bulk Description',
  `operation_count` int(10) unsigned NOT NULL COMMENT 'Total number of operations scheduled within this bulk',
  `start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Bulk start time',
  PRIMARY KEY (`id`),
  UNIQUE KEY `MAGENTO_BULK_UUID` (`uuid`),
  KEY `MAGENTO_BULK_USER_ID` (`user_id`),
  KEY `MAGENTO_BULK_START_TIME` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Bulk entity that represents set of related asynchronous operations';


-- drakesterling_old.magento_login_as_customer_log definition

CREATE TABLE `magento_login_as_customer_log` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Log Id',
  `time` timestamp NULL DEFAULT NULL COMMENT 'Event Date',
  `user_id` int(10) unsigned DEFAULT NULL COMMENT 'User Id',
  `user_name` varchar(40) DEFAULT NULL COMMENT 'User Name',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer Id',
  `customer_email` varchar(40) DEFAULT NULL COMMENT 'Customer email',
  PRIMARY KEY (`log_id`),
  KEY `MAGENTO_LOGIN_AS_CUSTOMER_LOG_USER_ID` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Login as Customer Logging';


-- drakesterling_old.mageplaza_blog_category definition

CREATE TABLE `mageplaza_blog_category` (
  `category_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Category ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Category Name',
  `description` mediumtext COMMENT 'Category Description',
  `store_ids` int(11) NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Category URL Key',
  `enabled` int(2) DEFAULT '1' COMMENT 'Category Enabled',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Meta Title',
  `meta_description` mediumtext COMMENT 'Meta Description',
  `meta_keywords` mediumtext COMMENT 'Meta Keywords',
  `meta_robots` mediumtext COMMENT 'Meta Robots',
  `parent_id` int(11) DEFAULT NULL COMMENT 'Category Parent ID',
  `path` varchar(255) DEFAULT NULL COMMENT 'Category Path',
  `position` int(11) DEFAULT NULL COMMENT 'Category Position',
  `level` int(11) DEFAULT NULL COMMENT 'Category Level',
  `children_count` int(11) DEFAULT NULL COMMENT 'Category Children Count',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Category Updated At',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Category Created At',
  `import_source` mediumtext COMMENT 'Import Source',
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Category Table';


-- drakesterling_old.mageplaza_blog_tag definition

CREATE TABLE `mageplaza_blog_tag` (
  `tag_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Tag ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Tag Name',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Tag URL Key',
  `description` mediumtext COMMENT 'Tag Description',
  `store_ids` int(11) NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `enabled` int(2) DEFAULT '1' COMMENT 'Tag Enabled',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Tag Updated At',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Tag Created At',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Meta Title',
  `meta_description` mediumtext COMMENT 'Meta Description',
  `meta_keywords` mediumtext COMMENT 'Meta Keywords',
  `meta_robots` mediumtext COMMENT 'Meta Robots',
  `import_source` mediumtext COMMENT 'Import Source',
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Tag Table';


-- drakesterling_old.mageplaza_blog_topic definition

CREATE TABLE `mageplaza_blog_topic` (
  `topic_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Topic ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Topic Name',
  `description` mediumtext COMMENT 'Topic Description',
  `store_ids` int(11) NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `enabled` int(2) DEFAULT '1' COMMENT 'Topic Enabled',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Topic URL Key',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Meta Title',
  `meta_description` mediumtext COMMENT 'Meta Description',
  `meta_keywords` mediumtext COMMENT 'Meta Keywords',
  `meta_robots` mediumtext COMMENT 'Meta Robots',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Topic Updated At',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Topic Created At',
  `import_source` mediumtext COMMENT 'Import Source',
  PRIMARY KEY (`topic_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Topic Table';


-- drakesterling_old.mageplaza_smtp_log definition

CREATE TABLE `mageplaza_smtp_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `subject` varchar(255) DEFAULT NULL COMMENT 'Email Subject',
  `email_content` text COMMENT 'Email Content',
  `status` smallint(6) NOT NULL COMMENT 'Status',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `sender` varchar(255) DEFAULT NULL COMMENT 'Sender',
  `recipient` varchar(255) DEFAULT NULL COMMENT 'Recipient',
  `cc` varchar(255) DEFAULT NULL COMMENT 'Cc',
  `bcc` varchar(255) DEFAULT NULL COMMENT 'Bcc',
  PRIMARY KEY (`id`),
  KEY `MAGEPLAZA_SMTP_LOG_STATUS` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=31633 DEFAULT CHARSET=utf8 COMMENT='mageplaza_smtp_log';


-- drakesterling_old.mageplaza_webhook_cron_schedule definition

CREATE TABLE `mageplaza_webhook_cron_schedule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Schedule ID',
  `hook_type` varchar(255) DEFAULT NULL COMMENT 'Hook Type',
  `event_id` int(10) unsigned NOT NULL COMMENT 'Event ID',
  `status` varchar(10) DEFAULT NULL COMMENT 'Status',
  PRIMARY KEY (`id`),
  UNIQUE KEY `MAGEPLAZA_WEBHOOK_CRON_SCHEDULE_ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Cron Schedule Table';


-- drakesterling_old.mageplaza_webhook_hook definition

CREATE TABLE `mageplaza_webhook_hook` (
  `hook_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Feed Id',
  `name` varchar(255) NOT NULL COMMENT 'Name',
  `status` int(11) NOT NULL COMMENT 'Hook Status',
  `order_status` varchar(255) DEFAULT NULL COMMENT 'Order Status',
  `store_ids` varchar(64) NOT NULL COMMENT 'Stores',
  `hook_type` varchar(64) NOT NULL COMMENT 'Hook Type',
  `priority` int(11) DEFAULT NULL COMMENT 'Priority',
  `payload_url` text NOT NULL COMMENT 'Payload URL',
  `method` varchar(64) DEFAULT NULL COMMENT 'Method',
  `authentication` varchar(64) DEFAULT NULL COMMENT 'Authentication',
  `username` varchar(255) DEFAULT NULL COMMENT 'Username',
  `realm` text COMMENT 'Realm',
  `password` varchar(255) DEFAULT NULL COMMENT 'Password',
  `nonce` varchar(255) DEFAULT NULL COMMENT 'Nonce',
  `algorithm` varchar(255) DEFAULT NULL COMMENT 'Algorithm',
  `qop` varchar(255) DEFAULT NULL COMMENT 'qop',
  `nonce_count` varchar(255) DEFAULT NULL COMMENT 'Nonce Count',
  `client_nonce` varchar(255) DEFAULT NULL COMMENT 'Client Nonce',
  `opaque` varchar(255) DEFAULT NULL COMMENT 'Opaque',
  `headers` mediumtext COMMENT 'Header',
  `content_type` varchar(64) DEFAULT NULL COMMENT 'Content-type',
  `body` mediumtext COMMENT 'Header',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Update At',
  PRIMARY KEY (`hook_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Hook Table';


-- drakesterling_old.mailchimp_errors definition

CREATE TABLE `mailchimp_errors` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `mailchimp_store_id` varchar(50) DEFAULT NULL COMMENT 'Mailchimp Store Id',
  `type` text NOT NULL COMMENT 'type',
  `title` varchar(128) DEFAULT NULL COMMENT 'title',
  `status` int(11) NOT NULL COMMENT 'status',
  `errors` text NOT NULL COMMENT 'errors',
  `regtype` varchar(3) DEFAULT NULL COMMENT 'regtype',
  `original_id` int(11) NOT NULL COMMENT 'Associated object ID',
  `batch_id` varchar(64) DEFAULT NULL COMMENT 'Mailchimp Batch ID',
  `store_id` int(11) NOT NULL COMMENT 'Magento Store Id',
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Added at date',
  PRIMARY KEY (`id`),
  KEY `MAILCHIMP_ERRORS_STORE_ID_REGTYPE_ORIGINAL_ID` (`store_id`,`regtype`,`original_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3296 DEFAULT CHARSET=utf8;


-- drakesterling_old.mailchimp_interest_group definition

CREATE TABLE `mailchimp_interest_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `subscriber_id` int(11) NOT NULL COMMENT 'subscriber id',
  `store_id` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `groupdata` text NOT NULL COMMENT 'data',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8;


-- drakesterling_old.mailchimp_stores definition

CREATE TABLE `mailchimp_stores` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `apikey` varchar(128) DEFAULT NULL COMMENT 'API Key',
  `storeid` varchar(50) DEFAULT NULL COMMENT 'Store Id',
  `list_id` varchar(50) DEFAULT NULL COMMENT 'List Id',
  `name` varchar(128) DEFAULT NULL COMMENT 'Name',
  `platform` varchar(50) DEFAULT NULL COMMENT 'Platform',
  `is_sync` tinyint(1) NOT NULL COMMENT 'if the store is synced or not ',
  `email_address` varchar(128) DEFAULT NULL COMMENT 'email associated to store',
  `currency_code` varchar(3) DEFAULT NULL COMMENT 'store currency code',
  `money_format` varchar(10) DEFAULT NULL COMMENT 'symbol of currency',
  `primary_locale` varchar(5) DEFAULT NULL COMMENT 'store locale',
  `timezone` varchar(32) DEFAULT NULL COMMENT 'store timezone',
  `phone` varchar(50) DEFAULT NULL COMMENT 'store phone',
  `address_address_one` varchar(255) DEFAULT NULL COMMENT 'first street address',
  `address_address_two` varchar(255) DEFAULT NULL COMMENT 'second street address',
  `address_city` varchar(50) DEFAULT NULL COMMENT 'store city',
  `address_province` varchar(50) DEFAULT NULL COMMENT 'store province',
  `address_province_code` varchar(2) DEFAULT NULL COMMENT 'store province code',
  `address_postal_code` varchar(50) DEFAULT NULL COMMENT 'store postal code',
  `address_country` varchar(50) DEFAULT NULL COMMENT 'store country',
  `address_country_code` varchar(2) DEFAULT NULL COMMENT 'store country code',
  `domain` text NOT NULL COMMENT 'Domain',
  `mc_account_name` text NOT NULL COMMENT 'MC account name',
  `list_name` text NOT NULL COMMENT ' List Name',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;


-- drakesterling_old.mailchimp_sync_batches definition

CREATE TABLE `mailchimp_sync_batches` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `store_id` varchar(50) DEFAULT NULL COMMENT 'Store Id',
  `mailchimp_store_id` varchar(50) DEFAULT NULL COMMENT 'Mailchimp Store Id',
  `batch_id` varchar(24) DEFAULT NULL COMMENT 'Batch Id',
  `status` varchar(10) DEFAULT NULL COMMENT 'Status',
  `modified_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Sync Delta',
  `carts_new_count` smallint(6) DEFAULT NULL COMMENT 'Carts New Count',
  `customers_new_count` smallint(6) DEFAULT NULL COMMENT 'Customers New Count',
  `orders_new_count` smallint(6) DEFAULT NULL COMMENT 'Orders New Count',
  `products_new_count` smallint(6) DEFAULT NULL COMMENT 'Products New Count',
  `subscribers_new_count` smallint(6) DEFAULT NULL COMMENT 'Subscribers New Count',
  `carts_modified_count` smallint(6) DEFAULT NULL COMMENT 'Carts Modified Count',
  `customers_modified_count` smallint(6) DEFAULT NULL COMMENT 'Customers Modified Count',
  `orders_modified_count` smallint(6) DEFAULT NULL COMMENT 'Orders Modified Count',
  `products_modified_count` smallint(6) DEFAULT NULL COMMENT 'Products Modified Count',
  `subscribers_modified_count` smallint(6) DEFAULT NULL COMMENT 'Subscribers Modified Count',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=37613 DEFAULT CHARSET=utf8;


-- drakesterling_old.mailchimp_sync_ecommerce definition

CREATE TABLE `mailchimp_sync_ecommerce` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `mailchimp_store_id` varchar(50) DEFAULT NULL COMMENT 'Store Id',
  `type` varchar(24) DEFAULT NULL COMMENT 'Type of register',
  `related_id` int(10) unsigned NOT NULL COMMENT 'Id of the related entity',
  `mailchimp_sync_modified` tinyint(1) NOT NULL COMMENT 'If the entity was modified',
  `mailchimp_sync_delta` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Sync Delta',
  `mailchimp_sync_error` varchar(128) DEFAULT NULL COMMENT 'Error on synchronization',
  `mailchimp_sync_deleted` tinyint(1) NOT NULL COMMENT 'If the object was deleted in mailchimp',
  `mailchimp_token` varchar(32) DEFAULT NULL COMMENT 'Quote token',
  `batch_id` varchar(64) DEFAULT NULL COMMENT 'Batch id',
  `deleted_related_id` int(10) unsigned NOT NULL COMMENT 'Id related to delete item',
  `mailchimp_sent` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sent to Mailchimp',
  PRIMARY KEY (`id`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_RELATED_ID` (`related_id`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_TYPE` (`type`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_BATCH_ID` (`batch_id`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_MAILCHIMP_STORE_ID` (`mailchimp_store_id`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_MAILCHIMP_SYNC_DELTA` (`mailchimp_sync_delta`),
  KEY `MAILCHIMP_SYNC_ECOMMERCE_MAILCHIMP_SYNC_MODIFIED` (`mailchimp_sync_modified`)
) ENGINE=InnoDB AUTO_INCREMENT=4368 DEFAULT CHARSET=utf8;


-- drakesterling_old.mailchimp_webhook_request definition

CREATE TABLE `mailchimp_webhook_request` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Table Id',
  `type` varchar(50) DEFAULT NULL COMMENT 'request type',
  `fired_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'date of the request',
  `data_request` text NOT NULL COMMENT 'data of the request',
  `processed` tinyint(1) NOT NULL COMMENT 'Already processed',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.media_content_asset definition

CREATE TABLE `media_content_asset` (
  `asset_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `entity_type` varchar(255) NOT NULL COMMENT 'Content type',
  `entity_id` varchar(255) NOT NULL COMMENT 'Content entity id',
  `field` varchar(255) NOT NULL COMMENT 'Content field',
  PRIMARY KEY (`entity_type`,`entity_id`,`field`,`asset_id`),
  KEY `MEDIA_CONTENT_ASSET_ASSET_ID` (`asset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Relation between media content and media asset';


-- drakesterling_old.media_gallery_asset definition

CREATE TABLE `media_gallery_asset` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `path` text COMMENT 'Path',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `source` varchar(255) DEFAULT NULL COMMENT 'Source',
  `content_type` varchar(255) DEFAULT NULL COMMENT 'Content Type',
  `width` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Width',
  `height` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Height',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `description` text COMMENT 'Description',
  `hash` varchar(255) DEFAULT NULL COMMENT 'File hash',
  `size` int(10) unsigned NOT NULL COMMENT 'Asset file size in bytes',
  PRIMARY KEY (`id`),
  KEY `MEDIA_GALLERY_ASSET_ID` (`id`),
  FULLTEXT KEY `MEDIA_GALLERY_ASSET_TITLE` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='Media Gallery Asset';


-- drakesterling_old.media_gallery_keyword definition

CREATE TABLE `media_gallery_keyword` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Keyword ID',
  `keyword` varchar(255) NOT NULL COMMENT 'Keyword',
  PRIMARY KEY (`id`),
  UNIQUE KEY `MEDIA_GALLERY_KEYWORD_KEYWORD` (`keyword`),
  KEY `MEDIA_GALLERY_KEYWORD_ID` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Media Gallery Keyword';


-- drakesterling_old.msp_tfa_country_codes definition

CREATE TABLE `msp_tfa_country_codes` (
  `msp_tfa_country_codes_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'TFA admin user ID',
  `code` text NOT NULL COMMENT 'Country code',
  `name` text NOT NULL COMMENT 'Country name',
  `dial_code` text NOT NULL COMMENT 'Prefix',
  PRIMARY KEY (`msp_tfa_country_codes_id`),
  KEY `MSP_TFA_COUNTRY_CODES_CODE` (`code`(128))
) ENGINE=InnoDB AUTO_INCREMENT=242 DEFAULT CHARSET=utf8 COMMENT='msp_tfa_country_codes';


-- drakesterling_old.mview_state definition

CREATE TABLE `mview_state` (
  `state_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'View State ID',
  `view_id` varchar(255) DEFAULT NULL COMMENT 'View ID',
  `mode` varchar(16) DEFAULT 'disabled' COMMENT 'View Mode',
  `status` varchar(16) DEFAULT 'idle' COMMENT 'View Status',
  `updated` datetime DEFAULT NULL COMMENT 'View updated time',
  `version_id` int(10) unsigned DEFAULT NULL COMMENT 'View Version ID',
  PRIMARY KEY (`state_id`),
  KEY `MVIEW_STATE_VIEW_ID` (`view_id`),
  KEY `MVIEW_STATE_MODE` (`mode`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8 COMMENT='View State';


-- drakesterling_old.newsletter_template definition

CREATE TABLE `newsletter_template` (
  `template_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Template ID',
  `template_code` varchar(150) DEFAULT NULL COMMENT 'Template Code',
  `template_text` text COMMENT 'Template Text',
  `template_styles` text COMMENT 'Template Styles',
  `template_type` int(10) unsigned DEFAULT NULL COMMENT 'Template Type',
  `template_subject` varchar(200) DEFAULT NULL COMMENT 'Template Subject',
  `template_sender_name` varchar(200) DEFAULT NULL COMMENT 'Template Sender Name',
  `template_sender_email` varchar(200) DEFAULT NULL COMMENT 'Template Sender Email',
  `template_actual` smallint(5) unsigned DEFAULT '1' COMMENT 'Template Actual',
  `added_at` timestamp NULL DEFAULT NULL COMMENT 'Added At',
  `modified_at` timestamp NULL DEFAULT NULL COMMENT 'Modified At',
  `is_legacy` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Should the template render in legacy mode',
  PRIMARY KEY (`template_id`),
  KEY `NEWSLETTER_TEMPLATE_TEMPLATE_ACTUAL` (`template_actual`),
  KEY `NEWSLETTER_TEMPLATE_ADDED_AT` (`added_at`),
  KEY `NEWSLETTER_TEMPLATE_MODIFIED_AT` (`modified_at`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Newsletter Template';


-- drakesterling_old.oauth_consumer definition

CREATE TABLE `oauth_consumer` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `name` varchar(255) NOT NULL COMMENT 'Name of consumer',
  `key` varchar(32) NOT NULL COMMENT 'Key code',
  `secret` varchar(128) NOT NULL COMMENT 'Secret code',
  `callback_url` text COMMENT 'Callback URL',
  `rejected_callback_url` text NOT NULL COMMENT 'Rejected callback URL',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `OAUTH_CONSUMER_KEY` (`key`),
  UNIQUE KEY `OAUTH_CONSUMER_SECRET` (`secret`),
  KEY `OAUTH_CONSUMER_CREATED_AT` (`created_at`),
  KEY `OAUTH_CONSUMER_UPDATED_AT` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=utf8 COMMENT='OAuth Consumers';


-- drakesterling_old.oauth_token_request_log definition

CREATE TABLE `oauth_token_request_log` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `user_name` varchar(255) NOT NULL COMMENT 'Customer email or admin login',
  `user_type` smallint(5) unsigned NOT NULL COMMENT 'User type (admin or customer)',
  `failures_count` smallint(5) unsigned DEFAULT '0' COMMENT 'Number of failed authentication attempts in a row',
  `lock_expires_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Lock expiration time',
  PRIMARY KEY (`log_id`),
  UNIQUE KEY `OAUTH_TOKEN_REQUEST_LOG_USER_NAME_USER_TYPE` (`user_name`,`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Log of token request authentication failures.';


-- drakesterling_old.pagebuilder_template definition

CREATE TABLE `pagebuilder_template` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Template ID Auto Increment',
  `name` varchar(1024) NOT NULL COMMENT 'Template Name',
  `preview_image` varchar(1024) DEFAULT NULL COMMENT 'Template Preview Image',
  `template` longtext NOT NULL COMMENT 'Master Format HTML',
  `created_for` varchar(255) DEFAULT NULL COMMENT 'Created For',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  PRIMARY KEY (`template_id`),
  FULLTEXT KEY `PAGEBUILDER_TEMPLATE_NAME` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Page Builder Templates';


-- drakesterling_old.password_reset_request_event definition

CREATE TABLE `password_reset_request_event` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `request_type` smallint(5) unsigned NOT NULL COMMENT 'Type of the event under a security control',
  `account_reference` varchar(255) DEFAULT NULL COMMENT 'An identifier for existing account or another target',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Timestamp when the event occurs',
  `ip` varchar(15) NOT NULL COMMENT 'Remote user IP',
  PRIMARY KEY (`id`),
  KEY `PASSWORD_RESET_REQUEST_EVENT_ACCOUNT_REFERENCE` (`account_reference`),
  KEY `PASSWORD_RESET_REQUEST_EVENT_CREATED_AT` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=9001 DEFAULT CHARSET=utf8 COMMENT='Password Reset Request Event under a security control';


-- drakesterling_old.patch_list definition

CREATE TABLE `patch_list` (
  `patch_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Patch Auto Increment',
  `patch_name` varchar(1024) NOT NULL COMMENT 'Patch Class Name',
  PRIMARY KEY (`patch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=194 DEFAULT CHARSET=utf8 COMMENT='List of data/schema patches';


-- drakesterling_old.payment_services_order_data_production_submitted_hash definition

CREATE TABLE `payment_services_order_data_production_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Order identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Order Feed Storage';


-- drakesterling_old.payment_services_order_data_sandbox_submitted_hash definition

CREATE TABLE `payment_services_order_data_sandbox_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Order identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Order Feed Storage';


-- drakesterling_old.payment_services_order_status_data_prod_submitted_hash definition

CREATE TABLE `payment_services_order_status_data_prod_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Order Status identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Order Status Feed Storage';


-- drakesterling_old.payment_services_order_status_data_sandbox_submitted_hash definition

CREATE TABLE `payment_services_order_status_data_sandbox_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Order Status identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Order Status Feed Storage';


-- drakesterling_old.payment_services_store_data_production_submitted_hash definition

CREATE TABLE `payment_services_store_data_production_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Store identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Store Feed Storage';


-- drakesterling_old.payment_services_store_data_sandbox_submitted_hash definition

CREATE TABLE `payment_services_store_data_sandbox_submitted_hash` (
  `identifier` varchar(64) NOT NULL COMMENT 'Store identifier',
  `feed_hash` varchar(64) NOT NULL COMMENT 'feed_hash',
  `submitted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Submitted At',
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Payment Services Store Feed Storage';


-- drakesterling_old.paypal_payment_transaction definition

CREATE TABLE `paypal_payment_transaction` (
  `transaction_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `txn_id` varchar(100) DEFAULT NULL COMMENT 'Txn ID',
  `additional_information` blob COMMENT 'Additional Information',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `PAYPAL_PAYMENT_TRANSACTION_TXN_ID` (`txn_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='PayPal Payflow Link Payment Transaction';


-- drakesterling_old.paypal_settlement_report definition

CREATE TABLE `paypal_settlement_report` (
  `report_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Report ID',
  `report_date` date DEFAULT NULL COMMENT 'Report Date',
  `account_id` varchar(64) DEFAULT NULL COMMENT 'Account ID',
  `filename` varchar(24) DEFAULT NULL COMMENT 'Filename',
  `last_modified` timestamp NULL DEFAULT NULL COMMENT 'Last Modified',
  PRIMARY KEY (`report_id`),
  UNIQUE KEY `PAYPAL_SETTLEMENT_REPORT_REPORT_DATE_ACCOUNT_ID` (`report_date`,`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Paypal Settlement Report Table';


-- drakesterling_old.plugincompany_fraudprevention_rule definition

CREATE TABLE `plugincompany_fraudprevention_rule` (
  `rule_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `name` varchar(255) NOT NULL COMMENT 'name',
  `attributes` text NOT NULL COMMENT 'attributes',
  `strikes` int(11) NOT NULL DEFAULT '1' COMMENT 'strikes',
  `status` int(11) NOT NULL DEFAULT '1' COMMENT 'status',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'updated_at',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'created_at',
  `customer_groups` text COMMENT 'customer_groups',
  PRIMARY KEY (`rule_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='plugincompany_fraudprevention_rule';


-- drakesterling_old.plugincompany_fraudprevention_suspicion definition

CREATE TABLE `plugincompany_fraudprevention_suspicion` (
  `suspicion_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `customer_id` int(11) DEFAULT NULL COMMENT 'customer_id',
  `order_id` int(11) DEFAULT NULL COMMENT 'order_id',
  `postcode` varchar(255) DEFAULT NULL COMMENT 'postcode',
  `firstname` varchar(255) DEFAULT NULL COMMENT 'firstname',
  `middlename` varchar(255) DEFAULT NULL COMMENT 'middlename',
  `lastname` varchar(255) DEFAULT NULL COMMENT 'lastname',
  `street` text COMMENT 'street',
  `city` varchar(255) DEFAULT NULL COMMENT 'city',
  `region` varchar(255) DEFAULT NULL COMMENT 'region',
  `region_id` int(11) DEFAULT NULL COMMENT 'region_id',
  `country_id` varchar(255) DEFAULT NULL COMMENT 'country_id',
  `email` varchar(255) DEFAULT NULL COMMENT 'email',
  `telephone` varchar(255) DEFAULT NULL COMMENT 'telephone',
  `fax` varchar(255) DEFAULT NULL COMMENT 'fax',
  `address_type` varchar(255) DEFAULT NULL COMMENT 'address_type',
  `company` varchar(255) DEFAULT NULL COMMENT 'company',
  `marked_by_admin` int(11) DEFAULT '0' COMMENT 'marked_by_admin',
  `comment` text COMMENT 'comment',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'updated_at',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'created_at',
  `email_domain` varchar(255) DEFAULT NULL COMMENT 'email_domain',
  `customer_ip` varchar(255) DEFAULT NULL COMMENT 'customer_ip',
  `firstname_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized First Name',
  `middlename_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Middle Name',
  `lastname_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Last Name',
  `street_normalized` mediumtext COMMENT 'Normalized Street',
  `postcode_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Postcode',
  `city_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized City',
  `region_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Region',
  `telephone_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Telephone',
  `fax_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Fax',
  `company_normalized` varchar(255) DEFAULT NULL COMMENT 'Normalized Company',
  `weight` int(11) DEFAULT '1' COMMENT 'Weight',
  PRIMARY KEY (`suspicion_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='plugincompany_fraudprevention_suspicion';


-- drakesterling_old.prince_faq definition

CREATE TABLE `prince_faq` (
  `faq_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `title` text COMMENT 'title',
  `content` text COMMENT 'content',
  `group` text COMMENT 'group',
  `storeview` text COMMENT 'storeview',
  `customer_group` text COMMENT 'customer_group',
  `sortorder` int(11) DEFAULT NULL COMMENT 'sortorder',
  `status` tinyint(1) DEFAULT NULL COMMENT 'status',
  PRIMARY KEY (`faq_id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8 COMMENT='prince_faq';


-- drakesterling_old.prince_faqgroup definition

CREATE TABLE `prince_faqgroup` (
  `faqgroup_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `groupname` text COMMENT 'groupname',
  `icon` text COMMENT 'icon',
  `storeview` text COMMENT 'storeview',
  `customer_group` text COMMENT 'customer_group',
  `sortorder` int(11) DEFAULT NULL COMMENT 'sortorder',
  `status` tinyint(1) DEFAULT NULL COMMENT 'status',
  PRIMARY KEY (`faqgroup_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='prince_faqgroup';


-- drakesterling_old.queue definition

CREATE TABLE `queue` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Queue ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Queue name',
  PRIMARY KEY (`id`),
  UNIQUE KEY `QUEUE_NAME` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COMMENT='Table storing unique queues';


-- drakesterling_old.queue_lock definition

CREATE TABLE `queue_lock` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Message ID',
  `message_code` varchar(255) NOT NULL DEFAULT '' COMMENT 'Message Code',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`id`),
  UNIQUE KEY `QUEUE_LOCK_MESSAGE_CODE` (`message_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Messages that were processed are inserted here to be locked.';


-- drakesterling_old.queue_message definition

CREATE TABLE `queue_message` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Message ID',
  `topic_name` varchar(255) DEFAULT NULL COMMENT 'Message topic',
  `body` longtext COMMENT 'Message body',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Queue messages';


-- drakesterling_old.queue_poison_pill definition

CREATE TABLE `queue_poison_pill` (
  `version` varchar(255) NOT NULL COMMENT 'Poison Pill version.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sequence table for poison pill versions';


-- drakesterling_old.rating_entity definition

CREATE TABLE `rating_entity` (
  `entity_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `entity_code` varchar(64) NOT NULL COMMENT 'Entity Code',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `RATING_ENTITY_ENTITY_CODE` (`entity_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Rating entities';


-- drakesterling_old.report_event_types definition

CREATE TABLE `report_event_types` (
  `event_type_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Event Type ID',
  `event_name` varchar(64) NOT NULL COMMENT 'Event Name',
  `customer_login` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Login',
  PRIMARY KEY (`event_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='Reports Event Type Table';


-- drakesterling_old.reporting_counts definition

CREATE TABLE `reporting_counts` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `type` varchar(255) DEFAULT NULL COMMENT 'Item Reported',
  `count` int(10) unsigned DEFAULT NULL COMMENT 'Count Value',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reporting for all count related events generated via the cron job';


-- drakesterling_old.reporting_module_status definition

CREATE TABLE `reporting_module_status` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Module ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Module Name',
  `active` varchar(255) DEFAULT NULL COMMENT 'Module Active Status',
  `setup_version` varchar(255) DEFAULT NULL COMMENT 'Module Version',
  `state` varchar(255) DEFAULT NULL COMMENT 'Module State',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Module Status Table';


-- drakesterling_old.reporting_orders definition

CREATE TABLE `reporting_orders` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `total` decimal(20,4) unsigned DEFAULT NULL,
  `total_base` decimal(20,4) unsigned DEFAULT NULL,
  `item_count` int(10) unsigned NOT NULL COMMENT 'Line Item Count',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reporting for all orders';


-- drakesterling_old.reporting_system_updates definition

CREATE TABLE `reporting_system_updates` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `type` varchar(255) DEFAULT NULL COMMENT 'Update Type',
  `action` varchar(255) DEFAULT NULL COMMENT 'Action Performed',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reporting for system updates';


-- drakesterling_old.reporting_users definition

CREATE TABLE `reporting_users` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `type` varchar(255) DEFAULT NULL COMMENT 'User Type',
  `action` varchar(255) DEFAULT NULL COMMENT 'Action Performed',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reporting for user actions';


-- drakesterling_old.review_entity definition

CREATE TABLE `review_entity` (
  `entity_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Review entity ID',
  `entity_code` varchar(32) NOT NULL COMMENT 'Review entity code',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Review entities';


-- drakesterling_old.review_status definition

CREATE TABLE `review_status` (
  `status_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Status ID',
  `status_code` varchar(32) NOT NULL COMMENT 'Status code',
  PRIMARY KEY (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Review statuses';


-- drakesterling_old.sales_creditmemo_grid definition

CREATE TABLE `sales_creditmemo_grid` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `order_increment_id` varchar(50) DEFAULT NULL COMMENT 'Order Increment ID',
  `order_created_at` timestamp NULL DEFAULT NULL COMMENT 'Order Created At',
  `billing_name` varchar(255) DEFAULT NULL COMMENT 'Billing Name',
  `state` int(11) DEFAULT NULL COMMENT 'Status',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `order_status` varchar(32) DEFAULT NULL COMMENT 'Order Status',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `billing_address` varchar(255) DEFAULT NULL COMMENT 'Billing Address',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT 'Shipping Address',
  `customer_name` varchar(128) NOT NULL COMMENT 'Customer Name',
  `customer_email` varchar(128) DEFAULT NULL COMMENT 'Customer Email',
  `customer_group_id` smallint(6) DEFAULT NULL COMMENT 'Customer Group ID',
  `payment_method` varchar(32) DEFAULT NULL COMMENT 'Payment Method',
  `shipping_information` varchar(255) DEFAULT NULL COMMENT 'Shipping Method Name',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `shipping_and_handling` decimal(20,4) DEFAULT NULL COMMENT 'Shipping and handling amount',
  `adjustment_positive` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Positive',
  `adjustment_negative` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Negative',
  `order_base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Order Grand Total',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_CREDITMEMO_GRID_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_CREDITMEMO_GRID_ORDER_INCREMENT_ID` (`order_increment_id`),
  KEY `SALES_CREDITMEMO_GRID_CREATED_AT` (`created_at`),
  KEY `SALES_CREDITMEMO_GRID_UPDATED_AT` (`updated_at`),
  KEY `SALES_CREDITMEMO_GRID_ORDER_CREATED_AT` (`order_created_at`),
  KEY `SALES_CREDITMEMO_GRID_STATE` (`state`),
  KEY `SALES_CREDITMEMO_GRID_BILLING_NAME` (`billing_name`),
  KEY `SALES_CREDITMEMO_GRID_ORDER_STATUS` (`order_status`),
  KEY `SALES_CREDITMEMO_GRID_BASE_GRAND_TOTAL` (`base_grand_total`),
  KEY `SALES_CREDITMEMO_GRID_STORE_ID` (`store_id`),
  KEY `SALES_CREDITMEMO_GRID_ORDER_BASE_GRAND_TOTAL` (`order_base_grand_total`),
  KEY `SALES_CREDITMEMO_GRID_ORDER_ID` (`order_id`),
  FULLTEXT KEY `FTI_32B7BA885941A8254EE84AE650ABDC86` (`increment_id`,`order_increment_id`,`billing_name`,`billing_address`,`shipping_address`,`customer_name`,`customer_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Creditmemo Grid';


-- drakesterling_old.sales_data_exporter_order_statuses definition

CREATE TABLE `sales_data_exporter_order_statuses` (
  `status` varchar(255) NOT NULL COMMENT 'status',
  `feed_data` mediumtext NOT NULL COMMENT 'Feed Data',
  `modified_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Modified At',
  PRIMARY KEY (`status`),
  KEY `SALES_DATA_EXPORTER_ORDER_STATUSES_MODIFIED_AT` (`modified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Order Statuses Feed Storage';


-- drakesterling_old.sales_data_exporter_order_statuses_index_batches definition

CREATE TABLE `sales_data_exporter_order_statuses_index_batches` (
  `batch_number` int(11) NOT NULL COMMENT 'Batch Number',
  `status` varchar(32) NOT NULL COMMENT 'Status',
  PRIMARY KEY (`batch_number`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='sales_data_exporter_order_statuses_index_batches';


-- drakesterling_old.sales_data_exporter_order_statuses_index_sequence definition

CREATE TABLE `sales_data_exporter_order_statuses_index_sequence` (
  `i` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID',
  PRIMARY KEY (`i`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='sales_data_exporter_order_statuses_index_sequence';


-- drakesterling_old.sales_data_exporter_orders definition

CREATE TABLE `sales_data_exporter_orders` (
  `id` int(10) unsigned NOT NULL COMMENT 'ID',
  `mode` varchar(255) NOT NULL COMMENT 'Order Payment Mode',
  `feed_data` mediumtext NOT NULL COMMENT 'Feed Data',
  `modified_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Modified At',
  PRIMARY KEY (`id`),
  KEY `SALES_DATA_EXPORTER_ORDERS_MODIFIED_AT` (`modified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Orders Feed Storage';


-- drakesterling_old.sales_data_exporter_orders_index_batches definition

CREATE TABLE `sales_data_exporter_orders_index_batches` (
  `batch_number` int(11) NOT NULL COMMENT 'Batch Number',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity Id',
  PRIMARY KEY (`batch_number`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='sales_data_exporter_orders_index_batches';


-- drakesterling_old.sales_data_exporter_orders_index_sequence definition

CREATE TABLE `sales_data_exporter_orders_index_sequence` (
  `i` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID',
  PRIMARY KEY (`i`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COMMENT='sales_data_exporter_orders_index_sequence';


-- drakesterling_old.sales_invoice_grid definition

CREATE TABLE `sales_invoice_grid` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `state` int(11) DEFAULT NULL COMMENT 'State',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `store_name` varchar(255) DEFAULT NULL COMMENT 'Store Name',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `order_increment_id` varchar(50) DEFAULT NULL COMMENT 'Order Increment ID',
  `order_created_at` timestamp NULL DEFAULT NULL COMMENT 'Order Created At',
  `customer_name` varchar(255) DEFAULT NULL COMMENT 'Customer Name',
  `customer_email` varchar(255) DEFAULT NULL COMMENT 'Customer Email',
  `customer_group_id` int(11) DEFAULT NULL,
  `payment_method` varchar(128) DEFAULT NULL COMMENT 'Payment Method',
  `store_currency_code` varchar(3) DEFAULT NULL COMMENT 'Store Currency Code',
  `order_currency_code` varchar(3) DEFAULT NULL COMMENT 'Order Currency Code',
  `base_currency_code` varchar(3) DEFAULT NULL COMMENT 'Base Currency Code',
  `global_currency_code` varchar(3) DEFAULT NULL COMMENT 'Global Currency Code',
  `billing_name` varchar(255) DEFAULT NULL COMMENT 'Billing Name',
  `billing_address` varchar(255) DEFAULT NULL COMMENT 'Billing Address',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT 'Shipping Address',
  `shipping_information` varchar(255) DEFAULT NULL COMMENT 'Shipping Method Name',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `shipping_and_handling` decimal(20,4) DEFAULT NULL COMMENT 'Shipping and handling amount',
  `grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Grand Total',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_INVOICE_GRID_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_INVOICE_GRID_STORE_ID` (`store_id`),
  KEY `SALES_INVOICE_GRID_GRAND_TOTAL` (`grand_total`),
  KEY `SALES_INVOICE_GRID_ORDER_ID` (`order_id`),
  KEY `SALES_INVOICE_GRID_STATE` (`state`),
  KEY `SALES_INVOICE_GRID_ORDER_INCREMENT_ID` (`order_increment_id`),
  KEY `SALES_INVOICE_GRID_CREATED_AT` (`created_at`),
  KEY `SALES_INVOICE_GRID_UPDATED_AT` (`updated_at`),
  KEY `SALES_INVOICE_GRID_ORDER_CREATED_AT` (`order_created_at`),
  KEY `SALES_INVOICE_GRID_BILLING_NAME` (`billing_name`),
  KEY `SALES_INVOICE_GRID_BASE_GRAND_TOTAL` (`base_grand_total`),
  FULLTEXT KEY `FTI_95D9C924DD6A8734EB8B5D01D60F90DE` (`increment_id`,`order_increment_id`,`billing_name`,`billing_address`,`shipping_address`,`customer_name`,`customer_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Invoice Grid';


-- drakesterling_old.sales_order_data_exporter_cl definition

CREATE TABLE `sales_order_data_exporter_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6103 DEFAULT CHARSET=utf8 COMMENT='sales_order_data_exporter_cl';


-- drakesterling_old.sales_order_data_exporter_cl_index_batches definition

CREATE TABLE `sales_order_data_exporter_cl_index_batches` (
  `batch_number` int(11) NOT NULL COMMENT 'Batch Number',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Id',
  PRIMARY KEY (`batch_number`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='sales_order_data_exporter_cl_index_batches';


-- drakesterling_old.sales_order_data_exporter_cl_index_sequence definition

CREATE TABLE `sales_order_data_exporter_cl_index_sequence` (
  `i` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID',
  PRIMARY KEY (`i`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='sales_order_data_exporter_cl_index_sequence';


-- drakesterling_old.sales_order_grid definition

CREATE TABLE `sales_order_grid` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `status` varchar(32) DEFAULT NULL COMMENT 'Status',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `store_name` varchar(255) DEFAULT NULL COMMENT 'Store Name',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `base_total_paid` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Paid',
  `grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Grand Total',
  `total_paid` decimal(20,4) DEFAULT NULL COMMENT 'Total Paid',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `base_currency_code` varchar(3) DEFAULT NULL COMMENT 'Base Currency Code',
  `order_currency_code` varchar(255) DEFAULT NULL COMMENT 'Order Currency Code',
  `shipping_name` varchar(255) DEFAULT NULL COMMENT 'Shipping Name',
  `billing_name` varchar(255) DEFAULT NULL COMMENT 'Billing Name',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  `billing_address` varchar(255) DEFAULT NULL COMMENT 'Billing Address',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT 'Shipping Address',
  `shipping_information` varchar(255) DEFAULT NULL COMMENT 'Shipping Method Name',
  `customer_email` varchar(255) DEFAULT NULL COMMENT 'Customer Email',
  `customer_group` varchar(255) DEFAULT NULL COMMENT 'Customer Group',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `shipping_and_handling` decimal(20,4) DEFAULT NULL COMMENT 'Shipping and handling amount',
  `customer_name` varchar(255) DEFAULT NULL COMMENT 'Customer Name',
  `payment_method` varchar(255) DEFAULT NULL COMMENT 'Payment Method',
  `total_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Total Refunded',
  `signifyd_guarantee_status` varchar(32) DEFAULT NULL COMMENT 'Signifyd Guarantee Disposition Status',
  `mailchimp_flag` tinyint(1) NOT NULL COMMENT 'Retrieved from Mailchimp',
  `dispute_status` varchar(45) DEFAULT NULL COMMENT 'Braintree Dispute Status',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_ORDER_GRID_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_ORDER_GRID_STATUS` (`status`),
  KEY `SALES_ORDER_GRID_STORE_ID` (`store_id`),
  KEY `SALES_ORDER_GRID_BASE_GRAND_TOTAL` (`base_grand_total`),
  KEY `SALES_ORDER_GRID_BASE_TOTAL_PAID` (`base_total_paid`),
  KEY `SALES_ORDER_GRID_GRAND_TOTAL` (`grand_total`),
  KEY `SALES_ORDER_GRID_TOTAL_PAID` (`total_paid`),
  KEY `SALES_ORDER_GRID_SHIPPING_NAME` (`shipping_name`),
  KEY `SALES_ORDER_GRID_BILLING_NAME` (`billing_name`),
  KEY `SALES_ORDER_GRID_CREATED_AT` (`created_at`),
  KEY `SALES_ORDER_GRID_CUSTOMER_ID` (`customer_id`),
  KEY `SALES_ORDER_GRID_UPDATED_AT` (`updated_at`),
  FULLTEXT KEY `FTI_65B9E9925EC58F0C7C2E2F6379C233E7` (`increment_id`,`billing_name`,`shipping_name`,`shipping_address`,`billing_address`,`customer_name`,`customer_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order Grid';


-- drakesterling_old.sales_order_status definition

CREATE TABLE `sales_order_status` (
  `status` varchar(32) NOT NULL COMMENT 'Status',
  `label` varchar(128) NOT NULL COMMENT 'Label',
  PRIMARY KEY (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Order Status Table';


-- drakesterling_old.sales_order_status_data_exporter_cl definition

CREATE TABLE `sales_order_status_data_exporter_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` varchar(32) NOT NULL DEFAULT '' COMMENT 'Order status',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='sales_order_status_data_exporter_cl';


-- drakesterling_old.sales_order_tax definition

CREATE TABLE `sales_order_tax` (
  `tax_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Tax ID',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `code` varchar(255) DEFAULT NULL COMMENT 'Code',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `percent` decimal(12,4) DEFAULT NULL COMMENT 'Percent',
  `amount` decimal(20,4) DEFAULT NULL COMMENT 'Amount',
  `priority` int(11) NOT NULL COMMENT 'Priority',
  `position` int(11) NOT NULL COMMENT 'Position',
  `base_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount',
  `process` smallint(6) NOT NULL COMMENT 'Process',
  `base_real_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Real Amount',
  PRIMARY KEY (`tax_id`),
  KEY `SALES_ORDER_TAX_ORDER_ID_PRIORITY_POSITION` (`order_id`,`priority`,`position`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='Sales Order Tax Table';


-- drakesterling_old.sales_sequence_meta definition

CREATE TABLE `sales_sequence_meta` (
  `meta_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `entity_type` varchar(32) NOT NULL COMMENT 'Prefix',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `sequence_table` varchar(64) NOT NULL COMMENT 'table for sequence',
  PRIMARY KEY (`meta_id`),
  UNIQUE KEY `SALES_SEQUENCE_META_ENTITY_TYPE_STORE_ID` (`entity_type`,`store_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='sales_sequence_meta';


-- drakesterling_old.sales_shipment_grid definition

CREATE TABLE `sales_shipment_grid` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_increment_id` varchar(32) NOT NULL COMMENT 'Order Increment ID',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `order_created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Order Increment ID',
  `customer_name` varchar(128) NOT NULL COMMENT 'Customer Name',
  `total_qty` decimal(12,4) DEFAULT NULL COMMENT 'Total Qty',
  `shipment_status` int(11) DEFAULT NULL COMMENT 'Shipment Status',
  `order_status` varchar(32) DEFAULT NULL COMMENT 'Order',
  `billing_address` varchar(255) DEFAULT NULL COMMENT 'Billing Address',
  `shipping_address` varchar(255) DEFAULT NULL COMMENT 'Shipping Address',
  `billing_name` varchar(128) DEFAULT NULL COMMENT 'Billing Name',
  `shipping_name` varchar(128) DEFAULT NULL COMMENT 'Shipping Name',
  `customer_email` varchar(128) DEFAULT NULL COMMENT 'Customer Email',
  `customer_group_id` int(11) DEFAULT NULL,
  `payment_method` varchar(32) DEFAULT NULL COMMENT 'Payment Method',
  `shipping_information` varchar(255) DEFAULT NULL COMMENT 'Shipping Method Name',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_SHIPMENT_GRID_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_SHIPMENT_GRID_STORE_ID` (`store_id`),
  KEY `SALES_SHIPMENT_GRID_TOTAL_QTY` (`total_qty`),
  KEY `SALES_SHIPMENT_GRID_ORDER_INCREMENT_ID` (`order_increment_id`),
  KEY `SALES_SHIPMENT_GRID_SHIPMENT_STATUS` (`shipment_status`),
  KEY `SALES_SHIPMENT_GRID_ORDER_STATUS` (`order_status`),
  KEY `SALES_SHIPMENT_GRID_CREATED_AT` (`created_at`),
  KEY `SALES_SHIPMENT_GRID_UPDATED_AT` (`updated_at`),
  KEY `SALES_SHIPMENT_GRID_ORDER_CREATED_AT` (`order_created_at`),
  KEY `SALES_SHIPMENT_GRID_SHIPPING_NAME` (`shipping_name`),
  KEY `SALES_SHIPMENT_GRID_BILLING_NAME` (`billing_name`),
  KEY `SALES_SHIPMENT_GRID_ORDER_ID` (`order_id`),
  FULLTEXT KEY `FTI_086B40C8955F167B8EA76653437879B4` (`increment_id`,`order_increment_id`,`shipping_name`,`customer_name`,`customer_email`,`billing_address`,`shipping_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Shipment Grid';


-- drakesterling_old.salesrule definition

CREATE TABLE `salesrule` (
  `rule_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `description` text COMMENT 'Description',
  `from_date` date DEFAULT NULL COMMENT 'From',
  `to_date` date DEFAULT NULL COMMENT 'To',
  `uses_per_customer` int(11) NOT NULL DEFAULT '0' COMMENT 'Uses Per Customer',
  `is_active` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Active',
  `conditions_serialized` mediumtext COMMENT 'Conditions Serialized',
  `actions_serialized` mediumtext COMMENT 'Actions Serialized',
  `stop_rules_processing` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Stop Rules Processing',
  `is_advanced` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Advanced',
  `product_ids` text COMMENT 'Product Ids',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `simple_action` varchar(32) DEFAULT NULL COMMENT 'Simple Action',
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount',
  `discount_qty` decimal(12,4) DEFAULT NULL COMMENT 'Discount Qty',
  `discount_step` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Discount Step',
  `apply_to_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Apply To Shipping',
  `times_used` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Times Used',
  `is_rss` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Is Rss',
  `coupon_type` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Coupon Type',
  `use_auto_generation` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Use Auto Generation',
  `uses_per_coupon` int(11) NOT NULL DEFAULT '0' COMMENT 'User Per Coupon',
  `simple_free_shipping` smallint(5) unsigned DEFAULT NULL COMMENT 'Simple Free Shipping',
  PRIMARY KEY (`rule_id`),
  KEY `SALESRULE_IS_ACTIVE_SORT_ORDER_TO_DATE_FROM_DATE` (`is_active`,`sort_order`,`to_date`,`from_date`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='Salesrule';


-- drakesterling_old.scconnector_google_feed_cl definition

CREATE TABLE `scconnector_google_feed_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=628828 DEFAULT CHARSET=utf8 COMMENT='scconnector_google_feed_cl';


-- drakesterling_old.scconnector_google_remove_cl definition

CREATE TABLE `scconnector_google_remove_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB AUTO_INCREMENT=154688 DEFAULT CHARSET=utf8 COMMENT='scconnector_google_remove_cl';


-- drakesterling_old.sendfriend_log definition

CREATE TABLE `sendfriend_log` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `ip` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer IP address',
  `time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Log time',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`log_id`),
  KEY `SENDFRIEND_LOG_IP` (`ip`),
  KEY `SENDFRIEND_LOG_TIME` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Send to friend function log storage table';


-- drakesterling_old.sequence_creditmemo_0 definition

CREATE TABLE `sequence_creditmemo_0` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_creditmemo_1 definition

CREATE TABLE `sequence_creditmemo_1` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_invoice_0 definition

CREATE TABLE `sequence_invoice_0` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_invoice_1 definition

CREATE TABLE `sequence_invoice_1` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB AUTO_INCREMENT=4291 DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_order_0 definition

CREATE TABLE `sequence_order_0` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_order_1 definition

CREATE TABLE `sequence_order_1` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB AUTO_INCREMENT=23752 DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_shipment_0 definition

CREATE TABLE `sequence_shipment_0` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- drakesterling_old.sequence_shipment_1 definition

CREATE TABLE `sequence_shipment_1` (
  `sequence_value` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`sequence_value`)
) ENGINE=InnoDB AUTO_INCREMENT=4011 DEFAULT CHARSET=latin1;


-- drakesterling_old.`session` definition

CREATE TABLE `session` (
  `session_id` varchar(255) NOT NULL COMMENT 'Session Id',
  `session_expires` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Date of Session Expiration',
  `session_data` mediumblob NOT NULL COMMENT 'Session Data',
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Database Sessions Storage';


-- drakesterling_old.setup_module definition

CREATE TABLE `setup_module` (
  `module` varchar(50) NOT NULL COMMENT 'Module',
  `schema_version` varchar(50) DEFAULT NULL COMMENT 'Schema Version',
  `data_version` varchar(50) DEFAULT NULL COMMENT 'Data Version',
  PRIMARY KEY (`module`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Module versions registry';


-- drakesterling_old.shipperhq_order_detail definition

CREATE TABLE `shipperhq_order_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` int(10) unsigned NOT NULL DEFAULT '0',
  `carrier_group_id` text NOT NULL COMMENT 'carrier group id',
  `carrier_type` text COMMENT 'Carrier Type',
  `carrier_id` text COMMENT 'Carrier ID',
  `carrier_group` text COMMENT 'Carrier Group',
  `carrier_group_detail` text COMMENT 'Carrier Group Detail',
  `carrier_group_html` text COMMENT 'Carrier Group Information Formatted',
  `dispatch_date` date DEFAULT NULL COMMENT 'Dispatch Date',
  `delivery_date` date DEFAULT NULL COMMENT 'Delivery Date',
  `time_slot` text COMMENT 'Time Slot',
  `pickup_location` text COMMENT 'Pickup Location',
  `pickup_location_id` text COMMENT 'Pickup Location ID',
  `pickup_latitude` text COMMENT 'Pickup Latitude',
  `pickup_longitude` text COMMENT 'Pickup Longitude',
  `pickup_email` text COMMENT 'Pickup Email',
  `pickup_contact` text COMMENT 'Pickup Contact Name',
  `pickup_email_option` text COMMENT 'Pickup Email Option',
  `delivery_comments` text COMMENT 'Delivery Comments',
  `destination_type` text COMMENT 'Destination Type',
  `liftgate_required` text COMMENT 'Liftgate Required',
  `notify_required` text COMMENT 'Notify Required',
  `inside_delivery` text COMMENT 'Inside Delivery',
  `freight_quote_id` text COMMENT 'Freight Quote ID',
  `customer_carrier` text COMMENT 'Customer Carrier',
  `customer_carrier_account` text COMMENT 'Customer Carrier Account Number',
  `customer_carrier_ph` text COMMENT 'Customer Carrier Phone Number',
  `address_valid` text COMMENT 'Address Valid Status',
  `limited_delivery` varchar(10) DEFAULT NULL COMMENT 'Limited Delivery',
  `validated_shipping_street` varchar(255) DEFAULT NULL COMMENT 'Validated Shipping Street',
  `validated_shipping_street2` varchar(255) DEFAULT NULL COMMENT 'Validated Shipping Street 2',
  `validated_shipping_city` varchar(40) DEFAULT NULL COMMENT 'Validated Shipping City',
  `validated_shipping_postcode` varchar(20) DEFAULT NULL COMMENT 'Validated Shipping Postcode',
  `validated_shipping_region` varchar(40) DEFAULT NULL COMMENT 'Validated Shipping Region',
  `validated_shipping_country` varchar(30) DEFAULT NULL COMMENT 'Validated Shipping Country',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_ORDER_DETAIL_ORDER_ID` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Order Carrier Group Information';


-- drakesterling_old.shipperhq_order_detail_grid definition

CREATE TABLE `shipperhq_order_detail_grid` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` int(10) unsigned NOT NULL DEFAULT '0',
  `carrier_group` varchar(255) DEFAULT '',
  `dispatch_date` date DEFAULT NULL COMMENT 'Dispatch Date',
  `delivery_date` date DEFAULT NULL COMMENT 'Delivery Date',
  `time_slot` text COMMENT 'Time Slot',
  `pickup_location` text COMMENT 'Pickup Location',
  `delivery_comments` text COMMENT 'Delivery Comments',
  `destination_type` text COMMENT 'Destination Type',
  `liftgate_required` text COMMENT 'Liftgate Required',
  `notify_required` text COMMENT 'Notify Required',
  `inside_delivery` text COMMENT 'Inside Delivery',
  `address_valid` text COMMENT 'Address Valid Status',
  `carrier_type` varchar(255) DEFAULT NULL COMMENT 'Carrier Type',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_ORDER_DETAIL_GRID_ORDER_ID` (`order_id`),
  KEY `SHIPPERHQ_ORDER_DETAIL_GRID_CARRIER_GROUP` (`carrier_group`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Order Grid Information';


-- drakesterling_old.shipperhq_order_item_detail definition

CREATE TABLE `shipperhq_order_item_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_item_id` varchar(50) NOT NULL DEFAULT '',
  `carrier_group_id` text NOT NULL COMMENT 'carrier group id',
  `carrier_group` text COMMENT 'Carrier Group',
  `carrier_group_shipping` text COMMENT 'Shipping Details',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_ORDER_ITEM_DETAIL_ORDER_ITEM_ID` (`order_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Order Item Carrier Group Information';


-- drakesterling_old.shipperhq_order_packages definition

CREATE TABLE `shipperhq_order_packages` (
  `package_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Package_id',
  `order_id` int(10) unsigned NOT NULL DEFAULT '0',
  `carrier_group_id` text NOT NULL COMMENT 'Carrier Group ID',
  `carrier_code` text NOT NULL COMMENT 'Carrier Code',
  `package_name` text NOT NULL COMMENT 'Package Name',
  `length` float DEFAULT NULL COMMENT 'Package length',
  `width` float DEFAULT NULL COMMENT 'Package width',
  `height` float DEFAULT NULL COMMENT 'Package height',
  `weight` float DEFAULT NULL COMMENT 'Package weight',
  `declared_value` float DEFAULT NULL COMMENT 'Package declared value',
  `surcharge_price` float DEFAULT NULL COMMENT 'Surcharge price',
  PRIMARY KEY (`package_id`),
  KEY `SHIPPERHQ_ORDER_PACKAGES_ORDER_ID` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Address Package Information';


-- drakesterling_old.shipperhq_quote_address_detail definition

CREATE TABLE `shipperhq_quote_address_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `quote_address_id` varchar(50) NOT NULL DEFAULT '',
  `carrier_group_id` text NOT NULL COMMENT 'carrier group id',
  `carrier_type` text COMMENT 'Carrier Type',
  `carrier_id` text COMMENT 'Carrier ID',
  `carrier_group` text COMMENT 'Carrier Group',
  `carrier_group_detail` text COMMENT 'Carrier Group Detail',
  `carrier_group_html` text COMMENT 'Carrier Group Information Formatted',
  `dispatch_date` date DEFAULT NULL COMMENT 'Dispatch Date',
  `delivery_date` date DEFAULT NULL COMMENT 'Delivery Date',
  `time_slot` text COMMENT 'Time Slot',
  `pickup_location` text COMMENT 'Pickup Location',
  `pickup_location_id` text COMMENT 'Pickup Location ID',
  `pickup_latitude` text COMMENT 'Pickup Latitude',
  `pickup_longitude` text COMMENT 'Pickup Longitude',
  `pickup_email` text COMMENT 'Pickup Email',
  `pickup_contact` text COMMENT 'Pickup Contact Name',
  `pickup_email_option` text COMMENT 'Pickup Email Option',
  `is_checkout` text COMMENT 'Checkout flag',
  `delivery_comments` text COMMENT 'Delivery Comments',
  `destination_type` text COMMENT 'Destination Type',
  `liftgate_required` text COMMENT 'Liftgate Required',
  `notify_required` text COMMENT 'Notify Required',
  `inside_delivery` text COMMENT 'Inside Delivery',
  `freight_quote_id` text COMMENT 'Freight Quote ID',
  `customer_carrier` text COMMENT 'Customer Carrier',
  `customer_carrier_account` text COMMENT 'Customer Carrier Account Number',
  `customer_carrier_ph` text COMMENT 'Customer Carrier Phone Number',
  `address_valid` text COMMENT 'Address Valid Status',
  `limited_delivery` varchar(10) DEFAULT NULL COMMENT 'Limited Delivery',
  `validated_shipping_street` varchar(255) DEFAULT NULL COMMENT 'Validated Shipping Street',
  `validated_shipping_street2` varchar(255) DEFAULT NULL COMMENT 'Validated Shipping Street 2',
  `validated_shipping_city` varchar(40) DEFAULT NULL COMMENT 'Validated Shipping City',
  `validated_shipping_postcode` varchar(20) DEFAULT NULL COMMENT 'Validated Shipping Postcode',
  `validated_shipping_region` varchar(40) DEFAULT NULL COMMENT 'Validated Shipping Region',
  `validated_shipping_country` varchar(30) DEFAULT NULL COMMENT 'Validated Shipping Country',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_QUOTE_ADDRESS_DETAIL_QUOTE_ADDRESS_ID` (`quote_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Carrier Group Information';


-- drakesterling_old.shipperhq_quote_address_item_detail definition

CREATE TABLE `shipperhq_quote_address_item_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `quote_address_item_id` varchar(50) NOT NULL DEFAULT '',
  `carrier_group_id` text NOT NULL COMMENT 'carrier group id',
  `carrier_group` text COMMENT 'Carrier Group',
  `carrier_group_shipping` text COMMENT 'Shipping Details',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_QUOTE_ADDRESS_ITEM_DETAIL_QUOTE_ADDRESS_ITEM_ID` (`quote_address_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Address Item Carrier Group Information';


-- drakesterling_old.shipperhq_quote_item_detail definition

CREATE TABLE `shipperhq_quote_item_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `quote_item_id` varchar(50) NOT NULL DEFAULT '',
  `carrier_group_id` text NOT NULL COMMENT 'carrier group id',
  `carrier_group` text COMMENT 'Carrier Group',
  `carrier_group_shipping` text COMMENT 'Shipping Details',
  PRIMARY KEY (`id`),
  KEY `SHIPPERHQ_QUOTE_ITEM_DETAIL_QUOTE_ITEM_ID` (`quote_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Item Carrier Group Information';


-- drakesterling_old.shipperhq_quote_packages definition

CREATE TABLE `shipperhq_quote_packages` (
  `package_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Package_id',
  `quote_address_id` varchar(50) NOT NULL DEFAULT '',
  `carrier_group_id` text NOT NULL COMMENT 'Carrier Group ID',
  `carrier_code` text NOT NULL COMMENT 'Carrier Code',
  `package_name` text NOT NULL COMMENT 'Package Name',
  `length` float DEFAULT NULL COMMENT 'Package length',
  `width` float DEFAULT NULL COMMENT 'Package width',
  `height` float DEFAULT NULL COMMENT 'Package height',
  `weight` float DEFAULT NULL COMMENT 'Package weight',
  `declared_value` float DEFAULT NULL COMMENT 'Package declared value',
  `surcharge_price` float DEFAULT NULL COMMENT 'Surcharge price',
  PRIMARY KEY (`package_id`),
  KEY `SHIPPERHQ_QUOTE_PACKAGES_QUOTE_ADDRESS_ID` (`quote_address_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Address Package Information';


-- drakesterling_old.shipperhq_synchronize definition

CREATE TABLE `shipperhq_synchronize` (
  `synch_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Synch ID',
  `attribute_code` text NOT NULL COMMENT 'Attribute code',
  `attribute_type` text NOT NULL COMMENT 'Type of synch data',
  `value` text COMMENT 'Synchronize data value',
  `status` text NOT NULL COMMENT 'Synch status',
  `date_added` datetime NOT NULL COMMENT 'Synch entry date stamp',
  PRIMARY KEY (`synch_id`),
  KEY `SHIPPERHQ_SYNCHRONIZE_SYNCH_ID` (`synch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Synchronize data table';


-- drakesterling_old.shipping_tablerate definition

CREATE TABLE `shipping_tablerate` (
  `pk` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `website_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `dest_country_id` varchar(4) NOT NULL DEFAULT '0' COMMENT 'Destination coutry ISO/2 or ISO/3 code',
  `dest_region_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Destination Region ID',
  `dest_zip` varchar(10) NOT NULL DEFAULT '*' COMMENT 'Destination Post Code (Zip)',
  `condition_name` varchar(30) NOT NULL COMMENT 'Rate Condition name',
  `condition_value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Rate condition value',
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `cost` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Cost',
  PRIMARY KEY (`pk`),
  UNIQUE KEY `UNQ_D60821CDB2AFACEE1566CFC02D0D4CAA` (`website_id`,`dest_country_id`,`dest_region_id`,`dest_zip`,`condition_name`,`condition_value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Shipping Tablerate';


-- drakesterling_old.shqlogger_log definition

CREATE TABLE `shqlogger_log` (
  `notification_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Notification ID',
  `severity` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Severity',
  `date_added` datetime NOT NULL COMMENT 'Date added',
  `extension` text NOT NULL COMMENT 'Extension',
  `title` text NOT NULL COMMENT 'Log title',
  `description` text COMMENT 'Log description',
  `code` text COMMENT 'Code',
  `url` text COMMENT 'URL',
  `is_read` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Has been read',
  `is_remove` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'To be removed',
  PRIMARY KEY (`notification_id`),
  KEY `SHQLOGGER_LOG_SEVERITY` (`severity`),
  KEY `SHQLOGGER_LOG_IS_READ` (`is_read`),
  KEY `SHQLOGGER_LOG_IS_REMOVE` (`is_remove`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Logger data table';


-- drakesterling_old.smile_elasticsuite_notification_log definition

CREATE TABLE `smile_elasticsuite_notification_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `notification_code` varchar(50) NOT NULL COMMENT 'Viewer last view notification id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SMILE_ELASTICSUITE_NOTIFICATION_LOG_NOTIFICATION_CODE` (`notification_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Elasticsuite Notification Viewer Log Table';


-- drakesterling_old.smile_elasticsuite_optimizer definition

CREATE TABLE `smile_elasticsuite_optimizer` (
  `optimizer_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'Optimizer ID',
  `store_id` smallint(6) NOT NULL COMMENT 'Store id',
  `is_active` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'Is Optimizer Active',
  `from_date` date DEFAULT NULL COMMENT 'Enable rule from date',
  `to_date` date DEFAULT NULL COMMENT 'Enable rule to date',
  `name` text NOT NULL COMMENT 'Optimizer Name',
  `model` text COMMENT 'Optimizer model',
  `config` text COMMENT 'Optimizer serialized configuration',
  `rule_condition` text COMMENT 'Optimizer rule condition configuration',
  PRIMARY KEY (`optimizer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuite_relevance_config_data definition

CREATE TABLE `smile_elasticsuite_relevance_config_data` (
  `config_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Config Id',
  `scope` varchar(30) NOT NULL COMMENT 'Config Scope',
  `scope_code` varchar(30) NOT NULL COMMENT 'Config Scope Code',
  `path` varchar(255) NOT NULL COMMENT 'Config path',
  `value` text COMMENT 'Config value',
  PRIMARY KEY (`config_id`),
  UNIQUE KEY `SMILE_ELASTICSUITE_RELEVANCE_CONFIG_DATA_SCOPE_SCOPE_ID_PATH` (`scope`,`scope_code`,`path`),
  KEY `SMILE_ELASTICSUITE_RELEVANCE_CONFIG_DATA_SCOPE_SCOPE_CODE_PATH` (`scope`,`scope_code`,`path`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuite_thesaurus definition

CREATE TABLE `smile_elasticsuite_thesaurus` (
  `thesaurus_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Thesaurus ID',
  `name` text NOT NULL COMMENT 'Thesaurus name',
  `type` text NOT NULL COMMENT 'Thesaurus type',
  `is_active` smallint(6) NOT NULL DEFAULT '1' COMMENT 'If the Thesaurus is active',
  PRIMARY KEY (`thesaurus_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.store_data_exporter_cl definition

CREATE TABLE `store_data_exporter_cl` (
  `version_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Version ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  PRIMARY KEY (`version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='store_data_exporter_cl';


-- drakesterling_old.store_website definition

CREATE TABLE `store_website` (
  `website_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Website ID',
  `code` varchar(32) DEFAULT NULL COMMENT 'Code',
  `name` varchar(64) DEFAULT NULL COMMENT 'Website Name',
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `default_group_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Default Group ID',
  `is_default` smallint(5) unsigned DEFAULT '0' COMMENT 'Defines Is Website Default',
  PRIMARY KEY (`website_id`),
  UNIQUE KEY `STORE_WEBSITE_CODE` (`code`),
  KEY `STORE_WEBSITE_SORT_ORDER` (`sort_order`),
  KEY `STORE_WEBSITE_DEFAULT_GROUP_ID` (`default_group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Websites';


-- drakesterling_old.stores_data_exporter definition

CREATE TABLE `stores_data_exporter` (
  `id` int(10) unsigned NOT NULL COMMENT 'ID',
  `feed_data` mediumtext NOT NULL COMMENT 'Feed Data',
  `modified_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Modified At',
  PRIMARY KEY (`id`),
  KEY `STORES_DATA_EXPORTER_MODIFIED_AT` (`modified_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Stores Feed Storage';


-- drakesterling_old.stores_data_exporter_index_batches definition

CREATE TABLE `stores_data_exporter_index_batches` (
  `batch_number` int(11) NOT NULL COMMENT 'Batch Number',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website Id',
  PRIMARY KEY (`batch_number`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='stores_data_exporter_index_batches';


-- drakesterling_old.stores_data_exporter_index_sequence definition

CREATE TABLE `stores_data_exporter_index_sequence` (
  `i` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Auto Increment ID',
  PRIMARY KEY (`i`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='stores_data_exporter_index_sequence';


-- drakesterling_old.swissup_core_module definition

CREATE TABLE `swissup_core_module` (
  `code` varchar(50) NOT NULL COMMENT 'Code',
  `name` varchar(50) DEFAULT NULL COMMENT 'Package Name',
  `description` varchar(255) DEFAULT NULL COMMENT 'Package Description',
  `keywords` varchar(255) DEFAULT NULL COMMENT 'Keywords',
  `data_version` varchar(50) DEFAULT NULL COMMENT 'Data_version',
  `identity_key` varchar(255) DEFAULT NULL COMMENT 'Identity_key',
  `store_ids` varchar(64) DEFAULT NULL COMMENT 'Store_ids',
  `type` varchar(32) DEFAULT NULL COMMENT 'Package Type',
  `version` varchar(50) DEFAULT NULL COMMENT 'Version',
  `latest_version` varchar(50) DEFAULT NULL COMMENT 'Latest Version',
  `release_date` datetime DEFAULT NULL COMMENT 'Release Date',
  `link` varchar(255) DEFAULT NULL COMMENT 'Module Homepage',
  `download_link` varchar(255) DEFAULT NULL COMMENT 'Module Download Link',
  `identity_key_link` varchar(255) DEFAULT NULL COMMENT 'Identity Key Link',
  PRIMARY KEY (`code`),
  FULLTEXT KEY `SWISSUP_CORE_MODULE_CODE_NAME_DESCRIPTION_KEYWORDS` (`code`,`name`,`description`,`keywords`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='swissup_core_module';


-- drakesterling_old.tax_calculation_rate definition

CREATE TABLE `tax_calculation_rate` (
  `tax_calculation_rate_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Tax Calculation Rate ID',
  `tax_country_id` varchar(2) NOT NULL COMMENT 'Tax Country ID',
  `tax_region_id` int(11) NOT NULL COMMENT 'Tax Region ID',
  `tax_postcode` varchar(21) DEFAULT NULL COMMENT 'Tax Postcode',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `rate` decimal(12,4) NOT NULL COMMENT 'Rate',
  `zip_is_range` smallint(6) DEFAULT NULL COMMENT 'Zip Is Range',
  `zip_from` int(10) unsigned DEFAULT NULL COMMENT 'Zip From',
  `zip_to` int(10) unsigned DEFAULT NULL COMMENT 'Zip To',
  PRIMARY KEY (`tax_calculation_rate_id`),
  KEY `TAX_CALCULATION_RATE_TAX_COUNTRY_ID_TAX_REGION_ID_TAX_POSTCODE` (`tax_country_id`,`tax_region_id`,`tax_postcode`),
  KEY `TAX_CALCULATION_RATE_CODE` (`code`),
  KEY `IDX_CA799F1E2CB843495F601E56C84A626D` (`tax_calculation_rate_id`,`tax_country_id`,`tax_region_id`,`zip_is_range`,`tax_postcode`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Tax Calculation Rate';


-- drakesterling_old.tax_calculation_rule definition

CREATE TABLE `tax_calculation_rule` (
  `tax_calculation_rule_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Tax Calculation Rule ID',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `priority` int(11) NOT NULL COMMENT 'Priority',
  `position` int(11) NOT NULL COMMENT 'Position',
  `calculate_subtotal` int(11) NOT NULL COMMENT 'Calculate off subtotal option',
  PRIMARY KEY (`tax_calculation_rule_id`),
  KEY `TAX_CALCULATION_RULE_PRIORITY_POSITION` (`priority`,`position`),
  KEY `TAX_CALCULATION_RULE_CODE` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tax Calculation Rule';


-- drakesterling_old.tax_class definition

CREATE TABLE `tax_class` (
  `class_id` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'Class ID',
  `class_name` varchar(255) NOT NULL COMMENT 'Class Name',
  `class_type` varchar(8) NOT NULL DEFAULT 'CUSTOMER' COMMENT 'Class Type',
  PRIMARY KEY (`class_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COMMENT='Tax Class';


-- drakesterling_old.theme definition

CREATE TABLE `theme` (
  `theme_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Theme identifier',
  `parent_id` int(11) DEFAULT NULL COMMENT 'Parent ID',
  `theme_path` varchar(255) DEFAULT NULL COMMENT 'Theme Path',
  `theme_title` varchar(255) NOT NULL COMMENT 'Theme Title',
  `preview_image` varchar(255) DEFAULT NULL COMMENT 'Preview Image',
  `is_featured` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is Theme Featured',
  `area` varchar(255) NOT NULL COMMENT 'Theme Area',
  `type` smallint(6) NOT NULL COMMENT 'Theme type: 0:physical, 1:virtual, 2:staging',
  `code` text COMMENT 'Full theme code, including package',
  PRIMARY KEY (`theme_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COMMENT='Core theme';


-- drakesterling_old.url_rewrite definition

CREATE TABLE `url_rewrite` (
  `url_rewrite_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rewrite ID',
  `entity_type` varchar(32) NOT NULL COMMENT 'Entity type code',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `request_path` varchar(255) DEFAULT NULL COMMENT 'Request Path',
  `target_path` varchar(255) DEFAULT NULL COMMENT 'Target Path',
  `redirect_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Redirect Type',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `description` varchar(255) DEFAULT NULL COMMENT 'Description',
  `is_autogenerated` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is rewrite generated automatically flag',
  `metadata` varchar(255) DEFAULT NULL COMMENT 'Meta data for url rewrite',
  PRIMARY KEY (`url_rewrite_id`),
  UNIQUE KEY `URL_REWRITE_REQUEST_PATH_STORE_ID` (`request_path`,`store_id`),
  KEY `URL_REWRITE_TARGET_PATH` (`target_path`),
  KEY `URL_REWRITE_STORE_ID_ENTITY_ID` (`store_id`,`entity_id`),
  KEY `URL_REWRITE_ENTITY_ID` (`entity_id`),
  KEY `URL_REWRITE_IS_AUTOGENERATED_METADATA` (`is_autogenerated`,`metadata`)
) ENGINE=InnoDB AUTO_INCREMENT=7286021 DEFAULT CHARSET=utf8 COMMENT='Url Rewrites';


-- drakesterling_old.variable definition

CREATE TABLE `variable` (
  `variable_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Variable ID',
  `code` varchar(255) DEFAULT NULL COMMENT 'Variable Code',
  `name` varchar(255) DEFAULT NULL COMMENT 'Variable Name',
  PRIMARY KEY (`variable_id`),
  UNIQUE KEY `VARIABLE_CODE` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Variables';


-- drakesterling_old.vertex_custom_option_flex_field definition

CREATE TABLE `vertex_custom_option_flex_field` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Map Entity ID',
  `option_id` int(10) unsigned NOT NULL COMMENT 'Customizable Option ID',
  `website_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `flex_field` text COMMENT 'Flexible Field ID',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `VERTEX_CUSTOM_OPTION_FLEX_FIELD_OPTION_ID_WEBSITE_ID` (`option_id`,`website_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customizable Option to Flex Field Map';


-- drakesterling_old.vertex_customer_code definition

CREATE TABLE `vertex_customer_code` (
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `customer_code` text COMMENT 'Customer Code for Vertex',
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_customer_code';


-- drakesterling_old.vertex_invoice_sent definition

CREATE TABLE `vertex_invoice_sent` (
  `invoice_id` int(10) unsigned NOT NULL COMMENT 'Invoice ID',
  `sent_to_vertex` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Invoice has been logged in Vertex',
  PRIMARY KEY (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_invoice_sent';


-- drakesterling_old.vertex_order_invoice_status definition

CREATE TABLE `vertex_order_invoice_status` (
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `sent_to_vertex` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Invoice has been logged in Vertex',
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_order_invoice_status';


-- drakesterling_old.vertex_sales_creditmemo_item_invoice_text_code definition

CREATE TABLE `vertex_sales_creditmemo_item_invoice_text_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Creditmemo Item ID',
  `invoice_text_code` varchar(100) NOT NULL COMMENT 'Invoice text code from Vertex',
  UNIQUE KEY `UNQ_4BC40DA748D7713ADA661D2DE1BCF161` (`item_id`,`invoice_text_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_creditmemo_item_invoice_text_code';


-- drakesterling_old.vertex_sales_creditmemo_item_tax_code definition

CREATE TABLE `vertex_sales_creditmemo_item_tax_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Creditmemo Item ID',
  `tax_code` varchar(100) NOT NULL COMMENT 'Invoice text code from Vertex',
  UNIQUE KEY `VERTEX_SALES_CREDITMEMO_ITEM_TAX_CODE_ITEM_ID_TAX_CODE` (`item_id`,`tax_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_creditmemo_item_tax_code';


-- drakesterling_old.vertex_sales_creditmemo_item_vertex_tax_code definition

CREATE TABLE `vertex_sales_creditmemo_item_vertex_tax_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Creditmemo Item ID',
  `vertex_tax_code` varchar(100) NOT NULL COMMENT 'Text code from Vertex',
  UNIQUE KEY `UNQ_31D7AADB3412BC7E7C1C98D5CC3A5D46` (`item_id`,`vertex_tax_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_creditmemo_item_vertex_tax_code';


-- drakesterling_old.vertex_sales_order_item_invoice_text_code definition

CREATE TABLE `vertex_sales_order_item_invoice_text_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Order Item ID',
  `invoice_text_code` varchar(100) NOT NULL COMMENT 'Invoice text code from Vertex',
  UNIQUE KEY `UNQ_96F6BE3160A4185CEA4D866018EAF6DC` (`item_id`,`invoice_text_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_order_item_invoice_text_code';


-- drakesterling_old.vertex_sales_order_item_tax_code definition

CREATE TABLE `vertex_sales_order_item_tax_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Order Item ID',
  `tax_code` varchar(100) NOT NULL COMMENT 'Invoice text code from Vertex',
  UNIQUE KEY `VERTEX_SALES_ORDER_ITEM_TAX_CODE_ITEM_ID_TAX_CODE` (`item_id`,`tax_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_order_item_tax_code';


-- drakesterling_old.vertex_sales_order_item_vertex_tax_code definition

CREATE TABLE `vertex_sales_order_item_vertex_tax_code` (
  `item_id` int(10) unsigned NOT NULL COMMENT 'Order Item ID',
  `vertex_tax_code` varchar(100) NOT NULL COMMENT 'Text code from Vertex',
  UNIQUE KEY `VERTEX_SALES_ORDER_ITEM_VERTEX_TAX_CODE_ITEM_ID_VERTEX_TAX_CODE` (`item_id`,`vertex_tax_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='vertex_sales_order_item_vertex_tax_code';


-- drakesterling_old.vertex_taxrequest definition

CREATE TABLE `vertex_taxrequest` (
  `request_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `request_type` varchar(255) NOT NULL COMMENT 'Request Type',
  `response_time` int(10) unsigned DEFAULT NULL COMMENT 'Milliseconds taken for Vertex API call to complete',
  `quote_id` bigint(20) DEFAULT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `total_tax` varchar(255) NOT NULL COMMENT 'Total Tax Amount',
  `source_path` varchar(255) NOT NULL COMMENT 'Source path controller_module_action',
  `tax_area_id` varchar(255) NOT NULL COMMENT 'Tax Jurisdictions Id',
  `sub_total` varchar(255) NOT NULL COMMENT 'Response Subtotal Amount',
  `total` varchar(255) NOT NULL COMMENT 'Response Total Amount',
  `lookup_result` varchar(255) NOT NULL COMMENT 'Tax Area Response Lookup Result',
  `request_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Request create date',
  `request_xml` text NOT NULL COMMENT 'Request XML',
  `response_xml` text NOT NULL COMMENT 'Response XML',
  PRIMARY KEY (`request_id`),
  UNIQUE KEY `VERTEX_TAXREQUEST_REQUEST_ID` (`request_id`),
  KEY `VERTEX_TAXREQUEST_REQUEST_TYPE` (`request_type`),
  KEY `VERTEX_TAXREQUEST_ORDER_ID` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Log of requests to Vertex';


-- drakesterling_old.webshopapps_matrixrate definition

CREATE TABLE `webshopapps_matrixrate` (
  `pk` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary key',
  `website_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Website Id',
  `dest_country_id` varchar(4) NOT NULL DEFAULT '0' COMMENT 'Destination coutry ISO/2 or ISO/3 code',
  `dest_region_id` int(11) NOT NULL DEFAULT '0' COMMENT 'Destination Region Id',
  `dest_city` varchar(30) NOT NULL DEFAULT '' COMMENT 'Destination City',
  `dest_zip` varchar(10) NOT NULL DEFAULT '*' COMMENT 'Destination Post Code (Zip)',
  `dest_zip_to` varchar(10) NOT NULL DEFAULT '*' COMMENT 'Destination Post Code To (Zip)',
  `condition_name` varchar(20) NOT NULL COMMENT 'Rate Condition name',
  `condition_from_value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Rate condition from value',
  `condition_to_value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Rate condition to value',
  `price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `cost` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Cost',
  `shipping_method` varchar(255) NOT NULL COMMENT 'Shipping Method',
  PRIMARY KEY (`pk`),
  UNIQUE KEY `UNQ_1F88ACC89F513C4E6FE1FEEAD343B921` (`website_id`,`dest_country_id`,`dest_region_id`,`dest_city`,`dest_zip`,`condition_name`,`condition_from_value`,`condition_to_value`,`shipping_method`)
) ENGINE=InnoDB AUTO_INCREMENT=4402 DEFAULT CHARSET=utf8 COMMENT='WebShopApps Shipping MatrixRate';


-- drakesterling_old.weltpixel_license definition

CREATE TABLE `weltpixel_license` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `module_name` varchar(255) DEFAULT NULL COMMENT 'Module Name',
  `license_key` text COMMENT 'License Key',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='WeltPixel License';


-- drakesterling_old.wesupply_orders definition

CREATE TABLE `wesupply_orders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Order id',
  `order_number` text NOT NULL COMMENT 'Order Increment ID',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `info` longtext NOT NULL COMMENT 'Order Information',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store Id',
  `awaiting_update` tinyint(1) NOT NULL COMMENT 'Order was updated by ERP or other',
  `is_excluded` smallint(5) unsigned DEFAULT '0' COMMENT 'Order was excluded from export',
  PRIMARY KEY (`id`),
  KEY `WESUPPLY_ORDERS_UPDATED_AT` (`updated_at`),
  KEY `WESUPPLY_ORDERS_STORE_ID` (`store_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='WeSupply Orders';


-- drakesterling_old.wesupply_returns_list definition

CREATE TABLE `wesupply_returns_list` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `return_reference` bigint(20) unsigned DEFAULT NULL COMMENT 'Return_reference',
  `status` text COMMENT 'Status',
  `refunded` tinyint(1) NOT NULL COMMENT 'Refunded',
  `creditmemo_id` text COMMENT 'Creditmemo_id',
  `request_log_id` text COMMENT 'Request_log_id',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='wesupply_returns_list';


-- drakesterling_old.widget definition

CREATE TABLE `widget` (
  `widget_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Widget ID',
  `widget_code` varchar(255) DEFAULT NULL COMMENT 'Widget code for template directive',
  `widget_type` varchar(255) DEFAULT NULL COMMENT 'Widget Type',
  `parameters` text COMMENT 'Parameters',
  PRIMARY KEY (`widget_id`),
  KEY `WIDGET_WIDGET_CODE` (`widget_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Preconfigured Widgets';


-- drakesterling_old.wk_ebay_categories definition

CREATE TABLE `wk_ebay_categories` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `ebay_cat_id` int(10) unsigned NOT NULL COMMENT 'Ebay Category Id',
  `ebay_cat_parentid` int(10) unsigned NOT NULL COMMENT 'Ebay parent Category Id',
  `ebay_cat_name` varchar(255) DEFAULT NULL COMMENT 'Ebay Category Name',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Category Mapped Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_CATEGORIES_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12311 DEFAULT CHARSET=utf8 COMMENT='Ebay Categories Table';


-- drakesterling_old.wk_ebay_inventory_manage definition

CREATE TABLE `wk_ebay_inventory_manage` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `ebay_pro_id` varchar(255) DEFAULT NULL COMMENT 'eBay Product Id',
  `status` int(11) DEFAULT NULL COMMENT 'Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'created time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_INVENTORY_MANAGE_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='eBay Inventory Manage';


-- drakesterling_old.wk_ebay_listing_template definition

CREATE TABLE `wk_ebay_listing_template` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `template_title` varchar(255) DEFAULT NULL COMMENT 'Template Title',
  `template_content` mediumtext COMMENT 'Product Content',
  `mapped_attribute` mediumtext COMMENT 'Mapped Attribute With Template Content',
  `status` int(10) unsigned NOT NULL COMMENT 'Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Template Create Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_LISTING_TEMPLATE_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='eBay Listing Template';


-- drakesterling_old.wk_ebay_missed_order definition

CREATE TABLE `wk_ebay_missed_order` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `order_id` varchar(255) DEFAULT NULL COMMENT 'Ebay Order Id',
  `status` varchar(255) DEFAULT NULL COMMENT 'Ebay Order Status',
  `error` mediumtext COMMENT 'Error during order create on store',
  `resynchronize_order` int(10) unsigned DEFAULT NULL COMMENT 'Resynchronize Order',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'sync time',
  PRIMARY KEY (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8 COMMENT='missed order list';


-- drakesterling_old.wk_ebay_product_pricerule definition

CREATE TABLE `wk_ebay_product_pricerule` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `price_from` int(11) DEFAULT NULL COMMENT 'Product Price From',
  `price_to` int(11) DEFAULT NULL COMMENT 'Product Price To',
  `sku` varchar(255) DEFAULT NULL COMMENT 'product sku',
  `operation` varchar(255) DEFAULT NULL COMMENT 'Product Price Operation',
  `price` int(11) DEFAULT NULL COMMENT 'Price',
  `operation_type` varchar(255) DEFAULT NULL COMMENT 'Product Operation Type ex. fixed/percent',
  `status` int(11) DEFAULT NULL COMMENT 'status of rule',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'rule created time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_PRODUCT_PRICERULE_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='eBay Product Price Rule';


-- drakesterling_old.wk_ebay_tempebay definition

CREATE TABLE `wk_ebay_tempebay` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `item_type` varchar(255) DEFAULT NULL COMMENT 'Idenityfy that order or product',
  `item_id` varchar(255) DEFAULT NULL COMMENT 'eBay Item Id',
  `product_data` text COMMENT 'eBay item data in json format',
  `associate_products` text COMMENT 'Configurable Associates Products',
  `total_associate` int(10) unsigned NOT NULL COMMENT 'Total Associate Products Count',
  `error` varchar(255) DEFAULT NULL COMMENT 'Error report',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Import Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_TEMPEBAY_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='eBay imported products temp table';


-- drakesterling_old.wk_ebaysynchronize_category_specification definition

CREATE TABLE `wk_ebaysynchronize_category_specification` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `ebay_category_id` int(10) unsigned NOT NULL COMMENT 'Ebay Category Id',
  `ebay_specification_name` varchar(255) DEFAULT NULL COMMENT 'eBay Specification Name',
  `mage_product_attribute_code` varchar(255) DEFAULT NULL COMMENT 'Magento Product Attribute Code',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Specification Sync Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_CATEGORY_SPECIFICATION_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8 COMMENT='eBay Synchronize Category Specifications Table';


-- drakesterling_old.wk_ebaysynchronize_order definition

CREATE TABLE `wk_ebaysynchronize_order` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `ebay_order_id` varchar(255) DEFAULT NULL COMMENT 'Ebay Order Id',
  `mage_order_id` varchar(255) DEFAULT NULL COMMENT 'Magento Order Id',
  `status` varchar(255) DEFAULT NULL COMMENT 'Order Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Order Sync Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_ORDER_ENTITY_ID` (`entity_id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8 COMMENT='Ebay Synchronize Order Table';


-- drakesterling_old.yotpo_order_status_history definition

CREATE TABLE `yotpo_order_status_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `order_id` int(10) unsigned DEFAULT NULL COMMENT 'Order Id',
  `store_id` int(10) unsigned DEFAULT NULL COMMENT 'Store Id',
  `old_status` varchar(32) DEFAULT NULL COMMENT 'Old Status',
  `new_status` varchar(32) DEFAULT NULL COMMENT 'New Status',
  `created_at` datetime DEFAULT NULL COMMENT 'Created At',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2447 DEFAULT CHARSET=utf8 COMMENT='yotpo_order_status_history';


-- drakesterling_old.yotpo_rich_snippets definition

CREATE TABLE `yotpo_rich_snippets` (
  `rich_snippet_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `product_id` int(11) NOT NULL COMMENT 'Product Id',
  `store_id` int(11) NOT NULL COMMENT 'Store Id',
  `average_score` decimal(10,2) NOT NULL COMMENT 'Average Score',
  `reviews_count` float NOT NULL COMMENT 'Reviews Count',
  `expiration_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Expiry Time',
  PRIMARY KEY (`rich_snippet_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='yotpo_rich_snippets';


-- drakesterling_old.yotpo_sync definition

CREATE TABLE `yotpo_sync` (
  `sync_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `store_id` int(10) unsigned DEFAULT NULL COMMENT 'Store Id',
  `entity_type` varchar(50) DEFAULT NULL COMMENT 'Entity Type',
  `entity_id` int(10) unsigned DEFAULT NULL COMMENT 'Entity Id',
  `sync_flag` smallint(6) DEFAULT '0' COMMENT 'Sync Flag',
  `sync_date` datetime NOT NULL COMMENT 'Sync Date',
  PRIMARY KEY (`sync_id`),
  UNIQUE KEY `YOTPO_SYNC_STORE_ID_ENTITY_TYPE_ENTITY_ID` (`store_id`,`entity_type`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='yotpo_sync';


-- drakesterling_old.admin_adobe_ims_webapi definition

CREATE TABLE `admin_adobe_ims_webapi` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `admin_user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Admin User Id',
  `access_token_hash` varchar(255) DEFAULT NULL COMMENT 'Access Token Hash',
  `access_token` text COMMENT 'Access Token',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `last_check_time` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Last check time',
  `access_token_expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Access Token Expires At',
  PRIMARY KEY (`id`),
  UNIQUE KEY `ADMIN_ADOBE_IMS_WEBAPI_ACCESS_TOKEN_HASH` (`access_token_hash`),
  KEY `ADMIN_ADOBE_IMS_WEBAPI_ADMIN_USER_ID` (`admin_user_id`),
  CONSTRAINT `ADMIN_ADOBE_IMS_WEBAPI_ADMIN_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`admin_user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Admin Adobe IMS Webapi';


-- drakesterling_old.admin_passwords definition

CREATE TABLE `admin_passwords` (
  `password_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Password ID',
  `user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'User ID',
  `password_hash` varchar(255) DEFAULT NULL COMMENT 'Password Hash',
  `expires` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Deprecated',
  `last_updated` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Last Updated',
  PRIMARY KEY (`password_id`),
  KEY `ADMIN_PASSWORDS_USER_ID` (`user_id`),
  CONSTRAINT `ADMIN_PASSWORDS_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=utf8 COMMENT='Admin Passwords';


-- drakesterling_old.admin_user_expiration definition

CREATE TABLE `admin_user_expiration` (
  `user_id` int(10) unsigned NOT NULL COMMENT 'User ID',
  `expires_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'User Expiration Date',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `ADMIN_USER_EXPIRATION_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Admin User expiration dates table';


-- drakesterling_old.admin_user_session definition

CREATE TABLE `admin_user_session` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `session_id` varchar(1) DEFAULT NULL COMMENT 'Deprecated: Session ID value no longer used',
  `user_id` int(10) unsigned DEFAULT NULL COMMENT 'Admin User ID',
  `status` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Current Session status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  `ip` varchar(15) NOT NULL COMMENT 'Remote user IP',
  PRIMARY KEY (`id`),
  KEY `ADMIN_USER_SESSION_SESSION_ID` (`session_id`),
  KEY `ADMIN_USER_SESSION_USER_ID` (`user_id`),
  CONSTRAINT `ADMIN_USER_SESSION_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2532 DEFAULT CHARSET=utf8 COMMENT='Admin User sessions table';


-- drakesterling_old.adobe_stock_asset definition

CREATE TABLE `adobe_stock_asset` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `media_gallery_id` int(10) unsigned DEFAULT NULL COMMENT 'Media gallery ID',
  `category_id` int(10) unsigned DEFAULT NULL COMMENT 'Category ID',
  `creator_id` int(10) unsigned DEFAULT NULL COMMENT 'Creator ID',
  `is_licensed` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Licensed',
  `creation_date` varchar(255) DEFAULT NULL COMMENT 'Creation Date',
  PRIMARY KEY (`id`),
  KEY `ADOBE_STOCK_ASSET_MEDIA_GALLERY_ID_MEDIA_GALLERY_ASSET_ID` (`media_gallery_id`),
  KEY `ADOBE_STOCK_ASSET_ID` (`id`),
  KEY `ADOBE_STOCK_ASSET_CATEGORY_ID` (`category_id`),
  KEY `ADOBE_STOCK_ASSET_CREATOR_ID` (`creator_id`),
  CONSTRAINT `ADOBE_STOCK_ASSET_CATEGORY_ID_ADOBE_STOCK_CATEGORY_ID` FOREIGN KEY (`category_id`) REFERENCES `adobe_stock_category` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ADOBE_STOCK_ASSET_CREATOR_ID_ADOBE_STOCK_CREATOR_ID` FOREIGN KEY (`creator_id`) REFERENCES `adobe_stock_creator` (`id`) ON DELETE SET NULL,
  CONSTRAINT `ADOBE_STOCK_ASSET_MEDIA_GALLERY_ID_MEDIA_GALLERY_ASSET_ID` FOREIGN KEY (`media_gallery_id`) REFERENCES `media_gallery_asset` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Adobe Stock Asset';


-- drakesterling_old.adobe_user_profile definition

CREATE TABLE `adobe_user_profile` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `admin_user_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Admin User Id',
  `name` varchar(255) NOT NULL COMMENT 'Display Name',
  `email` varchar(255) NOT NULL COMMENT 'user profile email',
  `image` varchar(255) NOT NULL COMMENT 'user profile avatar',
  `account_type` varchar(255) DEFAULT NULL COMMENT 'Account Type',
  `access_token` text COMMENT 'Access Token',
  `refresh_token` text COMMENT 'Refresh Token',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `access_token_expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' COMMENT 'Access Token Expires At',
  PRIMARY KEY (`id`),
  KEY `ADOBE_USER_PROFILE_ADMIN_USER_ID_ADMIN_USER_USER_ID` (`admin_user_id`),
  KEY `ADOBE_USER_PROFILE_ID` (`id`),
  KEY `ADOBE_USER_PROFILE_ADMIN_USER_ID` (`admin_user_id`),
  CONSTRAINT `ADOBE_USER_PROFILE_ADMIN_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`admin_user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Adobe IMS User Profile';


-- drakesterling_old.authorization_rule definition

CREATE TABLE `authorization_rule` (
  `rule_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule ID',
  `role_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Role ID',
  `resource_id` varchar(255) DEFAULT NULL COMMENT 'Resource ID',
  `privileges` varchar(20) DEFAULT NULL COMMENT 'Privileges',
  `permission` varchar(10) DEFAULT NULL COMMENT 'Permission',
  PRIMARY KEY (`rule_id`),
  KEY `AUTHORIZATION_RULE_RESOURCE_ID_ROLE_ID` (`resource_id`,`role_id`),
  KEY `AUTHORIZATION_RULE_ROLE_ID_RESOURCE_ID` (`role_id`,`resource_id`),
  CONSTRAINT `AUTHORIZATION_RULE_ROLE_ID_AUTHORIZATION_ROLE_ROLE_ID` FOREIGN KEY (`role_id`) REFERENCES `authorization_role` (`role_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=216171 DEFAULT CHARSET=utf8 COMMENT='Admin Rule Table';


-- drakesterling_old.catalog_category_product definition

CREATE TABLE `catalog_category_product` (
  `entity_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`entity_id`,`category_id`,`product_id`),
  UNIQUE KEY `CATALOG_CATEGORY_PRODUCT_CATEGORY_ID_PRODUCT_ID` (`category_id`,`product_id`),
  KEY `CATALOG_CATEGORY_PRODUCT_PRODUCT_ID` (`product_id`),
  KEY `category_id_indexed_name` (`category_id`,`product_id`),
  CONSTRAINT `CAT_CTGR_PRD_CTGR_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_PRD_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=599439 DEFAULT CHARSET=utf8 COMMENT='Catalog Product To Category Linkage Table';


-- drakesterling_old.catalog_product_bundle_option definition

CREATE TABLE `catalog_product_bundle_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `required` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Required',
  `position` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Position',
  `type` varchar(255) DEFAULT NULL COMMENT 'Type',
  PRIMARY KEY (`option_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_OPTION_PARENT_ID` (`parent_id`),
  CONSTRAINT `CAT_PRD_BNDL_OPT_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Option';


-- drakesterling_old.catalog_product_bundle_option_value definition

CREATE TABLE `catalog_product_bundle_option_value` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `option_id` int(10) unsigned NOT NULL COMMENT 'Option ID',
  `parent_product_id` int(10) unsigned NOT NULL COMMENT 'Parent Product ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CAT_PRD_BNDL_OPT_VAL_OPT_ID_PARENT_PRD_ID_STORE_ID` (`option_id`,`parent_product_id`,`store_id`),
  CONSTRAINT `CAT_PRD_BNDL_OPT_VAL_OPT_ID_CAT_PRD_BNDL_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_bundle_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Option Value';


-- drakesterling_old.catalog_product_bundle_price_index definition

CREATE TABLE `catalog_product_bundle_price_index` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `min_price` decimal(20,6) NOT NULL COMMENT 'Min Price',
  `max_price` decimal(20,6) NOT NULL COMMENT 'Max Price',
  PRIMARY KEY (`entity_id`,`website_id`,`customer_group_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_PRICE_INDEX_WEBSITE_ID` (`website_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_PRICE_INDEX_CUSTOMER_GROUP_ID` (`customer_group_id`),
  CONSTRAINT `CAT_PRD_BNDL_PRICE_IDX_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_BNDL_PRICE_IDX_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_BNDL_PRICE_IDX_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Price Index';


-- drakesterling_old.catalog_product_bundle_selection definition

CREATE TABLE `catalog_product_bundle_selection` (
  `selection_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Selection ID',
  `option_id` int(10) unsigned NOT NULL COMMENT 'Option ID',
  `parent_product_id` int(10) unsigned NOT NULL COMMENT 'Parent Product ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `position` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Position',
  `is_default` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Default',
  `selection_price_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Selection Price Type',
  `selection_price_value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Selection Price Value',
  `selection_qty` decimal(12,4) DEFAULT NULL COMMENT 'Selection Qty',
  `selection_can_change_qty` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Selection Can Change Qty',
  PRIMARY KEY (`selection_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_SELECTION_OPTION_ID` (`option_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_SELECTION_PRODUCT_ID` (`product_id`),
  CONSTRAINT `CAT_PRD_BNDL_SELECTION_OPT_ID_CAT_PRD_BNDL_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_bundle_option` (`option_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_BNDL_SELECTION_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Selection';


-- drakesterling_old.catalog_product_bundle_selection_price definition

CREATE TABLE `catalog_product_bundle_selection_price` (
  `selection_id` int(10) unsigned NOT NULL COMMENT 'Selection ID',
  `parent_product_id` int(10) unsigned NOT NULL COMMENT 'Parent Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `selection_price_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Selection Price Type',
  `selection_price_value` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Selection Price Value',
  PRIMARY KEY (`selection_id`,`parent_product_id`,`website_id`),
  KEY `CATALOG_PRODUCT_BUNDLE_SELECTION_PRICE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CAT_PRD_BNDL_SELECTION_PRICE_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_DCF37523AA05D770A70AA4ED7C2616E4` FOREIGN KEY (`selection_id`) REFERENCES `catalog_product_bundle_selection` (`selection_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Bundle Selection Price';


-- drakesterling_old.catalog_product_entity_tier_price definition

CREATE TABLE `catalog_product_entity_tier_price` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `all_groups` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Applicable To All Customer Groups',
  `customer_group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer Group ID',
  `qty` decimal(12,4) NOT NULL DEFAULT '1.0000' COMMENT 'QTY',
  `value` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Value',
  `percentage_value` decimal(5,2) DEFAULT NULL COMMENT 'Percentage value',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `UNQ_E8AB433B9ACB00343ABB312AD2FAB087` (`entity_id`,`all_groups`,`customer_group_id`,`qty`,`website_id`),
  KEY `CATALOG_PRODUCT_ENTITY_TIER_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOG_PRODUCT_ENTITY_TIER_PRICE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CAT_PRD_ENTT_TIER_PRICE_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_TIER_PRICE_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_TIER_PRICE_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Tier Price Attribute Backend Table';


-- drakesterling_old.catalog_product_index_tier_price definition

CREATE TABLE `catalog_product_index_tier_price` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `min_price` decimal(20,6) DEFAULT NULL COMMENT 'Min Price',
  PRIMARY KEY (`entity_id`,`customer_group_id`,`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_TIER_PRICE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `CATALOG_PRODUCT_INDEX_TIER_PRICE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CAT_PRD_IDX_TIER_PRICE_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_IDX_TIER_PRICE_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_IDX_TIER_PRICE_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Tier Price Index Table';


-- drakesterling_old.catalog_product_index_website definition

CREATE TABLE `catalog_product_index_website` (
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `website_date` date DEFAULT NULL COMMENT 'Website Date',
  `rate` float DEFAULT '1' COMMENT 'Rate',
  `default_store_id` smallint(5) unsigned NOT NULL COMMENT 'Default store ID for website',
  PRIMARY KEY (`website_id`),
  KEY `CATALOG_PRODUCT_INDEX_WEBSITE_WEBSITE_DATE` (`website_date`),
  CONSTRAINT `CAT_PRD_IDX_WS_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Website Index Table';


-- drakesterling_old.catalog_product_link definition

CREATE TABLE `catalog_product_link` (
  `link_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Link ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `linked_product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Linked Product ID',
  `link_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Link Type ID',
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `CATALOG_PRODUCT_LINK_LINK_TYPE_ID_PRODUCT_ID_LINKED_PRODUCT_ID` (`link_type_id`,`product_id`,`linked_product_id`),
  KEY `CATALOG_PRODUCT_LINK_PRODUCT_ID` (`product_id`),
  KEY `CATALOG_PRODUCT_LINK_LINKED_PRODUCT_ID` (`linked_product_id`),
  CONSTRAINT `CATALOG_PRODUCT_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_LNK_LNKED_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`linked_product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_LNK_LNK_TYPE_ID_CAT_PRD_LNK_TYPE_LNK_TYPE_ID` FOREIGN KEY (`link_type_id`) REFERENCES `catalog_product_link_type` (`link_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product To Product Linkage Table';


-- drakesterling_old.catalog_product_link_attribute definition

CREATE TABLE `catalog_product_link_attribute` (
  `product_link_attribute_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Product Link Attribute ID',
  `link_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Link Type ID',
  `product_link_attribute_code` varchar(32) DEFAULT NULL COMMENT 'Product Link Attribute Code',
  `data_type` varchar(32) DEFAULT NULL COMMENT 'Data Type',
  PRIMARY KEY (`product_link_attribute_id`),
  KEY `CATALOG_PRODUCT_LINK_ATTRIBUTE_LINK_TYPE_ID` (`link_type_id`),
  CONSTRAINT `CAT_PRD_LNK_ATTR_LNK_TYPE_ID_CAT_PRD_LNK_TYPE_LNK_TYPE_ID` FOREIGN KEY (`link_type_id`) REFERENCES `catalog_product_link_type` (`link_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Link Attribute Table';


-- drakesterling_old.catalog_product_link_attribute_decimal definition

CREATE TABLE `catalog_product_link_attribute_decimal` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `product_link_attribute_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Product Link Attribute ID',
  `link_id` int(10) unsigned NOT NULL COMMENT 'Link ID',
  `value` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CAT_PRD_LNK_ATTR_DEC_PRD_LNK_ATTR_ID_LNK_ID` (`product_link_attribute_id`,`link_id`),
  KEY `CATALOG_PRODUCT_LINK_ATTRIBUTE_DECIMAL_LINK_ID` (`link_id`),
  CONSTRAINT `CAT_PRD_LNK_ATTR_DEC_LNK_ID_CAT_PRD_LNK_LNK_ID` FOREIGN KEY (`link_id`) REFERENCES `catalog_product_link` (`link_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_AB2EFA9A14F7BCF1D5400056203D14B6` FOREIGN KEY (`product_link_attribute_id`) REFERENCES `catalog_product_link_attribute` (`product_link_attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Link Decimal Attribute Table';


-- drakesterling_old.catalog_product_link_attribute_int definition

CREATE TABLE `catalog_product_link_attribute_int` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `product_link_attribute_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Product Link Attribute ID',
  `link_id` int(10) unsigned NOT NULL COMMENT 'Link ID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CAT_PRD_LNK_ATTR_INT_PRD_LNK_ATTR_ID_LNK_ID` (`product_link_attribute_id`,`link_id`),
  KEY `CATALOG_PRODUCT_LINK_ATTRIBUTE_INT_LINK_ID` (`link_id`),
  CONSTRAINT `CAT_PRD_LNK_ATTR_INT_LNK_ID_CAT_PRD_LNK_LNK_ID` FOREIGN KEY (`link_id`) REFERENCES `catalog_product_link` (`link_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_D6D878F8BA2A4282F8DDED7E6E3DE35C` FOREIGN KEY (`product_link_attribute_id`) REFERENCES `catalog_product_link_attribute` (`product_link_attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Link Integer Attribute Table';


-- drakesterling_old.catalog_product_link_attribute_varchar definition

CREATE TABLE `catalog_product_link_attribute_varchar` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `product_link_attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Product Link Attribute ID',
  `link_id` int(10) unsigned NOT NULL COMMENT 'Link ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CAT_PRD_LNK_ATTR_VCHR_PRD_LNK_ATTR_ID_LNK_ID` (`product_link_attribute_id`,`link_id`),
  KEY `CATALOG_PRODUCT_LINK_ATTRIBUTE_VARCHAR_LINK_ID` (`link_id`),
  CONSTRAINT `CAT_PRD_LNK_ATTR_VCHR_LNK_ID_CAT_PRD_LNK_LNK_ID` FOREIGN KEY (`link_id`) REFERENCES `catalog_product_link` (`link_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_DEE9C4DA61CFCC01DFCF50F0D79CEA51` FOREIGN KEY (`product_link_attribute_id`) REFERENCES `catalog_product_link_attribute` (`product_link_attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Link Varchar Attribute Table';


-- drakesterling_old.catalog_product_option definition

CREATE TABLE `catalog_product_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `type` varchar(50) DEFAULT NULL COMMENT 'Type',
  `is_require` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Is Required',
  `sku` varchar(64) DEFAULT NULL COMMENT 'SKU',
  `max_characters` int(10) unsigned DEFAULT NULL COMMENT 'Max Characters',
  `file_extension` varchar(50) DEFAULT NULL COMMENT 'File Extension',
  `image_size_x` smallint(5) unsigned DEFAULT NULL COMMENT 'Image Size X',
  `image_size_y` smallint(5) unsigned DEFAULT NULL COMMENT 'Image Size Y',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`option_id`),
  KEY `CATALOG_PRODUCT_OPTION_PRODUCT_ID` (`product_id`),
  CONSTRAINT `CAT_PRD_OPT_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Table';


-- drakesterling_old.catalog_product_option_type_value definition

CREATE TABLE `catalog_product_option_type_value` (
  `option_type_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option Type ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `sku` varchar(64) DEFAULT NULL COMMENT 'SKU',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`option_type_id`),
  KEY `CATALOG_PRODUCT_OPTION_TYPE_VALUE_OPTION_ID` (`option_id`),
  CONSTRAINT `CAT_PRD_OPT_TYPE_VAL_OPT_ID_CAT_PRD_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Type Value Table';


-- drakesterling_old.catalog_product_relation definition

CREATE TABLE `catalog_product_relation` (
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `child_id` int(10) unsigned NOT NULL COMMENT 'Child ID',
  PRIMARY KEY (`parent_id`,`child_id`),
  KEY `CATALOG_PRODUCT_RELATION_CHILD_ID` (`child_id`),
  CONSTRAINT `CAT_PRD_RELATION_CHILD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`child_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_RELATION_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Relation Table';


-- drakesterling_old.catalog_product_super_attribute definition

CREATE TABLE `catalog_product_super_attribute` (
  `product_super_attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Product Super Attribute ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `position` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`product_super_attribute_id`),
  UNIQUE KEY `CATALOG_PRODUCT_SUPER_ATTRIBUTE_PRODUCT_ID_ATTRIBUTE_ID` (`product_id`,`attribute_id`),
  CONSTRAINT `CAT_PRD_SPR_ATTR_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Super Attribute Table';


-- drakesterling_old.catalog_product_super_link definition

CREATE TABLE `catalog_product_super_link` (
  `link_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Link ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Parent ID',
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `CATALOG_PRODUCT_SUPER_LINK_PRODUCT_ID_PARENT_ID` (`product_id`,`parent_id`),
  KEY `CATALOG_PRODUCT_SUPER_LINK_PARENT_ID` (`parent_id`),
  CONSTRAINT `CAT_PRD_SPR_LNK_PARENT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`parent_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_SPR_LNK_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Super Link Table';


-- drakesterling_old.catalog_product_website definition

CREATE TABLE `catalog_product_website` (
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`product_id`,`website_id`),
  KEY `CATALOG_PRODUCT_WEBSITE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CATALOG_PRODUCT_WEBSITE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_WS_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product To Website Linkage Table';


-- drakesterling_old.catalog_url_rewrite_product_category definition

CREATE TABLE `catalog_url_rewrite_product_category` (
  `url_rewrite_id` int(10) unsigned NOT NULL COMMENT 'url_rewrite_id',
  `category_id` int(10) unsigned NOT NULL COMMENT 'category_id',
  `product_id` int(10) unsigned NOT NULL COMMENT 'product_id',
  PRIMARY KEY (`url_rewrite_id`),
  KEY `CATALOG_URL_REWRITE_PRODUCT_CATEGORY_CATEGORY_ID_PRODUCT_ID` (`category_id`,`product_id`),
  KEY `CAT_URL_REWRITE_PRD_CTGR_PRD_ID_CAT_PRD_ENTT_ENTT_ID` (`product_id`),
  KEY `FK_BB79E64705D7F17FE181F23144528FC8` (`url_rewrite_id`),
  CONSTRAINT `CAT_URL_REWRITE_PRD_CTGR_CTGR_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_URL_REWRITE_PRD_CTGR_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_BB79E64705D7F17FE181F23144528FC8` FOREIGN KEY (`url_rewrite_id`) REFERENCES `url_rewrite` (`url_rewrite_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='url_rewrite_relation';


-- drakesterling_old.cataloginventory_stock_item definition

CREATE TABLE `cataloginventory_stock_item` (
  `item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Item ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `stock_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Stock ID',
  `qty` decimal(12,4) DEFAULT NULL COMMENT 'Qty',
  `min_qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Min Qty',
  `use_config_min_qty` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Min Qty',
  `is_qty_decimal` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Qty Decimal',
  `backorders` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Backorders',
  `use_config_backorders` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Backorders',
  `min_sale_qty` decimal(12,4) NOT NULL DEFAULT '1.0000' COMMENT 'Min Sale Qty',
  `use_config_min_sale_qty` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Min Sale Qty',
  `max_sale_qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Max Sale Qty',
  `use_config_max_sale_qty` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Max Sale Qty',
  `is_in_stock` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is In Stock',
  `low_stock_date` timestamp NULL DEFAULT NULL COMMENT 'Low Stock Date',
  `notify_stock_qty` decimal(12,4) DEFAULT NULL COMMENT 'Notify Stock Qty',
  `use_config_notify_stock_qty` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Notify Stock Qty',
  `manage_stock` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Manage Stock',
  `use_config_manage_stock` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Manage Stock',
  `stock_status_changed_auto` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Stock Status Changed Automatically',
  `use_config_qty_increments` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Qty Increments',
  `qty_increments` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty Increments',
  `use_config_enable_qty_inc` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Use Config Enable Qty Increments',
  `enable_qty_increments` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Enable Qty Increments',
  `is_decimal_divided` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Divided into Multiple Boxes for Shipping',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  PRIMARY KEY (`item_id`),
  UNIQUE KEY `CATALOGINVENTORY_STOCK_ITEM_PRODUCT_ID_STOCK_ID` (`product_id`,`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_ITEM_WEBSITE_ID` (`website_id`),
  KEY `CATALOGINVENTORY_STOCK_ITEM_STOCK_ID` (`stock_id`),
  KEY `CATALOGINVENTORY_STOCK_ITEM_WEBSITE_ID_PRODUCT_ID` (`website_id`,`product_id`),
  CONSTRAINT `CATINV_STOCK_ITEM_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CATINV_STOCK_ITEM_STOCK_ID_CATINV_STOCK_STOCK_ID` FOREIGN KEY (`stock_id`) REFERENCES `cataloginventory_stock` (`stock_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=127168 DEFAULT CHARSET=utf8 COMMENT='Cataloginventory Stock Item';


-- drakesterling_old.catalogrule_customer_group definition

CREATE TABLE `catalogrule_customer_group` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`),
  KEY `CATALOGRULE_CUSTOMER_GROUP_CUSTOMER_GROUP_ID` (`customer_group_id`),
  CONSTRAINT `CATALOGRULE_CUSTOMER_GROUP_RULE_ID_CATALOGRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `catalogrule` (`rule_id`) ON DELETE CASCADE,
  CONSTRAINT `CATRULE_CSTR_GROUP_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Rules To Customer Groups Relations';


-- drakesterling_old.catalogrule_website definition

CREATE TABLE `catalogrule_website` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`website_id`),
  KEY `CATALOGRULE_WEBSITE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CATALOGRULE_WEBSITE_RULE_ID_CATALOGRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `catalogrule` (`rule_id`) ON DELETE CASCADE,
  CONSTRAINT `CATALOGRULE_WEBSITE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Rules To Websites Relations';


-- drakesterling_old.directory_country_region_name definition

CREATE TABLE `directory_country_region_name` (
  `locale` varchar(16) NOT NULL COMMENT 'Locale',
  `region_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Region ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Region Name',
  PRIMARY KEY (`locale`,`region_id`),
  KEY `DIRECTORY_COUNTRY_REGION_NAME_REGION_ID` (`region_id`),
  CONSTRAINT `DIR_COUNTRY_REGION_NAME_REGION_ID_DIR_COUNTRY_REGION_REGION_ID` FOREIGN KEY (`region_id`) REFERENCES `directory_country_region` (`region_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Directory Country Region Name';


-- drakesterling_old.downloadable_link definition

CREATE TABLE `downloadable_link` (
  `link_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Link ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort order',
  `number_of_downloads` int(11) DEFAULT NULL COMMENT 'Number of downloads',
  `is_shareable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Shareable flag',
  `link_url` varchar(255) DEFAULT NULL COMMENT 'Link Url',
  `link_file` varchar(255) DEFAULT NULL COMMENT 'Link File',
  `link_type` varchar(20) DEFAULT NULL COMMENT 'Link Type',
  `sample_url` varchar(255) DEFAULT NULL COMMENT 'Sample Url',
  `sample_file` varchar(255) DEFAULT NULL COMMENT 'Sample File',
  `sample_type` varchar(20) DEFAULT NULL COMMENT 'Sample Type',
  PRIMARY KEY (`link_id`),
  KEY `DOWNLOADABLE_LINK_PRODUCT_ID_SORT_ORDER` (`product_id`,`sort_order`),
  CONSTRAINT `DOWNLOADABLE_LINK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Link Table';


-- drakesterling_old.downloadable_link_price definition

CREATE TABLE `downloadable_link_price` (
  `price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Price ID',
  `link_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Link ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Price',
  PRIMARY KEY (`price_id`),
  KEY `DOWNLOADABLE_LINK_PRICE_LINK_ID` (`link_id`),
  KEY `DOWNLOADABLE_LINK_PRICE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `DOWNLOADABLE_LINK_PRICE_LINK_ID_DOWNLOADABLE_LINK_LINK_ID` FOREIGN KEY (`link_id`) REFERENCES `downloadable_link` (`link_id`) ON DELETE CASCADE,
  CONSTRAINT `DOWNLOADABLE_LINK_PRICE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Link Price Table';


-- drakesterling_old.downloadable_sample definition

CREATE TABLE `downloadable_sample` (
  `sample_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Sample ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `sample_url` varchar(255) DEFAULT NULL COMMENT 'Sample URL',
  `sample_file` varchar(255) DEFAULT NULL COMMENT 'Sample file',
  `sample_type` varchar(20) DEFAULT NULL COMMENT 'Sample Type',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`sample_id`),
  KEY `DOWNLOADABLE_SAMPLE_PRODUCT_ID` (`product_id`),
  CONSTRAINT `DOWNLOADABLE_SAMPLE_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Sample Table';


-- drakesterling_old.eav_attribute definition

CREATE TABLE `eav_attribute` (
  `attribute_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Attribute ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_code` varchar(255) NOT NULL COMMENT 'Attribute Code',
  `attribute_model` varchar(255) DEFAULT NULL COMMENT 'Attribute Model',
  `backend_model` varchar(255) DEFAULT NULL COMMENT 'Backend Model',
  `backend_type` varchar(8) NOT NULL DEFAULT 'static' COMMENT 'Backend Type',
  `backend_table` varchar(255) DEFAULT NULL COMMENT 'Backend Table',
  `frontend_model` varchar(255) DEFAULT NULL COMMENT 'Frontend Model',
  `frontend_input` varchar(50) DEFAULT NULL COMMENT 'Frontend Input',
  `frontend_label` varchar(255) DEFAULT NULL COMMENT 'Frontend Label',
  `frontend_class` varchar(255) DEFAULT NULL COMMENT 'Frontend Class',
  `source_model` varchar(255) DEFAULT NULL COMMENT 'Source Model',
  `is_required` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Defines Is Required',
  `is_user_defined` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Defines Is User Defined',
  `default_value` text COMMENT 'Default Value',
  `is_unique` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Defines Is Unique',
  `note` varchar(255) DEFAULT NULL COMMENT 'Note',
  PRIMARY KEY (`attribute_id`),
  UNIQUE KEY `EAV_ATTRIBUTE_ENTITY_TYPE_ID_ATTRIBUTE_CODE` (`entity_type_id`,`attribute_code`),
  KEY `EAV_ATTRIBUTE_FRONTEND_INPUT_ENTITY_TYPE_ID_IS_USER_DEFINED` (`frontend_input`,`entity_type_id`,`is_user_defined`),
  CONSTRAINT `EAV_ATTRIBUTE_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=225 DEFAULT CHARSET=utf8 COMMENT='Eav Attribute';


-- drakesterling_old.eav_attribute_option definition

CREATE TABLE `eav_attribute_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`option_id`),
  KEY `EAV_ATTRIBUTE_OPTION_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `EAV_ATTRIBUTE_OPTION_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5747 DEFAULT CHARSET=utf8 COMMENT='Eav Attribute Option';


-- drakesterling_old.eav_attribute_set definition

CREATE TABLE `eav_attribute_set` (
  `attribute_set_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Attribute Set ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_set_name` varchar(255) DEFAULT NULL COMMENT 'Attribute Set Name',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`attribute_set_id`),
  UNIQUE KEY `EAV_ATTRIBUTE_SET_ENTITY_TYPE_ID_ATTRIBUTE_SET_NAME` (`entity_type_id`,`attribute_set_name`),
  KEY `EAV_ATTRIBUTE_SET_ENTITY_TYPE_ID_SORT_ORDER` (`entity_type_id`,`sort_order`),
  CONSTRAINT `EAV_ATTRIBUTE_SET_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='Eav Attribute Set';


-- drakesterling_old.email_catalog definition

CREATE TABLE `email_catalog` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product Id',
  `imported` smallint(5) unsigned DEFAULT NULL COMMENT 'Product imported [deprecated]',
  `modified` smallint(5) unsigned DEFAULT NULL COMMENT 'Product modified [deprecated]',
  `processed` smallint(5) unsigned NOT NULL COMMENT 'Product processed',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  `last_imported_at` timestamp NULL DEFAULT NULL COMMENT 'Last imported date',
  PRIMARY KEY (`id`),
  KEY `EMAIL_CATALOG_PRODUCT_ID` (`product_id`),
  KEY `EMAIL_CATALOG_PROCESSED` (`processed`),
  KEY `EMAIL_CATALOG_CREATED_AT` (`created_at`),
  KEY `EMAIL_CATALOG_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_CATALOG_LAST_IMPORTED_AT` (`last_imported_at`),
  CONSTRAINT `EMAIL_CATALOG_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=17152 DEFAULT CHARSET=utf8 COMMENT='Connector Catalog';


-- drakesterling_old.email_contact definition

CREATE TABLE `email_contact` (
  `email_contact_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `is_guest` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Guest',
  `contact_id` varchar(15) DEFAULT NULL COMMENT 'Connector Contact ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Customer Email',
  `is_subscriber` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Subscriber',
  `subscriber_status` smallint(5) unsigned DEFAULT NULL COMMENT 'Subscriber status',
  `email_imported` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Imported',
  `subscriber_imported` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Subscriber Imported',
  `suppressed` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Suppressed',
  `last_subscribed_at` timestamp NULL DEFAULT NULL COMMENT 'Last time user subscribed',
  PRIMARY KEY (`email_contact_id`),
  KEY `EMAIL_CONTACT_EMAIL_CONTACT_ID` (`email_contact_id`),
  KEY `EMAIL_CONTACT_IS_GUEST` (`is_guest`),
  KEY `EMAIL_CONTACT_CUSTOMER_ID` (`customer_id`),
  KEY `EMAIL_CONTACT_WEBSITE_ID` (`website_id`),
  KEY `EMAIL_CONTACT_IS_SUBSCRIBER` (`is_subscriber`),
  KEY `EMAIL_CONTACT_SUBSCRIBER_STATUS` (`subscriber_status`),
  KEY `EMAIL_CONTACT_EMAIL_IMPORTED` (`email_imported`),
  KEY `EMAIL_CONTACT_SUBSCRIBER_IMPORTED` (`subscriber_imported`),
  KEY `EMAIL_CONTACT_SUPPRESSED` (`suppressed`),
  KEY `EMAIL_CONTACT_EMAIL` (`email`),
  KEY `EMAIL_CONTACT_CONTACT_ID` (`contact_id`),
  CONSTRAINT `EMAIL_CONTACT_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=623 DEFAULT CHARSET=utf8 COMMENT='Connector Contacts';


-- drakesterling_old.email_contact_consent definition

CREATE TABLE `email_contact_consent` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `email_contact_id` int(10) unsigned DEFAULT NULL COMMENT 'Email Contact Id',
  `consent_url` varchar(255) DEFAULT NULL COMMENT 'Contact consent url',
  `consent_datetime` datetime DEFAULT NULL COMMENT 'Contact consent datetime',
  `consent_ip` varchar(255) DEFAULT NULL COMMENT 'Contact consent ip',
  `consent_user_agent` varchar(255) DEFAULT NULL COMMENT 'Contact consent user agent',
  PRIMARY KEY (`id`),
  KEY `EMAIL_CONTACT_CONSENT_EMAIL_CONTACT_ID` (`email_contact_id`),
  CONSTRAINT `FK_17E9EA0C469163E550BC6B732AC49FDB` FOREIGN KEY (`email_contact_id`) REFERENCES `email_contact` (`email_contact_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Email contact consent table.';


-- drakesterling_old.integration definition

CREATE TABLE `integration` (
  `integration_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Integration ID',
  `name` varchar(255) NOT NULL COMMENT 'Integration name is displayed in the admin interface',
  `email` varchar(255) NOT NULL COMMENT 'Email address of the contact person',
  `endpoint` varchar(255) DEFAULT NULL COMMENT 'Endpoint for posting consumer credentials',
  `status` smallint(5) unsigned NOT NULL COMMENT 'Integration status',
  `consumer_id` int(10) unsigned DEFAULT NULL COMMENT 'Oauth consumer',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  `setup_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Integration type - manual or config file',
  `identity_link_url` varchar(255) DEFAULT NULL COMMENT 'Identity linking Url',
  PRIMARY KEY (`integration_id`),
  UNIQUE KEY `INTEGRATION_NAME` (`name`),
  UNIQUE KEY `INTEGRATION_CONSUMER_ID` (`consumer_id`),
  CONSTRAINT `INTEGRATION_CONSUMER_ID_OAUTH_CONSUMER_ENTITY_ID` FOREIGN KEY (`consumer_id`) REFERENCES `oauth_consumer` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=utf8 COMMENT='integration';


-- drakesterling_old.magenest_xero_log definition

CREATE TABLE `magenest_xero_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `type` varchar(45) NOT NULL COMMENT 'Entity Type',
  `entity_id` text COMMENT 'Entity Id',
  `dequeue_time` datetime NOT NULL COMMENT 'Sync time',
  `status` smallint(6) NOT NULL COMMENT 'Status',
  `xero_id` varchar(55) DEFAULT NULL COMMENT 'Xero Id',
  `msg` varchar(255) NOT NULL COMMENT 'Message',
  `xml_log_id` int(10) unsigned DEFAULT NULL COMMENT 'Xml Log Id',
  PRIMARY KEY (`id`),
  KEY `MAGENEST_XERO_LOG_XML_LOG_ID_MAGENEST_XERO_XML_LOG_ID` (`xml_log_id`),
  CONSTRAINT `MAGENEST_XERO_LOG_XML_LOG_ID_MAGENEST_XERO_XML_LOG_ID` FOREIGN KEY (`xml_log_id`) REFERENCES `magenest_xero_xml_log` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=16118 DEFAULT CHARSET=utf8 COMMENT='Sync Log Table';


-- drakesterling_old.magento_acknowledged_bulk definition

CREATE TABLE `magento_acknowledged_bulk` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Internal ID',
  `bulk_uuid` varbinary(39) DEFAULT NULL COMMENT 'Related Bulk UUID',
  PRIMARY KEY (`id`),
  UNIQUE KEY `MAGENTO_ACKNOWLEDGED_BULK_BULK_UUID` (`bulk_uuid`),
  CONSTRAINT `MAGENTO_ACKNOWLEDGED_BULK_BULK_UUID_MAGENTO_BULK_UUID` FOREIGN KEY (`bulk_uuid`) REFERENCES `magento_bulk` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Bulk that was viewed by user from notification area';


-- drakesterling_old.magento_operation definition

CREATE TABLE `magento_operation` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Operation ID',
  `bulk_uuid` varbinary(39) DEFAULT NULL COMMENT 'Related Bulk UUID',
  `topic_name` varchar(255) DEFAULT NULL COMMENT 'Name of the related message queue topic',
  `serialized_data` blob COMMENT 'Data (serialized) required to perform an operation',
  `result_serialized_data` blob COMMENT 'Result data (serialized) after perform an operation',
  `status` smallint(6) DEFAULT '0' COMMENT 'Operation status (OPEN | COMPLETE | RETRIABLY_FAILED | NOT_RETRIABLY_FAILED)',
  `error_code` smallint(6) DEFAULT NULL COMMENT 'Code of the error that appeared during operation execution (used to aggregate related failed operations)',
  `result_message` varchar(255) DEFAULT NULL COMMENT 'Operation result message',
  `operation_key` int(10) unsigned DEFAULT NULL COMMENT 'Operation Key',
  `started_at` timestamp NULL DEFAULT NULL COMMENT 'Datetime the operation started processing',
  PRIMARY KEY (`id`),
  KEY `MAGENTO_OPERATION_BULK_UUID_ERROR_CODE` (`bulk_uuid`,`error_code`),
  KEY `MAGENTO_OPERATION_STATUS_STARTED_AT` (`status`,`started_at`),
  CONSTRAINT `MAGENTO_OPERATION_BULK_UUID_MAGENTO_BULK_UUID` FOREIGN KEY (`bulk_uuid`) REFERENCES `magento_bulk` (`uuid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Operation entity';


-- drakesterling_old.mageplaza_blog_author definition

CREATE TABLE `mageplaza_blog_author` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Author ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Author Name',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Author URL Key',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Author Updated At',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Author Created At',
  `image` varchar(255) DEFAULT NULL COMMENT 'Author Image',
  `short_description` mediumtext COMMENT 'Author Short Description',
  `facebook_link` varchar(255) DEFAULT NULL COMMENT 'Facebook Link',
  `twitter_link` varchar(255) DEFAULT NULL COMMENT 'Twitter Link',
  `customer_id` int(10) unsigned DEFAULT '0' COMMENT 'Customer ID',
  `type` int(10) unsigned DEFAULT '0' COMMENT 'Author Type',
  `status` int(10) unsigned DEFAULT '0' COMMENT 'Author Status',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_AUTHOR_USER_ID` (`user_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_AUTHOR_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Author Table';


-- drakesterling_old.mageplaza_blog_post definition

CREATE TABLE `mageplaza_blog_post` (
  `post_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Post ID',
  `name` varchar(255) DEFAULT NULL COMMENT 'Post Name',
  `short_description` mediumtext COMMENT 'Post Short Description',
  `post_content` mediumtext COMMENT 'Post Content',
  `store_ids` int(11) NOT NULL COMMENT 'Store Id',
  `image` varchar(255) DEFAULT NULL COMMENT 'Post Image',
  `views` int(11) DEFAULT NULL COMMENT 'Post Views ',
  `enabled` int(2) DEFAULT '1' COMMENT 'Post Enabled',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Post URL Key',
  `in_rss` int(2) DEFAULT '0' COMMENT 'Post In RSS',
  `allow_comment` int(2) NOT NULL DEFAULT '0' COMMENT 'Post Allow Comment',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Meta Title',
  `meta_description` mediumtext COMMENT 'Meta Description',
  `meta_keywords` mediumtext COMMENT 'Meta Keywords',
  `meta_robots` mediumtext COMMENT 'Post Meta Robots',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Post Updated At',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Created At',
  `author_id` int(10) unsigned DEFAULT NULL COMMENT 'Author ID',
  `modifier_id` int(10) unsigned DEFAULT NULL COMMENT 'Author ID',
  `publish_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Updated At',
  `import_source` mediumtext COMMENT 'Import Source',
  `layout` mediumtext COMMENT 'Post Layout',
  PRIMARY KEY (`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_AUTHOR_ID_MAGEPLAZA_BLOG_AUTHOR_USER_ID` (`author_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_AUTHOR_ID_MAGEPLAZA_BLOG_AUTHOR_USER_ID` FOREIGN KEY (`author_id`) REFERENCES `mageplaza_blog_author` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Table';


-- drakesterling_old.mageplaza_blog_post_category definition

CREATE TABLE `mageplaza_blog_post_category` (
  `category_id` int(10) unsigned NOT NULL COMMENT 'Category ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`category_id`,`post_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_POST_CATEGORY_CATEGORY_ID_POST_ID` (`category_id`,`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_CATEGORY_CATEGORY_ID` (`category_id`),
  KEY `MAGEPLAZA_BLOG_POST_CATEGORY_POST_ID` (`post_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_CATEGORY_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_POST_CTGR_CTGR_ID_MAGEPLAZA_BLOG_CTGR_CTGR_ID` FOREIGN KEY (`category_id`) REFERENCES `mageplaza_blog_category` (`category_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Category Table';


-- drakesterling_old.mageplaza_blog_post_history definition

CREATE TABLE `mageplaza_blog_post_history` (
  `history_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'History ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post Id',
  `name` varchar(255) DEFAULT NULL COMMENT 'Post Name',
  `short_description` mediumtext COMMENT 'Post Short Description',
  `post_content` mediumtext COMMENT 'Post Content',
  `store_ids` int(11) NOT NULL COMMENT 'Store Id',
  `image` varchar(255) DEFAULT NULL COMMENT 'Post Image',
  `views` int(11) DEFAULT NULL COMMENT 'Post Views ',
  `enabled` int(2) DEFAULT '1' COMMENT 'Post Enabled',
  `url_key` varchar(255) DEFAULT NULL COMMENT 'Post URL Key',
  `in_rss` int(2) DEFAULT '0' COMMENT 'Post In RSS',
  `allow_comment` int(2) NOT NULL DEFAULT '0' COMMENT 'Post Allow Comment',
  `meta_title` varchar(255) DEFAULT NULL COMMENT 'Meta Title',
  `meta_keywords` mediumtext COMMENT 'Meta Keywords',
  `meta_description` mediumtext COMMENT 'Meta Description',
  `meta_robots` mediumtext COMMENT 'Post Meta Robots',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Created At',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Post Updated At',
  `author_id` int(10) unsigned DEFAULT NULL COMMENT 'Author ID',
  `modifier_id` int(10) unsigned DEFAULT NULL COMMENT 'Author ID',
  `publish_date` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Post Updated At',
  `import_source` mediumtext COMMENT 'Import Source',
  `category_ids` varchar(255) DEFAULT NULL COMMENT 'Category Ids',
  `tag_ids` varchar(255) DEFAULT NULL COMMENT 'Tag Ids',
  `topic_ids` varchar(255) DEFAULT NULL COMMENT 'Topic Ids',
  `product_ids` mediumtext COMMENT 'Product Ids',
  `layout` mediumtext COMMENT 'Post Layout',
  PRIMARY KEY (`history_id`),
  KEY `MAGEPLAZA_BLOG_POST_HISTORY_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` (`post_id`),
  KEY `FK_1C30A58B003D759E461CA81B2AB46020` (`author_id`),
  CONSTRAINT `FK_1C30A58B003D759E461CA81B2AB46020` FOREIGN KEY (`author_id`) REFERENCES `mageplaza_blog_author` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_POST_HISTORY_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post History Table';


-- drakesterling_old.mageplaza_blog_post_like definition

CREATE TABLE `mageplaza_blog_post_like` (
  `like_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Like ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `action` int(10) unsigned NOT NULL COMMENT 'type like',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'User Like ID',
  PRIMARY KEY (`like_id`),
  KEY `MAGEPLAZA_BLOG_POST_LIKE_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` (`post_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_LIKE_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Like Table';


-- drakesterling_old.mageplaza_blog_post_product definition

CREATE TABLE `mageplaza_blog_post_product` (
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Entity ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`entity_id`,`post_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_POST_PRODUCT_POST_ID_ENTITY_ID` (`post_id`,`entity_id`),
  KEY `MAGEPLAZA_BLOG_POST_PRODUCT_POST_ID` (`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_PRODUCT_ENTITY_ID` (`entity_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_PRD_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_POST_PRODUCT_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Product Table';


-- drakesterling_old.mageplaza_blog_post_tag definition

CREATE TABLE `mageplaza_blog_post_tag` (
  `tag_id` int(10) unsigned NOT NULL COMMENT 'Tag ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`tag_id`,`post_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_POST_TAG_POST_ID_TAG_ID` (`post_id`,`tag_id`),
  KEY `MAGEPLAZA_BLOG_POST_TAG_POST_ID` (`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_TAG_TAG_ID` (`tag_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_TAG_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_POST_TAG_TAG_ID_MAGEPLAZA_BLOG_TAG_TAG_ID` FOREIGN KEY (`tag_id`) REFERENCES `mageplaza_blog_tag` (`tag_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Tag Table';


-- drakesterling_old.mageplaza_blog_post_topic definition

CREATE TABLE `mageplaza_blog_post_topic` (
  `topic_id` int(10) unsigned NOT NULL COMMENT 'Topic ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  PRIMARY KEY (`topic_id`,`post_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_POST_TOPIC_POST_ID_TOPIC_ID` (`post_id`,`topic_id`),
  KEY `MAGEPLAZA_BLOG_POST_TOPIC_POST_ID` (`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_TOPIC_TOPIC_ID` (`topic_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_TOPIC_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_POST_TOPIC_TOPIC_ID_MAGEPLAZA_BLOG_TOPIC_TOPIC_ID` FOREIGN KEY (`topic_id`) REFERENCES `mageplaza_blog_topic` (`topic_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Topic Table';


-- drakesterling_old.mageplaza_blog_post_traffic definition

CREATE TABLE `mageplaza_blog_post_traffic` (
  `traffic_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Traffic ID',
  `post_id` int(10) unsigned NOT NULL COMMENT 'Post ID',
  `numbers_view` int(11) DEFAULT NULL,
  PRIMARY KEY (`traffic_id`),
  UNIQUE KEY `MAGEPLAZA_BLOG_POST_TRAFFIC_POST_ID_TRAFFIC_ID` (`post_id`,`traffic_id`),
  KEY `MAGEPLAZA_BLOG_POST_TRAFFIC_POST_ID` (`post_id`),
  KEY `MAGEPLAZA_BLOG_POST_TRAFFIC_TRAFFIC_ID` (`traffic_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_POST_TRAFFIC_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Post Traffic Table';


-- drakesterling_old.mageplaza_webhook_history definition

CREATE TABLE `mageplaza_webhook_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log Id',
  `hook_id` int(10) unsigned NOT NULL COMMENT 'Hook Id',
  `hook_name` varchar(255) DEFAULT NULL COMMENT 'Hook Name',
  `status` varchar(64) DEFAULT NULL COMMENT 'Log Status',
  `store_ids` varchar(64) NOT NULL COMMENT 'Stores',
  `hook_type` varchar(64) NOT NULL COMMENT 'Hook Type',
  `response` mediumtext COMMENT 'Response',
  `priority` int(11) DEFAULT NULL COMMENT 'Priority',
  `payload_url` text NOT NULL COMMENT 'Payload URL',
  `message` text COMMENT 'Message',
  `body` mediumtext COMMENT 'Body',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Update At',
  PRIMARY KEY (`id`),
  KEY `MAGEPLAZA_WEBHOOK_HISTORY_HOOK_ID` (`hook_id`),
  CONSTRAINT `MAGEPLAZA_WEBHOOK_HISTORY_HOOK_ID_MAGEPLAZA_WEBHOOK_HOOK_HOOK_ID` FOREIGN KEY (`hook_id`) REFERENCES `mageplaza_webhook_hook` (`hook_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7183 DEFAULT CHARSET=utf8 COMMENT='Product Feed Table';


-- drakesterling_old.media_gallery_asset_keyword definition

CREATE TABLE `media_gallery_asset_keyword` (
  `keyword_id` int(10) unsigned NOT NULL COMMENT 'Keyword Id',
  `asset_id` int(10) unsigned NOT NULL COMMENT 'Asset ID',
  PRIMARY KEY (`keyword_id`,`asset_id`),
  KEY `MEDIA_GALLERY_ASSET_KEYWORD_ASSET_ID` (`asset_id`),
  KEY `MEDIA_GALLERY_ASSET_KEYWORD_KEYWORD_ID` (`keyword_id`),
  CONSTRAINT `MEDIA_GALLERY_ASSET_KEYWORD_ASSET_ID_MEDIA_GALLERY_ASSET_ID` FOREIGN KEY (`asset_id`) REFERENCES `media_gallery_asset` (`id`) ON DELETE CASCADE,
  CONSTRAINT `MEDIA_GALLERY_ASSET_KEYWORD_KEYWORD_ID_MEDIA_GALLERY_KEYWORD_ID` FOREIGN KEY (`keyword_id`) REFERENCES `media_gallery_keyword` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Media Gallery Asset Keyword';


-- drakesterling_old.newsletter_queue definition

CREATE TABLE `newsletter_queue` (
  `queue_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Queue ID',
  `template_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Template ID',
  `newsletter_type` int(11) DEFAULT NULL COMMENT 'Newsletter Type',
  `newsletter_text` text COMMENT 'Newsletter Text',
  `newsletter_styles` text COMMENT 'Newsletter Styles',
  `newsletter_subject` varchar(200) DEFAULT NULL COMMENT 'Newsletter Subject',
  `newsletter_sender_name` varchar(200) DEFAULT NULL COMMENT 'Newsletter Sender Name',
  `newsletter_sender_email` varchar(200) DEFAULT NULL COMMENT 'Newsletter Sender Email',
  `queue_status` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Queue Status',
  `queue_start_at` timestamp NULL DEFAULT NULL COMMENT 'Queue Start At',
  `queue_finish_at` timestamp NULL DEFAULT NULL COMMENT 'Queue Finish At',
  PRIMARY KEY (`queue_id`),
  KEY `NEWSLETTER_QUEUE_TEMPLATE_ID` (`template_id`),
  CONSTRAINT `NEWSLETTER_QUEUE_TEMPLATE_ID_NEWSLETTER_TEMPLATE_TEMPLATE_ID` FOREIGN KEY (`template_id`) REFERENCES `newsletter_template` (`template_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Newsletter Queue';


-- drakesterling_old.oauth_nonce definition

CREATE TABLE `oauth_nonce` (
  `nonce` varchar(32) NOT NULL COMMENT 'Nonce String',
  `timestamp` int(10) unsigned NOT NULL COMMENT 'Nonce Timestamp',
  `consumer_id` int(10) unsigned NOT NULL COMMENT 'Consumer ID',
  PRIMARY KEY (`nonce`,`consumer_id`),
  KEY `OAUTH_NONCE_CONSUMER_ID_OAUTH_CONSUMER_ENTITY_ID` (`consumer_id`),
  KEY `OAUTH_NONCE_TIMESTAMP` (`timestamp`),
  CONSTRAINT `OAUTH_NONCE_CONSUMER_ID_OAUTH_CONSUMER_ENTITY_ID` FOREIGN KEY (`consumer_id`) REFERENCES `oauth_consumer` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='OAuth Nonce';


-- drakesterling_old.paypal_cert definition

CREATE TABLE `paypal_cert` (
  `cert_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Cert ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `content` text COMMENT 'Content',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  PRIMARY KEY (`cert_id`),
  KEY `PAYPAL_CERT_WEBSITE_ID` (`website_id`),
  CONSTRAINT `PAYPAL_CERT_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Paypal Certificate Table';


-- drakesterling_old.paypal_settlement_report_row definition

CREATE TABLE `paypal_settlement_report_row` (
  `row_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Row ID',
  `report_id` int(10) unsigned NOT NULL COMMENT 'Report ID',
  `transaction_id` varchar(19) DEFAULT NULL COMMENT 'Transaction ID',
  `invoice_id` varchar(127) DEFAULT NULL COMMENT 'Invoice ID',
  `paypal_reference_id` varchar(19) DEFAULT NULL COMMENT 'Paypal Reference ID',
  `paypal_reference_id_type` varchar(3) DEFAULT NULL COMMENT 'Paypal Reference ID Type',
  `transaction_event_code` varchar(5) DEFAULT NULL COMMENT 'Transaction Event Code',
  `transaction_initiation_date` timestamp NULL DEFAULT NULL COMMENT 'Transaction Initiation Date',
  `transaction_completion_date` timestamp NULL DEFAULT NULL COMMENT 'Transaction Completion Date',
  `transaction_debit_or_credit` varchar(2) NOT NULL DEFAULT 'CR' COMMENT 'Transaction Debit Or Credit',
  `gross_transaction_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Gross Transaction Amount',
  `gross_transaction_currency` varchar(3) DEFAULT NULL COMMENT 'Gross Transaction Currency',
  `fee_debit_or_credit` varchar(2) DEFAULT NULL COMMENT 'Fee Debit Or Credit',
  `fee_amount` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Fee Amount',
  `fee_currency` varchar(3) DEFAULT NULL COMMENT 'Fee Currency',
  `custom_field` varchar(255) DEFAULT NULL COMMENT 'Custom Field',
  `consumer_id` varchar(127) DEFAULT NULL COMMENT 'Consumer ID',
  `payment_tracking_id` varchar(255) DEFAULT NULL COMMENT 'Payment Tracking ID',
  `store_id` varchar(50) DEFAULT NULL COMMENT 'Store ID',
  PRIMARY KEY (`row_id`),
  KEY `PAYPAL_SETTLEMENT_REPORT_ROW_REPORT_ID` (`report_id`),
  CONSTRAINT `FK_E183E488F593E0DE10C6EBFFEBAC9B55` FOREIGN KEY (`report_id`) REFERENCES `paypal_settlement_report` (`report_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Paypal Settlement Report Row Table';


-- drakesterling_old.queue_message_status definition

CREATE TABLE `queue_message_status` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Relation ID',
  `queue_id` int(10) unsigned NOT NULL COMMENT 'Queue ID',
  `message_id` bigint(20) unsigned NOT NULL COMMENT 'Message ID',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `status` smallint(5) unsigned NOT NULL COMMENT 'Message status in particular queue',
  `number_of_trials` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of trials to processed failed message processing',
  PRIMARY KEY (`id`),
  UNIQUE KEY `QUEUE_MESSAGE_STATUS_QUEUE_ID_MESSAGE_ID` (`queue_id`,`message_id`),
  KEY `QUEUE_MESSAGE_STATUS_MESSAGE_ID_QUEUE_MESSAGE_ID` (`message_id`),
  KEY `QUEUE_MESSAGE_STATUS_STATUS_UPDATED_AT` (`status`,`updated_at`),
  CONSTRAINT `QUEUE_MESSAGE_STATUS_MESSAGE_ID_QUEUE_MESSAGE_ID` FOREIGN KEY (`message_id`) REFERENCES `queue_message` (`id`) ON DELETE CASCADE,
  CONSTRAINT `QUEUE_MESSAGE_STATUS_QUEUE_ID_QUEUE_ID` FOREIGN KEY (`queue_id`) REFERENCES `queue` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Relation table to keep associations between queues and messages';


-- drakesterling_old.rating definition

CREATE TABLE `rating` (
  `rating_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rating ID',
  `entity_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `rating_code` varchar(64) NOT NULL COMMENT 'Rating Code',
  `position` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Position On Storefront',
  `is_active` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Rating is active.',
  PRIMARY KEY (`rating_id`),
  UNIQUE KEY `RATING_RATING_CODE` (`rating_code`),
  KEY `RATING_ENTITY_ID` (`entity_id`),
  CONSTRAINT `RATING_ENTITY_ID_RATING_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `rating_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COMMENT='Ratings';


-- drakesterling_old.rating_option definition

CREATE TABLE `rating_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rating Option ID',
  `rating_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating ID',
  `code` varchar(32) NOT NULL COMMENT 'Rating Option Code',
  `value` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Option Value',
  `position` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Ration option position on Storefront',
  PRIMARY KEY (`option_id`),
  KEY `RATING_OPTION_RATING_ID` (`rating_id`),
  CONSTRAINT `RATING_OPTION_RATING_ID_RATING_RATING_ID` FOREIGN KEY (`rating_id`) REFERENCES `rating` (`rating_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COMMENT='Rating options';


-- drakesterling_old.release_notification_viewer_log definition

CREATE TABLE `release_notification_viewer_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Log ID',
  `viewer_id` int(10) unsigned NOT NULL COMMENT 'Viewer admin user ID',
  `last_view_version` varchar(16) NOT NULL COMMENT 'Viewer last view on product version',
  PRIMARY KEY (`id`),
  UNIQUE KEY `RELEASE_NOTIFICATION_VIEWER_LOG_VIEWER_ID` (`viewer_id`),
  CONSTRAINT `RELEASE_NOTIFICATION_VIEWER_LOG_VIEWER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`viewer_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Release Notification Viewer Log Table';


-- drakesterling_old.review definition

CREATE TABLE `review` (
  `review_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Review ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Review create date',
  `entity_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `entity_pk_value` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `status_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Status code',
  PRIMARY KEY (`review_id`),
  KEY `REVIEW_ENTITY_ID` (`entity_id`),
  KEY `REVIEW_STATUS_ID` (`status_id`),
  KEY `REVIEW_ENTITY_PK_VALUE` (`entity_pk_value`),
  CONSTRAINT `REVIEW_ENTITY_ID_REVIEW_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `review_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REVIEW_STATUS_ID_REVIEW_STATUS_STATUS_ID` FOREIGN KEY (`status_id`) REFERENCES `review_status` (`status_id`) ON DELETE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Review base information';


-- drakesterling_old.sales_order_status_state definition

CREATE TABLE `sales_order_status_state` (
  `status` varchar(32) NOT NULL COMMENT 'Status',
  `state` varchar(32) NOT NULL COMMENT 'Label',
  `is_default` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Default',
  `visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Visible on front',
  PRIMARY KEY (`status`,`state`),
  CONSTRAINT `SALES_ORDER_STATUS_STATE_STATUS_SALES_ORDER_STATUS_STATUS` FOREIGN KEY (`status`) REFERENCES `sales_order_status` (`status`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Order Status Table';


-- drakesterling_old.sales_sequence_profile definition

CREATE TABLE `sales_sequence_profile` (
  `profile_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `meta_id` int(10) unsigned NOT NULL COMMENT 'Meta_id',
  `prefix` varchar(32) DEFAULT NULL COMMENT 'Prefix',
  `suffix` varchar(32) DEFAULT NULL COMMENT 'Suffix',
  `start_value` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'Start value for sequence',
  `step` int(10) unsigned NOT NULL DEFAULT '1' COMMENT 'Step for sequence',
  `max_value` int(10) unsigned NOT NULL COMMENT 'MaxValue for sequence',
  `warning_value` int(10) unsigned NOT NULL COMMENT 'WarningValue for sequence',
  `is_active` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'isActive flag',
  PRIMARY KEY (`profile_id`),
  UNIQUE KEY `SALES_SEQUENCE_PROFILE_META_ID_PREFIX_SUFFIX` (`meta_id`,`prefix`,`suffix`),
  CONSTRAINT `SALES_SEQUENCE_PROFILE_META_ID_SALES_SEQUENCE_META_META_ID` FOREIGN KEY (`meta_id`) REFERENCES `sales_sequence_meta` (`meta_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='sales_sequence_profile';


-- drakesterling_old.salesrule_coupon definition

CREATE TABLE `salesrule_coupon` (
  `coupon_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Coupon ID',
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `code` varchar(255) DEFAULT NULL COMMENT 'Code',
  `usage_limit` int(10) unsigned DEFAULT NULL COMMENT 'Usage Limit',
  `usage_per_customer` int(10) unsigned DEFAULT NULL COMMENT 'Usage Per Customer',
  `times_used` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Times Used',
  `expiration_date` datetime DEFAULT NULL COMMENT 'Expiration Date',
  `is_primary` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Primary',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Coupon Code Creation Date',
  `type` smallint(6) DEFAULT '0' COMMENT 'Coupon Code Type',
  `generated_by_dotmailer` smallint(6) DEFAULT NULL COMMENT '1 = Generated by dotmailer',
  PRIMARY KEY (`coupon_id`),
  UNIQUE KEY `SALESRULE_COUPON_CODE` (`code`),
  UNIQUE KEY `SALESRULE_COUPON_RULE_ID_IS_PRIMARY` (`rule_id`,`is_primary`),
  KEY `SALESRULE_COUPON_RULE_ID` (`rule_id`),
  CONSTRAINT `SALESRULE_COUPON_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Salesrule Coupon';


-- drakesterling_old.salesrule_customer_group definition

CREATE TABLE `salesrule_customer_group` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  PRIMARY KEY (`rule_id`,`customer_group_id`),
  KEY `SALESRULE_CUSTOMER_GROUP_CUSTOMER_GROUP_ID` (`customer_group_id`),
  CONSTRAINT `SALESRULE_CSTR_GROUP_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_CUSTOMER_GROUP_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Rules To Customer Groups Relations';


-- drakesterling_old.salesrule_product_attribute definition

CREATE TABLE `salesrule_product_attribute` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `customer_group_id` int(10) unsigned NOT NULL COMMENT 'Customer Group ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  PRIMARY KEY (`rule_id`,`website_id`,`customer_group_id`,`attribute_id`),
  KEY `SALESRULE_PRODUCT_ATTRIBUTE_WEBSITE_ID` (`website_id`),
  KEY `SALESRULE_PRODUCT_ATTRIBUTE_CUSTOMER_GROUP_ID` (`customer_group_id`),
  KEY `SALESRULE_PRODUCT_ATTRIBUTE_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `SALESRULE_PRD_ATTR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_PRD_ATTR_CSTR_GROUP_ID_CSTR_GROUP_CSTR_GROUP_ID` FOREIGN KEY (`customer_group_id`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_PRODUCT_ATTRIBUTE_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_PRODUCT_ATTRIBUTE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Salesrule Product Attribute';


-- drakesterling_old.salesrule_website definition

CREATE TABLE `salesrule_website` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  PRIMARY KEY (`rule_id`,`website_id`),
  KEY `SALESRULE_WEBSITE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `SALESRULE_WEBSITE_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_WEBSITE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Rules To Websites Relations';


-- drakesterling_old.shipperhq_order_package_items definition

CREATE TABLE `shipperhq_order_package_items` (
  `package_id` int(10) unsigned NOT NULL DEFAULT '0',
  `sku` text NOT NULL COMMENT 'SKU',
  `qty_packed` float DEFAULT NULL COMMENT 'Qty packed',
  `weight_packed` float DEFAULT NULL COMMENT 'Weight packed',
  KEY `SHIPPERHQ_ORDER_PACKAGE_ITEMS_PACKAGE_ID` (`package_id`),
  CONSTRAINT `FK_90229CAB8ACAE06D7B0DE067E949286D` FOREIGN KEY (`package_id`) REFERENCES `shipperhq_order_packages` (`package_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Address Package Items Information';


-- drakesterling_old.shipperhq_quote_package_items definition

CREATE TABLE `shipperhq_quote_package_items` (
  `package_id` int(10) unsigned NOT NULL DEFAULT '0',
  `sku` text NOT NULL COMMENT 'SKU',
  `qty_packed` float DEFAULT NULL COMMENT 'Qty packed',
  `weight_packed` float DEFAULT NULL COMMENT 'Weight packed',
  KEY `SHIPPERHQ_QUOTE_PACKAGE_ITEMS_PACKAGE_ID` (`package_id`),
  CONSTRAINT `FK_E889295880F829D5ADA7C3C4604ECF61` FOREIGN KEY (`package_id`) REFERENCES `shipperhq_quote_packages` (`package_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='ShipperHQ Quote Address Package Items Information';


-- drakesterling_old.smile_elasticsuite_optimizer_search_container definition

CREATE TABLE `smile_elasticsuite_optimizer_search_container` (
  `optimizer_id` smallint(6) NOT NULL COMMENT 'Optimizer ID',
  `search_container` varchar(255) NOT NULL COMMENT 'Search Container',
  `apply_to` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'If this optimizer applies to specific entities or not.',
  PRIMARY KEY (`optimizer_id`,`search_container`),
  KEY `SMILE_ELASTICSUITE_OPTIMIZER_SEARCH_CONTAINER` (`search_container`),
  KEY `SMILE_ELASTICSUITE_OPTIMIZER_SEARCH_CONTAINER_SEARCH_CONTAINER` (`search_container`),
  CONSTRAINT `FK_19A755216ED198194BA7339E2AB30596` FOREIGN KEY (`optimizer_id`) REFERENCES `smile_elasticsuite_optimizer` (`optimizer_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuite_thesaurus_expanded_terms definition

CREATE TABLE `smile_elasticsuite_thesaurus_expanded_terms` (
  `thesaurus_id` int(10) unsigned NOT NULL COMMENT 'Thesaurus ID',
  `term_id` int(10) unsigned NOT NULL COMMENT 'Reference Term Id',
  `term` varchar(255) NOT NULL COMMENT 'Reference Term',
  PRIMARY KEY (`thesaurus_id`,`term_id`,`term`),
  KEY `SMILE_ELASTICSUITE_THESAURUS_EXPANDED_TERMS_TERM_ID` (`term_id`),
  CONSTRAINT `FK_9209E40A220DC2E4BE81B9A68B9B966D` FOREIGN KEY (`thesaurus_id`) REFERENCES `smile_elasticsuite_thesaurus` (`thesaurus_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuite_thesaurus_reference_terms definition

CREATE TABLE `smile_elasticsuite_thesaurus_reference_terms` (
  `thesaurus_id` int(10) unsigned NOT NULL COMMENT 'Thesaurus ID',
  `term_id` int(10) unsigned NOT NULL COMMENT 'Reference Term Id',
  `term` text NOT NULL COMMENT 'Reference Term',
  PRIMARY KEY (`thesaurus_id`,`term_id`),
  CONSTRAINT `FK_F32473FFBA5C398A18CD364D37976CB5` FOREIGN KEY (`thesaurus_id`) REFERENCES `smile_elasticsuite_thesaurus` (`thesaurus_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuitecatalog_category_filterable_attribute definition

CREATE TABLE `smile_elasticsuitecatalog_category_filterable_attribute` (
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Category ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute Id',
  `position` int(10) unsigned DEFAULT NULL COMMENT 'Position',
  `facet_display_mode` int(11) NOT NULL DEFAULT '0' COMMENT 'Facet display mode',
  `facet_min_coverage_rate` int(11) DEFAULT NULL COMMENT 'Facet min coverage rate',
  `facet_max_size` int(10) unsigned DEFAULT NULL COMMENT 'Facet max size',
  `facet_sort_order` varchar(30) DEFAULT NULL COMMENT 'The pattern to display facet values',
  PRIMARY KEY (`entity_id`,`attribute_id`),
  KEY `FK_691E21396002A6A370AE01801420A14A` (`attribute_id`),
  CONSTRAINT `FK_691E21396002A6A370AE01801420A14A` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_8B0BDE1CA9474CFD234FCD0FEBDC0225` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.store_group definition

CREATE TABLE `store_group` (
  `group_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Group ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `code` varchar(32) DEFAULT NULL COMMENT 'Store group unique code',
  `name` varchar(255) NOT NULL COMMENT 'Store Group Name',
  `root_category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Root Category ID',
  `default_store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Default Store ID',
  PRIMARY KEY (`group_id`),
  UNIQUE KEY `STORE_GROUP_CODE` (`code`),
  KEY `STORE_GROUP_WEBSITE_ID` (`website_id`),
  KEY `STORE_GROUP_DEFAULT_STORE_ID` (`default_store_id`),
  CONSTRAINT `STORE_GROUP_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Store Groups';


-- drakesterling_old.tax_calculation definition

CREATE TABLE `tax_calculation` (
  `tax_calculation_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Tax Calculation ID',
  `tax_calculation_rate_id` int(11) NOT NULL COMMENT 'Tax Calculation Rate ID',
  `tax_calculation_rule_id` int(11) NOT NULL COMMENT 'Tax Calculation Rule ID',
  `customer_tax_class_id` smallint(6) NOT NULL COMMENT 'Customer Tax Class ID',
  `product_tax_class_id` smallint(6) NOT NULL COMMENT 'Product Tax Class ID',
  PRIMARY KEY (`tax_calculation_id`),
  KEY `TAX_CALCULATION_TAX_CALCULATION_RULE_ID` (`tax_calculation_rule_id`),
  KEY `TAX_CALCULATION_CUSTOMER_TAX_CLASS_ID` (`customer_tax_class_id`),
  KEY `TAX_CALCULATION_PRODUCT_TAX_CLASS_ID` (`product_tax_class_id`),
  KEY `TAX_CALC_TAX_CALC_RATE_ID_CSTR_TAX_CLASS_ID_PRD_TAX_CLASS_ID` (`tax_calculation_rate_id`,`customer_tax_class_id`,`product_tax_class_id`),
  CONSTRAINT `TAX_CALCULATION_CUSTOMER_TAX_CLASS_ID_TAX_CLASS_CLASS_ID` FOREIGN KEY (`customer_tax_class_id`) REFERENCES `tax_class` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `TAX_CALCULATION_PRODUCT_TAX_CLASS_ID_TAX_CLASS_CLASS_ID` FOREIGN KEY (`product_tax_class_id`) REFERENCES `tax_class` (`class_id`) ON DELETE CASCADE,
  CONSTRAINT `TAX_CALC_TAX_CALC_RATE_ID_TAX_CALC_RATE_TAX_CALC_RATE_ID` FOREIGN KEY (`tax_calculation_rate_id`) REFERENCES `tax_calculation_rate` (`tax_calculation_rate_id`) ON DELETE CASCADE,
  CONSTRAINT `TAX_CALC_TAX_CALC_RULE_ID_TAX_CALC_RULE_TAX_CALC_RULE_ID` FOREIGN KEY (`tax_calculation_rule_id`) REFERENCES `tax_calculation_rule` (`tax_calculation_rule_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tax Calculation';


-- drakesterling_old.theme_file definition

CREATE TABLE `theme_file` (
  `theme_files_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Theme files identifier',
  `theme_id` int(10) unsigned NOT NULL COMMENT 'Theme ID',
  `file_path` varchar(255) DEFAULT NULL COMMENT 'Relative path to file',
  `file_type` varchar(32) NOT NULL COMMENT 'File Type',
  `content` longtext NOT NULL COMMENT 'File Content',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `is_temporary` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is Temporary File',
  PRIMARY KEY (`theme_files_id`),
  KEY `THEME_FILE_THEME_ID_THEME_THEME_ID` (`theme_id`),
  CONSTRAINT `THEME_FILE_THEME_ID_THEME_THEME_ID` FOREIGN KEY (`theme_id`) REFERENCES `theme` (`theme_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Core theme files';


-- drakesterling_old.ui_bookmark definition

CREATE TABLE `ui_bookmark` (
  `bookmark_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Bookmark identifier',
  `user_id` int(10) unsigned NOT NULL COMMENT 'User ID',
  `namespace` varchar(255) NOT NULL COMMENT 'Bookmark namespace',
  `identifier` varchar(255) NOT NULL COMMENT 'Bookmark Identifier',
  `current` smallint(6) NOT NULL COMMENT 'Mark current bookmark per user and identifier',
  `title` varchar(255) DEFAULT NULL COMMENT 'Bookmark title',
  `config` longtext COMMENT 'Bookmark config',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Bookmark created at',
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Bookmark updated at',
  PRIMARY KEY (`bookmark_id`),
  KEY `UI_BOOKMARK_USER_ID_NAMESPACE_IDENTIFIER` (`user_id`,`namespace`,`identifier`),
  CONSTRAINT `UI_BOOKMARK_USER_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`user_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=496 DEFAULT CHARSET=utf8 COMMENT='Bookmark';


-- drakesterling_old.weee_tax definition

CREATE TABLE `weee_tax` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `country` varchar(2) DEFAULT NULL COMMENT 'Country',
  `value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Value',
  `state` int(11) NOT NULL DEFAULT '0' COMMENT 'State',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  PRIMARY KEY (`value_id`),
  KEY `WEEE_TAX_WEBSITE_ID` (`website_id`),
  KEY `WEEE_TAX_ENTITY_ID` (`entity_id`),
  KEY `WEEE_TAX_COUNTRY` (`country`),
  KEY `WEEE_TAX_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `WEEE_TAX_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `WEEE_TAX_COUNTRY_DIRECTORY_COUNTRY_COUNTRY_ID` FOREIGN KEY (`country`) REFERENCES `directory_country` (`country_id`) ON DELETE CASCADE,
  CONSTRAINT `WEEE_TAX_ENTITY_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `WEEE_TAX_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Weee Tax';


-- drakesterling_old.widget_instance definition

CREATE TABLE `widget_instance` (
  `instance_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Instance ID',
  `instance_type` varchar(255) DEFAULT NULL COMMENT 'Instance Type',
  `theme_id` int(10) unsigned NOT NULL COMMENT 'Theme ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Widget Title',
  `store_ids` varchar(255) NOT NULL DEFAULT '0' COMMENT 'Store ids',
  `widget_parameters` text COMMENT 'Widget parameters',
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort order',
  PRIMARY KEY (`instance_id`),
  KEY `WIDGET_INSTANCE_THEME_ID_THEME_THEME_ID` (`theme_id`),
  CONSTRAINT `WIDGET_INSTANCE_THEME_ID_THEME_THEME_ID` FOREIGN KEY (`theme_id`) REFERENCES `theme` (`theme_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COMMENT='Instances of Widget for Package Theme';


-- drakesterling_old.widget_instance_page definition

CREATE TABLE `widget_instance_page` (
  `page_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Page ID',
  `instance_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Instance ID',
  `page_group` varchar(25) DEFAULT NULL COMMENT 'Block Group Type',
  `layout_handle` varchar(255) DEFAULT NULL COMMENT 'Layout Handle',
  `block_reference` varchar(255) DEFAULT NULL COMMENT 'Container',
  `page_for` varchar(25) DEFAULT NULL COMMENT 'For instance entities',
  `entities` text COMMENT 'Catalog entities (comma separated)',
  `page_template` varchar(255) DEFAULT NULL COMMENT 'Path to widget template',
  PRIMARY KEY (`page_id`),
  KEY `WIDGET_INSTANCE_PAGE_INSTANCE_ID` (`instance_id`),
  CONSTRAINT `WIDGET_INSTANCE_PAGE_INSTANCE_ID_WIDGET_INSTANCE_INSTANCE_ID` FOREIGN KEY (`instance_id`) REFERENCES `widget_instance` (`instance_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COMMENT='Instance of Widget on Page';


-- drakesterling_old.widget_instance_page_layout definition

CREATE TABLE `widget_instance_page_layout` (
  `page_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Page ID',
  `layout_update_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Layout Update ID',
  PRIMARY KEY (`layout_update_id`,`page_id`),
  KEY `WIDGET_INSTANCE_PAGE_LAYOUT_PAGE_ID` (`page_id`),
  CONSTRAINT `WIDGET_INSTANCE_PAGE_LAYOUT_PAGE_ID_WIDGET_INSTANCE_PAGE_PAGE_ID` FOREIGN KEY (`page_id`) REFERENCES `widget_instance_page` (`page_id`) ON DELETE CASCADE,
  CONSTRAINT `WIDGET_INSTANCE_PAGE_LYT_LYT_UPDATE_ID_LYT_UPDATE_LYT_UPDATE_ID` FOREIGN KEY (`layout_update_id`) REFERENCES `layout_update` (`layout_update_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Layout updates';


-- drakesterling_old.wk_ebay_product_image definition

CREATE TABLE `wk_ebay_product_image` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `magento_pro_id` int(10) unsigned NOT NULL COMMENT 'Magento Product id',
  `image_url` varchar(255) DEFAULT NULL COMMENT 'image url',
  `is_default` int(11) DEFAULT NULL COMMENT 'is default',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'created time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAY_PRODUCT_IMAGE_ENTITY_ID` (`entity_id`),
  KEY `WK_EBAY_PRD_IMAGE_MAGENTO_PRO_ID_CAT_PRD_ENTT_ENTT_ID` (`magento_pro_id`),
  CONSTRAINT `WK_EBAY_PRD_IMAGE_MAGENTO_PRO_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`magento_pro_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='wk_ebay_product_image';


-- drakesterling_old.wk_ebaysynchronize_category definition

CREATE TABLE `wk_ebaysynchronize_category` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `attribute_set` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Store attribute set id',
  `mage_cat_id` int(10) unsigned NOT NULL COMMENT 'Magento Category Id',
  `ebay_cat_id` int(10) unsigned NOT NULL COMMENT 'Ebay Category Id',
  `ebay_cat_name` varchar(255) DEFAULT NULL COMMENT 'Ebay Category Name',
  `ebay_store_cat_id` varchar(255) DEFAULT NULL COMMENT 'eBay store category id',
  `ebay_store_cat_name` varchar(255) DEFAULT NULL COMMENT 'eBay store category name',
  `ebay_cat_path` varchar(255) NOT NULL COMMENT 'eBay Category Path',
  `pro_condition_attr` varchar(255) DEFAULT NULL COMMENT 'Product Condition Attribute',
  `variations_enabled` int(10) unsigned NOT NULL COMMENT 'Product Variations Enabled',
  `ean_status` varchar(255) NOT NULL COMMENT 'EAN Status',
  `upc_status` varchar(255) NOT NULL COMMENT 'UPC Status',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Category Mapped Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_CATEGORY_ENTITY_ID` (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_CTGR_MAGE_CAT_ID_CAT_CTGR_ENTT_ENTT_ID` (`mage_cat_id`),
  CONSTRAINT `WK_EBAYSYNCHRONIZE_CTGR_MAGE_CAT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`mage_cat_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8 COMMENT='Ebay Synchronize Category Table';


-- drakesterling_old.wk_ebaysynchronize_product definition

CREATE TABLE `wk_ebaysynchronize_product` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Id',
  `ebay_pro_id` varchar(255) DEFAULT NULL COMMENT 'Ebay Product Id',
  `name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_type` varchar(255) DEFAULT NULL COMMENT 'Product Type',
  `price` decimal(12,4) NOT NULL COMMENT 'Product Price',
  `magento_pro_id` int(10) unsigned NOT NULL COMMENT 'Magento Product Id',
  `sku` varchar(255) NOT NULL COMMENT 'Product SKU on magento',
  `mage_cat_id` int(10) unsigned NOT NULL COMMENT 'Magento Category Id',
  `change_status` int(10) unsigned NOT NULL COMMENT 'Change Status',
  `status` varchar(255) NOT NULL DEFAULT 'active' COMMENT 'Sync Status',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Product sync Time',
  PRIMARY KEY (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_PRODUCT_ENTITY_ID` (`entity_id`),
  KEY `WK_EBAYSYNCHRONIZE_PRD_MAGENTO_PRO_ID_CAT_PRD_ENTT_ENTT_ID` (`magento_pro_id`),
  CONSTRAINT `WK_EBAYSYNCHRONIZE_PRD_MAGENTO_PRO_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`magento_pro_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3722 DEFAULT CHARSET=utf8 COMMENT='eBay Synchronize Product';


-- drakesterling_old.catalog_eav_attribute definition

CREATE TABLE `catalog_eav_attribute` (
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `frontend_input_renderer` varchar(255) DEFAULT NULL COMMENT 'Frontend Input Renderer',
  `is_global` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Global',
  `is_visible` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Visible',
  `is_searchable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Searchable',
  `is_filterable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Filterable',
  `is_comparable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Comparable',
  `is_visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible On Front',
  `is_html_allowed_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is HTML Allowed On Front',
  `is_used_for_price_rules` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used For Price Rules',
  `is_filterable_in_search` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Filterable In Search',
  `used_in_product_listing` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used In Product Listing',
  `used_for_sort_by` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used For Sorting',
  `apply_to` varchar(255) DEFAULT NULL COMMENT 'Apply To',
  `is_visible_in_advanced_search` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible In Advanced Search',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  `is_wysiwyg_enabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is WYSIWYG Enabled',
  `is_used_for_promo_rules` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used For Promo Rules',
  `is_required_in_admin_store` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Required In Admin Store',
  `is_used_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used in Grid',
  `is_visible_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible in Grid',
  `is_filterable_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Filterable in Grid',
  `search_weight` float NOT NULL DEFAULT '1' COMMENT 'Search Weight',
  `additional_data` text COMMENT 'Additional swatch attributes data',
  `is_displayed_in_autocomplete` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'If attribute is displayed in autocomplete',
  `is_used_in_spellcheck` tinyint(1) NOT NULL DEFAULT '1' COMMENT 'If fuzziness is used on attribute',
  `facet_min_coverage_rate` int(10) unsigned NOT NULL DEFAULT '90' COMMENT 'Facet min coverage rate',
  `facet_max_size` int(10) unsigned NOT NULL DEFAULT '10' COMMENT 'Facet max size',
  `facet_sort_order` varchar(30) NOT NULL DEFAULT '_count' COMMENT 'The sort order for facet values',
  `facet_boolean_logic` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Boolean logic to use when combining multiple selected values inside the filter',
  `display_pattern` text COMMENT 'The pattern to display facet values',
  `display_precision` int(11) DEFAULT '0' COMMENT 'Attribute decimal precision for display',
  `sort_order_asc_missing` varchar(30) NOT NULL DEFAULT '_last' COMMENT 'Sort products without value when sorting ASC',
  `sort_order_desc_missing` varchar(30) NOT NULL DEFAULT '_first' COMMENT 'Sort products without value when sorting DESC',
  `is_pagebuilder_enabled` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is PageBuilder Enabled',
  `is_display_rel_nofollow` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Boolean logic to use for displaying rel=nofollow attribute for all filter links of current attribute',
  `include_zero_false_values` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Should the search engine index zero (integer or decimal attribute) or false (boolean attribute) values',
  `is_spannable` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Should this field be used for span queries.',
  `norms_disabled` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'If this field should have norms:false in Elasticsearch.',
  `default_analyzer` varchar(30) NOT NULL DEFAULT 'standard' COMMENT 'Default analyzer for this field',
  `datalayer` smallint(6) DEFAULT NULL COMMENT 'Attribute dataLayer[] signal',
  PRIMARY KEY (`attribute_id`),
  KEY `CATALOG_EAV_ATTRIBUTE_USED_FOR_SORT_BY` (`used_for_sort_by`),
  KEY `CATALOG_EAV_ATTRIBUTE_USED_IN_PRODUCT_LISTING` (`used_in_product_listing`),
  CONSTRAINT `CATALOG_EAV_ATTRIBUTE_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog EAV Attribute Table';


-- drakesterling_old.catalog_product_entity_media_gallery definition

CREATE TABLE `catalog_product_entity_media_gallery` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  `media_type` varchar(32) NOT NULL DEFAULT 'image' COMMENT 'Media entry type',
  `disabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Visibility status',
  PRIMARY KEY (`value_id`),
  KEY `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=124293 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Media Gallery Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_media_gallery_value_to_entity definition

CREATE TABLE `catalog_product_entity_media_gallery_value_to_entity` (
  `value_id` int(10) unsigned NOT NULL COMMENT 'Value media Entry ID',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Product Entity ID',
  PRIMARY KEY (`value_id`,`entity_id`),
  KEY `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` (`entity_id`),
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_TO_ENTT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_A6C6C8FAA386736921D3A7C4B50B1185` FOREIGN KEY (`value_id`) REFERENCES `catalog_product_entity_media_gallery` (`value_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Link Media value to Product entity table';


-- drakesterling_old.customer_eav_attribute definition

CREATE TABLE `customer_eav_attribute` (
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `is_visible` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Visible',
  `input_filter` varchar(255) DEFAULT NULL COMMENT 'Input Filter',
  `multiline_count` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Multiline Count',
  `validate_rules` text COMMENT 'Validate Rules',
  `is_system` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is System',
  `sort_order` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `data_model` varchar(255) DEFAULT NULL COMMENT 'Data Model',
  `is_used_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Used in Grid',
  `is_visible_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible in Grid',
  `is_filterable_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Filterable in Grid',
  `is_searchable_in_grid` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Searchable in Grid',
  `grid_filter_condition_type` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Grid Filter Condition Type',
  PRIMARY KEY (`attribute_id`),
  KEY `CUSTOMER_EAV_ATTRIBUTE_SORT_ORDER` (`sort_order`),
  CONSTRAINT `CUSTOMER_EAV_ATTRIBUTE_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Eav Attribute';


-- drakesterling_old.customer_eav_attribute_website definition

CREATE TABLE `customer_eav_attribute_website` (
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `website_id` smallint(5) unsigned NOT NULL COMMENT 'Website ID',
  `is_visible` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Visible',
  `is_required` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Required',
  `default_value` text COMMENT 'Default Value',
  `multiline_count` smallint(5) unsigned DEFAULT NULL COMMENT 'Multiline Count',
  PRIMARY KEY (`attribute_id`,`website_id`),
  KEY `CUSTOMER_EAV_ATTRIBUTE_WEBSITE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `CSTR_EAV_ATTR_WS_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_EAV_ATTR_WS_WS_ID_STORE_WS_WS_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Eav Attribute Website';


-- drakesterling_old.customer_form_attribute definition

CREATE TABLE `customer_form_attribute` (
  `form_code` varchar(32) NOT NULL COMMENT 'Form Code',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  PRIMARY KEY (`form_code`,`attribute_id`),
  KEY `CUSTOMER_FORM_ATTRIBUTE_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `CUSTOMER_FORM_ATTRIBUTE_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Form Attribute';


-- drakesterling_old.eav_attribute_group definition

CREATE TABLE `eav_attribute_group` (
  `attribute_group_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Attribute Group ID',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `attribute_group_name` varchar(255) DEFAULT NULL COMMENT 'Attribute Group Name',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  `default_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Default ID',
  `attribute_group_code` varchar(255) NOT NULL COMMENT 'Attribute Group Code',
  `tab_group_code` varchar(255) DEFAULT NULL COMMENT 'Tab Group Code',
  PRIMARY KEY (`attribute_group_id`),
  UNIQUE KEY `EAV_ATTRIBUTE_GROUP_ATTRIBUTE_SET_ID_ATTRIBUTE_GROUP_CODE` (`attribute_set_id`,`attribute_group_code`),
  UNIQUE KEY `EAV_ATTRIBUTE_GROUP_ATTRIBUTE_SET_ID_ATTRIBUTE_GROUP_NAME` (`attribute_set_id`,`attribute_group_name`),
  KEY `EAV_ATTRIBUTE_GROUP_ATTRIBUTE_SET_ID_SORT_ORDER` (`attribute_set_id`,`sort_order`),
  CONSTRAINT `EAV_ATTR_GROUP_ATTR_SET_ID_EAV_ATTR_SET_ATTR_SET_ID` FOREIGN KEY (`attribute_set_id`) REFERENCES `eav_attribute_set` (`attribute_set_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COMMENT='Eav Attribute Group';


-- drakesterling_old.eav_entity_attribute definition

CREATE TABLE `eav_entity_attribute` (
  `entity_attribute_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Attribute ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `attribute_group_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Group ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `sort_order` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`entity_attribute_id`),
  UNIQUE KEY `EAV_ENTITY_ATTRIBUTE_ATTRIBUTE_SET_ID_ATTRIBUTE_ID` (`attribute_set_id`,`attribute_id`),
  UNIQUE KEY `EAV_ENTITY_ATTRIBUTE_ATTRIBUTE_GROUP_ID_ATTRIBUTE_ID` (`attribute_group_id`,`attribute_id`),
  KEY `EAV_ENTITY_ATTRIBUTE_ATTRIBUTE_SET_ID_SORT_ORDER` (`attribute_set_id`,`sort_order`),
  KEY `EAV_ENTITY_ATTRIBUTE_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `EAV_ENTITY_ATTRIBUTE_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTT_ATTR_ATTR_GROUP_ID_EAV_ATTR_GROUP_ATTR_GROUP_ID` FOREIGN KEY (`attribute_group_id`) REFERENCES `eav_attribute_group` (`attribute_group_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6337 DEFAULT CHARSET=utf8 COMMENT='Eav Entity Attributes';


-- drakesterling_old.email_coupon_attribute definition

CREATE TABLE `email_coupon_attribute` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `salesrule_coupon_id` int(10) unsigned NOT NULL COMMENT 'Coupon ID',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'Coupon expiration date',
  PRIMARY KEY (`id`),
  KEY `EMAIL_COUPON_ATTRIBUTE_COUPON_ID` (`salesrule_coupon_id`),
  KEY `EMAIL_COUPON_ATTRIBUTE_EMAIL` (`email`),
  CONSTRAINT `EMAIL_COUPON_ATTRIBUTE_COUPON_ID_SALESRULE_COUPON_COUPON_ID` FOREIGN KEY (`salesrule_coupon_id`) REFERENCES `salesrule_coupon` (`coupon_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Dotdigital coupon attributes table';


-- drakesterling_old.rating_option_vote definition

CREATE TABLE `rating_option_vote` (
  `vote_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Vote ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Vote option ID',
  `remote_ip` varchar(16) NOT NULL COMMENT 'Customer IP',
  `remote_ip_long` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Customer IP converted to long integer format',
  `customer_id` int(10) unsigned DEFAULT '0' COMMENT 'Customer ID',
  `entity_pk_value` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `rating_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating ID',
  `review_id` bigint(20) unsigned DEFAULT NULL COMMENT 'Review ID',
  `percent` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Percent amount',
  `value` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Vote option value',
  PRIMARY KEY (`vote_id`),
  KEY `RATING_OPTION_VOTE_OPTION_ID` (`option_id`),
  KEY `RATING_OPTION_VOTE_REVIEW_ID_REVIEW_REVIEW_ID` (`review_id`),
  CONSTRAINT `RATING_OPTION_VOTE_OPTION_ID_RATING_OPTION_OPTION_ID` FOREIGN KEY (`option_id`) REFERENCES `rating_option` (`option_id`) ON DELETE CASCADE,
  CONSTRAINT `RATING_OPTION_VOTE_REVIEW_ID_REVIEW_REVIEW_ID` FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rating option values';


-- drakesterling_old.store definition

CREATE TABLE `store` (
  `store_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Store ID',
  `code` varchar(32) DEFAULT NULL COMMENT 'Code',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `group_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Group ID',
  `name` varchar(255) NOT NULL COMMENT 'Store Name',
  `sort_order` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store Sort Order',
  `is_active` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store Activity',
  PRIMARY KEY (`store_id`),
  UNIQUE KEY `STORE_CODE` (`code`),
  KEY `STORE_WEBSITE_ID` (`website_id`),
  KEY `STORE_IS_ACTIVE_SORT_ORDER` (`is_active`,`sort_order`),
  KEY `STORE_GROUP_ID` (`group_id`),
  CONSTRAINT `STORE_GROUP_ID_STORE_GROUP_GROUP_ID` FOREIGN KEY (`group_id`) REFERENCES `store_group` (`group_id`) ON DELETE CASCADE,
  CONSTRAINT `STORE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Stores';


-- drakesterling_old.tax_calculation_rate_title definition

CREATE TABLE `tax_calculation_rate_title` (
  `tax_calculation_rate_title_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Tax Calculation Rate Title ID',
  `tax_calculation_rate_id` int(11) NOT NULL COMMENT 'Tax Calculation Rate ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `value` varchar(255) NOT NULL COMMENT 'Value',
  PRIMARY KEY (`tax_calculation_rate_title_id`),
  KEY `TAX_CALCULATION_RATE_TITLE_TAX_CALCULATION_RATE_ID_STORE_ID` (`tax_calculation_rate_id`,`store_id`),
  KEY `TAX_CALCULATION_RATE_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `FK_37FB965F786AD5897BB3AE90470C42AB` FOREIGN KEY (`tax_calculation_rate_id`) REFERENCES `tax_calculation_rate` (`tax_calculation_rate_id`) ON DELETE CASCADE,
  CONSTRAINT `TAX_CALCULATION_RATE_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tax Calculation Rate Title';


-- drakesterling_old.tax_order_aggregated_created definition

CREATE TABLE `tax_order_aggregated_created` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `percent` float DEFAULT NULL COMMENT 'Percent',
  `orders_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `tax_base_amount_sum` float DEFAULT NULL COMMENT 'Tax Base Amount Sum',
  PRIMARY KEY (`id`),
  UNIQUE KEY `TAX_ORDER_AGGRED_CREATED_PERIOD_STORE_ID_CODE_PERCENT_ORDER_STS` (`period`,`store_id`,`code`,`percent`,`order_status`),
  KEY `TAX_ORDER_AGGREGATED_CREATED_STORE_ID` (`store_id`),
  CONSTRAINT `TAX_ORDER_AGGREGATED_CREATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tax Order Aggregation';


-- drakesterling_old.tax_order_aggregated_updated definition

CREATE TABLE `tax_order_aggregated_updated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `percent` float DEFAULT NULL COMMENT 'Percent',
  `orders_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `tax_base_amount_sum` float DEFAULT NULL COMMENT 'Tax Base Amount Sum',
  PRIMARY KEY (`id`),
  UNIQUE KEY `TAX_ORDER_AGGRED_UPDATED_PERIOD_STORE_ID_CODE_PERCENT_ORDER_STS` (`period`,`store_id`,`code`,`percent`,`order_status`),
  KEY `TAX_ORDER_AGGREGATED_UPDATED_STORE_ID` (`store_id`),
  CONSTRAINT `TAX_ORDER_AGGREGATED_UPDATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Tax Order Aggregated Updated';


-- drakesterling_old.`translation` definition

CREATE TABLE `translation` (
  `key_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Key ID of Translation',
  `string` varchar(255) NOT NULL DEFAULT 'Translate String' COMMENT 'Translation String',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `translate` varchar(255) DEFAULT NULL COMMENT 'Translate',
  `locale` varchar(20) NOT NULL DEFAULT 'en_US' COMMENT 'Locale',
  `crc_string` bigint(20) NOT NULL DEFAULT '1591228201' COMMENT 'Translation String CRC32 Hash',
  PRIMARY KEY (`key_id`),
  UNIQUE KEY `TRANSLATION_STORE_ID_LOCALE_CRC_STRING_STRING` (`store_id`,`locale`,`crc_string`,`string`),
  CONSTRAINT `TRANSLATION_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Translations';


-- drakesterling_old.variable_value definition

CREATE TABLE `variable_value` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Variable Value ID',
  `variable_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Variable ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `plain_value` text COMMENT 'Plain Text Value',
  `html_value` text COMMENT 'Html Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `VARIABLE_VALUE_VARIABLE_ID_STORE_ID` (`variable_id`,`store_id`),
  KEY `VARIABLE_VALUE_STORE_ID` (`store_id`),
  CONSTRAINT `VARIABLE_VALUE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `VARIABLE_VALUE_VARIABLE_ID_VARIABLE_VARIABLE_ID` FOREIGN KEY (`variable_id`) REFERENCES `variable` (`variable_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Variable Value';


-- drakesterling_old.amasty_fpc_log definition

CREATE TABLE `amasty_fpc_log` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created_at',
  `url` varchar(255) NOT NULL COMMENT 'Url',
  `store` smallint(5) unsigned DEFAULT NULL COMMENT 'Store',
  `currency` varchar(3) DEFAULT NULL COMMENT 'Currency',
  `customer_group` int(10) unsigned DEFAULT NULL COMMENT 'Customer_group',
  `rate` int(10) unsigned NOT NULL COMMENT 'Rate',
  `status` smallint(5) unsigned NOT NULL COMMENT 'Status',
  `load_time` float(10,0) unsigned NOT NULL COMMENT 'Load_time',
  `mobile` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `AMASTY_FPC_LOG_STORE_STORE_STORE_ID` (`store`),
  KEY `AMASTY_FPC_LOG_CUSTOMER_GROUP_CUSTOMER_GROUP_CUSTOMER_GROUP_ID` (`customer_group`),
  CONSTRAINT `AMASTY_FPC_LOG_CUSTOMER_GROUP_CUSTOMER_GROUP_CUSTOMER_GROUP_ID` FOREIGN KEY (`customer_group`) REFERENCES `customer_group` (`customer_group_id`) ON DELETE CASCADE,
  CONSTRAINT `AMASTY_FPC_LOG_STORE_STORE_STORE_ID` FOREIGN KEY (`store`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2214119 DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Log Table';


-- drakesterling_old.amasty_fpc_queue_page definition

CREATE TABLE `amasty_fpc_queue_page` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Id',
  `url` varchar(255) NOT NULL COMMENT 'Url',
  `rate` int(10) unsigned NOT NULL COMMENT 'Rate',
  `store` smallint(5) unsigned DEFAULT NULL COMMENT 'Store',
  PRIMARY KEY (`id`),
  KEY `AMASTY_FPC_QUEUE_RATE` (`rate`),
  KEY `AMASTY_FPC_QUEUE_PAGE_STORE_STORE_STORE_ID` (`store`),
  CONSTRAINT `AMASTY_FPC_QUEUE_PAGE_STORE_STORE_STORE_ID` FOREIGN KEY (`store`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8 COMMENT='Amasty FPC Queue Table';


-- drakesterling_old.catalog_category_entity_datetime definition

CREATE TABLE `catalog_category_entity_datetime` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` datetime DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_CATEGORY_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DATETIME_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DATETIME_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DATETIME_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_CATEGORY_ENTITY_DATETIME_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_DTIME_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_DTIME_ENTT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=747 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Datetime Attribute Backend Table';


-- drakesterling_old.catalog_category_entity_decimal definition

CREATE TABLE `catalog_category_entity_decimal` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` decimal(20,6) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_CATEGORY_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DECIMAL_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_CATEGORY_ENTITY_DECIMAL_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_CATEGORY_ENTITY_DECIMAL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_DEC_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_DEC_ENTT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Decimal Attribute Backend Table';


-- drakesterling_old.catalog_category_entity_int definition

CREATE TABLE `catalog_category_entity_int` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` int(11) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_CATEGORY_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_CATEGORY_ENTITY_INT_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_INT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_CATEGORY_ENTITY_INT_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_CATEGORY_ENTITY_INT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_INT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_INT_ENTT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3674 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Integer Attribute Backend Table';


-- drakesterling_old.catalog_category_entity_text definition

CREATE TABLE `catalog_category_entity_text` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` mediumtext COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_CATEGORY_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_CATEGORY_ENTITY_TEXT_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_TEXT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_CATEGORY_ENTITY_TEXT_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_CATEGORY_ENTITY_TEXT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_TEXT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_TEXT_ENTT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1647 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Text Attribute Backend Table';


-- drakesterling_old.catalog_category_entity_varchar definition

CREATE TABLE `catalog_category_entity_varchar` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_CATEGORY_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_CATEGORY_ENTITY_VARCHAR_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_CATEGORY_ENTITY_VARCHAR_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_CATEGORY_ENTITY_VARCHAR_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_CATEGORY_ENTITY_VARCHAR_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_VCHR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_CTGR_ENTT_VCHR_ENTT_ID_CAT_CTGR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9585 DEFAULT CHARSET=utf8 COMMENT='Catalog Category Varchar Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_datetime definition

CREATE TABLE `catalog_product_entity_datetime` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` datetime DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_DATETIME_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_ENTITY_DATETIME_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_DATETIME_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_DTIME_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_DTIME_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=173179 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Datetime Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_decimal definition

CREATE TABLE `catalog_product_entity_decimal` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` decimal(20,6) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_DECIMAL_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_DECIMAL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_DEC_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_DEC_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=556406 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Decimal Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_gallery definition

CREATE TABLE `catalog_product_entity_gallery` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `position` int(11) NOT NULL DEFAULT '0' COMMENT 'Position',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_GALLERY_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_GALLERY_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_PRODUCT_ENTITY_GALLERY_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_ENTITY_GALLERY_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_GALLERY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_GLR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_GLR_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Gallery Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_int definition

CREATE TABLE `catalog_product_entity_int` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` int(11) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_INT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_ENTITY_INT_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_INT_ATTRIBUTE_ID_STORE_ID_VALUE` (`attribute_id`,`store_id`,`value`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_INT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_INT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_INT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6920325 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Integer Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_media_gallery_value definition

CREATE TABLE `catalog_product_entity_media_gallery_value` (
  `value_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Value ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `label` varchar(255) DEFAULT NULL COMMENT 'Label',
  `position` int(10) unsigned DEFAULT NULL COMMENT 'Position',
  `disabled` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Disabled',
  `record_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Record ID',
  PRIMARY KEY (`record_id`),
  KEY `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_VALUE_STORE_ID` (`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_VALUE_ENTITY_ID` (`entity_id`),
  KEY `CATALOG_PRODUCT_ENTITY_MEDIA_GALLERY_VALUE_VALUE_ID` (`value_id`),
  KEY `CAT_PRD_ENTT_MDA_GLR_VAL_ENTT_ID_VAL_ID_STORE_ID` (`entity_id`,`value_id`,`store_id`),
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_VAL_ID_CAT_PRD_ENTT_MDA_GLR_VAL_ID` FOREIGN KEY (`value_id`) REFERENCES `catalog_product_entity_media_gallery` (`value_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=170504 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Media Gallery Attribute Value Table';


-- drakesterling_old.catalog_product_entity_media_gallery_value_video definition

CREATE TABLE `catalog_product_entity_media_gallery_value_video` (
  `value_id` int(10) unsigned NOT NULL COMMENT 'Media Entity ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `provider` varchar(32) DEFAULT NULL COMMENT 'Video provider ID',
  `url` text COMMENT 'Video URL',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `description` text COMMENT 'Page Meta Description',
  `metadata` text COMMENT 'Video meta data',
  PRIMARY KEY (`value_id`,`store_id`),
  KEY `CAT_PRD_ENTT_MDA_GLR_VAL_VIDEO_STORE_ID_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `CAT_PRD_ENTT_MDA_GLR_VAL_VIDEO_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_6FDF205946906B0E653E60AA769899F8` FOREIGN KEY (`value_id`) REFERENCES `catalog_product_entity_media_gallery` (`value_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Video Table';


-- drakesterling_old.catalog_product_entity_text definition

CREATE TABLE `catalog_product_entity_text` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` mediumtext COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_TEXT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_ENTITY_TEXT_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_TEXT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_TEXT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_TEXT_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=745924 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Text Attribute Backend Table';


-- drakesterling_old.catalog_product_entity_varchar definition

CREATE TABLE `catalog_product_entity_varchar` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CATALOG_PRODUCT_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_ENTITY_VARCHAR_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CATALOG_PRODUCT_ENTITY_VARCHAR_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_ENTITY_VARCHAR_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_VCHR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_ENTT_VCHR_ENTT_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4596278 DEFAULT CHARSET=utf8 COMMENT='Catalog Product Varchar Attribute Backend Table';


-- drakesterling_old.catalog_product_option_price definition

CREATE TABLE `catalog_product_option_price` (
  `option_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option Price ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Price',
  `price_type` varchar(7) NOT NULL DEFAULT 'fixed' COMMENT 'Price Type',
  PRIMARY KEY (`option_price_id`),
  UNIQUE KEY `CATALOG_PRODUCT_OPTION_PRICE_OPTION_ID_STORE_ID` (`option_id`,`store_id`),
  KEY `CATALOG_PRODUCT_OPTION_PRICE_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_OPTION_PRICE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_OPT_PRICE_OPT_ID_CAT_PRD_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Price Table';


-- drakesterling_old.catalog_product_option_title definition

CREATE TABLE `catalog_product_option_title` (
  `option_title_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option Title ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  PRIMARY KEY (`option_title_id`),
  UNIQUE KEY `CATALOG_PRODUCT_OPTION_TITLE_OPTION_ID_STORE_ID` (`option_id`,`store_id`),
  KEY `CATALOG_PRODUCT_OPTION_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_OPTION_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_OPT_TTL_OPT_ID_CAT_PRD_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `catalog_product_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Title Table';


-- drakesterling_old.catalog_product_option_type_price definition

CREATE TABLE `catalog_product_option_type_price` (
  `option_type_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option Type Price ID',
  `option_type_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option Type ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Price',
  `price_type` varchar(7) NOT NULL DEFAULT 'fixed' COMMENT 'Price Type',
  PRIMARY KEY (`option_type_price_id`),
  UNIQUE KEY `CATALOG_PRODUCT_OPTION_TYPE_PRICE_OPTION_TYPE_ID_STORE_ID` (`option_type_id`,`store_id`),
  KEY `CATALOG_PRODUCT_OPTION_TYPE_PRICE_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_OPTION_TYPE_PRICE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_B523E3378E8602F376CC415825576B7F` FOREIGN KEY (`option_type_id`) REFERENCES `catalog_product_option_type_value` (`option_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Type Price Table';


-- drakesterling_old.catalog_product_option_type_title definition

CREATE TABLE `catalog_product_option_type_title` (
  `option_type_title_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option Type Title ID',
  `option_type_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option Type ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  PRIMARY KEY (`option_type_title_id`),
  UNIQUE KEY `CATALOG_PRODUCT_OPTION_TYPE_TITLE_OPTION_TYPE_ID_STORE_ID` (`option_type_id`,`store_id`),
  KEY `CATALOG_PRODUCT_OPTION_TYPE_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_OPTION_TYPE_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_C085B9CF2C2A302E8043FDEA1937D6A2` FOREIGN KEY (`option_type_id`) REFERENCES `catalog_product_option_type_value` (`option_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Option Type Title Table';


-- drakesterling_old.catalog_product_super_attribute_label definition

CREATE TABLE `catalog_product_super_attribute_label` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `product_super_attribute_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product Super Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `use_default` smallint(5) unsigned DEFAULT '0' COMMENT 'Use Default Value',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CAT_PRD_SPR_ATTR_LBL_PRD_SPR_ATTR_ID_STORE_ID` (`product_super_attribute_id`,`store_id`),
  KEY `CATALOG_PRODUCT_SUPER_ATTRIBUTE_LABEL_STORE_ID` (`store_id`),
  CONSTRAINT `CATALOG_PRODUCT_SUPER_ATTRIBUTE_LABEL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_309442281DF7784210ED82B2CC51E5D5` FOREIGN KEY (`product_super_attribute_id`) REFERENCES `catalog_product_super_attribute` (`product_super_attribute_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Super Attribute Label Table';


-- drakesterling_old.checkout_agreement_store definition

CREATE TABLE `checkout_agreement_store` (
  `agreement_id` int(10) unsigned NOT NULL COMMENT 'Agreement ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`agreement_id`,`store_id`),
  KEY `CHECKOUT_AGREEMENT_STORE_STORE_ID_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `CHECKOUT_AGREEMENT_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `CHKT_AGRT_STORE_AGRT_ID_CHKT_AGRT_AGRT_ID` FOREIGN KEY (`agreement_id`) REFERENCES `checkout_agreement` (`agreement_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Checkout Agreement Store';


-- drakesterling_old.cms_block_store definition

CREATE TABLE `cms_block_store` (
  `block_id` smallint(6) NOT NULL,
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`block_id`,`store_id`),
  KEY `CMS_BLOCK_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `CMS_BLOCK_STORE_BLOCK_ID_CMS_BLOCK_BLOCK_ID` FOREIGN KEY (`block_id`) REFERENCES `cms_block` (`block_id`) ON DELETE CASCADE,
  CONSTRAINT `CMS_BLOCK_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CMS Block To Store Linkage Table';


-- drakesterling_old.cms_page_store definition

CREATE TABLE `cms_page_store` (
  `page_id` smallint(6) NOT NULL COMMENT 'Entity ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`page_id`,`store_id`),
  KEY `CMS_PAGE_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `CMS_PAGE_STORE_PAGE_ID_CMS_PAGE_PAGE_ID` FOREIGN KEY (`page_id`) REFERENCES `cms_page` (`page_id`) ON DELETE CASCADE,
  CONSTRAINT `CMS_PAGE_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='CMS Page To Store Linkage Table';


-- drakesterling_old.customer_entity definition

CREATE TABLE `customer_entity` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `website_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Website ID',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `group_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Group ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `store_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Store ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `is_active` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Active',
  `disable_auto_group_change` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Disable automatic group change based on VAT ID',
  `created_in` varchar(255) DEFAULT NULL COMMENT 'Created From',
  `prefix` varchar(40) DEFAULT NULL COMMENT 'Name Prefix',
  `firstname` varchar(255) DEFAULT NULL COMMENT 'First Name',
  `middlename` varchar(255) DEFAULT NULL COMMENT 'Middle Name/Initial',
  `lastname` varchar(255) DEFAULT NULL COMMENT 'Last Name',
  `suffix` varchar(40) DEFAULT NULL COMMENT 'Name Suffix',
  `dob` date DEFAULT NULL COMMENT 'Date of Birth',
  `password_hash` varchar(128) DEFAULT NULL COMMENT 'Password_hash',
  `rp_token` varchar(128) DEFAULT NULL COMMENT 'Reset password token',
  `rp_token_created_at` datetime DEFAULT NULL COMMENT 'Reset password token creation time',
  `default_billing` int(10) unsigned DEFAULT NULL COMMENT 'Default Billing Address',
  `default_shipping` int(10) unsigned DEFAULT NULL COMMENT 'Default Shipping Address',
  `taxvat` varchar(50) DEFAULT NULL COMMENT 'Tax/VAT Number',
  `confirmation` varchar(64) DEFAULT NULL COMMENT 'Is Confirmed',
  `gender` smallint(5) unsigned DEFAULT NULL COMMENT 'Gender',
  `failures_num` smallint(6) DEFAULT '0' COMMENT 'Failure Number',
  `first_failure` timestamp NULL DEFAULT NULL COMMENT 'First Failure',
  `lock_expires` timestamp NULL DEFAULT NULL COMMENT 'Lock Expiration Date',
  `session_cutoff` timestamp NULL DEFAULT NULL COMMENT 'Session Cutoff Time',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_EMAIL_WEBSITE_ID` (`email`,`website_id`),
  KEY `CUSTOMER_ENTITY_STORE_ID` (`store_id`),
  KEY `CUSTOMER_ENTITY_WEBSITE_ID` (`website_id`),
  KEY `CUSTOMER_ENTITY_FIRSTNAME` (`firstname`),
  KEY `CUSTOMER_ENTITY_LASTNAME` (`lastname`),
  CONSTRAINT `CUSTOMER_ENTITY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL,
  CONSTRAINT `CUSTOMER_ENTITY_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2249 DEFAULT CHARSET=utf8 COMMENT='Customer Entity';


-- drakesterling_old.customer_entity_datetime definition

CREATE TABLE `customer_entity_datetime` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` datetime DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ENTITY_DATETIME_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CUSTOMER_ENTITY_DATETIME_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CUSTOMER_ENTITY_DATETIME_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Entity Datetime';


-- drakesterling_old.customer_entity_decimal definition

CREATE TABLE `customer_entity_decimal` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ENTITY_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CUSTOMER_ENTITY_DECIMAL_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CUSTOMER_ENTITY_DECIMAL_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Entity Decimal';


-- drakesterling_old.customer_entity_int definition

CREATE TABLE `customer_entity_int` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ENTITY_INT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CUSTOMER_ENTITY_INT_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CUSTOMER_ENTITY_INT_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2103 DEFAULT CHARSET=utf8 COMMENT='Customer Entity Int';


-- drakesterling_old.customer_entity_text definition

CREATE TABLE `customer_entity_text` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` text NOT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ENTITY_TEXT_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `CUSTOMER_ENTITY_TEXT_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CUSTOMER_ENTITY_TEXT_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Entity Text';


-- drakesterling_old.customer_entity_varchar definition

CREATE TABLE `customer_entity_varchar` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ENTITY_VARCHAR_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CUSTOMER_ENTITY_VARCHAR_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CUSTOMER_ENTITY_VARCHAR_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1743 DEFAULT CHARSET=utf8 COMMENT='Customer Entity Varchar';


-- drakesterling_old.design_change definition

CREATE TABLE `design_change` (
  `design_change_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Design Change ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `design` varchar(255) DEFAULT NULL COMMENT 'Design',
  `date_from` date DEFAULT NULL COMMENT 'First Date of Design Activity',
  `date_to` date DEFAULT NULL COMMENT 'Last Date of Design Activity',
  PRIMARY KEY (`design_change_id`),
  KEY `DESIGN_CHANGE_STORE_ID` (`store_id`),
  CONSTRAINT `DESIGN_CHANGE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Design Changes';


-- drakesterling_old.downloadable_link_title definition

CREATE TABLE `downloadable_link_title` (
  `title_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Title ID',
  `link_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Link ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  PRIMARY KEY (`title_id`),
  UNIQUE KEY `DOWNLOADABLE_LINK_TITLE_LINK_ID_STORE_ID` (`link_id`,`store_id`),
  KEY `DOWNLOADABLE_LINK_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `DOWNLOADABLE_LINK_TITLE_LINK_ID_DOWNLOADABLE_LINK_LINK_ID` FOREIGN KEY (`link_id`) REFERENCES `downloadable_link` (`link_id`) ON DELETE CASCADE,
  CONSTRAINT `DOWNLOADABLE_LINK_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Link Title Table';


-- drakesterling_old.downloadable_sample_title definition

CREATE TABLE `downloadable_sample_title` (
  `title_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Title ID',
  `sample_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Sample ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  PRIMARY KEY (`title_id`),
  UNIQUE KEY `DOWNLOADABLE_SAMPLE_TITLE_SAMPLE_ID_STORE_ID` (`sample_id`,`store_id`),
  KEY `DOWNLOADABLE_SAMPLE_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `DL_SAMPLE_TTL_SAMPLE_ID_DL_SAMPLE_SAMPLE_ID` FOREIGN KEY (`sample_id`) REFERENCES `downloadable_sample` (`sample_id`) ON DELETE CASCADE,
  CONSTRAINT `DOWNLOADABLE_SAMPLE_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Sample Title Table';


-- drakesterling_old.eav_attribute_label definition

CREATE TABLE `eav_attribute_label` (
  `attribute_label_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Attribute Label ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`attribute_label_id`),
  KEY `EAV_ATTRIBUTE_LABEL_STORE_ID` (`store_id`),
  KEY `EAV_ATTRIBUTE_LABEL_ATTRIBUTE_ID_STORE_ID` (`attribute_id`,`store_id`),
  CONSTRAINT `EAV_ATTRIBUTE_LABEL_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ATTRIBUTE_LABEL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Attribute Label';


-- drakesterling_old.eav_attribute_option_swatch definition

CREATE TABLE `eav_attribute_option_swatch` (
  `swatch_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Swatch ID',
  `option_id` int(10) unsigned NOT NULL COMMENT 'Option ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `type` smallint(5) unsigned NOT NULL COMMENT 'Swatch type: 0 - text, 1 - visual color, 2 - visual image',
  `value` varchar(255) DEFAULT NULL COMMENT 'Swatch Value',
  PRIMARY KEY (`swatch_id`),
  UNIQUE KEY `EAV_ATTRIBUTE_OPTION_SWATCH_STORE_ID_OPTION_ID` (`store_id`,`option_id`),
  KEY `EAV_ATTRIBUTE_OPTION_SWATCH_SWATCH_ID` (`swatch_id`),
  KEY `EAV_ATTR_OPT_SWATCH_OPT_ID_EAV_ATTR_OPT_OPT_ID` (`option_id`),
  CONSTRAINT `EAV_ATTRIBUTE_OPTION_SWATCH_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ATTR_OPT_SWATCH_OPT_ID_EAV_ATTR_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `eav_attribute_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Magento Swatches table';


-- drakesterling_old.eav_attribute_option_value definition

CREATE TABLE `eav_attribute_option_value` (
  `value_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `option_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Option ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  KEY `EAV_ATTRIBUTE_OPTION_VALUE_OPTION_ID` (`option_id`),
  KEY `EAV_ATTRIBUTE_OPTION_VALUE_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_ATTRIBUTE_OPTION_VALUE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ATTR_OPT_VAL_OPT_ID_EAV_ATTR_OPT_OPT_ID` FOREIGN KEY (`option_id`) REFERENCES `eav_attribute_option` (`option_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10022 DEFAULT CHARSET=utf8 COMMENT='Eav Attribute Option Value';


-- drakesterling_old.eav_entity definition

CREATE TABLE `eav_entity` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_set_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute Set ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `parent_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Parent ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `is_active` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Defines Is Entity Active',
  PRIMARY KEY (`entity_id`),
  KEY `EAV_ENTITY_ENTITY_TYPE_ID` (`entity_type_id`),
  KEY `EAV_ENTITY_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_ENTITY_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity';


-- drakesterling_old.eav_entity_datetime definition

CREATE TABLE `eav_entity_datetime` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` datetime DEFAULT NULL COMMENT 'Attribute Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `EAV_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `EAV_ENTITY_DATETIME_STORE_ID` (`store_id`),
  KEY `EAV_ENTITY_DATETIME_ATTRIBUTE_ID_VALUE` (`attribute_id`,`value`),
  KEY `EAV_ENTITY_DATETIME_ENTITY_TYPE_ID_VALUE` (`entity_type_id`,`value`),
  CONSTRAINT `EAV_ENTITY_DATETIME_ENTITY_ID_EAV_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `eav_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_DATETIME_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTT_DTIME_ENTT_TYPE_ID_EAV_ENTT_TYPE_ENTT_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Value Prefix';


-- drakesterling_old.eav_entity_decimal definition

CREATE TABLE `eav_entity_decimal` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Attribute Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `EAV_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `EAV_ENTITY_DECIMAL_STORE_ID` (`store_id`),
  KEY `EAV_ENTITY_DECIMAL_ATTRIBUTE_ID_VALUE` (`attribute_id`,`value`),
  KEY `EAV_ENTITY_DECIMAL_ENTITY_TYPE_ID_VALUE` (`entity_type_id`,`value`),
  CONSTRAINT `EAV_ENTITY_DECIMAL_ENTITY_ID_EAV_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `eav_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_DECIMAL_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_DECIMAL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Value Prefix';


-- drakesterling_old.eav_entity_int definition

CREATE TABLE `eav_entity_int` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT 'Attribute Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `EAV_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `EAV_ENTITY_INT_STORE_ID` (`store_id`),
  KEY `EAV_ENTITY_INT_ATTRIBUTE_ID_VALUE` (`attribute_id`,`value`),
  KEY `EAV_ENTITY_INT_ENTITY_TYPE_ID_VALUE` (`entity_type_id`,`value`),
  CONSTRAINT `EAV_ENTITY_INT_ENTITY_ID_EAV_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `eav_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_INT_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_INT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Value Prefix';


-- drakesterling_old.eav_entity_store definition

CREATE TABLE `eav_entity_store` (
  `entity_store_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity Store ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `increment_prefix` varchar(20) DEFAULT NULL COMMENT 'Increment Prefix',
  `increment_last_id` varchar(50) DEFAULT NULL COMMENT 'Last Incremented ID',
  PRIMARY KEY (`entity_store_id`),
  KEY `EAV_ENTITY_STORE_ENTITY_TYPE_ID` (`entity_type_id`),
  KEY `EAV_ENTITY_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_ENTITY_STORE_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Store';


-- drakesterling_old.eav_entity_text definition

CREATE TABLE `eav_entity_text` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` text NOT NULL COMMENT 'Attribute Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `EAV_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `EAV_ENTITY_TEXT_ENTITY_TYPE_ID` (`entity_type_id`),
  KEY `EAV_ENTITY_TEXT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `EAV_ENTITY_TEXT_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_ENTITY_TEXT_ENTITY_ID_EAV_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `eav_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_TEXT_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_TEXT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Value Prefix';


-- drakesterling_old.eav_entity_varchar definition

CREATE TABLE `eav_entity_varchar` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `entity_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity Type ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Attribute Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `EAV_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_STORE_ID` (`entity_id`,`attribute_id`,`store_id`),
  KEY `EAV_ENTITY_VARCHAR_STORE_ID` (`store_id`),
  KEY `EAV_ENTITY_VARCHAR_ATTRIBUTE_ID_VALUE` (`attribute_id`,`value`),
  KEY `EAV_ENTITY_VARCHAR_ENTITY_TYPE_ID_VALUE` (`entity_type_id`,`value`),
  CONSTRAINT `EAV_ENTITY_VARCHAR_ENTITY_ID_EAV_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `eav_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_VARCHAR_ENTITY_TYPE_ID_EAV_ENTITY_TYPE_ENTITY_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_ENTITY_VARCHAR_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Entity Value Prefix';


-- drakesterling_old.eav_form_type definition

CREATE TABLE `eav_form_type` (
  `type_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Type ID',
  `code` varchar(64) NOT NULL COMMENT 'Code',
  `label` varchar(255) NOT NULL COMMENT 'Label',
  `is_system` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is System',
  `theme` varchar(64) DEFAULT NULL COMMENT 'Theme',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `EAV_FORM_TYPE_CODE_THEME_STORE_ID` (`code`,`theme`,`store_id`),
  KEY `EAV_FORM_TYPE_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_FORM_TYPE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COMMENT='Eav Form Type';


-- drakesterling_old.eav_form_type_entity definition

CREATE TABLE `eav_form_type_entity` (
  `type_id` smallint(5) unsigned NOT NULL COMMENT 'Type ID',
  `entity_type_id` smallint(5) unsigned NOT NULL COMMENT 'Entity Type ID',
  PRIMARY KEY (`type_id`,`entity_type_id`),
  KEY `EAV_FORM_TYPE_ENTITY_ENTITY_TYPE_ID` (`entity_type_id`),
  CONSTRAINT `EAV_FORM_TYPE_ENTITY_TYPE_ID_EAV_FORM_TYPE_TYPE_ID` FOREIGN KEY (`type_id`) REFERENCES `eav_form_type` (`type_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_FORM_TYPE_ENTT_ENTT_TYPE_ID_EAV_ENTT_TYPE_ENTT_TYPE_ID` FOREIGN KEY (`entity_type_id`) REFERENCES `eav_entity_type` (`entity_type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Form Type Entity';


-- drakesterling_old.elasticsuite_tracker_log_customer_link definition

CREATE TABLE `elasticsuite_tracker_log_customer_link` (
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `session_id` varchar(255) NOT NULL COMMENT 'Session ID',
  `visitor_id` varchar(255) NOT NULL COMMENT 'Visitor ID',
  `delete_after` datetime DEFAULT NULL COMMENT 'Delete after',
  PRIMARY KEY (`customer_id`,`session_id`,`visitor_id`),
  CONSTRAINT `ELASTICSUITE_TRACKER_LOG_CSTR_LNK_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.email_campaign definition

CREATE TABLE `email_campaign` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `campaign_id` int(10) unsigned NOT NULL COMMENT 'Campaign ID',
  `email` varchar(255) NOT NULL DEFAULT '' COMMENT 'Contact Email',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `sent_at` timestamp NULL DEFAULT NULL COMMENT 'Send Date',
  `order_increment_id` varchar(50) NOT NULL COMMENT 'Order Increment ID',
  `quote_id` int(10) unsigned NOT NULL COMMENT 'Sales Quote ID',
  `message` varchar(255) NOT NULL DEFAULT '' COMMENT 'Error Message',
  `checkout_method` varchar(255) NOT NULL DEFAULT '' COMMENT 'Checkout Method Used',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `event_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'Event Name',
  `send_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'Send Id',
  `send_status` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Campaign send status',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`id`),
  KEY `EMAIL_CAMPAIGN_STORE_ID` (`store_id`),
  KEY `EMAIL_CAMPAIGN_CAMPAIGN_ID` (`campaign_id`),
  KEY `EMAIL_CAMPAIGN_EMAIL` (`email`),
  KEY `EMAIL_CAMPAIGN_SEND_ID` (`send_id`),
  KEY `EMAIL_CAMPAIGN_SEND_STATUS` (`send_status`),
  KEY `EMAIL_CAMPAIGN_CREATED_AT` (`created_at`),
  KEY `EMAIL_CAMPAIGN_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_CAMPAIGN_SENT_AT` (`sent_at`),
  KEY `EMAIL_CAMPAIGN_EVENT_NAME` (`event_name`),
  KEY `EMAIL_CAMPAIGN_MESSAGE` (`message`),
  KEY `EMAIL_CAMPAIGN_QUOTE_ID` (`quote_id`),
  KEY `EMAIL_CAMPAIGN_CUSTOMER_ID` (`customer_id`),
  CONSTRAINT `EMAIL_CAMPAIGN_STORE_ID_CORE/STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Connector Campaigns';


-- drakesterling_old.googleoptimizer_code definition

CREATE TABLE `googleoptimizer_code` (
  `code_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Google experiment code ID',
  `entity_id` int(10) unsigned NOT NULL COMMENT 'Optimized entity ID product ID or catalog ID',
  `entity_type` varchar(50) DEFAULT NULL COMMENT 'Optimized entity type',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `experiment_script` text COMMENT 'Google experiment script',
  PRIMARY KEY (`code_id`),
  UNIQUE KEY `GOOGLEOPTIMIZER_CODE_STORE_ID_ENTITY_ID_ENTITY_TYPE` (`store_id`,`entity_id`,`entity_type`),
  CONSTRAINT `GOOGLEOPTIMIZER_CODE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Google Experiment code';


-- drakesterling_old.layout_link definition

CREATE TABLE `layout_link` (
  `layout_link_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Link ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `theme_id` int(10) unsigned NOT NULL COMMENT 'Theme ID',
  `layout_update_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Layout Update ID',
  `is_temporary` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Defines whether Layout Update is Temporary',
  PRIMARY KEY (`layout_link_id`),
  KEY `LAYOUT_LINK_LAYOUT_UPDATE_ID` (`layout_update_id`),
  KEY `LAYOUT_LINK_STORE_ID_THEME_ID_LAYOUT_UPDATE_ID_IS_TEMPORARY` (`store_id`,`theme_id`,`layout_update_id`,`is_temporary`),
  KEY `LAYOUT_LINK_THEME_ID_THEME_THEME_ID` (`theme_id`),
  CONSTRAINT `LAYOUT_LINK_LAYOUT_UPDATE_ID_LAYOUT_UPDATE_LAYOUT_UPDATE_ID` FOREIGN KEY (`layout_update_id`) REFERENCES `layout_update` (`layout_update_id`) ON DELETE CASCADE,
  CONSTRAINT `LAYOUT_LINK_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `LAYOUT_LINK_THEME_ID_THEME_THEME_ID` FOREIGN KEY (`theme_id`) REFERENCES `theme` (`theme_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='Layout Link';


-- drakesterling_old.login_as_customer_assistance_allowed definition

CREATE TABLE `login_as_customer_assistance_allowed` (
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  PRIMARY KEY (`customer_id`),
  CONSTRAINT `LOGIN_AS_CSTR_ASSISTANCE_ALLOWED_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Magento Login as Customer Assistance Allowed Table';


-- drakesterling_old.mageplaza_blog_comment definition

CREATE TABLE `mageplaza_blog_comment` (
  `comment_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Comment ID',
  `post_id` int(10) unsigned DEFAULT NULL COMMENT 'Post ID',
  `entity_id` int(10) unsigned DEFAULT NULL COMMENT 'User ID',
  `has_reply` int(5) unsigned DEFAULT NULL COMMENT 'Comment has reply',
  `is_reply` int(5) unsigned DEFAULT NULL COMMENT 'Is reply comment',
  `reply_id` int(10) unsigned DEFAULT NULL COMMENT 'Reply ID',
  `content` mediumtext,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `status` int(5) unsigned NOT NULL DEFAULT '3' COMMENT 'Status',
  `store_ids` int(11) NOT NULL DEFAULT '0' COMMENT 'Store Id',
  `user_name` mediumtext COMMENT 'User Name',
  `user_email` mediumtext COMMENT 'User Email',
  `import_source` mediumtext COMMENT 'Import Source',
  PRIMARY KEY (`comment_id`),
  KEY `MAGEPLAZA_BLOG_COMMENT_COMMENT_ID` (`comment_id`),
  KEY `MAGEPLAZA_BLOG_COMMENT_ENTITY_ID` (`entity_id`),
  KEY `MAGEPLAZA_BLOG_COMMENT_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` (`post_id`),
  CONSTRAINT `MAGEPLAZA_BLOG_COMMENT_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_COMMENT_POST_ID_MAGEPLAZA_BLOG_POST_POST_ID` FOREIGN KEY (`post_id`) REFERENCES `mageplaza_blog_post` (`post_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Comment Table';


-- drakesterling_old.mageplaza_blog_comment_like definition

CREATE TABLE `mageplaza_blog_comment_like` (
  `like_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'like ID',
  `comment_id` int(10) unsigned DEFAULT NULL COMMENT 'Comment ID',
  `entity_id` int(10) unsigned DEFAULT NULL COMMENT 'User ID',
  PRIMARY KEY (`like_id`),
  KEY `MAGEPLAZA_BLOG_COMMENT_LIKE_LIKE_ID` (`like_id`),
  KEY `FK_1AA6C994694449283752B6F4C2373B42` (`comment_id`),
  KEY `MAGEPLAZA_BLOG_COMMENT_LIKE_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` (`entity_id`),
  CONSTRAINT `FK_1AA6C994694449283752B6F4C2373B42` FOREIGN KEY (`comment_id`) REFERENCES `mageplaza_blog_comment` (`comment_id`) ON DELETE CASCADE,
  CONSTRAINT `MAGEPLAZA_BLOG_COMMENT_LIKE_ENTITY_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Mageplaza Blog Comment Like Table';


-- drakesterling_old.newsletter_queue_store_link definition

CREATE TABLE `newsletter_queue_store_link` (
  `queue_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Queue ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`queue_id`,`store_id`),
  KEY `NEWSLETTER_QUEUE_STORE_LINK_STORE_ID` (`store_id`),
  CONSTRAINT `NEWSLETTER_QUEUE_STORE_LINK_QUEUE_ID_NEWSLETTER_QUEUE_QUEUE_ID` FOREIGN KEY (`queue_id`) REFERENCES `newsletter_queue` (`queue_id`) ON DELETE CASCADE,
  CONSTRAINT `NEWSLETTER_QUEUE_STORE_LINK_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Newsletter Queue Store Link';


-- drakesterling_old.newsletter_subscriber definition

CREATE TABLE `newsletter_subscriber` (
  `subscriber_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Subscriber ID',
  `store_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Store ID',
  `change_status_at` timestamp NULL DEFAULT NULL COMMENT 'Change Status At',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `subscriber_email` varchar(150) DEFAULT NULL COMMENT 'Subscriber Email',
  `subscriber_status` int(11) NOT NULL DEFAULT '0' COMMENT 'Subscriber Status',
  `subscriber_confirm_code` varchar(32) DEFAULT 'NULL' COMMENT 'Subscriber Confirm Code',
  PRIMARY KEY (`subscriber_id`),
  KEY `NEWSLETTER_SUBSCRIBER_CUSTOMER_ID` (`customer_id`),
  KEY `NEWSLETTER_SUBSCRIBER_STORE_ID` (`store_id`),
  KEY `NEWSLETTER_SUBSCRIBER_SUBSCRIBER_EMAIL` (`subscriber_email`),
  CONSTRAINT `NEWSLETTER_SUBSCRIBER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2719 DEFAULT CHARSET=utf8 COMMENT='Newsletter Subscriber';


-- drakesterling_old.oauth_token definition

CREATE TABLE `oauth_token` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `consumer_id` int(10) unsigned DEFAULT NULL COMMENT 'Oauth Consumer ID',
  `admin_id` int(10) unsigned DEFAULT NULL COMMENT 'Admin user ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer user ID',
  `type` varchar(16) NOT NULL COMMENT 'Token Type',
  `token` varchar(32) NOT NULL COMMENT 'Token',
  `secret` varchar(128) NOT NULL COMMENT 'Token Secret',
  `verifier` varchar(32) DEFAULT NULL COMMENT 'Token Verifier',
  `callback_url` text NOT NULL COMMENT 'Token Callback URL',
  `revoked` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Token revoked',
  `authorized` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Token authorized',
  `user_type` int(11) DEFAULT NULL COMMENT 'User type',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Token creation timestamp',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `OAUTH_TOKEN_TOKEN` (`token`),
  KEY `OAUTH_TOKEN_CONSUMER_ID` (`consumer_id`),
  KEY `OAUTH_TOKEN_ADMIN_ID_ADMIN_USER_USER_ID` (`admin_id`),
  KEY `OAUTH_TOKEN_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` (`customer_id`),
  KEY `OAUTH_TOKEN_CREATED_AT` (`created_at`),
  CONSTRAINT `OAUTH_TOKEN_ADMIN_ID_ADMIN_USER_USER_ID` FOREIGN KEY (`admin_id`) REFERENCES `admin_user` (`user_id`) ON DELETE CASCADE,
  CONSTRAINT `OAUTH_TOKEN_CONSUMER_ID_OAUTH_CONSUMER_ENTITY_ID` FOREIGN KEY (`consumer_id`) REFERENCES `oauth_consumer` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `OAUTH_TOKEN_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='OAuth Tokens';


-- drakesterling_old.paypal_billing_agreement definition

CREATE TABLE `paypal_billing_agreement` (
  `agreement_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Agreement ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `method_code` varchar(32) NOT NULL COMMENT 'Method Code',
  `reference_id` varchar(32) NOT NULL COMMENT 'Reference ID',
  `status` varchar(20) NOT NULL COMMENT 'Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated At',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `agreement_label` varchar(255) DEFAULT NULL COMMENT 'Agreement Label',
  PRIMARY KEY (`agreement_id`),
  KEY `PAYPAL_BILLING_AGREEMENT_CUSTOMER_ID` (`customer_id`),
  KEY `PAYPAL_BILLING_AGREEMENT_STORE_ID` (`store_id`),
  CONSTRAINT `PAYPAL_BILLING_AGREEMENT_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PAYPAL_BILLING_AGREEMENT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Billing Agreement';


-- drakesterling_old.persistent_session definition

CREATE TABLE `persistent_session` (
  `persistent_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Session ID',
  `key` varchar(50) NOT NULL COMMENT 'Unique cookie key',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `info` text COMMENT 'Session Data',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`persistent_id`),
  UNIQUE KEY `PERSISTENT_SESSION_KEY` (`key`),
  UNIQUE KEY `PERSISTENT_SESSION_CUSTOMER_ID` (`customer_id`),
  KEY `PERSISTENT_SESSION_UPDATED_AT` (`updated_at`),
  KEY `PERSISTENT_SESSION_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` (`website_id`),
  CONSTRAINT `PERSISTENT_SESSION_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PERSISTENT_SESSION_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1051 DEFAULT CHARSET=utf8 COMMENT='Persistent Session';


-- drakesterling_old.plugincompany_fraudprevention_rule_store definition

CREATE TABLE `plugincompany_fraudprevention_rule_store` (
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`rule_id`,`store_id`),
  KEY `PLUGINCOMPANY_FRAUDPREVENTION_RULE_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `FK_28215BF9542C636364EF98E4B68CB9B0` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_54BC62FB8F705BA86EBAA943F2BCA721` FOREIGN KEY (`rule_id`) REFERENCES `plugincompany_fraudprevention_rule` (`rule_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rule To Store Linkage Table';


-- drakesterling_old.plugincompany_fraudprevention_suspicion_store definition

CREATE TABLE `plugincompany_fraudprevention_suspicion_store` (
  `suspicion_id` int(10) unsigned NOT NULL COMMENT 'Suspicion ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`suspicion_id`,`store_id`),
  KEY `PLUGINCOMPANY_FRAUDPREVENTION_SUSPICION_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `FK_C59632180F37969E7F7BFCD8AED729A7` FOREIGN KEY (`suspicion_id`) REFERENCES `plugincompany_fraudprevention_suspicion` (`suspicion_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_F07DB7D861E56C07265B41A964086296` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Suspicion To Store Linkage Table';


-- drakesterling_old.product_alert_price definition

CREATE TABLE `product_alert_price` (
  `alert_price_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Product alert price ID',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `price` decimal(20,6) NOT NULL DEFAULT '0.000000' COMMENT 'Price amount',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `add_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Product alert add date',
  `last_send_date` timestamp NULL DEFAULT NULL COMMENT 'Product alert last send date',
  `send_count` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Product alert send count',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Product alert status',
  `store_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`alert_price_id`),
  KEY `PRODUCT_ALERT_PRICE_CUSTOMER_ID` (`customer_id`),
  KEY `PRODUCT_ALERT_PRICE_PRODUCT_ID` (`product_id`),
  KEY `PRODUCT_ALERT_PRICE_WEBSITE_ID` (`website_id`),
  KEY `PRODUCT_ALERT_PRICE_STORE_ID` (`store_id`),
  CONSTRAINT `PRODUCT_ALERT_PRICE_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_PRICE_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_PRICE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_PRICE_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Product Alert Price';


-- drakesterling_old.product_alert_stock definition

CREATE TABLE `product_alert_stock` (
  `alert_stock_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Product alert stock ID',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID',
  `add_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Product alert add date',
  `send_date` timestamp NULL DEFAULT NULL COMMENT 'Product alert send date',
  `send_count` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Send Count',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Product alert status',
  `store_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`alert_stock_id`),
  KEY `PRODUCT_ALERT_STOCK_CUSTOMER_ID` (`customer_id`),
  KEY `PRODUCT_ALERT_STOCK_PRODUCT_ID` (`product_id`),
  KEY `PRODUCT_ALERT_STOCK_WEBSITE_ID` (`website_id`),
  KEY `PRODUCT_ALERT_STOCK_STORE_ID` (`store_id`),
  CONSTRAINT `PRODUCT_ALERT_STOCK_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_STOCK_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_STOCK_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `PRODUCT_ALERT_STOCK_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Product Alert Stock';


-- drakesterling_old.quote definition

CREATE TABLE `quote` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `converted_at` timestamp NULL DEFAULT NULL COMMENT 'Converted At',
  `is_active` smallint(5) unsigned DEFAULT '1' COMMENT 'Is Active',
  `is_virtual` smallint(5) unsigned DEFAULT '0' COMMENT 'Is Virtual',
  `is_multi_shipping` smallint(5) unsigned DEFAULT '0' COMMENT 'Is Multi Shipping',
  `items_count` int(10) unsigned DEFAULT '0' COMMENT 'Items Count',
  `items_qty` decimal(12,4) DEFAULT '0.0000' COMMENT 'Items Qty',
  `orig_order_id` int(10) unsigned DEFAULT '0' COMMENT 'Orig Order ID',
  `store_to_base_rate` decimal(12,4) DEFAULT '0.0000' COMMENT 'Store To Base Rate',
  `store_to_quote_rate` decimal(12,4) DEFAULT '0.0000' COMMENT 'Store To Quote Rate',
  `base_currency_code` varchar(255) DEFAULT NULL COMMENT 'Base Currency Code',
  `store_currency_code` varchar(255) DEFAULT NULL COMMENT 'Store Currency Code',
  `quote_currency_code` varchar(255) DEFAULT NULL COMMENT 'Quote Currency Code',
  `grand_total` decimal(20,4) DEFAULT '0.0000' COMMENT 'Grand Total',
  `base_grand_total` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Grand Total',
  `checkout_method` varchar(255) DEFAULT NULL COMMENT 'Checkout Method',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `customer_tax_class_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer Tax Class ID',
  `customer_group_id` int(10) unsigned DEFAULT '0' COMMENT 'Customer Group ID',
  `customer_email` varchar(255) DEFAULT NULL COMMENT 'Customer Email',
  `customer_prefix` varchar(40) DEFAULT NULL COMMENT 'Customer Prefix',
  `customer_firstname` varchar(255) DEFAULT NULL COMMENT 'Customer Firstname',
  `customer_middlename` varchar(40) DEFAULT NULL COMMENT 'Customer Middlename',
  `customer_lastname` varchar(255) DEFAULT NULL COMMENT 'Customer Lastname',
  `customer_suffix` varchar(40) DEFAULT NULL COMMENT 'Customer Suffix',
  `customer_dob` datetime DEFAULT NULL COMMENT 'Customer Dob',
  `customer_note` text COMMENT 'Customer Note',
  `customer_note_notify` smallint(5) unsigned DEFAULT '1' COMMENT 'Customer Note Notify',
  `customer_is_guest` smallint(5) unsigned DEFAULT '0' COMMENT 'Customer Is Guest',
  `remote_ip` varchar(45) DEFAULT NULL COMMENT 'Remote Ip',
  `applied_rule_ids` varchar(255) DEFAULT NULL COMMENT 'Applied Rule Ids',
  `reserved_order_id` varchar(64) DEFAULT NULL COMMENT 'Reserved Order ID',
  `password_hash` varchar(255) DEFAULT NULL COMMENT 'Password Hash',
  `coupon_code` varchar(255) DEFAULT NULL COMMENT 'Coupon Code',
  `global_currency_code` varchar(255) DEFAULT NULL COMMENT 'Global Currency Code',
  `base_to_global_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Global Rate',
  `base_to_quote_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Quote Rate',
  `customer_taxvat` varchar(255) DEFAULT NULL COMMENT 'Customer Taxvat',
  `customer_gender` varchar(255) DEFAULT NULL COMMENT 'Customer Gender',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `base_subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal',
  `subtotal_with_discount` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal With Discount',
  `base_subtotal_with_discount` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal With Discount',
  `is_changed` int(10) unsigned DEFAULT NULL COMMENT 'Is Changed',
  `trigger_recollect` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Trigger Recollect',
  `ext_shipping_info` text COMMENT 'Ext Shipping Info',
  `is_persistent` smallint(5) unsigned DEFAULT '0' COMMENT 'Is Quote Persistent',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `mailchimp_abandonedcart_flag` tinyint(1) NOT NULL COMMENT 'Retrieved from Mailchimp',
  `mailchimp_campaign_id` varchar(16) DEFAULT NULL COMMENT 'Campaign',
  `mailchimp_landing_page` text NOT NULL COMMENT 'Landing Page',
  `fee` decimal(10,0) DEFAULT '0' COMMENT 'Fee',
  `base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base Fee',
  `transaction_fee` decimal(10,0) DEFAULT '0' COMMENT 'TransactionFee',
  `transaction_base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base TransactionFee',
  `delivery_timestamp` text COMMENT 'Delivery Timestamp',
  PRIMARY KEY (`entity_id`),
  KEY `QUOTE_CUSTOMER_ID_STORE_ID_IS_ACTIVE` (`customer_id`,`store_id`,`is_active`),
  KEY `QUOTE_STORE_ID_UPDATED_AT` (`store_id`,`updated_at`),
  CONSTRAINT `QUOTE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=21870 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote';


-- drakesterling_old.quote_address definition

CREATE TABLE `quote_address` (
  `address_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Address ID',
  `quote_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Quote ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `save_in_address_book` smallint(6) DEFAULT '0' COMMENT 'Save In Address Book',
  `customer_address_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer Address ID',
  `address_type` varchar(10) DEFAULT NULL COMMENT 'Address Type',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `prefix` varchar(40) DEFAULT NULL COMMENT 'Prefix',
  `firstname` varchar(255) DEFAULT NULL,
  `middlename` varchar(40) DEFAULT NULL,
  `lastname` varchar(255) DEFAULT NULL,
  `suffix` varchar(40) DEFAULT NULL COMMENT 'Suffix',
  `company` varchar(255) DEFAULT NULL COMMENT 'Company',
  `street` varchar(255) DEFAULT NULL COMMENT 'Street',
  `city` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `region_id` int(10) unsigned DEFAULT NULL COMMENT 'Region ID',
  `postcode` varchar(20) DEFAULT NULL COMMENT 'Postcode',
  `country_id` varchar(30) DEFAULT NULL COMMENT 'Country ID',
  `telephone` varchar(255) DEFAULT NULL,
  `fax` varchar(255) DEFAULT NULL,
  `same_as_billing` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Same As Billing',
  `collect_shipping_rates` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Collect Shipping Rates',
  `shipping_method` varchar(120) DEFAULT NULL,
  `shipping_description` varchar(255) DEFAULT NULL COMMENT 'Shipping Description',
  `weight` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Weight',
  `subtotal` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal',
  `base_subtotal` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Subtotal',
  `subtotal_with_discount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal With Discount',
  `base_subtotal_with_discount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Subtotal With Discount',
  `tax_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Tax Amount',
  `base_tax_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Tax Amount',
  `shipping_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Shipping Amount',
  `base_shipping_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Shipping Amount',
  `shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Tax Amount',
  `base_shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Tax Amount',
  `discount_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount',
  `base_discount_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Discount Amount',
  `grand_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Grand Total',
  `base_grand_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Grand Total',
  `customer_notes` text COMMENT 'Customer Notes',
  `applied_taxes` text COMMENT 'Applied Taxes',
  `discount_description` varchar(255) DEFAULT NULL COMMENT 'Discount Description',
  `shipping_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Amount',
  `base_shipping_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Amount',
  `subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Incl Tax',
  `base_subtotal_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Total Incl Tax',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `shipping_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Tax Compensation Amount',
  `base_shipping_discount_tax_compensation_amnt` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Tax Compensation Amount',
  `shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Incl Tax',
  `base_shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Incl Tax',
  `free_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Free Shipping',
  `vat_id` text COMMENT 'Vat ID',
  `vat_is_valid` smallint(6) DEFAULT NULL COMMENT 'Vat Is Valid',
  `vat_request_id` text COMMENT 'Vat Request ID',
  `vat_request_date` text COMMENT 'Vat Request Date',
  `vat_request_success` smallint(6) DEFAULT NULL COMMENT 'Vat Request Success',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `fee` decimal(10,0) DEFAULT '0' COMMENT 'Fee',
  `base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base Fee',
  `transaction_fee` decimal(10,0) DEFAULT '0' COMMENT 'TransactionFee',
  `transaction_base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base TransactionFee',
  `carrier_type` text COMMENT 'ShipperHQ Carrier Type',
  `carrier_id` text COMMENT 'ShipperHQ Carrier ID',
  `carriergroup_shipping_details` text COMMENT 'ShipperHQ Carrier Group Details',
  `is_checkout` smallint(6) NOT NULL DEFAULT '0' COMMENT 'ShipperHQ Checkout Flag',
  `split_rates` smallint(6) NOT NULL DEFAULT '0' COMMENT 'ShipperHQ Split Rates Flag',
  `checkout_display_merged` smallint(6) NOT NULL DEFAULT '1' COMMENT 'ShipperHQ Checkout Display Type',
  `carriergroup_shipping_html` text COMMENT 'ShipperHQ Carrier Group HTML',
  `destination_type` text COMMENT 'ShipperHQ Address Type',
  `validation_status` text COMMENT 'ShipperHQ Address Validation Status',
  `validated_country_code` text COMMENT 'Validated Country Code',
  `validated_vat_number` text COMMENT 'Validated Vat Number',
  PRIMARY KEY (`address_id`),
  KEY `QUOTE_ADDRESS_QUOTE_ID` (`quote_id`),
  CONSTRAINT `QUOTE_ADDRESS_QUOTE_ID_QUOTE_ENTITY_ID` FOREIGN KEY (`quote_id`) REFERENCES `quote` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53340 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Address';


-- drakesterling_old.quote_id_mask definition

CREATE TABLE `quote_id_mask` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `quote_id` int(10) unsigned NOT NULL COMMENT 'Quote ID',
  `masked_id` varchar(32) DEFAULT NULL COMMENT 'Masked ID',
  PRIMARY KEY (`entity_id`,`quote_id`),
  KEY `QUOTE_ID_MASK_QUOTE_ID` (`quote_id`),
  KEY `QUOTE_ID_MASK_MASKED_ID` (`masked_id`),
  CONSTRAINT `QUOTE_ID_MASK_QUOTE_ID_QUOTE_ENTITY_ID` FOREIGN KEY (`quote_id`) REFERENCES `quote` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10627 DEFAULT CHARSET=utf8 COMMENT='Quote ID and masked ID mapping';


-- drakesterling_old.quote_item definition

CREATE TABLE `quote_item` (
  `item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Item ID',
  `quote_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Quote ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `parent_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent Item ID',
  `is_virtual` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Virtual',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `description` text COMMENT 'Description',
  `applied_rule_ids` text COMMENT 'Applied Rule Ids',
  `additional_data` text COMMENT 'Additional Data',
  `is_qty_decimal` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Qty Decimal',
  `no_discount` smallint(5) unsigned DEFAULT '0' COMMENT 'No Discount',
  `weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Weight',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `base_price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Price',
  `custom_price` decimal(20,4) DEFAULT NULL COMMENT 'Custom Price',
  `discount_percent` decimal(12,4) DEFAULT '0.0000' COMMENT 'Discount Percent',
  `discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Discount Amount',
  `base_discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Discount Amount',
  `tax_percent` decimal(12,4) DEFAULT '0.0000' COMMENT 'Tax Percent',
  `tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Tax Amount',
  `base_tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Tax Amount',
  `row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Row Total',
  `base_row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Row Total',
  `row_total_with_discount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Row Total With Discount',
  `row_weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Row Weight',
  `product_type` varchar(255) DEFAULT NULL COMMENT 'Product Type',
  `base_tax_before_discount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Before Discount',
  `tax_before_discount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Before Discount',
  `original_custom_price` decimal(20,4) DEFAULT NULL COMMENT 'Original Custom Price',
  `redirect_url` varchar(255) DEFAULT NULL COMMENT 'Redirect Url',
  `base_cost` decimal(12,4) DEFAULT NULL COMMENT 'Base Cost',
  `price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Price Incl Tax',
  `base_price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Price Incl Tax',
  `row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Row Total Incl Tax',
  `base_row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total Incl Tax',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `free_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Free Shipping',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `weee_tax_applied` text COMMENT 'Weee Tax Applied',
  `weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Amount',
  `weee_tax_applied_row_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Row Amount',
  `weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Disposition',
  `weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Row Disposition',
  `base_weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Amount',
  `base_weee_tax_applied_row_amnt` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Row Amnt',
  `base_weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Disposition',
  `base_weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Row Disposition',
  `carriergroup_id` text COMMENT 'Carrier Group ID',
  `carriergroup` text COMMENT 'ShipperHQ Carrier Group',
  `carriergroup_shipping` text COMMENT 'ShipperHQ Shipping Description',
  PRIMARY KEY (`item_id`),
  KEY `QUOTE_ITEM_PARENT_ITEM_ID` (`parent_item_id`),
  KEY `QUOTE_ITEM_PRODUCT_ID` (`product_id`),
  KEY `QUOTE_ITEM_QUOTE_ID` (`quote_id`),
  KEY `QUOTE_ITEM_STORE_ID` (`store_id`),
  CONSTRAINT `QUOTE_ITEM_PARENT_ITEM_ID_QUOTE_ITEM_ITEM_ID` FOREIGN KEY (`parent_item_id`) REFERENCES `quote_item` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `QUOTE_ITEM_QUOTE_ID_QUOTE_ENTITY_ID` FOREIGN KEY (`quote_id`) REFERENCES `quote` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `QUOTE_ITEM_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=32645 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Item';


-- drakesterling_old.quote_item_option definition

CREATE TABLE `quote_item_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
  `item_id` int(10) unsigned NOT NULL COMMENT 'Item ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `value` text COMMENT 'Value',
  PRIMARY KEY (`option_id`),
  KEY `QUOTE_ITEM_OPTION_ITEM_ID` (`item_id`),
  CONSTRAINT `QUOTE_ITEM_OPTION_ITEM_ID_QUOTE_ITEM_ITEM_ID` FOREIGN KEY (`item_id`) REFERENCES `quote_item` (`item_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=32644 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Item Option';


-- drakesterling_old.quote_payment definition

CREATE TABLE `quote_payment` (
  `payment_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Payment ID',
  `quote_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Quote ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `method` varchar(255) DEFAULT NULL COMMENT 'Method',
  `cc_type` varchar(255) DEFAULT NULL COMMENT 'Cc Type',
  `cc_number_enc` varchar(255) DEFAULT NULL COMMENT 'Cc Number Enc',
  `cc_last_4` varchar(255) DEFAULT NULL COMMENT 'Cc Last 4',
  `cc_cid_enc` varchar(255) DEFAULT NULL COMMENT 'Cc Cid Enc',
  `cc_owner` varchar(255) DEFAULT NULL COMMENT 'Cc Owner',
  `cc_exp_month` varchar(255) DEFAULT NULL COMMENT 'Cc Exp Month',
  `cc_exp_year` smallint(5) unsigned DEFAULT '0' COMMENT 'Cc Exp Year',
  `cc_ss_owner` varchar(255) DEFAULT NULL COMMENT 'Cc Ss Owner',
  `cc_ss_start_month` smallint(5) unsigned DEFAULT '0' COMMENT 'Cc Ss Start Month',
  `cc_ss_start_year` smallint(5) unsigned DEFAULT '0' COMMENT 'Cc Ss Start Year',
  `po_number` varchar(255) DEFAULT NULL COMMENT 'Po Number',
  `additional_data` text COMMENT 'Additional Data',
  `cc_ss_issue` varchar(255) DEFAULT NULL COMMENT 'Cc Ss Issue',
  `additional_information` text COMMENT 'Additional Information',
  `paypal_payer_id` varchar(255) DEFAULT NULL COMMENT 'Paypal Payer ID',
  `paypal_payer_status` varchar(255) DEFAULT NULL COMMENT 'Paypal Payer Status',
  `paypal_correlation_id` varchar(255) DEFAULT NULL COMMENT 'Paypal Correlation ID',
  PRIMARY KEY (`payment_id`),
  KEY `QUOTE_PAYMENT_QUOTE_ID` (`quote_id`),
  CONSTRAINT `QUOTE_PAYMENT_QUOTE_ID_QUOTE_ENTITY_ID` FOREIGN KEY (`quote_id`) REFERENCES `quote` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9274 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Payment';


-- drakesterling_old.quote_shipping_rate definition

CREATE TABLE `quote_shipping_rate` (
  `rate_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rate ID',
  `address_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Address ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `carrier` varchar(255) DEFAULT NULL COMMENT 'Carrier',
  `carrier_title` varchar(255) DEFAULT NULL COMMENT 'Carrier Title',
  `code` varchar(255) DEFAULT NULL COMMENT 'Code',
  `method` varchar(255) DEFAULT NULL COMMENT 'Method',
  `method_description` text COMMENT 'Method Description',
  `price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `error_message` text COMMENT 'Error Message',
  `method_title` text COMMENT 'Method Title',
  `carrier_type` text COMMENT 'ShipperHQ Carrier Type',
  `carrier_id` text COMMENT 'ShipperHQ Carrier ID',
  `carriergroup_id` text COMMENT 'Carrier Group ID',
  `carriergroup` text COMMENT 'ShipperHQ Carrier Group',
  `carriergroup_shipping_details` text COMMENT 'ShipperHQ Carrier Group Details',
  `shq_dispatch_date` date DEFAULT NULL COMMENT 'ShipperHQ Address Type',
  `shq_delivery_date` date DEFAULT NULL COMMENT 'ShipperHQ Address Type',
  PRIMARY KEY (`rate_id`),
  KEY `QUOTE_SHIPPING_RATE_ADDRESS_ID` (`address_id`),
  CONSTRAINT `QUOTE_SHIPPING_RATE_ADDRESS_ID_QUOTE_ADDRESS_ADDRESS_ID` FOREIGN KEY (`address_id`) REFERENCES `quote_address` (`address_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=28353 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Shipping Rate';


-- drakesterling_old.rating_option_vote_aggregated definition

CREATE TABLE `rating_option_vote_aggregated` (
  `primary_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Vote aggregation ID',
  `rating_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating ID',
  `entity_pk_value` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `vote_count` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Vote dty',
  `vote_value_sum` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'General vote sum',
  `percent` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Vote percent',
  `percent_approved` smallint(6) DEFAULT '0' COMMENT 'Vote percent approved by admin',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`primary_id`),
  KEY `RATING_OPTION_VOTE_AGGREGATED_RATING_ID` (`rating_id`),
  KEY `RATING_OPTION_VOTE_AGGREGATED_STORE_ID` (`store_id`),
  CONSTRAINT `RATING_OPTION_VOTE_AGGREGATED_RATING_ID_RATING_RATING_ID` FOREIGN KEY (`rating_id`) REFERENCES `rating` (`rating_id`) ON DELETE CASCADE,
  CONSTRAINT `RATING_OPTION_VOTE_AGGREGATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rating vote aggregated';


-- drakesterling_old.rating_store definition

CREATE TABLE `rating_store` (
  `rating_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`rating_id`,`store_id`),
  KEY `RATING_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `RATING_STORE_RATING_ID_RATING_RATING_ID` FOREIGN KEY (`rating_id`) REFERENCES `rating` (`rating_id`) ON DELETE CASCADE,
  CONSTRAINT `RATING_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rating Store';


-- drakesterling_old.rating_title definition

CREATE TABLE `rating_title` (
  `rating_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `value` varchar(255) NOT NULL COMMENT 'Rating Label',
  PRIMARY KEY (`rating_id`,`store_id`),
  KEY `RATING_TITLE_STORE_ID` (`store_id`),
  CONSTRAINT `RATING_TITLE_RATING_ID_RATING_RATING_ID` FOREIGN KEY (`rating_id`) REFERENCES `rating` (`rating_id`) ON DELETE CASCADE,
  CONSTRAINT `RATING_TITLE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Rating Title';


-- drakesterling_old.report_compared_product_index definition

CREATE TABLE `report_compared_product_index` (
  `index_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Index ID',
  `visitor_id` int(10) unsigned DEFAULT NULL COMMENT 'Visitor ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Added At',
  PRIMARY KEY (`index_id`),
  UNIQUE KEY `REPORT_COMPARED_PRODUCT_INDEX_VISITOR_ID_PRODUCT_ID` (`visitor_id`,`product_id`),
  UNIQUE KEY `REPORT_COMPARED_PRODUCT_INDEX_CUSTOMER_ID_PRODUCT_ID` (`customer_id`,`product_id`),
  KEY `REPORT_COMPARED_PRODUCT_INDEX_STORE_ID` (`store_id`),
  KEY `REPORT_COMPARED_PRODUCT_INDEX_ADDED_AT` (`added_at`),
  KEY `REPORT_COMPARED_PRODUCT_INDEX_PRODUCT_ID` (`product_id`),
  CONSTRAINT `REPORT_CMPD_PRD_IDX_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_CMPD_PRD_IDX_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_COMPARED_PRODUCT_INDEX_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Reports Compared Product Index Table';


-- drakesterling_old.report_event definition

CREATE TABLE `report_event` (
  `event_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Event ID',
  `logged_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Logged At',
  `event_type_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Event Type ID',
  `object_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Object ID',
  `subject_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Subject ID',
  `subtype` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Subtype',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`event_id`),
  KEY `REPORT_EVENT_EVENT_TYPE_ID` (`event_type_id`),
  KEY `REPORT_EVENT_SUBJECT_ID` (`subject_id`),
  KEY `REPORT_EVENT_OBJECT_ID` (`object_id`),
  KEY `REPORT_EVENT_SUBTYPE` (`subtype`),
  KEY `REPORT_EVENT_STORE_ID` (`store_id`),
  CONSTRAINT `REPORT_EVENT_EVENT_TYPE_ID_REPORT_EVENT_TYPES_EVENT_TYPE_ID` FOREIGN KEY (`event_type_id`) REFERENCES `report_event_types` (`event_type_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_EVENT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2509297 DEFAULT CHARSET=utf8 COMMENT='Reports Event Table';


-- drakesterling_old.report_viewed_product_aggregated_daily definition

CREATE TABLE `report_viewed_product_aggregated_daily` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `views_num` int(11) NOT NULL DEFAULT '0' COMMENT 'Number of Views',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `REPORT_VIEWED_PRD_AGGRED_DAILY_PERIOD_STORE_ID_PRD_ID` (`period`,`store_id`,`product_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_DAILY_STORE_ID` (`store_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_DAILY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_DAILY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_VIEWED_PRODUCT_AGGREGATED_DAILY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8918 DEFAULT CHARSET=utf8 COMMENT='Most Viewed Products Aggregated Daily';


-- drakesterling_old.report_viewed_product_aggregated_monthly definition

CREATE TABLE `report_viewed_product_aggregated_monthly` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `views_num` int(11) NOT NULL DEFAULT '0' COMMENT 'Number of Views',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `REPORT_VIEWED_PRD_AGGRED_MONTHLY_PERIOD_STORE_ID_PRD_ID` (`period`,`store_id`,`product_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_MONTHLY_STORE_ID` (`store_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_MONTHLY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_MONTHLY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_VIEWED_PRODUCT_AGGREGATED_MONTHLY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13753 DEFAULT CHARSET=utf8 COMMENT='Most Viewed Products Aggregated Monthly';


-- drakesterling_old.report_viewed_product_aggregated_yearly definition

CREATE TABLE `report_viewed_product_aggregated_yearly` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `views_num` int(11) NOT NULL DEFAULT '0' COMMENT 'Number of Views',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `REPORT_VIEWED_PRD_AGGRED_YEARLY_PERIOD_STORE_ID_PRD_ID` (`period`,`store_id`,`product_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_YEARLY_STORE_ID` (`store_id`),
  KEY `REPORT_VIEWED_PRODUCT_AGGREGATED_YEARLY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `REPORT_VIEWED_PRD_AGGRED_YEARLY_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_VIEWED_PRODUCT_AGGREGATED_YEARLY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9442 DEFAULT CHARSET=utf8 COMMENT='Most Viewed Products Aggregated Yearly';


-- drakesterling_old.report_viewed_product_index definition

CREATE TABLE `report_viewed_product_index` (
  `index_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Index ID',
  `visitor_id` int(10) unsigned DEFAULT NULL COMMENT 'Visitor ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `added_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Added At',
  PRIMARY KEY (`index_id`),
  UNIQUE KEY `REPORT_VIEWED_PRODUCT_INDEX_VISITOR_ID_PRODUCT_ID` (`visitor_id`,`product_id`),
  UNIQUE KEY `REPORT_VIEWED_PRODUCT_INDEX_CUSTOMER_ID_PRODUCT_ID` (`customer_id`,`product_id`),
  KEY `REPORT_VIEWED_PRODUCT_INDEX_STORE_ID` (`store_id`),
  KEY `REPORT_VIEWED_PRODUCT_INDEX_ADDED_AT` (`added_at`),
  KEY `REPORT_VIEWED_PRODUCT_INDEX_PRODUCT_ID` (`product_id`),
  CONSTRAINT `REPORT_VIEWED_PRD_IDX_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_VIEWED_PRD_IDX_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `REPORT_VIEWED_PRODUCT_INDEX_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2497179 DEFAULT CHARSET=utf8 COMMENT='Reports Viewed Product Index Table';


-- drakesterling_old.review_detail definition

CREATE TABLE `review_detail` (
  `detail_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Review detail ID',
  `review_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'Review ID',
  `store_id` smallint(5) unsigned DEFAULT '0' COMMENT 'Store ID',
  `title` varchar(255) NOT NULL COMMENT 'Title',
  `detail` text NOT NULL COMMENT 'Detail description',
  `nickname` varchar(128) NOT NULL COMMENT 'User nickname',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  PRIMARY KEY (`detail_id`),
  KEY `REVIEW_DETAIL_REVIEW_ID` (`review_id`),
  KEY `REVIEW_DETAIL_STORE_ID` (`store_id`),
  KEY `REVIEW_DETAIL_CUSTOMER_ID` (`customer_id`),
  CONSTRAINT `REVIEW_DETAIL_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE SET NULL,
  CONSTRAINT `REVIEW_DETAIL_REVIEW_ID_REVIEW_REVIEW_ID` FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `REVIEW_DETAIL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Review detail information';


-- drakesterling_old.review_entity_summary definition

CREATE TABLE `review_entity_summary` (
  `primary_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Summary review entity ID',
  `entity_pk_value` bigint(20) NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `entity_type` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Entity type ID',
  `reviews_count` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Qty of reviews',
  `rating_summary` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Summarized rating',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`primary_id`),
  UNIQUE KEY `REVIEW_ENTITY_SUMMARY_ENTITY_PK_VALUE_STORE_ID_ENTITY_TYPE` (`entity_pk_value`,`store_id`,`entity_type`),
  KEY `REVIEW_ENTITY_SUMMARY_STORE_ID` (`store_id`),
  CONSTRAINT `REVIEW_ENTITY_SUMMARY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Review aggregates';


-- drakesterling_old.review_store definition

CREATE TABLE `review_store` (
  `review_id` bigint(20) unsigned NOT NULL COMMENT 'Review ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  PRIMARY KEY (`review_id`,`store_id`),
  KEY `REVIEW_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `REVIEW_STORE_REVIEW_ID_REVIEW_REVIEW_ID` FOREIGN KEY (`review_id`) REFERENCES `review` (`review_id`) ON DELETE CASCADE,
  CONSTRAINT `REVIEW_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Review Store';


-- drakesterling_old.sales_bestsellers_aggregated_daily definition

CREATE TABLE `sales_bestsellers_aggregated_daily` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `qty_ordered` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty Ordered',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_BESTSELLERS_AGGREGATED_DAILY_PERIOD_STORE_ID_PRODUCT_ID` (`period`,`store_id`,`product_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_DAILY_STORE_ID` (`store_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_DAILY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `SALES_BESTSELLERS_AGGREGATED_DAILY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15031 DEFAULT CHARSET=utf8 COMMENT='Sales Bestsellers Aggregated Daily';


-- drakesterling_old.sales_bestsellers_aggregated_monthly definition

CREATE TABLE `sales_bestsellers_aggregated_monthly` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `qty_ordered` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty Ordered',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_BESTSELLERS_AGGREGATED_MONTHLY_PERIOD_STORE_ID_PRODUCT_ID` (`period`,`store_id`,`product_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_MONTHLY_STORE_ID` (`store_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_MONTHLY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `SALES_BESTSELLERS_AGGREGATED_MONTHLY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16994 DEFAULT CHARSET=utf8 COMMENT='Sales Bestsellers Aggregated Monthly';


-- drakesterling_old.sales_bestsellers_aggregated_yearly definition

CREATE TABLE `sales_bestsellers_aggregated_yearly` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product Name',
  `product_price` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Product Price',
  `qty_ordered` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty Ordered',
  `rating_pos` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Rating Pos',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_BESTSELLERS_AGGREGATED_YEARLY_PERIOD_STORE_ID_PRODUCT_ID` (`period`,`store_id`,`product_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_YEARLY_STORE_ID` (`store_id`),
  KEY `SALES_BESTSELLERS_AGGREGATED_YEARLY_PRODUCT_ID` (`product_id`),
  CONSTRAINT `SALES_BESTSELLERS_AGGREGATED_YEARLY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16961 DEFAULT CHARSET=utf8 COMMENT='Sales Bestsellers Aggregated Yearly';


-- drakesterling_old.sales_invoiced_aggregated definition

CREATE TABLE `sales_invoiced_aggregated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `orders_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Orders Invoiced',
  `invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced',
  `invoiced_captured` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced Captured',
  `invoiced_not_captured` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced Not Captured',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_INVOICED_AGGREGATED_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_INVOICED_AGGREGATED_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_INVOICED_AGGREGATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14760 DEFAULT CHARSET=utf8 COMMENT='Sales Invoiced Aggregated';


-- drakesterling_old.sales_invoiced_aggregated_order definition

CREATE TABLE `sales_invoiced_aggregated_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `orders_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Orders Invoiced',
  `invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced',
  `invoiced_captured` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced Captured',
  `invoiced_not_captured` decimal(20,4) DEFAULT NULL COMMENT 'Invoiced Not Captured',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_INVOICED_AGGREGATED_ORDER_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_INVOICED_AGGREGATED_ORDER_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_INVOICED_AGGREGATED_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4090 DEFAULT CHARSET=utf8 COMMENT='Sales Invoiced Aggregated Order';


-- drakesterling_old.sales_order definition

CREATE TABLE `sales_order` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `state` varchar(32) DEFAULT NULL COMMENT 'State',
  `status` varchar(32) DEFAULT NULL COMMENT 'Status',
  `coupon_code` varchar(255) DEFAULT NULL COMMENT 'Coupon Code',
  `protect_code` varchar(255) DEFAULT NULL COMMENT 'Protect Code',
  `shipping_description` varchar(255) DEFAULT NULL COMMENT 'Shipping Description',
  `is_virtual` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Virtual',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `base_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Amount',
  `base_discount_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Canceled',
  `base_discount_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Invoiced',
  `base_discount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Refunded',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `base_shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Amount',
  `base_shipping_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Canceled',
  `base_shipping_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Invoiced',
  `base_shipping_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Refunded',
  `base_shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Tax Amount',
  `base_shipping_tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Tax Refunded',
  `base_subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal',
  `base_subtotal_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Canceled',
  `base_subtotal_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Invoiced',
  `base_subtotal_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Refunded',
  `base_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Amount',
  `base_tax_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Canceled',
  `base_tax_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Invoiced',
  `base_tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Refunded',
  `base_to_global_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Global Rate',
  `base_to_order_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Order Rate',
  `base_total_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Canceled',
  `base_total_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Invoiced',
  `base_total_invoiced_cost` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Invoiced Cost',
  `base_total_offline_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Offline Refunded',
  `base_total_online_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Online Refunded',
  `base_total_paid` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Paid',
  `base_total_qty_ordered` decimal(12,4) DEFAULT NULL COMMENT 'Base Total Qty Ordered',
  `base_total_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Refunded',
  `discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Amount',
  `discount_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Discount Canceled',
  `discount_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Discount Invoiced',
  `discount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Discount Refunded',
  `grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Grand Total',
  `shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Amount',
  `shipping_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Canceled',
  `shipping_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Invoiced',
  `shipping_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Refunded',
  `shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Tax Amount',
  `shipping_tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Tax Refunded',
  `store_to_base_rate` decimal(12,4) DEFAULT NULL COMMENT 'Store To Base Rate',
  `store_to_order_rate` decimal(12,4) DEFAULT NULL COMMENT 'Store To Order Rate',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `subtotal_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Canceled',
  `subtotal_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Invoiced',
  `subtotal_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Refunded',
  `tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Amount',
  `tax_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Tax Canceled',
  `tax_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Tax Invoiced',
  `tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Tax Refunded',
  `total_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Total Canceled',
  `total_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Total Invoiced',
  `total_offline_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Total Offline Refunded',
  `total_online_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Total Online Refunded',
  `total_paid` decimal(20,4) DEFAULT NULL COMMENT 'Total Paid',
  `total_qty_ordered` decimal(12,4) DEFAULT NULL COMMENT 'Total Qty Ordered',
  `total_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Total Refunded',
  `can_ship_partially` smallint(5) unsigned DEFAULT NULL COMMENT 'Can Ship Partially',
  `can_ship_partially_item` smallint(5) unsigned DEFAULT NULL COMMENT 'Can Ship Partially Item',
  `customer_is_guest` smallint(5) unsigned DEFAULT NULL COMMENT 'Customer Is Guest',
  `customer_note_notify` smallint(5) unsigned DEFAULT NULL COMMENT 'Customer Note Notify',
  `billing_address_id` int(11) DEFAULT NULL COMMENT 'Billing Address ID',
  `customer_group_id` int(11) DEFAULT NULL,
  `edit_increment` int(11) DEFAULT NULL COMMENT 'Edit Increment',
  `email_sent` smallint(5) unsigned DEFAULT NULL COMMENT 'Email Sent',
  `send_email` smallint(5) unsigned DEFAULT NULL COMMENT 'Send Email',
  `forced_shipment_with_invoice` smallint(5) unsigned DEFAULT NULL COMMENT 'Forced Do Shipment With Invoice',
  `payment_auth_expiration` int(11) DEFAULT NULL COMMENT 'Payment Authorization Expiration',
  `quote_address_id` int(11) DEFAULT NULL COMMENT 'Quote Address ID',
  `quote_id` int(11) DEFAULT NULL COMMENT 'Quote ID',
  `shipping_address_id` int(11) DEFAULT NULL COMMENT 'Shipping Address ID',
  `adjustment_negative` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Negative',
  `adjustment_positive` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Positive',
  `base_adjustment_negative` decimal(20,4) DEFAULT NULL COMMENT 'Base Adjustment Negative',
  `base_adjustment_positive` decimal(20,4) DEFAULT NULL COMMENT 'Base Adjustment Positive',
  `base_shipping_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Amount',
  `base_subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Incl Tax',
  `base_total_due` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Due',
  `payment_authorization_amount` decimal(20,4) DEFAULT NULL COMMENT 'Payment Authorization Amount',
  `shipping_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Amount',
  `subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Incl Tax',
  `total_due` decimal(20,4) DEFAULT NULL COMMENT 'Total Due',
  `weight` decimal(12,4) DEFAULT NULL COMMENT 'Weight',
  `customer_dob` datetime DEFAULT NULL COMMENT 'Customer Dob',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `applied_rule_ids` varchar(128) DEFAULT NULL COMMENT 'Applied Rule Ids',
  `base_currency_code` varchar(3) DEFAULT NULL COMMENT 'Base Currency Code',
  `customer_email` varchar(128) DEFAULT NULL COMMENT 'Customer Email',
  `customer_firstname` varchar(128) DEFAULT NULL COMMENT 'Customer Firstname',
  `customer_lastname` varchar(128) DEFAULT NULL COMMENT 'Customer Lastname',
  `customer_middlename` varchar(128) DEFAULT NULL COMMENT 'Customer Middlename',
  `customer_prefix` varchar(32) DEFAULT NULL COMMENT 'Customer Prefix',
  `customer_suffix` varchar(32) DEFAULT NULL COMMENT 'Customer Suffix',
  `customer_taxvat` varchar(32) DEFAULT NULL COMMENT 'Customer Taxvat',
  `discount_description` varchar(255) DEFAULT NULL COMMENT 'Discount Description',
  `ext_customer_id` varchar(32) DEFAULT NULL COMMENT 'Ext Customer ID',
  `ext_order_id` varchar(32) DEFAULT NULL COMMENT 'Ext Order ID',
  `global_currency_code` varchar(3) DEFAULT NULL COMMENT 'Global Currency Code',
  `hold_before_state` varchar(32) DEFAULT NULL COMMENT 'Hold Before State',
  `hold_before_status` varchar(32) DEFAULT NULL COMMENT 'Hold Before Status',
  `order_currency_code` varchar(3) DEFAULT NULL COMMENT 'Order Currency Code',
  `original_increment_id` varchar(50) DEFAULT NULL COMMENT 'Original Increment ID',
  `relation_child_id` varchar(32) DEFAULT NULL COMMENT 'Relation Child ID',
  `relation_child_real_id` varchar(32) DEFAULT NULL COMMENT 'Relation Child Real ID',
  `relation_parent_id` varchar(32) DEFAULT NULL COMMENT 'Relation Parent ID',
  `relation_parent_real_id` varchar(32) DEFAULT NULL COMMENT 'Relation Parent Real ID',
  `remote_ip` varchar(45) DEFAULT NULL COMMENT 'Remote Ip',
  `shipping_method` varchar(120) DEFAULT NULL,
  `store_currency_code` varchar(3) DEFAULT NULL COMMENT 'Store Currency Code',
  `store_name` varchar(255) DEFAULT NULL COMMENT 'Store Name',
  `x_forwarded_for` varchar(255) DEFAULT NULL COMMENT 'X Forwarded For',
  `customer_note` text COMMENT 'Customer Note',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `total_item_count` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Total Item Count',
  `customer_gender` int(11) DEFAULT NULL COMMENT 'Customer Gender',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `shipping_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Tax Compensation Amount',
  `base_shipping_discount_tax_compensation_amnt` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Tax Compensation Amount',
  `discount_tax_compensation_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Invoiced',
  `base_discount_tax_compensation_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Invoiced',
  `discount_tax_compensation_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Refunded',
  `base_discount_tax_compensation_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Refunded',
  `shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Incl Tax',
  `base_shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Incl Tax',
  `coupon_rule_name` varchar(255) DEFAULT NULL COMMENT 'Coupon Sales Rule Name',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `paypal_ipn_customer_notified` int(11) DEFAULT '0' COMMENT 'Paypal Ipn Customer Notified',
  `mailchimp_abandonedcart_flag` tinyint(1) NOT NULL COMMENT 'Retrieved from Mailchimp',
  `mailchimp_campaign_id` varchar(16) DEFAULT NULL COMMENT 'Campaign',
  `mailchimp_landing_page` text NOT NULL COMMENT 'Landing Page',
  `mailchimp_flag` tinyint(1) NOT NULL COMMENT 'Retrieved from Mailchimp',
  `fee` decimal(10,0) DEFAULT '0' COMMENT 'Fee',
  `base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base Fee',
  `transaction_fee` decimal(10,0) DEFAULT '0' COMMENT 'TransactionFee',
  `transaction_base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base TransactionFee',
  `carrier_type` text COMMENT 'ShipperHQ Carrier Type',
  `carrier_id` text COMMENT 'ShipperHQ Carrier ID',
  `carriergroup_shipping_details` text COMMENT 'ShipperHQ Carrier Group Details',
  `carriergroup_shipping_html` text COMMENT 'ShipperHQ Carrier Group HTML',
  `destination_type` text COMMENT 'ShipperHQ Address Type',
  `validation_status` text COMMENT 'ShipperHQ Address Validation Status',
  `delivery_timestamp` text COMMENT 'Delivery Timestamp',
  `delivery_utc_offset` text COMMENT 'Delivery UTC Offset',
  `exclude_import_pending` smallint(5) unsigned DEFAULT '0' COMMENT 'Exclude order while is pending from export',
  `exclude_import_complete` smallint(5) unsigned DEFAULT '0' COMMENT 'Exclude complete order from export',
  `codisto_orderid` varchar(10) DEFAULT NULL COMMENT 'Codisto Order Id',
  `codisto_merchantid` varchar(10) DEFAULT NULL COMMENT 'Codisto Merchant Id',
  `pc_whitelisted` int(11) DEFAULT NULL COMMENT 'Pc Whitelisted',
  `dispute_status` varchar(45) DEFAULT NULL COMMENT 'Braintree Dispute Status',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_ORDER_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_ORDER_STATUS` (`status`),
  KEY `SALES_ORDER_STATE` (`state`),
  KEY `SALES_ORDER_STORE_ID` (`store_id`),
  KEY `SALES_ORDER_CREATED_AT` (`created_at`),
  KEY `SALES_ORDER_CUSTOMER_ID` (`customer_id`),
  KEY `SALES_ORDER_EXT_ORDER_ID` (`ext_order_id`),
  KEY `SALES_ORDER_QUOTE_ID` (`quote_id`),
  KEY `SALES_ORDER_UPDATED_AT` (`updated_at`),
  KEY `SALES_ORDER_SEND_EMAIL` (`send_email`),
  KEY `SALES_ORDER_EMAIL_SENT` (`email_sent`),
  KEY `SALES_ORDER_STORE_ID_STATE_CREATED_AT` (`store_id`,`state`,`created_at`),
  CONSTRAINT `SALES_ORDER_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE SET NULL,
  CONSTRAINT `SALES_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=5380 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order';


-- drakesterling_old.sales_order_address definition

CREATE TABLE `sales_order_address` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent ID',
  `customer_address_id` int(11) DEFAULT NULL COMMENT 'Customer Address ID',
  `quote_address_id` int(11) DEFAULT NULL COMMENT 'Quote Address ID',
  `region_id` int(11) DEFAULT NULL COMMENT 'Region ID',
  `customer_id` int(11) DEFAULT NULL COMMENT 'Customer ID',
  `fax` varchar(255) DEFAULT NULL COMMENT 'Fax',
  `region` varchar(255) DEFAULT NULL COMMENT 'Region',
  `postcode` varchar(255) DEFAULT NULL COMMENT 'Postcode',
  `lastname` varchar(255) DEFAULT NULL COMMENT 'Lastname',
  `street` varchar(255) DEFAULT NULL COMMENT 'Street',
  `city` varchar(255) DEFAULT NULL COMMENT 'City',
  `email` varchar(255) DEFAULT NULL COMMENT 'Email',
  `telephone` varchar(255) DEFAULT NULL COMMENT 'Phone Number',
  `country_id` varchar(2) DEFAULT NULL COMMENT 'Country ID',
  `firstname` varchar(255) DEFAULT NULL COMMENT 'Firstname',
  `address_type` varchar(255) DEFAULT NULL COMMENT 'Address Type',
  `prefix` varchar(255) DEFAULT NULL COMMENT 'Prefix',
  `middlename` varchar(255) DEFAULT NULL COMMENT 'Middlename',
  `suffix` varchar(255) DEFAULT NULL COMMENT 'Suffix',
  `company` varchar(255) DEFAULT NULL COMMENT 'Company',
  `vat_id` text COMMENT 'Vat ID',
  `vat_is_valid` smallint(6) DEFAULT NULL COMMENT 'Vat Is Valid',
  `vat_request_id` text COMMENT 'Vat Request ID',
  `vat_request_date` text COMMENT 'Vat Request Date',
  `vat_request_success` smallint(6) DEFAULT NULL COMMENT 'Vat Request Success',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_ORDER_ADDRESS_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_ORDER_ADDRESS_PARENT_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=10757 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order Address';


-- drakesterling_old.sales_order_aggregated_created definition

CREATE TABLE `sales_order_aggregated_created` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `total_qty_ordered` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Qty Ordered',
  `total_qty_invoiced` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Qty Invoiced',
  `total_income_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Income Amount',
  `total_revenue_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Revenue Amount',
  `total_profit_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Profit Amount',
  `total_invoiced_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Invoiced Amount',
  `total_canceled_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Canceled Amount',
  `total_paid_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Paid Amount',
  `total_refunded_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Refunded Amount',
  `total_tax_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Tax Amount',
  `total_tax_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Tax Amount Actual',
  `total_shipping_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Shipping Amount',
  `total_shipping_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Shipping Amount Actual',
  `total_discount_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Discount Amount',
  `total_discount_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Discount Amount Actual',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_ORDER_AGGREGATED_CREATED_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_ORDER_AGGREGATED_CREATED_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_ORDER_AGGREGATED_CREATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10694 DEFAULT CHARSET=utf8 COMMENT='Sales Order Aggregated Created';


-- drakesterling_old.sales_order_aggregated_updated definition

CREATE TABLE `sales_order_aggregated_updated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `total_qty_ordered` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Qty Ordered',
  `total_qty_invoiced` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Qty Invoiced',
  `total_income_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Income Amount',
  `total_revenue_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Revenue Amount',
  `total_profit_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Profit Amount',
  `total_invoiced_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Invoiced Amount',
  `total_canceled_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Canceled Amount',
  `total_paid_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Paid Amount',
  `total_refunded_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Refunded Amount',
  `total_tax_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Tax Amount',
  `total_tax_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Tax Amount Actual',
  `total_shipping_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Shipping Amount',
  `total_shipping_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Shipping Amount Actual',
  `total_discount_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Discount Amount',
  `total_discount_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Discount Amount Actual',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_ORDER_AGGREGATED_UPDATED_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_ORDER_AGGREGATED_UPDATED_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_ORDER_AGGREGATED_UPDATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10136 DEFAULT CHARSET=utf8 COMMENT='Sales Order Aggregated Updated';


-- drakesterling_old.sales_order_item definition

CREATE TABLE `sales_order_item` (
  `item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Item ID',
  `order_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Order ID',
  `parent_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent Item ID',
  `quote_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Quote Item ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `product_type` varchar(255) DEFAULT NULL COMMENT 'Product Type',
  `product_options` longtext COMMENT 'Product Options',
  `weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Weight',
  `is_virtual` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Virtual',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `description` text COMMENT 'Description',
  `applied_rule_ids` text COMMENT 'Applied Rule Ids',
  `additional_data` text COMMENT 'Additional Data',
  `is_qty_decimal` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Qty Decimal',
  `no_discount` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'No Discount',
  `qty_backordered` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Backordered',
  `qty_canceled` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Canceled',
  `qty_invoiced` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Invoiced',
  `qty_ordered` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Ordered',
  `qty_refunded` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Refunded',
  `qty_shipped` decimal(12,4) DEFAULT '0.0000' COMMENT 'Qty Shipped',
  `base_cost` decimal(12,4) DEFAULT '0.0000' COMMENT 'Base Cost',
  `price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Price',
  `base_price` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Price',
  `original_price` decimal(20,4) DEFAULT NULL COMMENT 'Original Price',
  `base_original_price` decimal(20,4) DEFAULT NULL COMMENT 'Base Original Price',
  `tax_percent` decimal(12,4) DEFAULT '0.0000' COMMENT 'Tax Percent',
  `tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Tax Amount',
  `base_tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Tax Amount',
  `tax_invoiced` decimal(20,4) DEFAULT '0.0000' COMMENT 'Tax Invoiced',
  `base_tax_invoiced` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Tax Invoiced',
  `discount_percent` decimal(12,4) DEFAULT '0.0000' COMMENT 'Discount Percent',
  `discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Discount Amount',
  `base_discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Discount Amount',
  `discount_invoiced` decimal(20,4) DEFAULT '0.0000' COMMENT 'Discount Invoiced',
  `base_discount_invoiced` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Discount Invoiced',
  `amount_refunded` decimal(20,4) DEFAULT '0.0000' COMMENT 'Amount Refunded',
  `base_amount_refunded` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Amount Refunded',
  `row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Row Total',
  `base_row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Row Total',
  `row_invoiced` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Row Invoiced',
  `base_row_invoiced` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Row Invoiced',
  `row_weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Row Weight',
  `base_tax_before_discount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Before Discount',
  `tax_before_discount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Before Discount',
  `ext_order_item_id` varchar(255) DEFAULT NULL COMMENT 'Ext Order Item ID',
  `locked_do_invoice` smallint(5) unsigned DEFAULT NULL COMMENT 'Locked Do Invoice',
  `locked_do_ship` smallint(5) unsigned DEFAULT NULL COMMENT 'Locked Do Ship',
  `price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Price Incl Tax',
  `base_price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Price Incl Tax',
  `row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Row Total Incl Tax',
  `base_row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total Incl Tax',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `discount_tax_compensation_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Invoiced',
  `base_discount_tax_compensation_invoiced` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Invoiced',
  `discount_tax_compensation_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Refunded',
  `base_discount_tax_compensation_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Refunded',
  `tax_canceled` decimal(12,4) DEFAULT NULL COMMENT 'Tax Canceled',
  `discount_tax_compensation_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Canceled',
  `tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Tax Refunded',
  `base_tax_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Refunded',
  `discount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Discount Refunded',
  `base_discount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Refunded',
  `free_shipping` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Free Shipping',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `gift_message_available` int(11) DEFAULT NULL COMMENT 'Gift Message Available',
  `weee_tax_applied` text COMMENT 'Weee Tax Applied',
  `weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Amount',
  `weee_tax_applied_row_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Row Amount',
  `weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Disposition',
  `weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Row Disposition',
  `base_weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Amount',
  `base_weee_tax_applied_row_amnt` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Row Amnt',
  `base_weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Disposition',
  `base_weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Row Disposition',
  `carriergroup_id` text COMMENT 'Carrier Group ID',
  `carriergroup` text COMMENT 'ShipperHQ Carrier Group',
  `carriergroup_shipping` text COMMENT 'ShipperHQ Shipping Description',
  PRIMARY KEY (`item_id`),
  KEY `SALES_ORDER_ITEM_ORDER_ID` (`order_id`),
  KEY `SALES_ORDER_ITEM_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_ORDER_ITEM_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_ORDER_ITEM_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7907 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order Item';


-- drakesterling_old.sales_order_payment definition

CREATE TABLE `sales_order_payment` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `base_shipping_captured` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Captured',
  `shipping_captured` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Captured',
  `amount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Amount Refunded',
  `base_amount_paid` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Paid',
  `amount_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Amount Canceled',
  `base_amount_authorized` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Authorized',
  `base_amount_paid_online` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Paid Online',
  `base_amount_refunded_online` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Refunded Online',
  `base_shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Amount',
  `shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Amount',
  `amount_paid` decimal(20,4) DEFAULT NULL COMMENT 'Amount Paid',
  `amount_authorized` decimal(20,4) DEFAULT NULL COMMENT 'Amount Authorized',
  `base_amount_ordered` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Ordered',
  `base_shipping_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Refunded',
  `shipping_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Refunded',
  `base_amount_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Refunded',
  `amount_ordered` decimal(20,4) DEFAULT NULL COMMENT 'Amount Ordered',
  `base_amount_canceled` decimal(20,4) DEFAULT NULL COMMENT 'Base Amount Canceled',
  `quote_payment_id` int(11) DEFAULT NULL COMMENT 'Quote Payment ID',
  `additional_data` text COMMENT 'Additional Data',
  `cc_exp_month` varchar(12) DEFAULT NULL COMMENT 'Cc Exp Month',
  `cc_ss_start_year` varchar(12) DEFAULT NULL COMMENT 'Cc Ss Start Year',
  `echeck_bank_name` varchar(128) DEFAULT NULL COMMENT 'Echeck Bank Name',
  `method` varchar(128) DEFAULT NULL COMMENT 'Method',
  `cc_debug_request_body` varchar(32) DEFAULT NULL COMMENT 'Cc Debug Request Body',
  `cc_secure_verify` varchar(32) DEFAULT NULL COMMENT 'Cc Secure Verify',
  `protection_eligibility` varchar(32) DEFAULT NULL COMMENT 'Protection Eligibility',
  `cc_approval` varchar(32) DEFAULT NULL COMMENT 'Cc Approval',
  `cc_last_4` varchar(100) DEFAULT NULL COMMENT 'Cc Last 4',
  `cc_status_description` varchar(32) DEFAULT NULL COMMENT 'Cc Status Description',
  `echeck_type` varchar(32) DEFAULT NULL COMMENT 'Echeck Type',
  `cc_debug_response_serialized` varchar(32) DEFAULT NULL COMMENT 'Cc Debug Response Serialized',
  `cc_ss_start_month` varchar(128) DEFAULT NULL COMMENT 'Cc Ss Start Month',
  `echeck_account_type` varchar(255) DEFAULT NULL COMMENT 'Echeck Account Type',
  `last_trans_id` varchar(255) DEFAULT NULL COMMENT 'Last Trans ID',
  `cc_cid_status` varchar(32) DEFAULT NULL COMMENT 'Cc Cid Status',
  `cc_owner` varchar(128) DEFAULT NULL COMMENT 'Cc Owner',
  `cc_type` varchar(32) DEFAULT NULL COMMENT 'Cc Type',
  `po_number` varchar(32) DEFAULT NULL COMMENT 'Po Number',
  `cc_exp_year` varchar(4) DEFAULT NULL COMMENT 'Cc Exp Year',
  `cc_status` varchar(4) DEFAULT NULL COMMENT 'Cc Status',
  `echeck_routing_number` varchar(32) DEFAULT NULL COMMENT 'Echeck Routing Number',
  `account_status` varchar(32) DEFAULT NULL COMMENT 'Account Status',
  `anet_trans_method` varchar(32) DEFAULT NULL COMMENT 'Anet Trans Method',
  `cc_debug_response_body` varchar(32) DEFAULT NULL COMMENT 'Cc Debug Response Body',
  `cc_ss_issue` varchar(32) DEFAULT NULL COMMENT 'Cc Ss Issue',
  `echeck_account_name` varchar(32) DEFAULT NULL COMMENT 'Echeck Account Name',
  `cc_avs_status` varchar(32) DEFAULT NULL COMMENT 'Cc Avs Status',
  `cc_number_enc` varchar(128) DEFAULT NULL,
  `cc_trans_id` varchar(32) DEFAULT NULL COMMENT 'Cc Trans ID',
  `address_status` varchar(32) DEFAULT NULL COMMENT 'Address Status',
  `additional_information` text COMMENT 'Additional Information',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_ORDER_PAYMENT_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_ORDER_PAYMENT_PARENT_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5379 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order Payment';


-- drakesterling_old.sales_order_status_history definition

CREATE TABLE `sales_order_status_history` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `is_customer_notified` int(11) DEFAULT NULL COMMENT 'Is Customer Notified',
  `is_visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible On Front',
  `comment` text COMMENT 'Comment',
  `status` varchar(32) DEFAULT NULL COMMENT 'Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `entity_name` varchar(32) DEFAULT NULL COMMENT 'Shows what entity history is bind to.',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_ORDER_STATUS_HISTORY_PARENT_ID` (`parent_id`),
  KEY `SALES_ORDER_STATUS_HISTORY_CREATED_AT` (`created_at`),
  CONSTRAINT `SALES_ORDER_STATUS_HISTORY_PARENT_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5889 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Order Status History';


-- drakesterling_old.sales_order_status_label definition

CREATE TABLE `sales_order_status_label` (
  `status` varchar(32) NOT NULL COMMENT 'Status',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `label` varchar(128) NOT NULL COMMENT 'Label',
  PRIMARY KEY (`status`,`store_id`),
  KEY `SALES_ORDER_STATUS_LABEL_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_ORDER_STATUS_LABEL_STATUS_SALES_ORDER_STATUS_STATUS` FOREIGN KEY (`status`) REFERENCES `sales_order_status` (`status`) ON DELETE CASCADE,
  CONSTRAINT `SALES_ORDER_STATUS_LABEL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Order Status Label Table';


-- drakesterling_old.sales_order_tax_item definition

CREATE TABLE `sales_order_tax_item` (
  `tax_item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Tax Item ID',
  `tax_id` int(10) unsigned NOT NULL COMMENT 'Tax ID',
  `item_id` int(10) unsigned DEFAULT NULL COMMENT 'Item ID',
  `tax_percent` decimal(12,4) NOT NULL COMMENT 'Real Tax Percent For Item',
  `amount` decimal(20,4) NOT NULL COMMENT 'Tax amount for the item and tax rate',
  `base_amount` decimal(20,4) NOT NULL COMMENT 'Base tax amount for the item and tax rate',
  `real_amount` decimal(20,4) NOT NULL COMMENT 'Real tax amount for the item and tax rate',
  `real_base_amount` decimal(20,4) NOT NULL COMMENT 'Real base tax amount for the item and tax rate',
  `associated_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Id of the associated item',
  `taxable_item_type` varchar(32) NOT NULL COMMENT 'Type of the taxable item',
  PRIMARY KEY (`tax_item_id`),
  UNIQUE KEY `SALES_ORDER_TAX_ITEM_TAX_ID_ITEM_ID` (`tax_id`,`item_id`),
  KEY `SALES_ORDER_TAX_ITEM_ITEM_ID` (`item_id`),
  KEY `SALES_ORDER_TAX_ITEM_ASSOCIATED_ITEM_ID_SALES_ORDER_ITEM_ITEM_ID` (`associated_item_id`),
  CONSTRAINT `SALES_ORDER_TAX_ITEM_ASSOCIATED_ITEM_ID_SALES_ORDER_ITEM_ITEM_ID` FOREIGN KEY (`associated_item_id`) REFERENCES `sales_order_item` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_ORDER_TAX_ITEM_ITEM_ID_SALES_ORDER_ITEM_ITEM_ID` FOREIGN KEY (`item_id`) REFERENCES `sales_order_item` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_ORDER_TAX_ITEM_TAX_ID_SALES_ORDER_TAX_TAX_ID` FOREIGN KEY (`tax_id`) REFERENCES `sales_order_tax` (`tax_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COMMENT='Sales Order Tax Item';


-- drakesterling_old.sales_payment_transaction definition

CREATE TABLE `sales_payment_transaction` (
  `transaction_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Transaction ID',
  `parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent ID',
  `order_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Order ID',
  `payment_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Payment ID',
  `txn_id` varchar(100) DEFAULT NULL COMMENT 'Txn ID',
  `parent_txn_id` varchar(100) DEFAULT NULL COMMENT 'Parent Txn ID',
  `txn_type` varchar(15) DEFAULT NULL COMMENT 'Txn Type',
  `is_closed` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Closed',
  `additional_information` blob COMMENT 'Additional Information',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `SALES_PAYMENT_TRANSACTION_ORDER_ID_PAYMENT_ID_TXN_ID` (`order_id`,`payment_id`,`txn_id`),
  KEY `SALES_PAYMENT_TRANSACTION_PARENT_ID` (`parent_id`),
  KEY `SALES_PAYMENT_TRANSACTION_PAYMENT_ID` (`payment_id`),
  CONSTRAINT `FK_B99FF1A06402D725EBDB0F3A7ECD47A2` FOREIGN KEY (`parent_id`) REFERENCES `sales_payment_transaction` (`transaction_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_PAYMENT_TRANSACTION_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_PAYMENT_TRANSACTION_PAYMENT_ID_SALES_ORDER_PAYMENT_ENTT_ID` FOREIGN KEY (`payment_id`) REFERENCES `sales_order_payment` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8 COMMENT='Sales Payment Transaction';


-- drakesterling_old.sales_refunded_aggregated definition

CREATE TABLE `sales_refunded_aggregated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) NOT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `refunded` decimal(20,4) DEFAULT NULL COMMENT 'Refunded',
  `online_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Online Refunded',
  `offline_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Offline Refunded',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_REFUNDED_AGGREGATED_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_REFUNDED_AGGREGATED_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_REFUNDED_AGGREGATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8 COMMENT='Sales Refunded Aggregated';


-- drakesterling_old.sales_refunded_aggregated_order definition

CREATE TABLE `sales_refunded_aggregated_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `refunded` decimal(20,4) DEFAULT NULL COMMENT 'Refunded',
  `online_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Online Refunded',
  `offline_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Offline Refunded',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_REFUNDED_AGGREGATED_ORDER_PERIOD_STORE_ID_ORDER_STATUS` (`period`,`store_id`,`order_status`),
  KEY `SALES_REFUNDED_AGGREGATED_ORDER_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_REFUNDED_AGGREGATED_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COMMENT='Sales Refunded Aggregated Order';


-- drakesterling_old.sales_shipment definition

CREATE TABLE `sales_shipment` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `total_weight` decimal(12,4) DEFAULT NULL COMMENT 'Total Weight',
  `total_qty` decimal(12,4) DEFAULT NULL COMMENT 'Total Qty',
  `email_sent` smallint(5) unsigned DEFAULT NULL COMMENT 'Email Sent',
  `send_email` smallint(5) unsigned DEFAULT NULL COMMENT 'Send Email',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `customer_id` int(11) DEFAULT NULL COMMENT 'Customer ID',
  `shipping_address_id` int(11) DEFAULT NULL COMMENT 'Shipping Address ID',
  `billing_address_id` int(11) DEFAULT NULL COMMENT 'Billing Address ID',
  `shipment_status` int(11) DEFAULT NULL COMMENT 'Shipment Status',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `packages` text COMMENT 'Packed Products in Packages',
  `shipping_label` mediumblob COMMENT 'Shipping Label Content',
  `customer_note` text COMMENT 'Customer Note',
  `customer_note_notify` smallint(5) unsigned DEFAULT NULL COMMENT 'Customer Note Notify',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_SHIPMENT_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_SHIPMENT_STORE_ID` (`store_id`),
  KEY `SALES_SHIPMENT_TOTAL_QTY` (`total_qty`),
  KEY `SALES_SHIPMENT_ORDER_ID` (`order_id`),
  KEY `SALES_SHIPMENT_CREATED_AT` (`created_at`),
  KEY `SALES_SHIPMENT_UPDATED_AT` (`updated_at`),
  KEY `SALES_SHIPMENT_SEND_EMAIL` (`send_email`),
  KEY `SALES_SHIPMENT_EMAIL_SENT` (`email_sent`),
  CONSTRAINT `SALES_SHIPMENT_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_SHIPMENT_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3915 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Shipment';


-- drakesterling_old.sales_shipment_comment definition

CREATE TABLE `sales_shipment_comment` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `is_customer_notified` int(11) DEFAULT NULL COMMENT 'Is Customer Notified',
  `is_visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible On Front',
  `comment` text COMMENT 'Comment',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_SHIPMENT_COMMENT_CREATED_AT` (`created_at`),
  KEY `SALES_SHIPMENT_COMMENT_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_SHIPMENT_COMMENT_PARENT_ID_SALES_SHIPMENT_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_shipment` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Shipment Comment';


-- drakesterling_old.sales_shipment_item definition

CREATE TABLE `sales_shipment_item` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `row_total` decimal(20,4) DEFAULT NULL COMMENT 'Row Total',
  `price` decimal(20,4) DEFAULT NULL COMMENT 'Price',
  `weight` decimal(12,4) DEFAULT NULL COMMENT 'Weight',
  `qty` decimal(12,4) DEFAULT NULL COMMENT 'Qty',
  `product_id` int(11) DEFAULT NULL COMMENT 'Product ID',
  `order_item_id` int(11) DEFAULT NULL COMMENT 'Order Item ID',
  `additional_data` text COMMENT 'Additional Data',
  `description` text COMMENT 'Description',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_SHIPMENT_ITEM_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_SHIPMENT_ITEM_PARENT_ID_SALES_SHIPMENT_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_shipment` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5733 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Shipment Item';


-- drakesterling_old.sales_shipment_track definition

CREATE TABLE `sales_shipment_track` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `weight` decimal(12,4) DEFAULT NULL COMMENT 'Weight',
  `qty` decimal(12,4) DEFAULT NULL COMMENT 'Qty',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `track_number` text COMMENT 'Number',
  `description` text COMMENT 'Description',
  `title` varchar(255) DEFAULT NULL COMMENT 'Title',
  `carrier_code` varchar(32) DEFAULT NULL COMMENT 'Carrier Code',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_SHIPMENT_TRACK_PARENT_ID` (`parent_id`),
  KEY `SALES_SHIPMENT_TRACK_ORDER_ID` (`order_id`),
  KEY `SALES_SHIPMENT_TRACK_CREATED_AT` (`created_at`),
  CONSTRAINT `SALES_SHIPMENT_TRACK_PARENT_ID_SALES_SHIPMENT_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_shipment` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3856 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Shipment Track';


-- drakesterling_old.sales_shipping_aggregated definition

CREATE TABLE `sales_shipping_aggregated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `shipping_description` varchar(255) DEFAULT NULL COMMENT 'Shipping Description',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `total_shipping` decimal(20,4) DEFAULT NULL COMMENT 'Total Shipping',
  `total_shipping_actual` decimal(20,4) DEFAULT NULL COMMENT 'Total Shipping Actual',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALES_SHPP_AGGRED_PERIOD_STORE_ID_ORDER_STS_SHPP_DESCRIPTION` (`period`,`store_id`,`order_status`,`shipping_description`),
  KEY `SALES_SHIPPING_AGGREGATED_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_SHIPPING_AGGREGATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=22606 DEFAULT CHARSET=utf8 COMMENT='Sales Shipping Aggregated';


-- drakesterling_old.sales_shipping_aggregated_order definition

CREATE TABLE `sales_shipping_aggregated_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date DEFAULT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `shipping_description` varchar(255) DEFAULT NULL COMMENT 'Shipping Description',
  `orders_count` int(11) NOT NULL DEFAULT '0' COMMENT 'Orders Count',
  `total_shipping` decimal(20,4) DEFAULT NULL COMMENT 'Total Shipping',
  `total_shipping_actual` decimal(20,4) DEFAULT NULL COMMENT 'Total Shipping Actual',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNQ_C05FAE47282EEA68654D0924E946761F` (`period`,`store_id`,`order_status`,`shipping_description`),
  KEY `SALES_SHIPPING_AGGREGATED_ORDER_STORE_ID` (`store_id`),
  CONSTRAINT `SALES_SHIPPING_AGGREGATED_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=36727 DEFAULT CHARSET=utf8 COMMENT='Sales Shipping Aggregated Order';


-- drakesterling_old.salesrule_coupon_aggregated definition

CREATE TABLE `salesrule_coupon_aggregated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date NOT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT 'Coupon Code',
  `coupon_uses` int(11) NOT NULL DEFAULT '0' COMMENT 'Coupon Uses',
  `subtotal_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal Amount',
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount',
  `total_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Amount',
  `subtotal_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal Amount Actual',
  `discount_amount_actual` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount Actual',
  `total_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Amount Actual',
  `rule_name` varchar(255) DEFAULT NULL COMMENT 'Rule Name',
  PRIMARY KEY (`id`),
  UNIQUE KEY `SALESRULE_COUPON_AGGRED_PERIOD_STORE_ID_ORDER_STS_COUPON_CODE` (`period`,`store_id`,`order_status`,`coupon_code`),
  KEY `SALESRULE_COUPON_AGGREGATED_STORE_ID` (`store_id`),
  KEY `SALESRULE_COUPON_AGGREGATED_RULE_NAME` (`rule_name`),
  CONSTRAINT `SALESRULE_COUPON_AGGREGATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Coupon Aggregated';


-- drakesterling_old.salesrule_coupon_aggregated_order definition

CREATE TABLE `salesrule_coupon_aggregated_order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date NOT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT 'Coupon Code',
  `coupon_uses` int(11) NOT NULL DEFAULT '0' COMMENT 'Coupon Uses',
  `subtotal_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal Amount',
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount',
  `total_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Amount',
  `rule_name` varchar(255) DEFAULT NULL COMMENT 'Rule Name',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNQ_1094D1FBBCBB11704A29DEF3ACC37D2B` (`period`,`store_id`,`order_status`,`coupon_code`),
  KEY `SALESRULE_COUPON_AGGREGATED_ORDER_STORE_ID` (`store_id`),
  KEY `SALESRULE_COUPON_AGGREGATED_ORDER_RULE_NAME` (`rule_name`),
  CONSTRAINT `SALESRULE_COUPON_AGGREGATED_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Coupon Aggregated Order';


-- drakesterling_old.salesrule_coupon_aggregated_updated definition

CREATE TABLE `salesrule_coupon_aggregated_updated` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `period` date NOT NULL COMMENT 'Period',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `order_status` varchar(50) DEFAULT NULL COMMENT 'Order Status',
  `coupon_code` varchar(50) DEFAULT NULL COMMENT 'Coupon Code',
  `coupon_uses` int(11) NOT NULL DEFAULT '0' COMMENT 'Coupon Uses',
  `subtotal_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal Amount',
  `discount_amount` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount',
  `total_amount` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Amount',
  `subtotal_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Subtotal Amount Actual',
  `discount_amount_actual` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Discount Amount Actual',
  `total_amount_actual` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Total Amount Actual',
  `rule_name` varchar(255) DEFAULT NULL COMMENT 'Rule Name',
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNQ_7196FA120A4F0F84E1B66605E87E213E` (`period`,`store_id`,`order_status`,`coupon_code`),
  KEY `SALESRULE_COUPON_AGGREGATED_UPDATED_STORE_ID` (`store_id`),
  KEY `SALESRULE_COUPON_AGGREGATED_UPDATED_RULE_NAME` (`rule_name`),
  CONSTRAINT `SALESRULE_COUPON_AGGREGATED_UPDATED_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Salesrule Coupon Aggregated Updated';


-- drakesterling_old.salesrule_coupon_usage definition

CREATE TABLE `salesrule_coupon_usage` (
  `coupon_id` int(10) unsigned NOT NULL COMMENT 'Coupon ID',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer ID',
  `times_used` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Times Used',
  PRIMARY KEY (`coupon_id`,`customer_id`),
  KEY `SALESRULE_COUPON_USAGE_CUSTOMER_ID` (`customer_id`),
  CONSTRAINT `SALESRULE_COUPON_USAGE_COUPON_ID_SALESRULE_COUPON_COUPON_ID` FOREIGN KEY (`coupon_id`) REFERENCES `salesrule_coupon` (`coupon_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_COUPON_USAGE_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Salesrule Coupon Usage';


-- drakesterling_old.salesrule_customer definition

CREATE TABLE `salesrule_customer` (
  `rule_customer_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Rule Customer ID',
  `rule_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Rule ID',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `times_used` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Times Used',
  PRIMARY KEY (`rule_customer_id`),
  KEY `SALESRULE_CUSTOMER_RULE_ID_CUSTOMER_ID` (`rule_id`,`customer_id`),
  KEY `SALESRULE_CUSTOMER_CUSTOMER_ID_RULE_ID` (`customer_id`,`rule_id`),
  CONSTRAINT `SALESRULE_CUSTOMER_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_CUSTOMER_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Salesrule Customer';


-- drakesterling_old.salesrule_label definition

CREATE TABLE `salesrule_label` (
  `label_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Label ID',
  `rule_id` int(10) unsigned NOT NULL COMMENT 'Rule ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `label` varchar(255) DEFAULT NULL COMMENT 'Label',
  PRIMARY KEY (`label_id`),
  UNIQUE KEY `SALESRULE_LABEL_RULE_ID_STORE_ID` (`rule_id`,`store_id`),
  KEY `SALESRULE_LABEL_STORE_ID` (`store_id`),
  CONSTRAINT `SALESRULE_LABEL_RULE_ID_SALESRULE_RULE_ID` FOREIGN KEY (`rule_id`) REFERENCES `salesrule` (`rule_id`) ON DELETE CASCADE,
  CONSTRAINT `SALESRULE_LABEL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='Salesrule Label';


-- drakesterling_old.search_query definition

CREATE TABLE `search_query` (
  `query_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Query ID',
  `query_text` varchar(255) DEFAULT NULL COMMENT 'Query text',
  `num_results` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Num results',
  `popularity` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Popularity',
  `redirect` varchar(255) DEFAULT NULL COMMENT 'Redirect',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `display_in_terms` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Display in terms',
  `is_active` smallint(6) DEFAULT '1' COMMENT 'Active status',
  `is_processed` smallint(6) DEFAULT '0' COMMENT 'Processed status',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated at',
  `is_spellchecked` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Is the query spellchecked',
  PRIMARY KEY (`query_id`),
  UNIQUE KEY `SEARCH_QUERY_QUERY_TEXT_STORE_ID` (`query_text`,`store_id`),
  KEY `SEARCH_QUERY_QUERY_TEXT_STORE_ID_POPULARITY` (`query_text`,`store_id`,`popularity`),
  KEY `SEARCH_QUERY_IS_PROCESSED` (`is_processed`),
  KEY `SEARCH_QUERY_STORE_ID_NUM_RESULTS_POPULARITY` (`store_id`,`num_results`,`popularity`),
  CONSTRAINT `SEARCH_QUERY_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=694825 DEFAULT CHARSET=utf8 COMMENT='Search query table';


-- drakesterling_old.search_synonyms definition

CREATE TABLE `search_synonyms` (
  `group_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Synonyms Group ID',
  `synonyms` text NOT NULL COMMENT 'list of synonyms making up this group',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID - identifies the store view these synonyms belong to',
  `website_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Website ID - identifies the website ID these synonyms belong to',
  PRIMARY KEY (`group_id`),
  KEY `SEARCH_SYNONYMS_STORE_ID` (`store_id`),
  KEY `SEARCH_SYNONYMS_WEBSITE_ID` (`website_id`),
  FULLTEXT KEY `SEARCH_SYNONYMS_SYNONYMS` (`synonyms`),
  CONSTRAINT `SEARCH_SYNONYMS_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `SEARCH_SYNONYMS_WEBSITE_ID_STORE_WEBSITE_WEBSITE_ID` FOREIGN KEY (`website_id`) REFERENCES `store_website` (`website_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='table storing various synonyms groups';


-- drakesterling_old.signifyd_case definition

CREATE TABLE `signifyd_case` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity_id',
  `order_id` int(10) unsigned DEFAULT NULL COMMENT 'Order_id',
  `case_id` int(10) unsigned DEFAULT NULL COMMENT 'Case_id',
  `guarantee_eligible` tinyint(1) DEFAULT NULL COMMENT 'Guarantee_eligible',
  `guarantee_disposition` varchar(32) DEFAULT 'PENDING' COMMENT 'Guarantee_disposition',
  `status` varchar(32) DEFAULT 'PENDING' COMMENT 'Status',
  `score` int(10) unsigned DEFAULT NULL COMMENT 'Score',
  `associated_team` text COMMENT 'Associated_team',
  `review_disposition` varchar(32) DEFAULT NULL COMMENT 'Review_disposition',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Created_at',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Updated_at',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SIGNIFYD_CASE_ORDER_ID` (`order_id`),
  UNIQUE KEY `SIGNIFYD_CASE_CASE_ID` (`case_id`),
  CONSTRAINT `SIGNIFYD_CASE_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='signifyd_case';


-- drakesterling_old.sitemap definition

CREATE TABLE `sitemap` (
  `sitemap_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Sitemap ID',
  `sitemap_type` varchar(32) DEFAULT NULL COMMENT 'Sitemap Type',
  `sitemap_filename` varchar(32) DEFAULT NULL COMMENT 'Sitemap Filename',
  `sitemap_path` varchar(255) DEFAULT NULL COMMENT 'Sitemap Path',
  `sitemap_time` timestamp NULL DEFAULT NULL COMMENT 'Sitemap Time',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  PRIMARY KEY (`sitemap_id`),
  KEY `SITEMAP_STORE_ID` (`store_id`),
  CONSTRAINT `SITEMAP_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='XML Sitemap';


-- drakesterling_old.smile_elasticsuite_optimizer_limitation definition

CREATE TABLE `smile_elasticsuite_optimizer_limitation` (
  `optimizer_id` smallint(6) NOT NULL COMMENT 'Optimizer ID',
  `category_id` int(10) unsigned DEFAULT NULL COMMENT 'Category ID',
  `query_id` int(10) unsigned DEFAULT NULL COMMENT 'Query ID',
  UNIQUE KEY `UNQ_0FB126492F65ADDBD7F9CE0585EE7691` (`optimizer_id`,`category_id`,`query_id`),
  KEY `FK_DECB3B36711079998CA4D3DB38F2E0EB` (`category_id`),
  KEY `SMILE_ELASTICSUITE_OPTIMIZER_LIMITATION_QR_ID_SRCH_QR_QR_ID` (`query_id`),
  KEY `SMILE_ELASTICSUITE_OPTIMIZER_LIMITATION_QUERY_ID` (`query_id`),
  KEY `IDX_0FB126492F65ADDBD7F9CE0585EE7691` (`optimizer_id`,`category_id`,`query_id`),
  CONSTRAINT `FK_29EE1ECD41B422FDFF017973D0039789` FOREIGN KEY (`optimizer_id`) REFERENCES `smile_elasticsuite_optimizer` (`optimizer_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_DECB3B36711079998CA4D3DB38F2E0EB` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SMILE_ELASTICSUITE_OPTIMIZER_LIMITATION_QR_ID_SRCH_QR_QR_ID` FOREIGN KEY (`query_id`) REFERENCES `search_query` (`query_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuite_thesaurus_store definition

CREATE TABLE `smile_elasticsuite_thesaurus_store` (
  `thesaurus_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Thesaurus ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store Id',
  PRIMARY KEY (`thesaurus_id`,`store_id`),
  KEY `SMILE_ELASTICSUITE_THESAURUS_STORE_STORE_ID_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `FK_63B974533C5D31F477D220BDD0870DBE` FOREIGN KEY (`thesaurus_id`) REFERENCES `smile_elasticsuite_thesaurus` (`thesaurus_id`) ON DELETE CASCADE,
  CONSTRAINT `SMILE_ELASTICSUITE_THESAURUS_STORE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_elasticsuitecatalog_search_query_product_position definition

CREATE TABLE `smile_elasticsuitecatalog_search_query_product_position` (
  `query_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Query ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_blacklisted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'If the product is blacklisted',
  `facet_boolean_logic` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'Boolean logic to use when combining multiple selected values inside the filter',
  PRIMARY KEY (`query_id`,`product_id`),
  KEY `SMILE_ELASTICSUITECAT_SRCH_QR_PRD_POSITION_PRD_ID` (`product_id`),
  CONSTRAINT `FK_E51230BD209344C6172518E1E4908CDA` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SMILE_ELASTICSUITECAT_SRCH_QR_PRD_POSITION_QR_ID_SRCH_QR_QR_ID` FOREIGN KEY (`query_id`) REFERENCES `search_query` (`query_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.smile_virtualcategory_catalog_category_product_position definition

CREATE TABLE `smile_virtualcategory_catalog_category_product_position` (
  `category_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Category ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `position` int(11) DEFAULT NULL COMMENT 'Position',
  `is_blacklisted` tinyint(1) NOT NULL DEFAULT '0' COMMENT 'If the product is blacklisted',
  PRIMARY KEY (`category_id`,`product_id`,`store_id`),
  KEY `SMILE_VIRTUALCTGR_CAT_CTGR_PRD_POSITION_PRD_ID` (`product_id`),
  KEY `SMILE_VIRTUALCTGR_CAT_CTGR_PRD_POSITION_STORE_ID_STORE_STORE_ID` (`store_id`),
  CONSTRAINT `FK_9A80162E8ADF9FB814AC79D709D977F3` FOREIGN KEY (`category_id`) REFERENCES `catalog_category_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_D8ED66CF4B5DA2EE349B79458FFC6587` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SMILE_VIRTUALCTGR_CAT_CTGR_PRD_POSITION_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- drakesterling_old.vault_payment_token definition

CREATE TABLE `vault_payment_token` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `public_hash` varchar(128) NOT NULL COMMENT 'Hash code for using on frontend',
  `payment_method_code` varchar(128) NOT NULL COMMENT 'Payment method code',
  `type` varchar(128) NOT NULL COMMENT 'Type',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'Expires At',
  `gateway_token` varchar(255) NOT NULL COMMENT 'Gateway Token',
  `details` text COMMENT 'Details',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_visible` tinyint(1) NOT NULL DEFAULT '1',
  `website_id` int(10) unsigned DEFAULT NULL COMMENT 'Website ID',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `VAULT_PAYMENT_TOKEN_PUBLIC_HASH` (`public_hash`),
  UNIQUE KEY `VAULT_PAYMENT_TOKEN_PAYMENT_METHOD_CODE_CSTR_ID_GATEWAY_TOKEN` (`payment_method_code`,`customer_id`,`gateway_token`),
  KEY `VAULT_PAYMENT_TOKEN_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` (`customer_id`),
  CONSTRAINT `VAULT_PAYMENT_TOKEN_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Vault tokens of payment';


-- drakesterling_old.vault_payment_token_order_payment_link definition

CREATE TABLE `vault_payment_token_order_payment_link` (
  `order_payment_id` int(10) unsigned NOT NULL COMMENT 'Order payment ID',
  `payment_token_id` int(10) unsigned NOT NULL COMMENT 'Payment token ID',
  PRIMARY KEY (`order_payment_id`,`payment_token_id`),
  KEY `FK_4ED894655446D385894580BECA993862` (`payment_token_id`),
  CONSTRAINT `FK_4ED894655446D385894580BECA993862` FOREIGN KEY (`payment_token_id`) REFERENCES `vault_payment_token` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_CF37B9D854256534BE23C818F6291CA2` FOREIGN KEY (`order_payment_id`) REFERENCES `sales_order_payment` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Order payments to vault token';


-- drakesterling_old.wishlist definition

CREATE TABLE `wishlist` (
  `wishlist_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Wishlist ID',
  `customer_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Customer ID',
  `shared` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Sharing flag (0 or 1)',
  `sharing_code` varchar(32) DEFAULT NULL COMMENT 'Sharing encrypted code',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Last updated date',
  PRIMARY KEY (`wishlist_id`),
  UNIQUE KEY `WISHLIST_CUSTOMER_ID` (`customer_id`),
  KEY `WISHLIST_SHARED` (`shared`),
  CONSTRAINT `WISHLIST_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2032 DEFAULT CHARSET=utf8 COMMENT='Wishlist main Table';


-- drakesterling_old.wishlist_item definition

CREATE TABLE `wishlist_item` (
  `wishlist_item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Wishlist item ID',
  `wishlist_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Wishlist ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `added_at` timestamp NULL DEFAULT NULL COMMENT 'Add date and time',
  `description` text COMMENT 'Short description of wish list item',
  `qty` decimal(12,4) NOT NULL COMMENT 'Qty',
  PRIMARY KEY (`wishlist_item_id`),
  KEY `WISHLIST_ITEM_WISHLIST_ID` (`wishlist_id`),
  KEY `WISHLIST_ITEM_PRODUCT_ID` (`product_id`),
  KEY `WISHLIST_ITEM_STORE_ID` (`store_id`),
  CONSTRAINT `WISHLIST_ITEM_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `WISHLIST_ITEM_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL,
  CONSTRAINT `WISHLIST_ITEM_WISHLIST_ID_WISHLIST_WISHLIST_ID` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlist` (`wishlist_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Wishlist items';


-- drakesterling_old.wishlist_item_option definition

CREATE TABLE `wishlist_item_option` (
  `option_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Option ID',
  `wishlist_item_id` int(10) unsigned NOT NULL COMMENT 'Wishlist Item ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `code` varchar(255) NOT NULL COMMENT 'Code',
  `value` text COMMENT 'Value',
  PRIMARY KEY (`option_id`),
  KEY `FK_A014B30B04B72DD0EAB3EECD779728D6` (`wishlist_item_id`),
  CONSTRAINT `FK_A014B30B04B72DD0EAB3EECD779728D6` FOREIGN KEY (`wishlist_item_id`) REFERENCES `wishlist_item` (`wishlist_item_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Wishlist Item Option Table';


-- drakesterling_old.amazon_customer definition

CREATE TABLE `amazon_customer` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity_id',
  `customer_id` int(10) unsigned NOT NULL COMMENT 'Customer_id',
  `amazon_id` varchar(255) NOT NULL COMMENT 'Amazon_id',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `AMAZON_CUSTOMER_CUSTOMER_ID_AMAZON_ID` (`customer_id`,`amazon_id`),
  UNIQUE KEY `AMAZON_CUSTOMER_CUSTOMER_ID` (`customer_id`),
  CONSTRAINT `AMAZON_CUSTOMER_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='amazon_customer';


-- drakesterling_old.braintree_transaction_details definition

CREATE TABLE `braintree_transaction_details` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order Id',
  `transaction_source` varchar(12) DEFAULT NULL COMMENT 'Transaction Source',
  PRIMARY KEY (`entity_id`),
  KEY `BRAINTREE_TRANSACTION_DETAILS_ORDER_ID` (`order_id`),
  CONSTRAINT `BRAINTREE_TRANSACTION_DETAILS_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Braintree transaction details table';


-- drakesterling_old.catalog_compare_list definition

CREATE TABLE `catalog_compare_list` (
  `list_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Compare List ID',
  `list_id_mask` varchar(32) DEFAULT NULL COMMENT 'Masked ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  PRIMARY KEY (`list_id`),
  UNIQUE KEY `CATALOG_COMPARE_LIST_CUSTOMER_ID` (`customer_id`),
  KEY `CATALOG_COMPARE_LIST_LIST_ID_MASK` (`list_id_mask`),
  CONSTRAINT `CATALOG_COMPARE_LIST_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Compare List with hash Table';


-- drakesterling_old.catalog_product_frontend_action definition

CREATE TABLE `catalog_product_frontend_action` (
  `action_id` bigint(20) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Product Action ID',
  `type_id` varchar(64) NOT NULL COMMENT 'Type of product action',
  `visitor_id` int(10) unsigned DEFAULT NULL COMMENT 'Visitor ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL COMMENT 'Product ID',
  `added_at` bigint(20) NOT NULL COMMENT 'Added At',
  PRIMARY KEY (`action_id`),
  UNIQUE KEY `CATALOG_PRODUCT_FRONTEND_ACTION_VISITOR_ID_PRODUCT_ID_TYPE_ID` (`visitor_id`,`product_id`,`type_id`),
  UNIQUE KEY `CATALOG_PRODUCT_FRONTEND_ACTION_CUSTOMER_ID_PRODUCT_ID_TYPE_ID` (`customer_id`,`product_id`,`type_id`),
  KEY `CAT_PRD_FRONTEND_ACTION_PRD_ID_CAT_PRD_ENTT_ENTT_ID` (`product_id`),
  CONSTRAINT `CAT_PRD_FRONTEND_ACTION_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CAT_PRD_FRONTEND_ACTION_PRD_ID_CAT_PRD_ENTT_ENTT_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Catalog Product Frontend Action Table';


-- drakesterling_old.catalogsearch_recommendations definition

CREATE TABLE `catalogsearch_recommendations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `query_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Query ID',
  `relation_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Relation ID',
  PRIMARY KEY (`id`),
  KEY `CATALOGSEARCH_RECOMMENDATIONS_QUERY_ID_SEARCH_QUERY_QUERY_ID` (`query_id`),
  KEY `CATALOGSEARCH_RECOMMENDATIONS_RELATION_ID_SEARCH_QUERY_QUERY_ID` (`relation_id`),
  CONSTRAINT `CATALOGSEARCH_RECOMMENDATIONS_QUERY_ID_SEARCH_QUERY_QUERY_ID` FOREIGN KEY (`query_id`) REFERENCES `search_query` (`query_id`) ON DELETE CASCADE,
  CONSTRAINT `CATALOGSEARCH_RECOMMENDATIONS_RELATION_ID_SEARCH_QUERY_QUERY_ID` FOREIGN KEY (`relation_id`) REFERENCES `search_query` (`query_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Advanced Search Recommendations';


-- drakesterling_old.customer_address_entity definition

CREATE TABLE `customer_address_entity` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `parent_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `is_active` smallint(5) unsigned NOT NULL DEFAULT '1' COMMENT 'Is Active',
  `city` varchar(255) NOT NULL COMMENT 'City',
  `company` varchar(255) DEFAULT NULL COMMENT 'Company',
  `country_id` varchar(255) NOT NULL COMMENT 'Country',
  `fax` varchar(255) DEFAULT NULL COMMENT 'Fax',
  `firstname` varchar(255) NOT NULL COMMENT 'First Name',
  `lastname` varchar(255) NOT NULL COMMENT 'Last Name',
  `middlename` varchar(255) DEFAULT NULL COMMENT 'Middle Name',
  `postcode` varchar(255) DEFAULT NULL COMMENT 'Zip/Postal Code',
  `prefix` varchar(40) DEFAULT NULL COMMENT 'Name Prefix',
  `region` varchar(255) DEFAULT NULL COMMENT 'State/Province',
  `region_id` int(10) unsigned DEFAULT NULL COMMENT 'State/Province',
  `street` text NOT NULL COMMENT 'Street Address',
  `suffix` varchar(40) DEFAULT NULL COMMENT 'Name Suffix',
  `telephone` varchar(255) NOT NULL COMMENT 'Phone Number',
  `vat_id` varchar(255) DEFAULT NULL COMMENT 'VAT number',
  `vat_is_valid` int(10) unsigned DEFAULT NULL COMMENT 'VAT number validity',
  `vat_request_date` varchar(255) DEFAULT NULL COMMENT 'VAT number validation request date',
  `vat_request_id` varchar(255) DEFAULT NULL COMMENT 'VAT number validation request ID',
  `vat_request_success` int(10) unsigned DEFAULT NULL COMMENT 'VAT number validation request success',
  PRIMARY KEY (`entity_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_PARENT_ID` (`parent_id`),
  CONSTRAINT `CUSTOMER_ADDRESS_ENTITY_PARENT_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2722 DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity';


-- drakesterling_old.customer_address_entity_datetime definition

CREATE TABLE `customer_address_entity_datetime` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` datetime DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ADDRESS_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_DATETIME_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_DATETIME_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CSTR_ADDR_ENTT_DTIME_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_ADDR_ENTT_DTIME_ENTT_ID_CSTR_ADDR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_address_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity Datetime';


-- drakesterling_old.customer_address_entity_decimal definition

CREATE TABLE `customer_address_entity_decimal` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ADDRESS_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_DECIMAL_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_DECIMAL_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CSTR_ADDR_ENTT_DEC_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_ADDR_ENTT_DEC_ENTT_ID_CSTR_ADDR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_address_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity Decimal';


-- drakesterling_old.customer_address_entity_int definition

CREATE TABLE `customer_address_entity_int` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` int(11) NOT NULL DEFAULT '0' COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ADDRESS_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_INT_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_INT_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CSTR_ADDR_ENTT_INT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_ADDR_ENTT_INT_ENTT_ID_CSTR_ADDR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_address_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity Int';


-- drakesterling_old.customer_address_entity_text definition

CREATE TABLE `customer_address_entity_text` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` text NOT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ADDRESS_ENTITY_TEXT_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_TEXT_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `CSTR_ADDR_ENTT_TEXT_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_ADDR_ENTT_TEXT_ENTT_ID_CSTR_ADDR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_address_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity Text';


-- drakesterling_old.customer_address_entity_varchar definition

CREATE TABLE `customer_address_entity_varchar` (
  `value_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'Value ID',
  `attribute_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Attribute ID',
  `entity_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Entity ID',
  `value` varchar(255) DEFAULT NULL COMMENT 'Value',
  PRIMARY KEY (`value_id`),
  UNIQUE KEY `CUSTOMER_ADDRESS_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID` (`entity_id`,`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_VARCHAR_ATTRIBUTE_ID` (`attribute_id`),
  KEY `CUSTOMER_ADDRESS_ENTITY_VARCHAR_ENTITY_ID_ATTRIBUTE_ID_VALUE` (`entity_id`,`attribute_id`,`value`),
  CONSTRAINT `CSTR_ADDR_ENTT_VCHR_ATTR_ID_EAV_ATTR_ATTR_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `CSTR_ADDR_ENTT_VCHR_ENTT_ID_CSTR_ADDR_ENTT_ENTT_ID` FOREIGN KEY (`entity_id`) REFERENCES `customer_address_entity` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Customer Address Entity Varchar';


-- drakesterling_old.downloadable_link_purchased definition

CREATE TABLE `downloadable_link_purchased` (
  `purchased_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Purchased ID',
  `order_id` int(10) unsigned DEFAULT '0' COMMENT 'Order ID',
  `order_increment_id` varchar(50) DEFAULT NULL COMMENT 'Order Increment ID',
  `order_item_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Order Item ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Date of creation',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Date of modification',
  `customer_id` int(10) unsigned DEFAULT '0' COMMENT 'Customer ID',
  `product_name` varchar(255) DEFAULT NULL COMMENT 'Product name',
  `product_sku` varchar(255) DEFAULT NULL COMMENT 'Product sku',
  `link_section_title` varchar(255) DEFAULT NULL COMMENT 'Link_section_title',
  PRIMARY KEY (`purchased_id`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_ORDER_ID` (`order_id`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_ORDER_ITEM_ID` (`order_item_id`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_CUSTOMER_ID` (`customer_id`),
  CONSTRAINT `DL_LNK_PURCHASED_CSTR_ID_CSTR_ENTT_ENTT_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE SET NULL,
  CONSTRAINT `DOWNLOADABLE_LINK_PURCHASED_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Link Purchased Table';


-- drakesterling_old.downloadable_link_purchased_item definition

CREATE TABLE `downloadable_link_purchased_item` (
  `item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Item ID',
  `purchased_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Purchased ID',
  `order_item_id` int(10) unsigned DEFAULT '0' COMMENT 'Order Item ID',
  `product_id` int(10) unsigned DEFAULT '0' COMMENT 'Product ID',
  `link_hash` varchar(255) DEFAULT NULL COMMENT 'Link hash',
  `number_of_downloads_bought` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of downloads bought',
  `number_of_downloads_used` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Number of downloads used',
  `link_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Link ID',
  `link_title` varchar(255) DEFAULT NULL COMMENT 'Link Title',
  `is_shareable` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Shareable Flag',
  `link_url` varchar(255) DEFAULT NULL COMMENT 'Link Url',
  `link_file` varchar(255) DEFAULT NULL COMMENT 'Link File',
  `link_type` varchar(255) DEFAULT NULL COMMENT 'Link Type',
  `status` varchar(50) DEFAULT NULL COMMENT 'Status',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation Time',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Update Time',
  PRIMARY KEY (`item_id`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_ITEM_LINK_HASH` (`link_hash`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_ITEM_ORDER_ITEM_ID` (`order_item_id`),
  KEY `DOWNLOADABLE_LINK_PURCHASED_ITEM_PURCHASED_ID` (`purchased_id`),
  CONSTRAINT `DL_LNK_PURCHASED_ITEM_ORDER_ITEM_ID_SALES_ORDER_ITEM_ITEM_ID` FOREIGN KEY (`order_item_id`) REFERENCES `sales_order_item` (`item_id`) ON DELETE SET NULL,
  CONSTRAINT `DL_LNK_PURCHASED_ITEM_PURCHASED_ID_DL_LNK_PURCHASED_PURCHASED_ID` FOREIGN KEY (`purchased_id`) REFERENCES `downloadable_link_purchased` (`purchased_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Downloadable Link Purchased Item Table';


-- drakesterling_old.eav_form_fieldset definition

CREATE TABLE `eav_form_fieldset` (
  `fieldset_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Fieldset ID',
  `type_id` smallint(5) unsigned NOT NULL COMMENT 'Type ID',
  `code` varchar(64) NOT NULL COMMENT 'Code',
  `sort_order` int(11) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`fieldset_id`),
  UNIQUE KEY `EAV_FORM_FIELDSET_TYPE_ID_CODE` (`type_id`,`code`),
  CONSTRAINT `EAV_FORM_FIELDSET_TYPE_ID_EAV_FORM_TYPE_TYPE_ID` FOREIGN KEY (`type_id`) REFERENCES `eav_form_type` (`type_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Form Fieldset';


-- drakesterling_old.eav_form_fieldset_label definition

CREATE TABLE `eav_form_fieldset_label` (
  `fieldset_id` smallint(5) unsigned NOT NULL COMMENT 'Fieldset ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store ID',
  `label` varchar(255) NOT NULL COMMENT 'Label',
  PRIMARY KEY (`fieldset_id`,`store_id`),
  KEY `EAV_FORM_FIELDSET_LABEL_STORE_ID` (`store_id`),
  CONSTRAINT `EAV_FORM_FIELDSET_LABEL_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_FORM_FSET_LBL_FSET_ID_EAV_FORM_FSET_FSET_ID` FOREIGN KEY (`fieldset_id`) REFERENCES `eav_form_fieldset` (`fieldset_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Eav Form Fieldset Label';


-- drakesterling_old.email_order definition

CREATE TABLE `email_order` (
  `email_order_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `order_status` varchar(255) NOT NULL COMMENT 'Order Status',
  `quote_id` int(10) unsigned NOT NULL COMMENT 'Sales Quote ID',
  `store_id` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Store ID',
  `email_imported` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Order Imported',
  `modified` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Order Modified',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`email_order_id`),
  KEY `EMAIL_ORDER_STORE_ID` (`store_id`),
  KEY `EMAIL_ORDER_QUOTE_ID` (`quote_id`),
  KEY `EMAIL_ORDER_EMAIL_IMPORTED` (`email_imported`),
  KEY `EMAIL_ORDER_ORDER_STATUS` (`order_status`),
  KEY `EMAIL_ORDER_MODIFIED` (`modified`),
  KEY `EMAIL_ORDER_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_ORDER_CREATED_AT` (`created_at`),
  KEY `EMAIL_ORDER_ORDER_ID_SALES_ORDER_ENTITY_ID` (`order_id`),
  CONSTRAINT `EMAIL_ORDER_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EMAIL_ORDER_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=681 DEFAULT CHARSET=utf8 COMMENT='Transactional Order Data';


-- drakesterling_old.email_wishlist definition

CREATE TABLE `email_wishlist` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Primary Key',
  `wishlist_id` int(10) unsigned NOT NULL COMMENT 'Wishlist Id',
  `item_count` int(10) unsigned NOT NULL COMMENT 'Item Count',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `store_id` smallint(5) unsigned NOT NULL COMMENT 'Store Id',
  `wishlist_imported` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Wishlist Imported',
  `wishlist_modified` smallint(5) unsigned DEFAULT NULL COMMENT 'Wishlist Modified',
  `created_at` timestamp NULL DEFAULT NULL COMMENT 'Creation Time',
  `updated_at` timestamp NULL DEFAULT NULL COMMENT 'Update Time',
  PRIMARY KEY (`id`),
  KEY `EMAIL_WISHLIST_WISHLIST_ID` (`wishlist_id`),
  KEY `EMAIL_WISHLIST_ITEM_COUNT` (`item_count`),
  KEY `EMAIL_WISHLIST_CUSTOMER_ID` (`customer_id`),
  KEY `EMAIL_WISHLIST_WISHLIST_MODIFIED` (`wishlist_modified`),
  KEY `EMAIL_WISHLIST_WISHLIST_IMPORTED` (`wishlist_imported`),
  KEY `EMAIL_WISHLIST_CREATED_AT` (`created_at`),
  KEY `EMAIL_WISHLIST_UPDATED_AT` (`updated_at`),
  KEY `EMAIL_WISHLIST_STORE_ID` (`store_id`),
  CONSTRAINT `EMAIL_WISHLIST_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `EMAIL_WISHLIST_WISHLIST_ID_WISHLIST_WISHLIST_ID` FOREIGN KEY (`wishlist_id`) REFERENCES `wishlist` (`wishlist_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Connector Wishlist';


-- drakesterling_old.newsletter_problem definition

CREATE TABLE `newsletter_problem` (
  `problem_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Problem ID',
  `subscriber_id` int(10) unsigned DEFAULT NULL COMMENT 'Subscriber ID',
  `queue_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Queue ID',
  `problem_error_code` int(10) unsigned DEFAULT '0' COMMENT 'Problem Error Code',
  `problem_error_text` varchar(200) DEFAULT NULL COMMENT 'Problem Error Text',
  PRIMARY KEY (`problem_id`),
  KEY `NEWSLETTER_PROBLEM_SUBSCRIBER_ID` (`subscriber_id`),
  KEY `NEWSLETTER_PROBLEM_QUEUE_ID` (`queue_id`),
  CONSTRAINT `NEWSLETTER_PROBLEM_QUEUE_ID_NEWSLETTER_QUEUE_QUEUE_ID` FOREIGN KEY (`queue_id`) REFERENCES `newsletter_queue` (`queue_id`) ON DELETE CASCADE,
  CONSTRAINT `NLTTR_PROBLEM_SUBSCRIBER_ID_NLTTR_SUBSCRIBER_SUBSCRIBER_ID` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscriber` (`subscriber_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Newsletter Problems';


-- drakesterling_old.newsletter_queue_link definition

CREATE TABLE `newsletter_queue_link` (
  `queue_link_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Queue Link ID',
  `queue_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Queue ID',
  `subscriber_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Subscriber ID',
  `letter_sent_at` timestamp NULL DEFAULT NULL COMMENT 'Letter Sent At',
  PRIMARY KEY (`queue_link_id`),
  KEY `NEWSLETTER_QUEUE_LINK_SUBSCRIBER_ID` (`subscriber_id`),
  KEY `NEWSLETTER_QUEUE_LINK_QUEUE_ID_LETTER_SENT_AT` (`queue_id`,`letter_sent_at`),
  CONSTRAINT `NEWSLETTER_QUEUE_LINK_QUEUE_ID_NEWSLETTER_QUEUE_QUEUE_ID` FOREIGN KEY (`queue_id`) REFERENCES `newsletter_queue` (`queue_id`) ON DELETE CASCADE,
  CONSTRAINT `NLTTR_QUEUE_LNK_SUBSCRIBER_ID_NLTTR_SUBSCRIBER_SUBSCRIBER_ID` FOREIGN KEY (`subscriber_id`) REFERENCES `newsletter_subscriber` (`subscriber_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='Newsletter Queue Link';


-- drakesterling_old.paypal_billing_agreement_order definition

CREATE TABLE `paypal_billing_agreement_order` (
  `agreement_id` int(10) unsigned NOT NULL COMMENT 'Agreement ID',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  PRIMARY KEY (`agreement_id`,`order_id`),
  KEY `PAYPAL_BILLING_AGREEMENT_ORDER_ORDER_ID` (`order_id`),
  CONSTRAINT `PAYPAL_BILLING_AGREEMENT_ORDER_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `PAYPAL_BILLING_AGRT_ORDER_AGRT_ID_PAYPAL_BILLING_AGRT_AGRT_ID` FOREIGN KEY (`agreement_id`) REFERENCES `paypal_billing_agreement` (`agreement_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Billing Agreement Order';


-- drakesterling_old.quote_address_item definition

CREATE TABLE `quote_address_item` (
  `address_item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Address Item ID',
  `parent_item_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent Item ID',
  `quote_address_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Quote Address ID',
  `quote_item_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Quote Item ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `applied_rule_ids` text COMMENT 'Applied Rule Ids',
  `additional_data` text COMMENT 'Additional Data',
  `weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Weight',
  `qty` decimal(12,4) NOT NULL DEFAULT '0.0000' COMMENT 'Qty',
  `discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Discount Amount',
  `tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Tax Amount',
  `row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Row Total',
  `base_row_total` decimal(20,4) NOT NULL DEFAULT '0.0000' COMMENT 'Base Row Total',
  `row_total_with_discount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Row Total With Discount',
  `base_discount_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Discount Amount',
  `base_tax_amount` decimal(20,4) DEFAULT '0.0000' COMMENT 'Base Tax Amount',
  `row_weight` decimal(12,4) DEFAULT '0.0000' COMMENT 'Row Weight',
  `product_id` int(10) unsigned DEFAULT NULL COMMENT 'Product ID',
  `super_product_id` int(10) unsigned DEFAULT NULL COMMENT 'Super Product ID',
  `parent_product_id` int(10) unsigned DEFAULT NULL COMMENT 'Parent Product ID',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `image` varchar(255) DEFAULT NULL COMMENT 'Image',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `description` text COMMENT 'Description',
  `is_qty_decimal` int(10) unsigned DEFAULT NULL COMMENT 'Is Qty Decimal',
  `price` decimal(12,4) DEFAULT NULL COMMENT 'Price',
  `discount_percent` decimal(12,4) DEFAULT NULL COMMENT 'Discount Percent',
  `no_discount` int(10) unsigned DEFAULT NULL COMMENT 'No Discount',
  `tax_percent` decimal(12,4) DEFAULT NULL COMMENT 'Tax Percent',
  `base_price` decimal(20,4) DEFAULT NULL COMMENT 'Base Price',
  `base_cost` decimal(20,4) DEFAULT NULL COMMENT 'Base Cost',
  `price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Price Incl Tax',
  `base_price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Price Incl Tax',
  `row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Row Total Incl Tax',
  `base_row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total Incl Tax',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `free_shipping` int(10) unsigned DEFAULT NULL COMMENT 'Free Shipping',
  `gift_message_id` int(11) DEFAULT NULL COMMENT 'Gift Message ID',
  `carriergroup_id` text COMMENT 'Carrier Group ID',
  `carriergroup` text COMMENT 'ShipperHQ Carrier Group',
  `carriergroup_shipping` text COMMENT 'ShipperHQ Shipping Description',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  PRIMARY KEY (`address_item_id`),
  KEY `QUOTE_ADDRESS_ITEM_QUOTE_ADDRESS_ID` (`quote_address_id`),
  KEY `QUOTE_ADDRESS_ITEM_PARENT_ITEM_ID` (`parent_item_id`),
  KEY `QUOTE_ADDRESS_ITEM_QUOTE_ITEM_ID` (`quote_item_id`),
  KEY `QUOTE_ADDRESS_ITEM_STORE_ID` (`store_id`),
  CONSTRAINT `QUOTE_ADDRESS_ITEM_QUOTE_ADDRESS_ID_QUOTE_ADDRESS_ADDRESS_ID` FOREIGN KEY (`quote_address_id`) REFERENCES `quote_address` (`address_id`) ON DELETE CASCADE,
  CONSTRAINT `QUOTE_ADDRESS_ITEM_QUOTE_ITEM_ID_QUOTE_ITEM_ITEM_ID` FOREIGN KEY (`quote_item_id`) REFERENCES `quote_item` (`item_id`) ON DELETE CASCADE,
  CONSTRAINT `QUOTE_ADDR_ITEM_PARENT_ITEM_ID_QUOTE_ADDR_ITEM_ADDR_ITEM_ID` FOREIGN KEY (`parent_item_id`) REFERENCES `quote_address_item` (`address_item_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Quote Address Item';


-- drakesterling_old.sales_creditmemo definition

CREATE TABLE `sales_creditmemo` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `adjustment_positive` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Positive',
  `base_shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Tax Amount',
  `store_to_order_rate` decimal(20,4) DEFAULT NULL COMMENT 'Store To Order Rate',
  `base_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Amount',
  `base_to_order_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Order Rate',
  `grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Grand Total',
  `base_adjustment_negative` decimal(20,4) DEFAULT NULL COMMENT 'Base Adjustment Negative',
  `base_subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Incl Tax',
  `shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Amount',
  `subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Incl Tax',
  `adjustment_negative` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment Negative',
  `base_shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Amount',
  `store_to_base_rate` decimal(20,4) DEFAULT NULL COMMENT 'Store To Base Rate',
  `base_to_global_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Global Rate',
  `base_adjustment` decimal(20,4) DEFAULT NULL COMMENT 'Base Adjustment',
  `base_subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal',
  `discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Amount',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `adjustment` decimal(20,4) DEFAULT NULL COMMENT 'Adjustment',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `base_adjustment_positive` decimal(20,4) DEFAULT NULL COMMENT 'Base Adjustment Positive',
  `base_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Amount',
  `shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Tax Amount',
  `tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Amount',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `email_sent` smallint(5) unsigned DEFAULT NULL COMMENT 'Email Sent',
  `send_email` smallint(5) unsigned DEFAULT NULL COMMENT 'Send Email',
  `creditmemo_status` int(11) DEFAULT NULL COMMENT 'Creditmemo Status',
  `state` int(11) DEFAULT NULL COMMENT 'State',
  `shipping_address_id` int(11) DEFAULT NULL COMMENT 'Shipping Address ID',
  `billing_address_id` int(11) DEFAULT NULL COMMENT 'Billing Address ID',
  `invoice_id` int(11) DEFAULT NULL COMMENT 'Invoice ID',
  `store_currency_code` varchar(3) DEFAULT NULL COMMENT 'Store Currency Code',
  `order_currency_code` varchar(3) DEFAULT NULL COMMENT 'Order Currency Code',
  `base_currency_code` varchar(3) DEFAULT NULL COMMENT 'Base Currency Code',
  `global_currency_code` varchar(3) DEFAULT NULL COMMENT 'Global Currency Code',
  `transaction_id` varchar(255) DEFAULT NULL COMMENT 'Transaction ID',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `shipping_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Tax Compensation Amount',
  `base_shipping_discount_tax_compensation_amnt` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Tax Compensation Amount',
  `shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Incl Tax',
  `base_shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Incl Tax',
  `discount_description` varchar(255) DEFAULT NULL COMMENT 'Discount Description',
  `customer_note` text COMMENT 'Customer Note',
  `customer_note_notify` smallint(5) unsigned DEFAULT NULL COMMENT 'Customer Note Notify',
  `fee` decimal(10,0) DEFAULT '0' COMMENT 'Fee',
  `base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base Fee',
  `transaction_fee` decimal(10,0) DEFAULT '0' COMMENT 'TransactionFee',
  `transaction_base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base TransactionFee',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_CREDITMEMO_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_CREDITMEMO_STORE_ID` (`store_id`),
  KEY `SALES_CREDITMEMO_ORDER_ID` (`order_id`),
  KEY `SALES_CREDITMEMO_CREDITMEMO_STATUS` (`creditmemo_status`),
  KEY `SALES_CREDITMEMO_STATE` (`state`),
  KEY `SALES_CREDITMEMO_CREATED_AT` (`created_at`),
  KEY `SALES_CREDITMEMO_UPDATED_AT` (`updated_at`),
  KEY `SALES_CREDITMEMO_SEND_EMAIL` (`send_email`),
  KEY `SALES_CREDITMEMO_EMAIL_SENT` (`email_sent`),
  CONSTRAINT `SALES_CREDITMEMO_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_CREDITMEMO_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Creditmemo';


-- drakesterling_old.sales_creditmemo_comment definition

CREATE TABLE `sales_creditmemo_comment` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `is_customer_notified` int(11) DEFAULT NULL COMMENT 'Is Customer Notified',
  `is_visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible On Front',
  `comment` text COMMENT 'Comment',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_CREDITMEMO_COMMENT_CREATED_AT` (`created_at`),
  KEY `SALES_CREDITMEMO_COMMENT_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_CREDITMEMO_COMMENT_PARENT_ID_SALES_CREDITMEMO_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_creditmemo` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sales Flat Creditmemo Comment';


-- drakesterling_old.sales_creditmemo_item definition

CREATE TABLE `sales_creditmemo_item` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `base_price` decimal(20,4) DEFAULT NULL COMMENT 'Base Price',
  `tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Amount',
  `base_row_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total',
  `discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Amount',
  `row_total` decimal(20,4) DEFAULT NULL COMMENT 'Row Total',
  `base_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Amount',
  `price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Price Incl Tax',
  `base_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Amount',
  `base_price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Price Incl Tax',
  `qty` decimal(12,4) DEFAULT NULL COMMENT 'Qty',
  `base_cost` decimal(20,4) DEFAULT NULL COMMENT 'Base Cost',
  `price` decimal(20,4) DEFAULT NULL COMMENT 'Price',
  `base_row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total Incl Tax',
  `row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Row Total Incl Tax',
  `product_id` int(11) DEFAULT NULL COMMENT 'Product ID',
  `order_item_id` int(11) DEFAULT NULL COMMENT 'Order Item ID',
  `additional_data` text COMMENT 'Additional Data',
  `description` text COMMENT 'Description',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `tax_ratio` text COMMENT 'Ratio of tax in the creditmemo item over tax of the order item',
  `weee_tax_applied` text COMMENT 'Weee Tax Applied',
  `weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Amount',
  `weee_tax_applied_row_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Row Amount',
  `weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Disposition',
  `weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Row Disposition',
  `base_weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Amount',
  `base_weee_tax_applied_row_amnt` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Row Amnt',
  `base_weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Disposition',
  `base_weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Row Disposition',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_CREDITMEMO_ITEM_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_CREDITMEMO_ITEM_PARENT_ID_SALES_CREDITMEMO_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_creditmemo` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Creditmemo Item';


-- drakesterling_old.sales_invoice definition

CREATE TABLE `sales_invoice` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `base_grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Grand Total',
  `shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Tax Amount',
  `tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Amount',
  `base_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Amount',
  `store_to_order_rate` decimal(20,4) DEFAULT NULL COMMENT 'Store To Order Rate',
  `base_shipping_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Tax Amount',
  `base_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Amount',
  `base_to_order_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Order Rate',
  `grand_total` decimal(20,4) DEFAULT NULL COMMENT 'Grand Total',
  `shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Amount',
  `subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal Incl Tax',
  `base_subtotal_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal Incl Tax',
  `store_to_base_rate` decimal(20,4) DEFAULT NULL COMMENT 'Store To Base Rate',
  `base_shipping_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Amount',
  `total_qty` decimal(12,4) DEFAULT NULL COMMENT 'Total Qty',
  `base_to_global_rate` decimal(20,4) DEFAULT NULL COMMENT 'Base To Global Rate',
  `subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Subtotal',
  `base_subtotal` decimal(20,4) DEFAULT NULL COMMENT 'Base Subtotal',
  `discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Amount',
  `billing_address_id` int(11) DEFAULT NULL COMMENT 'Billing Address ID',
  `is_used_for_refund` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Used For Refund',
  `order_id` int(10) unsigned NOT NULL COMMENT 'Order ID',
  `email_sent` smallint(5) unsigned DEFAULT NULL COMMENT 'Email Sent',
  `send_email` smallint(5) unsigned DEFAULT NULL COMMENT 'Send Email',
  `can_void_flag` smallint(5) unsigned DEFAULT NULL COMMENT 'Can Void Flag',
  `state` int(11) DEFAULT NULL COMMENT 'State',
  `shipping_address_id` int(11) DEFAULT NULL COMMENT 'Shipping Address ID',
  `store_currency_code` varchar(3) DEFAULT NULL COMMENT 'Store Currency Code',
  `transaction_id` varchar(255) DEFAULT NULL COMMENT 'Transaction ID',
  `order_currency_code` varchar(3) DEFAULT NULL COMMENT 'Order Currency Code',
  `base_currency_code` varchar(3) DEFAULT NULL COMMENT 'Base Currency Code',
  `global_currency_code` varchar(3) DEFAULT NULL COMMENT 'Global Currency Code',
  `increment_id` varchar(50) DEFAULT NULL COMMENT 'Increment ID',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Updated At',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `shipping_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Discount Tax Compensation Amount',
  `base_shipping_discount_tax_compensation_amnt` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Discount Tax Compensation Amount',
  `shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Shipping Incl Tax',
  `base_shipping_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Shipping Incl Tax',
  `base_total_refunded` decimal(20,4) DEFAULT NULL COMMENT 'Base Total Refunded',
  `discount_description` varchar(255) DEFAULT NULL COMMENT 'Discount Description',
  `customer_note` text COMMENT 'Customer Note',
  `customer_note_notify` smallint(5) unsigned DEFAULT NULL COMMENT 'Customer Note Notify',
  `fee` decimal(10,0) DEFAULT '0' COMMENT 'Fee',
  `base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base Fee',
  `transaction_fee` decimal(10,0) DEFAULT '0' COMMENT 'TransactionFee',
  `transaction_base_fee` decimal(10,0) DEFAULT '0' COMMENT 'Base TransactionFee',
  PRIMARY KEY (`entity_id`),
  UNIQUE KEY `SALES_INVOICE_INCREMENT_ID_STORE_ID` (`increment_id`,`store_id`),
  KEY `SALES_INVOICE_STORE_ID` (`store_id`),
  KEY `SALES_INVOICE_GRAND_TOTAL` (`grand_total`),
  KEY `SALES_INVOICE_ORDER_ID` (`order_id`),
  KEY `SALES_INVOICE_STATE` (`state`),
  KEY `SALES_INVOICE_CREATED_AT` (`created_at`),
  KEY `SALES_INVOICE_UPDATED_AT` (`updated_at`),
  KEY `SALES_INVOICE_SEND_EMAIL` (`send_email`),
  KEY `SALES_INVOICE_EMAIL_SENT` (`email_sent`),
  CONSTRAINT `SALES_INVOICE_ORDER_ID_SALES_ORDER_ENTITY_ID` FOREIGN KEY (`order_id`) REFERENCES `sales_order` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `SALES_INVOICE_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3985 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Invoice';


-- drakesterling_old.sales_invoice_comment definition

CREATE TABLE `sales_invoice_comment` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `is_customer_notified` smallint(5) unsigned DEFAULT NULL COMMENT 'Is Customer Notified',
  `is_visible_on_front` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'Is Visible On Front',
  `comment` text COMMENT 'Comment',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Created At',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_INVOICE_COMMENT_CREATED_AT` (`created_at`),
  KEY `SALES_INVOICE_COMMENT_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_INVOICE_COMMENT_PARENT_ID_SALES_INVOICE_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_invoice` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Invoice Comment';


-- drakesterling_old.sales_invoice_item definition

CREATE TABLE `sales_invoice_item` (
  `entity_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Entity ID',
  `parent_id` int(10) unsigned NOT NULL COMMENT 'Parent ID',
  `base_price` decimal(20,4) DEFAULT NULL COMMENT 'Base Price',
  `tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Tax Amount',
  `base_row_total` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total',
  `discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Amount',
  `row_total` decimal(20,4) DEFAULT NULL COMMENT 'Row Total',
  `base_discount_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Amount',
  `price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Price Incl Tax',
  `base_tax_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Tax Amount',
  `base_price_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Price Incl Tax',
  `qty` decimal(12,4) DEFAULT NULL COMMENT 'Qty',
  `base_cost` decimal(20,4) DEFAULT NULL COMMENT 'Base Cost',
  `price` decimal(20,4) DEFAULT NULL COMMENT 'Price',
  `base_row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Base Row Total Incl Tax',
  `row_total_incl_tax` decimal(20,4) DEFAULT NULL COMMENT 'Row Total Incl Tax',
  `product_id` int(11) DEFAULT NULL COMMENT 'Product ID',
  `order_item_id` int(11) DEFAULT NULL COMMENT 'Order Item ID',
  `additional_data` text COMMENT 'Additional Data',
  `description` text COMMENT 'Description',
  `sku` varchar(255) DEFAULT NULL COMMENT 'Sku',
  `name` varchar(255) DEFAULT NULL COMMENT 'Name',
  `discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Discount Tax Compensation Amount',
  `base_discount_tax_compensation_amount` decimal(20,4) DEFAULT NULL COMMENT 'Base Discount Tax Compensation Amount',
  `tax_ratio` text COMMENT 'Ratio of tax invoiced over tax of the order item',
  `weee_tax_applied` text COMMENT 'Weee Tax Applied',
  `weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Amount',
  `weee_tax_applied_row_amount` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Applied Row Amount',
  `weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Disposition',
  `weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Weee Tax Row Disposition',
  `base_weee_tax_applied_amount` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Amount',
  `base_weee_tax_applied_row_amnt` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Applied Row Amnt',
  `base_weee_tax_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Disposition',
  `base_weee_tax_row_disposition` decimal(12,4) DEFAULT NULL COMMENT 'Base Weee Tax Row Disposition',
  PRIMARY KEY (`entity_id`),
  KEY `SALES_INVOICE_ITEM_PARENT_ID` (`parent_id`),
  CONSTRAINT `SALES_INVOICE_ITEM_PARENT_ID_SALES_INVOICE_ENTITY_ID` FOREIGN KEY (`parent_id`) REFERENCES `sales_invoice` (`entity_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5892 DEFAULT CHARSET=utf8 COMMENT='Sales Flat Invoice Item';


-- drakesterling_old.catalog_compare_item definition

CREATE TABLE `catalog_compare_item` (
  `catalog_compare_item_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Compare Item ID',
  `visitor_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Visitor ID',
  `customer_id` int(10) unsigned DEFAULT NULL COMMENT 'Customer ID',
  `product_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT 'Product ID',
  `store_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Store ID',
  `list_id` int(10) unsigned DEFAULT NULL COMMENT 'List ID',
  PRIMARY KEY (`catalog_compare_item_id`),
  KEY `CATALOG_COMPARE_ITEM_PRODUCT_ID` (`product_id`),
  KEY `CATALOG_COMPARE_ITEM_VISITOR_ID_PRODUCT_ID` (`visitor_id`,`product_id`),
  KEY `CATALOG_COMPARE_ITEM_CUSTOMER_ID_PRODUCT_ID` (`customer_id`,`product_id`),
  KEY `CATALOG_COMPARE_ITEM_STORE_ID` (`store_id`),
  KEY `CATALOG_COMPARE_ITEM_LIST_ID_CATALOG_COMPARE_LIST_LIST_ID` (`list_id`),
  CONSTRAINT `CATALOG_COMPARE_ITEM_CUSTOMER_ID_CUSTOMER_ENTITY_ENTITY_ID` FOREIGN KEY (`customer_id`) REFERENCES `customer_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CATALOG_COMPARE_ITEM_LIST_ID_CATALOG_COMPARE_LIST_LIST_ID` FOREIGN KEY (`list_id`) REFERENCES `catalog_compare_list` (`list_id`) ON DELETE CASCADE,
  CONSTRAINT `CATALOG_COMPARE_ITEM_PRODUCT_ID_CATALOG_PRODUCT_ENTITY_ENTITY_ID` FOREIGN KEY (`product_id`) REFERENCES `catalog_product_entity` (`entity_id`) ON DELETE CASCADE,
  CONSTRAINT `CATALOG_COMPARE_ITEM_STORE_ID_STORE_STORE_ID` FOREIGN KEY (`store_id`) REFERENCES `store` (`store_id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='Catalog Compare Table';


-- drakesterling_old.eav_form_element definition

CREATE TABLE `eav_form_element` (
  `element_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT 'Element ID',
  `type_id` smallint(5) unsigned NOT NULL COMMENT 'Type ID',
  `fieldset_id` smallint(5) unsigned DEFAULT NULL COMMENT 'Fieldset ID',
  `attribute_id` smallint(5) unsigned NOT NULL COMMENT 'Attribute ID',
  `sort_order` int(11) NOT NULL DEFAULT '0' COMMENT 'Sort Order',
  PRIMARY KEY (`element_id`),
  UNIQUE KEY `EAV_FORM_ELEMENT_TYPE_ID_ATTRIBUTE_ID` (`type_id`,`attribute_id`),
  KEY `EAV_FORM_ELEMENT_FIELDSET_ID` (`fieldset_id`),
  KEY `EAV_FORM_ELEMENT_ATTRIBUTE_ID` (`attribute_id`),
  CONSTRAINT `EAV_FORM_ELEMENT_ATTRIBUTE_ID_EAV_ATTRIBUTE_ATTRIBUTE_ID` FOREIGN KEY (`attribute_id`) REFERENCES `eav_attribute` (`attribute_id`) ON DELETE CASCADE,
  CONSTRAINT `EAV_FORM_ELEMENT_FIELDSET_ID_EAV_FORM_FIELDSET_FIELDSET_ID` FOREIGN KEY (`fieldset_id`) REFERENCES `eav_form_fieldset` (`fieldset_id`) ON DELETE SET NULL,
  CONSTRAINT `EAV_FORM_ELEMENT_TYPE_ID_EAV_FORM_TYPE_TYPE_ID` FOREIGN KEY (`type_id`) REFERENCES `eav_form_type` (`type_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8 COMMENT='Eav Form Element';