#context if target() != "html" {
  set page(
    margin: (top: 0pt, bottom: 2cm, left: 0pt, right: 0pt),
  )

  align(center)[
    #box(
      width: 100%,
      height: auto,
      clip: true,
      image("img/header.svg", width: 15%, height: auto, fit: "cover")
    )
  ]


  pad(left: 3cm, right: 3cm)[
    #outline(title: [Rheo documentation])
  ]

  pagebreak()
}
