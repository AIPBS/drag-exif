#!/bin/sh
set -eu

extra_root="${EXTRA_ROOT:-/app/extra}"
cd "$extra_root"

[ -f dragexif-linux_standalone.tar.gz ] || {
  echo 'missing extra-data: dragexif-linux_standalone.tar.gz' >&2
  exit 1
}

rm -rf bundle
tar --no-same-owner -xzf dragexif-linux_standalone.tar.gz
[ -x bundle/'Drag Exif' ] || {
  echo 'Drag Exif binary not found in standalone bundle' >&2
  exit 1
}
[ -x bundle/exiftool/exiftool ] || {
  echo 'bundled ExifTool not found in standalone bundle' >&2
  exit 1
}

rm -f dragexif-linux_standalone.tar.gz
