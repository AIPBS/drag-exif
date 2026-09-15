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
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../generated/app_localizations.dart';
import '../models/exif_tag_item.dart';
import '../models/loaded_file.dart';
import '../services/exif_tool_service.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/platform_helper.dart';
import '../widgets/editable_exif_data_table.dart';
import '../widgets/error_display.dart';
import '../widgets/export_menu.dart';
import '../widgets/file_list_panel.dart';
import '../widgets/add_tag_dialog.dart';
import '../widgets/unsaved_changes_dialog.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _UndoEntry {
  final String key;
  final String? previousValue;
  final bool wasNewTag;
  _UndoEntry({required this.key, this.previousValue, this.wasNewTag = false});
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class _MainScreenState extends State<MainScreen> with WindowListener {
  final _exifTool = ExifToolService();
  final _settings = SettingsService();

  /// 0 = Home, 1 = Settings (rightmost as required by project conventions).
  int _currentTab = 0;

  // All loaded files
  final List<LoadedFile> _allFiles = [];

  // Selection state
  final Set<int> _selectedIndices = {};
  int? _lastClickedIndex;

  // Merged EXIF view for selected files
  Map<String, List<MergedTagItem>> _mergedItems = {};

  // Newly added tags that don't exist in any selected file yet
  final Map<String, List<MergedTagItem>> _newTags = {};

  // Pending edits: key = "tagGroup|tagId|tagName" -> {tagId, tagName, tagGroup, value}
  final Map<String, Map<String, String>> _pendingEdits = {};

  // Undo stack for tag modifications
  final List<_UndoEntry> _undoStack = [];

  String _error = '';
  String _errorDetails = '';
  bool _isLoading = false;
  bool _dragging = false;
  double _leftPanelWidth = 260;

  // ── Perceived-performance: file-switching guard ──
  // When true the right panel shows a lightweight spinner instead of the
  // heavy EditableExifDataTable. This keeps the frame that updates the
  // file-list highlight fast (<16 ms) so the highlight feels instant.
  bool _isSwitchingFile = false;
  int _rebuildGeneration = 0;

  final _tableKey = GlobalKey<EditableExifDataTableState>();

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    if (Platform.isWindows) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }
    // Defer window config to after the first frame — _initWindow uses
    // AppLocalizations.of(context) which requires the widget tree to be built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initWindow());
    _checkExifToolOnStartup();
    if (kDebugMode) {
      WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    }
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final buildMs = timing.buildDuration.inMilliseconds;
      final rasterMs = timing.rasterDuration.inMilliseconds;
      if (buildMs > 16 || rasterMs > 16) {
        log('Slow frame — build: ${buildMs}ms, raster: ${rasterMs}ms',
            name: 'dragexif.perf');
      }
    }
  }

  Future<void> _checkExifToolOnStartup() async {
    final found = await ExifToolService.checkExifToolExists(_settings.exifToolExecutable);
    if (found == null && mounted) {
      setState(() {
        _error = PlatformHelper.installInstructions;
      });
    }
  }

  Future<void> _initWindow() async {
    await windowManager.setTitle(AppLocalizations.of(context)?.windowTitle ?? Constants.appName);
    await windowManager.setMinimumSize(const Size(700, 500));
    await windowManager.setPreventClose(true);
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    windowManager.removeListener(this);
    _exifTool.dispose();
    super.dispose();
  }

  
  Future<void> _handleSave() async {
    if (kDebugMode) {
      log('User pressed Ctrl+S', name: 'dragexif.user');
    }
    // If the user is mid-edit in the table, finish that edit first
    _tableKey.currentState?.finishEditing();
    if (_pendingEdits.isNotEmpty) {
      if (kDebugMode) {
        log('Saving ${_pendingEdits.length} pending edits...', name: 'dragexif.user');
      }
      await _saveChanges();
    } else {
      if (kDebugMode) {
        log('Ctrl+S: no pending edits to save', name: 'dragexif.user');
      }
    }
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (!Platform.isWindows || event is! KeyDownEvent) return false;

    if (event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isControlPressed) {
      unawaited(_handleSave());
      return true;
    }

    return false;
  }

  MergedTagItem? _findMergedTagItem(String key) {
    final parts = key.split('|');
    final group = parts[0];
    final tagName = parts.length > 2 ? parts[2] : parts[1];

    for (final item in _mergedItems[group] ?? []) {
      if (item.tagName == tagName) return item;
    }
    for (final item in _newTags[group] ?? []) {
      if (item.tagName == tagName) return item;
    }
    return null;
  }

  void _undo() {
    if (_undoStack.isEmpty) return;

    final entry = _undoStack.removeLast();
    final item = _findMergedTagItem(entry.key);

    setState(() {
      final prev = entry.previousValue;
      if (prev != null) {
        // Restore previous pending value
        _pendingEdits[entry.key]?['value'] = prev;
        item?.pendingValue = prev;
      } else {
        // No previous value: remove the edit entirely
        _pendingEdits.remove(entry.key);
        item?.pendingValue = null;

        if (entry.wasNewTag) {
          // Remove newly-added tag from _newTags
          final parts = entry.key.split('|');
          final group = parts[0];
          final tagName = parts.length > 2 ? parts[2] : parts[1];
          _newTags[group]?.removeWhere((t) => t.tagName == tagName);
          if (_newTags[group]?.isEmpty == true) {
            _newTags.remove(group);
          }
        }
      }
    });

  }

  @override
  void onWindowResize() => _saveWindowState();

  @override
  void onWindowMove() => _saveWindowState();

  bool _isClosing = false;

  @override
  void onWindowClose() async {
    if (_isClosing) return;
    _isClosing = true;
    final canClose = await _handleUnsavedChangesBeforeAction();
    if (canClose) {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    } else {
      _isClosing = false;
    }
  }

  Future<void> _saveWindowState() async {
    final bounds = await windowManager.getBounds();
    final isMaximized = await windowManager.isMaximized();
    _settings.windowPositionX = bounds.left.toInt();
    _settings.windowPositionY = bounds.top.toInt();
    _settings.windowWidth = bounds.width.toInt();
    _settings.windowHeight = bounds.height.toInt();
    _settings.isMaximized = isMaximized;
    await _settings.save();
  }

  // ──────────────────────────────────────────────────────────
  // Selection
  // ──────────────────────────────────────────────────────────

  Future<void> _onSelectFile(int index, {bool ctrl = false, bool shift = false}) async {
    if (kDebugMode) {
      log('User clicked file: ${_allFiles[index].fileName} (#$index)', name: 'dragexif.user');
    }
    if (_pendingEdits.isNotEmpty) {
      final action = await UnsavedChangesDialog.show(
        context,
        changeCount: _pendingEdits.length,
      );
      switch (action) {
        case UnsavedAction.cancel:
          return;
        case UnsavedAction.discard:
          _discardEditsInternal();
          break;
        case UnsavedAction.save:
          await _saveChangesInternal();
          if (_pendingEdits.isNotEmpty) return; // save failed
          break;
      }
    }

    final generation = ++_rebuildGeneration;

    setState(() {
      _isSwitchingFile = true;
      if (shift && _lastClickedIndex != null) {
        final start = _lastClickedIndex!;
        final end = index;
        final range = <int>{};
        final min = start < end ? start : end;
        final max = start < end ? end : start;
        for (var i = min; i <= max; i++) {
          range.add(i);
        }
        _selectedIndices.addAll(range);
      } else if (ctrl) {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      } else {
        _selectedIndices.clear();
        _selectedIndices.add(index);
      }
      _lastClickedIndex = index;
    });

    // Defer the heavy EXIF table rebuild so the highlight frame stays fast.
    Future.delayed(Duration.zero, () {
      if (_rebuildGeneration != generation) return; // stale click
      _rebuildMergedView();
    });
  }

  void _rebuildMergedView() {
    if (_selectedIndices.isEmpty) {
      setState(() {
        _mergedItems = {};
        _displayItems = {};
        _isSwitchingFile = false;
      });
      return;
    }

    final selectedTags = <String, List<ExifTagItem>>{};
    for (final idx in _selectedIndices) {
      final file = _allFiles[idx];
      if (file.isLoaded && !file.hasError) {
        selectedTags[file.path] = file.tags;
      }
    }

    final merged = selectedTags.isEmpty
        ? <String, List<MergedTagItem>>{}
        : MergedTagItem.mergeFiles(selectedTags);

    final display = <String, List<MergedTagItem>>{};
    for (final entry in merged.entries) {
      display[entry.key] = List.from(entry.value);
    }
    for (final entry in _newTags.entries) {
      display.putIfAbsent(entry.key, () => []).addAll(entry.value);
    }

    setState(() {
      _mergedItems = merged;
      _displayItems = display;
      _isSwitchingFile = false;
    });
  }

  // ──────────────────────────────────────────────────────────
  // File loading
  // ──────────────────────────────────────────────────────────

  Future<void> _loadFiles(List<String> paths) async {
    if (paths.isEmpty) return;

    // Check unsaved changes
    if (_pendingEdits.isNotEmpty) {
      final action = await UnsavedChangesDialog.show(
        context,
        changeCount: _pendingEdits.length,
      );
      switch (action) {
        case UnsavedAction.cancel:
          return;
        case UnsavedAction.discard:
          _discardEditsInternal();
          break;
        case UnsavedAction.save:
          await _saveChangesInternal();
          if (_pendingEdits.isNotEmpty) return;
          break;
      }
    }

    setState(() {
      _allFiles.clear();
      _selectedIndices.clear();
      _lastClickedIndex = null;
      _mergedItems = {};
      _pendingEdits.clear();
      _error = '';
      _errorDetails = '';
    });

    // Add files to list
    for (final path in paths) {
      _allFiles.add(LoadedFile(path: path));
    }

    // Select first file by default
    if (_allFiles.isNotEmpty) {
      _selectedIndices.add(0);
      _lastClickedIndex = 0;
    }

    if (!mounted) return;
    await windowManager.setTitle(AppLocalizations.of(context)!.windowTitleWithCount(_allFiles.length));

    // Verify ExifTool
    final exifToolResolved = await ExifToolService.checkExifToolExists(_settings.exifToolExecutable);
    if (exifToolResolved == null) {
      setState(() {
        _error = PlatformHelper.installInstructions;
        for (final f in _allFiles) {
          f.hasError = true;
          f.errorMessage = 'ExifTool not found';
        }
      });
      return;
    }

    _exifTool.exifToolPath = exifToolResolved;

    // Load EXIF for all files in parallel
    final args = _settings.exifToolArguments.isNotEmpty
        ? _settings.exifToolArguments.split(' ')
        : <String>[];

    await Future.wait(
      List.generate(_allFiles.length, (i) => _loadExifForIndex(i, args)),
    );

    _rebuildMergedView();
  }

  Future<void> _loadExifForIndex(int index, List<String> args) async {
    final file = _allFiles[index];
    setState(() => file.isLoading = true);

    try {
      final tags = await _exifTool.readAsync(file.path, extraArgs: args);
      setState(() {
        file.tags = tags;
        file.isLoaded = true;
        file.isLoading = false;
        file.hasError = false;
        file.errorMessage = null;
      });
    } catch (e) {
      setState(() {
        file.hasError = true;
        file.errorMessage = e.toString();
        file.isLoading = false;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _allFiles.removeAt(index);

      // Rebuild selected indices
      final newSelected = <int>{};
      for (final idx in _selectedIndices) {
        if (idx < index) {
          newSelected.add(idx);
        } else if (idx > index) {
          newSelected.add(idx - 1);
        }
        // idx == index is removed
      }
      _selectedIndices
        ..clear()
        ..addAll(newSelected);

      if (_lastClickedIndex == index) {
        _lastClickedIndex = null;
      } else if (_lastClickedIndex != null && _lastClickedIndex! > index) {
        _lastClickedIndex = _lastClickedIndex! - 1;
      }

      if (_allFiles.isNotEmpty && _selectedIndices.isEmpty) {
        _selectedIndices.add(0);
        _lastClickedIndex = 0;
      }
    });
    _rebuildMergedView();
  }

  Future<void> _renameFile(int index, String newName) async {
    final file = _allFiles[index];
    final oldPath = file.path;
    final lastSep = oldPath.lastIndexOf(Platform.pathSeparator);
    final dir = lastSep >= 0 ? oldPath.substring(0, lastSep) : '';
    final newPath = dir.isNotEmpty
        ? '$dir${Platform.pathSeparator}$newName'
        : newName;

    if (newPath == oldPath) return;

    try {
      final oldFile = File(oldPath);
      if (await oldFile.exists()) {
        try {
          await oldFile.rename(newPath);
        } catch (_) {
          // Cross-device rename fallback
          await oldFile.copy(newPath);
          await oldFile.delete();
        }
      }

      setState(() {
        file.path = newPath;
      });

    } catch (e) {
      // ignored
    }
  }

  // ──────────────────────────────────────────────────────────
  // Editing
  // ──────────────────────────────────────────────────────────

  void _onEdit(MergedTagItem item) {
    final key = '${item.tagGroup}|${item.tagId}|${item.tagName}';
    final previousValue = _pendingEdits[key]?['value'];
    final wasNewTag = _newTags[item.tagGroup]?.any((t) => t.tagName == item.tagName) ?? false;

    _undoStack.add(_UndoEntry(
      key: key,
      previousValue: previousValue,
      wasNewTag: wasNewTag && previousValue == null,
    ));

    setState(() {
      _pendingEdits[key] = {
        'tagId': item.tagId,
        'tagName': item.tagName,
        'tagGroup': item.tagGroup,
        'value': item.pendingValue!,
      };
    });
  }

  Future<void> _saveChanges() async {
    await _saveChangesInternal();
  }

  Future<void> _saveChangesInternal() async {
    if (_pendingEdits.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final tagChanges = <String, String>{};
      for (final edit in _pendingEdits.values) {
        final group = edit['tagGroup']!;
        final tagName = edit['tagName']!;
        // Use group prefix so ExifTool writes to the correct namespace
        // (e.g. XMP-dc:Creator instead of just Creator)
        tagChanges['$group:$tagName'] = edit['value']!;
      }

      // Determine which files to save to
      final targetFiles = <String>[];
      for (final idx in _selectedIndices) {
        final file = _allFiles[idx];
        if (file.isLoaded && !file.hasError) {
          targetFiles.add(file.path);
        }
      }

      for (final filePath in targetFiles) {
        final tempPath = await _exifTool.writeTagsAsync(
          filePath,
          tagChanges,
        );
        // Move temp file over original
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          try {
            await tempFile.rename(filePath);
          } catch (_) {
            // Cross-device rename fallback
            await tempFile.copy(filePath);
            await tempFile.delete();
          }
        }
      }

      setState(() {
        _pendingEdits.clear();
        _newTags.clear();
        _undoStack.clear();
        _isLoading = false;
      });

      if (kDebugMode) {
        log('Save completed successfully', name: 'dragexif.user');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.changesSaved)),
        );
      }

      // Reload EXIF for affected files
      final args = _settings.exifToolArguments.isNotEmpty
          ? _settings.exifToolArguments.split(' ')
          : <String>[];
      await Future.wait(
        _selectedIndices.map((idx) => _loadExifForIndex(idx, args)),
      );
      _rebuildMergedView();

    } catch (e) {
      if (kDebugMode) {
        log('SAVE FAILED: $e', name: 'dragexif.user');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed(e.toString()))),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  void _cancelChanges() {
    _discardEditsInternal();
  }

  void _discardEditsInternal() {
    setState(() {
      _pendingEdits.clear();
      _newTags.clear();
      _undoStack.clear();
      for (final group in _mergedItems.values) {
        for (final item in group) {
          item.pendingValue = null;
        }
      }
    });
  }

  // ──────────────────────────────────────────────────────────
  // Unsaved changes guard
  // ──────────────────────────────────────────────────────────

  Future<bool> _handleUnsavedChangesBeforeAction() async {
    if (_pendingEdits.isEmpty) return true;

    final action = await UnsavedChangesDialog.show(
      context,
      changeCount: _pendingEdits.length,
    );
    switch (action) {
      case UnsavedAction.cancel:
        return false;
      case UnsavedAction.discard:
        _discardEditsInternal();
        return true;
      case UnsavedAction.save:
        await _saveChangesInternal();
        return _pendingEdits.isEmpty;
    }
  }

  // ──────────────────────────────────────────────────────────
  // File pickers
  // ──────────────────────────────────────────────────────────

  Future<void> _pickFiles() async {
    final typeGroup = XTypeGroup(
      label: AppLocalizations.of(context)!.filePickerImages,
      extensions: Constants.supportedImageExtensions,
    );
    final files = await openFiles(acceptedTypeGroups: [typeGroup]);
    if (files.isNotEmpty) {
      await _loadFiles(files.map((f) => f.path).toList());
    }
  }

  // ──────────────────────────────────────────────────────────
  // Clipboard / Export
  // ──────────────────────────────────────────────────────────

  Map<String, List<MergedTagItem>> _displayItems = {};

  Future<void> _showAddTagDialog() async {
    if (_selectedIndices.isEmpty) return;

    final result = await AddTagDialog.show(context);
    if (result == null) return;

    // Normalize XMP sub-groups for display (XMP-dc, XMP-xmp, etc. → XMP)
    final displayGroup = result.group.startsWith('XMP-') ? 'XMP' : result.group;

    // Block adding tags to read-only groups / tags
    if (Constants.isReadOnlyExifTag(displayGroup, result.tagName)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.cannotAddReadOnlyTag(result.tagName, displayGroup)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    final key = '$displayGroup||${result.tagName}';
    _undoStack.add(_UndoEntry(
      key: key,
      previousValue: null,
      wasNewTag: true,
    ));

    setState(() {
      _pendingEdits[key] = {
        'tagId': '',
        'tagName': result.tagName,
        'tagGroup': displayGroup,
        'value': result.value,
      };

      final newItem = MergedTagItem(
        tagId: '',
        tagGroup: displayGroup,
        tagName: result.tagName,
        fileValues: {},
        displayValue: '<new>',
        isUnequal: false,
        pendingValue: result.value,
      );
      _newTags.putIfAbsent(displayGroup, () => []).add(newItem);
    });
  }

  Future<void> _copySelected() async {
    final buffer = StringBuffer();
    final display = _displayItems;
    for (final groupEntry in display.entries) {
      buffer.writeln('[${groupEntry.key}]');
      for (final item in groupEntry.value) {
        buffer.writeln('  ${item.tagName}: ${item.currentValue}');
      }
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
  }

  List<ExifTagItem> get _exportItems {
    // Flatten display items into ExifTagItem list for export
    final result = <ExifTagItem>[];
    var index = 0;
    for (final group in _displayItems.values) {
      for (final item in group) {
        result.add(ExifTagItem(
          index: ++index,
          tagId: item.tagId,
          tagGroup: item.tagGroup,
          tagName: item.tagName,
          tagValue: item.currentValue,
        ));
      }
    }
    return result;
  }

  // ──────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────

  // Toggle to false to test if the right-side panel is causing lag
  static const bool _kShowRightPanel = true;

  Widget _buildBody(BuildContext context) {
    final hasChanges = _pendingEdits.isNotEmpty;
    final selectedCount = _selectedIndices.length;

    return DropTarget(
      onDragEntered: (_) => setState(() => _dragging = true),
      onDragExited: (_) => setState(() => _dragging = false),
      onDragDone: (detail) async {
        setState(() => _dragging = false);
        final files = <String>[];
        for (final file in detail.files) {
          final path = file.path;
          if (path.isNotEmpty) {
            final stat = FileStat.statSync(path);
            if (stat.type != FileSystemEntityType.directory &&
                Constants.isSupportedImage(path)) {
              files.add(path);
            }
          }
        }
        if (files.isNotEmpty) {
          await _loadFiles(files);
        }
      },
      child: Container(
        color: _dragging
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        child: Row(
          children: [
            // ── Left: File list panel ──
            SizedBox(
              width: _leftPanelWidth,
              child: FileListPanel(
                files: _allFiles,
                selectedIndices: _selectedIndices,
                lastClickedIndex: _lastClickedIndex,
                onSelect: _onSelectFile,
                onRemove: _removeFile,
                onRename: _renameFile,
              ),
            ),

            // Draggable splitter
            MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _leftPanelWidth += details.delta.dx;
                    _leftPanelWidth = _leftPanelWidth.clamp(150.0, 500.0);
                  });
                },
                child: SizedBox(
                  width: 8,
                  child: Center(
                    child: VerticalDivider(
                      width: 1,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
            ),

            // ── Right: Main content ──
            if (_kShowRightPanel)
              Expanded(
                child: Column(
                children: [
                  // Unsaved changes banner
                  if (hasChanges)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.unsavedChangesBanner(_pendingEdits.length),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _cancelChanges,
                            child: Text(AppLocalizations.of(context)!.discard),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _saveChanges,
                            child: Text(AppLocalizations.of(context)!.save),
                          ),
                        ],
                      ),
                    ),

                  // Main content area
                  Expanded(
                    child: _error.isNotEmpty && _allFiles.isEmpty
                        ? ErrorDisplay(error: _error, details: _errorDetails)
                        : _allFiles.isEmpty && !_isLoading
                            ? Center(child: Text(AppLocalizations.of(context)!.dropFilesHint))
                            : _isLoading && _mergedItems.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : selectedCount == 0
                                    ? Center(child: Text(AppLocalizations.of(context)!.selectFileHint))
                                    : _isSwitchingFile
                                        ? Container(
                                            alignment: Alignment.center,
                                            child: const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            ),
                                          )
                                        : _displayItems.isEmpty
                                            ? Center(child: Text(AppLocalizations.of(context)!.noExifData))
                                            : EditableExifDataTable(
                                                key: _tableKey,
                                                groupedItems: _displayItems,
                                                showIndex: _settings.showColumnIndex,
                                                showTagId: _settings.showColumnTagId,
                                                showTagName: _settings.showColumnTagName,
                                                showTagValue: _settings.showColumnTagValue,
                                                onEdit: _onEdit,
                                              ),
                  ),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilledButton.icon(
                                onPressed: _pickFiles,
                                icon: const Icon(Icons.folder_open, size: 18),
                                label: Text(AppLocalizations.of(context)!.openFiles),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _displayItems.isEmpty ? null : _copySelected,
                                icon: const Icon(Icons.copy, size: 18),
                                label: Text(AppLocalizations.of(context)!.copy),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: _selectedIndices.isEmpty ? null : _showAddTagDialog,
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(AppLocalizations.of(context)!.addTag),
                              ),
                              const SizedBox(width: 8),
                              ExportMenu(
                                items: _exportItems,
                                defaultFileName: selectedCount > 0
                                    ? '${_allFiles[_selectedIndices.first].fileName.split('.').first}_exif'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyS, control: true): SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, meta: true): SaveIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, control: true): UndoIntent(),
        SingleActivator(LogicalKeyboardKey.keyZ, meta: true): UndoIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SaveIntent: CallbackAction<SaveIntent>(
            onInvoke: (_) => _handleSave(),
          ),
          UndoIntent: CallbackAction<UndoIntent>(
            onInvoke: (_) => _undo(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: IndexedStack(
              index: _currentTab,
              children: [
                _buildBody(context),
                const SettingsPage(),
              ],
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentTab,
              onDestinationSelected: (index) {
                setState(() => _currentTab = index);
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home),
                  label: AppLocalizations.of(context)!.tabHome,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.settings_outlined),
                  selectedIcon: const Icon(Icons.settings),
                  label: AppLocalizations.of(context)!.settings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
