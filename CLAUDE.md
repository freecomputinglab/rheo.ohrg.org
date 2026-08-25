# CLAUDE.md — rheo.ohrg.org

User-facing documentation site for rheo, authored in Typst and built **with rheo itself**.
Content lives in `pages/` (`content_dir = "pages"` in `rheo.toml`). The spine is a plain
directory scan of `pages/` — there is no explicit ordering list. `rheo.toml`'s `[pdf.spine]`
and `[epub.spine]` each carry only a `title` and, optionally, an `exclude` glob list.

## Sidebar navigation

The sidebar is hand-authored, separately from the spine: `site-nav` in `pages/index.typ` is a
literal nested array of sections and page entries. Adding a page needs **both** a new
`pages/<name>.typ` file **and** a `site-nav` entry there — the file alone compiles but stays
unreachable from any nav. Every page opens with the two-line header:

```typ
#import "index.typ": sidebar-site
#show: sidebar-site.with(current: "<id>")
```

where `<id>` matches that page's `site-nav` entry id.

## Building locally

Always build the site locally with:

```bash
rheo compile .
```

Output lands in `build/html/`. Use a locally-built `rheo` from `../rheo` (`cargo run -- compile .`
from that repo, or an installed `rheo`) so docs are validated against current engine behaviour.

**Do NOT run `build.sh` locally.** It is the CI build only: it downloads a *pinned release*
binary (`RHEO_VERSION` in the script), clones `rheo-packages`, and builds `@rheo/sidebar` into
the Typst cache. It does not reflect local `rheo/` changes.

## Workflow

Shared jj / beads / Plan Mode conventions live in `~/.claude/CLAUDE.md`; cross-repo flow lives
in the workspace `../CLAUDE.md`. "When done" step here: `rheo compile .` builds clean.
