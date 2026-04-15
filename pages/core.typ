#import "index.typ": rheo-source-url, rheobook
#show: rheobook.with(current-page: "core")

= Core

Rheo is built around a plugin architecture.
At its center is a core engine that embeds the Typst compiler and provides shared infrastructure -- #link("./spines.typ")[spine] resolution, #link("./assets.typ")[asset] management, #link("./relative-linking.typ")[relative link] rewriting, and a development server with live reloading.
On top of this core, each output format is implemented as a _format plugin_.

== Format plugins

Typst natively supports PDF and, experimentally, HTML.
Rheo's architecture takes this further: rather than being limited to the formats that Typst itself can produce, Rheo defines a `FormatPlugin` trait that any output format can implement.
The EPUB format, for instance, is not something Typst supports at all -- it exists entirely as a Rheo format plugin that converts Typst's output into a standards-compliant EPUB archive.

Each format plugin declares:

- A *compilation target* -- whether it builds from Typst's paged (PDF) or HTML output.
- Whether it *merges* multiple source files into a single output, or produces one output per file.
- Any *assets* it needs -- such as the HTML plugin's CSS stylesheet and JavaScript entrypoint.
- Optional *template files* and *configuration* that are scaffolded when you run `rheo init`.

The core engine handles the rest: it discovers source files, resolves the spine for each format, copies assets, and invokes each plugin's compilation in turn.
If one format fails to compile a particular file, the others continue uninterrupted.

== An open architecture

Our hope is that this plugin architecture will inspire innovation at the format level.
Typst is a remarkably expressive document language, and we believe its utility extends well beyond the formats it natively targets.
By making it straightforward to implement new format plugins, Rheo opens the door to outputs we haven't yet imagined -- presentation slides, interactive notebooks, audiobook manifests, or formats that don't exist yet.

If you are interested in building a format plugin, take a look at the existing #link(rheo-source-url + "/tree/main/crates")[plugin implementations] for reference.
Adding a new plugin to Rheo requires only implementing the `FormatPlugin` trait and registering it in the CLI -- the core engine takes care of everything else.
