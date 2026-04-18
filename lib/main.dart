import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jade_gallery/color.dart';
import 'package:jade_gallery/constants.dart';
import 'package:jade_gallery/home.dart';
import 'package:jade_gallery/shortcuts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  LicenseRegistry.addLicense(() async* {
    final String license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(<String>['google_fonts'], license);
  });

  runApp(const MyApp());

  doWhenWindowReady(() {
    appWindow.minSize = Size(600, 450);
    appWindow.size = Size(1051, 720);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GlobalShortcuts(
      child: MaterialApp(
        title: appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: accentBlue,
            // brightness: Brightness.dark,
          ),
          // brightness: Brightness.dark,
          // textTheme: GoogleFonts.gothicA1TextTheme(),
        ),
        home: const MainPage(title: appName),
      ),
    );
  }
}
