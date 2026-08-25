#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "atom-feeds")

= Feeds

The `@rheo/feeds` #link(<packages>)[package] mints a syndication feed --- Atom 1.0, RSS 2.0, or JSON Feed 1.1 --- from the pages a project already has.
A feed is a file a reader's newsreader polls on its own schedule, so new pages surface without anyone visiting your site to go and check.
Describe one feed in Typst, point it at a slice of your project, and the package writes the file at the end of the build and puts an autodiscovery link in every page's `<head>`.

Rheo used to generate the Atom half of this itself, from a handful of `[html]` keys in `rheo.toml` read by a Rust plugin built into the engine.
Since 0.6.0 that plugin is retired and feeds come from the package instead, built on the #link(<marrow>)[marrow], #link(<beacons>)[beacon], and #link(<head-control>)[control asset] primitives.
The wire format a subscriber's reader parses is unchanged; only the place you configure it has moved.

The package needs Rheo 0.6.0 or later, because those three build-time surfaces --- a #link(<rheo-context>)[per-vertebra metadata beacon], #link(<beacons>)[page transclusion], and an #link(<head-control>)[autodiscovery control asset] --- don't exist before it.
It asserts that floor itself rather than failing quietly on an older Rheo, which matters here because all three surfaces fail silently: on 0.5.2 the same project compiles clean and simply ships no feed.

== Importing the package

Import the package in whichever vertebra you want to configure your feeds from:

```typ
#import "@rheo/feeds:0.1.0": feed, configure, spine
```

== Configuring a feed

Describe one feed, and hand it to `configure`:

```typ
#configure(feeds: (
  feed(
    title: "My Site",
    base-url: "https://example.com",
    sources: (spine(),),
  ),
))
```

Call `configure` from any vertebra you like.
It only appends onto a document-wide state, and the package's own build step reads that state once, at the end of the compile, and mints `feed.xml`.
`spine()` reproduces the retired generator's default behaviour: every vertebra in the project becomes a candidate entry, so this block is the whole #link(<feed-migration>)[migration] for a site that only ever pointed the old generator at a base URL.

=== Feed fields

`feed(...)` validates its arguments and returns the config dictionary that every source is later handed:

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  table.header[*Field*][*Default*][*Description*],
  [`title`],
  [required],
  [
    The feed's own title, a non-empty string.
    It doubles as the `title=` on each autodiscovery link.
  ],

  [`base-url`],
  [required],
  [
    An absolute URL, scheme included.
    It prefixes an entry's `page` into an absolute URL, and is emitted as the feed's own `rel="alternate"` link --- the site a reader visits from a subscription, as distinct from `rel="self"`, the feed file itself.
  ],

  [`sources`],
  [required],
  [
    An array of at least one source function.
    See #link(<feed-sources>)[Where entries come from].
  ],

  [`path`],
  [`"feed.xml"`],
  [
    Where the feed is written, relative to the HTML build directory.
  ],

  [`author`],
  [`"Rheo"`],
  [
    The feed-level author, inherited by any entry that names none of its own.
  ],

  [`subtitle`],
  [`none`],
  [
    An optional feed subtitle.
  ],

  [`format`],
  [`"atom"`],
  [
    The serializer: `"atom"`, `"rss"`, or `"json"`.
  ],

  [`content`],
  [`"html"`],
  [
    What an entry's body resolves to.
    `"html"` and `"xhtml"` splice in the entry's own page via #link(<beacons>)[transclusion]; `none` omits the body entirely, leaving a `summary` to stand in for it.
  ],

  [`limit`],
  [`none`],
  [
    A positive integer capping how many entries the feed carries, or `none` for all of them.
  ],
)

== Multiple feeds and formats

A feed is just a value, so you can register more than one in the same `configure` call, each over its own slice of the site and with its own title, author, and output path:

```typ
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

The same applies over *format*, so identical sources can be registered at three paths and ship as Atom, RSS, and JSON Feed from one call:

```typ
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

Every page's `<head>` then carries one #link(<head-control>)[autodiscovery link] per feed, each with its own type, so whichever format a visitor's reader prefers, it finds it.

The entry model is shared across the three, but the formats are not equivalent, and where they diverge the package maps rather than drops:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Format*][*What differs*],
  [`"atom"`],
  [
    The reference mapping, and the only one that takes `content: "xhtml"`.
    An entry with both `published` and `updated` gets both elements.
  ],

  [`"rss"`],
  [
    RSS has one date per item, so `pubDate` takes `published` where there is one and `updated` otherwise, and the channel's `lastBuildDate` carries the newest `updated`.
    An author is emitted per item as `<dc:creator>` rather than `<author>`, which RSS requires to hold an email address.
  ],

  [`"json"`],
  [
    Summary-only, and it needs `content: none`.
    There is no JSON-safe way yet to splice a page's compiled HTML into a JSON string, which is a Rheo limitation rather than a `@rheo/feeds` one.
  ],
)

== Where entries come from <feed-sources>

A feed's `sources` field is an array of plain functions, `cfg => (entries,)`, where `cfg` is the feed config above.
A built-in source takes its own options and *returns* the source, so it reads as an ordinary call at the call site --- `spine(filter: ...)`, not `spine.with(filter: ...)`, which yields a function that then refuses the positional `cfg` and fails with `error: unexpected argument`.

The package ships two:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Source*][*What it reads*],
  [`spine(filter:, select:)`],
  [
    The project's own #link(<spines>)[spine]: every vertebra is a candidate entry unless `filter` says otherwise.
    The predicate runs against the vertebra's `handle`, `path`, and `title`, not its position in the directory tree, so a filtered source can reach arbitrarily deep --- a post nested three directories down still matches a `handle.starts-with("posts:")` filter the same as one at the top level.
    Each entry's title, dates, and categories come straight from that vertebra's own `#set document(...)` call.
    `select`, where given, is passed through to every entry this source produces.
  ],

  [`items(filter:, label-name:)`],
  [
    Any `#metadata((...)) <feeds:item>` beacon emitted anywhere in the project, by hand or via the package's own `item(...)` helper, with the metadata value shaped as an entry.
    Rheo compiles a project in one pass, so `items()` sees every beacon in the bundle rather than only those in the calling vertebra.
    Reach for this where the data has no accessor of its own to call, such as a hand-authored page with no registry behind it.
  ],
)

=== Entry fields

A source fills in as much of an entry as it has.
Only `title` is mandatory on the way in; the package resolves the rest, and checks every type it is given, so a wrong value is named against this table rather than surfacing from somewhere inside the XML serializer.

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  table.header[*Field*][*Default*][*Description*],
  [`title`],
  [required],
  [
    A string or content value.
  ],

  [`page`],
  [one of `page`/`url`],
  [
    The entry's page, relative to the HTML build directory, joined onto the feed's `base-url`.
  ],

  [`url`],
  [one of `page`/`url`],
  [
    An absolute URL, where you would rather give one directly than have it built.
    A page-relative path belongs in `page`.
  ],

  [`published`],
  [one of `published`/`updated`],
  [
    A real `datetime(year: ..., month: ..., day: ...)`, never a string.
  ],

  [`updated`],
  [one of `published`/`updated`],
  [
    Falls back to `published` where only that is given.
  ],

  [`id`],
  [the entry's `url`],
  [
    A stable, globally unique string.
    It need not be a URL: where it isn't, an RSS `guid` is emitted with `isPermaLink="false"` so a reader doesn't try to follow it.
  ],

  [`select`],
  [`none`],
  [
    A region selector for this entry's body, passed through to the same mechanism described under #link(<feed-chrome>)[page chrome].
  ],

  [`summary`],
  [`none`],
  [
    A plain-text summary, emitted alongside the body rather than instead of it.
  ],

  [`categories`],
  [`()`],
  [
    An array of strings, even for a single tag: `("note",)` and never `"note"`.
  ],

  [`author`],
  [the feed's `author`],
  [
    A plain name.
  ],
)

== Sourcing from another package

Because a source is only a function, a package that already exposes its own data can be read directly.
`@rheo/rookery`'s labelled notes are the case to reach for first: `ideas(tags:)` hands back an array of every matching note, synchronously, so a source can call it rather than going by way of a beacon.
Rookery's own `href` field is relative to wherever a note happens to be read from, and a source runs at the bundle root, so the leading `../` run has to be stripped first:

```typ
#import "@rheo/feeds:0.1.0": feed, configure
#import "@rheo/rookery:0.5.0": ideas

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

Neither package imports the other: `from-ideas` is a plain function reshaping rookery's own row shape (`href`, `text`, `minted`) into the entry shape `@rheo/feeds` expects (`page`, `title`, `published`).
Reshaping one vocabulary into the other is the project's job, and getting it wrong surfaces at build time as `dictionary does not contain key "page"` --- an error naming the key you asked for rather than the one that exists, so read the accessor's own row shape rather than assuming it matches the entry table above.
The parentheses wrapping the `.filter(...).map(...)` chain are load-bearing, not decorative#footnote[Spread across lines without them, the chained calls fall out of the `#let`'s single expression and back into markup, which typesets as a paragraph of code rather than binding a function.].
`content: none` is required here rather than a preference --- a rookery note's page is minted rather than compiled, so it has no rendered body to splice into an entry, and these entries carry rookery's plain-text `body` as a summary instead.

Anything with its own array-returning accessor becomes a source the same way, in a few lines that reshape its fields into the entry table above.

== Keeping page chrome out of your entries <feed-chrome>

Where a feed's `content` is `"html"` (the default) or `"xhtml"`, an entry's body is spliced in from the page itself, and you want the article rather than the header and navigation sitting around it.
This is Rheo's own default for splicing one page's content into another, and a feed entry is one consumer of it among others.
Wrap the article in `<main>` and keep the chrome outside it:

```typ
#html.elem("main", doc)
```

Where your template already reserves `<main>` for something else, mark the region you want with the `rheo-feed-content` class:

```typ
#html.elem("div", attrs: (class: "rheo-feed-content"), doc)
```

Rheo checks four things in order before giving up: `<main>`, then a generic `.rheo-content` class meant for uses beyond feeds, then this specific `rheo-feed-content` one (kept working as a compatibility alias), then the whole `<body>`.
An entry's own `select` field, where a source sets one, is passed straight through to the same mechanism, letting a source point at a differently-marked region per entry rather than relying on the page-wide default.

== Required fields and silent drops

`title` is required, with no fallback chain.
The retired generator fell back from an explicit title to the HTML spine's own title to the project's directory name; `feed(...)` refuses to build without one.

An entry with no date is dropped rather than dated some other way.
Atom requires `<updated>`, and Typst has no way to read a compiled file's modification time the way the retired generator did, so a `spine()` entry with no `#set document(date: ...)` --- and no `published` or `updated` from anywhere else --- never becomes a feed entry at all.
This doubles as the replacement for the old `rheo-feed-exclude`: an undated cover page or index simply never becomes a candidate.

`<published>` is a genuine addition rather than parity.
The retired generator only ever wrote `<updated>`, whereas an entry with both `published` and `updated` set now gets both elements, with their own distinct values when the two differ.

One trap carries over unchanged: `datetime.today()` resolves to whatever day the build happens to run on, so a page dated with it produces an entry that looks freshly updated on every deploy, forever, to every subscriber.
Give a post's `#set document(date: ...)` a literal `datetime(year: ..., month: ..., day: ...)` instead.

Within one date, entries keep their source's order.
Spine dates are day-granular --- one `#set document(date: ...)` per vertebra --- so two posts published on one day are common, and the feed lists them in the order the source produced them.
Where that matters, give the two posts distinct dates rather than relying on source order.

== Migrating from the retired `[html]` feed keys <feed-migration>

Every `[html]` key and `rheo-*` variable the old generator read has a replacement here.
See #link(<feed-removal>)[Migrating projects] for what 0.6.0 removed and the warnings a build now emits for a retired key.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Retired `rheo.toml` key*][*Here*],
  [`[html] feed_base_url`], [the feed config's `base-url`],
  [`[html] feed_title`], [`title`],
  [`[html] feed_author`], [`author`],
  [`[[html.feed_include]]`], [no longer needed --- a source already lists exactly what it lists],
)

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Retired per-vertebra variable*][*Here*],
  [`#let rheo-feed-title = "..."`], [the entry's `title` --- usually `#set document(title: ...)`, which `spine()` reads back],
  [`#let rheo-feed-updated = "..."`], [`#set document(date: datetime(...))`, or a composed override over a source's output],
  [`#let rheo-feed-exclude = true`], [omit the page from every source's selection, or leave it undated --- either drops it from the feed],
)
