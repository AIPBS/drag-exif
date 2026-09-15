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
import 'about_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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

  // ── Theme ──

  int get _themeIndex => _settings.themeMode;

  void _onThemeChanged(int index) {
    setState(() => _settings.themeMode = index);
    _settings.save();
    themeModeNotifier.value = _themeModeFromIndex(index);
  }

  ThemeMode _themeModeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.dark;
      case 2:
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  // ── Locale ──

  String get _localeCode => _settings.locale;

  void _onLocaleChanged(String code) {
    setState(() => _settings.locale = code);
    _settings.save();
    localeNotifier.value = code.isEmpty ? null : Locale(code);
  }


  // ── ExifTool ──

  void _onExifToolChanged() {
    _settings.exifToolExecutable = _executableController.text.trim();
    _settings.exifToolArguments = _argumentsController.text.trim();
    _settings.save();
  }

  Future<void> _showAbout() async {
    await showDialog(
      context: context,
      builder: (_) => const AboutScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    Theme.of(context).brightness == Brightness.dark
                        ? 'assets/app_icon_v1.1.0.png'
                        : 'assets/app_icon_v1.1.0_light.png',
                    width: 240,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Appearance ──
                Text(
                  l10n.appTheme,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _themeIndex,
                  items: [
                    DropdownMenuItem(value: 0, child: Text(l10n.themeSystem)),
                    DropdownMenuItem(value: 1, child: Text(l10n.themeDark)),
                    DropdownMenuItem(value: 2, child: Text(l10n.themeLight)),
                  ],
                  onChanged: (v) {
                    if (v != null) _onThemeChanged(v);
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                Text(
                  l10n.language,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _localeCode,
                  items: [
                    DropdownMenuItem(value: '', child: Text(l10n.languageSystem)),
                    const DropdownMenuItem(value: 'en', child: Text('English')),
                    const DropdownMenuItem(value: 'zh', child: Text('中文')),
                  ],
                  onChanged: (v) {
                    if (v != null) _onLocaleChanged(v);
                  },
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                

                // ── ExifTool ──
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
                        onChanged: (_) => _onExifToolChanged(),
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
                  onChanged: (_) => _onExifToolChanged(),
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
                const SizedBox(height: 24),

                Text(
                  l10n.about,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.about),
                  onTap: _showAbout,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
