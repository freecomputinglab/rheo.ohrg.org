#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "format-epub")

= EPUB

EPUB is, in our view, the most promising document format for the future of digital reading.
It combines the portability of PDF -- a document encapsulated in a single file that renders reliably -- with the flexibility of HTML -- dynamic layout that adapts to different screens, and the ability to support interactivity and extensions.#footnote[For more on why we believe EPUB deserves wider adoption, see #link("https://willcrichton.net/notes/portable-epubs/")[Portable EPUBs].]

Typst does #link("https://github.com/typst/typst/issues/188")[not yet support] EPUB.
The Rheo EPUB format bridges the gap, letting you compile EPUB documents straight from a Rheo project directory.
As EPUB export is on Typst's roadmap, we will track this feature closely in the upstream and look to integrate with it when it lands in the future.

== How Rheo builds an EPUB

Unlike the PDF and HTML formats, EPUB always produces a single merged output from your project.
Rheo handles the whole packaging pipeline: it converts your Typst source files to XHTML, generates a table of contents from your document headings, and bundles everything into an EPUB archive that validates against the spec.

Math renders the same way it does in #link(<format-html>)[HTML output] --- straight to MathML, both inline and display --- and Rheo goes one step further here than it does for HTML: any XHTML file that ends up containing MathML gets marked with the `mathml` property in the EPUB manifest, as the EPUB 3 spec requires for reading systems to render it correctly.

The #link(<spines>)[spine] determines which files are included and in what order.
An EPUB must have a spine in order to be valid; if you don't specify one, Rheo infers a default from the directory-scan order.
Give the EPUB a title and narrow the included files with `exclude`:

```toml
[epub.spine]
title = "My book"
exclude = ["drafts/**"]
```

The `title` field sets the EPUB's metadata title.
Rheo also generates a unique identifier for the document and populates other metadata fields such as language and publication date, though both the identifier and the date are yours to set explicitly under `[epub]` if the auto-generated versions don't suit --- a stable identifier matters if you're distributing revisions of the same book and want reading systems to recognise them as the same work across updates:

```toml
[epub]
identifier = "urn:isbn:9780000000000"
date = 2024-01-24T00:00:00Z
```

Leave either out and Rheo falls back to its defaults: a freshly generated `urn:uuid:...` for the identifier, and no `dc:date` element at all for the date.#footnote[The date has to be a full TOML offset date-time, not a bare date --- Rheo parses it as RFC 3339, and a plain `2024-01-24` with no time or offset attached fails that parse and is silently dropped rather than erroring.]

#link(<relative-linking>)[Relative links] between source files are resolved to internal links that navigate between sections in the EPUB.

Although the EPUB is a single merged archive, it is bundled from one output page per source file, and by default Rheo resets the footnote counter to `1` at the start of every page, so each section numbers its footnotes independently.
Set `reset_footnotes = false` under `[epub]` to let footnotes accumulate continuously across the whole book instead:

```toml
[epub]
reset_footnotes = false
```

== Detecting the EPUB target

EPUB compiles through Typst's HTML target, so Typst's native `target()` returns `"html"` for both HTML and EPUB output -- the two are indistinguishable to standard Typst.
Rheo synthesizes an extra value so you can tell them apart: inside an EPUB build, `target()` returns `"epub"`.

```typ
#context if target() == "epub" {
  // EPUB-only markup
} else if target() == "html" {
  // plain HTML output
}
```

Rheo polyfills `target()` to report one of three values: `"paged"` (PDF), `"html"` (HTML), and `"epub"` (EPUB).
