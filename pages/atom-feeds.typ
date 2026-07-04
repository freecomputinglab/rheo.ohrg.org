#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "atom-feeds")

= Atom feeds

Rheo can generate an #link("https://en.wikipedia.org/wiki/Atom_(Web_standard)")[Atom] feed for your site so that readers can subscribe to new pages in a feed reader.
Enable it by setting `feed_base_url` under `[html]`.
When set, the HTML build writes `build/html/feed.xml` (Atom 1.0) and injects an Atom autodiscovery `<link>` into the `<head>` of every page:

```toml
[html]
feed_base_url = "https://example.com"
```

The feed contains one `<entry>` per vertebra by default (see #link(<rheo-variables>)[the variables below] to override entry metadata or opt a page out).
Two further `[html]` fields customize the feed itself:

- `feed_author` --- the feed's author. Defaults to `Rheo`.
- `feed_title` --- the feed's title and the title shown in the autodiscovery link. Defaults to the HTML spine title, then the project name.

Without `feed_base_url`, no feed is emitted.

== Feed variables <rheo-variables>

Every vertebra appears in the feed by default.
To tune how a page is represented, set any of these top-level variables in its source; Rheo reads them when composing the feed. All are optional:

- `rheo-feed-title` --- overrides the entry's title. Defaults to the document title from `#set document(title: ...)`.
- `rheo-feed-updated` --- overrides the entry's timestamp, in #link("https://www.rfc-editor.org/rfc/rfc3339")[RFC 3339] format. Defaults to the document date from `#set document(date: ...)`, then the source file's modification time.
- `rheo-feed-exclude` --- set to the boolean `true` to omit this vertebra from the feed (its page is still generated). Handy for cover or index pages.

```typst
#let rheo-feed-title = "A new chapter"
#let rheo-feed-updated = "2026-06-29T12:00:00Z"
#let rheo-feed-exclude = true
```

The body of each entry is taken from the first `<main>` element in the page, else the first element carrying the `rheo-feed-content` class, else the entire `<body>`.
To keep page chrome such as headers and navigation out of your feed entries, wrap the article in `<main>` (for example `html.elem("main", doc)`) and keep the chrome outside it; with no marker, the full body is used.
As an alternative to `<main>`---useful when your template already reserves `<main>` for another purpose, or when the feed content is not the page's main landmark---mark the element you want included with the `rheo-feed-content` class (for example `html.elem("div", attrs: (class: "rheo-feed-content"), doc)`).
The generator prefers `<main>` first, then the first element carrying `rheo-feed-content`, then the entire `<body>`.
