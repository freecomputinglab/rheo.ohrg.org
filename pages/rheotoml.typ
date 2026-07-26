#import "index.typ": sidebar-site, rheo-version, code-with-version
#show: sidebar-site.with(current: "rheotoml")

The directory that holds your Typst source is called the *project directory*, and you can compile it like so:

```bash
rheo compile path/to/projectdirectory
```

In general, there are two ways to configure Rheo:

+ By passing *flags* directly to the CLI command.
+ By specifying configuration in a `rheo.toml` file at the root of the project directory.

If you compile a Rheo project directory without a `rheo.toml` file, the following default settings will be applied to compile your project.

#code-with-version(lang: "toml", `version = "{version}"
content_dir = "./"
build_dir = "build"
formats = ["pdf", "html", "epub"]

[epub.spine]
title = "[project directory name]"`)

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

