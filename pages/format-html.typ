#import "index.typ": rheobook
#show: rheobook.with(current-page: "format-html")

= HTML

Typst #link("https://typst.app/docs/reference/html/")[experimentally supports] HTML.
This means that not all Typst syntax will translate to a meaningful HTML structure.
The most common features in everyday prose are all supported, however, such as text markup, links, headings, footnotes, and citations.
For more information on which features are currently supported in Typst's HTML export, refer to the #link("https://github.com/typst/typst/issues/5512")[HTML export tracking issue].

Rheo's HTML format provides additional utilities for referencing CSS and Javascript in the built site, as well as passing through assets.#footnote[Note that there is an experimental #link("https://github.com/typst/typst/pull/7964")[bundle format] in upstream Typst which allows you to achieve similar results. We are tracking this closely, but for the time being have not incorporated this feature/format into Rheo on account of some critical deficiencies such as #link("https://github.com/typst/typst/issues/1097")[the inability to have multiple bibliographies in the same source file].]
