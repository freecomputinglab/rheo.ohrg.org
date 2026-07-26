#import "index.typ": rheo-source-url, sidebar-site
#show: sidebar-site.with(current: "core")

= Core

Rheo has a plugin architecture.
At its center is a core engine that embeds the Typst compiler and provides shared infrastructure such as #link(<spines>)[spine] resolution, #link(<assets>)[asset] management, #link(<relative-linking>)[relative link] rewriting, and a development server with live reloading.
On top of this core, each output format is implemented as a _format plugin_.

== Format plugins

Typst natively supports PDF and, experimentally, HTML.
Rheo defines a `FormatPlugin` trait that can be implemented to produce additional formats beyond those that Typst natively supports.
For example, Rheo #link(<format-epub>)[supports EPUB] as a format plugin, enabling the productino of a standards-compliant EPUB archive from source Typst.

Each format plugin declares:

- A *compile function* specifying how build output files should be produced from the source #link(<spines>)[spine].
- Any #link(<format-specific>)[format-specific assets] it needs -- such as the HTML plugin's CSS stylesheet and JavaScript entrypoint.
- Optional template files and configuration that are scaffolded when you run `rheo init`.

The core engine handles discovers source files, resolves the spine for each format, copies assets, and invokes each plugin's compilation in turn.

== An open architecture

Our hope is that this plugin architecture will inspire innovation at the format level.
Typst is a remarkably expressive document language, and we believe its utility extends well beyond the formats it natively targets.

We have built Rheo as infrastructure for #link("https://chi-star-workshop.github.io/src/assets/pdf/papers/DocumentInfrastructureForAugmentedReading%20-%20Will%20Crichton.pdf")[augmented reading research].
Reading augmentations -- features like hyperlink previews, contextual definitions, interactive visualizations, and explorable explanations -- can be implemented either as Typst library functions (at the language level) or as Rheo format plugins (at the compiler level).
The #link("https://github.com/freecomputinglab/rheo-packages")[Rheo packages repository] gives various examples of how custom Typst functions coupled with format-specific assets (such as JS and CSS in the case of HTML) can produce augmentations, both in the browser and in the other formats Rheo supports.
