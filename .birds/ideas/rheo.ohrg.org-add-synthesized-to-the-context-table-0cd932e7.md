---
id: rheo.ohrg.org-add-synthesized-to-the-context-table-0cd932e7
short-id: '0'
title: Add synthesized to the context table
priority: 3
labels:
- doc-context-synthesized
deps: []
closed: false
---
Touches: pages/rheo-context.typ

The `rheo-context` field table says `spine` nodes have four fields and
`spine-flat` entries three. Both are about to gain one, and the new one is
there to stop packages crashing.

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

`pages/rheo-context.typ:1-2` is the standard two-line page header
(`#import "index.typ": ...` then `#show: sidebar-site.with(current: ...)`).
Leave it alone.

## The table as it stands

`pages/rheo-context.typ` is 148 lines. Its field reference is a
`#table(columns: (auto, 1fr), align: (left, left), ...)` opening at `:32` and
closing at `:88`, with `table.header[*Field*][*Description*]` at `:35`. Each
entry is two cells: the field name in backticks, then a prose description,
each cell a bracketed block ending `],`.

The two entries this bird changes:

- `` [`spine`] `` at `:39-47`. Its prose at `:41` says "Each node is a
  dictionary with four fields", followed by a bullet per field at `:42-45`
  (`title`, `handle`, `path`, `children`) and a closing sentence at `:46`.
- `` [`spine-flat`] `` at `:49-51`. Its prose at `:50` says "Each entry is a
  dictionary with three fields: `handle`, `path`, and a `title` that is always
  path-derived."

Other entries in the same table, for reference on house style: `handle`
`:36-37`, `metadata-of` `:53-57`, `target` `:59-64`, `ext` `:66-71`,
`rheo-version` `:73-80`, `reset-footnotes` `:82-87`. The `target` entry at
`:59-64` is a good representative two-cell unit to copy the shape of.

Neither `synthesized` nor `rheo-index` appears anywhere in this repo today.

## What rheo now adds, and why it exists

`[spine] auto_index` (default `true`) mints a landing page for a content
directory that has children and no landing file of its own. The minted
vertebra goes into the spine like any other page, carrying the NOTIONAL path
`<dir>/index.typ` — and there is no such file on disk.

Nothing in the serialized spine currently says which entries are minted, and
that is a real breakage rather than an aesthetic gap. A package that does
anything with a spine path other than link to it — reading it with Typst's
`read()`, for instance — hits a file-not-found it can neither predict nor
recover from, because Typst has no `read`-with-default and no error recovery.
An observed case: a project built a sub-bibliography by reading every
`spine-flat` path, one of its directories had no `index.typ`, and because the
binding was top-level the failure landed at import time and took down every
page of the site rather than just that one index.

So rheo adds a boolean `synthesized` to BOTH shapes:

- every `spine-flat` entry, making it four fields;
- every `spine` tree node, making it five fields — `true` for a minted
  landing node, and `false` for a group node (which has `handle: none` and
  `path: none` anyway), so a package walking the tree gets the same guarantee
  as one walking the flat list.

`synthesized: true` means `path` is notional: rheo minted the page and there
is no such file on disk, so a consumer must never `read()` it. That sentence
is the whole point of documenting the field, and it should appear in the prose
in roughly those terms.

## Steps

1. In the `` [`spine`] `` entry (`:39-47`), change "four fields" at `:41` to
   "five fields" and add a fifth bullet after the `children` bullet at `:45`,
   in the same shape as the four already there (`` - `name` --- prose. ``).
   Document `synthesized` as: whether rheo minted this page itself rather than
   reading it from disk; when `true` the node's `path` is notional and must not
   be `read()`; `false` for an ordinary vertebra and for a group node.

   Put the bullet LAST, after `children`, rather than alphabetically — the
   existing four are in the order rheo serializes them and a reader comparing
   the docs to a `repr()` dump should see the same order.

2. In the `` [`spine-flat`] `` entry (`:49-51`), change "three fields" to "four
   fields" and add `synthesized` to the inline list at `:50`. That entry
   describes its fields inline rather than as bullets, so keep it inline —
   do not convert it to a bullet list. Restate the never-`read()`-it rule
   here too, briefly; a package author reading only this entry must not have
   to find the `spine` entry above to learn it.

3. Cross-reference where the field comes from. Both entries should point a
   reader at the `[spine] auto_index` key, which is documented on the Spines
   page, using the site's own `#link(<...>)` idiom — `pages/rheo-context.typ`
   already links that way, e.g. the `#link(<vertebra-metadata>)` and
   `#link(<relative-linking>)` forms in this same table. The Spines page's
   anchor is `<spines>`, used elsewhere in the site. One link from the `spine`
   entry is enough; do not add it to both cells if it reads as repetition.

4. Match the surrounding voice: declarative present tense, one idea per
   sentence, em-dash asides, `---` for em dashes as the file already does, no
   "simply" or "just". Read `:39-51` and `:59-64` before writing.

## NON-GOALS

- Do NOT edit anything in `/home/lox/code/_fcl/rheo` or
  `/home/lox/code/_fcl/rheo-tests`.
- Do NOT document `rheo-index()` here. It is not a `rheo-context()` field —
  it is a separately injected per-vertebra binding — and it is documented on
  the Spines page beside `[spine] auto_index` by a separate bird. Adding it to
  this table would put it in the wrong place and duplicate that bird.
- Do NOT document `[spine] auto_index` or `[spine] prelude` themselves here
  beyond the cross-reference in step 3. Separate bird, different page.
- Do NOT restructure the table, change its column widths, or convert the
  `spine-flat` entry's inline field list into bullets.
- Do NOT touch the `metadata-of`, `target`, `ext`, `rheo-version` or
  `reset-footnotes` entries. None of them changes.
- Do NOT add a new page or edit `pages/index.typ`.
- Do NOT run `build.sh`.

## VERIFY, all four

1. `rheo compile .` from the repo root completes with no error and no new
   warning.
2. `rg -n 'synthesized' pages/rheo-context.typ` shows hits in BOTH the `spine`
   and the `spine-flat` entries.
3. `rg -n 'four fields|five fields|three fields' pages/rheo-context.typ` shows
   "five fields" in the `spine` entry and "four fields" in the `spine-flat`
   entry, and no surviving "three fields".
4. Open `build/html/rheo-context.html` and confirm the table still renders as
   two columns with the new bullet and the new inline field in place, and that
   the cross-reference link resolves rather than rendering as a dead anchor.