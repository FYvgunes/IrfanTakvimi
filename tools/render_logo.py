"""
Render İrfan Takvimi logo to PNG at the sizes Flutter web expects.

Mirrors lib/presentation/widgets/app_logo.dart exactly:
  - two concentric copper rings (no closed star polygons)
  - bold central crescent moon
  - single ornamental copper dot at 12 o'clock on the outer ring

Writes:
  web/favicon.png             (32×32, transparent bg)
  web/icons/Icon-192.png      (192×192, transparent bg)
  web/icons/Icon-512.png      (512×512, transparent bg)
  web/icons/Icon-maskable-192.png  (192×192, ivory bg, logo at 80%)
  web/icons/Icon-maskable-512.png  (512×512, ivory bg, logo at 80%)
"""

import os
from PIL import Image, ImageDraw

# Palette — must match lib/core/constants/theme.dart
COPPER       = (0xB0, 0x7A, 0x2A, 255)
COPPER_SOFT  = (0xB0, 0x7A, 0x2A, 140)  # ~0.55 alpha
HERITAGE     = (0x0E, 0x3A, 0x2F, 255)
IVORY        = (0xF6, 0xEF, 0xD9, 255)


def draw_logo(size: int, bg=None, inset: float = 1.0) -> Image.Image:
    """Draw the logo on a canvas of [size]x[size]. [inset]<1.0 shrinks the
    mark within the canvas (used for maskable safe-zone)."""
    # Render at 4x then downscale for crisp anti-aliasing.
    scale = 4
    canvas = size * scale
    img = Image.new("RGBA", (canvas, canvas), bg if bg else (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx = cy = canvas / 2
    r = (canvas / 2) * inset

    # --- outer copper ring (stroke width 4.5% of r)
    outer_r = r * 0.94
    outer_sw = max(1, round(r * 0.045))
    _ring(draw, cx, cy, outer_r, outer_sw, COPPER)

    # --- inner soft copper ring
    inner_r = r * 0.78
    inner_sw = max(1, round(r * 0.022))
    _ring(draw, cx, cy, inner_r, inner_sw, COPPER_SOFT)

    # --- top ornamental dot (sits on outer ring at 12 o'clock)
    dot_r = r * 0.07
    dot_cy = cy - outer_r
    _filled_circle(draw, cx, dot_cy, dot_r, COPPER)

    # --- crescent (full disk minus an offset disk)
    cr = r * 0.46
    crc = (cx, cy + r * 0.04)
    off = (cr * 0.42, -cr * 0.08)
    crescent = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    cdraw = ImageDraw.Draw(crescent)
    _filled_circle(cdraw, crc[0], crc[1], cr, HERITAGE)
    # punch out the offset disk by drawing transparency
    punch = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    pdraw = ImageDraw.Draw(punch)
    _filled_circle(pdraw, crc[0] + off[0], crc[1] + off[1], cr * 0.92,
                   (0, 0, 0, 255))
    # use punch alpha as a mask to clear pixels in `crescent`
    crescent_arr = crescent.split()
    punch_alpha = punch.split()[3]
    # Subtract punch alpha from crescent alpha
    new_alpha = Image.eval(
        Image.merge("RGBA", crescent_arr).split()[3],
        lambda a: a)
    # Simpler approach: composite a transparent ellipse via alpha_composite
    # using the punch mask
    cleared_alpha = _subtract_alpha(crescent_arr[3], punch_alpha)
    crescent = Image.merge("RGBA",
                           (crescent_arr[0], crescent_arr[1],
                            crescent_arr[2], cleared_alpha))
    img.alpha_composite(crescent)

    # Downscale for AA
    return img.resize((size, size), Image.LANCZOS)


def _ring(draw, cx, cy, radius, stroke_width, color):
    """Draw an annulus by filling a wide ellipse outline."""
    # PIL's outline width is centered; clamp to integer.
    bbox = (cx - radius, cy - radius, cx + radius, cy + radius)
    draw.ellipse(bbox, outline=color, width=stroke_width)


def _filled_circle(draw, cx, cy, radius, color):
    bbox = (cx - radius, cy - radius, cx + radius, cy + radius)
    draw.ellipse(bbox, fill=color)


def _subtract_alpha(base_alpha, sub_alpha):
    """Return a new alpha channel where pixels with sub > 0 are cleared."""
    base = base_alpha.load()
    sub = sub_alpha.load()
    w, h = base_alpha.size
    out = Image.new("L", (w, h), 0)
    out_px = out.load()
    for y in range(h):
        for x in range(w):
            b = base[x, y]
            s = sub[x, y]
            out_px[x, y] = max(0, b - s)
    return out


def main():
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), '.'))
    # Resolve relative to project root when invoked from project dir.
    proj = os.environ.get("PROJ", os.getcwd())

    targets = [
        (os.path.join(proj, "web/favicon.png"),                  32,  None, 1.0),
        (os.path.join(proj, "web/icons/Icon-192.png"),           192, None, 1.0),
        (os.path.join(proj, "web/icons/Icon-512.png"),           512, None, 1.0),
        (os.path.join(proj, "web/icons/Icon-maskable-192.png"),  192, IVORY, 0.78),
        (os.path.join(proj, "web/icons/Icon-maskable-512.png"),  512, IVORY, 0.78),
    ]

    for path, size, bg, inset in targets:
        img = draw_logo(size, bg=bg, inset=inset)
        img.save(path, "PNG", optimize=True)
        print(f"  wrote {path} ({size}×{size})")


if __name__ == "__main__":
    main()
