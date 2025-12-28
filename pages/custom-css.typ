#import "index.typ": rheobook, rheo-source-url
#show: rheobook.with(current-page: "custom-css")

When rheo generates HTML, it injects a #link(rheo-source-url + "/blob/main/src/css/style.css")[default stylesheet] into the generated static site for a simple, modern, and mobile-friendly aesthetic. 
#link("https://screening-the-subject.ohrg.org")['Screening the subject'] is a website generated with the default rheo stylesheet for reference.

You can fully customize the stylesheet by adding a `style.css` at the root of your #link("./configuration.typ")[project directory].
Note that if your project contains a custom `style.css`, _none_ of the styles in the default stylesheet will be applied.
If you want to build on the default styles, copy and paste the #link(rheo-source-url + "/blob/main/src/css/style.css")[default stylesheet] into the `style.css` file in your project directory.
