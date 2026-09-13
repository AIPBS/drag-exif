/*
DragExif - EXIF metadata viewer
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generated/app_localizations.dart';
import '../models/exif_tag_item.dart';
import '../utils/exporters.dart';

class ExportMenu extends StatelessWidget {
  final List<ExifTagItem> items;
  final String? defaultFileName;

  const ExportMenu({
    super.key,
    required this.items,
    this.defaultFileName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopupMenuButton<ExportFileType>(
      tooltip: l10n.exportAs,
      onSelected: (type) => _export(context, type),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ExportFileType.text,
          child: Text(l10n.exportText),
        ),
        PopupMenuItem(
          value: ExportFileType.csv,
          child: Text(l10n.exportCsv),
        ),
        PopupMenuItem(
          value: ExportFileType.json,
          child: Text(l10n.exportJson),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.exportAs),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context, ExportFileType type) async {
    String content;

    switch (type) {
      case ExportFileType.text:
        content = Exporters.toText(items);
      case ExportFileType.csv:
        content = Exporters.toCsv(items);
      case ExportFileType.json:
        content = Exporters.toJson(items);
    }

    // For now, copy to clipboard as a quick win
    // File save dialog can be added later with file_selector
    await Clipboard.setData(ClipboardData(text: content));

    // ignored
  }
}
