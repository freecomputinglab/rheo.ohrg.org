#import "index.typ": rheobook
#show: rheobook.with(current-page: "formats")

= Formats

Since v0.2.0, Rheo has a plugin architecture, meaning that it can produce an arbitrary number of formats.
By default, Rheo produces three different formats simultaneously: *PDF*, *HTML*, and *EPUB*.
There are cases in which you may only want to produce one of these formats, however, or to exclude one format because your project either cannot support or does not require it. 

== PDF 

#link("https://typst.app/")[Typst], the programming language and compilation toolchain that underwrites Rheo, natively and fully supports PDF. 
Rheo adds the additional ability to merge multiple different Typst files into a single PDF.
This is useful when you want to separate sections of your book in individual files, or show the sections of your book as separate web pages in the HTML output. 

== HTML 

Typst #link("https://typst.app/docs/reference/html/")[experimentally supports] HTML.
This means that not all Typst syntax will translate to a meaningful HTML structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.
For more information on which features are currently supported in Typst's HTML export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

Rheo's HTML format provides additional utilities for referencing CSS and Javascript in the built site, as well as passing through assets.#footnote[Note that there is an experimental #link("https://github.com/typst/typst/pull/7964")[bundle format] in upstream Typst which allows you to achieve similar results. We are tracking this closely, but for the time being have not incorporated this feature/format into Rheo on account of some critical deficiencies such as #link("https://github.com/typst/typst/issues/1097")[the inability to have multiple bibliographies in the same source file].]

== EPUB 

Typst does #link("https://github.com/typst/typst/issues/188")[not yet support] EPUB.
The Rheo EPUB format bridges the gap to this, allowing you to compile fully functional EPUB documents from a Rheo project directory.
As EPUB export is on Typst's roadmap, we will track this feature closely in the upstream and look to integrate with it when it lands in the future.

== Configuration
=== CLI flag
You can constrain Rheo to producing one or more formats by passing one or more of the following flags to `compile` or `watch`:

```bash
rheo compile path/to/project --pdf
rheo compile path/to/project --html
rheo compile path/to/project --epub
```

=== `rheo.toml` 
You can also specify formats at the top level of `rheo.toml` in an array that contains one or more formats.
The default, if `formats` is not specified, is an array with all three formats:

```toml
formats = ["pdf", "html", "epub"] 
```


