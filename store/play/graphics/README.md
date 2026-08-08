# Play graphic assets

Designed promotional assets for the Google Play listing, generated (not hand-drawn) from the repo's own brand sources.

| File | Size | Play spec it matches |
| --- | --- | --- |
| `icon-512.png` | 512 x 512, 32-bit PNG | App icon: full square, <=1 MB; Play masks its own corners |
| `feature-graphic.png` | 1024 x 500 PNG | Feature graphic, <=15 MB, no screenshot collage, text legible at 1/4 scale |

## Source assets

The design system's brand card (`design/guidelines/brand-wordmark.card.html`) defines the mark: no drawn logo exists, the name in GitLab Sans on brand orange is the mark.
Both assets derive from exactly that:

- Font: `assets/fonts/GitLabSans.ttf` (variable; rendered at opsz 28, wght 600 for the mark).
- Colors: `design/tokens/colors.css` - brand-500 `#fc6d26`, neutral-950 `#18171d`, neutral-300 `#a4a3a8`.
- The icon is the wordmark's initial as a white G monogram on flat brand-500, the square-format reduction of the wordmark treatment (white on brand orange, as in `design/assets/gitsune-social-preview.png`).
- The feature graphic is the brand card's dark treatment: brand-500 wordmark and neutral-300 tagline on neutral-950.

## Regeneration

`generate.py` is the single source; it also regenerates the Android launcher mipmaps and the iOS `AppIcon.appiconset` from the same master, so the installed app icon always matches the Play icon.
From the repo root:

```sh
uv run --with pillow python3 store/play/graphics/generate.py
```
