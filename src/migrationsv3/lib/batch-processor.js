/*
# Batch Processor Library

Handles batch processing with parallel execution, retry logic, and progress tracking.
*/

const logger = require('../../logger');

class BatchProcessor {
    constructor(options = {}) {
        this.batchSize = options.batchSize || 100;
        this.parallelLimit = options.parallelLimit || 1;
        this.retryAttempts = options.retryAttempts || 3;
        this.retryDelay = options.retryDelay || 1000;
        this.timeout = options.timeout || 300000; // 5 minutes
        this.onProgress = options.onProgress || null;
        this.onError = options.onError || null;
    }

    async process(items, processorFn, options = {}) {
        if (!Array.isArray(items) || items.length === 0) {
            logger.info('No items to process');
            return { success: 0, failed: 0, total: 0 };
        }

        const batches = this.createBatches(items, this.batchSize);
        logger.info(`Created ${batches.length} batches of max ${this.batchSize} items each`);

        let successCount = 0;
        let failedCount = 0;
        let processedBatches = 0;

        // Process batches in parallel with limit
        const processBatch = async (batch, batchIndex) => {
            try {
                const result = await this.processBatchWithRetry(batch, processorFn, batchIndex);
                successCount += result.success;
                failedCount += result.failed;

                processedBatches++;
                if (this.onProgress) {
                    const progress = Math.round((processedBatches / batches.length) * 100);
                    this.onProgress(progress, { success: successCount, failed: failedCount });
                }

                return result;
            } catch (error) {
                logger.error(`Batch ${batchIndex} failed permanently`, { error: error.message });
                failedCount += batch.length;
                processedBatches++;

                if (this.onError) {
                    this.onError(error, batch, batchIndex);
                }

                return { success: 0, failed: batch.length };
            }
        };

        // Process batches with parallel limit
        const promises = [];
        for (let i = 0; i < batches.length; i += this.parallelLimit) {
            const batchPromises = batches
                .slice(i, i + this.parallelLimit)
                .map((batch, index) => processBatch(batch, i + index));

            promises.push(...batchPromises);

            // Wait for current parallel batch to complete before starting next
            if (i + this.parallelLimit < batches.length) {
                await Promise.allSettled(batchPromises);
            }
        }

        // Wait for all batches to complete
        await Promise.allSettled(promises);

        logger.success(`Batch processing completed: ${successCount} success, ${failedCount} failed, ${items.length} total`);

        return {
            success: successCount,
            failed: failedCount,
            total: items.length,
            batchesProcessed: processedBatches
        };
    }

    createBatches(items, batchSize) {
        const batches = [];
        for (let i = 0; i < items.length; i += batchSize) {
            batches.push(items.slice(i, i + batchSize));
        }
        return batches;
    }

    async processBatchWithRetry(batch, processorFn, batchIndex) {
        let lastError;

        for (let attempt = 1; attempt <= this.retryAttempts; attempt++) {
            try {
                logger.debug(`Processing batch ${batchIndex}, attempt ${attempt}/${this.retryAttempts}`);

                const result = await this.executeWithTimeout(
                    () => processorFn(batch, batchIndex),
                    this.timeout
                );

                return {
                    success: result?.success || batch.length,
                    failed: result?.failed || 0
                };

            } catch (error) {
                lastError = error;
                logger.warn(`Batch ${batchIndex} attempt ${attempt} failed`, { error: error.message });

                if (attempt < this.retryAttempts) {
                    await this.delay(this.retryDelay * attempt); // Exponential backoff
                }
            }
        }

        // All retry attempts failed
        throw lastError;
    }

    async executeWithTimeout(fn, timeoutMs) {
        return new Promise(async (resolve, reject) => {
            const timeout = setTimeout(() => {
                reject(new Error(`Operation timed out after ${timeoutMs}ms`));
            }, timeoutMs);

            try {
                const result = await fn();
                clearTimeout(timeout);
                resolve(result);
            } catch (error) {
                clearTimeout(timeout);
                reject(error);
            }
        });
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Utility method for processing single items
    async processItem(item, processorFn, options = {}) {
        return this.process([item], (batch) => processorFn(batch[0]), options);
    }
}

module.exports = BatchProcessor;
