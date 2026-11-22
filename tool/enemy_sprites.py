"""Pixel-art spritesheet for the slime enemy (assets/images/enemies/slime.png).

Sheet: 8 columns x 2 rows of 32x32 frames, facing left.
  row 0  move  (8 frames, looping squash & stretch hop)
  row 1  death (6 frames, splat into a puddle + droplets, then gone)

Same look as the original vector slime: purple body, lighter belly patch,
big white eyes, dark outline, cel shading lit from the upper left.

Usage:  python3 tool/enemy_sprites.py [--preview PATH]
"""

import argparse
import math
import os

import numpy as np
from PIL import Image

F = 32
COLS = 8
OUT = 'assets/images/enemies/slime.png'


def hx(s):
    s = s.lstrip('#')
    return np.array([int(s[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)


OUTLINE = hx('#2a123f')
DARK = hx('#6a3399')
BASE = hx('#8e4fc8')
LIGHT = hx('#b57ce6')
HI = hx('#e2c6f7')
WHITE = hx('#ffffff')
EYE_SHADE = hx('#d8cce6')
PUPIL = hx('#14081f')


class Canvas:
    def __init__(self):
        ys, xs = np.mgrid[0:F, 0:F].astype(float) + 0.5
        self.xs, self.ys = xs, ys
        self.rgb = np.zeros((F, F, 3))
        self.mask = np.zeros((F, F), bool)
        self.no_outline = np.zeros((F, F), bool)

    def ellipse(self, cx, cy, rx, ry):
        u = (self.xs - cx) / rx
        v = (self.ys - cy) / ry
        return u * u + v * v <= 0.97, u, v

    def paint(self, m, color, outline=True):
        self.rgb[m] = color
        self.mask |= m
        if not outline:
            self.no_outline |= m

    def finish(self):
        a = self.mask
        grow = np.zeros_like(a)
        grow[1:, :] |= a[:-1, :]
        grow[:-1, :] |= a[1:, :]
        grow[:, 1:] |= a[:, :-1]
        grow[:, :-1] |= a[:, 1:]
        ring = grow & ~a
        # droplets etc. that asked for no outline don't spawn one
        self.rgb[ring] = OUTLINE
        alpha = a | ring
        img = np.zeros((F, F, 4), np.uint8)
        img[..., :3] = np.clip(self.rgb, 0, 255).astype(np.uint8)
        img[..., 3] = np.where(alpha, 255, 0)
        return Image.fromarray(img, 'RGBA')


def body(c, cx, ground, w, h, lean=0.0, eyes='open', look=-1.0):
    """Slime body resting on [ground]: half-dome with a flat-ish bottom."""
    # Centre below the half height so the ground cuts a flat base.
    cy = ground - h * 0.42
    _, u, v = c.ellipse(cx, cy, w / 2, h / 2)
    # lean: shift the top forward (left) while moving
    u = u + lean * np.clip(-v, 0, 1)
    m = (u * u + v * v) <= 0.93
    flat = c.ys < ground
    m &= flat
    s = -0.55 * u - 0.8 * v  # light from upper left
    col = np.empty((F, F, 3))
    col[:] = BASE
    col[s > 0.35] = LIGHT
    col[(s > 0.75) & (u * u + v * v < 0.55)] = HI
    col[(s < -0.35)] = DARK
    col[(u * u + v * v > 0.8) & (s < 0.05)] = DARK
    c.paint(m, col[m])
    # glossy highlight blob top-left
    hm, _, _ = c.ellipse(cx - w * 0.22, cy - h * 0.22, max(1.2, w * 0.1), max(1.0, h * 0.09))
    c.paint(hm & m, HI)

    if eyes == 'none':
        return
    ex0 = cx + look * w * 0.12
    ey = cy - h * 0.08
    for dx in (-w * 0.17, w * 0.17):
        ex = ex0 + dx
        if eyes == 'x':
            for k in range(-1, 2):
                for (px, py) in ((ex + k, ey + k), (ex + k, ey - k)):
                    xi, yi = int(math.floor(px)), int(math.floor(py))
                    if 0 <= xi < F and 0 <= yi < F:
                        c.rgb[yi, xi] = PUPIL
            continue
        em, eu, ev = c.ellipse(ex, ey, 2.4, 2.9 if eyes == 'open' else 1.0)
        col = np.empty((F, F, 3))
        col[:] = WHITE
        col[ev > 0.45] = EYE_SHADE
        c.paint(em, col[em])
        if eyes == 'open':
            pm, _, _ = c.ellipse(ex + look * 0.9, ey + 0.3, 1.1, 1.5)
            c.paint(pm, PUPIL)
            c.paint((c.xs // 1 == math.floor(ex - 0.6)) & (c.ys // 1 == math.floor(ey - 1.2)) & em, WHITE)
        else:  # squint line
            c.paint(em, PUPIL)


GROUND = 29.0
CX = 16.0


def move_frame(i):
    t = i / COLS * 2 * math.pi
    s = math.sin(t)
    hop = max(0.0, math.sin(t)) * 2.0  # airborne half of the cycle
    w = 22 * (1 - 0.10 * s)
    h = 17 * (1 + 0.14 * s)
    c = Canvas()
    body(c, CX, GROUND - hop, w, h, lean=0.18 * max(0, s), eyes='open')
    return c.finish()


def drop(c, x, y, r):
    m, _, _ = c.ellipse(x, y, r, r * 1.1)
    c.paint(m, LIGHT)


def death_frame(i):
    c = Canvas()
    if i == 0:  # squash, eyes shut
        body(c, CX, GROUND, 25, 12, eyes='shut')
    elif i == 1:  # flatter, X eyes
        body(c, CX, GROUND, 28, 8, eyes='x')
    elif i == 2:  # puddle + droplets leaving
        body(c, CX, GROUND, 28, 5, eyes='none')
        for x, y in ((8, 18), (24, 17), (16, 14)):
            drop(c, x, y, 1.6)
    elif i == 3:
        body(c, CX, GROUND, 24, 4, eyes='none')
        for x, y in ((5, 15), (27, 13), (16, 9)):
            drop(c, x, y, 1.4)
    elif i == 4:
        body(c, CX, GROUND, 16, 3, eyes='none')
        for x, y in ((3, 14), (29, 12), (16, 5)):
            drop(c, x, y, 1.1)
    else:  # last wisps
        for x, y in ((2, 16), (30, 15), (16, 3)):
            drop(c, x, y, 0.8)
    return c.finish()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--preview')
    a = ap.parse_args()
    sheet = Image.new('RGBA', (F * COLS, F * 2), (0, 0, 0, 0))
    for i in range(COLS):
        sheet.paste(move_frame(i), (i * F, 0))
    for i in range(6):
        sheet.paste(death_frame(i), (i * F, F))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    sheet.save(OUT)
    print('wrote', OUT, sheet.size)
    if a.preview:
        bg = Image.new('RGBA', sheet.size, (120, 140, 100, 255))
        bg.alpha_composite(sheet)
        bg.resize((sheet.width * 6, sheet.height * 6), Image.NEAREST).save(a.preview)


if __name__ == '__main__':
    main()
