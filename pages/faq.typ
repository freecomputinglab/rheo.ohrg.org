#import "index.typ": rheobook, rheo-source-url, fcl-zulip-join-url
#show: rheobook.with(current-page: "FAQ")

= Frequently Asked Questions

== What is the difference between Typst and Rheo?

#link("https://typst.app/")[Typst] is a markup/programming language that provides its own toolchain which includes a CLI.
You can use the Typst CLI to compile one Typst document to one kind of output file:

```sh
typst compile source.typ # compile to PDF
typst compile --features html --format html source.typ # compile to HTML
```

Rheo compiles a _project folder_ to three outputs---PDF, HTML, and EPUB---concurrently.
It allows you to configure how certain source files should be merged (to produce a 'combined' EPUB or PDF file, for example, via #link("./spines.typ")[spines]), and also allows you to enrich certain outputs (such as HTML via #link("./custom-css.typ")[custom CSS]) with non-Typst content.
Rheo supports EPUB natively, which is not currently supported by the upstream Typst CLI (though it is #link("https://github.com/typst/typst/issues/188")[on the roadmap]).
In summary, Rheo is a opinionated way to manage writing projects with Typst. 

== How do I read EPUBs on my system?
Mileage varies greatly on EPUB reading niceness across systems!
If you're interested to learn more, we have written more about this #link("https://willcrichton.net/notes/portable-epubs/")[here].
If you don't have a good EPUB reading experience currently, we recommend trying #link("https://github.com/nota-lang/bene")[bene], an EPUB reading system that we are developing.

== Who maintains Rheo?

Rheo is developed by the #link("https://freecomputinglab.ohrg.org/")[Free Computing Lab], an academic research consortium that researches the nature of computing freedom.
If you're interested to learn more or get involved, you can #link(fcl-zulip-join-url)[join our Zulip].

== Can I contribute to Rheo? 
Yes!
Rheo is written in Rust and developed in public through #link(rheo-source-url)[Github].
You can track development and submit issues or requests for features through that platform.
While in principle we welcome community pull requests, it's best to #link(fcl-zulip-join-url)[join our Zulip] and ask about it first, to confirm that your work will not go to waste.
