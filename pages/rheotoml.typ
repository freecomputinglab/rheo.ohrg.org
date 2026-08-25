#import "index.typ": code-with-version, rheo-version, sidebar-site
#show: sidebar-site.with(current: "rheotoml")

The directory that holds your Typst source is called the *project directory*, and you can compile it like so:

```bash
rheo compile path/to/projectdirectory
```

In general, there are two ways to configure Rheo:

+ By passing *flags* directly to the CLI command.
+ By specifying configuration in a `rheo.toml` file at the root of the project directory.

If you compile a Rheo project directory without a `rheo.toml` file, the following default settings will be applied to compile your project.

#code-with-version(
  lang: "toml",
  `version = "{version}"
content_dir = "./"
build_dir = "build"
formats = ["pdf", "html", "epub"]

[epub.spine]
title = "[project directory name]"`,
)

Without a #link(<spines>)[spine] config, every Typst file under `content_dir` is included, ordered by the #link(<spines>)[directory-scan default].

To point Rheo to a rheo.toml file that is not at the root of the project directory, specify it directly via the CLI:

```sh
rheo compile path/to/project --config path/to/config
```

== Per-page footnotes

In HTML and EPUB output, Rheo produces one output file per page.
By default it resets the footnote counter to `1` at the start of every page, so each page numbers its footnotes independently.
To let footnotes accumulate continuously across the whole bundle instead, set `reset_footnotes = false` under `[html]` or `[epub]`:

```toml
[html]
reset_footnotes = false   # let footnotes accumulate across pages (default: true)
```

The key is per-format: set it on `[html]` and `[epub]` independently.
It defaults to `true`, and as with other settings the CLI takes precedence over `rheo.toml`, which takes precedence over the default (there is no CLI flag for it).
PDF is unaffected --- it combines your project into a single document, so its footnotes are always continuous regardless of this key.

== Automatic package detection

Rheo scans your content files' `#import` statements and auto-detects assets or marrow declared by any `@rheo`-aware package you use, per format.
Set `auto_detect_packages = false` on a format's own table to turn that off for that format alone:

```toml
[html]
auto_detect_packages = false   # default: true
```

See #link(<packages>)[Packages] for more information.

== Fonts

Because Rheo embeds its own copy of the Typst compiler, it resolves fonts itself rather than deferring to any `typst` binary or font cache already on your system.
Alongside your system fonts, it looks for a `fonts` directory at the root of your project by default and loads anything it finds there.
Set the top-level `font_dirs` key to search different or additional directories instead --- paths are resolved relative to the project root unless absolute, and setting this key switches off the automatic `fonts` autoscan, so include `"fonts"` explicitly if you still want it searched:

```toml
font_dirs = ["fonts", "custom/typefaces"]
```

The repeatable `--font-dir` CLI flag, available on `compile` and `watch`, appends further directories on top of whatever `font_dirs` (or the autoscan) already resolved.

