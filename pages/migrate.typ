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

== What migrate rewrites

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

  [`< 0.5.1`],
  [
    - *`rheo-context` binding:* the injected per-vertebra binding changed from a bare dictionary to a zero-arg function #link(<rheo-context>)[`rheo-context()`]. So existing `rheo-context.field` code keeps working, `migrate` prepends a one-line compatibility shim to each file that reads the binding:
      ```typ
      #let rheo-context = rheo-context()
      ```
      The shim calls the injected function once and rebinds the name to its dictionary. `migrate` does *not* rewrite individual `rheo-context.field` references --- the shim leaves them working untouched.
  ],

  [`< 0.6.0`],
  [
    - *Feed removal:* Atom feed generation left Rheo in 0.6.0, and nothing about the change is mechanical enough to rewrite. `migrate` instead reports every retired `[html]` feed key and `#let rheo-feed-*` / `rheo-author` binding it finds, each with its file and line --- see #link(<feed-removal>)[what 0.6.0 removed] below for the full account and where the replacement lives.
  ],

  [any outdated version], [Bumps the `version` field in `rheo.toml` to match the current CLI version (`--apply` only).],
)

== Removals in 0.6.0 <feed-removal>

- `[html]` `feed_base_url`, `feed_author`, `feed_title`
- `[[html.feed_include]]`
- the entire `#let rheo-<key>` variable convention that fed the old generator --- `rheo-feed-title`, `rheo-feed-updated`, `rheo-feed-exclude`
- `rheo-author`, whose replacement is `#set document(author: ...)`

Since 0.6.0, a Rheo build will warn when it finds a retired key:

```
`feed_base_url` in [html] is retired and has no effect — Atom feed generation moved to the Typst package @rheo/feeds — see https://rheo.ohrg.org/feeds
```

A top-level `#let rheo-anything = (1, 2)` used to be a compile error, because the old harvester only accepted a string or boolean literal on the right-hand side.
From 0.6.0 it's just an ordinary Typst binding that Rheo doesn't consider.
