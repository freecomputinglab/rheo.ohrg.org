#import "@rheo/sidebar:0.1.0": sidebar

#let rheo-version = "0.4.0"
#let code-with-version(lang: none, body) = raw(
  lang: lang,
  block: true,
  body.text.replace("{version}", rheo-version)
)

#let rheo-source-url = "https://github.com/freecomputinglab/rheo"
#let rheo-docs-source-url = "https://github.com/freecomputinglab/rheo.ohrg.org"
#let rheo-docs-url = "https://rheo.ohrg.org"
#let fcl-zulip-join-url = "https://freecomputinglab.zulipchat.com/join/dit724hcwgbhic3xxwkdpkqs/"

#let site-nav = (
  (
    title: "Basics",
    items: (
      (id: "index", title: "Introduction", url: "./"),
      (id: "why-is-rheo", title: "Why Rheo?", url: "./why-is-rheo.html"),
      (id: "getting-started", title: "Getting started", url: "./getting-started.html"),
      (id: "init", title: "Initializing a project", url: "./init.html"),
      (id: "faq", title: "Frequently Asked Questions", url: "./faq.html"),
    ),
  ),
  (
    title: "Core",
    items: (
      (id: "core", title: "Basics", url: "./core.html"),
      (id: "rheotoml", title: "Rheo.toml", url: "./rheotoml.html"),
      (id: "relative-linking", title: "Relative linking", url: "./relative-linking.html"),
      (id: "migrate", title: "Migrating projects", url: "./migrate.html"),
      (id: "build-dir", title: "Build directory", url: "./build-dir.html"),
      (id: "content-dir", title: "Content directory", url: "./content-dir.html"),
      (id: "spines", title: "Spines", url: "./spines.html"),
      (id: "assets", title: "Assets", url: "./assets.html"),
      (id: "packages", title: "Packages", url: "./packages.html"),
    ),
  ),
  (
    title: "PDF",
    items: (
      (id: "format-pdf", title: "Basics of PDF", url: "./format-pdf.html"),
    ),
  ),
  (
    title: "EPUB",
    items: (
      (id: "format-epub", title: "Basics of EPUB", url: "./format-epub.html"),
    ),
  ),
  (
    title: "HTML",
    items: (
      (id: "format-html", title: "Basics of HTML", url: "./format-html.html"),
      (id: "custom-js-css", title: "Custom JS/CSS", url: "./custom-js-css.html"),
    ),
  ),
)

#let sidebar-site = sidebar.with(
  nav: site-nav,
  title: "Rheo",
  home-url: "/",
  logo: image("img/header.svg", alt: "Rheo", height: 24pt),
)

// RHEO_HACK: if_epub_start
// RHEO_HACK: if_epub_end

#show: sidebar-site.with(current: "index")

= What is Rheo?
The simple answer is that Rheo (_ree-oh_) is document infrastructure that makes #link("https://typst.app/")[Typst] a viable foundation for multi-format publishing.
The less simple answer is that Rheo is a typesetting and static site engine that sits between the Typst language and the formats readers use --- PDF, HTML, and EPUB --- providing the compilation, linking, and asset management needed to produce all three from a single set of source files.
This guide explains both _how_ to use Rheo, and _why_ it might be for you.

Rheo allows you to produce a website, a fixed-size document, and an adaptive document from the same Typst source.
It allows you to do something similar to #link("https://www.latex-project.org/")[LaTeX]---except that Typst is _much_ simpler to write, and we can produce a greater number of formats with it.
The documentation that you are reading now, for example, was typeset with Rheo.
As a result, you can read it as:

- #link("https://rheo.ohrg.org")[HTML] - as a website for browsers.
- #link("https://rheo.ohrg.org/rheo-docs.pdf")[PDF] - as a fixed-size document for printing.
- #link("https://nota-lang.github.io/bene/?preload=https%3A%2F%2Frheo.ohrg.org%2Frheo-docs.epub")[EPUB] - as an adaptive document for e-readers.

= Who should use Rheo?
If you write anything as simple as a blog or as complex as a dissertation or monograph in Typst, Rheo enables you to publish it in multiple formats.
If you are willing to learn #link("https://typst.app/docs/reference/syntax/")[a little bit of syntax], you can turn a piece of writing into a website, an adaptive document, and/or a printable document.

Some of the things you can write and publish with Rheo include:
- A blog
- A paper
- A dissertation
- A book manuscript
- A novel
- A textbook
- Technical documentation

Rheo is for anyone who has ever spent regrettable hours formatting citations, fighting with LaTeX, experiencing the limitations of Markdown, or who wants to benefit from the richer writing experience that Typst makes possible (more on this in the next section).
It is for students and teachers, humanists and scientists, bloggers and novelists.

If you have only ever used Microsoft Word to author text, or haven't heard the phrase 'markup language' before, we recommend first familiarizing yourself with Typst via the #link("https://typst.app/docs/tutorial/")[excellent tutorial].
This should give you a good intuition for what Typst is---a markup language similar to but also more powerful than Markdown---and why you might want to use Rheo to typeset your documents.
