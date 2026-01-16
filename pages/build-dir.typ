#import "index.typ": rheobook
#show: rheobook.with(current-page: "build-dir")

= Build directory  

Rheo produces outputs in a simple directory structure with one subdirectory for each kind of output.
By default, Rheo produces all outputs (PDF, HTML, and EPUB) in a `build` directory instide the project directory:

```
build/
├── epub
│   └── blog_post.epub
├── html
│   ├── portable_epubs.html
│   └── style.css
└── pdf
    └── portable_epubs.pdf
```

The build directory path is calculated _relative to the content directory_.
This is important, as if you change the #link("./content-dir.typ")[content directory], then your build directory path will become relevant to that directory.  

= Configuration 
== CLI flag 
You can specify a build directory with either the `compile` and `watch` commands:

```bash
rheo compile path/to/project --build-dir path/to/build
```

== `rheo.toml` 
The build directory is specified at the top level of the `rheo.toml`:

```toml
build_dir = "custom_build_directory"
```
