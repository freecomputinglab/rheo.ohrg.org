#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "format-html")

= HTML

Typst #link("https://typst.app/docs/reference/html/")[experimentally supports] HTML.
This means that not all Typst syntax will translate to a meaningful HTML structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.
For more information on which features are currently supported in Typst's HTML export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

== What Rheo adds

Where the Typst CLI produces a single HTML file, Rheo turns your project into a fully functional static site.
Each Typst source file becomes its own HTML page, and #link(<relative-linking>)[relative links] between files are automatically rewritten from `.typ` to `.html` so that navigation works in the browser.

Rheo also provides a development server with live reloading when you use the `watch` command, so you can see changes in the browser as you edit your source files:

```bash
rheo watch my-project --html --open
```

The HTML format supports configurable #link(<custom-js-css>)[CSS and JavaScript] entrypoints, as well as #link(<assets>)[asset copying] for additional files your site needs.
These entrypoints are also the mechanism through which reading augmentations can be delivered -- the #link("https://github.com/freecomputinglab/rheo/tree/main/examples/tooltip_html")[tooltip example], for instance, uses a custom Typst function and a JavaScript entrypoint to provide inline tooltips in the HTML output.#footnote[Note that there is an experimental #link("https://github.com/typst/typst/pull/7964")[bundle format] in upstream Typst which allows you to achieve similar results. We are tracking this closely, but for the time being have not incorporated this feature/format into Rheo on account of some critical deficiencies such as #link("https://github.com/typst/typst/issues/1097")[the inability to have multiple bibliographies in the same source file].]

You can customize which files are included in the HTML output using a #link(<spines>)[spine].
By default, Rheo compiles all Typst files in the project; you can narrow this if you want to exclude certain files from the site:

```toml
[html.spine]
vertebrae = ["index.typ", "about.typ", "posts/*.typ"]
```

== Atom feeds

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
