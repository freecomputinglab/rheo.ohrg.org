#import "index.typ": rheo-source-url, rheobook
#show: rheobook.with(current-page: "assets")

= Assets

Assets are non-Typst files that your project needs in its output -- things like images, fonts, or data files.
Rheo provides a `copy` attribute that lets you specify #link("https://www.man7.org/linux/man-pages/man7/glob.7.html")[glob] patterns for files that should be copied into your build output.

== Copying files to all formats

You can specify a top-level `copy` in your `rheo.toml` to copy files into every format's output directory:

```toml
copy = ["assets/**/*.png", "fonts/**"]
```

Paths are relative to the project root (not the #link("./content-dir.typ")[content directory]), and directory structure is preserved in the output.
Only files are copied; parent directories are created automatically.

For example, if your project looks like this:

```
my-project/
├── rheo.toml
├── assets/
│   └── logo.png
└── chapter.typ
```

Then `assets/logo.png` will be copied into each format's #link("./build-dir.typ")[build directory] at the same relative path.

== Format-specific copies

If you only need certain files for a specific format, you can scope the `copy` to that format's assets section:

```toml
[html.assets]
copy = ["images/**", "fonts/**"]
```

This copies the matched files only into the HTML output directory.
Use this when files are only relevant to one format -- for instance, web fonts that PDF and EPUB don't need.

You can combine global and format-specific copies; both will be applied when building a given format.

== HTML-specific assets

HTML output also supports configurable asset entrypoints for CSS and JavaScript.
See #link("./custom-js-css.typ")[Custom JS/CSS] for details on how to customize or replace the default stylesheet and add scripts.
