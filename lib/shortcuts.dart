import 'package:flutter/cupertino.dart';

typedef ShortcutHandler = void Function();

class ShortcutRegistry extends InheritedWidget {
  final Map<ShortcutActivator, List<ShortcutHandler>> handlers;
  final void Function(ShortcutActivator, ShortcutHandler) register;
  final void Function(ShortcutActivator, ShortcutHandler) unregister;

  const ShortcutRegistry({
    super.key,
    required this.handlers,
    required this.register,
    required this.unregister,
    required super.child,
  });

  static ShortcutRegistry of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShortcutRegistry>()!;
  }

  @override
  bool updateShouldNotify(ShortcutRegistry oldWidget) => false;
}

class GlobalShortcuts extends StatefulWidget {
  final Widget child;
  const GlobalShortcuts({super.key, required this.child});

  @override
  State<GlobalShortcuts> createState() => _GlobalShortcutsState();
}

class _GlobalShortcutsState extends State<GlobalShortcuts> {
  final Map<ShortcutActivator, List<ShortcutHandler>> _handlers = {};

  void _register(ShortcutActivator activator, ShortcutHandler handler) {
    _handlers.putIfAbsent(activator, () => []).add(handler);
    setState(() {}); // rebuild to refresh bindings
  }

  void _unregister(ShortcutActivator activator, ShortcutHandler handler) {
    final list = _handlers[activator];
    if (list != null) {
      list.remove(handler);
      if (list.isEmpty) {
        _handlers.remove(activator);
      }

      // setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        for (final activator in _handlers.keys)
          activator: () {
            for (final handler in _handlers[activator]!) {
              handler();
            }
          },
      },
      child: Focus(
        autofocus: true,
        child: ShortcutRegistry(
          handlers: _handlers,
          register: _register,
          unregister: _unregister,
          child: widget.child,
        ),
      ),
    );
  }
}
