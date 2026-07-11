# CLAUDE.md — rheo.ohrg.org

User-facing documentation site for rheo, authored in Typst and built **with rheo itself**.
Content lives in `pages/` (`content_dir = "pages"` in `rheo.toml`); the spine order is the
`vertebrae` list in `rheo.toml`.

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
