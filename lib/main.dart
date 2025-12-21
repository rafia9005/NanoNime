import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/providers/auth_provider.dart';
import 'package:nanonime/ui/screens/splash.dart';
import 'package:nanonime/core/theme/colors.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final perfs = await SharedPreferences.getInstance();
  final token = perfs.getString('token');
  print(token);
  await dotenv.load(fileName: ".env");
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const Runner(),
    ),
  );
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
