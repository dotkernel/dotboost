# Getting Started

## Install

Select one way.
Both ways install the same files.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
mkdir -p .claude
cp -r .dotboost/.claude/. .claude/
rm -rf .dotboost
```

### Download the zip

This way does not need git:

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

The payload commits no file with an executable bit.
Also, a zip that you extract on Windows has no permission bits at all.
`settings.json` runs the hooks and the status line as `bash <path>`, so they run without the bits.
The `chmod` is necessary only when you run one of them manually.
The `settings.local.json` line keeps personal, git-ignored overrides out of `git add .`.

The trailing `/.` copies the *contents* of the `.claude/` directory in the payload.
Thus, the copy merges into an existing `.claude/` directory.
It does not put a second directory at `.claude/.claude/`.
But the merge still overwrites the files that have the same name.
If the target project already has its own `.claude/settings.json` or `.claude/commands/`, merge the files manually.
Do not run the copy without a check.

## Add the `CLAUDE.md` block

Three behaviors need a short block in the *project's own* `CLAUDE.md`:

- the dependency policy in `dotkernel-package-status`
- the feature-docs check
- the writing style in `dotkernel-writing-style`

Without the block, these behaviors are only loadable.
With the block, they become proactive.
For more information, see [Architecture Overview](architecture.md#the-claudemd-contract) and [Package Status](skills/dotkernel-package-status.md).

All Dotkernel projects and packages write prose in ASD-STE100 Simplified Technical English.
Paste this block to make the `dotkernel-writing-style` skill always active:

```markdown
## Writing style

Write all prose in ASD-STE100 Simplified Technical English.
This includes chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments, docblock descriptions, exception messages, CLI output and OpenAPI descriptions.
Do not apply it to the code itself: identifiers, keywords, syntax and docblock tags stay as they are.
Load the `dotkernel-writing-style` skill before you write any of this prose.
```

## Optional: markdown linting

`.claude/hooks/markdown-lint.sh` checks each `.md` file that Claude writes against `.claude/markdownlint.jsonc`.
It needs `markdownlint-cli2`, which Dotboost does not include:

```bash
npm install -g markdownlint-cli2
```

A project-local `devDependency` also works.
The hook uses `./node_modules/.bin/markdownlint-cli2` first, and uses the global one when the local one is not available.
Until the hook can find the binary, it exits without output.
Thus, `.claude/` stays drop-in for projects that have no Node toolchain.

## Verify

Start Claude Code in the project, and run `/help`.
You should see `dk-bootstrap`, `dk-module`, `dk-route`, `dk-trace`, `dk-test`, `dk-document`, `dk-check`, `dk-deprecate`, `dk-review`, `dk-hygiene`.
The session-start hook should start with a short briefing.
The briefing shows the detected project variant, the root namespace and the authorization style.
It flags a guard policy that leaves unlisted routes public.
It also shows which config files are still missing.

[Verifying an Install](verifying-an-install.md) gives the full end-to-end verification steps.
It also tells how to test the guardrails themselves.
