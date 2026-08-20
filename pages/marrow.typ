#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "marrow")

= Marrow

The simple answer is that marrow is a file, `.marrow.typ`, that lets you mint extra output files from a Rheo project beyond the one-page-per-vertebra default.
The less simple answer is that marrow is Typst run at the *bundle root*---outside every `#document(...)` block Rheo synthesizes for your ordinary pages---where the native Typst `document()` and `asset()` elements are legal to call directly.
Derived artifacts like feeds, sitemaps, search indexes, and generated index pages belong in Typst rather than in a Rust plugin, and marrow is the seam that makes that possible: Rheo's job is only to provide the primitives, not to own every output file itself.

== Writing a marrow file

Drop a file named `.marrow.typ` at the top of your content directory, next to your ordinary pages, and Rheo inlines its text at the bundle root on every build.
Inside it, and only there, `document()` and `asset()` are in scope:

```typ
#document("extra/hello.html", format: "html", title: [Extra])[Hello from the bundle root.]
#asset("extra/hello.txt", "root-level asset")
```

Compiling this produces `extra/hello.html` and `extra/hello.txt` in your build output, sitting alongside whatever your ordinary vertebrae produce.
`document()` mints a page; `asset()` writes bytes verbatim, with no Typst compilation of its own.

If you'd rather call the file something else, set the top-level `marrow` key in `rheo.toml`, resolved against `content_dir` exactly like any other content path:

```toml
marrow = "bundle-root.typ"
```

Whatever it's named, a marrow file is never a vertebra in its own right.
It produces no `.marrow.html` of its own, and it never appears in the #link(<spines>)[spine], the sidebar navigation, or a template's prev/next pager---only the pages it explicitly mints with `document()` do.

== When marrow runs

Marrow runs once per *per-page* output format---HTML, EPUB---on every compile and every dev-server rebuild.
The combined PDF target skips it entirely, because `document()` and `asset()` both hard-error there: Typst reserves them for the bundle target, and a combined PDF has no bundle to speak of.

A page marrow mints is still a first-class Rheo page in every other sense.
It receives the same head-asset injection as an ordinary vertebra---a minted `extra/hello.html` carries `<link rel="stylesheet" href="../rheo-default.css">`, with the relative path adjusted for its own depth in the output tree---and any root-level `#set`/`#show` rule from your template still applies inside it.

== Reading across the bundle

A Rheo bundle compiles in a single Typst pass, and Typst's own bundle mechanism shares one introspector across every file in it.
That means marrow can read `state(...)` and query labels registered by ordinary vertebrae elsewhere in the project, which is the actual reason the feature exists: it lets a package or project turn data scattered across many pages into pages of its own, without a stub `.typ` file per entry.
The shape looks like this:

```typ
#context {
  for n in state("notes", ()).final() {
    document("notes/" + n.name + ".html", format: "html", title: [Note])[#n.body]
  }
}
```

Any vertebra elsewhere in the project registers into `"notes"` however it likes---`state("notes", ()).update(old => old + (my-note,))`, say---and marrow mints one page per entry once the whole bundle has been seen.
This is also `@rheo/feeds`'s own trick for minting an Atom feed with no Rust code, no plugin, and no `rheo.toml` keys of its own: packages configure it by registering into a state, and its own marrow file does the minting.

Two things are worth knowing about the limits of this introspection.
First, Typst has no facility for enumerating files on disk, so marrow can never discover content by scanning your project directory itself---only by reading `state`, labels, or `sys.inputs.rheo-context`, all of which have to have been populated by something else in the bundle first.
Second, a `#show` rule written inside marrow only affects content declared *after* it---in practice, the pages marrow itself goes on to mint---and does not reach back into vertebrae that already exist elsewhere in the project, because marrow is spliced in after every ordinary page, not before it.

== Packages can contribute marrow too

A Typst package can ship its own `.marrow.typ` at the root of the package, and Rheo inlines it exactly as it would your project's own---no `rheo.toml` entry, no manifest key in `typst.toml`, nothing to configure.
Importing the package anywhere in your project is the only trigger.
Every imported package's marrow is inlined first, in import order, and your project's own marrow is spliced in last, on top of whatever they've registered---all of them, every time, so renaming your project's marrow file can never silently suppress a package's contribution, or the other way around.

If you'd rather turn all of this off, setting `[html] auto_detect_packages = false` disables every form of automatic package-driven behaviour that importing a package can trigger---marrow included, alongside the automatic asset injection described in #link(<packages>)[Packages].

There is one sharp edge worth knowing if you're writing a package's marrow yourself.
Its text is spliced verbatim into *your project's* bundle root, so any relative path inside it resolves against the project root---not `content_dir`, and not the package's own directory on disk.
A package's marrow therefore has to reach its own code by package spec, `#import "@namespace/name:version"`, never by a relative import: a relative path that looks like it points at the package's own files will instead be resolved against whatever the importing project happens to keep there.

== EPUB

Marrow's `document()` and `asset()` calls both work under EPUB compilation as well as HTML.
A minted page is packaged into the EPUB container as an ordinary file, but---in keeping with marrow never producing a vertebra---it does not join the book's reading order (`package.opf`'s spine) or its `nav.xhtml` table of contents.
A minted `asset()`, unlike its HTML counterpart, is embedded directly inside the EPUB container with its own manifest entry, rather than being written as a loose file beside the `.epub` itself.

== Talking to compiled pages

Marrow runs inside the same Typst compile as every ordinary vertebra, but it runs before any of their HTML exists---Typst's `html` module can build elements and frames, but it has no function that turns a compiled document back into an HTML string.
That is a problem the moment a marrow-minted artifact wants to carry another page's actual content: an Atom entry's `<content>`, a search index's stored body, an excerpt on a generated listing page.
Rheo closes the gap with a placeholder element, resolved once every ordinary page has actually compiled, inside any bundle-emitted asset a marrow file mints with `asset(...)`:

```typ
<rheo-content page="notes/etal.html" select="main" as="escaped"/>
```

`page` is required, and names another vertebra's compiled output path---`notes/etal.html`, not `notes/etal.typ`.
`select` picks the region of that page to pull in: a bare tag name (`main`, `article`), or a leading-dot class (`.rheo-content`).
Left out, Rheo falls back to a cascade, first match wins: the page's `<main>` element, else the first element carrying the `rheo-content` class, else---kept working, but not the name to reach for freshly---the first element carrying `rheo-feed-content`, else the whole `<body>`.#footnote[The compatibility step exists because Rheo's Rust feed generator, retired in the move to `@rheo/feeds`, used `rheo-feed-content` for the same idea under a different name; a template still wrapping its article region that way keeps working exactly as it always did. #link(<atom-feeds>)[Feeds] tells that story in full.]
`as` chooses how the selected HTML lands in your asset text: `escaped` (the default, entity-escaping `&`/`<`/`>`, for an Atom `<content type="html">`), `raw` (verbatim, for `<content type="xhtml">`), or `json` (escaped as the body of a JSON string instead---quotes and control characters, not markup---for a JSON Feed's `content_html`).

A placeholder only resolves inside an asset marrow itself mints, never inside an ordinary vertebra's own page body, which has no reason to reach for another page's HTML this way in the first place.
An author wanting a clean `select` target writes it the same way they always would, by wrapping the region that matters and leaving the chrome outside it:

```typ
#html.elem("nav", [Site chrome.])
#html.elem("main", html.elem("p", [The actual words of this page.]))
```

and mints the asset that reaches for it elsewhere in the bundle:

```typ
#asset(
  "excerpt.xml",
  "<entry><body><rheo-content page=\"notes/etal.html\"/></body></entry>",
)
```

One more thing worth stating outright if you ever write the placeholder inside a JSON string by hand: JSON has no way to hold a bare `"`, so the attribute quotes have to be backslash-escaped (`page=\"notes/etal.html\"`) to keep the surrounding asset parseable, and Rheo un-escapes them before reading the tag.

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
