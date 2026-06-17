# Backend — SkillSphere Laravel 12-style REST API

Minimal notes to run this backend locally.

Requirements
- PHP 8.2+
- Composer
- MySQL or other supported DB

Quick start
1. Copy `.env.example` to `.env` and set database credentials.
2. Set `JWT_SECRET` and optionally `JWT_TTL_MINUTES` in `.env`.
3. Install dependencies:

```bash
composer install
```

4. Generate app key (if using Laravel features):

```bash
php artisan key:generate
```

5. Run migrations and seeders:

```bash
php artisan migrate --seed
```

6. Start the server:

```bash
php artisan serve --host=127.0.0.1 --port=8000
```

Notes
- Ensure a `treasury` wallet exists (seeders should create it). The `EconomyService` expects a wallet with `type = treasury`.
- JWT settings are in `config/jwt.php` and require `JWT_SECRET` in the environment.

If you want me to push this as a branch, confirm and I'll create a branch, commit, and push.
