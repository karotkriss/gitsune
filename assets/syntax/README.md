# Bundled syntax highlighter (WebView fallback)

`highlight.min.js` is the prebuilt browser bundle from npm `@highlightjs/cdn-assets@11.10.0` (all languages, minified), BSD-3-Clause license (`LICENSE-highlight.js.txt` alongside).
It backs `lib/core/syntax/gs_syntax_webview.dart`, the WebView fallback `re_highlight`'s native per-line path uses for oversized full-file views.
The JS is embedded inline into a generated HTML document at render time (no separate asset request, no network); theming reuses the same `GsTheme` code colors as the native path via generated CSS, not this bundle's own stylesheets.

To update, re-download from the same source and keep the license text in sync:

```sh
curl -o assets/syntax/highlight.min.js "https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@<version>/highlight.min.js"
curl -o assets/syntax/LICENSE-highlight.js.txt "https://cdn.jsdelivr.net/npm/@highlightjs/cdn-assets@<version>/LICENSE"
```
