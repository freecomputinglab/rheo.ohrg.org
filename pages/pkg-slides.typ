#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "pkg-slides")

= Slides

The `@rheo/slides` package turns your Typst source file into two outputs simultaneously: a printable PDF script and an interactive #link("https://revealjs.com/")[RevealJS] presentation in the browser.
This means that after writing a talk's script in Typst, you can insert slides into sections of it (also written in Typst) and produce a slide deck alongside a script that is also annotated with markers noting when to go to the next slide.

== Installation

Import the package at the top of your slides source file:

```typst
#import "@rheo/slides:0.1.0": template, slide
```

== Defining slides

Use the `slide` function to mark each slide.
Each call becomes one RevealJS slide in the browser and a 'slide' marker in the PDF:

```typst
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

```typst
#show: template.with(
  theme: "white",
  transition: "slide",
  first-slide: [
    = My Presentation

    Author Name
  ],
)
```

- `first-slide` accepts arbitrary Typst content and is rendered as the opening slide.
- `theme` accepts any #link("https://revealjs.com/themes/")[built-in RevealJS theme] name.
- `transition` accepts any RevealJS transition name (`none`, `fade`, `slide`, `convex`, `concave`, `zoom`).

== Configuring the spine

Add your document to both spines in `rheo.toml`:

```toml
[html.spine]
vertebrae = ["paper.typ"]

[pdf.spine]
title = "My Presentation"
vertebrae = ["paper.typ"]
```

== PDF script output

In PDF output, each `slide` call renders as a headed section on standard paper.
The first slide content (passed via `first-slide`) becomes a title page.
Speaker notes, if included, appear below the slide body in a smaller typeface.

This makes the PDF suitable as a printed script or a supplementary handout alongside the live RevealJS presentation.

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

- `--r-main-color` — foreground text colour
- `--r-background-color` — slide background colour
- `--r-main-font-size` — base font size
- `--r-heading-color` — heading colour
- `--r-link-color` — link colour

Use them to keep your overrides theme-agnostic:

```css
.reveal .slides figcaption {
  border-top: 1px solid color-mix(in srgb, var(--r-main-color) 25%, var(--r-background-color));
}
```

=== Common overrides

*Title slide heading colour* — target the first slide's heading:

```css
.reveal .slides section:first-child h2 {
  color: #e7ad52;
}
```

*Font sizes* — scale slide body and captions independently:

```css
.reveal .slides > section    { font-size: 0.8em; }
.reveal .slides blockquote   { font-size: 0.9em; }
.reveal .slides figure       { font-size: 1.5em; }
.reveal .slides figcaption   { font-size: 0.4em; }
```

== Adding slides without losing your original paper styling

Typst's conditional rendering makes it easy to keep both a publishable, typeset paper _as well as_ its script and slides in the same Typst document.
The key is overloading the `slide` function, so that it simply returns an empty block when you're not building the presentational format of your paper.
This means that you can use the same Typst document and render via Rheo to both:
- Publishable PDF/HTML/EPUB
- A presentation with a PDF script with slide markers, and a RevealJS (HTML) slide deck.

For example, you can define a global boolean and shadow `slide` at the top of your document:

```typst
#let is-presentation = false

#let slide = if is-presentation { slide } else { (..args) => [] }
```

When `is-presentation` is `false`, every `#slide[...]` call produces no content, so the document compiles as a clean paper with none of the slide scaffolding visible.
Set it to `true` (and apply the `template` show rule) to build the presentation instead.
Both outputs live in the same source file — switch between them by toggling one variable.
The same boolean can drive other conditional styling.
For example, a paper might use double spacing while the script uses single spacing:

```typst
#set par(leading: if is-presentation { 0.65em } else { 1.3em })
```

Any show or set rule that differs between outputs can be gated on `is-presentation` in the same way.


