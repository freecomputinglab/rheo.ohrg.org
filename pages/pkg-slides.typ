#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "pkg-slides")

= Slides

The `@rheo/slides` #link(<packages>)[package] turns one Typst source file into two outputs simultaneously: a printable PDF script and an interactive #link("https://revealjs.com/")[RevealJS] presentation in the browser.
Write a talk's script in Typst, insert slides into sections of it (also written in Typst), and you get a slide deck alongside a script annotated with markers noting when to advance.

== Importing the package

Import the package at the top of your slides source file:

```typ
#import "@rheo/slides:0.1.0": template, slide
```

== Defining slides

Use the `slide` function to mark each slide.
Each call becomes one RevealJS slide in the browser and a 'slide' marker in the PDF:

```typ
#slide(title: [Introduction])[
  Lorem ipsum dolor sit amet, consectetur adipiscing elit.
  Slides can contain any Typst content: lists, figures, math, citations.
]

#slide(title: [Methods])[
  - Step one: collect data
  - Step two: process data
  - Step three: analyse results
]
```

The `title` argument is optional.
When omitted, the slide renders without a heading in both outputs.

== Applying the template

Wrap your document with the `template` show rule to activate the layout:

```typ
#show: template.with(
  theme: "white",
  transition: "slide",
  first-slide: [
    = My Presentation

    Author Name
  ],
)
```

- `first-slide` --- arbitrary Typst content, rendered as the opening slide.
- `theme` --- any #link("https://revealjs.com/themes/")[built-in RevealJS theme] name.
- `transition` --- any RevealJS transition name (`none`, `fade`, `slide`, `convex`, `concave`, `zoom`).

== Configuring the spine

A single-file project needs no #link(<spines>)[spine] config at all --- the directory-scan default already includes `paper.typ`.
Give the PDF a title, if you'd like one:

```toml
[pdf.spine]
title = "My Presentation"
```

== PDF script output

In PDF output, each `slide` call renders as a headed section on standard paper.
The first slide's content, passed via `first-slide`, becomes a title page.
Speaker notes, if included, appear below the slide body in a smaller typeface.
This makes the PDF suitable as a printed script or a supplementary handout alongside the live presentation.

== Customising the RevealJS CSS

The `@rheo/slides` package injects its own base stylesheet automatically.
To layer project-specific overrides on top, attach a CSS file via `[[html.assets]]` in `rheo.toml`:

```toml
[[html.assets]]
css_stylesheet = "style.css"
```

Your `style.css` loads after the package base styles, so any rule you write wins.

=== RevealJS CSS variables

RevealJS themes expose CSS custom properties you can reference anywhere in your stylesheet.
The most useful ones:

- `--r-main-color` --- foreground text colour
- `--r-background-color` --- slide background colour
- `--r-main-font-size` --- base font size
- `--r-heading-color` --- heading colour
- `--r-link-color` --- link colour

Use them to keep your overrides theme-agnostic:

```css
.reveal .slides figcaption {
  border-top: 1px solid color-mix(in srgb, var(--r-main-color) 25%, var(--r-background-color));
}
```

=== Common overrides

*Title slide heading colour* --- target the first slide's heading:

```css
.reveal .slides section:first-child h2 {
  color: #e7ad52;
}
```

*Font sizes* --- scale slide body and captions independently:

```css
.reveal .slides > section    { font-size: 0.8em; }
.reveal .slides blockquote   { font-size: 0.9em; }
.reveal .slides figure       { font-size: 1.5em; }
.reveal .slides figcaption   { font-size: 0.4em; }
```

== Keeping your original paper styling

Typst's conditional rendering lets you keep a publishable, typeset paper _as well as_ its script and slides in the same document.
The trick is to overload the `slide` function so that it returns an empty block when you are not building the presentational format, which means one source file renders through Rheo to both:

- a publishable PDF, HTML, or EPUB, and
- a presentation --- a PDF script with slide markers, and a RevealJS slide deck.

Define a global boolean and shadow `slide` at the top of your document:

```typ
#let is-presentation = false

#let slide = if is-presentation { slide } else { (..args) => [] }
```

When `is-presentation` is `false`, every `#slide[...]` call produces no content, so the document compiles as a clean paper with none of the slide scaffolding visible.
Set it to `true` (and apply the `template` show rule) to build the presentation instead.
The same boolean can drive other conditional styling --- a paper might use double spacing while the script uses single spacing:

```typ
#set par(leading: if is-presentation { 0.65em } else { 1.3em })
```

Any show or set rule that differs between outputs can be gated on `is-presentation` in the same way.
