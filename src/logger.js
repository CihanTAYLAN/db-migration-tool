const winston = require('winston');

// Renkli konsol formatı
const consoleFormat = winston.format.combine(
    winston.format.timestamp({ format: 'HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.colorize(),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
        let msg = `${timestamp} ${level}: ${message}`;

        // Meta verileri ekle
        if (Object.keys(meta).length > 0) {
            msg += ` ${JSON.stringify(meta, null, 2)}`;
        }

        return msg;
    })
);

// Dosya formatı (renksiz)
const fileFormat = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.json()
);

// Logger oluştur
const logger = winston.createLogger({
    level: process.env.LOG_LEVEL || 'info',
    format: fileFormat,
    transports: [
        // Konsol çıktısı
        new winston.transports.Console({
            format: consoleFormat
        }),

        // Hata logları için dosya
        new winston.transports.File({
            filename: 'logs/error.log',
            level: 'error',
            format: fileFormat
        }),

        // Tüm loglar için dosya
        new winston.transports.File({
            filename: 'logs/combined.log',
            format: fileFormat
        })
    ]
});

// Development ortamında daha detaylı log
if (process.env.NODE_ENV === 'development') {
    logger.level = 'debug';
}

// Özel log metodları
logger.success = (message, meta = {}) => {
    logger.log('info', `✅ ${message}`, meta);
};

logger.error = (message, meta = {}) => {
    logger.log('error', `❌ ${message}`, meta);
};

logger.warning = (message, meta = {}) => {
    logger.log('warn', `⚠️ ${message}`, meta);
};

logger.info = (message, meta = {}) => {
    logger.log('info', `ℹ️ ${message}`, meta);
};

logger.debug = (message, meta = {}) => {
    logger.log('debug', `🔍 ${message}`, meta);
};

module.exports = logger;
