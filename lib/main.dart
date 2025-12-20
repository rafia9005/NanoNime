import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/ui/screens/splash.dart';
import 'package:nanonime/core/theme/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  runApp(const Runner());
}

class Runner extends StatelessWidget {
  const Runner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nanonime',
      scrollBehavior: ScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,

        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.card,
          onSurface: AppColors.foreground,
          outline: AppColors.border,
          secondary: AppColors.secondary,
        ),

        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme.apply(
            bodyColor: AppColors.foreground,
            displayColor: AppColors.foreground,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  Widget buildScrollBar(
    BuildContext context,
    Widget child,
    Scrollable details,
  ) {
    return child;
  }
}
