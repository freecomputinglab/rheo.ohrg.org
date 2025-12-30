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

== EPUB

An EPUB must have a spine in order to be valid.
By default, Rheo will infer the following spine if not specified:

```toml
[epub.spine]
title = "[project folder name]"
vertebrae = ["**/*.typ"]
```

== PDF 

By default, Rheo generates one PDF per Typst source file.
You can specify a spine for the PDF format in order to reticulate multiple source documents into a single output PDF by indicating the vertebrae and setting `merge` to `true`:

```toml
[pdf.spine]
title = "My reticulated pdf"
vertebrae = ["intro.typ", "*.typ"]
merge = true
```

In a PDF generated in this way, #link("./relative-linking.typ")[relative links] will resolve to internal document links that point to the relevant section.

== HTML 

Rheo does not currently support customizing HTML spines.
The default spine uses all Typst files: 

```toml
[html.spine]
title = "[project folder name]"
vertebrae = ["**/*.typ"]
```
