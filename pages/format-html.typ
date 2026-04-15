#import "index.typ": rheobook
#show: rheobook.with(current-page: "format-html")

= HTML

Typst #link("https://typst.app/docs/reference/html/")[experimentally supports] HTML.
This means that not all Typst syntax will translate to a meaningful HTML structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.
For more information on which features are currently supported in Typst's HTML export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

== What Rheo adds

Where the Typst CLI produces a single HTML file, Rheo turns your project into a fully functional static site.
Each Typst source file becomes its own HTML page, and #link("./relative-linking.typ")[relative links] between files are automatically rewritten from `.typ` to `.html` so that navigation works in the browser.

Rheo also provides a development server with live reloading when you use the `watch` command, so you can see changes in the browser as you edit your source files:

```bash
rheo watch my-project --html --open
```

The HTML format supports configurable #link("./custom-js-css.typ")[CSS and JavaScript] entrypoints, as well as #link("./assets.typ")[asset copying] for additional files your site needs.
These entrypoints are also the mechanism through which reading augmentations can be delivered -- the #link("https://github.com/freecomputinglab/rheo/tree/main/examples/tooltip_html")[tooltip example], for instance, uses a custom Typst function and a JavaScript entrypoint to provide inline tooltips in the HTML output.#footnote[Note that there is an experimental #link("https://github.com/typst/typst/pull/7964")[bundle format] in upstream Typst which allows you to achieve similar results. We are tracking this closely, but for the time being have not incorporated this feature/format into Rheo on account of some critical deficiencies such as #link("https://github.com/typst/typst/issues/1097")[the inability to have multiple bibliographies in the same source file].]

You can customize which files are included in the HTML output using a #link("./spines.typ")[spine]:

```toml
[html.spine]
vertebrae = ["index.typ", "about.typ", "posts/*.typ"]
```
