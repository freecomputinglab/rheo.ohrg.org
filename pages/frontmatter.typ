#context if target() != "html" {
  set text(font: ("Inter", "San Francisco", "Arial"))
  set page(
    margin: (top: 0pt, bottom: 2cm, left: 0pt, right: 0pt),
  )

  align(center)[
    #box(
      width: 100%,
      height: 25%,
      clip: true,
      image("img/header.svg", width: 100%, height: 100%, fit: "cover")
    )
  ]


  pad(left: 3cm, right: 3cm)[
    #v(1em)
    #outline(title: none)
  ]

  pagebreak()
}
