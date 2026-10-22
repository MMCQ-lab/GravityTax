"""Generate shop art: matching chests, seasonal jellies and effect sprites.

Run from the repo root:  python3 scripts/make_store_art.py
Everything is drawn here (no outside art), at 4x and scaled down for smooth edges.
"""
import math
import os
from PIL import Image, ImageDraw, ImageFilter, ImageChops

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMG = os.path.join(ROOT, "images")
SS = 4  # supersampling


def hexc(value, alpha=255):
    value = value.lstrip("#")
    return tuple(int(value[i:i + 2], 16) for i in (0, 2, 4)) + (alpha,)


def shade(color, factor):
    r, g, b, a = color
    if factor >= 1:
        return (int(r + (255 - r) * (factor - 1)), int(g + (255 - g) * (factor - 1)), int(b + (255 - b) * (factor - 1)), a)
    return (int(r * factor), int(g * factor), int(b * factor), a)


def canvas(w, h):
    return Image.new("RGBA", (w * SS, h * SS), (0, 0, 0, 0))


def finish(img, w, h):
    return img.resize((w, h), Image.LANCZOS)


def S(*values):
    return [v * SS for v in values]


# ---------------------------------------------------------------- chests
CHESTS = {
    "common": ("#9aa7bd", None),
    "uncommon": ("#43c463", None),
    "rare": ("#3a8dff", None),
    "epic": ("#9b5cff", None),
    "legendary": ("#f5b821", None),
    "sparkle": ("#ff6fcf", "sparkle"),
    "fall": ("#ff8a2b", "pumpkin"),
    "winter": ("#5fc4ff", "flake"),
    "spring": ("#ff9ec8", "flower"),
    "summer": ("#ffcf3a", "sun"),
}


def star_points(cx, cy, outer, inner, points=5, rotation=-90):
    pts = []
    for i in range(points * 2):
        r = outer if i % 2 == 0 else inner
        a = math.radians(rotation + i * 180 / points)
        pts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
    return pts


def draw_emblem(d, kind, cx, cy, r):
    if kind == "sparkle":
        d.polygon(star_points(cx, cy, r, r * 0.42, 4, -90), fill=(255, 255, 255, 255))
        d.polygon(star_points(cx + r * 0.9, cy - r * 0.7, r * 0.4, r * 0.16, 4, -90), fill=(255, 255, 255, 230))
    elif kind == "pumpkin":
        d.ellipse([cx - r, cy - r * 0.8, cx + r, cy + r * 0.8], fill=hexc("#ff8a2b"), outline=hexc("#b24d00"), width=SS * 3)
        d.line([cx, cy - r * 0.8, cx, cy + r * 0.8], fill=hexc("#d86a10"), width=SS * 3)
        d.rectangle([cx - r * 0.12, cy - r * 1.15, cx + r * 0.12, cy - r * 0.75], fill=hexc("#6b4a1e"))
    elif kind == "flake":
        for i in range(6):
            a = math.radians(i * 60)
            d.line([cx, cy, cx + r * math.cos(a), cy + r * math.sin(a)], fill=(255, 255, 255, 255), width=SS * 5)
        d.ellipse([cx - r * 0.2, cy - r * 0.2, cx + r * 0.2, cy + r * 0.2], fill=(255, 255, 255, 255))
    elif kind == "flower":
        for i in range(5):
            a = math.radians(i * 72 - 90)
            px, py = cx + r * 0.55 * math.cos(a), cy + r * 0.55 * math.sin(a)
            d.ellipse([px - r * 0.45, py - r * 0.45, px + r * 0.45, py + r * 0.45], fill=(255, 255, 255, 255))
        d.ellipse([cx - r * 0.35, cy - r * 0.35, cx + r * 0.35, cy + r * 0.35], fill=hexc("#ffd23a"))
    elif kind == "sun":
        for i in range(10):
            a = math.radians(i * 36)
            d.line([cx + r * 0.6 * math.cos(a), cy + r * 0.6 * math.sin(a), cx + r * math.cos(a), cy + r * math.sin(a)], fill=(255, 255, 255, 255), width=SS * 5)
        d.ellipse([cx - r * 0.5, cy - r * 0.5, cx + r * 0.5, cy + r * 0.5], fill=(255, 255, 255, 255))


def make_chest(name, color_hex, emblem):
    w = h = 256
    img = canvas(w, h)
    d = ImageDraw.Draw(img)
    base = hexc(color_hex)
    dark = shade(base, 0.62)
    light = shade(base, 1.35)
    gold = hexc("#ffd54a")
    gold_dark = hexc("#c98b10")
    outline = shade(base, 0.38)
    # shadow
    d.ellipse(S(40, 214, 216, 240), fill=(30, 30, 60, 60))
    # body
    d.rounded_rectangle(S(36, 112, 220, 222), radius=SS * 22, fill=base, outline=outline, width=SS * 6)
    d.rounded_rectangle(S(46, 178, 210, 214), radius=SS * 14, fill=dark)
    # lid
    d.rounded_rectangle(S(30, 62, 226, 124), radius=SS * 34, fill=light, outline=outline, width=SS * 6)
    d.rounded_rectangle(S(46, 72, 210, 92), radius=SS * 10, fill=shade(light, 1.25))
    # gold bands
    for x in (64, 172):
        d.rounded_rectangle(S(x, 64, x + 22, 220), radius=SS * 8, fill=gold, outline=gold_dark, width=SS * 3)
    d.rounded_rectangle(S(34, 112, 222, 128), radius=SS * 6, fill=gold, outline=gold_dark, width=SS * 3)
    # lock
    d.rounded_rectangle(S(106, 108, 150, 162), radius=SS * 12, fill=gold, outline=gold_dark, width=SS * 4)
    d.ellipse(S(121, 124, 135, 138), fill=outline)
    d.polygon(S(124, 134, 132, 134, 134, 150, 122, 150), fill=outline)
    # shine
    d.ellipse(S(44, 132, 60, 168), fill=(255, 255, 255, 90))
    if emblem:
        draw_emblem(d, emblem, 128 * SS, 40 * SS, 26 * SS)
    out = finish(img, w, h)
    os.makedirs(os.path.join(IMG, "chests"), exist_ok=True)
    out.save(os.path.join(IMG, "chests", f"chest_{name}.png"))


# ---------------------------------------------------------- seasonal jellies
EYE_L, EYE_R, EYE_Y, MOUTH = (55, 99, 74, (77, 90))


def load_base(index):
    return Image.open(os.path.join(IMG, "jelly_sprites", f"jelly_{index:02d}.png")).convert("RGBA")


def body_mask(img):
    return img.split()[3]


def tint(img, color_hex, amount):
    """Blend the jelly's colours toward a colour while keeping highlights/face."""
    overlay = Image.new("RGBA", img.size, hexc(color_hex))
    mixed = Image.blend(img, overlay, amount)
    mixed.putalpha(body_mask(img))
    # keep dark face features
    gray = img.convert("L")
    face = gray.point(lambda v: 255 if v < 50 else 0)
    mixed.paste(img, (0, 0), face)
    return mixed


def overlay_clipped(base, layer):
    """Composite a layer onto the jelly, but only inside the jelly body."""
    mask = ImageChops.multiply(layer.split()[3], body_mask(base))
    clipped = layer.copy()
    clipped.putalpha(mask)
    out = base.copy()
    out.alpha_composite(clipped)
    return out


def accessory(base, draw_fn, clip=False):
    w, h = base.size
    layer = canvas(w, h)
    draw_fn(ImageDraw.Draw(layer))
    layer = finish(layer, w, h)
    if clip:
        return overlay_clipped(base, layer)
    out = base.copy()
    out.alpha_composite(layer)
    return out


def keep_face(original, edited):
    gray = original.convert("L")
    face = gray.point(lambda v: 255 if v < 45 else 0)
    face = ImageChops.multiply(face, body_mask(original))
    edited = edited.copy()
    edited.paste(original, (0, 0), face)
    return edited


def seasonal_jellies():
    out = {}
    # --- Halloween
    pumpkin = load_base(1)
    pumpkin = accessory(pumpkin, lambda d: [d.arc(S(28 + i * 26, 6, 70 + i * 26, 134), 250, 290, fill=hexc("#c55a00", 150), width=SS * 3) for i in range(4)], clip=True)
    pumpkin = accessory(pumpkin, lambda d: (d.rounded_rectangle(S(70, 0, 84, 18), radius=SS * 4, fill=hexc("#6b4a1e")), d.ellipse(S(82, 2, 108, 14), fill=hexc("#4bbf56"))))
    out[50] = keep_face(load_base(1), pumpkin)

    ghost = load_base(8)
    mask = Image.new("L", ghost.size, 255)
    md = ImageDraw.Draw(mask)
    for i in range(6):
        cx = 22 + i * 22
        md.ellipse([cx - 11, 118, cx + 11, 140], fill=0)
    ghost.putalpha(ImageChops.multiply(body_mask(ghost), mask).point(lambda v: int(v * 0.88)))
    ghost = accessory(ghost, lambda d: (d.ellipse(S(36, 86, 50, 96), fill=hexc("#b9c7ff", 160)), d.ellipse(S(104, 86, 118, 96), fill=hexc("#b9c7ff", 160))))
    out[51] = ghost

    witch = load_base(3)
    def hat(d):
        d.ellipse(S(30, 18, 124, 34), fill=hexc("#3b2a5c"))
        d.polygon(S(52, 24, 102, 24, 92, -2, 70, -10), fill=hexc("#3b2a5c"))
        d.rectangle(S(54, 16, 100, 24), fill=hexc("#9b5cff"))
    out[52] = accessory(witch, hat)

    corn = load_base(2)
    def bands(d):
        d.rectangle(S(0, 0, 154, 48), fill=(255, 255, 255, 215))
        d.rectangle(S(0, 48, 154, 88), fill=hexc("#ff8a2b", 200))
    out[53] = keep_face(load_base(2), accessory(corn, bands, clip=True))

    # --- Winter
    snow = load_base(8)
    def snowman(d):
        d.rounded_rectangle(S(28, 108, 126, 120), radius=SS * 5, fill=hexc("#e8394a"))
        d.rounded_rectangle(S(98, 110, 112, 136), radius=SS * 4, fill=hexc("#e8394a"))
        d.polygon(S(74, 80, 74, 86, 92, 83), fill=hexc("#ff8a2b"))
        d.ellipse(S(46, 14, 108, 24), fill=hexc("#222233"))
        d.rectangle(S(56, -2, 98, 18), fill=hexc("#222233"))
        d.rectangle(S(56, 10, 98, 15), fill=hexc("#e8394a"))
    out[54] = accessory(snow, snowman)

    santa = load_base(3)
    def santa_hat(d):
        d.polygon(S(40, 22, 114, 22, 120, 4, 76, -12), fill=hexc("#e8394a"))
        d.polygon(S(76, -12, 120, 4, 138, 18), fill=hexc("#e8394a"))
        d.rounded_rectangle(S(34, 16, 120, 32), radius=SS * 8, fill=(255, 255, 255, 255))
        d.ellipse(S(130, 10, 148, 28), fill=(255, 255, 255, 255))
    out[55] = accessory(santa, santa_hat)

    deer = tint(load_base(1), "#7a4b2a", 0.55)
    def antlers(d):
        for side in (-1, 1):
            x = 77 + side * 26
            d.line(S(x, 20, x + side * 10, 0), fill=hexc("#6b4a1e"), width=SS * 6)
            d.line(S(x + side * 5, 10, x + side * 20, 6), fill=hexc("#6b4a1e"), width=SS * 5)
            d.line(S(x + side * 8, 4, x + side * 4, -6), fill=hexc("#6b4a1e"), width=SS * 4)
        d.ellipse(S(70, 76, 84, 88), fill=hexc("#ff3b4a"))
        d.ellipse(S(73, 78, 77, 82), fill=(255, 255, 255, 200))
    out[56] = accessory(keep_face(load_base(1), deer), antlers)

    frost = load_base(7)
    def snowcap(d):
        d.ellipse(S(30, 4, 124, 34), fill=(255, 255, 255, 255))
        for cx, cy in ((44, 32), (66, 36), (92, 34), (112, 30)):
            d.ellipse(S(cx - 8, cy - 8, cx + 8, cy + 8), fill=(255, 255, 255, 255))
        for cx, cy in ((26, 60), (130, 70), (120, 108)):
            for i in range(3):
                a = math.radians(i * 60)
                d.line(S(cx - 6 * math.cos(a), cy - 6 * math.sin(a), cx + 6 * math.cos(a), cy + 6 * math.sin(a)), fill=(255, 255, 255, 230), width=SS * 2)
    out[57] = accessory(frost, snowcap)

    # --- Spring
    crown = load_base(5)
    def flowers(d):
        colors = ["#ffd23a", "#ffffff", "#9b5cff", "#ffffff", "#ffd23a"]
        for i, c in enumerate(colors):
            cx, cy = 38 + i * 19.5, 18 - (abs(2 - i) * -2)
            for k in range(5):
                a = math.radians(k * 72)
                d.ellipse(S(cx + 6 * math.cos(a) - 5, cy + 6 * math.sin(a) - 5, cx + 6 * math.cos(a) + 5, cy + 6 * math.sin(a) + 5), fill=hexc(c))
            d.ellipse(S(cx - 4, cy - 4, cx + 4, cy + 4), fill=hexc("#ff8a2b"))
        d.line(S(30, 26, 124, 26), fill=hexc("#4bbf56"), width=SS * 3)
    out[58] = accessory(crown, flowers)

    egg = load_base(4)
    def egg_pattern(d):
        pts = []
        for i in range(12):
            pts += [i * 14, 44 if i % 2 == 0 else 34]
        d.line(S(*pts), fill=(255, 255, 255, 230), width=SS * 5)
        pts = []
        for i in range(12):
            pts += [i * 14, 116 if i % 2 == 0 else 106]
        d.line(S(*pts), fill=hexc("#ffd23a", 230), width=SS * 5)
        for cx in (30, 124):
            d.ellipse(S(cx - 5, 66, cx + 5, 76), fill=hexc("#ff9ec8"))
    out[59] = keep_face(load_base(4), accessory(egg, egg_pattern, clip=True))

    chick = load_base(2)
    def shell(d):
        pts = [24, 30]
        for i in range(9):
            pts += [32 + i * 11, 18 if i % 2 == 0 else 32]
        pts += [130, 30, 120, 4, 34, 4]
        d.polygon(S(*pts), fill=(255, 255, 255, 255), outline=hexc("#d9d9e6"))
        d.polygon(S(72, 86, 82, 86, 77, 94), fill=hexc("#ff8a2b"))
    out[60] = accessory(chick, shell)

    blossom = load_base(8)
    def petals(d):
        for cx, cy in ((30, 40), (120, 34), (40, 110), (118, 104), (78, 24), (20, 80), (134, 72)):
            for k in range(5):
                a = math.radians(k * 72)
                d.ellipse(S(cx + 5 * math.cos(a) - 4, cy + 5 * math.sin(a) - 4, cx + 5 * math.cos(a) + 4, cy + 5 * math.sin(a) + 4), fill=hexc("#ff9ec8"))
            d.ellipse(S(cx - 2, cy - 2, cx + 2, cy + 2), fill=hexc("#ffd23a"))
    out[61] = accessory(blossom, petals, clip=True)

    # --- Summer
    shades = load_base(2)
    def sunglasses(d):
        d.rounded_rectangle(S(34, 62, 70, 84), radius=SS * 9, fill=hexc("#222233"))
        d.rounded_rectangle(S(84, 62, 120, 84), radius=SS * 9, fill=hexc("#222233"))
        d.line(S(70, 68, 84, 68), fill=hexc("#222233"), width=SS * 4)
        d.line(S(40, 66, 50, 66), fill=(255, 255, 255, 160), width=SS * 3)
        d.line(S(90, 66, 100, 66), fill=(255, 255, 255, 160), width=SS * 3)
    out[62] = accessory(shades, sunglasses)

    ball = load_base(8)
    def wedges(d):
        colors = ["#e8394a", "#3a8dff", "#ffd23a", "#43c463"]
        for i, c in enumerate(colors):
            d.pieslice(S(-60, -60, 214, 200), i * 90 + 20, i * 90 + 60, fill=hexc(c, 210))
    out[63] = keep_face(load_base(8), accessory(ball, wedges, clip=True))

    pop = load_base(5)
    def stick(d):
        d.rounded_rectangle(S(70, 118, 84, 140), radius=SS * 5, fill=hexc("#e2b06a"))
        d.ellipse(S(28, 112, 40, 128), fill=hexc("#ff9ec8"))
        d.ellipse(S(112, 114, 122, 126), fill=hexc("#ff9ec8"))
    out[64] = accessory(pop, stick)
    out[64].alpha_composite(Image.new("RGBA", pop.size, (0, 0, 0, 0)))

    flamingo = tint(load_base(5), "#ff7ab0", 0.3)
    def ring(d):
        d.ellipse(S(6, 100, 148, 138), outline=(255, 255, 255, 255), width=SS * 12)
        for i in range(6):
            a0 = i * 60
            d.arc(S(6, 100, 148, 138), a0, a0 + 25, fill=hexc("#ff4f8a"), width=SS * 12)
    out[65] = accessory(keep_face(load_base(5), flamingo), ring)

    for skin_id, image in out.items():
        image.save(os.path.join(IMG, "jelly_sprites", f"jelly_{skin_id:02d}.png"))


# --------------------------------------------------------------- effects
def soft_glow(size, color):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    for r in range(size // 2, 0, -1):
        alpha = int(255 * (1 - r / (size / 2)) ** 1.6)
        ImageDraw.Draw(img).ellipse([size / 2 - r, size / 2 - r, size / 2 + r, size / 2 + r], fill=color[:3] + (alpha,))
    return img


def particle_textures():
    folder = os.path.join(IMG, "effects")
    os.makedirs(folder, exist_ok=True)
    soft_glow(128, (255, 255, 255, 255)).save(os.path.join(folder, "glow.png"))
    img = canvas(64, 64)
    ImageDraw.Draw(img).polygon(star_points(32 * SS, 32 * SS, 30 * SS, 9 * SS, 4), fill=(255, 255, 255, 255))
    finish(img, 64, 64).save(os.path.join(folder, "star.png"))
    img = canvas(64, 64)
    d = ImageDraw.Draw(img)
    d.ellipse(S(6, 10, 34, 38), fill=(255, 255, 255, 255))
    d.ellipse(S(30, 10, 58, 38), fill=(255, 255, 255, 255))
    d.polygon(S(8, 30, 56, 30, 32, 58), fill=(255, 255, 255, 255))
    finish(img, 64, 64).save(os.path.join(folder, "heart.png"))
    img = canvas(64, 64)
    d = ImageDraw.Draw(img)
    d.ellipse(S(6, 6, 58, 58), outline=(255, 255, 255, 255), width=SS * 4)
    d.ellipse(S(16, 14, 28, 26), fill=(255, 255, 255, 220))
    finish(img, 64, 64).save(os.path.join(folder, "bubble.png"))
    img = canvas(64, 64)
    d = ImageDraw.Draw(img)
    for i in range(6):
        a = math.radians(i * 60)
        d.line([32 * SS, 32 * SS, (32 + 28 * math.cos(a)) * SS, (32 + 28 * math.sin(a)) * SS], fill=(255, 255, 255, 255), width=SS * 5)
    finish(img, 64, 64).save(os.path.join(folder, "flake.png"))


def fix_panda_ears():
    """The panda's black ears were lost when the sprite background was removed.
    Paint them back in behind the head (safe to run more than once)."""
    path = os.path.join(IMG, "jelly_sprites", "jelly_11.png")
    sprite = Image.open(path).convert("RGBA")
    w, h = sprite.size
    ears = canvas(w, h)
    d = ImageDraw.Draw(ears)
    for cx, cy in ((36, 30), (121, 28)):
        d.ellipse(S(cx - 19, cy - 19, cx + 19, cy + 19), fill=hexc("#23232f"))
    ears = finish(ears, w, h)
    ears.alpha_composite(sprite)
    ears.save(path)


if __name__ == "__main__":
    for chest_name, (chest_color, chest_emblem) in CHESTS.items():
        make_chest(chest_name, chest_color, chest_emblem)
    # Seasonal jellies now come from the supplied sheet:
    # see scripts/cut_seasonal_jellies.py (seasonal_jellies() is the old drawn set).
    particle_textures()
    fix_panda_ears()
    print("done")
