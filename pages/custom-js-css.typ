#import "index.typ": rheo-source-url, sidebar-site
#show: sidebar-site.with(current: "custom-js-css")

= HTML Assets

The HTML format plugin extends Rheo's generic #link("./assets.typ")[asset system] with CSS and JavaScript entrypoints, configurable via `[html.assets]` in `rheo.toml`.

== CSS

When Rheo generates HTML, it injects a #link(rheo-source-url + "/blob/main/crates/html/src/templates/style.css")[default stylesheet] into the generated static site for a simple, modern, and mobile-friendly aesthetic.
#link("https://screening-the-subject.ohrg.org")['Screening the subject'] is a website generated with the default Rheo stylesheet for reference.

You can fully customize the stylesheet by adding a `style.css` at the root of your #link("./rheotoml.typ")[project directory].
Note that if your project contains a custom `style.css`, _none_ of the styles in the default stylesheet will be applied.
If you want to build on the default styles, copy and paste the #link(rheo-source-url + "/blob/main/crates/html/src/templates/style.css")[default stylesheet] into the `style.css` file in your project directory.

You can customize the entrypoint for the CSS included in the HTML build in `rheo.toml`.
Note that this path is relative to the Rheo root (not the #link("./content-dir.typ")[content directory]):

```toml
[html.assets]
css_stylesheet = "./index.css"
```

== Javascript

Rheo also makes it easy to reference JS in your HTML site by ferrying the code in `index.js` through to your HTML build.
Take a look at the #link(rheo-source-url + "/tree/main/examples/tooltip_html")[tooltip_html example project], which leverages the `index.js` entrypoint using a modern JS bundling toolchain to provide a package through which you can specify tooltips in the HTML build as a custom function in Typst.

You can customize the entrypoint for the JS included in the HTML build in `rheo.toml`.
Note that this path is relative to the Rheo root (not the #link("./content-dir.typ")[content directory]):

```toml
[html.assets]
js_scripts = "./entrypoint.js"
```

== Multiple asset blocks

`[html.assets]` can be written as an array of blocks using TOML's double-bracket syntax (`[[html.assets]]`).
Each block is a distinct asset set with its own `js_scripts`, `css_stylesheets`, and `copy`, and an optional `dest` subfolder within the HTML build directory.

```toml
[[html.assets]]
dest = "tooltip"
js_scripts = "tooltip/index.js"
css_stylesheets = "tooltip/index.css"

[[html.assets]]
dest = "annotations"
js_scripts = "annotations/index.js"
```

Use multiple blocks when your project combines more than one independent set of scripts or stylesheets --- for example, when bundling assets from multiple packages.
Each block's files are written under its `dest` subdirectory, or directly into the HTML root if `dest` is omitted.

For automatic injection of asset blocks from Typst packages, see #link("./packages.typ")[Packages].
