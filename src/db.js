const mysql = require('mysql2/promise');
const { Client } = require('pg');

class DbClient {
    constructor(connectionString, dbType) {
        this.dbType = dbType;
        this.connectionString = connectionString;

        if (dbType === 'mysql') {
            this.client = mysql.createPool(connectionString);
        } else if (dbType === 'postgresql') {
            this.client = new Client({ connectionString });
        } else {
            throw new Error(`Unsupported database type: ${dbType}`);
        }
    }

    async connect() {
        if (this.dbType === 'postgresql') {
            await this.client.connect();
        }
    }

    async query(sql, params = []) {
        try {
            if (this.dbType === 'mysql') {
                const [rows] = await this.client.execute(sql, params);
                return rows;
            } else if (this.dbType === 'postgresql') {
                const res = await this.client.query(sql, params);
                // For backward compatibility, return rows directly, but add rowCount property
                res.rows.rowCount = res.rowCount;
                return res.rows;
            }
        } catch (error) {
            throw new Error(`Query failed (${this.dbType}): ${error.message}`);
        }
    }

    async close() {
        if (this.dbType === 'mysql') {
            await this.client.end();
        } else if (this.dbType === 'postgresql') {
            await this.client.end();
        }
    }
}

module.exports = { DbClient };
