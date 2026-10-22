"""Cut the 16 seasonal jellies out of art_source/seasonal_jellies_sheet.png.

The sheet is a 4x4 grid on pure black. Black that touches the outside is
flood-filled away (black hats and sunglasses inside a jelly stay). Each
remaining piece is given to the grid cell its centre falls in, so hats that
poke over a cell line still stay with their jelly.
Output: images/jelly_sprites/jelly_50..65.png
"""
import os
from collections import deque
from PIL import Image, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHEET = os.path.join(ROOT, "art_source", "seasonal_jellies_sheet.png")
OUT = os.path.join(ROOT, "images", "jelly_sprites")
# Sheet order (rows): spring, summer, fall, winter -> game skin ids.
ORDER = [58, 59, 60, 61, 62, 63, 64, 65, 50, 51, 52, 53, 54, 55, 56, 57]
CANVAS = (154, 147)
THRESHOLD = 26  # max channel value treated as background black
MIN_PIECE = 150  # pixels; smaller specks are dropped


def main():
    sheet = Image.open(SHEET).convert("RGB")
    w, h = sheet.size
    px = sheet.load()
    background = bytearray(w * h)
    queue = deque()
    for x in range(w):
        queue.extend(((x, 0), (x, h - 1)))
    for y in range(h):
        queue.extend(((0, y), (w - 1, y)))
    while queue:
        x, y = queue.popleft()
        i = y * w + x
        if background[i] or max(px[x, y]) > THRESHOLD:
            continue
        background[i] = 1
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and not background[ny * w + nx]:
                queue.append((nx, ny))

    # Label foreground pieces and assign each to a grid cell by its centre.
    label = [0] * (w * h)
    cell_of = {}
    current = 0
    cw, ch = w / 4.0, h / 4.0
    for start in range(w * h):
        if background[start] or label[start]:
            continue
        current += 1
        label[start] = current
        stack = [start]
        count = sx = sy = 0
        while stack:
            i = stack.pop()
            x, y = i % w, i // w
            count += 1
            sx += x
            sy += y
            for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny * w + nx
                    if not background[j] and not label[j]:
                        label[j] = current
                        stack.append(j)
        if count >= MIN_PIECE:
            col = min(3, int((sx / count) / cw))
            row = min(3, int((sy / count) / ch))
            cell_of[current] = row * 4 + col

    masks = [Image.new("L", (w, h), 0) for _ in range(16)]
    mask_px = [m.load() for m in masks]
    for i, piece in enumerate(label):
        cell = cell_of.get(piece)
        if cell is not None:
            mask_px[cell][i % w, i // w] = 255

    for index, skin_id in enumerate(ORDER):
        alpha = masks[index]
        box = alpha.getbbox()
        alpha = alpha.crop(box)
        art = sheet.crop(box)
        ap = alpha.load()
        apx = art.load()
        # Fade the dark fringe left over from the black background.
        edge = alpha.filter(ImageFilter.MinFilter(3)).load()
        for y in range(alpha.height):
            for x in range(alpha.width):
                if ap[x, y] == 255 and edge[x, y] == 0:
                    ap[x, y] = min(255, int(max(apx[x, y]) * 2.2))
        alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))
        sprite = art.convert("RGBA")
        sprite.putalpha(alpha)
        scale = min(CANVAS[0] / sprite.width, CANVAS[1] / sprite.height)
        sprite = sprite.resize((max(1, round(sprite.width * scale)), max(1, round(sprite.height * scale))), Image.LANCZOS)
        canvas = Image.new("RGBA", CANVAS, (0, 0, 0, 0))
        canvas.alpha_composite(sprite, ((CANVAS[0] - sprite.width) // 2, CANVAS[1] - sprite.height))
        canvas.save(os.path.join(OUT, f"jelly_{skin_id:02d}.png"))
    print("cut", len(ORDER))


if __name__ == "__main__":
    main()
