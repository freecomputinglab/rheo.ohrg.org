#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "marrow")

= Marrow

The simple answer is that marrow is a file, `.marrow.typ`, that lets you mint extra output files from a Rheo project beyond the one-page-per-vertebra default.
The less simple answer is that marrow is Typst run at the *bundle root*---outside every `#document(...)` block Rheo synthesizes for your ordinary pages---where the native Typst `document()` and `asset()` elements are legal to call directly.
Derived artifacts like feeds, sitemaps, search indexes, and generated index pages belong in Typst rather than in a Rust plugin, and marrow is the seam that makes that possible: Rheo's job is only to provide the primitives, not to own every output file itself.

== Writing a marrow file

Drop a file named `.marrow.typ` at the top of your content directory, next to your ordinary pages, and Rheo inlines its text at the bundle root on every build.
Inside it, and only there, `document()` and `asset()` are in scope:

```typ
#document("extra/hello.html", format: "html", title: [Extra])[Hello from the bundle root.]
#asset("extra/hello.txt", "root-level asset")
```

Compiling this produces `extra/hello.html` and `extra/hello.txt` in your build output, sitting alongside whatever your ordinary vertebrae produce.
`document()` mints a page; `asset()` writes bytes verbatim, with no Typst compilation of its own.

If you'd rather call the file something else, set the top-level `marrow` key in `rheo.toml`, resolved against `content_dir` exactly like any other content path:

```toml
marrow = "bundle-root.typ"
```

Whatever it's named, a marrow file is never a vertebra in its own right.
It produces no `.marrow.html` of its own, and it never appears in the #link(<spines>)[spine], the sidebar navigation, or a template's prev/next pager---only the pages it explicitly mints with `document()` do.

== When marrow runs

Marrow runs once per *per-page* output format---HTML, EPUB---on every compile and every dev-server rebuild.
The combined PDF target skips it entirely, because `document()` and `asset()` both hard-error there: Typst reserves them for the bundle target, and a combined PDF has no bundle to speak of.

A page marrow mints is still a first-class Rheo page in every other sense.
It receives the same head-asset injection as an ordinary vertebra---a minted `extra/hello.html` carries `<link rel="stylesheet" href="../rheo-default.css">`, with the relative path adjusted for its own depth in the output tree---and any root-level `#set`/`#show` rule from your template still applies inside it.

== Reading across the bundle

A Rheo bundle compiles in a single Typst pass, and Typst's own bundle mechanism shares one introspector across every file in it.
That means marrow can read `state(...)` and query labels registered by ordinary vertebrae elsewhere in the project, which is the actual reason the feature exists: it lets a package or project turn data scattered across many pages into pages of its own, without a stub `.typ` file per entry.
The shape looks like this:

```typ
#context {
  for n in state("notes", ()).final() {
    document("notes/" + n.name + ".html", format: "html", title: [Note])[#n.body]
  }
}
```

Any vertebra elsewhere in the project registers into `"notes"` however it likes---`state("notes", ()).update(old => old + (my-note,))`, say---and marrow mints one page per entry once the whole bundle has been seen.
This is also `@rheo/feeds`'s own trick for minting an Atom feed with no Rust code, no plugin, and no `rheo.toml` keys of its own: packages configure it by registering into a state, and its own marrow file does the minting.

Two things are worth knowing about the limits of this introspection.
First, Typst has no facility for enumerating files on disk, so marrow can never discover content by scanning your project directory itself---only by reading `state`, labels, or `sys.inputs.rheo-context`, all of which have to have been populated by something else in the bundle first.
Second, a `#show` rule written inside marrow only affects content declared *after* it---in practice, the pages marrow itself goes on to mint---and does not reach back into vertebrae that already exist elsewhere in the project, because marrow is spliced in after every ordinary page, not before it.

== Packages can contribute marrow too

A Typst package can ship its own `.marrow.typ` at the root of the package, and Rheo inlines it exactly as it would your project's own---no `rheo.toml` entry, no manifest key in `typst.toml`, nothing to configure.
Importing the package anywhere in your project is the only trigger.
Every imported package's marrow is inlined first, in import order, and your project's own marrow is spliced in last, on top of whatever they've registered---all of them, every time, so renaming your project's marrow file can never silently suppress a package's contribution, or the other way around.

If you'd rather turn all of this off, setting `[html] auto_detect_packages = false` disables every form of automatic package-driven behaviour that importing a package can trigger---marrow included, alongside the automatic asset injection described in #link(<packages>)[Packages].

There is one sharp edge worth knowing if you're writing a package's marrow yourself.
Its text is spliced verbatim into *your project's* bundle root, so any relative path inside it resolves against the project root---not `content_dir`, and not the package's own directory on disk.
A package's marrow therefore has to reach its own code by package spec, `#import "@namespace/name:version"`, never by a relative import: a relative path that looks like it points at the package's own files will instead be resolved against whatever the importing project happens to keep there.

== EPUB

Marrow's `document()` and `asset()` calls both work under EPUB compilation as well as HTML.
A minted page is packaged into the EPUB container as an ordinary file, but---in keeping with marrow never producing a vertebra---it does not join the book's reading order (`package.opf`'s spine) or its `nav.xhtml` table of contents.
A minted `asset()`, unlike its HTML counterpart, is embedded directly inside the EPUB container with its own manifest entry, rather than being written as a loose file beside the `.epub` itself.
