#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "packages")

= Packages

A Rheo package is a standard #link("https://typst.app/universe/")[Typst Universe] package that ships its own web assets --- CSS, JavaScript, or files to copy --- alongside its Typst code.

== Using packages

To use a Rheo-compatible package, import it in your Typst source files as you normally would:

```typ
#import "@rheo/tooltip:0.1.0": tooltip
```

That's all!
Just like the Typst CLI, Rheo will prewarm the `@rheo` namespace so that all of the #link("https://github.com/freecomputinglab/rheo-packages")[existing packages] are available.
When Rheo compiles your project, it reads every `#import` statement in your content files, identifies any Typst Universe and Rheo packages, and makes them available in your project.

A Rheo package is essentially a Typst package that can also provide #link(<assets>)[assets] and #link(<marrow>)[marrow].
This means that a Rheo package can provide a Typst interface to custom functionality in any given format supported by Rheo, and/or abstract the same source Typst across multiple formats to gracefully degrade an interactive modal from HTML to PDF, for example.

See the #link(<pkg-slides>)[slides package] for an example exposing #link("https://revealjs.com/")[RevealJS] by way of a Typst API to downstream projects.

=== Turning off automatic detection

Rheo handles asset and marrow import for every `#import` in your content files by default.
If you don't want this auto-detection of Rheo packages, you can turn it off in your `rheo.toml`:

```toml
auto_detect_packages = false
```

== Creating a Rheo-compatible package

If you are authoring a Typst Universe package and want to ship assets that integrate with Rheo's HTML output, add a `[tool.rheo.html]` section to your package's `typst.toml`:

```toml
[package]
name = "rheo-tooltip"
version = "0.1.0"
entrypoint = "lib.typ"

[tool.rheo.html]
js_scripts = "dist/index.js"
css_stylesheets = "dist/index.css"
```

The `[tool.rheo.html]` section accepts the same fields as `[[html.assets]]`:

- `js_scripts` --- path to a JavaScript file to inject into HTML pages.
- `css_stylesheets` --- path to a CSS file to inject into HTML pages.
- `copy` --- glob patterns for additional files to copy into the HTML build.

Paths are relative to the package root and are resolved against the package's location in the local Typst package cache.
When a user imports your package and builds their Rheo project, your assets are injected without any extra steps on their part.

=== Requiring a minimum Rheo version

A package can also declare the oldest Rheo it works with, in a `[tool.rheo]` table alongside (or instead of) the format-specific asset section above:

```toml
[tool.rheo]
min_version = "0.6.0"
```

Rheo will only check a package if this attribute exists.
Where a project imports a package whose declared floor is above the running Rheo, the build will fail before any Typst compile even starts.
```
@acme/widgets:1.0 needs rheo >= 0.8.0, but this is rheo 0.6.0
@acme/charts:2.0 needs rheo >= 0.9.0, but this is rheo 0.6.0
Upgrade rheo: https://rheo.ohrg.org
```

A package that isn't resolved locally, has no manifest, or simply never sets `min_version` will never throw this kind of error.
`min_version` is only checked from Rheo `>=0.6.0`.
