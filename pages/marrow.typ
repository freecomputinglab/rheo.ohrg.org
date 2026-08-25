#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "marrow")

= Marrow

Rheo projects treat `.marrow.typ` as a special file that allows you to programmatically generate extra files beyond the one-page-per-vertebra default.
In contrast to vertebrae, which are treated as normal Typst compiled to PDF or HTML, marrow is Typst run at the #link("https://typst.app/docs/reference/bundle/")[bundle root], meaning that you can write Typst in it to generate new documents and assets.
You can use marrow to programmatically derive artifacts such as feeds, sitemaps, search indexes, and generated pages.

== Crafting marrow

Create a file named `.marrow.typ` at the top of your content directory, next to your ordinary pages.
Inside this file (and only there), `document()` and `asset()` are in scope:

```typ
#document("extra/hello.html", format: "html", title: [Extra])[Hello from the bundle root.]
#asset("extra/hello.txt", "root-level asset")
```

Compiling this produces `extra/hello.html` and `extra/hello.txt` in your build output, sitting alongside whatever your ordinary vertebrae produce.
For more information on what is valid Typst in marrow, see the #link("https://typst.app/docs/reference/bundle/")[Typst bundle documentation].

If you'd rather call the file something else, set the top-level `marrow` key in `rheo.toml`, resolved against `content_dir` in `rheo.toml`:

```toml
marrow = "bundle-root.typ"
```

Note that marrow will never produce a `.marrow.html` of its own, and it never appears in the #link(<spines>)[spine], the sidebar navigation, or a template's prev/next pager.

Marrow runs once per *per-page* output format on every compile and every dev-server rebuild.
The combined PDF target skips it entirely, because `document()` and `asset()` both hard-error there.
Typst reserves them for the bundle target, and a combined PDF has no bundle to speak of.

A page marrow mints is still a first-class Rheo page in every other sense.
It receives the same head-asset injection as an ordinary vertebra, and any root-level `#set`/`#show` rule from your template still applies inside it.

== Reading across the spine

A Rheo bundle compiles in a single Typst pass, and Typst's own bundle mechanism shares one introspector across every file in it.
That means marrow can read `state(...)` and query labels registered by ordinary vertebrae elsewhere in the project.
Marrow thus lets a package or project turn data scattered across many pages into pages of its own, without a stub `.typ` file per entry:

```typ
// across various vertebrae in the spine...
#state("notes", ()).update(old => old + (my-note,))

// in .marrow.typ
#context {
  for n in state("notes", ()).final() {
    document("notes/" + n.name + ".html", format: "html", title: [Note])[#n.body]
  }
}
```

Typst has no facility for enumerating files on disk, so marrow can never discover content by scanning your project directory itself---only by reading `state`, labels, or `sys.inputs.rheo-context`, all of which have to have been populated by something else in the bundle first.

// A `#show` rule written inside marrow only affects content declared *after* it---in practice, the pages marrow itself goes on to mint---and does not reach back into vertebrae that already exist elsewhere in the project, because marrow is spliced in after every ordinary page, not before it.

== Using beacons

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

== Reaching into every page's head

Typst builds a page's `<head>` from `#set document(...)` alone---title, description, and the handful of other fields Rheo already reads back through `metadata-of`---so there is no native hook for putting anything else there at all.
Marrow adds two routes in, one per-page and one site-wide.

A `<rheo-head>` wrapper, written anywhere in a page's own body, has its children hoisted into that page's `<head>` when the page compiles, and the wrapper itself vanishes without a trace:

```typ
#html.elem("rheo-head", html.elem("link", attrs: (rel: "canonical", href: "https://example.com/a.html")))
```

It can sit at the top of the body, the bottom, or buried in the middle of your prose---the hoist doesn't care where it is, only that it exists---and several wrappers on the same page hoist their children into `<head>` in the same order they appeared in the body.
This is the route for something that belongs to one page alone: a canonical link, an Open Graph image, a page-specific stylesheet override.

For something every page ought to carry, marrow mints `.rheo/head.html` instead---an HTML fragment with no wrapping `<html>`/`<head>`/`<body>` of its own, whose top-level elements are appended to *every* compiled page's `<head>`, after whatever that page's own `<rheo-head>` wrappers already hoisted in:

```typ
#asset(
  ".rheo/head.html",
  "<link rel=\"alternate\" type=\"application/atom+xml\" href=\"https://example.com/feed.xml\" title=\"My Site\">",
)
```

This is the whole mechanism behind a feed's autodiscovery link showing up on every page of a site without anyone visiting each vertebra to add it by hand.
Both routes are HTML-only for now; there is no EPUB equivalent of a page `<head>` for either of them to hoist into.

== Control assets

The `.rheo/` output prefix, seen above, is reserved outright: an `asset()` minted under it is not a file for a reader at all, but a message from the bundle to Rheo itself, consumed while compiling and never written to a plugin's actual build output.
`.rheo/head.html` is the only member Rheo currently understands---the site-wide route from the previous section---and a name it doesn't recognise still gets pulled out and dropped rather than written somewhere unexpected, with a warning in the build log rather than silence.
That matters most when a package ships a `.rheo/*` convention your installed Rheo predates: the safe assumption is that an unrecognised member simply does nothing yet, not that it has leaked into your output somewhere you haven't checked.
The one guarantee this carries into EPUB, echoing the section above: everything under `.rheo/` stays out of the container exactly as it stays out of an HTML build's output directory, dropped before either builder ever sees it.

== Who these primitives are for

Almost nobody writes any of the three above directly.
They exist so that a package can, and `@rheo/feeds` is the concrete case: it mints an Atom, RSS, or JSON feed entirely from its own `.marrow.typ`, using `rheo-metadata-all` to read every vertebra's title and date, `<rheo-content>` to carry each entry's real body across from the compiled page, and `.rheo/head.html` to drop one autodiscovery link onto every page of your site in a single call.
Put small-scale, that whole shape is just the last two examples above, side by side in the same marrow file:

```typ
#asset(
  "feed.xml",
  "<feed>"
  + "<entry><content type=\"html\"><rheo-content page=\"notes/etal.html\"/></content></entry>"
  + "</feed>",
)

#asset(
  ".rheo/head.html",
  "<link rel=\"alternate\" type=\"application/atom+xml\" href=\"https://example.com/feed.xml\">",
)
```

one call mints a real file with another page's real HTML embedded inside it, the other whispers into every page's `<head>` so a reader's newsreader finds it without them ever checking by hand.
#link(<atom-feeds>)[Feeds] documents `@rheo/feeds`'s own configuration surface end to end, and is the page to read next if that package is what brought you here rather than marrow itself.
Reach for these three directly only when what you need isn't something a package like it already covers.
