"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.migrationLoader = exports.MigrationLoader = void 0;
class MigrationLoader {
    constructor() {
        this.migrations = new Map();
    }
    async loadMigrations() {
        // src/migrations klasöründeki tüm dosyaları yükle
        const fs = require('fs');
        const path = require('path');
        const migrationsPath = path.join(__dirname, '../migrations');
        if (!fs.existsSync(migrationsPath)) {
            console.warn('Migrations directory not found:', migrationsPath);
            return;
        }
        const files = fs.readdirSync(migrationsPath).filter((file) => file.endsWith('.ts') || file.endsWith('.js'));
        for (const file of files) {
            try {
                const filePath = path.join(migrationsPath, file);
                const migrationModule = require(filePath);
                if (migrationModule.config && migrationModule.execute) {
                    const tableName = migrationModule.config.targetTable;
                    this.migrations.set(tableName, migrationModule);
                    console.log(`✓ Loaded migration for table: ${tableName}`);
                }
            }
            catch (error) {
                console.error(`Failed to load migration file ${file}:`, error);
            }
        }
    }
    getMigration(tableName) {
        return this.migrations.get(tableName);
    }
    getAllMigrations() {
        return this.migrations;
    }
    getAvailableTables() {
        return Array.from(this.migrations.keys());
    }
}
exports.MigrationLoader = MigrationLoader;
exports.migrationLoader = new MigrationLoader();
//# sourceMappingURL=migration-config.js.map