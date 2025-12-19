#import "index.typ": rheobook 
#show: rheobook.with(current-page: "build-dir")


= Build directory  

Rheo produces outputs a simple directory structure with one subdirectory for each kind of output.
By default rheo produces all outputs (pdf, html, and epub) in a `build` directory directly instide the project directory:

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

== Configuration 
=== CLI flag 
You can specify a build directory with either the `compile` and `watch` commands:

```sh
rheo compile path/to/project --build-dir path/to/build
```

=== `rheo.toml` 
The build directory is specified at the top level of the `rheo.toml`:

```toml
build_dir = "custom_build_directory"
```
