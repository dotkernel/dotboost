# Windows and Line Endings

Dotkernel repos ship `.gitattributes` with `* text eol=lf`, which governs anything git checks out.
Belt and braces, configure the client so nothing converts on the way in or out:

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

Already committed CRLF? Renormalize once with `git add --renormalize .`.

## PhpStorm

*Editor → Code Style → Line separator = Unix (\n)*, and *File Encodings → UTF-8*, *Create UTF-8 files: with NO BOM*.

## How Dotboost enforces this while working

`normalize-file.sh` fixes BOM, CRLF, trailing whitespace, and final newline on every file Claude writes — see [Hooks Reference](hooks/reference.md).
`session-start.sh` also warns at the start of a session if it detects CRLF in the working tree.
`/dk-hygiene` runs the same checks across a whole set of changed files on demand.
