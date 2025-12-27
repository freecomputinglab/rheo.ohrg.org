#import "index.typ": rheobook 
#show: rheobook.with(current-page: "relative-linking")

Rheo's design philosophy is to allow you to write pure #link("https://typst.app/docs/")[typst] as much as possible, without requiring any additional syntax or metadata. 
Because rheo wants to make it easy to create a website or to split a large writing project up into multiple files, however, we need a way to reference other files in the same rheo project.

The syntax for relative links in rheo should be familiar, as it is just a regular typst link with a `.typ` file in the same directory as its target:

```typ
#link("./another-section.typ")[Another section]
```

When you compile a project with rheo, relative links to other typst files in the same directory will be resolved and transformed in the output format.
What a relative link transforms to depends on both the output format and your rheo configuration, as using features such as #link("./spines.typ")[spines] affects the control flow between your source typst and your output formats.

- In *html*, relative links become `<a>` tags that point to the relevant html page.
- In *pdf*, relative links either become plain text (if each typst source file maps to one output pdf), or become links to the relevant sections in the output document (if your rheo config specifies a pdf spine). 
- In *epub*, relative links become links to the relevant sections in the epub (as a spine is required). 

Relative linking is what allows rheo to function as a static site engine.
It is also a feature that you can use to help you organize large writing projects with rheo.
(Note that the typst #link("https://typst.app/docs/reference/foundations/module/")[`import`] keyword works as you would expect in rheo, and so can also/still be used to modularize projects.)
