#import "index.typ": rheobook 
#show: rheobook.with(current-page: "formats")

= Formats

By default, Rheo produces three different output formats simultaneously: *PDF*, *HTML*, and *EPUB*.
There are cases in which you may only want to produce one of these formats, however, or to exclude one format because your project either cannot support or does not require it. 

== PDF 

#link("https://typst.app/")[Typst], the programming language and compilation toolchain that underwrites Rheo, natively and fully supports PDF. 

== HTML 

Typst #link("https://typst.app/docs/reference/html/")[experimentally supports] HTML.
This means that not all Typst syntax will translate to a meaningful HTML structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.
For more information on which features are currently supported in Typst's HTML export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

== EPUB 

Typst does #link("https://github.com/typst/typst/issues/188")[not yet support] EPUB, but it is supported in Rheo.
As EPUB export is on Typst's roadmap, Rheo will track this feature closely and look to integrate with it when it lands in the future.

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


