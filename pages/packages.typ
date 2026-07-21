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

A Rheo package is essentially a Typst package that can also provide #link(<assets>)[assets].
A package can declare assets that will be injected into a format's build folder automatically --- behaving exactly like a manually configured `[[html.assets]]` block.

This is particularly useful in HTML, as it means that we can essentially expose JS/CSS libraries through a Typst API to our project, as the #link(<pkg-slides>)[slides package] does for #link("https://revealjs.com/")[RevealJS].
(See #link(<custom-js-css>)[Custom JS/CSS] for details on what that means for the build output in HTML.)

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
