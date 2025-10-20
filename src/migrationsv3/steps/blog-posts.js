/*
# Blog Posts Migration Step

Migrates blog posts from Mageplaza Blog module to the contents system.
Migrates to contents and content_translations tables.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class BlogPostsStep {
  constructor(sourceDb, targetDb, config, defaultLanguageId) {
    this.sourceDb = sourceDb;
    this.targetDb = targetDb;
    this.config = config;
    this.defaultLanguageId = defaultLanguageId;
    this.batchProcessor = new BatchProcessor({
      batchSize: config.steps.blog_posts.batchSize,
      parallelLimit: config.steps.blog_posts.parallelLimit,
      retryAttempts: config.processing.retryAttempts,
      retryDelay: config.processing.retryDelay,
      timeout: config.processing.timeout,
      onProgress: (progress, stats) => {
        logger.info(`Blog posts migration progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
      }
    });
  }

  async run() {
    logger.info('Starting blog posts migration step...');

    try {
      // 1. Fetch source blog posts
      const blogPosts = await this.fetchSourceBlogPosts();

      if (blogPosts.length === 0) {
        logger.warning('No blog posts found to migrate');
        return { success: true, count: 0 };
      }

      logger.info(`Found ${blogPosts.length} blog posts to migrate`);

      // 2. Transform and migrate blog posts in batches
      const result = await this.batchProcessor.process(blogPosts, async (batch) => {
        return await this.processBlogPostBatch(batch);
      });

      logger.success(`Blog posts migration completed: ${result.success} success, ${result.failed} failed`);

      return {
        success: result.failed === 0,
        count: result.success,
        failed: result.failed
      };

    } catch (error) {
      logger.error('Blog posts migration step failed', { error: error.message });
      throw error;
    }
  }

  async fetchSourceBlogPosts() {
    logger.info('Fetching source blog posts...');

    const query = `
            SELECT
                post_id,
                name,
                short_description,
                post_content,
                image,
                views,
                url_key,
                meta_title,
                meta_description,
                meta_keywords,
                in_rss,
                allow_comment,
                publish_date,
                created_at,
                updated_at,
                enabled
            FROM mageplaza_blog_post
            WHERE enabled = 1
            ORDER BY created_at DESC
        `;

    const blogPosts = await this.sourceDb.query(query);
    logger.info(`Fetched ${blogPosts.length} enabled blog posts from source`);

    return blogPosts;
  }

  async processBlogPostBatch(blogPosts) {
    try {
      // Transform blog posts for contents and translations
      const transformed = this.transformBlogPosts(blogPosts, this.defaultLanguageId);

      // Insert contents and get the actual IDs
      let insertedContents = [];
      if (transformed.contents.length > 0) {
        insertedContents = await this.insertContents(transformed.contents);
      }

      // Create mapping from post_id to content_id
      const idMapping = new Map();
      insertedContents.forEach(content => {
        idMapping.set(content.postId, content.actualId);
      });

      // Update translation content_ids with actual IDs
      const updatedTranslations = transformed.translations.map(translation => ({
        ...translation,
        content_id: idMapping.get(translation.content_id) || translation.content_id
      }));

      // Insert content translations
      if (updatedTranslations.length > 0) {
        await this.insertContentTranslations(updatedTranslations);
      }

      return { success: blogPosts.length, failed: 0 };

    } catch (error) {
      logger.error('Failed to process blog post batch', { error: error.message, count: blogPosts.length });
      return { success: 0, failed: blogPosts.length };
    }
  }

  transformBlogPosts(blogPosts, defaultLanguageId) {
    const contents = [];
    const translations = [];

    for (const post of blogPosts) {
      const { v4: uuidv4 } = require('uuid');

      // Safe date parsing
      const parseDate = (dateStr) => {
        if (!dateStr || dateStr === '0000-00-00 00:00:00') {
          return new Date(); // Default to current time for invalid dates
        }
        const date = new Date(dateStr);
        return isNaN(date.getTime()) ? new Date() : date;
      };

      const backendUrlPrefix = 'https://drakesterling-backend.dev.uplide.com/api/ecommerce/file-manager/stream/blog/';

      // Create content entry
      const contentId = uuidv4();
      const content = {
        id: contentId,
        sort: post.post_id, // Use post_id as sort for consistency
        image: post.image ? backendUrlPrefix + post.image.replace('mageplaza/blog/post/', '') : null,
        type: 'news', // Fixed type for blog posts
        created_at: parseDate(post.created_at),
        updated_at: parseDate(post.updated_at),
        published: true, // All active posts are published
        is_allowed: true,
        postId: post.post_id // Keep reference for mapping
      };
      contents.push(content);

      // Create translation entry
      const translation = {
        id: uuidv4(),
        title: post.name || '',
        slug: this.generateSlug(post.url_key),
        description: post.post_content || '',
        meta_title: post.meta_title || null,
        meta_description: post.meta_description || null,
        meta_keywords: post.meta_keywords || null,
        created_at: parseDate(post.created_at),
        updated_at: parseDate(post.updated_at),
        content_id: contentId,
        language_id: defaultLanguageId
      };
      translations.push(translation);
    }

    return { contents, translations };
  }

  generateSlug(urlKey) {
    if (urlKey) return urlKey.toLowerCase().replace(/[^a-z0-9-]/g, '');
    return null;
  }

  async insertContents(contents) {
    const insertedContents = [];

    for (const content of contents) {
      const result = await this.targetDb.query(`
                INSERT INTO contents (id, sort, image, type, created_at, updated_at, published, is_allowed)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
                RETURNING id
            `, [
        content.id,
        content.sort,
        content.image,
        content.type,
        content.created_at,
        content.updated_at,
        content.published,
        content.is_allowed
      ]);

      insertedContents.push({
        postId: content.postId,
        actualId: result[0].id
      });
    }

    return insertedContents;
  }

  async insertContentTranslations(translations) {
    for (const translation of translations) {
      const existing = await this.targetDb.query(
        'SELECT id FROM content_translations WHERE content_id = $1 AND language_id = $2',
        [translation.content_id, translation.language_id]
      );

      if (existing.length > 0) {
        // Update existing
        await this.targetDb.query(`
                    UPDATE content_translations SET
                        title = $1, slug = $2, description = $3, meta_title = $4,
                        meta_description = $5, meta_keywords = $6, updated_at = $7
                    WHERE id = $8
                `, [
          translation.title,
          translation.slug,
          translation.description,
          translation.meta_title,
          translation.meta_description,
          translation.meta_keywords,
          translation.updated_at,
          existing[0].id
        ]);
      } else {
        // Insert new
        await this.targetDb.query(`
                    INSERT INTO content_translations (
                        id, title, slug, description, meta_title, meta_description,
                        meta_keywords, created_at, updated_at, content_id, language_id
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                `, [
          translation.id,
          translation.title,
          translation.slug,
          translation.description,
          translation.meta_title,
          translation.meta_description,
          translation.meta_keywords,
          translation.created_at,
          translation.updated_at,
          translation.content_id,
          translation.language_id
        ]);
      }
    }
  }
}

module.exports = BlogPostsStep;
