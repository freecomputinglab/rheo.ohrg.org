#let div(_class, ..body) = html.elem("div", attrs: (class: _class), ..body)
#let button(_class, _aria, ..body) = html.elem("button", attrs: (class: _class, aria-label: _aria), ..body)
#let ul(_class, ..body) = html.elem("ul", attrs: (class: _class), ..body)
#let li(_class, ..body) = html.elem("li", attrs: (class: _class), ..body)
#let a(_href, ..body) = html.elem("a", attrs: (href: _href), ..body)
#let nav(_class, ..body) = html.elem("nav", attrs: (class: _class), ..body)
#let span(_class, ..body) = html.elem("span", attrs: (class: _class), ..body)

#let rheo-source-url = "https://github.com/freecomputinglab/rheo"
#let rheo-docs-source-url = "https://github.com/freecomputinglab/rheo.ohrg.org"
#let rheo-docs-url = "https://rheo.ohrg.org"

// NOTE: in the future, this can perhaps be provided by rheo
#let rheobook(current-page: none, doc) = {
  let title = "Rheo"

  // NOTE: this links cannot be specified as ".typ" currently, as rheo only transforms links that 
  // are registered in Typst's AST. As these links are directly rendered into HTML using `html.elem`, 
  // rheo will just reproduce the URLs as specified.
  let pages = (
 
    // (id: "index", title: "Home", file: "./"),
    (id: "what-and-why-is-rheo", title: "What and why is rheo?", file: "./what-and-why-is-rheo.html"),
    (id: "getting-started", title: "Getting started", file: "./getting-started.html"),
    (id: "relative-linking", title: "Relative linking", file: "./relative-linking.html"),
    (id: "configuration", title: "Configuration", file: "./configuration.html"),
    (id: "build-dir", title: "Build directory", file: "./build-dir.html"),
    (id: "content-dir", title: "Content directory", file: "./content-dir.html"),
    (id: "formats", title: "Formats", file: "./formats.html"),
    (id: "spines", title: "Spines", file: "./spines.html"),
    (id: "custom-css", title: "Custom CSS", file: "./custom-css.html"),
  )

  context if target() == "html" {
    div("topbar")[
      #button("sidebar-toggle", "Toggle sidebar")[
        #span("hamburger")
      ]
      #div("topbar-title")[#title]
    ]

    nav("sidebar")[
      // banner
      #div("banner")[
        #a("./")[
          #image("img/rheo-header.png")
        ]
      ]

      // sidebar
      #ul("sidebar-nav")[
        #for page in pages {
          let class = if page.id == current-page {"active"} else {""}
          li(class)[
            #a(page.file)[#page.title]
          ]
        }
      ]
    ]

    div("content")[
      #doc
    ]

    // Sidebar toggle script
    // Source: sidebar-toggle-source.js (human-readable)
    // Encoded: sidebar-toggle.js (base64-encoded to avoid HTML entity escaping)
    // To update: edit sidebar-toggle-source.js, then run: bash encode-js.sh
    html.elem("script")[#read("sidebar-toggle.js")];

  } else { 
    doc 
  }
}

#show: rheobook.with(current-page: "index")

#div("quickstart")[
  ```bash cargo install rheo```
]

Rheo (_ree-oh_) is a typesetting and static site engine based on #link("https://typst.app/")[typst].
If 'static site engine' is all Greek to you---don't worry!
We can also explain rheo through what it allows you to do.

Rheo allows you to produce a website, a fixed-size document, and an adaptive document from a single set of source typst files.
It's sort of like #link("https://www.latex-project.org/")[LaTeX]---except that typst is _much_ simpler to write, and we can compile it to a greater number of formats. 
The documentation that you are reading now, for example, was typeset with rheo.
As a result, you can read it as:

- #link("https://rheo.ohrg.org")[HTML] - A website for browsers.
- #link("https://rheo.ohrg.org/rheo-docs.pdf")[PDF] - A fixed-size document for printing.
- #link("https://rheo.ohrg.org/rheo-docs.epub")[EPUB] - An adaptive document for e-readers.

== Who should use rheo?
If you write anything as simple as a blog or as complex as a dissertation or monograph in typst, rheo enables you to publish it across the formats listed above.  
Rheo is for anyone who is willing to learn #link("https://typst.app/docs/reference/syntax/")[a little bit of syntax] to turn a piece of writing into a website, an adaptive document, or a printable document. 

Rheo is for anyone who has ever spent regrettable hours formatting citatons in a bibliography or fighting with LaTeX, anyone who has experienced the limitatons of Markdown as a markup language, and anyone who wants to benefit from typst's richer features and capabilities in the writing experience (see #link("./pages/what-and-why-is-rheo.typ")[What and why is rheo?]).
It is for students and teachers, humanists and scientists, bloggers and novelists.

If you have only ever used Microsoft Word to author text, or haven't heard the phrase 'markup language' before, we recommend first familiarizing yourself with Markdown via #link("https://www.markdowntutorial.com")[the beginner's tutorial].   
This should give you a good intuition for what typst is---a markup language similar to but also more powerful than Markdown---and why you might want to use rheo to typeset your documents.
