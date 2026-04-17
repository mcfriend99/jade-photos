import 'package:flutter/material.dart' hide ShortcutRegistry;
import '../shortcuts.dart';

mixin Haskeyboardshortcuts<T extends StatefulWidget> on State<T> {
  ShortcutRegistry? shortcutRegistry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shortcutRegistry = ShortcutRegistry.of(context);
  }
}