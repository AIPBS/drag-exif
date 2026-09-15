#!/usr/bin/env python3

# Source icon name follows the versioned asset convention.
# ----------------------------

icon_name = "app_icon_v1.1.0.png"

# ----------------------------

import os
import struct
import sys

import gi
gi.require_version('Rsvg', '2.0')
gi.require_version('GdkPixbuf', '2.0')
from gi.repository import Rsvg, GdkPixbuf


BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE = os.path.join(BASE, 'assets', icon_name)
WIN_DIR = os.path.join(BASE, 'windows', 'runner', 'resources')
LIN_DIR = os.path.join(BASE, 'linux', 'runner', 'icons')
MAC_DIR = os.path.join(BASE, 'macos', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
SIZES = [16, 32, 48, 64, 128, 256, 512]


def render(source_path, out_path, size):
    if source_path.lower().endswith('.svg'):
        handle = Rsvg.Handle.new_from_file(source_path)
        pixbuf = handle.get_pixbuf()
    else:
        pixbuf = GdkPixbuf.Pixbuf.new_from_file(source_path)
    scaled = pixbuf.scale_simple(size, size, GdkPixbuf.InterpType.BILINEAR)
    scaled.savev(out_path, 'png', [], [])
    print(f"  {size}x{size} -> {out_path}")


def make_ico(png_paths, out_path):
    images = [open(p, 'rb').read() for p in png_paths]
    n = len(images)
    header = struct.pack('<HHH', 0, 1, n)
    entries = b''
    offset = 6 + 16 * n
    for i, data in enumerate(images):
        s = SIZES[i]
        w, h = (s if s < 256 else 0), (s if s < 256 else 0)
        entries += struct.pack('<BBBBHHII', w, h, 0, 0, 1, 32, len(data), offset)
        offset += len(data)
    with open(out_path, 'wb') as f:
        f.write(header + entries + b''.join(images))
    print(f"  ICO -> {out_path}")


def main():
    if not os.path.exists(SOURCE):
        print(f"Icon source not found: {SOURCE}")
        sys.exit(1)

    print("Generating icons...")
    os.makedirs(WIN_DIR, exist_ok=True)
    os.makedirs(LIN_DIR, exist_ok=True)
    os.makedirs(MAC_DIR, exist_ok=True)

    pngs = []
    for size in SIZES:
        p = os.path.join(WIN_DIR, f'app_icon_{size}.png')
        render(SOURCE, p, size)
        pngs.append(p)

    make_ico(pngs, os.path.join(WIN_DIR, 'app_icon.ico'))

    for size in SIZES:
        src = os.path.join(WIN_DIR, f'app_icon_{size}.png')
        dst = os.path.join(LIN_DIR, f'app_icon_{size}.png')
        with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
            fdst.write(fsrc.read())
        print(f"  Copied {size}x{size} to linux/")

    with open(os.path.join(WIN_DIR, 'app_icon_256.png'), 'rb') as fsrc, \
         open(os.path.join(LIN_DIR, 'app_icon.png'), 'wb') as fdst:
        fdst.write(fsrc.read())
    print(f"  app_icon.png -> linux/")

    # macOS icons
    mac_sizes = [16, 32, 64, 128, 256, 512, 1024]
    for size in mac_sizes:
        src = os.path.join(WIN_DIR, f'app_icon_{size}.png') if size in SIZES else None
        dst = os.path.join(MAC_DIR, f'app_icon_{size}.png')
        if src and os.path.exists(src):
            with open(src, 'rb') as fsrc, open(dst, 'wb') as fdst:
                fdst.write(fsrc.read())
        else:
            render(SOURCE, dst, size)
        print(f"  {size}x{size} -> macos/")

    print("Done.")


if __name__ == '__main__':
    main()
