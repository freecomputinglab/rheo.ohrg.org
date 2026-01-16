#import "index.typ": rheobook 
#show: rheobook.with(current-page: "content-dir")

= Content directory 

By default, Rheo will search your entire project directory for Typst documents.
You can, however, indicate a specific subdirectory that Rheo should use if you prefer. 
This can be helpful for structuring projects, as it allows you, for example, to keep a separate `drafts` folder that Rheo will not compile.

The default content directory is the same path as the Rheo project directory. 
It is important to note that if you specify a custom content directory, all other configuration such as `build_dir` and `spine` globs will operate _relative to the content directory_.

= Configuration
== `rheo.toml` 
A custom content directory can be specified at the top level of the `rheo.toml`.
The path is calculated relative to the project directory:

```toml
content_dir = "pages"
```


