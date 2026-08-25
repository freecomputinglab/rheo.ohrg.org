#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "beacons")

= Using beacons

Marrow runs inside the same Typst compile as every ordinary vertebra, but it runs before any of their HTML exists.
This is a problem if you want to interpolate a page's _compiled_ content into some asset that you program using marrow, such as an Atom entry's `<content>` or a search index's stored body.
Rheo therefore allows you to specify a placeholder element called a *beacon*, which is resolved only once every ordinary page has actually compiled in a post-compilation pass:

```typ
<rheo-content page="notes/etal.html" select="main" as="escaped"/>
```

// `page` is required, and names another vertebra's compiled output path---`notes/etal.html`, not `notes/etal.typ`.
// `select` picks the region of that page to pull in: a bare tag name (`main`, `article`), or a leading-dot class (`.rheo-content`).
// Left out, Rheo falls back to a cascade, first match wins: the page's `<main>` element, else the first element carrying the `rheo-content` class, else---kept working, but not the name to reach for freshly---the first element carrying `rheo-feed-content`, else the whole `<body>`.#footnote[The compatibility step exists because Rheo's Rust feed generator, retired in the move to `@rheo/feeds`, used `rheo-feed-content` for the same idea under a different name; a template still wrapping its article region that way keeps working exactly as it always did. #link(<atom-feeds>)[Feeds] tells that story in full.]
// `as` chooses how the selected HTML lands in your asset text: `escaped` (the default, entity-escaping `&`/`<`/`>`, for an Atom `<content type="html">`), `raw` (verbatim, for `<content type="xhtml">`), or `json` (escaped as the body of a JSON string instead---quotes and control characters, not markup---for a JSON Feed's `content_html`).
//
// A placeholder only resolves inside an asset marrow itself mints, never inside an ordinary vertebra's own page body, which has no reason to reach for another page's HTML this way in the first place.
// An author wanting a clean `select` target writes it the same way they always would, by wrapping the region that matters and leaving the chrome outside it:


You can specify a beacon in marrow like so:

```typ
#asset(
  "excerpt.xml",
  "<entry><body><rheo-content page=\"notes/etal.html\"/></body></entry>",
)
```
