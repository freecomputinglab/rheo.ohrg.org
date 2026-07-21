#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "rheo-context")

= `rheo-context`

When Rheo compiles a project, it prepends a small binding to the top of every vertebra:

```typ
#let rheo-context() = (
  handle: "chapters:intro",
  ..sys.inputs.rheo-context,
)
```

Only the `handle` is per-file; it is composed with the format-global values (`spine`, `spine-flat`, `target`, `ext`) spread from `sys.inputs.rheo-context`.
This exposes Rheo's view of the project to your Typst code: which file this is, and every file in the #link(<spines>)[spine] alongside it.
Rheo injects a distinct binding into each file, so every file sees _its own_ values.

`rheo-context()` is a zero-arg function returning a dictionary; call it to read Rheo's view.
It is *not* a Typst #link("https://typst.app/docs/reference/context/")[`context`] value, and it needs no `#context` keyword (`sys.inputs` is non-contextual).
Any Typst code in the file can use it directly:

```typ
This page's handle is #rheo-context().handle.
```

== Fields

The shape of `rheo-context` is designed to be extensible --- more fields may be added in future versions.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Field*][*Description*],
  [`handle`],
  [This file's #link(<relative-linking>)[handle] --- its `:`-separated identifier, the same handle used for cross-file links.],

  [`spine`],
  [
    A tree (a forest --- an array of top-level nodes) mirroring the project's directory and section structure. Each node is a dictionary with four fields:
    - `title` --- the node's title.
    - `handle` --- the vertebra's handle, or `none` for a group node (a directory or section with no landing file).
    - `path` --- the vertebra's path relative to the project root, or `none` for a group node.
    - `children` --- an array of child nodes, recursing to arbitrary depth (empty for a node with no descendants).
    A group node is not itself clickable --- there's nothing to link to --- but its title still labels the section. Walk `children` to build nested navigation.
  ],

  [`spine-flat`],
  [
    A flat list of every *clickable* vertebra in spine order (group nodes are omitted). Each entry is a dictionary with three fields:
    - `handle` --- the vertebra's handle.
    - `path` --- its path, relative to the project root.
    - `title` --- its title.
    Use this where a flat sequence is simpler than walking the tree --- prev/next navigation, page counts, and the like.
  ],

  [`target`],
  [
    The output format Rheo is compiling for --- `"html"` or `"epub"`.
    It is *absent* for PDF, where Typst's native `target()` returns `"paged"`.
    The value is the same for every vertebra.
    In authored files, prefer Typst's own `target()` (which Rheo polyfills to return this value) over reading the field directly --- `target()` works everywhere, e.g. `#if target() == "epub" [ ... ]`.
  ],
)

== Example: a table of contents

Because `spine-flat` lists every clickable vertebra in order, a template or package can build a flat table of contents from it directly:

```typ
#for entry in rheo-context().spine-flat [
  - #link(label(entry.handle))[#entry.title]
]
```

Each file receives the same `spine-flat`, so this produces a consistent list across the whole project, while `rheo-context().handle` lets a template highlight the current page.

A nested table of contents --- one that reflects the project's directory and section groups --- has to walk `spine` instead, recursing into `children`:

```typ
#let toc(nodes) = {
  for node in nodes [
    - #if node.handle != none [
        #link(label(node.handle))[#node.title]
      ] else [
        #node.title
      ]
      #if node.children.len() > 0 [
        #toc(node.children)
      ]
  ]
}
#toc(rheo-context().spine)
```
