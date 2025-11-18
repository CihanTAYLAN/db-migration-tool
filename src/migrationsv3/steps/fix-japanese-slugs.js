/*
# Fix Japanese Slugs Step

Converts Japanese slugs to Romaji (Latin script) for better URL compatibility.
Only processes Japanese language content_translations records.
*/

const logger = require("../../logger");

class FixJapaneseSlugsStep {
	constructor(targetDb, config, domain) {
		this.targetDb = targetDb;
		this.config = config;
		this.domain = domain;
	}

	async run() {
		logger.info("Starting fix Japanese slugs step");

		try {
			let totalProcessed = 0;
			let totalUpdated = 0;

			// Define all translation tables to process
			const translationTables = [
				{
					table: "content_translations",
					description: "Content translations",
				},
				{
					table: "product_translations",
					description: "Product translations",
				},
				{
					table: "category_translations",
					description: "Category translations",
				},
				{
					table: "page_translations",
					description: "Page translations",
				},
			];

			// Process each translation table
			for (const tableInfo of translationTables) {
				logger.info(`Processing Japanese slugs in ${tableInfo.description}...`);

				const result = await this.fixJapaneseSlugsInTable(tableInfo.table);
				totalProcessed += result.processed;
				totalUpdated += result.updated;

				logger.info(
					`${tableInfo.description}: ${result.updated} Japanese slugs updated`,
				);
			}

			logger.success(
				`Fix Japanese slugs step completed: ${totalUpdated} total records updated across all tables`,
			);

			return {
				success: true,
				count: totalProcessed,
				updated: totalUpdated,
			};
		} catch (error) {
			logger.error("Fix Japanese slugs step failed", { error: error.message });
			throw error;
		}
	}

	// Romaji conversion mapping for Japanese characters
	getRomajiMap() {
		return {
			// Hiragana to Romaji
			あ: "a",
			い: "i",
			う: "u",
			え: "e",
			お: "o",
			か: "ka",
			き: "ki",
			く: "ku",
			け: "ke",
			こ: "ko",
			さ: "sa",
			し: "shi",
			す: "su",
			せ: "se",
			そ: "so",
			た: "ta",
			ち: "chi",
			つ: "tsu",
			て: "te",
			と: "to",
			な: "na",
			に: "ni",
			ぬ: "nu",
			ね: "ne",
			の: "no",
			は: "ha",
			ひ: "hi",
			ふ: "fu",
			へ: "he",
			ほ: "ho",
			ま: "ma",
			み: "mi",
			む: "mu",
			め: "me",
			も: "mo",
			や: "ya",
			ゆ: "yu",
			よ: "yo",
			ら: "ra",
			り: "ri",
			る: "ru",
			れ: "re",
			ろ: "ro",
			わ: "wa",
			を: "wo",
			ん: "n",
			が: "ga",
			ぎ: "gi",
			ぐ: "gu",
			げ: "ge",
			ご: "go",
			ざ: "za",
			じ: "ji",
			ず: "zu",
			ぜ: "ze",
			ぞ: "zo",
			だ: "da",
			ぢ: "ji",
			づ: "zu",
			で: "de",
			ど: "do",
			ば: "ba",
			び: "bi",
			ぶ: "bu",
			べ: "be",
			ぼ: "bo",
			ぱ: "pa",
			ぴ: "pi",
			ぷ: "pu",
			ぺ: "pe",
			ぽ: "po",
			ゃ: "ya",
			ゅ: "yu",
			ょ: "yo",
			っ: "tsu",

			// Katakana to Romaji
			ア: "a",
			イ: "i",
			ウ: "u",
			エ: "e",
			オ: "o",
			カ: "ka",
			キ: "ki",
			ク: "ku",
			ケ: "ke",
			コ: "ko",
			サ: "sa",
			シ: "shi",
			ス: "su",
			セ: "se",
			ソ: "so",
			タ: "ta",
			チ: "chi",
			ツ: "tsu",
			テ: "te",
			ト: "to",
			ナ: "na",
			ニ: "ni",
			ヌ: "nu",
			ネ: "ne",
			ノ: "no",
			ハ: "ha",
			ヒ: "hi",
			フ: "fu",
			ヘ: "he",
			ホ: "ho",
			マ: "ma",
			ミ: "mi",
			ム: "mu",
			メ: "me",
			モ: "mo",
			ヤ: "ya",
			ユ: "yu",
			ヨ: "yo",
			ラ: "ra",
			リ: "ri",
			ル: "ru",
			レ: "re",
			ロ: "ro",
			ワ: "wa",
			ヲ: "wo",
			ン: "n",
			ガ: "ga",
			ギ: "gi",
			グ: "gu",
			ゲ: "ge",
			ゴ: "go",
			ザ: "za",
			ジ: "ji",
			ズ: "zu",
			ゼ: "ze",
			ゾ: "zo",
			ダ: "da",
			ヂ: "ji",
			ヅ: "zu",
			デ: "de",
			ド: "do",
			バ: "ba",
			ビ: "bi",
			ブ: "bu",
			ベ: "be",
			ボ: "bo",
			パ: "pa",
			ピ: "pi",
			プ: "pu",
			ペ: "pe",
			ポ: "po",
			ャ: "ya",
			ュ: "yu",
			ョ: "yo",
			ッ: "tsu",
			ー: "-",

			// Kanji approximations (common ones)
			年: "nen",
			月: "gatsu",
			日: "nichi",
			時: "ji",
			分: "fun",
			秒: "byo",
			後: "go",
			前: "mae",
			上: "ue",
			下: "shita",
			中: "naka",
			大: "dai",
			小: "sho",
			新: "shin",
			古: "furui",
			多: "ooi",
			少: "sukunai",
			高: "takai",
			低: "hikui",
			長: "nagai",
			短: "mijikai",
			早: "haya",
			遅: "oso",
			良: "yoi",
			悪: "warui",
			美: "utsukushii",
			醜: "minikui",
			強: "tsuyoi",
			弱: "yowai",
			易: "yasashii",
			難: "katai",
			近: "chikai",
			遠: "tooi",
			同: "onaji",
			異: "chigau",
			一: "ichi",
			二: "ni",
			三: "san",
			四: "yo",
			五: "go",
			六: "roku",
			七: "nana",
			八: "hachi",
			九: "kyu",
			十: "ju",

			// Special characters
			"・": "-",
			" ": "-",
			_: "-",
			"「": "",
			"」": "",
			"『": "",
			"』": "",
			"（": "",
			"）": "",
			"(": "",
			")": "",
			"[": "",
			"]": "",
			"{": "",
			"}": "",
		};
	}

	convertToRomaji(text) {
		if (!text || typeof text !== "string") {
			return text;
		}

		let romaji = text;
		const romajiMap = this.getRomajiMap();

		// Replace Japanese characters with Romaji
		for (const [japanese, roman] of Object.entries(romajiMap)) {
			// Use word boundaries to avoid partial replacements
			const regex = new RegExp(
				japanese.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
				"g",
			);
			romaji = romaji.replace(regex, roman);
		}

		// Clean up the result - remove any remaining non-ASCII characters
		romaji = romaji.replace(/[^\w-]/g, "-");

		// Remove multiple consecutive hyphens
		romaji = romaji.replace(/-+/g, "-");

		// Remove leading/trailing hyphens
		romaji = romaji.replace(/^-+|-+$/g, "");

		// Convert to lowercase
		romaji = romaji.toLowerCase();

		return romaji;
	}

	async fixJapaneseSlugsInTable(tableName) {
		try {
			// First, get the Japanese language ID
			const langQuery = "SELECT id FROM languages WHERE code = 'ja' LIMIT 1";
			const langResult = await this.targetDb.query(langQuery);

			if (langResult.length === 0) {
				throw new Error("Japanese language not found");
			}

			const japaneseLanguageId = langResult[0].id;
			logger.debug(`Japanese language ID: ${japaneseLanguageId}`);

			// Get all Japanese records with non-empty slugs for this table
			// Note: Some tables might not have 'title' column, so we select only what's available
			let selectFields = "id, slug";
			if (tableName === "content_translations") {
				selectFields = "id, slug, title"; // content_translations has title
			}

			const query = `
                SELECT ${selectFields}
                FROM ${tableName}
                WHERE language_id = $1
                AND (slug IS NOT NULL AND slug != '')
                ORDER BY id
            `;

			const records = await this.targetDb.query(query, [japaneseLanguageId]);

			if (records.length === 0) {
				logger.debug(`No Japanese ${tableName} records found`);
				return { processed: 0, updated: 0 };
			}

			logger.debug(
				`Found ${records.length} Japanese ${tableName} records to check`,
			);

			// Identify records where slug contains Japanese characters
			const recordsToFix = [];

			for (const record of records) {
				const slug = record.slug;

				// Check if slug contains Japanese characters (Hiragana, Katakana, or Kanji)
				const hasJapaneseChars =
					/[\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf]/.test(slug);

				if (hasJapaneseChars) {
					// Convert to Romaji
					const romajiSlug = this.convertToRomaji(slug);

					// If conversion resulted in a different slug, we need to update
					if (romajiSlug && romajiSlug !== slug) {
						logger.debug(
							`Converting Japanese slug in ${tableName}: "${slug}" -> "${romajiSlug}"`,
						);
						recordsToFix.push({
							id: record.id,
							oldSlug: slug,
							newSlug: romajiSlug,
						});
					}
				}
			}

			if (recordsToFix.length === 0) {
				logger.debug(
					`No Japanese slugs found that need conversion in ${tableName}`,
				);
				return { processed: records.length, updated: 0 };
			}

			logger.debug(
				`Found ${recordsToFix.length} Japanese slugs that need conversion in ${tableName}`,
			);

			// Update the records in batches
			const batchSize = this.config.steps.fixJapaneseSlugs.batchSize || 50;
			let totalUpdated = 0;

			for (let i = 0; i < recordsToFix.length; i += batchSize) {
				const batch = recordsToFix.slice(i, i + batchSize);

				try {
					// Individual updates for safety (since we're dealing with slug changes)
					for (const record of batch) {
						const updateQuery = `
                            UPDATE ${tableName}
                            SET slug = $1, updated_at = NOW()
                            WHERE id = $2
                        `;
						await this.targetDb.query(updateQuery, [record.newSlug, record.id]);
						totalUpdated++;
					}

					logger.debug(
						`Updated batch of ${batch.length} Japanese slugs in ${tableName}`,
					);
				} catch (error) {
					logger.error(
						`Failed to update batch starting at index ${i} in ${tableName}`,
						{ error: error.message },
					);

					// Continue with individual updates for failed batch
					for (const record of batch) {
						try {
							const updateQuery = `
                                UPDATE ${tableName}
                                SET slug = $1, updated_at = NOW()
                                WHERE id = $2
                            `;
							await this.targetDb.query(updateQuery, [
								record.newSlug,
								record.id,
							]);
							totalUpdated++;
						} catch (individualError) {
							logger.error(
								`Failed to update Japanese slug for ${tableName} record ${record.id}`,
								{
									error: individualError.message,
									oldSlug: record.oldSlug,
									newSlug: record.newSlug,
								},
							);
						}
					}
				}
			}

			return { processed: records.length, updated: totalUpdated };
		} catch (error) {
			logger.error(`Failed to fix Japanese slugs in ${tableName}`, {
				error: error.message,
			});
			return { processed: 0, updated: 0 };
		}
	}
}

module.exports = FixJapaneseSlugsStep;
