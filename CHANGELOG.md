# Changelog

All notable changes to this project are documented in this file.

## 1.2.0 - 09-18-2026

### Changed
- Updated the app and Microsoft Store branding to the new v1.2.0 SVG icons.

## 1.1.3 - 09-15-2026

### Fixed
- Windows Store packaging now declares the renamed `Drag Exif.exe` executable
  in the MSIX manifest.

## 1.1.1 - 09-15-2026

### Added
- Renamed the user-facing executable to `Drag Exif` on Windows and Linux.

### Changed
- Updated the Windows and Linux executable metadata to `Drag Exif`.

## 1.1.0 - 09-15-2026

### Added
- Theme-aware app branding in Settings using separate dark and light icons.
- About is now available from Settings.

### Changed
- Updated the new icons.
- New installations default to the dark theme.
- Removed the footer menu and separate Exit action; close the app with the
  window close button.

## 1.0.3 - 09-15-2026

### Fixed
- Windows Ctrl+S now reaches the save handler while an inline metadata field
  has focus.

## 1.0.2+3 - 09-15-2026

### Changed
- Reduced CI build time by reusing the ExifTool archive and avoiding a second
  Windows compilation during MSIX packaging.

## 1.0.2+2 - 09-15-2026

### Fixed
- Windows Store builds now bundle ExifTool and its required support files.
- Store MSIX builds now use the configured Partner Center publisher identity.

## 1.0.2 - 06-03-2026

### Changed
- **Settings exposed in bottom navigation bar** — Settings is no longer hidden in a popup menu. It's now a dedicated tab (rightmost) in a `NavigationBar` + `IndexedStack`, as required by project conventions.
- **Settings converted from dialog to full page** — all changes apply immediately without needing OK/Cancel. Theme and locale dropdowns now trigger instant app rebuilds.

### Fixed
- **Theme/locale changes now apply immediately** — the setters were updating `_settings` on dropdown change BEFORE `_save()` ran, so the `oldLocale != _selectedLocale` check was always false and `localeNotifier` was never updated. Added `themeModeNotifier` for theme reactivity. Both notifiers are now seeded from saved preferences on startup and triggered on every change.

## 1.0.1 - 06-03-2026

### Fixed
- **Linux window not appearing** — `runApp()` was called after `await windowManager.waitUntilReadyToShow()`, preventing the native GTK `first_frame_cb` from firing and showing the window. Moved `runApp()` before `waitUntilReadyToShow()` and removed the `await`.
- **`initState` localization error** — `_initWindow()` used `AppLocalizations.of(context)` before `initState()` completed. Deferred to a post-frame callback via `addPostFrameCallback`.
- Removed `Colors.transparent` window background on Linux to avoid GTK CSS transparency issues with certain window managers.

## 1.0.0 - 05-26-2026

### Added
- **Bilingual UI** — full English and Chinese (中文) localization via `flutter_localizations`.
  - Language can be switched in Settings or follows the system default.
  - All UI strings, dialogs, tooltips, and error messages are localized.
  - Chinese README added.

## 0.1.3 - 06-02-2026

### Added
- Format-specific read-only tag definitions: PNG, JFIF, GIF, BMP, TIFF, RIFF, WebP, HEIC/HEIF.
- `const Set<String>` lookup for read-only tags: O(1) `Set.contains()` replaces O(n) `List.contains()`.
- `_isSwitchingFile` perceived-performance guard: clicking a file now updates the highlight instantly while the heavy EXIF table rebuilds in a deferred frame.
- `_rebuildGeneration` stale-guard: rapid successive clicks discard obsolete deferred rebuilds.
- Memoized `_displayItems`: cached field prevents `EditableExifDataTable` from rebuilding on every frame.

### Changed
- Image preview completely rewritten:
  - Fixed `SizedBox` bounds (220 px) — no more layout jumps between placeholder and image.
  - Removed big icon placeholder flash during file evaluation.
  - `Image.file` with `frameBuilder` + `AnimatedOpacity` fade-in (200 ms).
  - Subtle 24 px spinner while decoding instead of a 48 px icon.
  - Background file-size check only affects `cacheHeight`, never blocks the visual.
- DataTable2: fixed `dataRowHeight` (48 px) and `headingRowHeight` (56 px) to skip intrinsic measurement; cached columns and row colors.
- Edit field alignment: `Align` + `Transform.translate(Offset(0, -1))` eliminates vertical offset pop.
- Active edit field styling: theme primary color + bold weight.
- Read-only fields: `SystemMouseCursors.forbidden` + hover tooltip "Cannot be edited".
- Add-tag dialog: blocks read-only tags with a SnackBar warning.
- Drag-and-drop: filters out non-image files before loading.
- Open-file dialog: restricted to image extensions.
- Frame timing: `WidgetsBinding.instance.addTimingsCallback` replaces inaccurate `Stopwatch` measurement.
- `main_screen.dart` build refactor: extracted `_buildBody()` to flatten nested widget tree.

### Fixed
- `Ctrl+S` shortcut: `Shortcuts`/`Actions`/`Focus` pattern properly finishes in-flight table edits before saving.

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
