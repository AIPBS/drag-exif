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
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';
import '../services/settings_service.dart';
import '../utils/constants.dart';
import '../utils/locale_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  late final _executableController = TextEditingController();
  late final _argumentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _executableController.text = _settings.exifToolExecutable;
    _argumentsController.text = _settings.exifToolArguments;
    _executableController.addListener(_updatePreview);
    _argumentsController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _executableController.dispose();
    _argumentsController.dispose();
    super.dispose();
  }

  String get _previewCommand {
    final path = _executableController.text.trim().isEmpty
        ? 'exiftool'
        : _executableController.text.trim();
    final args = _argumentsController.text.trim();
    return '$path ${Constants.defaultCommands} ${args.isNotEmpty ? '$args ' : ''}"C:\\path\\to\\photo.jpg"';
  }

  void _updatePreview() => setState(() {});

  Future<void> _pickExecutable() async {
    final typeGroup = XTypeGroup(
      label: AppLocalizations.of(context)!.exifToolBinary,
      extensions: ['exe'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() {
        _executableController.text = file.path;
      });
    }
  }

  void _save() {
    final oldLocale = _settings.locale;
    _settings.themeMode = _selectedThemeIndex;
    _settings.enableWindowTopMost = _topMost;
    _settings.locale = _selectedLocale;
    _settings.exifToolExecutable = _executableController.text.trim();
    _settings.exifToolArguments = _argumentsController.text.trim();
    _settings.save();
    if (oldLocale != _selectedLocale) {
      localeNotifier.value = _selectedLocale.isEmpty ? null : Locale(_selectedLocale);
    }
    Navigator.of(context).pop(true);
  }

  int get _selectedThemeIndex => _settings.themeMode;
  set _selectedThemeIndex(int value) => setState(() => _settings.themeMode = value);

  bool get _topMost => _settings.enableWindowTopMost;
  set _topMost(bool value) => setState(() => _settings.enableWindowTopMost = value);

  String get _selectedLocale => _settings.locale;
  set _selectedLocale(String value) => setState(() => _settings.locale = value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.settings),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.language,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedLocale,
                items: [
                  DropdownMenuItem(value: '', child: Text(l10n.languageSystem)),
                  const DropdownMenuItem(value: 'en', child: Text('English')),
                  const DropdownMenuItem(value: 'zh', child: Text('中文')),
                ],
                onChanged: (v) => _selectedLocale = v ?? '',
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTheme,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                initialValue: _selectedThemeIndex,
                items: [
                  DropdownMenuItem(value: 0, child: Text(l10n.themeSystem)),
                  DropdownMenuItem(value: 1, child: Text(l10n.themeDark)),
                  DropdownMenuItem(value: 2, child: Text(l10n.themeLight)),
                ],
                onChanged: (v) => _selectedThemeIndex = v ?? 0,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text(l10n.alwaysOnTop),
                value: _topMost,
                onChanged: (v) => _topMost = v ?? false,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.exifToolConfigurations,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(l10n.exifToolPath),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _executableController,
                      decoration: InputDecoration(
                        hintText: l10n.exifToolPathSelect,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _pickExecutable,
                    child: Text(l10n.exifToolPathSelect),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(l10n.exifToolArguments),
              const SizedBox(height: 4),
              TextField(
                controller: _argumentsController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.previewSettings),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 80),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _previewCommand,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
