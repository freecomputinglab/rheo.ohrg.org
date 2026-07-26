#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "format-pdf")

= PDF

#link("https://typst.app/")[Typst], the programming language and compilation toolchain that underwrites Rheo, natively and fully supports PDF.

== One PDF from many files

Where the Typst CLI compiles a single file, Rheo 'reticulates' every source file in your project into one unified PDF.
This lets you keep each section of your book in its own file --- so that a section can double as its own web page in the HTML output --- while still producing a single document for print.

The PDF format always produces a single combined document: every source file in its #link(<spines>)[spine] is merged into one output PDF, in directory-scan order.
Give the combined document a title, and narrow which files are included with `exclude`:

```toml
[pdf.spine]
title = "My book"
exclude = ["drafts/**"]
```

Because the source files are combined, #link(<relative-linking>)[relative links] between them are automatically resolved to internal document links that point to the relevant section in the output PDF.

Rheo also copies any #link(<assets>)[assets] matched by your `copy` patterns into the PDF build directory.
