#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "relative-linking")

Rheo allows you to write documents in plain #link("https://typst.app/docs/")[Typst] without requiring any additional syntax or metadata.
Because Rheo can combine multiple files into unified outputs, however, we need a way to reference other files in the same Rheo project.

Rheo assigns every source document a _handle_ --- a short label derived from its filename --- and you link between documents using standard Typst label syntax:

```typ
#link(<another-section>)[Another section]
```

Here `another-section` is the handle for `another-section.typ` in your content directory.
The handle is the file's stem (its name without the `.typ` extension), taken relative to the #link(<content-dir>)[content directory].

+ *Bare handle:* when a stem is unique across the project, the handle is just the stem: `content/intro.typ` → `#link(<intro>)`.
+ *Path-qualified handle:* if two files share a stem (say `content/intro.typ` and `content/chapters/intro.typ`), rheo qualifies the nested one to disambiguate: `#link(<chapters-intro>)` (using `-` as the separator). The root-level file keeps the bare handle.
+ *Escape form:* the alias `#link(<intro.typ>)` --- handle plus `.typ` suffix --- is always available, regardless of collisions.

When you compile a project with Rheo, these links are resolved and transformed according to the output format.
What a link transforms to depends on the output format and your Rheo configuration, as using features such as #link(<spines>)[spines] affects the control flow between your source Typst and output formats.

- In *HTML*, relative links become `<a>` tags that point to the relevant html page.
- In *PDF*, relative links become internal links to the relevant section in the single combined output PDF.
- In *EPUB*, relative links become links to the relevant sections in the EPUB.

Relative linking is what allows Rheo to produce fully functional static sites.
It is also a feature that you can use to help you organize large writing projects.
(Note that the Typst #link("https://typst.app/docs/reference/foundations/module/")[`import`] keyword works as you would expect in Rheo, and so can also/still be used as a mechanism to modularize projects.)

== Migrating from older Rheo versions

Before 0.4.0, relative links were written by pointing at the target's file path directly:

```typ
#link("./another-section.typ")[Another section]
```

This syntax still works, but the handle form above is now preferred.
To move an existing project onto the new syntax, run the `migrate` command from within the project directory:

```bash
rheo migrate path/to/project
```

By default this is a dry run that reports each link it would rewrite; pass `--apply` to write the changes.
