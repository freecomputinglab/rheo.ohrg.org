#import "index.typ": typbook 
#show: typbook.with(current-page: "formats")

= Formats

By default, rheo produces three different output formats simultaneously: *pdf*, *html*, and *epub*.
There are cases in which you may only want to produce one of these formats, however, or to exclude one format because your project cannot support or does not require it. 

== pdf 

The pdf format is natively and fully supported by #link("https://typst.app/")[typst], the programming language and compilation toolchain that underlies rheo. 

== html 

The html format is #link("https://typst.app/docs/reference/html/")[experimentally supported] by typst.
This means that not all typst syntax will translate to a meaningful html structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.For more information on which features are currently supported in html export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

== epub 

The epub format is #link("https://github.com/typst/typst/issues/188")[not yet supported] in upstream typst, but is experimentally supported in rheo.
As epub export is on typst's roadmap, rheo will track this feature closely and look to integrate with it when it lands in the future.

== Configuration
=== CLI flag
You can constrain rheo to producing one or more formats by passing one or more of the following flags to `compile` or `watch`:

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


