#import "index.typ": rheobook 
#show: rheobook.with(current-page: "what-and-why-is-rheo")

= What and why is rheo?

Rheo (_ree-oh_) is a source static site engine for Typst documents with source code that is openly #link("https://github.com/breezykermo/rheo")[available on GitHub].
Most static site engines these days employ Markdown, a markup format that is approachable and pretty generic, allowing folks who are not familiar with or otherwise don't want to deal directly with the required file formats of the web--- HTML, CSS, and Javascript--- to write blog posts and other content which can then be pumped into a static site.
('Static' here just means that the website produced doesn't require communication with a backend server to fill it out with content: the website is a self-sufficient set of files.)

Markdown has some ambiguities, however.
The most problematic one for academic work is the lack of standardized syntaxes for citations and footnotes.
Though extensions exist that can produce these, they are not supported in the core Markdown syntax, meaning that it's not _really_ Markdown and can't be relied upon to work in all contexts that support Markdown.
Similary, while Markdown's core supports a lot of what you want in hypertext--- hyperlinks, images, text decorations such as bold and italics, headings, etc--- it is limited when it comes to the styling one needs in fully fledged academic documents such as tables, figures, and math markup.
Furthermore, Markdown doesn't support programmatic constructs such as variables and loops.
In practice, therefore, it is often combined with an additional templating language in static site engines so that these constructs are available to the user, introducing further fragmentation in the ecosystem (of Markdown static site engines) as well as complexities produced at the interface (between Markdown and the templating language). 

Typst is a markup language that ergonomically and elegantly integrates with plain text, like Markdown, making it easy to adopt and joyful to write.
It is also a Turing-complete programming language with a modern type system, meaning that it is possible (though not necessary) to express sophisticated conditional logic controlling where and how text is rendered.  
Typst has a concrete and concise syntax for footnotes and citations, and can express visual constructs such as tables, figures, colors, and mathematical formulas. 
It was developed as a modern alternative to LaTeX, Leslie Lamport's legendary 1980s addition to Donald Knuth's original '78 Tex typesetting system.
For the past 40 years, LaTeX has been the most expressive way to produce pdf documents, rendering it the de facto standard for academic and scientific publication.
In the past few years, Typst has become the most promising and powerful alternative to LaTeX due to its maintainers' effort to build out a reliable PDF compilation toolchain.

Typst's development in 2025 has seen HTML added as an experimentally supported compilation target.
Though there are still many features in Typst that will only produce meaningful output in the PDF toolchain, the HTML toolchain now supports all of the essential features for academic documents in the humanities: text decoration, headings, hyperlinks, footnotes, and citations.
#footnote[
  I qualify this with 'in the humanities' as scientific papers often require tables, figures, and mathematical markup.
  These features are on Typst's roadmap for html, but are not yet available at time of writing (January 2026).]
This makes it an extremely good replacement for Markdown as a markup language in a static site engine, and so: enter Rheo.

Rheo is a CLI (command line interface) that produces PDF, HTML, and EPUB simultaneously from a folder of Typst documents.
It is a static site engine because it can produce a fully valid website: all it needs is a folder containing valid Typst.
Rheo also provides mechanisms to combine multiple Typst files into a unified EPUB or PDF, making it a tool that improves the experience of writing books, dissertations, or any other long-form text in Typst.
On the other side of the same coin, Rheo allows you to produce an offline version of a website such as a blog written in Typst through its PDF/EPUB toolchain.

Naturally, this blog post was #link("https://github.com/freecomputinglab/rheo.ohrg.org/pages/what-and-why-is-rheo.typ")[written with Typst], and this site was made with Rheo.
If you're already convinced, feel free to jump ahead to #link("./getting-started.typ")[Getting Started] to download Rheo on your system and get building. 

== The philosophy of Rheo
Rheo is a prefix or combining form in English that originates from the Greek word _rheos_ (ῥέος), meaning flow, stream, or current.
The most straightforward etymological interpretation here is that Rheo flows Typst documents into a number of concurrent output formats in PDF, HTML, and EPUB.
But other meanings lurk beneath the surface of this basic idea.
Sarah Pourciau has argued that the oceanic is a deep-rooted metaphor in computing, as all computation at some level seeks solid space in a sea of digital noise @pourciauDigitalOcean2022.
From Alan Turing's partial solution to David Hilbert's _Entscheidungsproblem_ in the universal machine, to Claude Shannon's information theory, to Leslie Lamport's ordering of events in a distributed system, the key issue at hand is how to carve out clarity from uncertainty and confusion.
Writing has played a magisterial role in calming the storm of imprecise thought.
Long before computation arrived on the scene, the written word has served as the steward of reason, in the Western world and beyond, from Mesopotamian cunieform to Twitter.
_Nota bene_ ('Take note'): that writing can also herald chaos and confusion doesn't invalidate its capacity for spreading sensibility.

Rheo is a tool that facilitates the production and publication of documents following from the original vision of the Internet as a mechanism for lively and reasonably unfettered academic exchange, rather than the densely commercial space of platform capitalism that it has become. 
It should not be so difficult, given the extraordinary capacities of software and hardware today, to make a piece of writing publically available in a plain and pleasant format.
That there exist digital humanities initiatives measured in months and years to bring books to the web as basic websites is a clear sign that something has gone awry.
#footnote[
  I am all for new and experimental ways of reading and appreciate much of the good work done in this vein in the digital humanities.
  What I decry is the work required to bring books online even in the simplest of legible formats.
]

Rheo aims to enable the publication of more books, blog posts, and papers without the necessary capitalist ceremony of creating an account on Substack, Medium, or Squarespace.
A website without any interactive elements such as forms, online marketplaces, or comments should be simple to set up, as it isn't rocket science in 2025 thanks to all the hard work that folks have put into Internet protocols and web standards.
It _should_ be simple to create a PDF or EPUB for sharing with colleagues or collaborators, as simple as it is to send an email.

This is the vision of the world to which we at #link("https://freecomputinglab.ohrg.org")[the free computing lab] aspire, and in search of which we have built Rheo.
Rheo is the first installment in a larger set of writing tools we aim to build, which will include processes for collaboratively drafting documents, constructing and working with digital libraries, and more.

#context if target() == "html" {
[== Bibliography
#bibliography("./img/refs.bib", title: none, style: "chicago-author-date")

== Footnotes]
}

