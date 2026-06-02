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

/// A fixed-size image preview that never changes dimensions while loading.
///
/// When the file path changes the widget:
/// 1. Keeps the exact same bounds (no layout jumps)
/// 2. Shows the image directly — no big placeholder icon flash
/// 3. Fades the image in smoothly once decoded
/// 4. Shows a subtle spinner while the new image is loading
class ImagePreview extends StatefulWidget {
  final String? filePath;
  final double height;

  const ImagePreview({
    super.key,
    this.filePath,
    this.height = 220,
  });

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  /// Optional down-scale for oversized images. Determined in the background
  /// so it never blocks the visual transition.
  int? _cacheHeight;

  @override
  void didUpdateWidget(covariant ImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      _cacheHeight = null;
      _updateCacheHeight();
    }
  }

  Future<void> _updateCacheHeight() async {
    final path = widget.filePath;
    if (path == null || !Constants.isPreviewableImage(path)) return;

    int? newCacheHeight;
    try {
      final file = File(path);
      if (await file.exists()) {
        final size = await file.length();
        if (size > Constants.maxAutoPreviewSizeBytes) {
          // Large file: decode at half resolution to save memory/time
          newCacheHeight = (widget.height * 0.5).round();
        }
      }
    } catch (_) {
      // Ignore — Image.file errorBuilder will surface real problems
    }

    if (mounted && widget.filePath == path) {
      setState(() => _cacheHeight = newCacheHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.filePath;

    // Fixed bounds — never changes size, preventing layout jumps
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        alignment: Alignment.center,
        child: path == null
            ? _Placeholder(text: 'No preview')
            : Image.file(
                File(path),
                fit: BoxFit.contain,
                cacheHeight: _cacheHeight,
                // frameBuilder is called every frame while the image decodes.
                // frame == null  → image hasn't decoded yet → show spinner
                // frame != null  → image ready → fade it in
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) {
                    return AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  }
                  // Subtle spinner instead of a big icon placeholder
                  return const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _Placeholder(
                    text: Constants.isPreviewableImage(path)
                        ? 'Cannot load image'
                        : 'Preview not available',
                  );
                },
              ),
      ),
    );
  }
}

/// A small, centered placeholder that fits inside the fixed preview box.
class _Placeholder extends StatelessWidget {
  final String text;

  const _Placeholder({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.image_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
