#let div(_class, ..body) = html.elem("div", attrs: (class: _class), ..body)
#let button(_class, _aria, ..body) = html.elem("button", attrs: (class: _class, aria-label: _aria), ..body)
#let ul(_class, ..body) = html.elem("ul", attrs: (class: _class), ..body)
#let li(_class, ..body) = html.elem("li", attrs: (class: _class), ..body)
#let a(_href, ..body) = html.elem("a", attrs: (href: _href), ..body)
#let nav(_class, ..body) = html.elem("nav", attrs: (class: _class), ..body)
#let span(_class, ..body) = html.elem("span", attrs: (class: _class), ..body)

#let rheo-source-url = "https://github.com/breezykermo/rheo"
#let rheo-docs-source-url = "https://github.com/breezykermo/rheo.ohrg.org"
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

Rheo (_ree-oh_) is a static site and epub engine based on #link("https://typst.app/")[typst].
It allows you to write books, blogs, documentation, and papers by producing three concurrent outputs from the same typst source files.
The three outputs you can get from rheo are: 

+ A static site such as #link("https://rheo.ohrg.org")[rheo.ohrg.org].
+ A #link("https://rheo.ohrg.org/rheo-docs.pdf")[pdf]. 
+ An #link("https://rheo.ohrg.org/rheo-docs.epub")[epub]. 

== Quickstart

#raw(lang: "bash", "# Install rheo\ncargo install rheo\n# Get some typst files\ngit clone " + rheo-docs-source-url + "\n# Flow them into outputs\nrheo watch rheo.ohrg.org --open")





