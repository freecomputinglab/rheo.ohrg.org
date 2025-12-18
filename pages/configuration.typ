#import "index.typ": typbook 
#show: typbook.with(current-page: "reference")

Rheo is a CLI that produces pdf, html, and epub simultaneously from a directory of typst source documents.
The directory that contains your typst is called the *project directory*, and you can compile it via rheo like so:

```bash
rheo compile path/to/project
```

In general, there are two ways to configure rheo:

+ By passing *flags* directly to the CLI command.
+ By specifying configuration in a *rheo.toml* file at the root of the project directory.

If you compile a rheo project directory without a `rheo.toml` file, the following default settings will be applied to compile your project.

```toml
content_dir = "./"
build_dir = "build"
formats = ["pdf", "html", "epub"]

[epub.merge]
spine = ["*.typ"]
title = "[project directory name]"
```

To point rheo to a rheo.toml file that is not at the root of the project directory, specify it directly via the CLI:

```sh
rheo compile path/to/project --config path/to/config 
```

