# Vendored assets

- `mermaid/mermaid.min.js`: from npm `mermaid@11.16.0`, MIT license, text at `mermaid/LICENSE-mermaid.txt`.
  Loaded into an offline `webview_flutter` view by `lib/core/markdown/mermaid/gs_mermaid.dart`; never fetched from a CDN at runtime.
- `mermaid/mermaid.html` and `mermaid/mermaid-init.js`: hand-written harness that restricts network access, loads `mermaid.min.js`, and exposes `gsRenderMermaid(source)` to the WebView bridge.

To update the vendored Mermaid build, fetch a newer tarball and copy its `dist/mermaid.min.js` and `LICENSE` over these files:

```sh
npm pack mermaid@<version>
tar xzf mermaid-*.tgz
cp package/dist/mermaid.min.js assets/vendor/mermaid/mermaid.min.js
cp package/LICENSE assets/vendor/mermaid/LICENSE-mermaid.txt
```
