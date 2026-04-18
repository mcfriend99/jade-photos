import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jade_gallery/color_backup.dart';
import 'package:jade_gallery/models/collection.dart';
import 'package:jade_gallery/models/j_image.dart';

class CollectionThumbnail extends StatefulWidget {
  final Collection collection;
  final List<JImage> images;
  final VoidCallback onTap;

  const CollectionThumbnail({
    super.key,
    this.images = const <JImage>[],
    required this.onTap,
    required this.collection,
  });

  @override
  State<CollectionThumbnail> createState() => _CollectionThumbnailState();
}

class _CollectionThumbnailState extends State<CollectionThumbnail> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final image = widget.images.firstWhere(
      (s) => s.collection == widget.collection.id,
      orElse: () =>
          JImage(collection: widget.collection.id, path: '', file: File('.')),
    );

    return MouseRegion(
      key: Key(widget.collection.path),
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 1,
          margin: EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          shape: const ContinuousRectangleBorder(),
          color: regionColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: image,
                child: Image.file(
                  image.file,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(180), Colors.transparent],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Text(
                        widget.collection.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Color(0x05000000),
                child: InkWell(
                  onTap: widget.onTap,
                  mouseCursor: SystemMouseCursors.click,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
