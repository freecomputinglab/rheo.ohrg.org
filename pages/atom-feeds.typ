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

The feed contains one `<entry>` per vertebra that declares a feed title (see #link(<rheo-variables>)[the variables below]).
Two further `[html]` fields customize the feed itself:

- `feed_author` --- the feed's author. Defaults to `Rheo`.
- `feed_title` --- the feed's title and the title shown in the autodiscovery link. Defaults to the HTML spine title, then the project name.

Without `feed_base_url`, no feed is emitted.

== rheo-\* variables <rheo-variables>

Rheo harvests any top-level `#let` whose name begins with `rheo-` from each source file, provided its value is a string literal --- a non-string value is a compile error.
Plugins read these per-file values with the `rheo-` prefix stripped, so `rheo-feed-title` is available to a plugin as `feed-title`.

The Atom feed uses two such variables:

- `rheo-feed-title` --- the entry's title. A vertebra must declare this to appear in the feed.
- `rheo-feed-updated` --- the entry's timestamp in #link("https://www.rfc-editor.org/rfc/rfc3339")[RFC 3339] format. Optional; falls back to the source file's modification time.

```typst
#let rheo-feed-title = "A new chapter"
#let rheo-feed-updated = "2026-06-29T12:00:00Z"
```

The body of each entry is taken from the first `<main>` element in the page, else the first element carrying the `rheo-feed-content` class, else the entire `<body>`.
To keep page chrome such as headers and navigation out of your feed entries, wrap the article in `<main>` (for example `html.elem("main", doc)`) and keep the chrome outside it; with no marker, the full body is used.
As an alternative to `<main>`---useful when your template already reserves `<main>` for another purpose, or when the feed content is not the page's main landmark---mark the element you want included with the `rheo-feed-content` class (for example `html.elem("div", attrs: (class: "rheo-feed-content"), doc)`).
The generator prefers `<main>` first, then the first element carrying `rheo-feed-content`, then the entire `<body>`.
