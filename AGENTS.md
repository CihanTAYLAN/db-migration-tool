# AGENTS.md - DB Migration Tool Kuralları

Bu dosya, proje için ajan kurallarını tanımlar. Alt klasör AGENTS.md override eder (yoksa kök geçerli).

## Zorunlu Okuma Sırası
1. Bulunduğu klasör AGENTS.md (override).
2. Kök AGENTS.md (bu dosya).
3. Yoksa "AGENTS.md bulamadım; kuralları kullanıcıdan sor" de, varsayım yapma.

## Kurulum
- Bağımlılıklar: `yarn install`.
- Geliştir: `yarn dev` (nodemon ile watch).
- Build: `yarn build` (tsc veya babel).
- CLI çalıştır: `yarn cli` veya `node src/cli/index.js`.
- Test: `yarn test`.

## Kod Stili
- JS strict mode: "use strict"; camelCase değişken/fonksiyon.
- Fonksiyonlar: Single responsibility, early return.
- No magic numbers; constants kullan.
- Yorumlar: İngilizce, kısa ("why" açıkla).
- No console.log; logger.js kullan (structured log).
- Dosya < 200 satır; modüllere böl (src/db.js, src/cli/).
- Error handling: Try-catch, custom errors.

## Güvenlik & Performans
- No hard-coded secrets (DB creds); .env.example güncelle.
- DB: Connection pool, no raw SQL if ORM (Prisma? Yoksa pg).
- CLI: Input validation (yargs commander), no injection.
- Migrations: Idempotent, rollback support.
- Log: Sensitive maskele (passwords [REDACTED]).

## Dil & Yorum
- Kod yorum: İngilizce.
- Doküman: Türkçe.
- AGENTS.md Türkçe ise yanıt Türkçe.

## Hata Durumu
- Çelişkili kural: Kullanıcıya göster, kod üretme.

**Özet: Kural yoksa hareket yok. Detaylı bilgi README.md.**
