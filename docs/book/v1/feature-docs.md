# Feature Documentation

`/dk-document` writes one markdown file for each feature into the target project.
The file tells what the feature does and why, the routes and roles that reach it, the data it adds, and how to try it.
A cleared session cannot find this part of a change again from `src/` alone.
For this reason, it is a file in the repo and not a note in a chat transcript.

## Where it lands

The skill finds the location in the repo and does not guess it.
Many Dotkernel repositories already have a `documentation/` directory, with command docs, a generated `openapi.json` and Postman collections.
The standard API has this directory, but derived projects are different.
Thus the skill checks the repo and does not infer:

- `documentation/features/` when the repo already has a `documentation/` directory
- `docs/features/` otherwise

It never creates a second documentation root next to an existing one.
Both paths are in the `allow` permission tier.
Prose in a docs directory is approximately the write with the lowest risk in the tree.

## The review uses the frontmatter

The frontmatter of each feature doc has `routes:` and `handlers:`.
`/dk-review` greps these keys to find whether a doc describes each new route in the current diff.
It reports a doc that is missing or out of date as *Should fix*.
`/dk-review` never writes a doc itself.
It is read-only by design, and it tells you to run `/dk-document`.

## Make Claude read the docs before a change

Claude writes a doc only when you ask for it.
You can make Claude look for an existing doc before it adds or changes behaviour in that area.
To do this, add this block to the `CLAUDE.md` of the project:

```markdown
## Feature docs

Before you add or change behaviour, examine `docs/features/` (or `documentation/features/`) for a doc about that area.
If a doc exists, read it.
After the change, update that doc, or write a new doc with `/dk-document`.
A doc that does not agree with the code is a bug in the doc.
```

The session-start hook always prints the directory and the number of docs.
Thus Claude can find the files without this block.
But the block makes Claude actually *read* them.
