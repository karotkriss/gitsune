# Renders the Gitsune brand mark into every raster icon/graphic the stores and
# platforms need, from the design system's own definition of the mark:
# design/guidelines/brand-wordmark.card.html - "No logo exists yet - the name in
# GitLab Sans on brand orange is the mark".
#
# Sources:
#   assets/fonts/GitLabSans.ttf        (variable font: opsz 14-28, wght 100-900)
#   design/tokens/colors.css           (hex values inlined below)
#
# Regenerate everything (from the repo root):
#   uv run --with pillow python3 store/play/graphics/generate.py
#
# Outputs:
#   store/play/graphics/icon-512.png            Play store icon, 512x512 RGBA
#   store/play/graphics/feature-graphic.png     Play feature graphic, 1024x500
#   android/app/src/main/res/mipmap-*/ic_launcher.png   launcher icons
#   ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png iOS icons (opaque)

import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[3]
FONT = ROOT / "assets/fonts/GitLabSans.ttf"
OUT = ROOT / "store/play/graphics"

# design/tokens/colors.css
BRAND_500 = "#fc6d26"  # --gs-color-brand-500
NEUTRAL_950 = "#18171d"  # --gl-color-neutral-950
NEUTRAL_300 = "#a4a3a8"  # --gl-color-neutral-300
WHITE = "#ffffff"

SS = 4  # supersample factor, downscaled with Lanczos for crisp glyph edges


def font(px, weight):
    f = ImageFont.truetype(str(FONT), px)
    f.set_variation_by_axes([28.0, float(weight)])  # opsz display, wght
    return f


def draw_centered(draw, text, f, fill, cx, cy):
    """Center text's tight ink bbox on (cx, cy); returns the drawn bbox height."""
    l, t, r, b = draw.textbbox((0, 0), text, font=f)
    draw.text((cx - (l + r) / 2, cy - (t + b) / 2), text, font=f, fill=fill)
    return b - t


def icon_master(side):
    """Full-square mark: white G monogram on brand orange."""
    s = side * SS
    img = Image.new("RGB", (s, s), BRAND_500)
    d = ImageDraw.Draw(img)
    draw_centered(d, "G", font(int(s * 0.62), 600), WHITE, s / 2, s / 2)
    return img.resize((side, side), Image.LANCZOS)


def rounded(img, radius_frac):
    """Bake transparent rounded corners (legacy Android launcher shape)."""
    side = img.width
    mask = Image.new("L", (side * SS,) * 2, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, side * SS - 1, side * SS - 1], radius=int(side * SS * radius_frac), fill=255
    )
    out = img.convert("RGBA")
    out.putalpha(mask.resize((side, side), Image.LANCZOS))
    return out


def feature_graphic():
    """1024x500 banner: dark wordmark treatment from the brand card."""
    w, h = 1024 * SS, 500 * SS
    img = Image.new("RGB", (w, h), NEUTRAL_950)
    d = ImageDraw.Draw(img)
    name_f = font(150 * SS, 600)
    tag_f = font(46 * SS, 400)
    l, t, r, b = d.textbbox((0, 0), "Gitsune", font=name_f)
    name_h = b - t
    l, t, r, b = d.textbbox((0, 0), "GitLab in your pocket", font=tag_f)
    tag_h = b - t
    gap = 40 * SS
    top = (h - (name_h + gap + tag_h)) / 2
    draw_centered(d, "Gitsune", name_f, BRAND_500, w / 2, top + name_h / 2)
    draw_centered(d, "GitLab in your pocket", tag_f, NEUTRAL_300, w / 2, top + name_h + gap + tag_h / 2)
    return img.resize((1024, 500), Image.LANCZOS)


def main():
    master = icon_master(1024)

    # Play store icon: full square, 32-bit PNG (Play masks its own corners).
    master.resize((512, 512), Image.LANCZOS).convert("RGBA").save(OUT / "icon-512.png")
    feature_graphic().save(OUT / "feature-graphic.png")

    # Android launcher mipmaps (legacy icons render unmasked, so bake the shape).
    for density, side in [("mdpi", 48), ("hdpi", 72), ("xhdpi", 96), ("xxhdpi", 144), ("xxxhdpi", 192)]:
        rounded(icon_master(side), 0.2).save(
            ROOT / f"android/app/src/main/res/mipmap-{density}/ic_launcher.png"
        )

    # iOS icon set: regenerate every existing size, opaque RGB as Apple requires.
    appiconset = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for png in sorted(appiconset.glob("Icon-App-*.png")):
        m = re.match(r"Icon-App-([\d.]+)x[\d.]+@(\d)x\.png", png.name)
        px = round(float(m.group(1)) * int(m.group(2)))
        master.resize((px, px), Image.LANCZOS).save(png)

    print("done")


if __name__ == "__main__":
    main()
