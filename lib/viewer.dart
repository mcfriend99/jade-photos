import 'package:flutter/material.dart';
import 'package:jade_gallery/color_backup.dart';
import 'package:jade_gallery/constants.dart';
import 'package:jade_gallery/widgets/access_bar.dart';
import 'package:jade_gallery/widgets/image_thumbnail.dart';
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
  late ScrollController _scrollController;
  late int _currentIndex;
  bool _showAppBar = true;
  bool _isInitialized = false;

  final _zoomController = TransformationController();
  final _minScale = 0.8;
  final _maxScale = 2.5;
  final _zoomFactor = 0.2;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _scrollController = ScrollController(
      initialScrollOffset: _calculateListOffset(),
    );
    _isInitialized = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  double _calculateListOffset() {
    double offset = 5;
    if (_isInitialized) {
      offset = MediaQuery.of(context).size.width / 72 / 2;
    }

    return (_currentIndex - offset).clamp(0, double.maxFinite) * 72;
  }

  void _scrollList() {
    _scrollController.animateTo(
      _calculateListOffset(),
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 200),
    );
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
                      _scrollList();
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
          _showAppBar
              ? Container(
                  height: 80,
                  decoration: BoxDecoration(
                    border: BoxBorder.fromLTRB(
                      top: const BorderSide(
                        color: innerBorderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: widget.images.length,
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    hitTestBehavior: HitTestBehavior.translucent,
                    padding: EdgeInsets.all(8),
                    separatorBuilder: (context, index) =>
                        const VerticalDivider(width: 12),
                    itemBuilder: (context, index) {
                      final image = widget.images[index];

                      return SizedBox(
                        width: 60,
                        height: 60,
                        child: ImageThumbnail(
                          key: Key(image.path),
                          image: image,
                          isSelected: index == _currentIndex,
                          onTap: () => _pageController.jumpToPage(index),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
