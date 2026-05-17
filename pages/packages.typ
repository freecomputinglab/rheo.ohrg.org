#import "index.typ": rheobook
#show: rheobook.with(current-page: "packages")

= Packages

A Rheo package is a standard #link("https://typst.app/universe/")[Typst Universe] package that ships its own web assets --- CSS, JavaScript, or files to copy --- alongside its Typst code.
When Rheo detects that a package declares a `[tool.rheo.html]` section in its `typst.toml`, it automatically injects those assets into the HTML build without any configuration on your part.

== Using packages

To use a Rheo-compatible package, import it in your Typst source files as you normally would:

```typ
#import "@preview/rheo-tooltip:0.1.0": tooltip
```

That is all you need to do.
When Rheo compiles your project, it reads every `#import` statement in your content files, identifies any Typst Universe packages, pre-warms them, and checks whether their `typst.toml` contains a `[tool.rheo.html]` section.
If it does, the declared assets are injected into the HTML output automatically --- behaving exactly like a manually configured `[[html.assets]]` block.
See #link("./custom-js-css.typ")[Custom JS/CSS] for details on what that means for the build output.

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
