---
id: rheo.ohrg.org-document-the-marrow-table-and-positions-75e1e40b
short-id: '7'
title: Document the marrow table and positions
priority: 4
labels:
- doc-marrow-table
deps: []
closed: false
---
Touches: pages/marrow.typ

The Marrow page documents a `rheo.toml` key that is being retired, and knows
nothing about marrow's two positions.

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

`pages/marrow.typ:1-2` is the standard two-line page header. Leave it alone.

## The page as it stands

`pages/marrow.typ` is 58 lines:

- `= Marrow` at `:4`, intro prose `:6-8`
- `== Crafting marrow` at `:10`, body `:12-21` — create `.marrow.typ` at the
  top of the content directory; `document()` and `asset()` are in scope there
- `:23-27` — the filename override: prose at `:23` says "If you'd rather call
  the file something else, set the top-level `marrow` key in `rheo.toml`,
  resolved against `content_dir`", then a ```toml block at `:25-27` reading
  `marrow = "bundle-root.typ"`
- `:30` — marrow never produces a `.marrow.html`, never appears in the spine,
  the sidebar or a prev/next pager
- `:35-37` — a page marrow mints gets the same head-asset injection as an
  ordinary vertebra
- `== Reading across the spine` at `:38`, body `:38-58`

The page describes exactly ONE marrow file per project. There is no
prologue/epilogue pair, no outranking rule, and no position key anywhere on
it — confirmed by search: `prelude`, `prologue`, `epilogue` and
`dot_marrow_is_epilogue` have zero hits anywhere in this repo.

## What rheo now does

Marrow has TWO POSITIONS relative to the vertebrae, and two explicit
filenames that name them:

- `.marrow.prologue.typ` is spliced BEFORE every `#document(...)` block at the
  bundle root, so a `#show`/`#set` rule in it reaches vertebrae that already
  exist.
- `.marrow.epilogue.typ` is spliced AFTER them.

A bare `.marrow.typ` is a fallback for whichever position the other two leave
open. **Either explicit name outranks it, and when one is present the bare
file is not read at all** — that last clause is the part that surprises
people and must be stated, not implied.

Where a bare `.marrow.typ` lands is set by a new `[marrow]` table, which also
absorbs the filename override that `:23-27` currently documents as a
top-level key:

    [marrow]
    file = "bundle-root.typ"   # was the top-level `marrow` key
    position = "epilogue"      # or "prologue" (default: "epilogue")

`position` governs ONLY where a bare `.marrow.typ` lands. It never moves an
explicitly-named one. And a project's `position` never moves a package's bare
marrow — a package's is always an epilogue, since one project's key has no
business relocating a dependency's splice. A package shipping its own marrow
is a real case on this site (`@rheo/feeds` mints Atom feeds that way), so that
rule earns its sentence.

Two keys are retired by this: the top-level `marrow = "..."` becomes
`[marrow] file`, and a boolean named `dot_marrow_is_epilogue` becomes
`[marrow] position`. The boolean was never documented on this site, so you
only have to rewrite the `file` half — but a reader upgrading may have it in
their `rheo.toml`, which is why the migration is documented on the Migrate
page by a separate bird.

## Steps

1. Rewrite `:23-27` — the filename-override paragraph and its ```toml block —
   to use the `[marrow]` table. The prose still says what it said (call the
   file something else; the path resolves against `content_dir`), but the key
   becomes `file` inside a `[marrow]` table:

       [marrow]
       file = "bundle-root.typ"

   Do NOT leave the old top-level form alongside it as an alternative. The
   top-level key is retired, not deprecated-but-working, and showing both
   would invite a reader to pick the one that warns.

2. Add a section documenting the two positions and the outranking rule. Give it
   its own `==` heading — `== Marrow positions` or similar — and place it after
   `== Crafting marrow`'s body and the `[marrow]` block from step 1, but BEFORE
   the `== Reading across the spine` section at `:38`. A reader needs to know
   the file exists and how to name it before they care where it splices.

   Cover, in this order: the two explicit filenames and what "before" and
   "after every `#document(...)` block" actually buys (a `#show`/`#set` in a
   prologue reaches pre-existing vertebrae; an epilogue's does not); that a
   bare `.marrow.typ` fills whichever position is left open; that either
   explicit name outranks the bare file and the bare file is then not read at
   all; `[marrow] position` and its `"epilogue"` default; and that a project's
   `position` never moves a package's bare marrow.

3. Keep the existing statements at `:30` and `:35-37` true for the new
   filenames. `:30` says marrow never produces a `.marrow.html` of its own and
   never appears in the spine, the sidebar navigation or a prev/next pager —
   check that its wording does not tie itself to the single literal
   `.marrow.typ` in a way that now reads as excluding the prologue and
   epilogue files. If it does, generalise it; if it already reads generically,
   leave it untouched and say so in your report.

4. Match the surrounding voice: declarative present tense, second person for
   instructions, one idea per sentence, `---` for em dashes, no "simply" or
   "just". Read `:12-21` and `:30-37` before writing.

## NON-GOALS

- Do NOT edit anything in `/home/lox/code/_fcl/rheo` or
  `/home/lox/code/_fcl/rheo-tests`. The engine rename is a separate bird in a
  separate repo, and the test-suite rename another.
- Do NOT add the migration note for the retired keys to this page. The Migrate
  page (`pages/migrate.typ`) carries every migration in one table and a
  separate bird adds this row there.
- Do NOT document `dot_marrow_is_epilogue` in order to say it is retired. It
  was never documented here, so introducing it just to retire it teaches a
  reader a key they never knew.
- Do NOT add any `[marrow]` key beyond `file` and `position`.
- Do NOT document the reserved `.rheo/` output prefix here. It already lives on
  the Head control page (`pages/head-control.typ:27-35`) and duplicating it
  would split the reference.
- Do NOT touch `== Reading across the spine` (`:38-58`). Nothing in it changes.
- Do NOT add a new page or edit `pages/index.typ`. Everything here fits the
  existing Marrow page, so the `site-nav` array needs no entry.
- Do NOT run `build.sh`.

## VERIFY, all four

1. `rheo compile .` from the repo root completes with no error and no new
   warning.
2. `rg -n 'marrow' pages/marrow.typ` shows a `[marrow]` table with `file` and
   `position`, and `rg -n '^marrow = ' pages/marrow.typ` returns no hits — the
   retired top-level form is gone.
3. `rg -n 'prologue|epilogue|outrank' pages/marrow.typ` shows both filenames
   and the outranking rule.
4. Open `build/html/marrow.html` and confirm the new positions section renders
   between the crafting section and "Reading across the spine", with its
   ```toml block formatted like the page's existing ones.