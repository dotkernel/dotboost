# Writing Style

Dotboost writes all its prose in ASD-STE100 Simplified Technical English (STE).
STE is a controlled language from ASD, the Aerospace, Security and Defence Industries Association of Europe.
It makes technical text clear for all readers, also for readers whose first language is not English.
It also helps a second agent or a translation tool, which cannot ask the author what a sentence means.

This page tells what changed in Dotboost to apply STE, and how the rule works in your project.

## Summary of the update

The update came in four pull requests:

| PR | Change |
| --- | --- |
| [#25](https://github.com/dotkernel/dotboost/pull/25) | Adds the `dotkernel-writing-style` skill and a "Writing style" block for the `CLAUDE.md` of the project |
| [#26](https://github.com/dotkernel/dotboost/pull/26) | Adds an STE check to `dotkernel-reviewer` and to `/dk-review` |
| [#28](https://github.com/dotkernel/dotboost/pull/28) | Rewrites the skills, the commands, the agent, the README and the docs in STE |
| [#29](https://github.com/dotkernel/dotboost/pull/29) | Rewrites the last three skill lines and updates the README |

## The `dotkernel-writing-style` skill

The skill applies to all Dotkernel projects and to all Dotkernel packages.

### What the skill applies to

STE applies to:

- chat answers
- commit messages, tag messages, and MR and PR descriptions
- prose in Markdown files: headings, paragraphs, list items, table cells and blockquotes
- code comments and docblock descriptions
- exception messages, error messages, CLI output, and OpenAPI summaries and descriptions

STE does not apply to the code itself: identifiers, keywords, syntax and docblock tags such as `@param`.
It also does not apply to inline code, file names, command names and configuration keys.
Do not change an identifier or a configuration key to make it "more STE".

### Two levels

The skill selects a level from the type of text.

| Level | Use it for | Apply |
| --- | --- | --- |
| Strict | Exception and error messages, CLI output, OpenAPI descriptions, procedures, and instructions for Claude in `CLAUDE.md`, skills and commands | All the rules, with the word rules as close as possible |
| Standard | Chat answers, README files, feature docs, release notes, commit and PR text, and code comments | All the structural rules, with the word rules as a direction only |

### Structural rules

The structural rules control the form of a sentence.
They do not need the ASD-STE100 dictionary, so the skill applies them fully:

- A procedural sentence has 20 words or fewer.
  A descriptive sentence has 25 words or fewer.
- An instruction uses the imperative form, with one instruction in each sentence.
- A sentence has no semicolon.
- A sentence keeps its subject, its verb and its articles.
- A noun cluster has three words or fewer.
- A sentence uses the active voice and the simple tenses.
- A sentence uses a verb for an action, not a noun made from the verb.
- A sentence does not use phrasal verbs, for example "spin up" or "take off".
- A paragraph has one topic and six sentences or fewer.

### Word rules

The word rules come from the ASD-STE100 dictionary.
Dotboost does not include the dictionary, because ASD owns its copyright.
Thus the word rules are a direction only, for example "use one word for one meaning" and "write `use`, not `utilize`".
The skill never says that a word is "approved".
To check a word, use the official specification at https://www.asd-ste100.org/.

### Keep the meaning

STE changes the form of a text.
It must not change what the text says.
The skill keeps each fact, condition, number, limit and hedge, and it adds no new fact.

A client or a test can compare a message character by character.
Thus a changed error message can be a breaking change.
Before you change a message on an existing route, load `dotkernel-evolution-pattern`.

## Make the rule always active

A skill loads only when its description matches the task.
To make the writing style always active, paste this block into the `CLAUDE.md` of your project:

```markdown
## Writing style

Write all prose in ASD-STE100 Simplified Technical English.
This includes chat answers, commit and tag messages, MR/PR descriptions, Markdown files, code comments, docblock descriptions, exception messages, CLI output and OpenAPI descriptions.
Do not apply it to the code itself: identifiers, keywords, syntax and docblock tags stay as they are.
Load the `dotkernel-writing-style` skill before you write any of this prose.
```

[Getting Started](getting-started.md) has the same block, together with the other `CLAUDE.md` blocks.

## The review check

`dotkernel-reviewer` and `/dk-review` load `dotkernel-writing-style` and check prose against it:

- The check examines only the lines that the diff adds or changes.
  Old text gives no findings.
- It also examines the commit messages on the branch that are not on the default branch.
- It finds long sentences, the passive voice, semicolons, phrasal verbs, and sentences with more than one instruction.
- It uses the Strict or the Standard level for each type of text.
- It reports a finding as **Should fix**, not **Blocking**, and gives a rewritten sentence.
- It does not report the code itself.

`dotkernel-reviewer` also writes its own review in STE.

## The rewrite of Dotboost

PR #28 and PR #29 rewrote the existing prose of Dotboost in STE:

- 18 skills, at the Strict level
- 10 `/dk-*` commands and the `dotkernel-reviewer` agent, at the Strict level
- `README.md` and 21 pages in `docs/book/`, at the Standard level

All prose now has one sentence on each line.

### What did not change

- each rule, condition, number, command, path and cross-reference
- the trigger words and the quoted phrases in the skill descriptions
- the `allowed-tools` lines of the commands
- code blocks, identifiers, URLs and link targets
- the headings that other pages link to

A script compared the skill descriptions before and after the rewrite.
It found no lost trigger word.

### Example

This text is from [Guardrails vs. Permissions](hooks/guardrails-vs-permissions.md).

Before:

```text
This is deliberate — the hook can see into compound Bash commands that a path/prefix
permission rule cannot — but it means the approval prompt you'd expect from the `ask`
tier never appears.
```

After:

```text
This is on purpose.
The hook can see into compound Bash commands, and a path or prefix permission rule cannot.
But because of this, you do not get the approval prompt that the `ask` tier gives.
```

### Wording changes to know

Some phrases changed more than their form.
The meaning is the same, but search for the new text:

| File | Before | After |
| --- | --- | --- |
| `dotkernel-evolution-pattern` | "do not shorten it silently" | "Do not make it earlier without an announcement" |
| `status-line.md` | "growth is credited to whatever state holds" | "It assigns each increase to the state that is true when the status line redraws" |
| `feature-docs.md`, `glossary.md` | "how to exercise it" | "how to try it" |
| `skills/reference.md` | table header "Fires on" | table header "Loads on" |
| `dotkernel-troubleshooting` | "Config cache." | "The config cache is stale. Run `composer clear-config-cache`." |

## Write new text in STE

When you add a skill, a command or a docs page to Dotboost, write it in STE.
Use the Strict level for a skill or a command.
Use the Standard level for a docs page.
Before you open a pull request, run `/dk-review` to check the prose.

## Sources

- ASD-STE100 official site: https://www.asd-ste100.org/
- The two levels, the scan checklist and the rules that keep the meaning come from the MIT-licensed [danyuchn/asd-ste100-skill](https://github.com/danyuchn/asd-ste100-skill).
  The skill gives these ideas in its own words.
