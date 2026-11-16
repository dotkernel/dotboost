# Windows and Line Endings

Dotkernel repos have a `.gitattributes` file with `* text eol=lf`, which controls all files that git checks out.
For more safety, also configure the client, so that no conversion occurs in either direction:

```bash
git config core.autocrlf false
git config core.eol lf
git config core.safecrlf warn
```

## Verify

```bash
git config --get core.autocrlf              # false
git ls-files --eol | grep -v 'w/lf' | head  # nothing for text files
```

If CRLF is already committed, renormalize one time with `git add --renormalize .`.

## PhpStorm

Set *Editor → Code Style → Line separator = Unix (\n)*.
Set *File Encodings → UTF-8* and *Create UTF-8 files: with NO BOM*.

## How Dotboost enforces this while working

`normalize-file.sh` fixes BOM, CRLF, trailing whitespace, and the final newline in each file that Claude writes.
See [Hooks Reference](hooks/reference.md).
`session-start.sh` also gives a warning at the start of a session if it finds CRLF in the working tree.
`/dk-hygiene` runs the same checks on a full set of changed files when you ask for it.
