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

import '../generated/app_localizations.dart';

enum UnsavedAction { save, discard, cancel }

class UnsavedChangesDialog extends StatelessWidget {
  final int changeCount;

  const UnsavedChangesDialog({
    super.key,
    required this.changeCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.orange),
          const SizedBox(width: 8),
          Text(l10n.unsavedChangesDialogTitle),
        ],
      ),
      content: Text(l10n.unsavedChangesDialogContent(changeCount)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(UnsavedAction.cancel),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(UnsavedAction.discard),
          child: Text(l10n.discard),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(UnsavedAction.save),
          child: Text(l10n.save),
        ),
      ],
    );
  }

  static Future<UnsavedAction> show(BuildContext context, {required int changeCount}) async {
    return await showDialog<UnsavedAction>(
          context: context,
          barrierDismissible: false,
          builder: (_) => UnsavedChangesDialog(changeCount: changeCount),
        ) ??
        UnsavedAction.cancel;
  }
}
