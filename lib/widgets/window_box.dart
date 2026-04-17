import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:jade_gallery/color.dart';
import 'package:jade_gallery/shortcuts.dart';
import 'package:jade_gallery/widgets/window_buttons.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WindowBox extends StatelessWidget {
  final String? title;
  final String? logo;
  final Widget? child;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? toolbarColor;

  const WindowBox({
    super.key,
    this.title,
    this.logo = 'images/logo.png',
    this.child,
    this.actions,
    this.backgroundColor,
    this.toolbarColor,
  });

  ThemeData _themeOverrideData(BuildContext context) {
    return Theme.of(context).copyWith(
      iconTheme: const IconThemeData(color: iconColor, size: 18.0),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: iconColor,
          disabledForegroundColor: disabledIconColor,
          enabledMouseCursor: SystemMouseCursors.click,
          iconSize: 18,
          padding: EdgeInsets.all(6),
          minimumSize: Size(0, 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      buttonTheme: ButtonTheme.of(context).copyWith(buttonColor: accentBlue),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (context) =>
            Icon(PhosphorIconsRegular.arrowLeft, color: normalColor, size: 18),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: hoverColor,
          iconColor: hoverColor,
          backgroundColor: accentBlue,
          side: BorderSide(color: accentBlue),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentBlue,
          iconColor: accentBlue,
          side: BorderSide(color: accentBlue),
        ),
      ),
      dividerTheme: DividerTheme.of(context).copyWith(
        color: innerBorderColor,
        thickness: 0.5,
        endIndent: 8,
        indent: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? backgroundStartColor,
      body: GlobalShortcuts(
        child: WindowBorder(
          color: borderColor,
          width: 1,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [backgroundStartColor, backgroundEndColor],
                stops: [0.0, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Title bar
                WindowTitleBarBox(
                  child: Container(
                    color: regionColor,
                    child: Row(
                      children: [
                        if (logo != null)
                          Padding(
                            padding: title == null
                                ? EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  )
                                : EdgeInsets.only(left: 16, top: 4, bottom: 4),
                            child: Image.asset(
                              logo!,
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                        if (title != null)
                          Padding(
                            padding: logo == null
                                ? EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 16,
                                  )
                                : EdgeInsets.only(
                                    left: 8,
                                    right: 16,
                                    top: 4,
                                    bottom: 4,
                                  ),
                            child: Text(
                              title!,
                              style: TextStyle(
                                color: normalColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Expanded(child: MoveWindow()),
                        const WindowButtons(),
                      ],
                    ),
                  ),
                ),

                // Toolbar
                if (actions != null && actions!.isNotEmpty)
                  IntrinsicHeight(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: toolbarColor ?? regionColor,
                        border: BoxBorder.fromLTRB(
                          bottom: BorderSide(color: borderColor),
                        ),
                      ),
                      child: Theme(
                        data: _themeOverrideData(context),
                        child: Row(spacing: 4, children: actions!),
                      ),
                    ),
                  ),

                // Main Content
                DefaultTextStyle(
                  style: TextStyle(color: normalColor, fontSize: 13),
                  child: Expanded(
                    child: Theme(
                      data: _themeOverrideData(context),
                      child: child ?? Center(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
