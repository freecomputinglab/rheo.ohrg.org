#import "index.typ": rheobook
#show: rheobook.with(current-page: "spines")

= Spines

A spine in Rheo is the backbone or 'table of contents' of Typst source files that should be compiled to an output format.
It takes its name from the #link("https://www.edrlab.org/open-standards/anatomy-of-an-epub-3-file/")[epub specification], in which the spine articulates---or _reticulates_--- the set and order of chapters included.

You can specify a spine's vertebrae for any output format using an array of #link("https://www.man7.org/linux/man-pages/man7/glob.7.html")[glob] strings in `rheo.toml`:

```toml
[epub.spine]
title = "My epub"
vertebrae = ["intro.typ", "*.typ"]
```

Notice how the first entry `intro.typ` is a specific file, whereas the second `*.typ` captures a range of files.
When a glob string captures a range of source files, they will be ordered lexicographically in the spine.

Each format uses its spine slightly differently.
See the #link("./format-pdf.typ")[PDF], #link("./format-html.typ")[HTML], and #link("./format-epub.typ")[EPUB] format pages for details on how spines are configured and what defaults are applied for each output.
