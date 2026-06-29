#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "relative-linking")

Rheo allows you to write documents in plain #link("https://typst.app/docs/")[Typst] without requiring any additional syntax or metadata.
Because Rheo can combine multiple files into unified outputs, however, we need a way to reference other files in the same Rheo project.

Rheo assigns every source document a _handle_ --- a short label derived from its path --- and you link between documents using standard Typst label syntax:

```typ
#link(<intro>)[Introduction]
#link(<chapters:intro>)[Chapter introduction]
```

When you compile a project with Rheo, these links are resolved and transformed according to the output format.

- In *HTML*, relative links become `<a>` tags that point to the relevant html page.
- In *PDF*, relative links become internal links to the relevant section in the single combined output PDF.
- In *EPUB*, relative links become links to the relevant sections in the EPUB.

== Handle assignment

Every `.typ` file in your content directory gets a canonical handle derived from its path relative to that directory.

- *Root-level files* get a bare handle: `content/intro.typ` → `<intro>`.
- *Nested files* get a path-qualified handle using `:` as the path separator: `content/chapters/intro.typ` → `<chapters:intro>`, `content/a/b/notes.typ` → `<a:b:notes>`.

`:` and `.` are valid Typst label characters; `/` is not, which is why `:` is used as the separator.

== Escape form

The alias `<handle.typ>` is always available for every vertebra, regardless of other labels in the project:

```typ
#link(<intro.typ>)[Introduction]         // root file
#link(<chapters:intro.typ>)[Chapter intro] // nested file
```

Use the escape form when the canonical handle would be ambiguous or when you want to be explicit about which file you are linking to.

== Canonical-skip rule

If you have authored a label in your source that matches the canonical handle for a file, Rheo silently skips injecting the automatic label for that file.
The file remains reachable via its escape form.

```typ
// chapters/intro.typ
= Chapter Introduction <chapters:intro>  // user-authored; Rheo skips auto-injection

// elsewhere
#link(<chapters:intro>)[...]    // resolves to the user label
#link(<chapters:intro.typ>)[...] // escape form also works
```

== Escape-label collision error

If any source file defines a label that matches the escape form of another file (e.g. `<chapters:intro.typ>`), Rheo aborts the build with an error naming the offending file and label.
This prevents silent ambiguity.

== Migrating from older Rheo versions

Before 0.4.0, relative links were written by pointing at the target's file path directly:

```typ
#link("./another-section.typ")[Another section]
```

This syntax still works, but the handle form above is now preferred.
See #link(<migrate>)[Migrating projects] for how to upgrade an existing project automatically.
