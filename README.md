# Migration CLI

A powerful and flexible database migration tool for migrating data between different database systems. Built with Node.js and designed for ease of use and extensibility.

## Features

- 🚀 **Easy Migration**: Simple command-line interface for database migrations
- 🔄 **Flexible Database Support**: Migrate between any supported database types
- 📊 **Connection Testing**: Test database connections before running migrations
- 📝 **Structured Logging**: Comprehensive logging with Winston
- 🛠️ **Extensible**: Easy to add new migration types and customize behavior
- 🎯 **Template System**: Reusable migration templates for consistent patterns

## Installation

### Global Installation (Recommended)

```bash
npm install -g migration-cli
# or
yarn global add migration-cli
```

### Local Installation

```bash
git clone https://github.com/yourusername/migration-cli.git
cd migration-cli
npm install
# or
yarn install
```

## Configuration

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Edit the `.env` file with your actual database configurations:

```env
# Source Database Configuration
SOURCE_DB_TYPE=mysql
SOURCE_DATABASE_URL=mysql://your_username:your_password@localhost:3306/your_source_db

# Target Database Configuration
TARGET_DB_TYPE=postgresql
TARGET_DATABASE_URL=postgresql://your_username:your_password@localhost:5432/your_target_db?schema=public

# Optional: Logging Level
LOG_LEVEL=info
```

### Environment Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `SOURCE_DB_TYPE` | Source database type (mysql, postgresql) | Yes | - |
| `SOURCE_DATABASE_URL` | Source database connection URL | Yes | - |
| `TARGET_DB_TYPE` | Target database type (mysql, postgresql) | Yes | - |
| `TARGET_DATABASE_URL` | Target database connection URL | Yes | - |
| `LOG_LEVEL` | Logging level (error, warn, info, debug) | No | `info` |

## Usage

### Basic Commands

```bash
# Test source database connection
migration-cli test-source

# Test target database connection
migration-cli test-target

# Run all migrations
migration-cli migrate

# List available migrations
migration-cli migration-list

# Show database configurations
migration-cli source-db-config
migration-cli target-db-config

# Show help
migration-cli --help
```

### Development Mode

If you're running from source:

```bash
# Install dependencies
yarn install

# Test database connections
yarn test-connections

# Run all migrations
yarn migrate

# Run specific commands
yarn dev test-source
yarn dev migrate
yarn dev --help
```

### Products Migration Workflow

The tool includes a complete products migration system that migrates Magento 2 products to PostgreSQL:

1. **Categories Migration** (`categories.js`): Migrates product categories with hierarchy
2. **Products Migration** (`products.js`): Migrates basic product information
3. **Product Categories** (`product_categories.js`): Links products to categories
4. **Product Images** (`product_images.js`): Migrates product gallery images
5. **Product Translations** (`product_translations.js`): Migrates multi-language content
6. **Product Prices** (`product_prices.js`): Migrates pricing information with currency support

#### Migration Order

The migrations run automatically in the correct order when you execute `yarn migrate`:

1. Categories → Creates category hierarchy
2. Products → Creates product records
3. Product Categories → Links products to categories
4. Product Images → Adds product images
5. Product Translations → Adds translations
6. Product Prices → Adds pricing data

#### Magento 2 EAV Support

The migration system fully supports Magento 2's EAV (Entity-Attribute-Value) structure:

- Automatically discovers attribute IDs for product fields
- Handles store-specific values (store_id = 0 for default)
- Supports multi-language content through store views
- Migrates complex product attributes and relationships

## Migration Structure

### Creating a New Migration

1. Create a new file in `src/migrations/` directory
2. Extend the `MigrationTemplate` class
3. Implement the `run()` method

Example migration file (`src/migrations/users.js`):

```javascript
const { MigrationTemplate } = require('./template');
const logger = require('../logger');

class UsersMigration extends MigrationTemplate {
    async run() {
        logger.info('Starting users migration...');

        try {
            // Read users data from source
            const users = await this.query('source', 'SELECT * FROM users');
            logger.info(`${users.length} users found`);

            if (users.length === 0) {
                logger.warning('Users table is empty or does not exist in source database');
                return;
            }

            // Create users table in target (if not exists)
            await this.query('target', `
                CREATE TABLE IF NOT EXISTS users (
                    id SERIAL PRIMARY KEY,
                    username VARCHAR(255) UNIQUE NOT NULL,
                    email VARCHAR(255) UNIQUE NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            `);

            // Insert each user into target
            for (const user of users) {
                await this.query('target', `
                    INSERT INTO users (id, username, email, created_at)
                    VALUES (?, ?, ?, ?)
                    ON CONFLICT (id) DO UPDATE SET
                        username = EXCLUDED.username,
                        email = EXCLUDED.email,
                        created_at = EXCLUDED.created_at
                `, [user.id, user.username, user.email, user.created_at]);
            }

            logger.success('Users migration completed');
        } catch (error) {
            logger.error('Users migration failed', { error: error.message });
            logger.info('Migration continuing...');
        }
    }
}

module.exports = { default: UsersMigration };
```

### Migration Template Methods

The `MigrationTemplate` class provides several useful methods:

- `check()`: Test database connections
- `query(dbType, sql, params)`: Execute SQL queries on source or target databases
- `run()`: Main migration logic (must be implemented by subclasses)

## Database Support

### Supported Databases

- **Source**: MySQL (using mysql2)
- **Target**: PostgreSQL (using pg)

### Connection URLs

#### MySQL
```
mysql://username:password@host:port/database
```

#### PostgreSQL
```
postgresql://username:password@host:port/database?schema=schema_name
```

## Logging

The application uses Winston for structured logging:

- **Console Output**: Colored, timestamped logs
- **File Output**: JSON format logs in `logs/` directory
- **Log Levels**: error, warn, info, debug

### Log Files

- `logs/error.log`: Error-level logs only
- `logs/combined.log`: All log levels

### Log Level Configuration

Set the `LOG_LEVEL` environment variable:

```env
LOG_LEVEL=debug  # Show all logs including debug
LOG_LEVEL=info   # Show info, warn, and error logs
LOG_LEVEL=error  # Show only error logs
```

## Development

### Project Structure

```
migration-cli/
├── src/
│   ├── cli/
│   │   └── index.js          # CLI interface
│   ├── db.js                 # Database client wrapper
│   ├── logger.js             # Winston logger configuration
│   ├── migrations/
│   │   ├── template.js       # Base migration template
│   │   └── products.js       # Example products migration
│   └── index.js              # Main entry point
├── .env                      # Environment configuration (create from .env.example)
├── .env.example              # Environment configuration template
├── package.json              # Project configuration
├── README.md                 # This file
└── .gitignore               # Git ignore rules
```

### Adding New Features

1. **New CLI Commands**: Add to `src/cli/index.js`
2. **New Migration Types**: Create in `src/migrations/`
3. **Database Support**: Extend `src/db.js`
4. **Logging**: Use the logger from `src/logger.js`

### Testing

```bash
# Test database connections
yarn dev test-source
yarn dev test-target

# Test migrations
yarn dev migrate

# Test CLI help
yarn dev --help
```

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and add tests
4. Commit your changes: `git commit -am 'Add new feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

### Development Guidelines

- Use async/await for asynchronous operations
- Handle errors gracefully with try/catch
- Use the provided logger for all logging
- Follow the existing code style
- Add JSDoc comments for new functions
- Test your changes thoroughly

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/yourusername/migration-cli/issues) page
2. Create a new issue with detailed information
3. Include your environment details and error logs

## Changelog

### v1.0.0
- Initial release
- Flexible database migration support
- CLI interface with multiple commands
- Winston logging integration
- Template-based migration system
- Connection testing functionality

## Roadmap

- [ ] Support for additional database types
- [ ] Migration rollback functionality
- [ ] Migration status tracking

---

Made with ❤️ for database migration needs
