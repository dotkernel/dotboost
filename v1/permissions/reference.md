# Reference

## Never read

`Read` denies — these never enter the context window:

- `.env`
- every `*.local.php`
- `config/autoload/local.php`
- `config/autoload/local.test.php`
- `data/oauth/`

## Never written

`Edit`/`Write` denies:

- dependency manifests: `composer.json`, `composer.lock`, `package.json`, `package-lock.json`
- `vendor/`, `node_modules/`
- `data/`, `log/`, `public/uploads/`
- anything under `Migration/` or `Migrations/`

## Never run

`Bash` denies:

- `composer require`/`remove`/`update`/`install`/`global`
- the `npm`/`yarn`/`pnpm` install and removal verbs
- `git push`, `git reset --hard`, `git clean`, `git submodule`
- `rm -rf`

## Ask first

- `doctrine-migrations`, `bin/doctrine`, `bin/cli.php`
- `mysql`/`mariadb`
- `git commit`/`add`/`checkout`/`rebase`/`merge`
- `config/pipeline.php`, `config/config.php`, the authorization config
- `phpcs.xml`/`phpstan.neon`/`phpunit.xml`
- `.github/`, `CHANGELOG.md`, `SECURITY.md`, the project README

## Allowed outright

- the Composer QA scripts: `check`, `cs-check`, `cs-fix`, `static-analysis`, `test`
- `clear-config-cache`, `development-status`, `dump-autoload`
- `vendor/bin` tools
- `php -l`, `php -v`, `php -m`
- read-only git: `status`, `diff`, `log`, `show`, `branch`, `ls-files`, `config --get`
