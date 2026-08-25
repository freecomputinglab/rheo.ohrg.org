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
Each call becomes one RevealJS `<section>` in the browser and a `SLIDE` marker in the PDF:

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

A slide's title is sticky rather than per-slide.
The package injects a title bar into the deck and repopulates it on every slide change from the current section's own title, so a slide that names no title keeps showing the last one that did --- which is what you want for a run of slides belonging to one part of a talk.
Pass `title: none` to clear the bar for a slide that should carry no heading at all.

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  table.header[*Argument*][*Default*][*Description*],
  [`title`],
  [`auto`],
  [
    The slide's title, shown in the deck's title bar.
    Left at `auto` the previous slide's title carries over; `none` clears the bar.
  ],

  [`transition`],
  [`auto`],
  [
    A per-slide override of the deck's transition, emitted as `data-transition` on that section.
    Left at `auto` (or set to `none`) the slide inherits whatever the deck is using.
    Any other value must be one of the transition names below, or the build fails naming it.
  ],

  [`inline`],
  [`false`],
  [
    Whether the slide's body is also typeset in the PDF, beneath its marker.
    See #link(<slides-pdf>)[PDF script output].
  ],
)

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

#table(
  columns: (auto, auto, 1fr),
  align: (left, left, left),
  table.header[*Argument*][*Default*][*Description*],
  [`theme`],
  [`"black"`],
  [
    One of RevealJS's #link("https://revealjs.com/themes/")[built-in themes], emitted as `data-theme` and used to pick the stylesheet the package injects at runtime.
    The accepted names are `beige`, `black`, `black-contrast`, `blood`, `dracula`, `league`, `moon`, `night`, `serif`, `simple`, `sky`, `solarized`, `white`, and `white-contrast`; anything else fails the build rather than silently falling back.
  ],

  [`transition`],
  [`none`],
  [
    The deck-wide transition: `none`, `fade`, `slide`, `convex`, `concave`, or `zoom`.
    Left unset, RevealJS's own default applies.
  ],

  [`first-slide`],
  [`none`],
  [
    Arbitrary Typst content, rendered as the opening slide.
  ],

  [`title`],
  [`none`],
  [
    The deck's title, seeding the title bar for every slide after the cover until a `slide(title: ...)` replaces it.
    Where `first-slide` is omitted, the opening slide becomes a level-1 heading containing this instead.
  ],
)

One of `first-slide` or `title` is required, and the template asserts as much rather than producing a deck with no cover.

== Configuring the spine

A single-file project needs no #link(<spines>)[spine] config at all --- the directory-scan default already includes `paper.typ`.
Give the PDF a title, if you'd like one:

```toml
[pdf.spine]
title = "My Presentation"
```

== PDF script output <slides-pdf>

The PDF is a script for the person giving the talk, not a printed copy of the deck.
Each `slide` call renders as a small red `SLIDE` marker in the flow of the prose, telling you where to advance; the slide's own body is left out, on the reasoning that a slide's content is a prompt for what you are about to say rather than part of the script.
Pass `inline: true` on a slide whose body you do want typeset beneath its marker.

This makes the PDF a working script, and it is why the same file can carry prose the deck never shows: anything outside a `#slide[...]` call is script-only, since the deck is assembled from the slide sections alone.

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
Writing overrides against these rather than against literal colours keeps them theme-agnostic, so switching `theme` doesn't strand your stylesheet on the old palette.

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*Property*][*What it holds*],
  [`--r-main-color`], [Foreground text colour.],
  [`--r-background-color`], [Slide background colour.],
  [`--r-main-font-size`], [Base font size, which slide-relative `em` sizes resolve against.],
  [`--r-heading-color`], [Heading colour.],
  [`--r-link-color`], [Link colour.],
)

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

*The title bar* --- the package appends it to `.reveal` as `.slide-title-bar`, so it is styled and positioned like any other element:

```css
.reveal .slide-title-bar { font-size: 0.5em; opacity: 0.6; }
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
