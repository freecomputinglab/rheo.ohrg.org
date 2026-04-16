#import "index.typ": rheobook
#show: rheobook.with(current-page: "format-pdf")

= PDF

#link("https://typst.app/")[Typst], the programming language and compilation toolchain that underwrites Rheo, natively and fully supports PDF.
By default, Rheo generates one PDF per Typst source file in your project -- much like running the Typst compiler directly.

== What Rheo adds

Where Rheo goes beyond the standard Typst CLI is in its ability to merge multiple source files into a single PDF.
This is useful when you want to separate sections of your book into individual files -- for example, so that each section can also appear as its own web page in the HTML output -- while still producing a unified document for print.

By default, Rheo does not use a #link("./spines.typ")[spine] for PDF -- each source file is compiled independently.
You can specify a spine in order to reticulate multiple source documents into a single output PDF by indicating the vertebrae and setting `merge` to `true`:

```toml
[pdf.spine]
title = "My book"
vertebrae = ["intro.typ", "chapters/*.typ"]
merge = true
```

When files are merged in this way, #link("./relative-linking.typ")[relative links] between source files are automatically resolved to internal document links that point to the relevant section in the output PDF.

Rheo also copies any #link("./assets.typ")[assets] matched by your `copy` patterns into the PDF build directory.
