#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "head-control")

= Head control

A `<rheo-head>` element written anywhere in a page's body has its children hoisted into that page's `<head>` when the page compiles, and the wrapper itself disappears from the output:

```typ
#html.elem("rheo-head", html.elem("link", attrs: (rel: "canonical", href: "https://example.com/a.html")))
```

The `<rheo-head>` element could sit at the top of the body, the bottom, or halfway through your prose.
Multiple `<rheo-head>`s on one page will be hoisted in the order they appear.

== `.rheo/head.html` for every page

For something every page's head ought to carry, you can specify a `.rheo/head.html` from your project's #link(<marrow>)[marrow].
This is an HTML fragment with no wrapping (`<html>`/`<head>`/`<body>`), and its top-level elements are appended to *every* compiled page's `<head>`, after whatever that page's own `<rheo-head>` wrappers already hoisted in:

```typ
#asset(
  ".rheo/head.html",
  "<link rel=\"alternate\" type=\"application/atom+xml\" href=\"https://example.com/feed.xml\" title=\"My Site\">",
)
```

== Control assets

The `.rheo/` output prefix is reserved.
An asset created in this folder should be considered a message from the bundle to Rheo itself.
It will be consumed while compiling, but never written to a format's build output.

This matters most when a package ships a `.rheo/*` convention your installed Rheo predates: an unrecognised member simply does nothing yet, and it has not leaked into your output somewhere you haven't checked.
Everything under `.rheo/` stays out of an EPUB container exactly as it stays out of an HTML build's output directory, dropped before either builder sees it.
#link(<atom-feeds>)[`@rheo/feeds`] uses it, for example, to drop one autodiscovery link onto every page of your site in a single call.

