---
id: rheo.ohrg.org-add-the-0-6-3-marrow-migration-row-99f1c322
short-id: '9'
title: Add the 0.6.3 marrow migration row
priority: 3
labels:
- doc-migrate-marrow
deps:
- blocked-by:rheo.ohrg.org-document-the-marrow-table-and-positions-75e1e40b
closed: false
---
Touches: pages/migrate.typ

Two `rheo.toml` keys are retired in the next release and the Migrate page's
table has no row for them.

## What you are working in

`/home/lox/code/_fcl/rheo.ohrg.org` is the user-facing documentation site for
`rheo`, a Typst-to-PDF/HTML/EPUB compiler. The site is itself authored in
Typst and built with rheo. Pages live in `pages/`.

Build from the repo root with a locally-built rheo from the sibling checkout
`/home/lox/code/_fcl/rheo`:

    rheo compile .

Output lands in `build/html/`. **Do NOT run `build.sh`** — CI only, pinned
release binary, does not reflect local engine changes. No Justfile, no test or
lint step; the whole "when done" criterion is that `rheo compile .` builds
clean.

`pages/migrate.typ:1-2` is the standard two-line page header. Leave it alone.

## The page as it stands

`pages/migrate.typ` is 84 lines. Its core is a
`#table(columns: (auto, 1fr), ...)` opening at `:25` with
`table.header[*From version*][*What migrate rewrites*]` at `:28` and closing
at `:68`. Each migration is one row: a version cell, then a cell of bullets.
The rows, in order:

- `< 0.4.0` at `:29-38` — link-syntax rewrite
- `< 0.5.0` at `:40-51` — the output-format rewrite (`rheo-target` to
  `rheo-context.target`) and the spine-config rewrite, with the retired
  `vertebrae` inclusion filter named explicitly at `:50`
- `< 0.5.1` at `:53-60` — the `rheo-context` binding shim
- `< 0.6.0` at `:62-65` — feed removal, reported rather than rewritten
- "any outdated version" at `:67` — the version bump

Below the table, `== Removals in 0.6.0` at `:70` with detail at `:72-84`
covering the retired feed keys and bindings.

The `< 0.5.0` row at `:40-51` is the best representative unit to copy: it is a
multi-bullet row covering two unrelated rewrites under one version.

## What rheo now retires

Two `rheo.toml` keys are replaced by a `[marrow]` table in the 0.6.3 release,
and `rheo migrate` rewrites both:

- the top-level `marrow = "somefile.typ"` (a marrow filename override) becomes
  `[marrow] file = "somefile.typ"`;
- the boolean `dot_marrow_is_epilogue` becomes `[marrow] position`, taking the
  string `"epilogue"` (the default) or `"prologue"`.

The mapping on the boolean is the part a reader will get backwards, so state
it explicitly: `dot_marrow_is_epilogue = false` means the bare `.marrow.typ`
is a PROLOGUE, so it migrates to `position = "prologue"`; `true` (or the key
absent) migrates to `position = "epilogue"`.

There is also an older, already-released spelling of the same boolean,
`marrow_prologue`, which migrates the same way — `marrow_prologue = true`
becomes `position = "prologue"`. Mention it only if the engine's migrate
actually handles it; check by reading
`/home/lox/code/_fcl/rheo/crates/cli/src/migrate.rs` for the literal string
`marrow_prologue`, and if it is absent, leave it out of the docs rather than
promising a rewrite that does not happen. Say in your report which you found.

Both keys warn rather than fail when left in place: a retired key produces a
build warning naming its replacement, so an unmigrated project still builds.
That is worth one sentence, because it tells a reader the upgrade is not
urgent.

## Steps

1. Add a `< 0.6.3` row to the table, after the `< 0.6.0` row (ending `:65`)
   and before the "any outdated version" row at `:67`. The table reads
   oldest-first, so the new row goes last among the versioned rows.

   Follow the shape of the `< 0.5.0` row at `:40-51`: a version cell, then a
   cell containing a short bolded lead-in per rewrite followed by bullets.
   Cover the two key rewrites and the boolean's direction as described above.

2. In the same row, state that both retired keys warn rather than fail, so a
   project that has not run `rheo migrate` still builds. One sentence.

3. Check whether `== Removals in 0.6.0` (`:70-84`) needs a sibling. That
   section exists because 0.6.0 removed things that `migrate` could only
   report, not rewrite. The marrow keys are fully rewritable, so they do NOT
   need such a section — do not add one. If while reading `:72-84` you find it
   claims 0.6.0 is the most recent set of removals in a way that the new row
   makes false, fix that sentence and nothing else; otherwise leave the whole
   section untouched and say so in your report.

4. Match the surrounding voice: the table cells are terse, declarative, and
   use `---` for em dashes. Read `:40-51` and `:62-65` before writing, and keep
   the new row's density comparable rather than writing the longest row on the
   page.

## NON-GOALS

- Do NOT edit anything in `/home/lox/code/_fcl/rheo` or
  `/home/lox/code/_fcl/rheo-tests`. Reading `crates/cli/src/migrate.rs` to
  answer the `marrow_prologue` question is fine; editing it is not.
- Do NOT document what the `[marrow]` table DOES. That is the Marrow page's
  job (`pages/marrow.typ`) and a separate bird covers it; this row says only
  what `migrate` rewrites. Cross-reference the Marrow page with the site's own
  `#link(<marrow>)` idiom if it reads naturally — the page already links out
  that way — but do not restate the semantics.
- Do NOT add rows for `[spine] auto_index` or `[spine] prelude`. Both are new
  keys with no predecessor, so there is nothing to migrate.
- Do NOT touch the `< 0.4.0`, `< 0.5.0`, `< 0.5.1` or `< 0.6.0` rows, or the
  `vertebrae` mention at `:50`. None of them changes.
- Do NOT restructure the table or change its columns.
- Do NOT add a new page or edit `pages/index.typ`.
- Do NOT run `build.sh`.

## VERIFY, all four

1. `rheo compile .` from the repo root completes with no error and no new
   warning.
2. `rg -n '0\.6\.3' pages/migrate.typ` shows the new row's version cell.
3. `rg -n 'marrow' pages/migrate.typ` shows the `[marrow]`, `file` and
   `position` names, and the direction of the boolean mapping
   (`false` to `"prologue"`).
4. Open `build/html/migrate.html` and confirm the table renders with the new
   row between the `< 0.6.0` row and the "any outdated version" row, matching
   the other rows' formatting.