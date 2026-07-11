#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "rheo-context")

= The `rheo-context` variable

When Rheo compiles a project, it prepends a small binding to the top of every vertebra:

```typ
#let rheo-context = (
  handle: "chapters:intro",
  spine: (
    (handle: "intro", path: "content/intro.typ", title: "Introduction"),
    (handle: "chapters:intro", path: "content/chapters/intro.typ", title: "Chapter Introduction"),
    // ... one entry per vertebra, in spine order
  ),
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

`rheo-context` currently has two fields.
The shape is extensible --- more fields may be added in future versions --- so treat it as a dictionary that will only grow.

/ `handle`: This file's #link(<relative-linking>)[handle] --- its `:`-separated identifier, the same handle used for cross-file links.

/ `spine`: A flat list of every vertebra in spine order. Each entry is a dictionary with three fields:
  - `handle` --- the vertebra's handle.
  - `path` --- its path, relative to the project root.
  - `title` --- its title.

== Passing it to a package

A Typst function captures the scope in which it was _defined_, not the scope from which it is _called_.
A function that lives in a package therefore cannot read the calling file's local `rheo-context` implicitly --- you have to hand it in.

Pass it explicitly as an argument:

```typ
#import "@preview/somepackage:0.1.0"
#show: somepackage.with(ctx: rheo-context)
```

The package can then read `ctx.handle`, walk `ctx.spine`, and so on.

== Example: a table of contents

Because `spine` lists every vertebra in order, a template or package can build navigation from it.
A minimal in-file table of contents:

```typ
#for entry in rheo-context.spine [
  - #link(label(entry.handle))[#entry.title]
]
```

Each file receives the same `spine`, so this produces a consistent list across the whole project, while `rheo-context.handle` lets a template highlight the current page.
