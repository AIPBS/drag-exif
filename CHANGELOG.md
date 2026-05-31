# Changelog

All notable changes to this project are documented in this file.

## 0.1.2 - 06-01-2026

### Changed
- Redesigned app icon (v0.1.2): removed background photo imagery and made "EXIF" text significantly larger and bolder for better identifiability at all sizes.
- Increased status and action icon sizes across the UI (16 px → 20 px).
- Increased EXIF table font sizes for improved readability.

### Fixed
- Windows window-close crash: replaced `windowManager.destroy()` with a safer `setPreventClose(false)` + `close()` sequence protected by an `_isClosing` guard.
- Inline editing text jumping: the edit-mode `TextField` now shares the same base `TextStyle` as the read-only text, eliminating the pop-up layout shift.
- Slow image preview on Windows: `Image.file` now decodes with `cacheHeight` capped to ~1.5× the display size, drastically reducing load time for large photos.
- Unicode tag editing on Windows: tag values are now written via a UTF-8 encoded ExifTool argfile (`-@ file`) instead of direct command-line arguments, preventing character mangling.

## 0.1.1 - 05-27-2026

### Added
- The Icon v0.1.1

### Fixed
- Windows version not showing EXIF lines

## 0.1.0 - 05-26-2026

### Added

- View EXIF, IPTC, XMP, and GPS metadata from image files via ExifTool.
- Drag and drop files onto the window to load them.
- File list panel with multi-select support (Ctrl and Shift click).
- Metadata table with columns for group, tag ID, tag name, and value.
- Inline editing of tag values. Read-only groups (File, ICC_Profile) are protected.
- Delete tags with a click; deletions are applied on save.
- Add new tags via a searchable catalog of known EXIF tags, or enter custom tag names.
- Undo support for edits and deletions (Ctrl+Z).
- Save changes to files (Ctrl+S).
- Unsaved changes warning dialog when closing the window.
- Rename files by double-clicking the filename in the left panel.
- Export metadata to text, CSV, or JSON.
- Copy metadata to clipboard as tab-delimited text.
- XMP subgroup normalization: all XMP-* groups display as "XMP".
- Tooltips on tag values; double-click long values to open a dialog with a Copy button.
- Draggable sidebar divider to resize the file list panel.
- Settings dialog for theme selection, always-on-top window, ExifTool path, and custom ExifTool arguments.
- About dialog showing version, credits, and license information.
