#import "index.typ": rheobook, rheo-source-url, rheo-docs-url, rheo-docs-source-url
#show: rheobook.with(current-page: "getting-started")

= Installation 
The easiest way to install Rheo is from #link("https://crates.io/")[crates.io], the Rust language's package manager.
If you don't already have Rust/cargo, you will need to #link("https://doc.rust-lang.org/cargo/getting-started/installation.html")[install those first].
Open your terminal, and run the following command:

```bash
cargo install rheo --locked
```

Rheo is packaged as a standalone binary, and doesn't require any version of Typst on your system.
(Note that even if you already have Typst on your system, Rheo will use its own embedded version of the compiler.)
Refer to #link(rheo-source-url)[Rheo's source code] for more information and installation options. 

== Firing up 
With Rheo we can produce a static site, a PDF, and an EPUB from a Typst document. 
Let's create a directory with a single Typst file in it:

```bash
mkdir project_uno
touch project_uno/index.typ
```

As one of Rheo's outputs is a static site, the landing page will default to one named 'index'.
(If this file doesn't exist, Rheo will present you with a basic listing of all the other files in the site.)
Let's put some Typst in the `index.typ` file:

`project_uno/index.typ`
```typ
= Project uno

Project uno is a writing project.
```

Rheo aims to keep out of your way as much as possible, and doesn't require that you add any special syntax or metadata to your files to work.
This single Typst file we need to get started.
Provided you've already installed Rheo on your system, we can compile the project.
You can tell Rheo to compile a folder by pointing the `compile` command at it: 

```bash
rheo compile project_uno 
```

This command produces a `build` subdirectory inside the base directory which contains a PDF, an EPUB, and a static site (HTML and CSS).
Your project folder should now look like so:

```
.
├── build
│   ├── epub
│   │   └── project_uno.epub
│   ├── html
│   │   ├── index.html
│   │   └── style.css
│   └── pdf
│       └── index.pdf
└── index.typ

```

It's a little tiring to have to run the compile command every time we make a change, though. 
Let's spin up a development server to see live changes across all output formats as we edit the source:

```bash
rheo watch project_uno --open
```

The `--open` flag here indicates that we'd like to open the output using our system's default applications.
Provided you have an EPUB reader on your system (if you don't, we recommend installing #link("https://github.com/nota-lang/bene")[bene]), you should now have a PDF, an EPUB, and a website in front of you.
As simple as that!

== Scaling up 

Let's kill that process (with Ctrl-C).
Rheo compiles documents from across your project directory towards EPUB, PDF, and HTML simultaneously, whereas the Typst compiler typically takes just one Typst file and produces one kind of output.#footnote[Typst allows you to break up your projects using #link("https://typst.app/docs/reference/foundations/module/")[modules], but still requires one entrypoint. Rheo, by contrast, enables multiple entrypoint files, corresponding to multiple standalone pages in a static site.] 
Let's add a couple of files to our project and link between them:

`project_uno/about.typ`
```typ
= About

Project uno is an incredible writing project that will transform the way we understand the world.
If you want to be involved, see the #link("./contact.typ")[Contact page].
```

`project_uno/contact.typ`
```typ
#let email = "myemail@mydomain.com"
= Contact 

To learn more about project uno, email me at #link("mailto:" + email)[#email]
```

And let's also link to the two new pages on the index page:

`project_uno/index.typ`
```typ
= Project uno

Project uno is a writing project.

- #link("./about.typ")[About]
- #link("./contact.typ")[Contact]
```

Now let's run Rheo again, but this time let's only build the HTML and EPUB outputs: 
```bash
rheo watch project_uno --html --epub --open
```

Note how the relative links are working across both the EPUB and the PDF. 
#link("./relative-linking.typ")[Relative linking] is one of the key features in Rheo that enables you to build richer static sites and EPUBs beyond using just Typst.
All of #link("https://typst.app/docs/reference/scripting/")[Typst's other features] such as variables are fair game, too, as Rheo just uses Typst's compiler under the hood.

== Adding a config 

One issue with the EPUB that is currently being produced is that the `index.typ` section shows up last, after the `about.typ` and `contact.typ`, as Rheo orders files lexicographically by default.
This is probably not what we want, as the index page acts as a sort of table of contents in our writing project currently.

To sophisticate the way that Rheo produces outputs, we can add a #link("./rheotoml.typ")[rheo.toml config] at the base of the project directory:

`project_uno/rheo.toml`
```toml
version = "0.1.0"

[epub.spine]
title = "Project Uno"
vertebrae = ["index.typ", "about.typ", "contact.typ"]
```

This config uses the notion of a #link("./spines.typ")[spine] to indicate a custom order for the sections.
We'll learn more about these later on in this documentation.

Let's run the `watch` command again, this time with all outputs like the first time:

```bash
rheo watch project_uno --open
```

Great!
The EPUB order is fixed.
We now, however, have three distinct PDFs that are being created: one for each page.
This is because Rheo defaults to producing one PDF per file in the project directory.
We can configure Rheo to merge files together into a single PDF output by specifying a PDF spine, as we did with EPUB, and setting the `merge` attribute to `true`:

`project_uno/rheo.toml`
```toml
version = "0.1.0"

[epub.spine]
title = "Project Uno"
vertebrae = ["index.typ", "about.typ", "contact.typ"]

[pdf.spine]
title = "Project Uno"
vertebrae = ["index.typ", "about.typ", "contact.typ"]
merge = true
```

Before we run this again, let's also clean the outputs in the build directory, as we don't need those individual PDFs that we produced anymore:

```sh
rheo clean project_uno
rheo watch project_uno --open
```

Now we have a fully featured writing project, with nice-looking and orderly outputs in PDF, EPUB, and in HTML!

#context if target() == "html" [== Footnotes]


