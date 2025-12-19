#import "index.typ": rheobook 
#show: rheobook.with(current-page: "content-dir")


= Content directory 

By default, rheo will search your entire project directory for typst source files.
You can, however, indicate a specific subdirectory that rheo should search if you prefer. 
(This can be helpful for structuring projects, as it allows you for example to keep a separate drafts folder which rheo will not compile.)

The default content directory is the same path as the rheo project directory. 
It is important to note that if you specify a custom content directory, all other configuration such as `build_dir` and `spine` globs will operate relative to the content directory.

== Configuration
=== `rheo.toml` 
A custom content directory can be specified at the top level of the `rheo.toml`.
The path is calculated relative to the project directory:

```toml
content_dir = "pages"
```


