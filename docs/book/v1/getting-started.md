# Getting Started

## Install

Pick one — both land the same files.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
mkdir -p .claude
cp -r .dotboost/.claude/. .claude/
rm -rf .dotboost
```

### Download the zip

No git needed:

```bash
cd <project>
curl -L -o dotboost.zip https://github.com/dotkernel/dotboost/archive/refs/heads/main.zip
unzip -q dotboost.zip
mkdir -p .claude
cp -r dotboost-main/.claude/. .claude/
rm -rf dotboost-main dotboost.zip
```

## After copying, either way

```bash
chmod +x .claude/hooks/*.sh .claude/statusline.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

Nothing in the payload is committed with an executable bit, and a zip extracted on Windows carries no permission bits at all.
`settings.json` invokes the hooks and the status line as `bash <path>`, so they run regardless; the `chmod` only matters when you run one of them by hand.
The `settings.local.json` line keeps personal, git-ignored overrides out of `git add .`.

The trailing `/.` copies the *contents* of the payload's `.claude/`, so it merges into an existing `.claude/` instead of nesting a second one at `.claude/.claude/`.
Merging still overwrites same-named files: if the target project already has its own `.claude/settings.json` or `.claude/commands/`, merge by hand instead of running the copy blind.

## Add the `CLAUDE.md` block

The dependency policy in `dotkernel-package-status`, the feature-docs check and the writing style in `dotkernel-writing-style` need a short block pasted into the *project's own* `CLAUDE.md` to become proactive rather than merely loadable — see [Architecture Overview](architecture.md#the-claudemd-contract) and [Package Status](skills/dotkernel-package-status.md).

All Dotkernel projects write prose in ASD-STE100 Simplified Technical English.
Paste this block to make the `dotkernel-writing-style` skill always active:

```markdown
## Writing style

Write all prose in ASD-STE100 Simplified Technical English.
This includes chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments and docblock descriptions.
Do not apply it to the code itself: identifiers, keywords, syntax and docblock tags stay as they are.
Load the `dotkernel-writing-style` skill before you write any of this prose.
```

## Optional: markdown linting

`.claude/hooks/markdown-lint.sh` checks every `.md` file Claude writes against `.claude/markdownlint.jsonc`.
It needs `markdownlint-cli2`, not bundled:

```bash
npm install -g markdownlint-cli2
```

A project-local `devDependency` works too — the hook prefers `./node_modules/.bin/markdownlint-cli2` and falls back to the global one.
Until the binary is resolvable the hook exits silently, so `.claude/` stays drop-in for projects with no Node toolchain.

## Verify

Start Claude Code in the project and run `/help` — you should see `dk-bootstrap`, `dk-module`, `dk-route`, `dk-trace`, `dk-test`, `dk-document`, `dk-check`, `dk-deprecate`, `dk-review`, `dk-hygiene`.
The session-start hook should open with a short briefing: detected project variant, root namespace, authorization style (flagging a guard policy that leaves unlisted routes public), and which config files are still missing.

Full end-to-end verification steps, including how to test the guardrails themselves, are in [Verifying an Install](verifying-an-install.md).
