#context if target() != "html" {
  set page(
    margin: (top: 1in, bottom: 2cm, left: 0pt, right: 0pt),
  )

  align(center)[
    #box(
      width: 100%,
      height: auto,
      clip: true,
      image("img/header.svg", width: 15%, height: auto, fit: "cover")
    )
  ]


  pad(left: 1.5in, right: 1.5in)[
    #outline(title: none)
  ]

  pagebreak()
}
