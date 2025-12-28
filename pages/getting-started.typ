#import "index.typ": rheobook, rheo-source-url, rheo-docs-url, rheo-docs-source-url
#show: rheobook.with(current-page: "getting-started")

== Installation 
The easiest way to install Rheo is from #link("https://crates.io/")[crates.io], the Rust language's package manager.
If you don't already have Rust/cargo, you will need to #link("https://doc.rust-lang.org/cargo/getting-started/installation.html")[install those first].
Open your terminal, and run the following command:

```bash
cargo install rheo
```

Rheo is packaged as a standalone binary, and doesn't require any version of Typst on your system.
(Note that even if you already have Typst on your system, Rheo will use its own embedded version of the compiler.)
Refer to #link(rheo-source-url)[Rheo's source code] for more information and installation options. 

== Firing up 
#link(rheo-docs-url)[Rheo's documentation] is a written in Typst.
With Rheo we can produce a static site, a PDF, and an EPUB from it. 
Let's clone the documentation source to see how Rheo works:

#raw(lang: "bash", "git clone " + rheo-docs-source-url)

Take a quick look at the structure of the source code.
Besides some configuration files at the top level, it's almost entirely just regular Typst.
Rheo aims to keep out of your way as much as possible, and doesn't require that you add any special syntax or metadata to your files to work.

Now that we have some Typst on our system, we can see Rheo at work:

```bash
rheo compile rheo.ohrg.org
```

This command produces a `build` subdirectory inside the base directory which contains a PDF, an EPUB, and a static site (HTML and CSS).
It's a little tiring to have to run the compile command every time we make a change, though. 
Let's spin up a development server to see live changes across all output formats as we edit the source:

```bash
rheo watch rheo.ohrg.org --open
```

The `--open` flag here indicates that we'd like to open the output using our system's default applications.
Provided you have an EPUB reader on your system (if you don't, we recommend installing #link("https://github.com/nota-lang/bene")[bene]), you should now have a PDF, an EPUB, and a website in front of you.
Huzzah!
