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

`migrate` groups its rewrites by the project version it's migrating from:

#table(
  columns: (auto, 1fr),
  align: (left, left),
  table.header[*From version*][*What `migrate` rewrites*],
  [`< 0.4.0`],
  [
    - *Link syntax:* cross-file links written as file paths are rewritten to the current #link(<relative-linking>)[handle form]:
      ```typ
      // before
      #link("./another-section.typ")[Another section]
      // after
      #link(<another-section>)[Another section]
      ```
  ],
  [`< 0.5.0`],
  [
    - *Output format:* direct `rheo-target` references are rewritten onto #link(<rheo-context>)[`rheo-context.target`]:
      ```typ
      // before
      #if "rheo-context" in sys.inputs and "target" in sys.inputs.rheo-context { sys.inputs.rheo-context.target }
      // after
      #if "rheo-context" in sys.inputs and "target" in sys.inputs.rheo-context { sys.inputs.rheo-context.target }
      ```
      It also rewrites the old `target()` helper to Typst's `target()`. Files already using `target()` need no change.
    - *Spine config:* a `[spine] vertebrae` inclusion-filter glob list is converted to an equivalent `[spine] exclude`, so files the old list never named don't silently start being published under the #link(<spines>)[directory-scan default].
  ],
  [any outdated version],
  [Bumps the `version` field in `rheo.toml` to match the current CLI version (`--apply` only).],
)

== What it does not migrate

- `#import` statements — these work unchanged in Rheo and do not need rewriting.
- Custom labels and other source constructs.
- The handle separator: during a pre-release window the path separator was briefly `-` rather than `:`. No automated rewrite exists for this because `-` is also used in ordinary single-segment stems (e.g. `<title-page>`), making the two forms indistinguishable without full project context. Projects that adopted the old `-` scheme during that window must update their links manually.
