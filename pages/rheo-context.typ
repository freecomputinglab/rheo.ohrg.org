#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "rheo-context")

= The `rheo-context` variable

When Rheo compiles a project, it prepends a small binding to the top of every vertebra:

```typ
#let rheo-context = (
  handle: "chapters:intro",
  spine: (
    (title: "Introduction", handle: "intro", path: "content/intro.typ", children: ()),
    (title: "Chapters", handle: none, path: none, children: (
      (title: "Chapter Introduction", handle: "chapters:intro", path: "content/chapters/intro.typ", children: ()),
      // ... one node per vertebra or group, nested to arbitrary depth
    )),
  ),
  spine-flat: (
    (handle: "intro", path: "content/intro.typ", title: "Introduction"),
    (handle: "chapters:intro", path: "content/chapters/intro.typ", title: "Chapter Introduction"),
    // ... one entry per vertebra, in spine order
  ),
  target: "html", // the output format; absent for PDF
)
```

This exposes Rheo's view of the project to your Typst code: which file this is, and every file in the #link(<spines>)[spine] alongside it.
Rheo injects a distinct literal into each file, so every file sees _its own_ values.

`rheo-context` is an ordinary top-level `#let` binding --- a plain dictionary.
It is *not* a Typst #link("https://typst.app/docs/reference/context/")[`context`] value, and reading it does *not* require the `#context` keyword.
Any Typst code in the file can use it directly:

```typ
This page's handle is #rheo-context.handle.
```

== Fields

`rheo-context` currently has four fields: `handle`, `spine`, `spine-flat`, and `target`.
The shape is extensible --- more fields may be added in future versions --- so treat it as a dictionary that will only grow.

/ `handle`: This file's #link(<relative-linking>)[handle] --- its `:`-separated identifier, the same handle used for cross-file links.

/ `spine`: A tree (a forest --- an array of top-level nodes) mirroring the project's directory and section structure. Each node is a dictionary with four fields:
  - `title` --- the node's title.
  - `handle` --- the vertebra's handle, or `none` for a group node (a directory or section with no landing file).
  - `path` --- the vertebra's path relative to the project root, or `none` for a group node.
  - `children` --- an array of child nodes, recursing to arbitrary depth (empty for a node with no descendants).
  A group node is not itself clickable --- there's nothing to link to --- but its title still labels the section. Walk `children` to build nested navigation.

/ `spine-flat`: A flat list of every *clickable* vertebra in spine order (group nodes are omitted). Each entry is a dictionary with three fields:
  - `handle` --- the vertebra's handle.
  - `path` --- its path, relative to the project root.
  - `title` --- its title.
  Use this where a flat sequence is simpler than walking the tree --- prev/next navigation, page counts, and the like.

/ `target`: The output format Rheo is compiling for --- `"html"` or `"epub"`.
  It is *absent* for PDF, where Typst's native `target()` returns `"paged"`.
  The value is the same for every vertebra.
  In authored files, prefer Typst's own `target()` (which Rheo polyfills to return this value) over reading the field directly --- `target()` works everywhere, e.g. `#if target() == "epub" [ ... ]`.

== Passing it to a package

A Typst function captures the scope in which it was _defined_, not the scope from which it is _called_.
A function that lives in a package therefore cannot read the calling file's local `rheo-context` implicitly --- you have to hand it in.

Pass it explicitly as an argument:

```typ
#import "@preview/somepackage:0.1.0"
#show: somepackage.with(ctx: rheo-context)
```

The package can then read `ctx.handle`, walk `ctx.spine` (the tree) or `ctx.spine-flat` (the flat list), and so on.

== Example: a table of contents

Because `spine-flat` lists every clickable vertebra in order, a template or package can build a flat table of contents from it directly:

```typ
#for entry in rheo-context.spine-flat [
  - #link(label(entry.handle))[#entry.title]
]
```

Each file receives the same `spine-flat`, so this produces a consistent list across the whole project, while `rheo-context.handle` lets a template highlight the current page.

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
#toc(rheo-context.spine)
```
