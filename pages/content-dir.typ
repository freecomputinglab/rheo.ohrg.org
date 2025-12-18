#import "index.typ": typbook 
#show: typbook.with(current-page: "content-dir")


=== Content directory 

By default, rheo will search your entire project directory for typst source files.
You can, however, indicate a specific subdirectory that rheo should search if you prefer. 
(This can be helpful for structuring projects, as it allows you for example to keep a separate drafts folder which rheo will not compile.)

The default content directory is the same path as the rheo project directory. 
It is important to note that if you specify a custom content directory, _other configuration such as `build_dir` and `spine` globs will operate relative to the content directory_.

You can specify a custom content directory in `rheo.toml`.
The path is calculated relative to the project directory:

```toml
content_dir = "content"
```


