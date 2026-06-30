#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "pkg-slides")

= Slides

The `@rheo/slides` package turns your Typst source file into two outputs simultaneously: a printable PDF script and an interactive #link("https://revealjs.com/")[RevealJS] presentation in the browser.
This means that after writing a talk's script in Typst, you can insert slides into sections of it (also written in Typst) and get a readable version.
You can always still export the script alone, meaning that you can keep both a publishable typeset paper and its presentational form with accompanying slides in the same Typst document.

== Installation

Import the package at the top of your slides source file:

```typst
#import "@rheo/slides:0.1.0": template, slide
```

== Defining slides

Use the `slide` function to mark each slide.
Each call becomes one RevealJS slide in the browser and one section in the PDF:

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

`first-slide` accepts arbitrary Typst content and is rendered as the opening slide.
`theme` accepts any #link("https://revealjs.com/themes/")[built-in RevealJS theme] name.
`transition` accepts any RevealJS transition name (`none`, `fade`, `slide`, `convex`, `concave`, `zoom`).

== Configuring the spine

Add your document to both spines in `rheo.toml`:

```toml
[html.spine]
vertebrae = ["slides.typ"]

[pdf.spine]
title = "My Presentation"
vertebrae = ["slides.typ"]
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
