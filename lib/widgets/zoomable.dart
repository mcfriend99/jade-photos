import 'package:flutter/cupertino.dart' hide ShortcutRegistry;
import 'package:flutter/services.dart';
import 'package:jade_gallery/mixins/HasKeyboardShortcuts.dart';

class Zoomable extends StatefulWidget {
  final Widget child;
  final bool keyboardZoom;
  final double keyZoomFactor;
  final double minScale;
  final double maxScale;
  final TransformationController? controller;
  final Function(double)? onZoom;

  const Zoomable({
    super.key,
    required this.child,
    this.controller,
    this.minScale = 0.8,
    this.maxScale = 2.5,
    this.keyboardZoom = true,
    this.keyZoomFactor = 0.2,
    this.onZoom,
  });

  @override
  State createState() => _Zoomable();
}

class _Zoomable extends State<Zoomable> with SingleTickerProviderStateMixin, Haskeyboardshortcuts {
  late TransformationController _controller;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TransformationController();
    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200), // Smooth but fast
        )..addListener(() {
          _controller.value = _animation!.value;
          widget.onZoom?.call(_controller.value.getMaxScaleOnAxis());
        });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      shortcutRegistry?.register(
        const SingleActivator(LogicalKeyboardKey.equal, control: true),
        _zoomIn,
      );

      shortcutRegistry?.register(
        const SingleActivator(LogicalKeyboardKey.minus, control: true),
        _zoomOut,
      );

      shortcutRegistry?.register(
        const SingleActivator(LogicalKeyboardKey.digit0, control: true),
        _resetZoom,
      );
    });
  }

  @override
  void dispose() {
    shortcutRegistry?.unregister(
      const SingleActivator(LogicalKeyboardKey.equal, control: true),
      _zoomIn,
    );

    shortcutRegistry?.unregister(
      const SingleActivator(LogicalKeyboardKey.minus, control: true),
      _zoomOut,
    );

    shortcutRegistry?.unregister(
      const SingleActivator(LogicalKeyboardKey.digit0, control: true),
      _resetZoom,
    );

    super.dispose();
  }

  void _zoom(double delta) {
    final double currentScale = _controller.value.getMaxScaleOnAxis();
    final double targetScale = (currentScale + delta).clamp(
      widget.minScale,
      widget.maxScale,
    );

    // Preserve current translation (pan)
    final translation = _controller.value.getTranslation();
    final Matrix4 targetMatrix = Matrix4.identity()
      ..translateByVector3(translation)
      ..scaleByDouble(targetScale, targetScale, targetScale, 1.0);

    // Define the transition from current matrix to target matrix
    _animation = Matrix4Tween(begin: _controller.value, end: targetMatrix)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut, // Gives it a natural "slow down" feel
          ),
        );

    _animationController.forward(from: 0);
  }

  void _resetZoom() {
    // Animate back to original size
    _animation = Matrix4Tween(begin: _controller.value, end: Matrix4.identity())
        .animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward(from: 0);
  }

  void _zoomIn() {
    _zoom(widget.keyZoomFactor);
  }

  void _zoomOut() {
    _zoom(-widget.keyZoomFactor);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}
