#import "index.typ": typbook 
#show: typbook.with(current-page: "build-dir")


=== Build directory  

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
You can configure rheo to produce outputs to a different build directory on the CLI:

```sh
rheo compile path/to/project --build-dir path/to/build
```

Or in `rheo.toml`:

```toml
build_dir = "custom_build_directory"
```


