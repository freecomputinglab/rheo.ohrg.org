---
id: rheo.ohrg.org-document-auto-index-and-prelude-a73da349
short-id: a
title: Document auto_index and prelude
priority: 4
labels:
- doc-spine-auto-index-prelude
deps: []
closed: false
---
Touches: pages/spines.typ

One sentence on this page becomes false on the next rheo release, and the two
`[spine]` keys that make it false are undocumented.

## What you are working in

`/home/lox/code/_fcl/rheo.ohrg.org` is the user-facing documentation site for
`rheo`, a Typst-to-PDF/HTML/EPUB compiler. The site is itself authored in
Typst and built with rheo. Pages live in `pages/` (`content_dir = "pages"` in
`rheo.toml`).

Build it from the repo root with a locally-built rheo from the sibling
checkout `/home/lox/code/_fcl/rheo`, so the docs are validated against
current engine behaviour:

    rheo compile .

Output lands in `build/html/`. **Do NOT run `build.sh`** — it is the CI build
only, downloading a pinned release binary, and does not reflect local engine
changes. There is no Justfile and no test or lint step; the project's whole
"when done" criterion is that `rheo compile .` builds clean.

Every page opens with the same two-line header — `pages/spines.typ:1-2` is
`#import "index.typ": sidebar-site` then
`#show: sidebar-site.with(current: "spines")`. Leave those two lines alone.

## The page as it stands

`pages/spines.typ` is 77 lines. It documents spine configuration with a
heading-per-key idiom: a `==` heading naming the literal key, then prose, then
a fenced ```toml block. The existing sections are:

- `== Directory-scan default` at `:9`, with its bullet list at `:13-16`
- `` == `[spine] exclude` `` at `:20`, body `:22-29`
- `` == `[spine] include` `` at `:31`, body `:33-44`
- `` == `[[spine.section]]` `` at `:46`, body `:48-60`
- `== Per-format overrides` at `:62`, body `:64-77`, whose rule is that a
  per-format `[<format>.spine]` overrides the global `[spine]` one field at a
  time

Neither `auto_index` nor `prelude` appears anywhere on this page, or anywhere
else in the repo.

## What rheo now does

**`[spine] auto_index`, default `true`.** A content subdirectory that has
children and NO landing file (no `index.typ`, no file named after the
directory) used to become a non-clickable group node with a prettified title
and no page of its own. It now gets a synthesized landing page instead: an
empty vertebra whose entire body is a call to `rheo-index()`, an injected
Typst function that renders that directory's own children as a list of links.
The page is a real vertebra — a new file in the build output and a new entry
in `spine-flat`, so it reaches any navigation, feed or sitemap derived from
it. A directory left with no children at all (after exclusion) is still
dropped entirely rather than given an empty index. Setting
`auto_index = false` restores the previous behaviour exactly. Like every other
spine key it falls back field by field, so `[pdf.spine] auto_index = false`
turns it off for the combined PDF alone.

A project restyles every one of its directory indexes at once by binding its
own `rheo-index` in `[spine] prelude` (below), which is spliced after rheo's
own definition and so shadows it — rather than hand-writing an `index.typ` per
directory.

**`[spine] prelude`.** A path, relative to `content_dir`, to a Typst file that
rheo prepends INSIDE every vertebra, after that vertebra's own
`rheo-context()` binding. Because it is part of the vertebra's own source, a
`#let` in it binds a name the page can actually use — which marrow cannot do,
since a vertebra is `#include`d and Typst scopes an included file's bindings
to itself. And because it follows the context binding it can call
`rheo-context()`, so a project derives per-page facts once instead of
restating them in every file:

    [spine]
    prelude = "_lib/prelude.typ"

with `pages/_lib/prelude.typ` containing something like an import of a
root-absolute template module and two `#let` bindings derived from
`rheo-context()`.

Two constraints belong in the prose. Imports in the prelude must be
ROOT-ABSOLUTE (`"/_lib/template.typ"`, not `"template.typ"`), because the same
text is spliced into vertebrae at every directory depth. And the prelude's
text is inlined into every vertebra, so its cost is page count times its own
size — keep it to a few `#let`s that import from a module, which Typst
evaluates once, rather than putting a template's worth of code in it. Say that
second point as guidance, not as a warning banner.

rheo excludes the prelude's own path from the spine scan, so the file does not
compile as a page of its own. The splice is keyed per vertebra, so it reaches
neither a partial pulled in by `#include` nor the library file it imports.

## Steps

1. Fix the false bullet. `pages/spines.typ:15` currently reads that a
   subdirectory *without* a landing file becomes a group node with no page or
   handle of its own, its title derived from the directory name. Rewrite it to
   say what now happens by default — such a directory gets a synthesized
   landing page listing its children — and to point at the
   `` == `[spine] auto_index` `` section for the detail and the opt-out. Keep
   the bullet to one or two sentences; it is a summary line in a five-bullet
   list, not the reference text.

   Leave the other bullets at `:13`, `:14` and `:16` alone. In particular the
   numeric-prefix bullet at `:16` is still exactly right, and a synthesized
   index takes its directory's prettified name by the same rule.

2. Add a `` == `[spine] auto_index` `` section documenting the key as described
   above. Place it after `== Directory-scan default` (which ends at `:18`) and
   before `` == `[spine] exclude` `` at `:20`, because it modifies the scan
   default and should be read next to it. Follow the page's own idiom: heading,
   prose, then a fenced ```toml block showing the key with an inline default
   comment, in the shape of `pages/rheotoml.typ:42-45`:

       [spine]
       auto_index = false   # a directory with no landing file gets no page (default: true)

3. Add a `` == `[spine] prelude` `` section documenting the key as described
   above, including the root-absolute-imports constraint and the cost
   guidance. Place it after `` == `[[spine.section]]` `` (ending `:60`) and
   before `== Per-format overrides` at `:62` — it is a key rather than a
   layering mechanism, and `prelude` falls back field-by-field like the rest,
   which the following section then covers generically.

4. Document `rheo-index()` inside the `auto_index` section, not as a section of
   its own: what it renders (that directory's children as a list of links),
   that a synthesized page's whole body is a call to it, that it is in scope in
   every vertebra so a hand-written `index.typ` can call it too, and that a
   project overrides it by binding `#let rheo-index() = ...` in
   `[spine] prelude`. Cross-reference the `prelude` section you added in step 3
   using the page's own `#link(<...>)` idiom — `pages/spines.typ` already links
   between pages that way, e.g. the `#link(<spines>)` form used elsewhere in
   the site. If an intra-page anchor turns out not to be available, a plain
   prose reference by section name is an acceptable fallback; say which you
   used.

5. Match the surrounding voice. The page is declarative present tense, second
   person for instructions ("list glob patterns", "name your files"), one idea
   per sentence, em-dash asides, no marketing register and no "simply" or
   "just". Read `:20-29` and `:62-77` before writing and follow them.

## NON-GOALS

- Do NOT edit anything in `/home/lox/code/_fcl/rheo` or
  `/home/lox/code/_fcl/rheo-tests`. This bird is documentation for the site
  only.
- Do NOT add a new page, and do NOT touch `pages/index.typ`. Both keys belong
  on the existing Spines page, so the `site-nav` array at
  `pages/index.typ:15-59` needs no entry and must not be edited.
- Do NOT document the `synthesized` field that `auto_index` adds to
  `spine-flat` entries and `spine` tree nodes. That belongs in the
  `rheo-context` field table on `pages/rheo-context.typ` and is a separate
  bird; mentioning it here would duplicate it.
- Do NOT document the reserved `typ/` project-root prefix. Separate bird.
- Do NOT bump `version` in `rheo.toml`. A `rheo.toml` version that does not
  match the running engine only warns, never fails, and the version shown in
  the docs is interpolated from the engine at build time by
  `code-with-version` (`pages/index.typ:4-8`), not hardcoded.
- Do NOT run `build.sh`.

## VERIFY, all four

1. `rheo compile .` from the repo root completes with no error and no new
   warning. This is the project's whole "when done" check.
2. `rg -n 'auto_index|\[spine\] prelude|rheo-index' pages/spines.typ` shows the
   two new headings and the `rheo-index()` prose.
3. `pages/spines.typ:15`'s replacement no longer claims that a landing-file-less
   subdirectory gets no page of its own:
   `rg -n 'no page or handle of its own' pages/spines.typ` returns no hits.
4. Open `build/html/spines.html` and confirm both new sections render, in the
   intended order (auto_index directly after the directory-scan default,
   prelude directly before the per-format overrides), with their ```toml blocks
   formatted like the page's existing ones.