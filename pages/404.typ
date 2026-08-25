#import "index.typ": sidebar-site
#show: sidebar-site.with(current: none)

// Cloudflare Pages serves this file's body at whatever path 404'd, so the page
// is read from a URL that is not its own. Relative URLs resolve against that
// path rather than the build root, so this page --- and only this page --- pins
// its own: `<base>` re-roots every link in the body, and the stylesheets are
// re-linked absolutely because `<rheo-head>` appends after Rheo's own relative
// ones, too late to re-root them.
#html.elem(
  "rheo-head",
  {
    html.elem("base", attrs: (href: "/"))
    html.elem("link", attrs: (rel: "stylesheet", href: "/style.css"))
    html.elem("link", attrs: (rel: "stylesheet", href: "/rheo/sidebar/sidebar.css"))
  },
)

= Page not found

There is no page at this address!
It may have moved.

Check the sidebar for a page similar to what you were looking for.

If you arrived here from a link on this site rather than from elsewhere, that is a bug in the documentation: please #link("https://github.com/freecomputinglab/rheo.ohrg.org/issues")[report it].
