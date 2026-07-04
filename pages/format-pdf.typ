#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "format-pdf")

= PDF

#link("https://typst.app/")[Typst], the programming language and compilation toolchain that underwrites Rheo, natively and fully supports PDF.

== What Rheo adds

Where Rheo goes beyond the standard Typst CLI is in its ability to reticulate multiple source files into a single, unified PDF.
This is useful when you want to separate sections of your book into individual files -- for example, so that each section can also appear as its own web page in the HTML output -- while still producing a unified document for print.

The PDF format always produces a single combined document: every source file is merged into one output PDF.
You can specify a #link(<spines>)[spine] to control which files are included and in what order:

```toml
[pdf.spine]
title = "My book"
vertebrae = ["intro.typ", "chapters/*.typ"]
```

PDF always combines the spine into a single document by default, so there is nothing extra to configure.

Because the source files are combined, #link(<relative-linking>)[relative links] between them are automatically resolved to internal document links that point to the relevant section in the output PDF.

Rheo also copies any #link(<assets>)[assets] matched by your `copy` patterns into the PDF build directory.
