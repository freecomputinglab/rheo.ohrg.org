#import "index.typ": rheobook
#show: rheobook.with(current-page: "format-epub")

= EPUB

Typst does #link("https://github.com/typst/typst/issues/188")[not yet support] EPUB.
The Rheo EPUB format bridges the gap, allowing you to compile fully functional EPUB documents from a Rheo project directory.
As EPUB export is on Typst's roadmap, we will track this feature closely in the upstream and look to integrate with it when it lands in the future.

== What Rheo provides

Unlike the PDF and HTML formats, EPUB always produces a single merged output from your project.
Rheo handles the full EPUB packaging pipeline: it converts your Typst source files to XHTML, generates a table of contents from your document headings, and bundles everything into a standards-compliant EPUB archive.

The #link("./spines.typ")[spine] determines which files are included and in what order.
If you don't specify one, Rheo infers a default spine that includes all Typst files in the project:

```toml
[epub.spine]
title = "My book"
vertebrae = ["intro.typ", "chapters/*.typ"]
```

The `title` field sets the EPUB's metadata title.
Rheo also generates a unique identifier for the document and populates other metadata fields such as language and publication date.

#link("./relative-linking.typ")[Relative links] between source files are resolved to internal links that navigate between sections in the EPUB.
