#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "rheo-context")

= `rheo-context`

When Rheo compiles a project, it prepends a small binding to the top of every vertebra:

```typ
#let rheo-context() = (
  handle: "chapters:intro",
  metadata-of: rheo-metadata,
  ..sys.inputs.rheo-context,
)
```

The `rheo-context` dictionary exposes Rheo's view of the project to your Typst code: which file this is, every file in the #link(<spines>)[spine] alongside it, and a way of reading any of their resolved document metadata live.
Most of this is global context that can also be read in the format-global `sys.inputs.rheo-context`, but `handle` and `metadata-of` are file-specific.
(Rheo injects a distinct binding into each file, so every file sees _its own_ `handle`.)

`rheo-context()` is a zero-arg function that returns a dictionary.
It is *not* a Typst #link("https://typst.app/docs/reference/context/")[`context`] value, and you can read most of it with no `#context` keyword.
The one exception is `metadata-of` (#link(<vertebra-metadata>)[see below]).

```typ
This page's handle is #rheo-context().handle.
```

== Fields

The shape of `rheo-context` is designed to be extensible.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Field*][*Description*],
  [`handle`],
  [This file's #link(<relative-linking>)[handle] --- its `:`-separated identifier, the same handle used for cross-file links.],

  [`spine`],
  [
    A tree (an array of top-level nodes) mirroring the project's directory and section structure. Each node is a dictionary with four fields:
    - `title` --- the node's title, always #link(<vertebra-metadata>)[path-derived] (the file or directory name, prettified), regardless of any `#set document(title: ...)` the vertebra itself authors.
    - `handle` --- the vertebra's handle, or `none` for a group node (a directory or section with no landing file).
    - `path` --- the vertebra's path relative to the project root, or `none` for a group node.
    - `children` --- an array of child nodes, recursing to arbitrary depth (empty for a node with no descendants).
    You can use a `title` or `handle` to derive the link to a vertebra. Walk `children` to build nested navigation.
  ],

  [`spine-flat`],
  [
    A flat list of every *clickable* vertebra in spine order (group nodes are omitted). Each entry is a dictionary with three fields: `handle`, `path`, and a `title` that is always path-derived. ],

  [`metadata-of`],
  [
    A function value, `(handle) => dict`, reading another vertebra's `#set document(...)` fields live off the compiled bundle.
    #link(<vertebra-metadata>)[See below] for more information.
  ],

  [`target`],
  [
    The output format Rheo is compiling for, such as `"html"` or `"epub"`.
    It is *absent* for PDF, where Typst's native `target()` returns `"paged"`.
    In authored files, prefer Typst's own `target()` (which Rheo polyfills to return this value) over reading this field directly, as `target()` works everywhere, e.g. `#if target() == "epub" [ ... ]`.
  ],

  [`ext`],
  [
    The output file extension for the format being compiled, such as `"html"` for HTML or `"xhtml"` for EPUB.
    Like `target`, it is format-global (the same for every vertebra) and *absent* for PDF, where there are no per-page files.
    This is the value Rheo uses to build #link(<relative-linking>)[cross-vertebra links].
  ],

  [`rheo-version`],
  [
    The compiling Rheo binary's own #link("https://semver.org/")[semver] string, e.g. `"0.6.0"`.
    Unlike `target`/`ext`, it is *always* present, on every format, including PDF.
    A package's own Typst code can read it to enforce a minimum Rheo and fail with a clear message of its own choosing, rather than breaking obscurely against a build-time surface an older Rheo simply doesn't have.
    Its *absence* is the signal to treat as "older than the release that added this field.
    (A package can also declare a floor in its own manifest: see #link(<packages>)[Packages].)
  ],

  [`reset-footnotes`],
  [
    The resolved per-format footnote-reset toggle, as a plain `bool`. Unlike `target`/`ext`, it is *always* present, on every format including PDF, because it's a resolved default rather than something format-gated.
    This only ever actually takes effect on HTML/EPUB regardless of its value, as a combined PDF has no per-page boundary to reset at.
    Set `reset_footnotes = false` under `[html]`/`[epub]` in #link(<rheotoml>)[`rheo.toml`] (default `true`) if you'd rather footnotes accumulate across the whole bundle instead of restarting on every page.
  ],
)

== Reading vertebra metadata <vertebra-metadata>

Every vertebra compiled under a per-page layout such as HTML or EPUB publishes a small, hidden beacon after its own body as #link("https://typst.app/docs/reference/introspection/metadata/")[Typst metadata].
You can use the `metadata-of` function in `rheo-context` to query this metadata, meaning that you can query attributes such as the document title and date of other vertebrae from any point of the spine, which is useful for building blog feeds or other site listings.
Because this is a live query using Typst introspection, it needs the #link("https://typst.app/docs/reference/context/")[`#context` keyword]:

```typ
// This vertebra's own metadata, looked up by its own handle.
#context {
  let me = (rheo-context().metadata-of)(rheo-context().handle)
  if "date" in me [
    Published #me.date.display("[year]-[month]-[day]").
  ]
}
```

The are a few important nuances to the `metadata-of` function that you should keep in mind if you intend to use it:
- The combined PDF has no per-vertebra metadata at all, as PDF's default layout puts every vertebra into one shared `#document(...)` block (`metadata-of` returns an empty dictionary for every handle).
- A title or other value set inside a bounded code block is invisible to the beacon, and thus also to `metadata-of`.
  If another vertebra or a `@handle` anchor needs to see it, set the metadata either explicitly at the vertebra's top level in a `#document` block, or through a `#show:` template.
- `datetime.today()` resolves to whatever day the build actually happened on. If a vertebra's date feeds something published downstream such as an Atom feed built with #link(<atom-feeds>)[`@rheo/feeds`], using `datetime.today()` date will churn on every rebuild. Use a literal `datetime(year:, month:, day:)` for anything that needs to hold still.
- The beacon's own label carries a reserved `rheo-meta:` prefix. Authoring a label starting with this prefix will result in a build error.

== Example: building a blog feed

// In addition to `metadata-of`, you can also use `rheo-metadata-all()` in scope directly inside a #link(<marrow>)[`.marrow.typ`] for the relatively common case of wanting every vertebra's metadata at once to build an index, a search page, or a feed.
You can build an index of all pages in your project by mapping `spine-flat` through `metadata-of`.
Note that we need the `#context` keyword because we are using the `metadata-of` function:

```typ
#context {
  let meta-of = rheo-context().metadata-of
  for e in rheo-context().spine-flat {
    let m = meta-of(e.handle)
    let when = m.at("date", default: none)
    if when != none [
      - #link(label(e.handle))[#m.at("title", default: e.title)] --- #when.display()
    ]
  }
}
```

You can also use `rheo-context().spine` to keep structure when building, for example, a table of contents:

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
