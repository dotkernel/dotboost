---
name: dotkernel-writing-style
description: >
  Use when writing any prose in a Dotkernel project — a chat answer, a commit message, a tag
  message, an MR or PR description, a Markdown file (README, feature doc, release notes,
  CHANGELOG), a code comment or a docblock description. Applies ASD-STE100 Simplified Technical
  English: short sentences, active voice, one instruction per sentence, one meaning per word. Also
  use when reviewing text for clarity, or when asked to rewrite text in STE, "simple English" or
  "plain English".
---

# Writing style: ASD-STE100

```text
Applies to
  Projects:  - all
  Packages:  - none
```

Dotkernel projects write all prose in ASD-STE100 Simplified Technical English (STE).
STE is a controlled language from ASD, the Aerospace, Security and Defence Industries Association of Europe.
It makes technical text clear for all readers, also for readers whose first language is not English.

## Scope

| Text | STE |
| --- | --- |
| Chat answers | Yes |
| Commit messages, tag messages, MR and PR descriptions | Yes |
| Prose in Markdown files: headings, paragraphs, list items, table cells, blockquotes | Yes |
| Prose in code: comments and docblock descriptions, in source files and in code blocks | Yes |
| The code itself: identifiers, keywords, syntax, docblock tags such as `@param` | No |
| Inline code in Markdown, file names, command names, configuration keys | No |

Do not change an identifier, a route name or a configuration key to make it "more STE".
Write the prose around it in STE.

## Words

- Use one word for one meaning.
  When you use `run` for a command, do not also use `execute` for it.
- Use simple, common words.
  Write "use", not "utilize".
  Write "start", not "initiate".
- Use technical names and technical verbs from the project as they are, for example `handler`, `route`, `migrate` or `phpstan`.
- Use the articles "the", "a" and "an".
  Do not remove them to make a sentence shorter.
- Do not use a noun cluster of more than three words.
  Write "the timeout of the queue worker", not "queue worker connection timeout value".
- Do not use the `-ing` form of a verb as a noun or an adjective, except in a technical name.

## Sentences

- Write procedural sentences of 20 words or fewer.
- Write descriptive sentences of 25 words or fewer.
- Use the active voice.
  Write "The hook blocks the command", not "The command is blocked by the hook".
- Use the simple tenses: present, past and future.
- Write instructions in the imperative form, with one instruction in each sentence.
- When two actions occur at the same time, you can put them in one sentence.

## Paragraphs and lists

- Give each paragraph one topic.
- Write a maximum of six sentences in a paragraph.
- Use a numbered list for steps that the reader must do in sequence.
- Use a bulleted list for items that have no sequence.

## Examples

Commit message:

```text
Wrong:  Fixed an issue where users that were not found were causing a 500 error to be returned
Right:  Return 404 when the user does not exist
```

Code comment:

```php
// Wrong: Basically we need to make sure the token hasn't expired before proceeding further.
// Right: Make sure that the token is not expired. Then continue.
```

Markdown paragraph:

```markdown
<!-- Wrong -->
It should be noted that the migration, once having been executed, cannot be easily reverted.

<!-- Right -->
You cannot easily revert the migration after you run it.
```

## How this works with other rules

- STE controls the words and the sentences.
  It does not change the format of the text.
- Markdown files must still pass the project's `markdownlint` config, and keep the project's line style.
- Commit messages keep the project's format, for example the subject line and the body.
- Feature docs keep the structure from `dotkernel-feature-docs`.
  Write their prose in STE.

## Limits of this skill

This skill is a short summary of the main STE writing rules, in our own words.
It is not the official specification, and it does not include the ASD-STE100 dictionary of approved words.
ASD owns the copyright of the specification and its dictionary, so do not copy them into the project.

Get the specification from https://www.asd-ste100.org/.
When the approval of a word is important, check it in the official dictionary.
Do not say that a word is "approved" from memory.
