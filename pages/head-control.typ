#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "head-control")

= Head control

Typst builds a page's `<head>` from `#set document(...)` alone --- title, description, and the handful of other fields Rheo reads back through #link(<rheo-context>)[`metadata-of`] --- so there is no native hook for putting anything else there.
Rheo adds two routes of its own, one per-page and one site-wide.
Both are HTML-only: there is no EPUB equivalent of a page `<head>` for either of them to write into.

== `<rheo-head>` for a single page

A `<rheo-head>` element written anywhere in a page's body has its children hoisted into that page's `<head>` when the page compiles, and the wrapper itself disappears from the output:

```typ
#html.elem("rheo-head", html.elem("link", attrs: (rel: "canonical", href: "https://example.com/a.html")))
```

The hoist doesn't care where the wrapper sits --- the top of the body, the bottom, or halfway through your prose --- and several wrappers on one page hoist their children in the order they appeared.
This is the route for something belonging to a single page: a canonical link, an Open Graph image, a page-specific stylesheet override.

== `.rheo/head.html` for every page

For something every page ought to carry, mint `.rheo/head.html` from your project's #link(<marrow>)[marrow] instead.
It is an HTML fragment with no wrapping `<html>`/`<head>`/`<body>` of its own, and its top-level elements are appended to *every* compiled page's `<head>`, after whatever that page's own `<rheo-head>` wrappers already hoisted in:

```typ
#asset(
  ".rheo/head.html",
  "<link rel=\"alternate\" type=\"application/atom+xml\" href=\"https://example.com/feed.xml\" title=\"My Site\">",
)
```

This is how a feed's autodiscovery link reaches every page of a site without anyone editing each vertebra by hand.

== Control assets

The `.rheo/` output prefix is reserved.
An `asset()` minted under it is not a file for a reader at all, but a message from the bundle to Rheo itself, consumed while compiling and never written to a format's build output.
`.rheo/head.html` is the only member Rheo currently understands.
A name it doesn't recognise is pulled out and dropped rather than written somewhere unexpected, with a warning in the build log rather than silence.

This matters most when a package ships a `.rheo/*` convention your installed Rheo predates: an unrecognised member simply does nothing yet, and it has not leaked into your output somewhere you haven't checked.
Everything under `.rheo/` stays out of an EPUB container exactly as it stays out of an HTML build's output directory, dropped before either builder sees it.

== Who these routes are for

Almost nobody reaches for either route directly; they exist so that a package can.
#link(<atom-feeds>)[`@rheo/feeds`] is the concrete case: it mints `.rheo/head.html` to drop one autodiscovery link onto every page of your site in a single call, alongside a #link(<beacons>)[beacon] per entry to carry each page's compiled body across, and `rheo-metadata-all` to read every vertebra's title and date.

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

One call mints a real file with another page's real HTML embedded inside it; the other writes into every page's `<head>` so a reader's newsreader finds it.
Reach for `<rheo-head>` or `.rheo/head.html` yourself when what you need is a page's own metadata rather than something a package like #link(<atom-feeds>)[`@rheo/feeds`] already covers.
