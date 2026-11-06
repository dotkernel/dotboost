---
name: dotkernel-writing-style
description: >
  Use when writing any prose in a Dotkernel project — a chat answer, a commit message, a tag
  message, an MR or PR description, a Markdown file (README, feature doc, release notes,
  CHANGELOG), a code comment, a docblock description, an exception or error message, CLI command
  output, or an OpenAPI summary or description. Applies ASD-STE100 Simplified Technical English:
  short sentences, active voice, simple tenses, one instruction per sentence, one meaning per word.
  Also use when reviewing text for clarity, or when asked to rewrite, simplify or disambiguate text,
  or to write it in STE, "simple English" or "plain English".
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
It also helps a second agent or a translation tool, which cannot ask the author what a sentence means.

## Scope

| Text | STE |
| --- | --- |
| Chat answers | Yes |
| Commit messages, tag messages, MR and PR descriptions | Yes |
| Prose in Markdown files: headings, paragraphs, list items, table cells, blockquotes | Yes |
| Prose in code: comments and docblock descriptions, in source files and in code blocks | Yes |
| Text in code that a person or a client reads: exception messages, error messages, CLI output, OpenAPI summaries and descriptions | Yes |
| The code itself: identifiers, keywords, syntax, docblock tags such as `@param` | No |
| Inline code in Markdown, file names, command names, configuration keys | No |

Do not change an identifier, a route name or a configuration key to make it "more STE".
Write the prose around it in STE.

Do not change a message string that a client or a test compares character by character without a reason.
A changed error message can be a breaking change.
Load `dotkernel-evolution-pattern` before you change one on an existing route.

## Two levels

Select the level from the type of text.

| Level | Use it for | Apply |
| --- | --- | --- |
| Strict | Exception and error messages, CLI output, OpenAPI descriptions, procedures and steps, instructions for Claude in `CLAUDE.md`, skills and commands | All the rules in this skill, with the word rules as close as possible |
| Standard | Chat answers, README files, feature docs, release notes, commit and PR text, code comments | All the structural rules, with the word rules as a direction only |

Text at the Standard level can use more different words.
It must still obey all the structural rules.

## Structural rules

These rules control the form of a sentence.
You can apply them without the ASD-STE100 dictionary, so apply them fully.

### Sentences

- Write procedural sentences of 20 words or fewer.
- Write descriptive sentences of 25 words or fewer.
- Write instructions in the imperative form, with one instruction in each sentence.
- When two actions occur at the same time, you can put them in one sentence.
- Do not use semicolons.
  Write two sentences.
- Do not remove the subject, the verb or the article to make a sentence shorter.
  Write "Files that you do not back up are lost", not "Files not backed up lost".
- Do not use a noun cluster of more than three words.
  Write "the timeout of the queue worker", not "queue worker connection timeout value".

### Verbs

- Use the active voice.
  Write "The hook blocks the command", not "The command is blocked by the hook".
- You can use the passive voice in a description only when the actor is unknown or not important.
- Use these verb forms: the infinitive, the imperative, the simple present, the simple past and the simple future.
  You can also use the past participle as an adjective, for example "the deleted user".
- Do not use the present perfect or the past perfect.
  Write "We received the report", not "We have received the report".
- Do not use the `-ing` form of a verb as a noun or an adjective, except in a technical name.
- Use a verb for an action, not a noun made from the verb.
  Write "Validate the input", not "Perform a validation of the input".
- Do not use phrasal verbs.
  Write "remove", not "take off", and write "start", not "spin up".

A present perfect can give information that the simple past cannot give.
"The migration has run" means that the result is in the database now.
When you need that information, keep the present perfect.

### Paragraphs and lists

- Give each paragraph one topic.
- Write a maximum of six sentences in a paragraph.
- Use a numbered list for steps that the reader must do in sequence.
- Use a bulleted list for three or more items or conditions that have no sequence.
- Put a warning or a condition at the start of the sentence.
  Write "Before you run the migration, make a backup", not "Make a backup, which you must do before the migration".

## Word rules

These rules come from the ASD-STE100 dictionary.
We do not have the dictionary in this project, so use these rules as a direction.
Do not say that a text complies with the dictionary.

- Use one word for one meaning in a document.
  When you use `run` for a command, do not also use `execute` or `launch` for it.
- Use one name for one thing.
  Do not write "user", "customer" and "account" for the same entity.
- Use simple, common words.
  Write "use", not "utilize", and write "start", not "initiate".
- Use a word as one part of speech only.
  Write "Apply oil to the valve", not "Oil the valve".
- Use the articles "the", "a" and "an".
- Use technical names and technical verbs from the project as they are, for example `handler`, `route`, `migrate` or `phpstan`.
  When a technical word is not common English, explain it the first time that you use it.

## Scan checklist

Before you write or rewrite a text, find these six problems:

1. **Synonym rotation**: one thing has more than one name.
    Select one name and use it each time.
2. **Hedge stacking**: many qualifiers in one sentence, for example "it may possibly help to improve".
    Write the claim, or delete it.
3. **Nominalization**: an action as a noun, for example "perform an analysis of".
    Use the verb.
4. **Marketing adjectives**: words such as "seamless", "robust", "powerful" or "blazing-fast".
    Delete them, or give the measurement.
5. **Run-on sentences**: many ideas joined with semicolons, dashes or "and".
    Write one idea in each sentence.
6. **Phrasal verbs**: for example "spin up", "reach out", "dive into" or "kick off".
    Use one plain verb.

## Keep the meaning

STE changes the form of a text.
It must not change what the text says.

- Keep each fact, condition, number and limit.
- Keep the strength of each hedge.
  "The request may have failed" must not become "The request failed".
- Do not add a fact, a cause or a frequency that the source did not give.
- When a shorter sentence loses a necessary condition, keep the longer sentence.
- Stop when the sentence has one clear meaning.
  The shortest sentence is not always the clearest.
- When a text already obeys the rules, do not change it.
- STE does not make weak content better.
  When a text has nothing to say, tell the user, and do not polish it.

## Rewrite a text on request

When the user asks you to rewrite a text in STE, give the rewritten text only.
When you kept a longer phrase on purpose, add one line that starts with `Kept as-is:` and tells why.

When the user asks for the changes, give a table:

```markdown
| Rule | Before | After |
| --- | --- | --- |
| Present perfect | "We have received your request." | "We received your request." |
| Nominalization | "Perform a validation of the input." | "Validate the input." |
```

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

Exception message:

```php
// Wrong: 'The requested resource could not be located; it may have been removed.'
// Right: 'The resource does not exist. It may have been deleted.'
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
- A changed message on an existing route follows `dotkernel-evolution-pattern`.

## Limits of this skill

This skill does not include the ASD-STE100 dictionary of approved words.
ASD owns the copyright of the specification and its dictionary, so do not copy them into the project.

Get the specification from https://www.asd-ste100.org/.
When the approval of a word is important, check it in the official dictionary.
Do not say that a word is "approved" from memory.

## Sources

- ASD-STE100 official site: https://www.asd-ste100.org/
- The two levels, the scan checklist and the rules to keep the meaning come from the MIT-licensed `danyuchn/asd-ste100-skill`: https://github.com/danyuchn/asd-ste100-skill
