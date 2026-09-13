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

import 'dart:developer';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../generated/app_localizations.dart';
import '../models/exif_tag_item.dart' show MergedTagItem;
import '../utils/constants.dart';

class EditableExifDataTable extends StatefulWidget {
  final Map<String, List<MergedTagItem>> groupedItems;
  final bool showIndex;
  final bool showTagId;
  final bool showTagName;
  final bool showTagValue;
  final void Function(MergedTagItem item)? onEdit;

  const EditableExifDataTable({
    super.key,
    required this.groupedItems,
    this.showIndex = true,
    this.showTagId = true,
    this.showTagName = true,
    this.showTagValue = true,
    this.onEdit,
  });

  @override
  State<EditableExifDataTable> createState() => EditableExifDataTableState();
}

class EditableExifDataTableState extends State<EditableExifDataTable> {
  int? _editingIndex;
  String? _editingGroup;
  MergedTagItem? _editingItem;
  final _editController = TextEditingController();
  List<DataColumn2>? _cachedColumns;
  static const double _rowHeight = 48;
  static const double _headerHeight = 56;
  static final _pendingRowColor = WidgetStateProperty.all(
    Colors.blue.withValues(alpha: 0.12),
  );

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EditableExifDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showIndex != widget.showIndex ||
        oldWidget.showTagId != widget.showTagId ||
        oldWidget.showTagName != widget.showTagName ||
        oldWidget.showTagValue != widget.showTagValue) {
      _cachedColumns = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupKeys = widget.groupedItems.keys.toList();

    return ListView.builder(
      itemCount: groupKeys.length,
      itemBuilder: (context, groupIndex) {
        final groupName = groupKeys[groupIndex];
        final groupItems = widget.groupedItems[groupName]!;

        return ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            groupName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(AppLocalizations.of(context)!.tagCount(groupItems.length)),
          children: [
            SizedBox(
              height: groupItems.length * _rowHeight + _headerHeight,
              child: DataTable2(
                dataRowHeight: _rowHeight,
                headingRowHeight: _headerHeight,
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: _buildColumns(),
                rows: List.generate(groupItems.length, (index) {
                  return _buildRow(groupItems[index], groupName, index);
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  List<DataColumn2> _buildColumns() {
    return _cachedColumns ??= _createColumns();
  }

  List<DataColumn2> _createColumns() {
    final columns = <DataColumn2>[];
    const headerStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    final l10n = AppLocalizations.of(context)!;
    if (widget.showIndex) {
      columns.add(const DataColumn2(size: ColumnSize.S, label: Text('', style: headerStyle)));
    }
    if (widget.showTagId) {
      columns.add(DataColumn2(size: ColumnSize.S, label: Text(l10n.columnTagId, style: headerStyle)));
    }
    if (widget.showTagName) {
      columns.add(DataColumn2(size: ColumnSize.M, label: Text(l10n.columnTagName, style: headerStyle)));
    }
    if (widget.showTagValue) {
      columns.add(DataColumn2(size: ColumnSize.L, label: Text(l10n.columnValue, style: headerStyle)));
    }
    // Action column (delete)
    columns.add(const DataColumn2(size: ColumnSize.S, label: Text('', style: headerStyle)));
    return columns;
  }

  bool _isReadOnly(MergedTagItem item) =>
      Constants.isReadOnlyExifTag(item.tagGroup, item.tagName);

  void _showReadOnlyNotice(MergedTagItem item) {
    // read-only notice removed per user request
  }

  DataRow2 _buildRow(MergedTagItem item, String groupName, int index) {
    final isEditing = _editingGroup == groupName && _editingIndex == index;
    final isMarkedForDeletion = item.pendingValue != null && item.pendingValue!.isEmpty;
    final displayValue = isMarkedForDeletion ? '<temp>' : item.currentValue;
    final isUnequal = item.isUnequal && item.pendingValue == null;
    final hasPending = item.hasPendingChange;
    final readOnly = _isReadOnly(item);

    final cells = <DataCell>[];

    const cellStyle = TextStyle(fontSize: 14);
    if (widget.showIndex) {
      cells.add(DataCell(Text('${index + 1}', style: cellStyle)));
    }
    if (widget.showTagId) {
      cells.add(DataCell(Text(item.tagId, style: cellStyle)));
    }
    if (widget.showTagName) {
      cells.add(
        DataCell(
          Tooltip(
            message: item.tagName,
            waitDuration: const Duration(milliseconds: 300),
            child: Text(
              item.tagName,
              overflow: TextOverflow.ellipsis,
              style: cellStyle,
            ),
          ),
        ),
      );
    }
    if (widget.showTagValue) {
      if (isEditing && !readOnly) {
        cells.add(
          DataCell(
            SizedBox.expand(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Transform.translate(
                  offset: const Offset(0, -1),
                  child: TextField(
                    controller: _editController,
                    autofocus: true,
                    style: cellStyle.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (value) {
                      _finishEdit(item, value);
                    },
                    onTapOutside: (_) {
                      _finishEdit(item, _editController.text);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (readOnly) {
        cells.add(
          DataCell(
            SizedBox.expand(
              child: InkWell(
                mouseCursor: SystemMouseCursors.forbidden,
                onTap: () => _showReadOnlyNotice(item),
                onDoubleTap: () => _showValueDialog(item),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: AppLocalizations.of(context)!.cannotBeEdited,
                    child: Text(
                      displayValue,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: cellStyle.copyWith(
                        color: isUnequal
                            ? Theme.of(context).colorScheme.error
                            : hasPending
                                ? Colors.blue
                                : null,
                        fontStyle: isUnequal ? FontStyle.italic : null,
                        fontWeight: hasPending ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        cells.add(
          DataCell(
            SizedBox.expand(
              child: InkWell(
                onTap: () => _startEdit(item, groupName, index),
                onDoubleTap: () => _showValueDialog(item),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(
                    message: displayValue,
                    waitDuration: const Duration(milliseconds: 300),
                    child: Text(
                      displayValue,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: cellStyle.copyWith(
                        color: isMarkedForDeletion
                            ? Theme.of(context).colorScheme.error
                            : isUnequal
                                ? Theme.of(context).colorScheme.error
                                : hasPending
                                    ? Colors.blue
                                    : null,
                        fontStyle: isUnequal || isMarkedForDeletion ? FontStyle.italic : null,
                        fontWeight: hasPending ? FontWeight.w600 : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    // Delete icon
    cells.add(
      DataCell(
        SizedBox.expand(
          child: readOnly
              ? const SizedBox.shrink()
              : InkWell(
                  onTap: () {
                    item.pendingValue = '';
                    widget.onEdit?.call(item);
                  },
                  child: const Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
      ),
    );

    return DataRow2(
      cells: cells,
      color: hasPending ? _pendingRowColor : null,
    );
  }

  Future<void> _showValueDialog(MergedTagItem item) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${item.tagGroup} › ${item.tagName}'),
        content: SingleChildScrollView(
          child: SelectableText(item.currentValue),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: item.currentValue));
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.copy),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _startEdit(MergedTagItem item, String groupName, int index) {
    if (kDebugMode) {
      log('User clicked field to edit: ${item.tagGroup}:${item.tagName}', name: 'dragexif.user');
    }
    setState(() {
      _editingGroup = groupName;
      _editingIndex = index;
      _editingItem = item;
      _editController.text = item.isUnequal ? '' : item.currentValue;
    });
  }

  /// Finish the current inline edit and commit the value.
  void finishEditing() {
    if (_editingItem != null) {
      _finishEdit(_editingItem!, _editController.text);
    }
  }

  void _finishEdit(MergedTagItem item, String value) {
    setState(() {
      _editingGroup = null;
      _editingIndex = null;
      _editingItem = null;
    });
    // Only register an edit if the value actually changed
    if (value != item.currentValue) {
      widget.onEdit?.call(item..pendingValue = value);
    }
  }
}
