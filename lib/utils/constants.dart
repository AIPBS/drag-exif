/*
DragExif - EXIF metadata viewer
Based on ExifGlass by Dương Diệu Pháp
Copyright (C) 2023-2025 DUONG DIEU PHAP
Project homepage: https://github.com/d2phap/ExifGlass
Copyright (C) 2026 Allen
Project homepage: https://github.com/AIPEAC/drag-exif


This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/
class Constants {
  static const String defaultCommands = '-fast -G -t -m -q -H';
  static const String appName = 'DragExif';
  static const String configFileName = 'config.json';
  static const String updateUrl =
      'https://raw.githubusercontent.com/d2phap/ExifGlass/main/update.json';

  // License / Attribution
  static const String originalProjectName = 'ExifGlass';
  static const String originalProjectUrl = 'https://github.com/d2phap/ExifGlass';
  static const String originalAuthor = 'Dương Diệu Pháp';
  static const String originalCopyright = 'Copyright © 2023-2025, Dương Diệu Pháp';
  static const String originalLicense = 'GNU General Public License v3.0 (GPLv3)';
  static const String thisProjectLicense = 'GNU General Public License v3.0 (GPLv3)';

  // ── Read-only EXIF groups / tags ──
  static const Set<String> readOnlyGroups = {
    'File',
    'ICC_Profile',
    'Composite',
    'PNG',
    'JFIF',
    'GIF',
    'BMP',
    'RIFF',
  };

  static const Set<String> readOnlyTagNames = {
    'ImageSize',
    'Megapixels',
    'FileType',
    'FileTypeExtension',
    'MIMEType',
    'BitDepth',
    'ColorType',
    'Compression',
    'Filter',
    'ImageHeight',
    'ImageWidth',
    'Interlace',
  };

  static bool isReadOnlyExifTag(String group, String tagName) =>
      readOnlyGroups.contains(group) || readOnlyTagNames.contains(tagName);

  // ── Image format support ──
  static const List<String> supportedImageExtensions = [
    // Common raster
    'jpg', 'jpeg', 'png', 'tiff', 'tif', 'gif', 'bmp', 'webp', 'ico',
    'heic', 'heif', 'avif', 'jxl',
    // RAW — Canon
    'cr2', 'cr3', 'crw',
    // RAW — Nikon
    'nef', 'nrw',
    // RAW — Sony
    'arw', 'srf', 'sr2',
    // RAW — Adobe / generic
    'dng', 'raw',
    // RAW — Olympus
    'orf',
    // RAW — Panasonic / Leica
    'rw2', 'rwl',
    // RAW — Fujifilm
    'raf',
    // RAW — Pentax
    'pef', 'ptx',
    // RAW — Sigma
    'x3f',
    // RAW — Minolta / Konica
    'mrw',
    // RAW — Kodak
    'kdc', 'k25', 'dcr',
    // RAW — Mamiya
    'mos',
    // RAW — Phase One
    'iiq',
    // RAW — Hasselblad
    '3fr',
    // RAW — Epson
    'erf',
    // RAW — Mamiya / Leaf
    'mef',
    // RAW — Samsung
    'srw',
    // RAW — Other
    'bay', 'cap', 'cin', 'cs1', 'drf', 'fff', 'iq', 'mdc', 'obm', 'qtk',
    // Photoshop / layered
    'psd', 'psb',
    // JPEG 2000
    'jp2', 'j2k', 'jpf', 'jpx', 'jpm', 'mj2',
    // Other common formats
    'tga', 'pcx', 'pnm', 'pbm', 'pgm', 'ppm', 'pfm', 'xbm', 'xpm', 'wbmp',
    // HDR / EXR
    'exr', 'hdr', 'pic',
    // SVG (rarely has EXIF, but possible)
    'svg', 'svgz',
  ];

  /// Formats that Flutter's [Image.file] can actually decode for preview.
  static const List<String> previewableImageExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp',
    'tiff', 'tif', 'ico', 'wbmp', 'heic', 'heif',
  ];

  /// Images larger than this will not be auto-previewed (user must click).
  static const int maxAutoPreviewSizeBytes = 10 * 1024 * 1024; // 10 MB

  static bool isSupportedImage(String path) {
    final ext = path.toLowerCase().split('.').lastOrNull;
    return ext != null && supportedImageExtensions.contains(ext);
  }

  static bool isPreviewableImage(String path) {
    final ext = path.toLowerCase().split('.').lastOrNull;
    return ext != null && previewableImageExtensions.contains(ext);
  }

  /// Toggle to disable image preview for performance testing.
  static const bool kEnableImagePreview = true;
}
