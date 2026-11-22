"""Procedural renderer for the HD bird spritesheets in assets/images/pets_final.

Each sheet is 256x256: a 4x4 grid of 64x64 frames, bird facing left.
Rows (see BirdSheet in pet_species_catalog.dart):
  0 fly   1 react   2 idle   3 hop

Usage:  python3 tool/bird_sprites.py [species ...] [--out DIR] [--preview]
"""

from __future__ import annotations

import argparse
import math
import os
from dataclasses import dataclass, field

import numpy as np
from PIL import Image

FRAME = 64
N = FRAME


# ---------------------------------------------------------------- colours --

def hx(s: str) -> np.ndarray:
    s = s.lstrip('#')
    return np.array([int(s[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)


def mix(a, b, t):
    return a * (1 - t) + b * t


def ramp(base: str, dark: str | None = None, light: str | None = None,
         hi: str | None = None):
    """4-tone material: [shadow, base, light, highlight]."""
    b = hx(base)
    d = hx(dark) if dark else mix(b, hx('#101830'), 0.38)
    l = hx(light) if light else mix(b, hx('#ffffff'), 0.22)
    h = hx(hi) if hi else mix(b, hx('#ffffff'), 0.45)
    return [d, b, l, h]


# ------------------------------------------------------------------ shapes --

class Shape:
    """Implicit shape in bird space. eval(bx, by) -> (inside, u, v)
    where u, v are local coords (roughly -1..1) used for shading."""

    def eval(self, bx, by):
        raise NotImplementedError


@dataclass
class Ellipse(Shape):
    cx: float
    cy: float
    rx: float
    ry: float
    ang: float = 0.0  # degrees, clockwise on screen (y down)

    def eval(self, bx, by):
        a = math.radians(self.ang)
        dx, dy = bx - self.cx, by - self.cy
        lx = dx * math.cos(a) + dy * math.sin(a)
        ly = -dx * math.sin(a) + dy * math.cos(a)
        u, v = lx / self.rx, ly / self.ry
        return u * u + v * v <= 0.97, u, v


@dataclass
class Poly(Shape):
    pts: list

    def eval(self, bx, by):
        pts = self.pts
        inside = np.zeros(bx.shape, bool)
        j = len(pts) - 1
        for i in range(len(pts)):
            xi, yi = pts[i]
            xj, yj = pts[j]
            cond = ((yi > by) != (yj > by))
            with np.errstate(divide='ignore', invalid='ignore'):
                xint = (xj - xi) * (by - yi) / (yj - yi + 1e-9) + xi
            inside ^= cond & (bx < xint)
            j = i
        xs = [p[0] for p in pts]
        ys = [p[1] for p in pts]
        cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
        rx, ry = max(1, (max(xs) - min(xs)) / 2), max(1, (max(ys) - min(ys)) / 2)
        return inside, (bx - cx) / rx, (by - cy) / ry


@dataclass
class Strip(Shape):
    """Tapered band from p0 to p1 (tail, beak, legs). u: 0..1 along, v: -1..1."""
    p0: tuple
    p1: tuple
    w0: float
    w1: float
    round_end: bool = False

    def eval(self, bx, by):
        x0, y0 = self.p0
        x1, y1 = self.p1
        L = math.hypot(x1 - x0, y1 - y0)
        ax, ay = (x1 - x0) / L, (y1 - y0) / L
        dx, dy = bx - x0, by - y0
        t = (dx * ax + dy * ay) / L
        s = -dx * ay + dy * ax
        w = (self.w0 + (self.w1 - self.w0) * np.clip(t, 0, 1)) / 2
        inside = (t >= 0) & (t <= 1) & (np.abs(s) <= w)
        if self.round_end:
            ex, ey = bx - x1, by - y1
            inside |= (ex * ex + ey * ey) <= (self.w1 / 2) ** 2
        return inside, t, s / np.maximum(w, 1e-6)


# ------------------------------------------------------------------- parts --

@dataclass
class Part:
    name: str
    shape: Shape
    paint: object  # callable(u, v, bx, by) -> (H, W, 3) colours, or a ramp
    group: str = 'body'  # 'body' follows body transform, 'head', 'wing', 'leg'
    edge: bool = False  # draw a dark line where it overlaps earlier parts
    edge_color: np.ndarray | None = None


def shade_ramp(r, light=(-0.55, -0.8), soft=False):
    """Classic cel shading: light from the upper left."""
    lx, ly = light

    def paint(u, v, bx, by):
        s = u * lx + v * ly
        rr = u * u + v * v
        out = np.empty(u.shape + (3,))
        out[:] = r[1]
        out[s > 0.35] = r[2]
        if not soft:
            out[(s > 0.75) & (rr < 0.6)] = r[3]
        out[(s < -0.45)] = r[0]
        out[(rr > 0.82) & (s < 0.1)] = r[0]
        return out
    return paint


def flat(c):
    c = hx(c) if isinstance(c, str) else c

    def paint(u, v, bx, by):
        out = np.empty(u.shape + (3,))
        out[:] = c
        return out
    return paint


# ------------------------------------------------------------------- poses --

@dataclass
class Pose:
    dx: float = 0
    dy: float = 0
    tilt: float = 0  # extra body rotation (deg) around the hip
    head_dx: float = 0
    head_dy: float = 0
    wing: str = 'fold'  # fold | up | high | mid | back
    legs: str = 'stand'  # stand | crouch | tuck | none
    crest: float = 1.0  # crest scale
    squash: float = 0  # >0 crouch (wider, lower body)


POSES = [
    # fly
    [Pose(dx=1, dy=-3, tilt=12, wing='high', legs='none'),
     Pose(dx=1, dy=-2, tilt=12, wing='up', legs='none'),
     Pose(dx=1, dy=-1, tilt=10, wing='back', legs='none'),
     Pose(dx=1, dy=-2, tilt=12, wing='mid', legs='none')],
    # react
    [Pose(),
     Pose(dy=-1, head_dy=-1, crest=1.35),
     Pose(dy=-1, head_dy=-1, crest=1.35, wing='high'),
     Pose(head_dy=0, crest=1.15, wing='mid')],
    # idle
    [Pose(),
     Pose(dy=1, head_dy=0, squash=0.5),
     Pose(head_dy=0),
     Pose(head_dx=-1, head_dy=-1)],
    # hop
    [Pose(dy=2, squash=1, legs='crouch'),
     Pose(dy=-3, legs='tuck', crest=1.1),
     Pose(dy=-5, legs='tuck', crest=1.15, wing='mid'),
     Pose(dy=-1, legs='stand')],
]


# ----------------------------------------------------------------- species --

@dataclass
class Spec:
    name: str
    outline: str
    body: list  # ramp
    belly: list
    wing: list
    tail: list
    head: list
    beak: tuple = ('#2a2a30', '#14141a')  # (upper, lower)
    beak_len: float = 9
    beak_w: float = 3.8
    legs: str = '#3a3f4f'
    eye: str = '#0b0b10'
    crest: float = 0  # 0 = none; >0 relative height
    crest_color: list | None = None
    face: str = 'none'
    tail_len: float = 1.0
    tail_w: float = 7
    tail_pattern: str = 'plain'  # plain | bars | tip | dark_tip
    tail_tip: str | None = None
    wing_pattern: str = 'feathers'  # feathers | bars | spots
    wing_extra: dict = field(default_factory=dict)
    size: float = 1.0
    head_r: float = 10
    eye_ring: str | None = None
    belly_pattern: str = 'plain'  # plain | spots | streaks
    pattern_color: str = '#3a2a20'
    face_colors: dict = field(default_factory=dict)


def build_parts(sp: Spec, pose: Pose):
    """Return list of (Part, transform) in draw order."""
    parts = []
    k = sp.size
    sq = pose.squash

    # --- reference geometry (bird space, ~standing pose of the blue jay) ---
    hip = (30.0, 44.0)
    body_c = (31.0, 39.0 + sq * 0.6)
    body = Ellipse(body_c[0], body_c[1], 14.5 * k + sq * 0.6, 9.0 * k - sq * 0.4, 28)
    belly = Ellipse(body_c[0] - 4.5 * k, body_c[1] + 2.5 * k, 12.0 * k, 7.0 * k, 20)
    head_c = (21.5 + pose.head_dx, 27.0 + pose.head_dy + (1 - k) * 6 + sq * 0.5)

    # tail
    tl = 19 * sp.tail_len
    ang = math.radians(58)
    t0 = (body_c[0] + 8 * k, body_c[1] + 3 * k)
    t1 = (t0[0] + tl * math.cos(ang), t0[1] + tl * math.sin(ang))
    tail = Strip(t0, t1, sp.tail_w * 0.85, sp.tail_w)

    def tail_paint(u, v, bx, by):
        r = sp.tail
        out = np.empty(u.shape + (3,))
        out[:] = r[1]
        out[v < -0.35] = r[2]
        out[v > 0.45] = r[0]
        if sp.tail_pattern == 'bars':
            d = np.floor(u * tl)
            bar = (d % 3 == 0) & (u > 0.2) & (np.abs(v) < 0.95)
            out[bar] = mix(hx(sp.outline), r[0], 0.35)
            out[(d % 3 == 1) & (v < 0.3)] = r[2]
        if sp.tail_pattern in ('bars', 'tip', 'dark_tip') or sp.tail_tip:
            tip = hx(sp.tail_tip or '#f4f7ff')
            out[u > 1 - 2.2 / tl] = tip
        center = (np.abs(v) < 0.16) & (u < 0.84)
        if sp.tail_pattern != 'bars':
            out[center] = r[0]
        return out

    parts.append((Part('tail', tail, tail_paint, edge=False), 'body'))

    # far leg is drawn as part of the leg group later
    parts.append((Part('body', body, shade_ramp(sp.body)), 'body'))

    def belly_paint(u, v, bx, by):
        out = shade_ramp(sp.belly)(u, v, bx, by)
        if 'breast' in sp.face_colors:
            br = shade_ramp(ramp(sp.face_colors['breast']))(u, v, bx, by)
            m = (u + v * 0.5) < sp.face_colors.get('cover', 0.25)
            out[m] = br[m]
        if sp.belly_pattern == 'spots':
            ix, iy = np.floor(bx).astype(int), np.floor(by).astype(int)
            m = ((ix + (iy // 3) * 2) % 4 == 0) & (iy % 3 != 2) & (v > -0.75) & (u < 0.75)
            out[m] = hx(sp.pattern_color)
        elif sp.belly_pattern == 'streaks':
            m = ((np.round(bx) + np.round(by) * 2) % 5 == 0) & (v > -0.8)
            out[m] = hx(sp.pattern_color)
        return out

    parts.append((Part('belly', belly, belly_paint), 'body'))

    # --- wing ---
    wing_r = sp.wing
    ol = hx(sp.outline)

    def wing_paint_folded(u, v, bx, by):
        out = shade_ramp(wing_r)(u, v, bx, by)
        # coverts lighter, primaries toward the back
        out[(u < -0.2) & (v < 0.2)] = wing_r[2]
        if sp.wing_pattern == 'bars':
            d = np.floor(u * 12.5 * k)
            bar = (d % 3 == 0) & (u > -0.15) & (v > -0.55)
            out[bar] = mix(ol, wing_r[0], 0.3)
        elif sp.wing_pattern == 'spots':
            out[(u > -0.1) & (u < 0.15) & (np.abs(v) < 0.5)] = hx(sp.wing_extra.get('patch', '#ffffff'))
        # feather separations along the long axis
        for off in (0.3,):
            line = (np.abs(v - off) < 0.14) & (u > 0.0)
            out[line] = wing_r[0]
        if 'tip' in sp.wing_extra:
            out[u > 0.65] = hx(sp.wing_extra['tip'])
        if 'shoulder' in sp.wing_extra:
            out[(u < -0.35)] = hx(sp.wing_extra['shoulder'])
        if 'dot' in sp.wing_extra:
            out[(u > 0.3) & (u < 0.5) & (np.abs(v + 0.1) < 0.35)] = hx(sp.wing_extra['dot'])
        return out

    def wing_paint_open(u, v, bx, by):
        # u along wing (0 root .. 1 tip-ish), v across
        out = shade_ramp(wing_r)(u, v, bx, by)
        out[v < -0.2] = wing_r[2]
        out[(v < -0.55) & (u > -0.2)] = wing_r[3]
        # radial feather lines on trailing half
        if sp.wing_pattern == 'bars':
            d = np.floor(u * 14)
            bar = (d % 3 == 0) & (v > -0.2) & (u > -0.3)
            out[bar] = mix(ol, wing_r[0], 0.3)
        lines = (np.floor((u + 1) * 6) % 2 == 0) & (v > 0.35)
        out[lines] = wing_r[0]
        if 'tip' in sp.wing_extra:
            out[u > 0.6] = hx(sp.wing_extra['tip'])
        if 'shoulder' in sp.wing_extra:
            out[(u < -0.45) & (v < 0.3)] = hx(sp.wing_extra['shoulder'])
        if 'dot' in sp.wing_extra and sp.wing_pattern != 'bars':
            out[(u > 0.2) & (u < 0.4) & (v > 0.1)] = hx(sp.wing_extra['dot'])
        return out

    shoulder = (body_c[0] + 4, body_c[1] - 5 * k)
    if pose.wing == 'fold':
        wing = Ellipse(body_c[0] + 4.5 * k, body_c[1] + 0.5, 12.5 * k, 6.2 * k, 38)
        parts.append((Part('wing', wing, wing_paint_folded, edge=True), 'body'))
    else:
        # open wing: ellipse rooted at the shoulder, rotated per state
        angle = {'high': -78, 'up': -62, 'mid': -40, 'back': -20}[pose.wing]
        length = {'high': 15, 'up': 14, 'mid': 13.5, 'back': 13}[pose.wing] * k
        width = 6.2 * k
        a = math.radians(angle)
        cx = shoulder[0] + math.cos(a) * length * 0.75
        cy = shoulder[1] + math.sin(a) * length * 0.75
        wing = Ellipse(cx, cy, length, width, angle)

        def open_paint(u, v, bx, by, _w=wing):
            # rotate local so that the trailing edge (behind) is v>0
            return wing_paint_open(u, -v if angle < -50 else v, bx, by)

        parts.append((Part('wing', wing, open_paint, edge=True), 'body'))

    # --- head ---
    hr = sp.head_r * (0.92 + 0.08 * k)
    head = Ellipse(head_c[0], head_c[1], hr, hr * 0.95, 0)

    # crest (drawn before head so the head overlaps its base)
    if sp.crest > 0:
        ch = 8 * sp.crest * pose.crest
        base_l = (head_c[0] - 4, head_c[1] - hr * 0.6)
        base_r = (head_c[0] + hr * 0.75, head_c[1] - hr * 0.2)
        tip = (head_c[0] + 2.5 + ch * 0.3, head_c[1] - hr - ch)
        crest = Poly([base_l, (head_c[0] - 2, head_c[1] - hr - ch * 0.35), tip, base_r])
        parts.append((Part('crest', crest, shade_ramp(sp.crest_color or sp.head, soft=True)), 'head'))

    def head_paint(u, v, bx, by):
        out = shade_ramp(sp.head)(u, v, bx, by)
        fc = sp.face_colors
        if sp.face == 'jay':
            dd = np.hypot(u + 0.15, v - 0.3)
            m = dd < 0.62
            out[m] = hx('#f2f5fb')
            out[m & (v > 0.6)] = hx('#c9d3e6')
            ring = (dd >= 0.62) & (dd < 0.78) & ((v > 0.0) | (u > 0.3))
            out[ring] = ol
            out[(np.abs(v + 0.12) < 0.1) & (u < -0.2)] = ol
        elif sp.face == 'mask':  # cardinal / waxwing
            m = (u < -0.05) & (np.abs(v - 0.05) < 0.32 + (-u) * 0.25)
            out[m] = hx(fc.get('mask', '#14090a'))
            if 'mask_edge' in fc:
                out[m & ~((u < -0.05) & (np.abs(v - 0.05) < 0.22 + (-u) * 0.25))] = hx(fc['mask_edge'])
        elif sp.face == 'band':  # waxwing: black band through the eye
            m = (np.abs(v + 0.2) < 0.2 - u * 0.05) & (u < 0.45)
            out[m] = hx(fc.get('mask', '#121010'))
            edge = (v + 0.2 >= 0.2 - u * 0.05) & (v + 0.2 < 0.36 - u * 0.05) & (u < 0.3) & (u > -0.6)
            out[edge] = hx(fc.get('mask_edge', '#f6f2ea'))
            out[(u < -0.55) & (v > 0.2)] = hx(fc.get('mask', '#121010'))
        elif sp.face == 'cap':  # chickadee
            out[v < 0.0] = hx(fc['cap'])
            cheek = (v >= 0.0) & (v < 0.45) & (u > -0.75)
            out[cheek] = hx(fc['cheek'])
            out[cheek & (v > 0.3)] = mix(hx(fc['cheek']), hx('#9aa0aa'), 0.4)
            out[(v >= 0.45) & (u < 0.3)] = hx(fc['cap'])
        elif sp.face == 'throat':  # hummingbird, finch, robin breast
            m = (v > 0.2) & (u < 0.45)
            out[m] = hx(fc['throat'])
            out[m & (v > 0.6)] = mix(hx(fc['throat']), hx('#000000'), 0.3)
            out[m & (u < -0.2) & (v < 0.5)] = mix(hx(fc['throat']), hx('#ffffff'), 0.3)
        elif sp.face == 'forehead':  # steller's jay streaks
            m = (u < -0.25) & (v < -0.25) & (v > -0.75) & ((np.floor(bx) % 3) == 0)
            out[m] = hx(fc['streak'])
        elif sp.face == 'thrush':
            m = (u < 0.3) & (v > 0.2) & ((np.round(bx) + np.round(by)) % 3 == 0)
            out[m] = hx(fc['streak'])
            out[(u < 0.2) & (v > 0.55)] = hx('#f4efe8')
        return out

    parts.append((Part('head', head, head_paint, edge=False), 'head'))

    # breast patch that continues from the head (robin, finch, cardinal...)
    if 'bib' in sp.face_colors:
        bib = Ellipse(head_c[0] + 1, head_c[1] + hr * 0.85, hr * 0.5, hr * 0.32, 0)
        parts.append((Part('bib', bib, flat(sp.face_colors['bib'])), 'head'))

    # beak
    bx0 = head_c[0] - hr + 1.5
    by0 = head_c[1] + 1.0
    upper = Strip((bx0 + 1.5, by0 - sp.beak_w * 0.25), (bx0 - sp.beak_len, by0 + 0.2),
                  sp.beak_w * 0.55, 1.0)
    lower = Strip((bx0 + 1.5, by0 + sp.beak_w * 0.3), (bx0 - sp.beak_len * 0.88, by0 + 0.6),
                  sp.beak_w * 0.5, 0.8)
    parts.append((Part('beak_lo', lower, flat(sp.beak[1])), 'head'))
    parts.append((Part('beak_up', upper, flat(sp.beak[0])), 'head'))

    # eye
    ex, ey = head_c[0] - hr * 0.32, head_c[1] - hr * 0.2
    if sp.eye_ring:
        parts.append((Part('ring', Ellipse(ex, ey, 2.3, 2.3), flat(sp.eye_ring)), 'head'))
    parts.append((Part('eye', Ellipse(ex, ey, 1.45, 1.6), flat(sp.eye)), 'head'))
    parts.append((Part('glint', Ellipse(ex - 0.6, ey - 0.6, 0.55, 0.55), flat('#ffffff')), 'head'))

    return parts, hip, head_c


def leg_parts(sp: Spec, pose: Pose, base_y: float):
    """Legs are vertical and not rotated with the body."""
    if pose.legs == 'none':
        return []
    c = sp.legs
    out = []
    ln = {'stand': 14, 'crouch': 11, 'tuck': 7}[pose.legs]
    for x in (26.5, 32.5):
        top = base_y
        bot = math.floor(top + ln) + 0.5
        out.append(Part('leg', Strip((x, top), (x, bot), 1.0, 1.0), flat(c)))
        if pose.legs != 'tuck':
            out.append(Part('foot', Strip((x - 2.0, bot), (x + 1.0, bot), 1.0, 1.0), flat(c)))
        else:
            out.append(Part('foot', Strip((x - 1.0, bot), (x + 0.0, bot), 1.0, 1.0), flat(c)))
    return out


# --------------------------------------------------------------- renderer --

def render_frame(sp: Spec, pose: Pose) -> Image.Image:
    ys, xs = np.mgrid[0:N, 0:N].astype(float) + 0.5
    rgb = np.zeros((N, N, 3))
    label = np.full((N, N), -1, int)
    edge_px = np.zeros((N, N), bool)

    parts, hip, head_c = build_parts(sp, pose)
    tilt = math.radians(pose.tilt)
    ct, st = math.cos(tilt), math.sin(tilt)

    def to_bird(group):
        # inverse of: rotate about hip by tilt, then translate by (dx, dy)
        X = xs - pose.dx
        Y = ys - pose.dy
        if group in ('body', 'head') and pose.tilt:
            px, py = X - hip[0], Y - hip[1]
            bx = px * ct + py * st + hip[0]
            by = -px * st + py * ct + hip[1]
            return bx, by
        return X, Y

    # legs first (body overlaps the top of the legs)
    leg_top = 44.0 + pose.squash * 0.5
    for i, p in enumerate(leg_parts(sp, pose, leg_top)):
        bx, by = to_bird('leg')
        m, u, v = p.shape.eval(bx, by)
        rgb[m] = p.paint(u, v, bx, by)[m]
        label[m] = 100 + i

    for i, (p, group) in enumerate(parts):
        bx, by = to_bird(group)
        m, u, v = p.shape.eval(bx, by)
        if not m.any():
            continue
        if p.edge:
            # pixels of this part that touch already-drawn pixels outside it
            below = (label >= 0) & ~m
            nb = np.zeros_like(m)
            nb[1:, :] |= below[:-1, :]
            nb[:-1, :] |= below[1:, :]
            nb[:, 1:] |= below[:, :-1]
            nb[:, :-1] |= below[:, 1:]
            edge_px &= ~m
            edge_px |= m & nb & (label >= 0)
        else:
            edge_px &= ~m
        rgb[m] = p.paint(u, v, bx, by)[m]
        label[m] = i

    ol = hx(sp.outline)
    rgb[edge_px] = mix(rgb[edge_px], ol, 0.85)

    alpha = label >= 0
    # outer outline (4-neighbourhood)
    grow = np.zeros_like(alpha)
    grow[1:, :] |= alpha[:-1, :]
    grow[:-1, :] |= alpha[1:, :]
    grow[:, 1:] |= alpha[:, :-1]
    grow[:, :-1] |= alpha[:, 1:]
    outline = grow & ~alpha
    rgb[outline] = ol
    alpha |= outline

    img = np.zeros((N, N, 4), np.uint8)
    img[..., :3] = np.clip(rgb, 0, 255).astype(np.uint8)
    img[..., 3] = np.where(alpha, 255, 0)
    return Image.fromarray(img, 'RGBA')


def render_sheet(sp: Spec) -> Image.Image:
    sheet = Image.new('RGBA', (FRAME * 4, FRAME * 4), (0, 0, 0, 0))
    for r, row in enumerate(POSES):
        for c, pose in enumerate(row):
            sheet.paste(render_frame(sp, pose), (c * FRAME, r * FRAME))
    return sheet


# ------------------------------------------------------------ the species --

def species() -> dict[str, Spec]:
    S = {}
    S['blue_jay'] = Spec(
        'blue_jay', outline='#0f1a33',
        body=ramp('#3f7fe0', '#2556b8', '#6aa2f0', '#a9cdfa'),
        belly=ramp('#e6ecf6', '#b9c6dd', '#f4f7fc', '#ffffff'),
        wing=ramp('#3d78db', '#1f4aa6', '#6fa6f2', '#b3d4ff'),
        tail=ramp('#3a74d6', '#1f4aa6', '#6aa2f0'),
        head=ramp('#3f7fe0', '#2556b8', '#6aa2f0', '#a9cdfa'),
        beak=('#1b2235', '#0f1424'), crest=1.0, face='jay',
        tail_pattern='bars', wing_pattern='bars', legs='#39405a')
    S['cardinal'] = Spec(
        'cardinal', outline='#2a0606',
        body=ramp('#d42a12', '#9a1608', '#ec4a2a', '#ff8a66'),
        belly=ramp('#e0361a', '#a81c0a', '#f25a36', '#ff9670'),
        wing=ramp('#b81e0c', '#7c1006', '#d8361c', '#f0623e'),
        tail=ramp('#b01c0c', '#741006', '#d0341a'),
        head=ramp('#e0321a', '#a01a0a', '#f45a38', '#ff9a78'),
        beak=('#ff7a3a', '#e05a20'), beak_len=7, beak_w=6.5,
        crest=1.0, face='mask', face_colors={'mask': '#1a0806'},
        legs='#6a5a5a', tail_len=1.05)
    S['cedar_waxwing'] = Spec(
        'cedar_waxwing', outline='#241a14',
        body=ramp('#9a8a7e', '#6e6058', '#b6a89c', '#d2c6ba'),
        belly=ramp('#f2d25a', '#cfa83a', '#fae28a', '#fff2b8'),
        wing=ramp('#7e7670', '#55504c', '#9c948c', '#bcb4ac'),
        tail=ramp('#6e6a66', '#4c4846', '#8c8682'),
        head=ramp('#c4926e', '#986a4c', '#dab092', '#eccab0'),
        crest_color=ramp('#c4926e', '#986a4c', '#dab092', '#eccab0'),
        beak=('#1e1a1a', '#0e0c0c'), beak_len=6, beak_w=4.2,
        crest=0.7, face='band', face_colors={'mask': '#121010', 'mask_edge': '#f6f2ea',
                                             'breast': '#c9a684'},
        tail_tip='#f4cc30', wing_extra={'dot': '#d42a1a'}, legs='#2e2a2a')
    S['chickadee'] = Spec(
        'chickadee', outline='#141418',
        body=ramp('#8e9298', '#666a72', '#aeb2b8', '#cdd0d4'),
        belly=ramp('#f4f2ec', '#d6c8a8', '#ffffff', '#ffffff'),
        wing=ramp('#7a7e86', '#52565e', '#9a9ea6', '#c4c8ce'),
        tail=ramp('#6e727a', '#4c5058', '#8e929a'),
        head=ramp('#1e1e24', '#0e0e12', '#34343c', '#4a4a54'),
        beak=('#2a2a30', '#141418'), beak_len=5, beak_w=3.6,
        face='cap', face_colors={'cap': '#17171c', 'cheek': '#fbfbfb', 'breast': '#f2ecdc', 'bib': '#17171c'},
        wing_extra={'tip': '#c8ccd2'}, legs='#3a3e4a', size=0.94, tail_len=0.9, head_r=10)
    S['crow'] = Spec(
        'crow', outline='#06060a',
        body=ramp('#2a2c36', '#16171e', '#3e4256', '#5c6380'),
        belly=ramp('#24262e', '#14151a', '#343848', '#4a5068'),
        wing=ramp('#262833', '#121319', '#3a3f55', '#5a6488'),
        tail=ramp('#22242e', '#101116', '#363a4c'),
        head=ramp('#2c2e38', '#17181f', '#424660', '#626a8a'),
        beak=('#24252c', '#121318'), beak_len=10, beak_w=6,
        eye='#000000', legs='#202228', tail_len=1.15, size=1.04)
    S['house_finch'] = Spec(
        'house_finch', outline='#24180c',
        body=ramp('#8a6a44', '#5c4428', '#a8865c', '#c4a47a'),
        belly=ramp('#ece0cc', '#c4b098', '#f8f0e2', '#ffffff'),
        wing=ramp('#7a5c38', '#4e3a22', '#9a7a52', '#c0a07a'),
        tail=ramp('#6e5232', '#463420', '#8c6c46'),
        head=ramp('#d84a48', '#a8302e', '#ec6a66', '#f89a94'),
        beak=('#b4a8a0', '#8c8078'), beak_len=6, beak_w=5.5,
        face='none', face_colors={'breast': '#d8504c'},
        belly_pattern='streaks', pattern_color='#8a6a48',
        wing_extra={'tip': '#e8dccb'}, legs='#9a8486', size=0.95)
    S['hummingbird'] = Spec(
        'hummingbird', outline='#0a1a06',
        body=ramp('#3a9a1e', '#22680e', '#5cc23a', '#9ae670'),
        belly=ramp('#e8f2e4', '#b4ccae', '#f6fbf4', '#ffffff'),
        wing=ramp('#7a8a6e', '#56624c', '#a4b298', '#d0dcc6'),
        tail=ramp('#2e7a16', '#1a520a', '#4aa028'),
        head=ramp('#3aa020', '#22680e', '#62c840', '#a0ec78'),
        beak=('#1a1a1a', '#0c0c0c'), beak_len=12, beak_w=2.6,
        face='throat', face_colors={'throat': '#c41a36'},
        tail_len=0.75, tail_w=6, size=0.86, head_r=8.5, legs='#2a2a2a')
    S['magpie'] = Spec(
        'magpie', outline='#060810',
        body=ramp('#1e2228', '#0e1014', '#343a44', '#4c5462'),
        belly=ramp('#f4f6f8', '#c8ced6', '#ffffff', '#ffffff'),
        wing=ramp('#1c58b0', '#0e3470', '#2e78d0', '#6aa4ea'),
        tail=ramp('#1a3e7a', '#0c2448', '#2a5aa4'),
        head=ramp('#20242a', '#0e1014', '#363c46', '#525a68'),
        beak=('#202228', '#0e1014'), beak_len=8, beak_w=4.6,
        wing_extra={'shoulder': '#f4f6f8', 'tip': '#14161c'},
        tail_len=1.1, tail_w=6.5, legs='#20242c')
    S['red_robin'] = Spec(
        'red_robin', outline='#16120e',
        body=ramp('#5a5450', '#3a3632', '#7a726c', '#9a928a'),
        belly=ramp('#f2eeea', '#c8c0b8', '#ffffff', '#ffffff'),
        wing=ramp('#4e4844', '#302c2a', '#6c645e', '#8e867e'),
        tail=ramp('#3e3a36', '#26221f', '#5a5450'),
        head=ramp('#2e2a28', '#1a1816', '#46413e', '#625c58'),
        beak=('#f0c22a', '#c89a14'), beak_len=7, beak_w=4.6,
        eye_ring='#f4f0e8', face_colors={'breast': '#d4542a', 'cover': 0.75},
        legs='#5a4e46')
    S['stellers_jay'] = Spec(
        'stellers_jay', outline='#050b1c',
        body=ramp('#1e4fa0', '#0e2e6a', '#3474c4', '#6aa0e0'),
        belly=ramp('#2a5cae', '#163a7a', '#4282cc', '#78aee6'),
        wing=ramp('#1c4c9c', '#0c2a62', '#3070c0', '#64a0e4'),
        tail=ramp('#1a4894', '#0c2a62', '#2e6cbc'),
        head=ramp('#1c2840', '#0e1626', '#2e3e60', '#46587e'),
        crest_color=ramp('#1c2840', '#0e1626', '#2e3e60', '#46587e'),
        beak=('#141a26', '#0a0e16'), crest=1.15, face='forehead',
        face_colors={'streak': '#6aa8f0'},
        tail_pattern='bars', wing_pattern='bars', tail_tip='#1a4894', legs='#202838')
    S['white_dove'] = Spec(
        'white_dove', outline='#4a4a58',
        body=ramp('#eceef2', '#bcc0cc', '#f8f9fb', '#ffffff'),
        belly=ramp('#f4f5f8', '#c8ccd6', '#ffffff', '#ffffff'),
        wing=ramp('#e2e4ea', '#a8adba', '#f4f5f8', '#ffffff'),
        tail=ramp('#dcdee6', '#a8adba', '#f0f2f6'),
        head=ramp('#f0f2f6', '#c0c4ce', '#ffffff', '#ffffff'),
        beak=('#f2a09a', '#d07a72'), beak_len=6, beak_w=3.8,
        eye='#5a1e1a', eye_ring='#e6b0aa', legs='#f08a84', size=1.04, head_r=8.5,
        tail_len=0.95)
    S['wood_thrush'] = Spec(
        'wood_thrush', outline='#24140a',
        body=ramp('#c47a3a', '#8e5222', '#dc9a58', '#f0bc80'),
        belly=ramp('#f6f2ec', '#d0c8bc', '#ffffff', '#ffffff'),
        wing=ramp('#a86830', '#74441a', '#c88648', '#e4a86c'),
        tail=ramp('#9a6030', '#6a3e1a', '#b87a44'),
        head=ramp('#cc7e3a', '#94541e', '#e2a05c', '#f4c288'),
        beak=('#5a4a44', '#3a2e2a'), beak_len=7, beak_w=4,
        eye_ring='#f6f0e6', face='thrush', face_colors={'streak': '#4a2e1e'},
        belly_pattern='spots', pattern_color='#3a2418', legs='#e08a96')
    return S


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('names', nargs='*')
    ap.add_argument('--out', default='assets/images/pets_final')
    ap.add_argument('--preview', default=None, help='write a zoomed contact sheet here')
    a = ap.parse_args()
    specs = species()
    names = a.names or [n for n in specs if n != 'blue_jay']
    os.makedirs(a.out, exist_ok=True)
    sheets = []
    for n in names:
        sh = render_sheet(specs[n])
        sh.save(os.path.join(a.out, f'{n}.png'))
        sheets.append(sh)
        print('wrote', n)
    if a.preview:
        cols = min(4, len(sheets))
        rows = math.ceil(len(sheets) / cols)
        pv = Image.new('RGBA', (cols * 260, rows * 260), (196, 204, 196, 255))
        for i, sh in enumerate(sheets):
            pv.alpha_composite(sh, ((i % cols) * 260 + 2, (i // cols) * 260 + 2))
        pv = pv.resize((pv.width * 2, pv.height * 2), Image.NEAREST)
        pv.save(a.preview)


if __name__ == '__main__':
    main()
