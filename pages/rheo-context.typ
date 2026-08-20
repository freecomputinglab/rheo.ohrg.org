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

Only the `handle` and the `metadata-of` closure are baked directly into this per-file binding; everything else --- `spine`, `spine-flat`, `target`, `ext`, `rheo-version`, `reset-footnotes` --- is spread in from the format-global `sys.inputs.rheo-context`, so the (potentially large) spine tree is stored once per compile rather than copied into every vertebra.
This exposes Rheo's view of the project to your Typst code: which file this is, every file in the #link(<spines>)[spine] alongside it, and a way of reading any of their resolved document metadata live.
Rheo injects a distinct binding into each file, so every file sees _its own_ `handle`, even though the rest of the dictionary is identical everywhere.

`rheo-context()` is a zero-arg function returning a dictionary; call it to read Rheo's view.
It is *not* a Typst #link("https://typst.app/docs/reference/context/")[`context`] value, and reading most of it needs no `#context` keyword at all, because `sys.inputs` is non-contextual.
`metadata-of` is the one exception --- see #link(<vertebra-metadata>)[Reading vertebra metadata] below --- and it is the only field on `rheo-context()` that needs `#context` to resolve.
Any Typst code in the file can use the rest of it directly:

```typ
This page's handle is #rheo-context().handle.
```

== Fields

The shape of `rheo-context` is designed to be extensible --- three of the fields below (`metadata-of`, `rheo-version`, `reset-footnotes`) arrived after this page was first written, and more will likely follow.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Field*][*Description*],
  [`handle`],
  [This file's #link(<relative-linking>)[handle] --- its `:`-separated identifier, the same handle used for cross-file links.],

  [`spine`],
  [
    A tree (a forest --- an array of top-level nodes) mirroring the project's directory and section structure. Each node is a dictionary with four fields:
    - `title` --- the node's title, always #link(<vertebra-metadata>)[path-derived] (the file or directory name, prettified), regardless of any `#set document(title: ...)` the vertebra itself authors.
    - `handle` --- the vertebra's handle, or `none` for a group node (a directory or section with no landing file).
    - `path` --- the vertebra's path relative to the project root, or `none` for a group node.
    - `children` --- an array of child nodes, recursing to arbitrary depth (empty for a node with no descendants).
    A group node is not itself clickable --- there's nothing to link to --- but its title still labels the section. Walk `children` to build nested navigation.
  ],

  [`spine-flat`],
  [
    A flat list of every *clickable* vertebra in spine order (group nodes are omitted). Each entry is a dictionary with three fields --- `handle`, `path`, and a `title` that is, like the tree's, always path-derived. Reach for it when a flat sequence beats walking the tree --- prev/next navigation, page counts, and the like.
  ],

  [`metadata-of`],
  [
    A function value, `(handle) => dict`, reading another vertebra's *actually authored* `#set document(...)` fields live off the compiled bundle --- neither `spine` nor `spine-flat` carries them.
    See #link(<vertebra-metadata>)[Reading vertebra metadata] below: it needs `#context`, and it needs an unusual call form, and both deserve a proper explanation rather than a table cell.
  ],

  [`target`],
  [
    The output format Rheo is compiling for --- `"html"` or `"epub"`.
    It is *absent* for PDF, where Typst's native `target()` returns `"paged"`.
    The value is the same for every vertebra.
    In authored files, prefer Typst's own `target()` (which Rheo polyfills to return this value) over reading the field directly --- `target()` works everywhere, e.g. `#if target() == "epub" [ ... ]`.
  ],

  [`ext`],
  [
    The output file extension for the format being compiled --- `"html"` for HTML, `"xhtml"` for EPUB --- sourced from the format plugin.
    Like `target`, it is format-global (the same for every vertebra) and *absent* for PDF, where there are no per-page files.
    This is the value Rheo itself uses to build depth-relative cross-vertebra link hrefs.
  ],

  [`rheo-version`],
  [
    The compiling Rheo binary's own #link("https://semver.org/")[semver] string, e.g. `"0.6.0"`.
    Unlike `target`/`ext`, it is *always* present, on every format, including PDF.
    A package's own Typst code can read it to enforce a minimum Rheo and fail with a clear message of its own choosing, rather than breaking obscurely against a build-time surface an older Rheo simply doesn't have.
    Its *absence* is the signal to treat as "older than the release that added this field" --- there's no finer-grained negotiation than presence-or-absence at this level.
    (A package can also declare a floor more declaratively, in its own manifest --- see #link(<packages>)[Packages].)
  ],

  [`reset-footnotes`],
  [
    The resolved per-format footnote-reset toggle, as a plain `bool`. Unlike `target`/`ext`, it is *always* present, on every format including PDF, because it's a resolved default rather than something format-gated.
    Rheo's own injected page-init hook ANDs it with the per-page `ext` gate before resetting each page's footnote counter to `1`, so it only ever actually takes effect on HTML/EPUB regardless of its value --- a combined PDF has no per-page boundary to reset at.
    Set `reset_footnotes = false` under `[html]`/`[epub]` in `rheo.toml` (default `true`) if you'd rather footnotes accumulate across the whole bundle instead of restarting on every page.
  ],
)

== Reading vertebra metadata <vertebra-metadata>

Rheo used to harvest a vertebra's `#set document(...)` values by statically scanning its source text before compilation, and stored the result right there on `spine`/`spine-flat`, as a `metadata` field on each entry.
That's gone: neither the tree nor the flat list carries a `metadata` key any more, and their `title` fields were never switched over to begin with --- they stay path-derived (the file or directory name, prettified) whether or not a vertebra authors its own title, literal or otherwise.
Metadata is read a different way now, live off the compiled bundle rather than off Rheo's pre-compile guess at your source, through the `metadata-of` closure on `rheo-context()`.

Every vertebra compiled under a per-page layout (HTML, EPUB) publishes a small, hidden "beacon" after its own body --- a labelled `#metadata(...)` element carrying whatever `document.title`, `.author`, `.description`, `.keywords`, and `.date` actually resolved to for that vertebra.
`metadata-of` queries it: `(rheo-context().metadata-of)(handle)` returns a dictionary with whichever of those keys the vertebra actually set, omitting the rest rather than filling them in with `none`.
Call it on your own `handle` to read your own metadata, or on any other vertebra's to read theirs --- the mechanism doesn't distinguish.
Because this is a live query (`query()`, under the hood) it needs `#context`, unlike every other field on `rheo-context()`, which is a plain read off non-contextual `sys.inputs`.
And because `metadata-of` is a dictionary field holding a function value rather than a method, you call it with the slightly awkward `(rheo-context().metadata-of)(handle)` form --- `rheo-context().metadata-of(handle)` fails outright, because Typst doesn't resolve dict-field function values as methods.

```typ
// This vertebra's own metadata, looked up by its own handle.
#context {
  let me = (rheo-context().metadata-of)(rheo-context().handle)
  if "date" in me [
    Published #me.date.display("[year]-[month]-[day]").
  ]
}
```

This closes most of the gaps the old source-text scan had.
A title set via an imported `#show:` template, buried in a non-literal expression, or set by several `#set document(...)` rules across a file all resolve correctly now, because the beacon reads off Typst's own realised style chain rather than re-parsing your source.
`title` and `description` come back as real Typst *content*, not flattened strings, which is new and deliberate --- the old scan had to flatten everything to plain text, because that was all it had to work with, but the beacon can hand back the actual formatted value.
`author` and `keywords` are always arrays, even for a single value; `date` is a genuine Typst #link("https://typst.app/docs/reference/foundations/datetime/")[`datetime`], so you can call `.display()`, `.year()`, and the like on it directly.

Three things are worth knowing honestly rather than discovering by surprise.
The first is that combined PDF has no per-vertebra metadata at all: PDF's default layout puts every vertebra into one shared `#document(...)` block, so there's no well-defined "this vertebra's own metadata" to publish --- a vertebra with no `#set document(...)` of its own would otherwise silently inherit whatever the previous one set. No beacon is emitted there, so `metadata-of` returns an empty dictionary for every handle under combined PDF, by design rather than as a gap to route around.
The second is that a title set inside a bounded code block is invisible to the beacon, even though it's perfectly visible in the vertebra's own compiled output: `#set document(...)` wrapped in its own `#{ }` or `#[ ]` still sets the vertebra's real compiled title correctly, because Typst's document-info collection doesn't care about block scoping, but the beacon's own `#context` read --- appended once, after the vertebra's whole body --- does respect it, and can't see a rule whose block already closed earlier in the file. Set a title at the vertebra's top level, or through a `#show:` template (which has no closing brace of its own to trip this), if another vertebra or a `@handle` anchor needs to see it.
The third is that `datetime.today()` now resolves to whatever day the build actually happened on: the old scan rejected it outright, because it couldn't tell a call from a literal by reading source text, and the new mechanism reads the resolved value instead, so it can't tell them apart either. If a vertebra's date feeds something published downstream --- an Atom feed built with #link(<atom-feeds>)[`@rheo/feeds`], say --- a `datetime.today()` date will churn on every rebuild. Reach for a literal `datetime(year:, month:, day:)` for anything that needs to hold still.

One more thing worth flagging, though you're unlikely to hit it by accident: the beacon's own label carries a reserved `rheo-meta:` prefix, and authoring a label starting with it yourself is a hard build error naming the offending file and label.

== Example: an index of dated pages

`metadata-of` also has a bundle-root companion, `rheo-metadata-all()`, in scope directly inside a `.marrow.typ` (see #link(<marrow>)[Marrow]) for the common case of wanting every vertebra's metadata at once --- building an index, a search page, or a feed the way #link(<atom-feeds>)[`@rheo/feeds`] does.
The same thing is reachable from an ordinary vertebra too, just by mapping `spine-flat` through `metadata-of` yourself:

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

Undated pages are skipped rather than sorted arbitrarily, since there's no fallback timestamp to reach for --- only a vertebra with a resolved `date` shows up at all.

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
