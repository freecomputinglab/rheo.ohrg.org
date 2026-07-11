#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "spines")

= Spines

A spine in Rheo is the backbone or 'table of contents' of Typst source files that should be compiled to an output format.
It takes its name from the #link("https://www.edrlab.org/open-standards/anatomy-of-an-epub-3-file/")[EPUB specification], in which the spine articulates---or _reticulates_--- the set and order of chapters included.

== Directory-scan default

With no configuration at all, the spine is built from `content_dir`'s own directory structure.
Every `.typ` file is included, ordered alphabetically within each directory level.
A subdirectory becomes a nested group in the spine: if it contains a landing file --- `index.typ`, or a file named after the directory itself (e.g. `chapters/chapters.typ`) --- that directory gets its own clickable page and handle; otherwise it becomes a non-clickable group node whose title is derived from the directory name.

A leading numeric prefix on a directory or section name (`01-intro/`) is used to order it among its siblings but stripped from the displayed title (`01-intro/` → "Intro"); the raw name, prefix included, is kept in the handle. Files are not prettified this way --- a file's title comes from its own content, not its filename.

This default is enough for most projects: name your files and folders in the order you want them read, and the spine follows.

== `[spine] exclude`

To omit files or folders from the scan without moving them out of `content_dir`, list glob patterns (relative to `content_dir`) under `[spine] exclude`:

```toml
[spine]
exclude = ["drafts/**", "TODO.typ"]
```

Excluded paths are dropped from every format's spine.

== `[[spine.section]]`: virtual directories

`[[spine.section]]` groups matched files under a virtual directory, without moving them on disk.
This is useful for reshaping the spine's structure independently of your folder layout:

```toml
[[spine.section]]
name = "chapters"
include = ["ch-*.typ"]
```

Files matching `include` get pulled under a virtual `chapters` group, gaining a namespaced handle (`ch-1.typ` → `<chapters:ch-1>`) exactly as if they lived in a `chapters/` directory.
A section's `title` defaults to a prettified version of `name`, and can be overridden explicitly.
Sections nest via `[[spine.section.section]]` to arbitrary depth.
When `include` lists more than one glob, matches are gathered in glob order and lexicographically within each glob --- so listing globs in the order you want lets you control ordering explicitly, not just alphabetically.

== Per-format overrides

A format-specific table --- `[pdf.spine]`, `[html.spine]`, `[epub.spine]` --- overrides the global `[spine]` table field by field: any field the per-format table sets replaces the matching global field, and any field it leaves unset still falls back to the global `[spine]`.

```toml
[spine]
exclude = ["drafts/**"]

[pdf.spine]
title = "My Book"   # combined-output title, PDF/EPUB only
```

Here PDF still inherits the global `exclude`, even though it only sets its own `title`.

Each format uses its spine slightly differently.
See the #link(<format-pdf>)[PDF], #link(<format-html>)[HTML], and #link(<format-epub>)[EPUB] format pages for details on how spines are configured and what defaults are applied for each output.
