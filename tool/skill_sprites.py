"""Pixel-art spritesheets for the elemental skills (assets/images/skills/).

One sheet per element: fire.png, water.png, air.png, earth.png.
Each is 4 columns x 3 rows of 32x32 frames:
  row 0  projectile in flight (looping, drawn travelling RIGHT -> rotate it)
  row 1  impact burst on the enemy (one-shot)
  row 2  status overlay drawn on top of an affected slime (aligned with the
         32x32 slime frame): burning / slowed / blown back / dust

Same look as the birds and the slime: 1px dark outline, flat cel shading.

Usage:  python3 tool/skill_sprites.py [--preview PATH]
"""

import argparse
import math
import os

import numpy as np
from PIL import Image, ImageDraw

F = 32
COLS = 4
OUT_DIR = 'assets/images/skills'


def hx(s):
    s = s.lstrip('#')
    return np.array([int(s[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)


class Frame:
    """Layered pixel canvas: shapes are painted in order, then a 1px outline
    is added around everything that has [outline] on."""

    def __init__(self):
        self.rgb = np.zeros((F, F, 3))
        self.alpha = np.zeros((F, F), bool)
        self.outlined = np.zeros((F, F), bool)

    @staticmethod
    def _mask(draw_fn):
        im = Image.new('L', (F, F), 0)
        draw_fn(ImageDraw.Draw(im))
        return np.asarray(im) > 127

    def poly(self, pts, color, outline=True):
        m = self._mask(lambda d: d.polygon([tuple(p) for p in pts], fill=255))
        self._paint(m, color, outline)
        return m

    def circle(self, cx, cy, r, color, outline=True):
        if r < 0.6:
            m = np.zeros((F, F), bool)
            xi, yi = int(round(cx)), int(round(cy))
            if 0 <= xi < F and 0 <= yi < F:
                m[yi, xi] = True
        else:
            m = self._mask(lambda d: d.ellipse(
                (cx - r, cy - r, cx + r - 1, cy + r - 1), fill=255))
        self._paint(m, color, outline)
        return m

    def line(self, pts, color, width=1, outline=False):
        m = self._mask(lambda d: d.line([tuple(p) for p in pts], fill=255, width=width))
        self._paint(m, color, outline)
        return m

    def pixel(self, x, y, color):
        xi, yi = int(round(x)), int(round(y))
        if 0 <= xi < F and 0 <= yi < F:
            self.rgb[yi, xi] = color
            self.alpha[yi, xi] = True

    def _paint(self, m, color, outline):
        self.rgb[m] = color
        self.alpha |= m
        if outline:
            self.outlined |= m

    def image(self, outline_color):
        a = self.outlined
        grow = np.zeros_like(a)
        grow[1:, :] |= a[:-1, :]
        grow[:-1, :] |= a[1:, :]
        grow[:, 1:] |= a[:, :-1]
        grow[:, :-1] |= a[:, 1:]
        ring = grow & ~self.alpha
        rgb = self.rgb.copy()
        rgb[ring] = outline_color
        alpha = self.alpha | ring
        out = np.zeros((F, F, 4), np.uint8)
        out[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
        out[..., 3] = np.where(alpha, 255, 0)
        return Image.fromarray(out, 'RGBA')


def rot(pts, cx, cy, ang):
    c, s = math.cos(ang), math.sin(ang)
    return [(cx + (x - cx) * c - (y - cy) * s, cy + (x - cx) * s + (y - cy) * c)
            for x, y in pts]


def ring_points(cx, cy, r, n, phase=0.0):
    return [(cx + r * math.cos(phase + 2 * math.pi * i / n),
             cy + r * math.sin(phase + 2 * math.pi * i / n)) for i in range(n)]


# ------------------------------------------------------------------ fire ----

FIRE = dict(out=hx('#4a1208'), red=hx('#e53935'), orange=hx('#ff8f00'),
            yellow=hx('#ffd54f'), core=hx('#fff8e1'), smoke=hx('#6d5a55'))


def fire_projectile(i):
    f = Frame()
    cx, cy = 20, 16
    wob = [0, 1, 0, -1][i]
    tail = 13 + [0, 2, 1, 3][i]
    # outer flame: teardrop pointing left
    f.poly([(cx - tail, cy + wob), (cx - 4, cy - 6), (cx + 3, cy - 6),
            (cx + 6, cy - 2), (cx + 6, cy + 2), (cx + 3, cy + 6),
            (cx - 4, cy + 6)], FIRE['red'])
    f.poly([(cx - tail + 4, cy + wob), (cx - 3, cy - 4), (cx + 3, cy - 4),
            (cx + 5, cy), (cx + 3, cy + 4), (cx - 3, cy + 4)], FIRE['orange'])
    f.circle(cx + 1, cy, 3.5, FIRE['yellow'])
    f.circle(cx + 2, cy - 1, 1.6, FIRE['core'])
    # embers
    for k, (dx, dy) in enumerate([(-tail - 2, -3), (-tail + 1, 4), (-tail - 4, 1)]):
        if (i + k) % 2 == 0:
            f.pixel(cx + dx, cy + dy, FIRE['orange'])
    return f.image(FIRE['out'])


def fire_impact(i):
    f = Frame()
    cx, cy = 16, 18
    r = [4, 7, 10, 12][i]
    if i < 3:
        for k in range(7):
            a = 2 * math.pi * k / 7 + i * 0.4
            tip = (cx + math.cos(a) * (r + 3), cy + math.sin(a) * (r + 3))
            l = (cx + math.cos(a - 0.35) * r * 0.5, cy + math.sin(a - 0.35) * r * 0.5)
            rr = (cx + math.cos(a + 0.35) * r * 0.5, cy + math.sin(a + 0.35) * r * 0.5)
            f.poly([l, tip, rr], FIRE['red'] if i == 2 else FIRE['orange'])
        f.circle(cx, cy, max(2, r * 0.6), FIRE['orange'])
        f.circle(cx, cy, max(1.5, r * 0.4), FIRE['yellow'])
        if i == 0:
            f.circle(cx, cy, 1.5, FIRE['core'])
    else:  # smoke puffs
        for (dx, dy, rad) in [(-6, -4, 3), (5, -6, 3.5), (0, -9, 2.5), (7, 2, 2.5), (-7, 3, 2)]:
            f.circle(cx + dx, cy + dy, rad, FIRE['smoke'])
    return f.image(FIRE['out'])


def fire_status(i):
    """Small flames dancing on top of a slime (body top ~ y 13)."""
    f = Frame()
    for k, (x, base, h) in enumerate([(10, 17, 8), (16, 14, 11), (22, 17, 8)]):
        hh = h + [0, 2, -1, 1][(i + k) % 4]
        sway = [0, 1, 0, -1][(i + k) % 4]
        f.poly([(x - 3, base), (x + sway, base - hh), (x + 3, base)], FIRE['red'])
        f.poly([(x - 1.5, base), (x + sway, base - hh * 0.6), (x + 1.5, base)], FIRE['yellow'])
    return f.image(FIRE['out'])


# ----------------------------------------------------------------- water ----

WATER = dict(out=hx('#0d2a5c'), dark=hx('#1565c0'), base=hx('#42a5f5'),
             light=hx('#90caf9'), white=hx('#ffffff'), foam=hx('#e3f2fd'))


def water_projectile(i):
    f = Frame()
    cx, cy = 19, 16
    s = [0, 0.5, 0, -0.5][i]
    f.poly([(cx - 11, cy), (cx - 3, cy - 5 - s), (cx + 3, cy - 5 - s), (cx + 6, cy - 2),
            (cx + 6, cy + 2), (cx + 3, cy + 5 + s), (cx - 3, cy + 5 + s)], WATER['dark'])
    f.poly([(cx - 8, cy), (cx - 2, cy - 4), (cx + 3, cy - 4), (cx + 5, cy - 1),
            (cx + 4, cy + 2), (cx - 2, cy + 3)], WATER['base'])
    f.circle(cx + 1, cy - 1, 2.6, WATER['light'])
    f.pixel(cx + 2, cy - 2, WATER['white'])
    f.pixel(cx + 1, cy - 2, WATER['white'])
    # trailing droplets
    for k, (dx, dy) in enumerate([(-14, -2), (-17, 2), (-20, -1)]):
        if (i + k) % 3 != 2:
            f.circle(cx + dx + i % 2, cy + dy, 1.0, WATER['base'])
    return f.image(WATER['out'])


def water_impact(i):
    f = Frame()
    cx, cy = 16, 20
    r = [3, 6, 9, 11][i]
    if i < 3:
        f.circle(cx, cy, r, WATER['base'])
        f.circle(cx, cy, max(1, r - 2.5), WATER['light'] if i else WATER['white'])
        if i > 0:
            f.circle(cx, cy, max(0.5, r - 5), WATER['base'], outline=False)
    for k in range(6):
        a = math.pi + math.pi * k / 5
        d = r + 2 + i * 2
        f.circle(cx + math.cos(a) * d, cy + math.sin(a) * d * 0.9 + (i * 1.5 if i > 1 else 0),
                 [1.6, 1.5, 1.2, 1.0][i], WATER['light'])
    return f.image(WATER['out'])


def water_status(i):
    """Dripping wet slime: drops sliding down its sides + small puddle."""
    f = Frame()
    f.poly([(6, 30), (9, 28), (23, 28), (26, 30)], WATER['base'])
    for k, (x, y0) in enumerate([(8, 18), (24, 17), (13, 14), (20, 15)]):
        y = y0 + ((i + k * 2) % 4) * 3
        f.circle(x, y, 1.6, WATER['base'])
        f.pixel(x - 1 + 0.5, y - 1, WATER['white'])
    # slow-down "bubbles" above
    for k, x in enumerate([11, 21]):
        y = 9 - ((i + k * 2) % 4)
        f.circle(x, y, 1.4, WATER['light'])
    return f.image(WATER['out'])


# ------------------------------------------------------------------- air ----

AIR = dict(out=hx('#1f4e5a'), base=hx('#80deea'), light=hx('#e0f7fa'),
           white=hx('#ffffff'), dark=hx('#4dd0e1'))


def air_projectile(i):
    f = Frame()
    cx, cy = 19, 16
    phase = i * math.pi / 2
    # swirling ring with a gap that rotates
    outer = ring_points(cx, cy, 6.5, 16, phase)
    f.poly(outer[:13] + [(cx, cy)], AIR['dark'])
    f.circle(cx, cy, 4.5, AIR['base'])
    inner = ring_points(cx, cy, 3.5, 12, -phase)
    f.poly(inner[:8] + [(cx, cy)], AIR['light'])
    f.circle(cx, cy, 1.2, AIR['white'])
    # trailing wind streaks
    for k, (dy, l) in enumerate([(-4, 9), (0, 13), (4, 8)]):
        off = (i + k) % 2
        f.line([(cx - 7 - l - off, cy + dy), (cx - 8 - off, cy + dy)], AIR['light'], outline=True)
    return f.image(AIR['out'])


def air_impact(i):
    f = Frame()
    cx, cy = 16, 18
    r = [4, 7, 10, 12][i]
    pts = ring_points(cx, cy, r, 24, i * 0.5)
    for k in range(0, 24, 3):
        seg = pts[k:k + 2] if k + 2 <= 24 else pts[k:] + pts[:1]
        f.line(seg, AIR['light'] if i < 3 else AIR['base'], width=2, outline=True)
    if i < 2:
        f.circle(cx, cy, 2.5 - i, AIR['white'])
    return f.image(AIR['out'])


def air_status(i):
    """Gust streaks blowing across a slime (pushed back)."""
    f = Frame()
    for k, (y, l) in enumerate([(12, 10), (18, 14), (24, 9)]):
        x0 = 2 + ((i * 5 + k * 7) % 14)
        f.line([(x0, y), (x0 + l, y)], AIR['light'], outline=True)
        f.pixel(x0 + l + 1, y - 1, AIR['white'])
    return f.image(AIR['out'])


# ----------------------------------------------------------------- earth ----

EARTH = dict(out=hx('#2b1a12'), dark=hx('#5d4037'), base=hx('#8d6e63'),
             light=hx('#bcaaa4'), dust=hx('#d7ccc8'), moss=hx('#7cb342'))

ROCK = [(-5, -3), (-1, -6), (4, -4), (6, 0), (4, 5), (-2, 6), (-6, 2)]


def rock(f, cx, cy, ang, scale=1.0):
    pts = rot([(cx + x * scale, cy + y * scale) for x, y in ROCK], cx, cy, ang)
    f.poly(pts, EARTH['base'])
    lit = rot([(cx + x * scale * 0.55 - 1, cy + y * scale * 0.55 - 1) for x, y in ROCK[:4]] +
              [(cx, cy)], cx, cy, ang)
    f.poly(lit, EARTH['light'])
    crack = rot([(cx + 1 * scale, cy - 1 * scale), (cx + 3 * scale, cy + 2 * scale)], cx, cy, ang)
    f.line(crack, EARTH['dark'])


def earth_projectile(i):
    f = Frame()
    cx, cy = 19, 16
    rock(f, cx, cy, i * math.pi / 2)
    for k, (dx, dy) in enumerate([(-10, 2), (-13, -2), (-16, 1)]):
        if (i + k) % 2 == 0:
            f.pixel(cx + dx, cy + dy, EARTH['dust'])
    return f.image(EARTH['out'])


def earth_impact(i):
    f = Frame()
    cx, cy = 16, 20
    d = [2, 5, 8, 11][i]
    for k, (ax, ay) in enumerate([(-1, -0.8), (1, -1), (-1.2, 0.3), (1.1, 0.4), (0, -1.3)]):
        rock(f, cx + ax * d, cy + ay * d + (i * i * 0.4), i * 0.8 + k, 0.35)
    if i < 3:
        for (dx, dy, r) in [(-4, 3, 2.5 + i), (4, 3, 2 + i), (0, 4, 2 + i)]:
            f.circle(cx + dx, cy + dy, r, EARTH['dust'], outline=False)
    return f.image(EARTH['out'])


def earth_status(i):
    """Dust kicked up at the slime's base (earth has no lasting effect)."""
    f = Frame()
    for k, x in enumerate([7, 13, 19, 25]):
        r = 1.5 + ((i + k) % 3) * 0.6
        f.circle(x, 28 - ((i + k) % 2), r, EARTH['dust'], outline=False)
    return f.image(EARTH['out'])


ELEMENTS = {
    'fire': (fire_projectile, fire_impact, fire_status),
    'water': (water_projectile, water_impact, water_status),
    'air': (air_projectile, air_impact, air_status),
    'earth': (earth_projectile, earth_impact, earth_status),
}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--preview')
    a = ap.parse_args()
    os.makedirs(OUT_DIR, exist_ok=True)
    sheets = []
    for name, rows in ELEMENTS.items():
        sheet = Image.new('RGBA', (F * COLS, F * 3), (0, 0, 0, 0))
        for r, fn in enumerate(rows):
            for c in range(COLS):
                sheet.paste(fn(c), (c * F, r * F))
        sheet.save(os.path.join(OUT_DIR, f'{name}.png'))
        sheets.append(sheet)
        print('wrote', name)
    if a.preview:
        pv = Image.new('RGBA', (len(sheets) * (F * COLS + 8), F * 3), (120, 140, 100, 255))
        for i, sh in enumerate(sheets):
            pv.alpha_composite(sh, (i * (F * COLS + 8), 0))
        pv.resize((pv.width * 4, pv.height * 4), Image.NEAREST).save(a.preview)


if __name__ == '__main__':
    main()
