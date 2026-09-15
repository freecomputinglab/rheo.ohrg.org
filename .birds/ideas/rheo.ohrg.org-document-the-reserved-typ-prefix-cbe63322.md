---
id: rheo.ohrg.org-document-the-reserved-typ-prefix-cbe63322
short-id: cb
title: Document the reserved typ prefix
priority: 2
labels:
- doc-reserved-typ-prefix
deps: []
closed: false
---
Touches: pages/rheotoml.typ, pages/head-control.typ

The site documents rheo's reserved OUTPUT prefix and says nothing about its
reserved INPUT prefix, which silently shadows a project's own files.

## What you are working in

`/home/lox/code/_fcl/rheo.ohrg.org` is the user-facing documentation site for
`rheo`, a Typst-to-PDF/HTML/EPUB compiler. The site is itself authored in
Typst and built with rheo. Pages live in `pages/` (`content_dir = "pages"`).

Build from the repo root with a locally-built rheo from the sibling checkout
`/home/lox/code/_fcl/rheo`:

    rheo compile .

Output lands in `build/html/`. **Do NOT run `build.sh`** — CI only, pinned
release binary, does not reflect local engine changes. No Justfile, no test or
lint step; the whole "when done" criterion is that `rheo compile .` builds
clean.

Every page opens with a two-line header (`#import "index.typ": ...` then
`#show: sidebar-site.with(current: "<id>")`). Leave those lines alone on both
pages you touch.

## What rheo now reserves

`typ/` at the PROJECT ROOT is a reserved input prefix. rheo's Typst world
serves two paths from memory before it ever falls back to disk:

- `typ/rheo.typ` — rheo's own injected template module, which is where
  `rheo-index()` and the other injected helpers live
- `typ/metadata.typ` — the metadata-beacon module behind
  `rheo-context()`'s `metadata-of`

A project that has its own file at either path cannot import it: rheo's copy
wins, silently, with no warning and no error. More paths under `typ/` may be
added in future releases, so the prefix as a whole is what is reserved, not
just those two names.

This is the mirror image of something the site already documents. The `.rheo/`
OUTPUT prefix is reserved and is covered on the Head control page
(`pages/head-control.typ:27-35`, `== Control assets`): an asset minted under
`.rheo/` is a message from the bundle to rheo, consumed during compilation and
never written to the build output. `:29` is the sentence "The `.rheo/` output
prefix is reserved."

The site has one other reserved-name mention, the `rheo-meta:` label prefix at
`pages/rheo-context.typ:111`. It is a label namespace rather than a path and is
not part of this bird.

## Where it goes, and why

Put it on `pages/rheotoml.typ`, which is 74 lines and is the page about what
rheo expects to find in a project. Its structure is a sequence of `==` prose
sections, each a heading, one to three sentences, then a fenced code block:
`== Per-page footnotes` at `:36` (body `:38-49`), `== Automatic package
detection` at `:51` (body `:53-61`), `== Fonts` at `:63` (body `:65-73`). The
`reset_footnotes` entry at `:40-49` is the representative unit to copy.

The alternative was the Head control page, beside the `.rheo/` prefix it
mirrors. That loses: `.rheo/` is documented there because it is the mechanism
that page is about (control assets minted from marrow), whereas `typ/` is a
project-layout fact with no connection to head control. A reader looking for
"what paths does rheo claim in my project" goes to the Rheo.toml page.

## Steps

1. Add a `== Reserved project paths` section to `pages/rheotoml.typ`. Place it
   after `== Fonts` (body ending `:73`), at the end of the page — it is
   reference material a reader consults rather than something they need early.

   Cover: that `typ/` at the project root is served by rheo from memory and not
   from disk; that a project file at such a path is shadowed and unreachable,
   silently, with no warning; the two paths in use today, `typ/rheo.typ` and
   `typ/metadata.typ`, and what each is; and that more may be added, so treat
   the whole prefix as rheo's rather than only those two names. The practical
   advice is one sentence: keep your own Typst modules anywhere else — the
   convention on this site's own source is a `_lib/` directory.

   Do NOT use `#code-with-version` for any code block here. That helper
   (`pages/index.typ:4-8`) substitutes `{version}` into a raw block and is for
   samples that must show the current release; a path listing has no version in
   it. Use a plain fenced block, or inline backticks if the paths read better
   in prose.

2. In the same section, name the `.rheo/` output prefix as the other half of
   the pair and link to where it is documented, using the site's own
   `#link(<...>)` idiom. The Head control page's anchor is `<head-control>`,
   which `pages/rheo-context.typ` and others already link to in that form.
   One sentence: `typ/` is reserved on the way IN, `.rheo/` on the way OUT.

3. Add the reciprocal cross-reference on the other page. `pages/head-control.typ:29`
   currently reads "The `.rheo/` output prefix is reserved." Extend that
   paragraph — do not restructure the section — with one sentence pointing at
   the new section for the input-side prefix, linking with
   `#link(<rheotoml>)`. Verify that anchor is the one the Rheo.toml page
   actually carries before using it; if the site uses a different anchor for
   that page, use whichever the `site-nav` entry's `id` implies
   (`pages/index.typ:15-59` holds the nav array, whose entries are
   `(id: ..., title: ..., url: ...)`), and say in your report which you used.

4. Match each page's voice: declarative present tense, second person for
   advice, one idea per sentence, `---` for em dashes, no "simply" or "just".
   Read `pages/rheotoml.typ:38-49` and `pages/head-control.typ:27-35` before
   writing.

## NON-GOALS

- Do NOT edit anything in `/home/lox/code/_fcl/rheo` or
  `/home/lox/code/_fcl/rheo-tests`.
- Do NOT propose or document a `rheo.toml` key to relocate either reserved
  path. None exists, and inventing one in the docs would be a promise the
  engine does not keep.
- Do NOT document `rheo-index()` or `metadata-of` themselves here beyond
  naming what each module is for. Both are documented elsewhere — the Spines
  page and the `rheo-context` field table respectively — by separate birds.
- Do NOT touch `pages/rheo-context.typ:111`'s `rheo-meta:` label-prefix
  mention. It is a label namespace, not a path, and is out of scope.
- Do NOT restructure the `== Control assets` section on
  `pages/head-control.typ`; add one sentence to the paragraph at `:29` and
  nothing else.
- Do NOT add a new page or add an entry to `site-nav` in `pages/index.typ`.
  Both edits land on existing pages. You may READ `pages/index.typ` to resolve
  the anchor question in step 3; do not edit it.
- Do NOT run `build.sh`.

## VERIFY, all five

1. `rheo compile .` from the repo root completes with no error and no new
   warning.
2. `rg -n 'typ/rheo\.typ|typ/metadata\.typ' pages/rheotoml.typ` shows both
   paths named.
3. `rg -n 'reserved' pages/rheotoml.typ pages/head-control.typ` shows the new
   section and the extended sentence on the Head control page.
4. Open `build/html/rheotoml.html` and confirm the new section renders last on
   the page, and that its link to the Head control page resolves rather than
   rendering as a dead anchor.
5. Open `build/html/head-control.html` and confirm the added sentence renders
   inside the existing Control assets paragraph, with its link resolving.