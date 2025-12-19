import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/screen/splash.dart';
import 'package:nanonime/styles/colors.dart';
// endpoint
import 'package:nanonime/screen/main.dart';
import 'package:nanonime/screen/auth/login.dart';
import 'package:nanonime/screen/auth/register.dart';

void main() {
  runApp(const Runner());
}

class Runner extends StatelessWidget {
  const Runner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nanonime',
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
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/": (context) => const MainScreen(),
        "/login": (context) => const AuthLoginScreen(),
        "/register": (context) => const AuthRegisterScreen(),
      },
    );
  }
}
