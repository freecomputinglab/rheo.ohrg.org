#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "spines")

= Spines

A spine in Rheo is the backbone or 'table of contents' of Typst source files that should be compiled to an output format.
It takes its name from the #link("https://www.edrlab.org/open-standards/anatomy-of-an-epub-3-file/")[EPUB specification], in which the spine articulates---or _reticulates_--- the set and order of chapters included.

== Directory-scan default

With no configuration at all, the spine is built from `content_dir`'s own directory structure:

- Every `.typ` file is included, ordered alphabetically within each directory level.
- A subdirectory with a landing file --- `index.typ`, or a file named after the directory itself (e.g. `chapters/chapters.typ`) --- becomes a group with its own page and handle.
- A subdirectory *without* a landing file becomes a group node with no page or handle of its own, its title derived from the directory name.
- A leading numeric prefix on a directory or section name orders it among its siblings but is stripped from the displayed title: `01-intro/` → "Intro". The raw name, prefix included, is kept in the handle. Files are not prettified this way --- a file's title comes from its own content, not its filename.

This default is enough for most projects: name your files and folders in the order you want them read, and the spine follows.

== `[spine] exclude`

To omit files or folders from the scan without moving them out of `content_dir`, list glob patterns (relative to `content_dir`) under `[spine] exclude`:

```toml
[spine]
exclude = ["drafts/**", "TODO.typ"]
```

Excluded paths are dropped from every format's spine.

== `[spine] include`

`[spine] include` is an ordered list of glob patterns that becomes that spine's definitive order, replacing the alphabetical directory scan outright.
Patterns are matched in the order you list them; within a single pattern, matches are sorted lexicographically.
A file matched by none of the listed patterns is dropped from the spine entirely --- which is also why `include` makes a separate `exclude` for the same files unnecessary.

```toml
[spine]
include = ["index.typ", "install.typ", "ideas.typ", "flights.typ"]
```

This is the tool for a specific reading order the alphabetical scan can't express on its own --- here `install` comes second even though `flights` and `ideas` would otherwise sort ahead of it.
Unlike `[[spine.section]]` below --- which happens to have a field of the same name and a related but distinct job --- flat `include` introduces no group node and no path prefix: the handles and output paths it produces are exactly what the directory scan would already give, just reordered.
`install.typ` still becomes `/install.html`, flat, not nested under any virtual directory.

Two situations here fail the build rather than doing something quietly unintended: setting both `include` and `section` on the same table is rejected at validation (they're two different ways of reshaping the same scan, and Rheo asks you to pick one), and a pattern that matches no file is an error rather than a pattern that silently contributed nothing.
The first version of flat `include` only reorders flat, top-level files --- it doesn't yet reach into a nested content directory and reorder within it.

== `[[spine.section]]`

`[[spine.section]]` also has a field called `include`, but it does something different from the flat `[spine] include` documented just above: it groups matched files under a virtual directory, without moving them on disk, and it *does* prefix every matched file's handle and URL with that group's name.
This is useful for reshaping the spine's structure independently of your folder layout:

```toml
[[spine.section]]
name = "chapters"
include = ["ch-*.typ"]
```

- Files matching `include` get pulled under a virtual `chapters` group, gaining a namespaced handle exactly as if they lived in a `chapters/` directory: `ch-1.typ` → `<chapters:ch-1>`.
- A section's `title` defaults to a prettified version of `name`, and can be overridden explicitly.
- Sections nest via `[[spine.section.section]]` to arbitrary depth.
- When `include` lists more than one glob, matches are gathered in glob order and lexicographically within each glob --- so listing globs in the order you want lets you control ordering explicitly, not just alphabetically.

== Per-format overrides

A format-specific table --- `[pdf.spine]`, `[html.spine]`, `[epub.spine]` --- overrides the global `[spine]` one field at a time: whatever it sets wins, and whatever it leaves out falls back to `[spine]`.

```toml
[spine]
exclude = ["drafts/**"]

[pdf.spine]
title = "My Book"   # combined-output title, PDF/EPUB only
```

Here PDF still inherits the global `exclude`, even though it only sets its own `title`.

Each format uses its spine slightly differently.
See the #link(<format-pdf>)[PDF], #link(<format-html>)[HTML], and #link(<format-epub>)[EPUB] format pages for details on how spines are configured and what defaults are applied for each output.
