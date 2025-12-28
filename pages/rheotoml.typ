#import "index.typ": rheobook 
#show: rheobook.with(current-page: "rheotoml")

Rheo is a CLI that produces PDF, HTML, and EPUB simultaneously from a directory of Typst source documents.
The directory that contains your Typst is called the *project directory*, and you can compile it like so:

```bash
rheo compile path/to/projectdirectory
```

In general, there are two ways to configure Rheo:

+ By passing *flags* directly to the CLI command.
+ By specifying configuration in a `rheo.toml` file at the root of the project directory.

If you compile a Rheo project directory without a `rheo.toml` file, the following default settings will be applied to compile your project.

```toml
version = "0.1.0"
content_dir = "./"
build_dir = "build"
formats = ["pdf", "html", "epub"]

[epub.spine]
vertebrae = ["**/*.typ"]
title = "[project directory name]"
```

To point Rheo to a rheo.toml file that is not at the root of the project directory, specify it directly via the CLI:

```sh
rheo compile path/to/project --config path/to/config 
```

