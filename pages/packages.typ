#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "packages")

= Packages

A Rheo package is a standard #link("https://typst.app/universe/")[Typst Universe] package that ships its own web assets --- CSS, JavaScript, or files to copy --- alongside its Typst code.

== Using packages

To use a Rheo-compatible package, import it in your Typst source files as you normally would:

```typ
#import "@rheo/tooltip:0.1.0": tooltip
```

That's all!
Just like the Typst CLI, Rheo will prewarm the `@rheo` namespace so that all of the #link("https://github.com/freecomputinglab/rheo-packages")[existing packages] are available.
When Rheo compiles your project, it reads every `#import` statement in your content files, identifies any Typst Universe and Rheo packages, and makes them available in your project.

A Rheo package is essentially a Typst package that can also provide #link(<assets>)[assets].
A package can declare assets that will be injected into a format's build folder automatically --- behaving exactly like a manually configured `[[html.assets]]` block.

This is particularly useful in HTML, as it means that we can essentially expose JS/CSS libraries through a Typst API to our project, as the #link(<pkg-slides>)[slides package] does for #link("https://revealjs.com/")[RevealJS].
(See #link(<custom-js-css>)[Custom JS/CSS] for details on what that means for the build output in HTML.)

A package doesn't have to ship a bundle at all, though --- #link(<atom-feeds>)[`@rheo/feeds`] is pure Typst, and generates a project's Atom, RSS, or JSON feeds from a plain `configure(...)` call, no CSS or JavaScript involved.

=== Turning off automatic detection

Everything above happens without you asking for it: Rheo reads every `#import` in your content files, and for each one that resolves to a locally-cached package, it goes looking in that package's own `typst.toml` for a `[tool.rheo.<format>]` section and for a bundle-root marrow file to splice in.
A project that would rather keep full control of what gets injected --- or that has run into a package whose auto-detected assets or marrow collide with something authored by hand --- can turn this off, one format at a time:

```toml
[html]
auto_detect_packages = false
```

The key defaults to `true`.
Setting it to `false` under a format's own table (`[html]`, `[epub]`, or `[pdf]`) disables auto-detection for that format alone; the others keep scanning as before.
It switches off both halves of what auto-detection does --- a package's declared assets and any marrow it ships --- not just one of them, so a project that disables it and still wants a package's CSS or JS has to add that back explicitly, as an ordinary `[[html.assets]]` block (see #link(<assets>)[Assets]).
It does not, however, touch the version floor described next: a package's declared `min_version` is still checked even with auto-detection off, because Rheo settles whether a package is too old for this build before it ever decides whether to go looking at that package's assets.

== Creating a Rheo-compatible package

If you are authoring a Typst Universe package and want to ship assets that integrate with Rheo's HTML output, add a `[tool.rheo.html]` section to your package's `typst.toml`:

```toml
[package]
name = "rheo-tooltip"
version = "0.1.0"
entrypoint = "lib.typ"

[tool.rheo.html]
js_scripts = "dist/index.js"
css_stylesheets = "dist/index.css"
```

The `[tool.rheo.html]` section accepts the same fields as `[[html.assets]]`:

- `js_scripts` --- path to a JavaScript file to inject into HTML pages.
- `css_stylesheets` --- path to a CSS file to inject into HTML pages.
- `copy` --- glob patterns for additional files to copy into the HTML build.

Paths are relative to the package root and are resolved against the package's location in the local Typst package cache.
When a user imports your package and builds their Rheo project, your assets are injected without any extra steps on their part.

=== Requiring a minimum Rheo version

A package can also declare the oldest Rheo it works with, in a `[tool.rheo]` table alongside (or instead of) the format-specific asset section above:

```toml
[tool.rheo]
min_version = "0.6.0"
```

This is a floor, not a range --- there's no caret, no upper bound, nothing like Cargo's `^0.6` --- just the single oldest version the package is willing to run under.
Leave it out and Rheo does no check at all: an unversioned package resolves against whatever Rheo happens to be running, for better or worse.
Where a project imports a package whose declared floor is above the running Rheo, the build fails before any Typst compile even starts, naming every offending import on its own line, so that a project pulling in several stale packages at once learns about all of them from a single build rather than discovering the next one on the next run:

```
@acme/widgets:1.0 needs rheo >= 0.8.0, but this is rheo 0.6.0
@acme/charts:2.0 needs rheo >= 0.9.0, but this is rheo 0.6.0
Upgrade rheo: https://rheo.ohrg.org
```

A package that isn't resolved locally, has no manifest, or simply never sets `min_version` is never an offender --- the check only fires on a floor that's actually declared, and actually too high.

Where you put `[tool.rheo]` in `typst.toml` matters more than it looks like it should.
A bare key written straight after a `[tool.rheo.<format>]` header belongs to that subtable, not to the package as a whole, so a `min_version` added carelessly next to your asset block silently becomes `tool.rheo.<format>.min_version` --- syntactically fine, and read by nothing.
Give it its own `[tool.rheo]` header, and if you also ship a `[tool.rheo.<format>]` section, the safest habit is the one #link(<atom-feeds>)[`@rheo/feeds`] uses: keep the bare `[tool.rheo]` table last in the file, so nothing declared afterwards can swallow it.

`min_version` is only as strong as the Rheo doing the resolving: it's checked by every Rheo from 0.6.0 onward, but a Rheo old enough to predate that release doesn't know the key exists, and silently ignores it --- which defeats the whole point for exactly the builds you most want to catch.
A package that wants to fail loudly even there has to assert its own floor from inside its own Typst, by reading `rheo-context()`'s `rheo-version` field (see #link(<rheo-context>)[Rheo context]) and treating its *absence* --- rather than any particular value --- as the signal that this Rheo predates the field entirely.
`@rheo/feeds` does exactly this: its `configure(...)` and `emit(...)` entry points both assert the floor before doing anything else, so a Rheo that lacks `rheo-version` fails the same way a too-old declared floor does, just from Typst rather than from Rheo itself.
