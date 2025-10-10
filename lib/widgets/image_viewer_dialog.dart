// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ImageViewerDialog extends StatefulWidget {
  final String imageUrl;
  final String? title;

  const ImageViewerDialog({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  State<ImageViewerDialog> createState() => _ImageViewerDialogState();
}

class _ImageViewerDialogState extends State<ImageViewerDialog> {
  late TransformationController _transformationController;
  late InteractiveViewer _interactiveViewer;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _interactiveViewer = InteractiveViewer(
      transformationController: _transformationController,
      minScale: 0.5,
      maxScale: 4.0,
      child: Image.network(
        widget.imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (final context, final error, final stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loadingBuilder: (final context, final child, final loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: LoadingAnimationWidget.beat(
              color: Theme.of(context).primaryColor,
              size: 50,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(final BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black12,
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Full screen image viewer
          Center(
            child: _interactiveViewer,
          ),

          // Top bar with close button and title
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 50,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title ?? 'Image',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _resetZoom,
                    icon: const Icon(
                      Icons.zoom_out_map,
                      color: Colors.white,
                      size: 24,
                    ),
                    tooltip: 'Reset zoom',
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar with zoom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Pinch to zoom • Drag to pan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show image viewer
void showImageViewer(final BuildContext context, final String imageUrl,
    {final String? title}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (final BuildContext context) {
      return ImageViewerDialog(
        imageUrl: imageUrl,
        title: title,
      );
    },
  );
}
