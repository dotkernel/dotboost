# Getting Started

## Install

Pick one — both land the same files.

### Clone it inside the project

```bash
cd <project>
git clone --depth 1 https://github.com/dotkernel/dotboost.git .dotboost
cp -r .dotboost/.claude .claude
rm -rf .dotboost
```

### Download the zip

No git needed:

```bash
cd <project>
curl -L -o dotboost.zip https://github.com/dotkernel/dotboost/archive/refs/heads/main.zip
unzip -q dotboost.zip
cp -r dotboost-main/.claude .claude
rm -rf dotboost-main dotboost.zip
```

## After copying, either way

```bash
chmod +x .claude/hooks/*.sh .claude/statusline.sh \
         .claude/skills/dependency-policy/scripts/*.sh
echo '.claude/settings.local.json' >> .git/info/exclude
```

Nothing in the payload is committed with an executable bit, and a zip extracted on Windows carries no permission bits at all — the `chmod` step is not optional.
The `settings.local.json` line keeps personal, git-ignored overrides out of `git add .`.

If the target project already has its own `.claude/settings.json` or `.claude/commands/`, merge by hand instead of running the copy blind — same-named files are overwritten.

## Add the `CLAUDE.md` block

`dependency-policy` and the feature-docs check need a short block pasted into the *project's own* `CLAUDE.md` to become proactive rather than merely loadable — see [Architecture Overview](architecture.md#the-claudemd-contract) and [Dependency Policy](skills/dependency-policy.md).

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
The session-start hook should open with a short briefing: detected application variant, root namespace, authorization style, branch, and which config files are still missing.

Full end-to-end verification steps, including how to test the guardrails themselves, are in [Verifying an Install](verifying-an-install.md).
