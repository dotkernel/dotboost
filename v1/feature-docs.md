# Feature Documentation

`/dk-document` writes one markdown file per feature into the target project — what it does, why, the routes and roles that reach it, the data it adds, and how to exercise it.
It's the part of a change a cleared session can't reconstruct from `src/` alone, which is why it's a file in the repo rather than a note in a chat transcript.

## Where it lands

Detected, not assumed.
Many Dotkernel repositories already carry a `documentation/` directory — command docs, a generated `openapi.json`, Postman collections — and which ones do isn't predictable from the application variant, so the skill checks rather than infers:

- `documentation/features/` when that directory already exists
- `docs/features/` otherwise

It never creates a second documentation root next to an existing one.
Both paths are in the `allow` permission tier — prose in a docs directory is about the lowest-risk write in the tree.

## The frontmatter is load-bearing

Each feature doc's frontmatter carries `routes:` and `handlers:`.
`/dk-review` greps these to decide whether a new route in the current diff is documented, and reports a missing or stale doc as *Should fix*.
`/dk-review` never writes one itself — it's read-only by design and tells you to run `/dk-document` instead.

## Making Claude read them before rebuilding something

The generation half only runs when asked.
To make Claude check for an existing doc before adding or changing behaviour in that area, add this to the project's `CLAUDE.md`:

```markdown
## Feature docs

Before adding or changing behaviour, check `docs/features/` (or `documentation/features/`) for a doc
covering that area and read it. After the change, update that doc or write a new one with
`/dk-document`. A doc that contradicts the code is a bug in the doc.
```

The session-start hook prints the directory and a doc count regardless, so the files are at least discoverable without this block — the block is what makes them actually get *read*.
