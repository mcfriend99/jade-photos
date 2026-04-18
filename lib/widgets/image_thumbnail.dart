import 'package:flutter/material.dart';
import 'package:jade_gallery/color.dart';
import 'package:jade_gallery/models/j_image.dart';
import 'package:path/path.dart' as p;
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ImageThumbnail extends StatefulWidget {
  final JImage image;
  final VoidCallback onTap;
  final bool showName;
  final bool isSelected;

  const ImageThumbnail({
    super.key,
    required this.image,
    required this.onTap,
    this.showName = false,
    this.isSelected = false,
  });

  @override
  State<ImageThumbnail> createState() => _ImageThumbnailState();
}

class _ImageThumbnailState extends State<ImageThumbnail> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: Key(widget.image.path),
      onEnter: widget.showName
          ? (_) => setState(() => _isHovered = true)
          : null,
      onExit: widget.showName
          ? (_) => setState(() => _isHovered = false)
          : null,
      child: AnimatedScale(
        scale: _isHovered ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: _isHovered ? 8 : 1,
          margin: EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          shape: ContinuousRectangleBorder(
            side: widget.isSelected
                ? BorderSide(color: accentBlue, width: 4)
                : BorderSide(color: Colors.transparent, width: 0.5),
          ),
          color: regionColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: widget.image,
                child: Image.file(
                  widget.image.file,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: const Icon(PhosphorIconsRegular.imageBroken),
                  ),
                ),
              ),
              if (_isHovered && widget.showName)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                      top: 12,
                      bottom: 8,
                      left: 12,
                      right: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(140),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      p.basename(widget.image.path),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              Material(
                color: Colors.transparent,
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
