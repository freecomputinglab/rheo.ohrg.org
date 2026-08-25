#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "marrow")

= Marrow

Rheo projects treat `.marrow.typ` as a special file that allows you to programmatically generate extra files beyond the one-page-per-vertebra default.
In contrast to vertebrae, which are treated as normal Typst compiled to PDF or HTML, marrow is Typst run at the #link("https://typst.app/docs/reference/bundle/")[bundle root], meaning that you can write Typst in it to generate new documents and assets.
You can use marrow to programmatically derive artifacts such as feeds, sitemaps, search indexes, and generated pages.

== Crafting marrow

Create a file named `.marrow.typ` at the top of your content directory, next to your ordinary pages.
Inside this file (and only there), `document()` and `asset()` are in scope:

```typ
#document("extra/hello.html", format: "html", title: [Extra])[Hello from the bundle root.]
#asset("extra/hello.txt", "root-level asset")
```

Compiling this produces `extra/hello.html` and `extra/hello.txt` in your build output, sitting alongside whatever your ordinary vertebrae produce.
For more information on what is valid Typst in marrow, see the #link("https://typst.app/docs/reference/bundle/")[Typst bundle documentation].

If you'd rather call the file something else, set the top-level `marrow` key in `rheo.toml`, resolved against `content_dir` in `rheo.toml`:

```toml
marrow = "bundle-root.typ"
```

Note that marrow will never produce a `.marrow.html` of its own, and it never appears in the #link(<spines>)[spine], the sidebar navigation, or a template's prev/next pager.

Marrow runs once per *per-page* output format on every compile and every dev-server rebuild.
The combined PDF target skips it entirely, because `document()` and `asset()` both hard-error there.
Typst reserves them for the bundle target, and a combined PDF has no bundle to speak of.

A page marrow mints is still a first-class Rheo page in every other sense.
It receives the same head-asset injection as an ordinary vertebra, and any root-level `#set`/`#show` rule from your template still applies inside it.

== Reading across the spine

A Rheo bundle compiles in a single Typst pass, and Typst's own bundle mechanism shares one introspector across every file in it.
That means marrow can read `state(...)` and query labels registered by ordinary vertebrae elsewhere in the project.
Marrow thus lets a package or project turn data scattered across many pages into pages of its own, without a stub `.typ` file per entry:

```typ
// across various vertebrae in the spine...
#state("notes", ()).update(old => old + (my-note,))

// in .marrow.typ
#context {
  for n in state("notes", ()).final() {
    document("notes/" + n.name + ".html", format: "html", title: [Note])[#n.body]
  }
}
```

Typst has no facility for enumerating files on disk, so marrow can never discover content by scanning your project directory itself---only by reading `state`, labels, or `sys.inputs.rheo-context`, all of which have to have been populated by something else in the bundle first.

// A `#show` rule written inside marrow only affects content declared *after* it---in practice, the pages marrow itself goes on to mint---and does not reach back into vertebrae that already exist elsewhere in the project, because marrow is spliced in after every ordinary page, not before it.
