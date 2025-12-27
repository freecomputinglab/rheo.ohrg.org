#import "index.typ": rheobook, rheo-source-url, rheo-docs-url, rheo-docs-source-url
#show: rheobook.with(current-page: "getting-started")

== Installation 
The easiest way to install rheo is from #link("https://crates.io/")[crates.io], the Rust language's package manager.
If you don't already have Rust/cargo, you will need to #link("https://doc.rust-lang.org/cargo/getting-started/installation.html")[install those first].
Open your terminal, and run the following command:

```bash
cargo install rheo
```

Rheo is packaged as a standalone binary, and doesn't require any version of Typst on your system.
(Note that even if you already have Typst on your system, rheo will use its own embedded version of the compiler.)
Refer to rheo's #link(rheo-source-url)[source code] for more information and installation options. 

== Firing up 
The #link(rheo-docs-url)[source code for rheo's documentation] is a collection of Typst files.
Rheo allows us to produce a static site, a pdf document, and an epub, all from that collection. 

// TODO: walk through adding Typst files one by one, more descriptive
Let's clone the source code for this documentation to understand what we can do:

#raw(lang: "bash", "git clone " + rheo-docs-source-url)

Take a quick look at the structure of the source code.
Besides some configuration files at the top level, it's almost entirely just Typst files.
Rheo doesn't require that you add any special syntax or metadata to your files to work.
It keeps out of your way as much as possible.

Now that we have some Typst on our system, we can see rheo at work:

```bash
rheo compile rheo.ohrg.org
```

This command produces a `build` subdirectory inside the `rheo.ohrg.org` directory which contains a pdf, an epub, and a static site.
It's a little tiring to have to run the compile command every time we make a change, though. 
Let's spin up a development server to see live changes across all output formats as we edit the source typst:

```bash
rheo watch rheo.ohrg.org --open
```

The `--open` flag here indicates that we'd like to open all of the outputs using our system's default applications.
You should now have a pdf, an epub, and a website in front of you.
Huzzah!

// And if we just need one format, such as a website, we can forego producing the other formats:
//
// ```bash
// rheo compile free-computing-lab.ohrg.org --html 
// # alternatively: --pdf or --epub
// ```
//
// == How can I contribute to rheo? 
// Rheo is written in Rust and developed in public through #link("https://github.com/breezykermo/rheo")[Github].
// You can track development and submit issues or requests for features through that platform.
// While in principle we welcome community pull requests, it's best to open an issue to confirm that your work will not go to waste first.
//
//
//
