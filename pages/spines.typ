#import "index.typ": rheobook 
#show: rheobook.with(current-page: "spines")

= Spines

A spine in rheo is the backbone, or table of contents, of typst source files that should be included in an output format.
It takes its name from the #link("https://www.edrlab.org/open-standards/anatomy-of-an-epub-3-file/")[epub specification], in which the spine articulates the set and order of chapters included.

You can specify a spine for an output format using an array of #link("https://www.man7.org/linux/man-pages/man7/glob.7.html")[glob] strings in `rheo.toml`:

```toml
[epub.merge]
title = "My epub"
spine = ["intro.typ", "*.typ"]
```

Notice how the first entry `intro.typ` is a specific file, whereas the second `*.typ` captures a range of files.
When a glob string captures a range of source files, they will be ordered lexicographically in the spine.

The spine specification needs to come under the `[epub.merge]` heading in the config, as we are telling rheo to merge multiple source files into a single output file.
This many-to-one merging is how you can think about what a spine does: it _reticulates_ a set of source files.

== epub

An epub must have a spine in order to be valid, and thus you cannot generate an epub from rheo until you speciy a spine in a `rheo.toml`.

== pdf

By default, rheo generates one pdf per typst source file.
You can specify a spine in order to reticulate multiple source files into a single pdf:

```toml
[pdf.merge]
title = "My reticulated pdf"
spine = ["intro.typ", "*.typ"]
```

== html

Rheo does not currently support reticulation via a spine in html.

