#import "index.typ": rheo-source-url, sidebar-site
#show: sidebar-site.with(current: "assets")

= Assets

Assets are non-Typst files that your project needs in its output -- things like images, fonts, or data files.
Rheo provides a `copy` attribute that lets you specify #link("https://www.man7.org/linux/man-pages/man7/glob.7.html")[glob] patterns for files that should be copied into your build output.

== Copying files to all formats

You can specify a top-level `copy` in your `rheo.toml` to copy files into every format's output directory:

```toml
copy = ["assets/**/*.png", "fonts/**"]
```

Paths are relative to the project root (not the #link(<content-dir>)[content directory]), and directory structure is preserved in the output.
Only files are copied; parent directories are created automatically.

For example, if your project looks like this:

```
my-project/
├── rheo.toml
├── assets/
│   └── logo.png
└── chapter.typ
```

Then `assets/logo.png` will be copied into each format's #link(<build-dir>)[build directory] at the same relative path.

== Format-specific copies

If you only need certain files for a specific format, you can scope the `copy` to that format's assets section:

```toml
[html.assets]
copy = ["images/**", "fonts/**"]
```

This copies the matched files only into the HTML output directory.
Use this when files are only relevant to one format -- for instance, web fonts that PDF and EPUB don't need.

You can combine global and format-specific copies; both will be applied when building a given format.

== Format-specific assets

Format plugins can expose additional asset configuration beyond `copy`.
For HTML, this includes CSS and JavaScript entrypoints and support for multiple asset blocks --- see #link(<custom-js-css>)[Custom JS/CSS].

== Relation to Typst's bundle format

Typst has an experimental #link("https://typst.app/docs/reference/bundle/")[bundle format] that handles assets programmatically: you call `asset("output/path", read("source/file", encoding: none))` inside your Typst source to declare files that should be written alongside the document output.

Rheo's `copy` serves the same purpose but declaratively, at the project level via `rheo.toml`.
Rather than writing `asset()` calls in every source file, you declare glob patterns once and Rheo copies the matched files into every (or a specific) format's output directory.
The two approaches are complementary: `copy` handles static files known at project-configuration time, while `asset()` is available for files that need to be generated or selected dynamically from within Typst.
