import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nanonime/screen/splash.dart';
import 'package:nanonime/styles/colors.dart';
// endpoint
import 'package:nanonime/screen/navigation.dart';
import 'package:nanonime/screen/auth/login.dart';
import 'package:nanonime/screen/auth/register.dart';
import 'package:nanonime/screen/anime/anime_detail.dart';
import 'package:nanonime/screen/episode/episode_watch.dart';

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
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/": (context) => const NavigationWrapper(),
        "/login": (context) => const AuthLoginScreen(),
        "/register": (context) => const AuthRegisterScreen(),
      },
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? "");
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'anime') {
          final id = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => AnimeDetailScreen(id: id),
            settings: settings,
          );
        }

        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'episode') {
          final id = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => EpisodeWatchScreen(episodeId: id),
            settings: settings,
          );
        }

        return null;
      },
    );
  }
}

class ScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollBar(
    BuildContext context,
    Widget child,
    Scrollable details,
  ) {
    return child;
  }
}
