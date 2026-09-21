#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  printf 'usage: %s EXIFTOOL_ARCHIVE OUTPUT_ARCHIVE\n' "$0" >&2
  exit 2
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
archive="$1"
output="$2"
build_bundle="$root/build/linux/x64/release/bundle"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

source_root="$work/exiftool-source"
standalone_root="$work/standalone"
mkdir -p "$source_root" "$standalone_root"
tar -xzf "$archive" -C "$source_root" --strip-components=1

test -x "$source_root/exiftool"
test -d "$source_root/lib/Image/ExifTool"
test -d "$build_bundle"

cp -a "$build_bundle" "$standalone_root/bundle"
exiftool_root="$standalone_root/bundle/exiftool"
perl_root="$exiftool_root/perl-root"
mkdir -p "$exiftool_root/native-libs" "$perl_root"

cp "$source_root/exiftool" "$exiftool_root/exiftool-bin"
cp -a "$source_root/lib" "$exiftool_root/"
for documentation in "$source_root"/LICENSE* "$source_root"/README*; do
  [ -e "$documentation" ] || continue
  cp -a "$documentation" "$exiftool_root/"
done

perl_bin="$(command -v perl)"
cp "$perl_bin" "$exiftool_root/perl"
mapfile -t perl_dirs < <(
  perl -MConfig -e \
    'print join("\n", grep { $_ && -d $_ } @Config{qw(archlib privlib vendorlib sitearch sitelib)})'
)
perl5lib=""
for source_dir in "${perl_dirs[@]}"; do
  relative_dir="${source_dir#/}"
  destination="$perl_root/$relative_dir"
  mkdir -p "$(dirname "$destination")"
  cp -aL "$source_dir" "$destination"
  perl5lib="$perl5lib\$dir/perl-root/$relative_dir:"
done

while read -r library; do
  case "$library" in
    ''|linux-vdso*|*/libc.so*|*/libm.so*|*/libpthread.so*|*/libdl.so*|*/ld-linux*)
      continue
      ;;
  esac
  cp -L "$library" "$exiftool_root/native-libs/"
done < <(
  ldd "$perl_bin" \
    | sed -n -E 's/.*=> (\/[^ ]+) .*/\1/p; s/^(\/[^ ]+) \(.*/\1/p' \
    | sort -u
)

cat > "$exiftool_root/exiftool" <<EOF
#!/bin/sh
set -eu
dir=\$(CDPATH= cd -- "\$(dirname -- "\$0")" && pwd)
export PERL5LIB="$perl5lib"
export LD_LIBRARY_PATH="\$dir/native-libs\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$dir/perl" "\$dir/exiftool-bin" "\$@"
EOF
chmod +x "$exiftool_root/exiftool" "$exiftool_root/perl" "$exiftool_root/exiftool-bin"

"$exiftool_root/exiftool" -ver | grep -Fx '13.59'
mkdir -p "$(dirname "$output")"
tar -czf "$output" -C "$standalone_root" bundle/

python3 - "$output" <<'PY'
import sys
import tarfile

archive_path = sys.argv[1]
with tarfile.open(archive_path, 'r:gz') as archive:
    for member in archive.getmembers():
        if member.issym() or member.islnk():
            raise SystemExit(f'archive contains a symlink: {member.name}')
        if member.name.startswith('/') or '/..' in member.name:
            raise SystemExit(f'archive contains an unsafe path: {member.name}')
PY
