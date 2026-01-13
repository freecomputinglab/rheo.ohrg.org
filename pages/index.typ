#let div(_class, ..body) = html.elem("div", attrs: (class: _class), ..body)
#let button(_class, _aria, ..body) = html.elem("button", attrs: (class: _class, aria-label: _aria), ..body)
#let ul(_class, ..body) = html.elem("ul", attrs: (class: _class), ..body)
#let li(_class, ..body) = html.elem("li", attrs: (class: _class), ..body)
#let a(_href, ..body) = html.elem("a", attrs: (href: _href), ..body)
#let a-with-class(_href, _class, ..body) = html.elem("a", attrs: (href: _href, class: _class), ..body)
#let nav(_class, ..body) = html.elem("nav", attrs: (class: _class), ..body)
#let span(_class, ..body) = html.elem("span", attrs: (class: _class), ..body)

#let rheo-source-url = "https://github.com/freecomputinglab/rheo"
#let rheo-docs-source-url = "https://github.com/freecomputinglab/rheo.ohrg.org"
#let rheo-docs-url = "https://rheo.ohrg.org"

// NOTE: in the future, this can perhaps be provided by rheo
#let rheobook(current-page: none, doc) = {

  set text(font: ("Inter", "San Francisco", "Arial"))

  // NOTE: this links cannot be specified as ".typ" currently, as rheo only transforms links that
  // are registered in Typst's AST. As these links are directly rendered into HTML using `html.elem`,
  // rheo will just reproduce the URLs as specified.
  let pages = (

    (id: "index", title: "Introduction", file: "./"),
    (id: "what-and-why-is-rheo", title: "Why Rheo?", file: "./what-and-why-is-rheo.html"),
    (id: "getting-started", title: "Getting started", file: "./getting-started.html"),
    (id: "relative-linking", title: "Relative linking", file: "./relative-linking.html"),
    (id: "rheotoml", title: "Rheo.toml", file: "./rheotoml.html"),
    (id: "build-dir", title: "Build directory", file: "./build-dir.html"),
    (id: "content-dir", title: "Content directory", file: "./content-dir.html"),
    (id: "formats", title: "Formats", file: "./formats.html"),
    (id: "spines", title: "Spines", file: "./spines.html"),
    (id: "custom-css", title: "Custom CSS", file: "./custom-css.html"),
  )

  // Calculate previous and next pages for navigation
  let current-index = if current-page != none {
    pages.position(p => p.id == current-page)
  } else {
    none
  }

  // Set document title based on current page
  let page-title = if current-index != none {
    pages.at(current-index).title + " | Rheo"
  } else {
    "Rheo"
  }
  set document(title: page-title)

  let prev-page = if current-index != none and current-index > 0 {
    pages.at(current-index - 1)
  } else {
    none
  }

  let next-page = if current-index != none and current-index < pages.len() - 1 {
    pages.at(current-index + 1)
  } else {
    none
  }

  context if target() == "html" {
    div("topbar")[
      #button("sidebar-toggle", "Toggle sidebar")[
        #span("hamburger")
      ]
    #a("/")[#div("topbar-title")[#image("img/header.svg", alt: "Rheo", height: 24pt)]]
    ]

    nav("sidebar")[
      // banner
      #div("banner")[
        #a("#")[]
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
      // Main content
      #doc
    ]

    // Desktop navigation arrows - after all content including footnotes
    div("nav-arrows desktop-nav")[
      #if prev-page != none {
        a-with-class(prev-page.file, "nav-arrow prev-arrow")[
          #span("arrow-icon")[←]
          #span("arrow-text")[#prev-page.title]
        ]
      }
      #if next-page != none {
        a-with-class(next-page.file, "nav-arrow next-arrow")[
          #span("arrow-text")[#next-page.title]
          #span("arrow-icon")[→]
        ]
      }
    ]

    // Mobile navigation arrows - after all content including footnotes
    div("nav-arrows mobile-nav")[
      #if prev-page != none {
        a-with-class(prev-page.file, "nav-arrow prev-arrow")[
          #span("arrow-icon")[←]
          #span("arrow-text")[Previous]
        ]
      }
      #if next-page != none {
        a-with-class(next-page.file, "nav-arrow next-arrow")[
          #span("arrow-text")[Next]
          #span("arrow-icon")[→]
        ]
      }
    ]

    // Sidebar toggle script
    // Source: sidebar-toggle-source.js (human-readable)
    // Encoded: sidebar-toggle.js (base64-encoded to avoid HTML entity escaping)
    // To update: edit sidebar-toggle-source.js, then run: bash encode-js.sh
    html.elem("script")[#read("sidebar-toggle.js")];

  } else { 
    set heading(numbering: "1.")
    doc 
  }
}

#show: rheobook.with(current-page: "index")

= What is Rheo?
The simple answer is that Rheo (_ree-oh_) is a new and more flexible way to produce and publish digital documents.
The less simple answer is that Rheo is a typesetting and static site engine based on #link("https://typst.app/")[Typst].
This guide explains both _how_ to use Rheo, and _why_ it might be for you.

Rheo allows you to produce a website, a fixed-size document, and an adaptive document from a single set of source Typst files.
It allows you to do something similar to #link("https://www.latex-project.org/")[LaTeX]---except that Typst is _much_ simpler to write, and we can produce a greater number of formats with it. 
The documentation that you are reading now, for example, was typeset with Rheo.
As a result, you can read it as:

- #link("https://rheo.ohrg.org")[HTML] - as a website for browsers.
- #link("https://rheo.ohrg.org/rheo-docs.pdf")[PDF] - as a fixed-size document for printing.
- #link("https://nota-lang.github.io/bene/?preload=https%3A%2F%2Frheo.ohrg.org%2Frheo-docs.epub")[EPUB] - as an adaptive document for e-readers.

== Who should use Rheo?
If you write anything as simple as a blog or as complex as a dissertation or monograph in Typst, Rheo enables you to publish it in multiple formats.  
If you are willing to learn #link("https://typst.app/docs/reference/syntax/")[a little bit of syntax], you can turn a piece of writing into a website, an adaptive document, and/or a printable document.

Some of the things you can write and publish with Rheo include:
- A blog
- A paper
- A dissertation
- A book manuscript
- A novel
- A text book
- Technical documentation

Rheo is for anyone who has ever spent regrettable hours formatting citatons, fighting with LaTeX, who has experienced the limitations of Markdown, or who wants to benefit from the richer writing experience that Typst makes possible (more on this in the next section).
It is for students and teachers, humanists and scientists, bloggers and novelists.

If you have only ever used Microsoft Word to author text, or haven't heard the phrase 'markup language' before, we recommend first familiarizing yourself with Typst via the #link("https://typst.app/docs/tutorial/")[excellent tutorial].   
This should give you a good intuition for what Typst is---a markup language similar to but also more powerful than Markdown---and why you might want to use Rheo to typeset your documents.
