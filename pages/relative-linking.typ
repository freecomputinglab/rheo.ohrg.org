#import "index.typ": rheobook 
#show: rheobook.with(current-page: "relative-linking")

Rheo allows you to write documents in plain #link("https://typst.app/docs/")[Typst] without requiring any additional syntax or metadata. 
Because Rheo can combine multiple files into unified outputs, however, we need a way to reference other files in the same Rheo project.

The syntax for these relative links in Rheo should be familiar, as they look just like regular Typst links, but reference a `.typ` file in the same directory as its target:

```typ
#link("./another-section.typ")[Another section]
```

When you compile a project with Rheo, relative links to other Typst documents in the same directory will be resolved and transformed according to the output format.
What a relative link transforms to depends on both the output format and your Rheo configuration, as using features such as #link("./spines.typ")[spines] affects the control flow between your source Typst and output formats.

- In *HTML*, relative links become `<a>` tags that point to the relevant html page.
- In *PDF*, relative links either become plain text (if input Typst is not combined, and thus produces one PDF per source document), or links to the relevant sections in the output document (if your config specifies a spine with the `merge` attribute set). 
- In *EPUB*, relative links become links to the relevant sections in the EPUB. 

Relative linking is what allows Rheo to produce fully functinoal static sites.
It is also a feature that you can use to help you organize large writing projects.
(Note that the Typst #link("https://typst.app/docs/reference/foundations/module/")[`import`] keyword works as you would expect in Rheo, and so can also/still be used as a mechanism to modularize projects.)
