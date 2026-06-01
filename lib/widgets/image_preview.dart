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

import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ImagePreview extends StatefulWidget {
  final String? filePath;
  final double maxHeight;

  const ImagePreview({
    super.key,
    this.filePath,
    this.maxHeight = 220,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  bool _showImage = false;
  int _fileSize = 0;
  bool _isPreviewable = false;
  bool _exists = false;
  bool _evaluating = true;

  @override
  void initState() {
    super.initState();
    _evaluateFile();
  }

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _evaluateFile();
    }
  }

  Future<void> _evaluateFile() async {
    final path = widget.filePath;
    if (path == null || path.isEmpty) {
      if (mounted) {
        setState(() {
          _exists = false;
          _isPreviewable = false;
          _fileSize = 0;
          _showImage = false;
          _evaluating = false;
        });
      }
      return;
    }

    setState(() => _evaluating = true);

    bool exists = false;
    int size = 0;
    try {
      final file = File(path);
      exists = await file.exists();
      if (exists) {
        size = await file.length();
      }
    } catch (_) {
      exists = false;
      size = 0;
    }

    if (!mounted) return;
    // Stale result guard – path may have changed while we were async
    if (widget.filePath != path) return;

    final isPreviewable = Constants.isPreviewableImage(path);

    setState(() {
      _exists = exists;
      _isPreviewable = isPreviewable;
      _fileSize = size;
      _showImage = exists && isPreviewable && size <= Constants.maxAutoPreviewSizeBytes;
      _evaluating = false;
    });
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filePath == null || widget.filePath!.isEmpty) {
      return _placeholder(context, Icons.image, 'No preview');
    }

    if (_evaluating) {
      return _placeholder(context, Icons.image, 'Loading preview...');
    }

    if (!_exists) {
      return _placeholder(context, Icons.broken_image, 'File not found');
    }

    if (!_isPreviewable) {
      return _placeholder(
        context,
        Icons.image_not_supported,
        'Preview not available',
        subtitle: 'Format not supported by Flutter preview',
      );
    }

    if (!_showImage) {
      return _clickablePlaceholder(
        context,
        Icons.photo_size_select_large,
        'Image too large',
        subtitle:
            '${_formatBytes(_fileSize)} — click to preview',
        onTap: () => setState(() => _showImage = true),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      padding: const EdgeInsets.all(8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          File(widget.filePath!),
          key: ValueKey(widget.filePath),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          cacheHeight: (widget.maxHeight * MediaQuery.of(context).devicePixelRatio * 1.5).round(),
          errorBuilder: (context, error, stackTrace) {
            return _placeholder(context, Icons.broken_image, 'Cannot load image');
          },
        ),
      ),
    );
  }

  Widget _placeholder(
    BuildContext context,
    IconData icon,
    String label, {
    String? subtitle,
  }) {
    return Container(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _clickablePlaceholder(
    BuildContext context,
    IconData icon,
    String label, {
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: BoxConstraints(maxHeight: widget.maxHeight),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.7),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to load',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
