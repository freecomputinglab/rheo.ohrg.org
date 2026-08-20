#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "atom-feeds")

= Feeds

Rheo sites can carry a feed --- a file a reader's newsreader polls on its own schedule, so new pages surface without anyone visiting the site to go and check.
What changed between one Rheo release and the next is not the capability but where it lives.
Generating a feed used to be a handful of `[html]` keys in `rheo.toml`, read by a Rust plugin built into the engine; now it is `@rheo/feeds:0.1.0`, a Typst package you import and configure the same way you'd reach for any other package from Typst Universe --- the same move `@rheo/blogfeed` and `@rheo/sidebar` already made for other project-shaped concerns.
The wire format a subscriber's reader parses hasn't moved; only the place you go to switch it on has.

Import the package, describe one feed, and configure it, and you're done:

```typst
#import "@rheo/feeds:0.1.0": feed, configure, spine

#configure(feeds: (
  feed(
    title: "My Site",
    base-url: "https://example.com",
    sources: (spine(),),
  ),
))
```

Call `configure` from any vertebra you like --- it only appends onto a document-wide state, and the package's own build step reads that state once, at the end of the compile, and mints `feed.xml`.
`spine()` reproduces the retired generator's default behaviour: every vertebra in the project becomes a candidate entry, so this block is the whole migration for a site that only ever pointed the old generator at a base URL and changed nothing else (see the migration table below for every other knob).
One floor to know about: this needs Rheo 0.6.0 or later, because the package leans on three build-time surfaces --- a per-vertebra metadata beacon, page transclusion, and an autodiscovery control asset --- that simply don't exist before it, and the package asserts that floor itself rather than failing quietly on an older Rheo.

== Multiple feeds

One project, several feeds, each over its own slice of the site, with its own title, author, and output path, is the reason to reach for this over the old generator's single base-URL switch.
A feed is just a value, so nothing stops you registering more than one in the same `configure` call:

```typst
#let posts = spine(filter: e => e.handle.starts-with("posts:"))
#let essays = spine(filter: e => e.handle.starts-with("essays:"))

#configure(feeds: (
  feed(path: "feed.xml", title: "My Site --- Posts", base-url: "https://example.com", sources: (posts,)),
  feed(
    path: "essays.xml",
    title: "My Site --- Essays",
    author: "Someone Else",
    base-url: "https://example.com",
    sources: (essays,),
  ),
))
```

The same trick multiplies over *format*, not only over subset.
`format` picks the serializer --- `"atom"` (the default), `"rss"`, or `"json"` --- so the identical sources can be registered at three paths and ship as Atom, RSS, and JSON Feed from one `configure` call:

```typst
#configure(feeds: (
  feed(path: "feed.xml", title: "My Site", base-url: "https://example.com", sources: (posts,)),
  feed(path: "rss.xml", title: "My Site", base-url: "https://example.com", sources: (posts,), format: "rss"),
  feed(
    path: "feed.json",
    title: "My Site",
    base-url: "https://example.com",
    sources: (posts,),
    format: "json",
    content: none,
  ),
))
```

Every page's `<head>` then carries one autodiscovery link per feed, so whichever format a visitor's reader prefers, it finds it.
JSON Feed is summary-only for now and needs `content: none` on any feed using it --- there's no JSON-safe way yet to splice a page's compiled HTML into a JSON string, which is a Rheo limitation rather than a `@rheo/feeds` one.

== Where entries come from

A feed's `sources` field is an array of plain functions, `cfg => (entries,)`, and the package ships two of them.

`spine(filter:, select:)` is the one used above: it walks the project's own spine, and every vertebra is a candidate entry unless `filter` says otherwise.
The predicate runs against the vertebra's `handle`, `path`, and `title`, not its position in the directory tree, which is why a filtered source can reach arbitrarily deep --- a post nested three directories down still matches a `handle.starts-with("posts:")` filter the same as one at the top level.
Each entry's title, dates, and categories come straight from that vertebra's own `#set document(...)` call.

`items(filter:, label-name:)` is the other one, and it reads a different shape of source entirely: any `#metadata((...)) <feeds:item>` beacon emitted anywhere in the project, by hand or via the package's own `item(...)` helper.
This is the fallback, not the first thing to reach for --- use it only when the data has no accessor of its own to call, such as an arbitrary hand-authored page with no registry behind it.

`@rheo/rookery`'s labelled notes look like the case `items()` is for, and turn out not to be one: `ideas(tags:)` already hands back an array of every matching note, synchronously, so a source can call it directly instead of going by way of a beacon.
Rookery's own `href` field is relative to wherever a note happens to be read from, and this source runs at the bundle root, so the leading `../` run has to be stripped first:

```typst
#import "@rheo/feeds:0.1.0": feed, configure
#import "@rheo/rookery:0.3.0": ideas

#let root-relative(h) = {
  let out = h
  while out.starts-with("../") { out = out.slice(3) }
  out
}

#let from-ideas(tags: none) = cfg => (
  ideas(tags: tags)
    .filter(e => e.href != none and e.updated != none)
    .map(e => (
      id: e.id,
      title: e.text,
      page: root-relative(e.href),
      updated: e.updated,
      published: e.minted,
      summary: e.body,
      categories: e.tags,
    ))
)

#configure(feeds: (
  feed(
    path: "notes.xml",
    title: "My Site --- Notes",
    base-url: "https://example.com",
    content: none,
    sources: (from-ideas(tags: "note"),),
  ),
))
```

Neither package imports the other: `from-ideas` is nothing but a plain function reshaping rookery's own row shape (`href`, `text`, `minted`) into the entry shape `@rheo/feeds` expects (`page`, `title`, `published`).
The parentheses wrapping the `.filter(...).map(...)` chain above are load-bearing, not decorative#footnote[Spread across lines without them, the chained calls fall out of the `#let`'s single expression and back into markup, which typesets as a paragraph of code rather than binding a function.].
`content: none` is required here, not a preference --- a rookery note's page is minted rather than compiled, so it has no rendered body to splice into a feed entry, and these entries carry rookery's plain-text `body` as a summary instead.

== Keeping page chrome out of your entries

Where a feed's `content` is `"html"` (the default) or `"xhtml"`, an entry's body is spliced in from the page itself, and you want the article, not the header and navigation sitting around it on the page.
That's no longer a feed-specific rule to configure --- it's Rheo's own default behaviour for splicing one page's content into another, and a feed entry is just one consumer of it among others.
Wrap the article in `<main>` and keep the chrome outside it:

```typst
#html.elem("main", doc)
```

Where your template already reserves `<main>` for something else, mark the region you actually want with the `rheo-feed-content` class, exactly as this page has always told you to:

```typst
#html.elem("div", attrs: (class: "rheo-feed-content"), doc)
```

Rheo checks four things in order before giving up --- `<main>`, then a generic `.rheo-content` class meant for uses beyond feeds, then this specific `rheo-feed-content` one (kept working as a compatibility alias), then the whole `<body>` when none of them are present --- so the class this page has documented from the start still does exactly what it always did.
An entry's own `select` field, when a source sets one, is passed straight through to the same mechanism, letting a source point at a differently-marked region per entry rather than relying on the page-wide default.

== Migrating from the retired `[html]` feed keys

Every `[html]` key and `rheo-*` variable the old generator read has a straightforward replacement here.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Retired*][*Here*],
  [`[html] feed_base_url`], [the feed config's `base-url`],
  [`[html] feed_title`], [`title`],
  [`[html] feed_author`], [`author`],
  [`[[html.feed_include]]`], [no longer needed --- a source already lists exactly what it lists],
  [`#let rheo-feed-title = "..."`], [the entry's `title` --- usually `#set document(title: ...)`, which `spine()` reads back],
  [`#let rheo-feed-updated = "..."`], [`#set document(date: datetime(...))`, or a composed override over a source's output],
  [`#let rheo-feed-exclude = true`], [omit the page from every source's selection, or leave it undated --- either drops it from the feed],
)

Three things about the new package are worth stating plainly rather than discovering the hard way.

`title` is now required, with no fallback chain: the retired generator fell back from an explicit title to the HTML spine's own title to the project's directory name, and `feed(...)` here simply refuses to build without one.
An entry with no date is silently dropped rather than dated some other way: Atom requires `<updated>`, and Typst has no way to read a compiled file's modification time the way the retired generator did, so a `spine()` entry with no `#set document(date: ...)` --- and no `published` or `updated` from anywhere else --- never becomes a feed entry at all, which is also what the exclude-this-page row in the table above now amounts to.
And `<published>` is a genuine addition rather than parity: the retired generator only ever wrote `<updated>`, whereas an entry with both `published` and `updated` set now gets both elements, with their own distinct values when the two differ.

One trap carries over unchanged from before: `datetime.today()` resolves to whatever day the build happens to run on, so a page dated with it produces a feed entry that looks freshly updated on every single deploy, forever, to every subscriber.
Give a post's `#set document(date: ...)` a literal `datetime(year: ..., month: ..., day: ...)` instead.
