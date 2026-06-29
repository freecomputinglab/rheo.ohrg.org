#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "migrate")

= Migrating projects <migrate>

The `migrate` command upgrades an existing Rheo project to the current version.
It reads the `version` field from `rheo.toml`, determines what migrations apply for the gap between that version and the current CLI, and reports or applies them.

== Usage

```bash
rheo migrate path/to/project          # dry run — reports changes, writes nothing
rheo migrate path/to/project --apply  # applies changes and bumps rheo.toml version
```

Always run the dry run first to review what will be rewritten, then pass `--apply` to write the changes.

`migrate` is best-effort: it applies the mechanical rewrites it knows about, but it does not guarantee that your project will build or behave correctly on the new version.
After migrating, rebuild and check the output yourself, and consult the changelog for breaking changes that require manual attention.

== What it migrates

*Link syntax (projects with version < 0.4.0):* Before 0.4.0, cross-file links used file paths directly:

```typ
#link("./another-section.typ")[Another section]
```

`migrate` rewrites these to the current #link(<relative-linking>)[handle form]:

```typ
#link(<another-section>)[Another section]
```

*Version bump:* `migrate --apply` updates the `version` field in `rheo.toml` to match the current CLI version.

== What it does not migrate

- `#import` statements — these work unchanged in Rheo and do not need rewriting.
- Custom labels and other source constructs.
- The handle separator: during a pre-release window the path separator was briefly `-` rather than `:`. No automated rewrite exists for this because `-` is also used in ordinary single-segment stems (e.g. `<title-page>`), making the two forms indistinguishable without full project context. Projects that adopted the old `-` scheme during that window must update their links manually.
