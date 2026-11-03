# Reference

## Never read

`Read` denies — Claude's file tools and the Bash file commands Claude Code recognises (`cat`, `head`, `tail`, `sed`, `tee`) cannot open these.
A command that reads files without naming them, such as `grep -r`, is not covered:

- `.env`
- every `*.local.php`
- `config/autoload/local.php`
- `config/autoload/local.test.php`
- `data/oauth/`

## Never written

`Edit` denies — Claude Code applies `Edit` rules to every file-editing tool, `Write` included, and `guard-protected-paths.sh` blocks these paths for every file-writing tool at the hook layer too (for `data/`, only `cache/`, `lock/` and `oauth/`):

- dependency manifests: `composer.json`, `composer.lock`, `package.json`, `package-lock.json`
- `vendor/`, `node_modules/`
- `data/`, `log/`, `public/uploads/`
- anything under `Migration/` or `Migrations/`
- every `*.local.php`, `config/autoload/local.php`, `config/autoload/local.test.php`

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
- `php ./vendor/bin/phpcs`, `phpcbf`, `phpstan`, `phpunit` — only with the `php ./` prefix; a bare `vendor/bin/phpunit` prompts
- `markdownlint-cli2`, `./node_modules/.bin/markdownlint-cli2`
- `php -l`, `php -v`, `php -m`
- `date +%F`
- read-only git: `status`, `diff`, `log`, `show`, `branch`, `ls-files`, `config --get`
- edits under `docs/features/` and `documentation/features/`
