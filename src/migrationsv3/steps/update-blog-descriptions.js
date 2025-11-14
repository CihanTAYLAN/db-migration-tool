/*
# Update Blog Descriptions Migration Step

Updates content_translations.description field from Mageplaza blog posts.
Matches existing content records by URL key or post ID and updates their descriptions.
Handles Magento media URL parsing and conversion to proper URLs.
*/

const logger = require('../../logger');
const BatchProcessor = require('../lib/batch-processor');

class UpdateBlogDescriptionsStep {
  constructor(sourceDb, targetDb, config, defaultLanguageId, domain) {
    this.sourceDb = sourceDb;
    this.targetDb = targetDb;
    this.config = config;
    this.defaultLanguageId = defaultLanguageId;
    this.domain = domain;

    if (!domain) {
      throw new Error('Domain parameter is required for updateBlogDescriptions step');
    }

    // Validate domain format
    if (!this.isValidDomain(domain)) {
      throw new Error('Invalid domain format. Expected format: https://example.com');
    }

    this.batchProcessor = new BatchProcessor({
      batchSize: config.steps.update_blog_descriptions?.batchSize || 50,
      parallelLimit: config.steps.update_blog_descriptions?.parallelLimit || 5,
      retryAttempts: config.processing.retryAttempts,
      retryDelay: config.processing.retryDelay,
      timeout: config.processing.timeout,
      onProgress: (progress, stats) => {
        logger.info(`Blog descriptions update progress: ${progress}% (${stats.success} success, ${stats.failed} failed)`);
      }
    });
  }

  isValidDomain(domain) {
    // URL validation - should start with https:// and contain valid domain characters (with optional path)
    const domainRegex = /^https:\/\/[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\/.*)?$/;
    return domainRegex.test(domain);
  }

  async run() {
    logger.info(`Starting blog descriptions update step for domain: ${this.domain}`);

    try {
      // 1. Fetch source blog posts
      const blogPosts = await this.fetchSourceBlogPosts();

      if (blogPosts.length === 0) {
        logger.warning('No blog posts found to update descriptions');
        return { success: true, count: 0 };
      }

      logger.info(`Found ${blogPosts.length} blog posts to update descriptions`);

      // 2. Process and update descriptions in batches
      const result = await this.batchProcessor.process(blogPosts, async (batch) => {
        return await this.processBlogDescriptionsBatch(batch);
      });

      logger.success(`Blog descriptions update completed: ${result.success} success, ${result.failed} failed`);

      return {
        success: result.failed === 0,
        count: result.success,
        failed: result.failed
      };

    } catch (error) {
      logger.error('Blog descriptions update step failed', { error: error.message });
      throw error;
    }
  }

  async fetchSourceBlogPosts() {
    logger.info('Fetching source blog posts for description update...');

    const query = `
      SELECT
        post_id,
        url_key,
        short_description,
        post_content,
        updated_at
      FROM mageplaza_blog_post
      WHERE enabled = 1
      ORDER BY updated_at DESC
    `;

    const blogPosts = await this.sourceDb.query(query);
    logger.info(`Fetched ${blogPosts.length} blog posts from source`);

    return blogPosts;
  }

  async processBlogDescriptionsBatch(blogPosts) {
    try {
      let successCount = 0;
      let failedCount = 0;

      for (const post of blogPosts) {
        try {
          // Find matching content_translation by slug (derived from url_key) or post_id
          const matchingTranslation = await this.findMatchingTranslation(post);

          if (matchingTranslation) {
            // Create description from post content with Magento media URL parsing
            const description = this.createDescription(post);
            
            // Update the description
            await this.updateDescription(matchingTranslation.id, description, post.updated_at);
            successCount++;
            
            logger.debug(`Updated description for post ${post.post_id} (${post.url_key})`);
          } else {
            logger.warning(`No matching translation found for post ${post.post_id} (${post.url_key})`);
            failedCount++;
          }
        } catch (error) {
          logger.error(`Failed to update description for post ${post.post_id}`, { error: error.message });
          failedCount++;
        }
      }

      return { success: successCount, failed: failedCount };

    } catch (error) {
      logger.error('Failed to process blog descriptions batch', { error: error.message, count: blogPosts.length });
      return { success: 0, failed: blogPosts.length };
    }
  }

  async findMatchingTranslation(post) {
    // Try to find by slug (url_key converted to slug format)
    const slug = this.generateSlug(post.url_key);
    
    // First try to find by slug
    let translation = await this.targetDb.query(`
      SELECT id, content_id 
      FROM content_translations 
      WHERE slug = $1 AND language_id = $2
      LIMIT 1
    `, [slug, this.defaultLanguageId]);

    if (translation.length > 0) {
      return translation[0];
    }

    // If not found by slug, try to find by content that was created from this blog post
    // This uses the deterministic UUID pattern from blog-posts.js
    const { v5: uuidv5 } = require('uuid');
    const blogNamespace = '1b671a64-40d5-491e-99b0-da01ff1f3341';
    const contentId = uuidv5(post.post_id.toString(), blogNamespace);
    
    translation = await this.targetDb.query(`
      SELECT id, content_id 
      FROM content_translations 
      WHERE content_id = $1 AND language_id = $2
      LIMIT 1
    `, [contentId, this.defaultLanguageId]);

    if (translation.length > 0) {
      return translation[0];
    }

    return null;
  }

  createDescription(post) {
    // Create a comprehensive description combining short_description and post_content
    let description = '';
    
    if (post.short_description && post.short_description.trim()) {
      description += this.parseMagentoMediaUrls(post.short_description.trim());
    }
    
    if (post.post_content && post.post_content.trim()) {
      if (description) {
        description += '\n\n';
      }
      description += this.parseMagentoMediaUrls(post.post_content.trim());
    }
    
    return description || '';
  }

  parseMagentoMediaUrls(content) {
    // Replace Magento media URLs and direct image URLs with API endpoint URLs
    // Convert all to: src="{backendDomain}/api/ecommerce/file-manager/stream/mg-blog-images/{image-path}"
    
    // First, handle Magento media URLs with src=: src="{{media url="path/to/image.jpg"}}
    const magentoMediaWithSrcPattern = /src="{{media url="([^"]+)"}}/g;
    
    content = content.replace(magentoMediaWithSrcPattern, (match, urlPath) => {
      // Remove leading slash and replace path
      const cleanPath = urlPath.startsWith('/') ? urlPath.slice(1) : urlPath;
      const updatedPath = cleanPath.replace(/^media\/wysiwyg\//, 'mg-blog-images/').replace(/^wysiwyg\//, 'mg-blog-images/');
      const fullUrl = `${this.domain}/api/ecommerce/file-manager/stream/${updatedPath}`;
      
      logger.debug(`Converted Magento media URL (with src): ${match} -> src="${fullUrl}"`);
      
      return `src="${fullUrl}"`;
    });
    
    // Handle Magento media URLs without src=: {{media url="path/to/image.jpg"}}
    const magentoMediaWithoutSrcPattern = /\{\{media url="([^"]+)"\}\}/g;
    
    content = content.replace(magentoMediaWithoutSrcPattern, (match, urlPath) => {
      // Remove leading slash and replace path
      const cleanPath = urlPath.startsWith('/') ? urlPath.slice(1) : urlPath;
      const updatedPath = cleanPath.replace(/^media\/wysiwyg\//, 'mg-blog-images/').replace(/^wysiwyg\//, 'mg-blog-images/');
      const fullUrl = `${this.domain}/api/ecommerce/file-manager/stream/${updatedPath}`;
      
      logger.debug(`Converted Magento media URL (without src): ${match} -> ${fullUrl}`);
      
      return fullUrl;
    });
    
    // Then, handle direct image URLs with wysiwyg path
    const directImagePattern = /src="([^"]*wysiwyg\/[^"]+)"/g;
    
    content = content.replace(directImagePattern, (match, imageUrl) => {
      // Extract everything after wysiwyg/
      const pathMatch = imageUrl.match(/wysiwyg\/(.+)$/);
      if (pathMatch) {
        const imagePath = pathMatch[1];
        
        // Replace domain with target domain if different, then update path
        let newUrl = imageUrl;
        if (this.domain) {
          // Extract current domain from URL
          const urlMatch = imageUrl.match(/^https?:\/\/[^/]+/);
          if (urlMatch) {
            newUrl = `${this.domain}${imageUrl.substring(urlMatch[0].length)}`;
          }
        }
        
        // Replace wysiwyg with mg-blog-images
        newUrl = newUrl.replace(/wysiwyg\//, 'mg-blog-images/');
        
        logger.debug(`Converted direct image URL: ${match} -> src="${newUrl}"`);
        
        return `src="${newUrl}"`;
      }
      
      return match;
    });
    
    return content;
  }

  async updateDescription(translationId, description, updatedAt) {
    // Safe date parsing
    const parseDate = (dateStr) => {
      if (!dateStr || dateStr === '0000-00-00 00:00:00') {
        return new Date();
      }
      const date = new Date(dateStr);
      return isNaN(date.getTime()) ? new Date() : date;
    };

    await this.targetDb.query(`
      UPDATE content_translations 
      SET description = $1, updated_at = $2
      WHERE id = $3
    `, [
      description,
      parseDate(updatedAt),
      translationId
    ]);
  }

  generateSlug(urlKey) {
    if (urlKey) return urlKey.toLowerCase().replace(/[^a-z0-9-]/g, '');
    return null;
  }
}

module.exports = UpdateBlogDescriptionsStep;