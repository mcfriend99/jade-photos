import 'package:flutter/material.dart';
import 'package:jade_gallery/constants.dart';
import 'package:jade_gallery/widgets/access_bar.dart';
import 'package:jade_gallery/widgets/window_box.dart';
import 'package:jade_gallery/widgets/zoomable.dart';
import 'package:path/path.dart' as p;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'models/images.dart';

class FullscreenViewer extends StatefulWidget {
  final List<JImage> images;
  final int initialIndex;

  const FullscreenViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenViewer> createState() => _FullscreenViewerState();
}

class _FullscreenViewerState extends State<FullscreenViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  final _zoomController = TransformationController();
  final _minScale = 0.8;
  final _maxScale = 2.5;
  final _zoomFactor = 0.2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleAppBar() {
    setState(() {
      _showAppBar = !_showAppBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WindowBox(
      title: appName,
      child: Column(
        children: [
          if (_showAppBar)
            SizedBox(
              height: 48,
              child: AccessBar(
                title: p.basename(widget.images.elementAt(_currentIndex).path),
                leading: const BackButton(color: Colors.white),
                actions: [
                  IconButton(
                    onPressed:
                        _zoomController.value.getMaxScaleOnAxis() > _minScale
                        ? () {
                            final scale =
                                (_zoomController.value.getMaxScaleOnAxis() -
                                        _zoomFactor)
                                    .clamp(_minScale, _maxScale);

                            setState(() {
                              _zoomController.value = Matrix4.identity()
                                ..scaleByDouble(scale, scale, scale, 1.0);
                            });
                          }
                        : null,
                    tooltip: 'Zoom Out (⌘-)',
                    icon: Icon(PhosphorIconsRegular.minus),
                  ),
                  IconButton(
                    onPressed:
                        _zoomController.value.getMaxScaleOnAxis() < _maxScale
                        ? () {
                            final scale =
                                (_zoomController.value.getMaxScaleOnAxis() +
                                        _zoomFactor)
                                    .clamp(_minScale, _maxScale);

                            setState(() {
                              _zoomController.value = Matrix4.identity()
                                ..scaleByDouble(scale, scale, scale, 1.0);
                            });
                          }
                        : null,
                    tooltip: 'Zoom In (⌘+)',
                    icon: Icon(PhosphorIconsRegular.plus),
                  ),
                  const VerticalDivider(),
                  IconButton(
                    onPressed: null,
                    tooltip: 'Properties (⌘I)',
                    icon: Icon(PhosphorIconsRegular.info),
                  ),
                  IconButton(
                    onPressed: null,
                    tooltip: 'Edit',
                    icon: Icon(PhosphorIconsRegular.pencil),
                  ),
                  IconButton(
                    onPressed: null,
                    tooltip: 'Send/Share',
                    icon: Icon(PhosphorIconsRegular.share),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.black,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _toggleAppBar,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final image = widget.images[index];

                    return Zoomable(
                      controller: _zoomController,
                      onZoom: (_) => setState(() {}),
                      child: Focus(
                        autofocus: true,
                        child: Center(
                          child: Hero(
                            tag: image.path,
                            child: Image.file(image.file, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withAlpha(40),
              elevation: 0,
              leading: const BackButton(color: Colors.white),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.basename(widget.images.elementAt(_currentIndex).path),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            )
          : null,
      body: GestureDetector(
        onTap: _toggleAppBar,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final image = widget.images.elementAt(index);
            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Center(
                child: Hero(
                  tag: image.path,
                  child: Image.file(image.file, fit: BoxFit.contain),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
