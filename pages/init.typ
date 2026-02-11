#import "index.typ": rheobook
#show: rheobook.with(current-page: "init")

The `init` command scaffolds a fully functional Rheo project that demonstrates relative linking, custom CSS, bibliographic references, and conditional targeting for HTML/PDF/EPUB.

= Usage

```bash
rheo init my_project
```

Where `my_project` is a path to either a new directory that will be created, or an existing empty directory in which the Rheo project will be scaffolded.
(Hidden files and directories like `.git` or `.jj` are ignored, so you can initialize a Rheo project in a fresh repository.)

= What gets created

Running `rheo init my_project` produces the following structure:

```
my_project/
├── content/
│   ├── img/
│   │   └── header.svg
│   ├── about.typ
│   ├── index.typ
│   └── references.bib
├── rheo.toml
└── style.css
```

- *`rheo.toml`* -- the project configuration, with a #link("./content-dir.typ")[content directory] set to `content/`, and #link("./spines.typ")[spines] for both PDF and EPUB.
- *`style.css`* -- a #link("./custom-css.typ")[custom stylesheet] for the HTML output.
- *`content/index.typ`* -- the landing page, which defines a reusable `template` show rule and demonstrates conditional rendering for HTML vs PDF.
- *`content/about.typ`* -- a second page that imports the template and links back to the index.
- *`content/references.bib`* -- a sample bibliography file, referenced from `index.typ` using Typst's `#bibliography` function.
- *`content/img/header.svg`* -- a header image used across formats.

= Compiling the scaffolded project

Once scaffolded, you can compile or watch the project as usual:

```bash
rheo compile my_project
```

Or spin up a development server:

```bash
rheo watch my_project --open
```

= Extending the template

The scaffolded `index.typ` includes a `template` function that applies a header across formats using Typst's `target()` function:

```typ
#let template(current-page: none, doc) = {
  context if target() == "html" {
    html.elem("div", attrs: (class: "header"))[
      #image("img/header.svg")
    ]
    html.elem("hr")
  } else if target() == "paged" {
    image("img/header.svg")
  } else {}
  doc
}
```

Other pages in the project import and apply this template with a show rule:

```typ
#import "index.typ": template
#show: template.with(current-page: "about")
```

This pattern --- defining a show rule in one file and importing it in others --- is the same one used to build #link("https://rheo.ohrg.org")[this documentation site].
You can extend it to include navigation, footers, or any other shared layout you need.
