#import "index.typ": rheo-source-url, rheobook
#show: rheobook.with(current-page: "custom-js-css")

= CSS
When Rheo generates HTML, it injects a #link(rheo-source-url + "/blob/main/crates/html/src/templates/style.css")[default stylesheet] into the generated static site for a simple, modern, and mobile-friendly aesthetic.
#link("https://screening-the-subject.ohrg.org")['Screening the subject'] is a website generated with the default Rheo stylesheet for reference.

You can fully customize the stylesheet by adding a `style.css` at the root of your #link("./rheotoml.typ")[project directory].
Note that if your project contains a custom `style.css`, _none_ of the styles in the default stylesheet will be applied.
If you want to build on the default styles, copy and paste the #link(rheo-source-url + "/blob/main/src/css/style.css")[default stylesheet] into the `style.css` file in your project directory.

You can customize the entrypoint for the CSS included in the HTML build in `rheo.toml`.
Note that this path is relative to the Rheo root (not the #link("./content-dir.typ")[content directory]):

```toml
[html.assets]
css_stylesheet = "./index.css"
```

= Javascript

Rheo also makes it easy to reference JS in your HTML site by ferrying the code in `index.js` through to your HTML build.
Take a look at the #link(rheo-source-url + "/tree/main/examples/tooltip_html")[tooltip_html example project], which leverages the `index.js` entrypoint using a modern JS bundling toolchain to provide a package through which you can specify tooltips in the HTML build as a custom function in Typst.

You can customize the entrypoint for the JS included in the HTML build in `rheo.toml`.
Note that this path is relative to the Rheo root (not the #link("./content-dir.typ")[content directory]):

```toml
[html.assets]
js_scripts = "./entrypoint.js"
```
