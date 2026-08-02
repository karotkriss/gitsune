# Bundled fonts

GitLab Sans and GitLab Mono, GitLab's open-source brand faces, licensed under the SIL Open Font License 1.1 (the `LICENSE-*.txt` files alongside).

The `.ttf` files are lossless conversions of the `.woff2` files vendored in `design/assets/fonts/` (from npm `@gitlab/fonts@1.3.1`), because Flutter bundles ttf/otf but not woff2.
To regenerate after a font update, run from the repo root:

```sh
for f in GitLabSans GitLabSans-Italic GitLabMono GitLabMono-Italic; do
  uvx --with brotli --from fonttools fonttools ttLib.woff2 decompress \
    -o "assets/fonts/$f.ttf" "design/assets/fonts/$f.woff2"
done
```

Keep the license files in sync with `design/assets/fonts/` whenever the fonts are updated.
