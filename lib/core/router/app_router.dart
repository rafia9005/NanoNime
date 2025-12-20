/// App Router
///
/// Centralized routing system for the Nanonime application.
/// Provides type-safe navigation methods without complex route definitions.
///
/// Usage:
/// ```dart
/// // Navigate to anime detail
/// AppRouter.toAnimeDetail(context, animeId: 'naruto-shippuden');
///
/// // Navigate to episode
/// AppRouter.toEpisodeWatch(context, episodeId: 'naruto-episode-1');
///
/// // Navigate with replacement
/// AppRouter.toHome(context, replace: true);
/// ```

import 'package:flutter/material.dart';
import '../../ui/screens/splash.dart';
import '../../ui/screens/navigation.dart';
import '../../ui/screens/auth/login.dart';
import '../../ui/screens/auth/register.dart';
import '../../ui/screens/anime/anime_detail.dart';
import '../../ui/screens/episode/episode_watch.dart';

class AppRouter {
  // Prevent instantiation
  AppRouter._();

  // Route names (for reference)
  static const String splash = '/splash';
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String animeDetail = '/anime';
  static const String episodeWatch = '/episode';

  /// Navigate to Splash Screen
  static Future<T?> toSplash<T>(BuildContext context, {bool replace = false}) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  /// Navigate to Home (Navigation Wrapper)
  static Future<T?> toHome<T>(BuildContext context, {bool replace = false}) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NavigationWrapper()),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NavigationWrapper()),
    );
  }

  /// Navigate to Login Screen
  static Future<T?> toLogin<T>(BuildContext context, {bool replace = false}) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
    );
  }

  /// Navigate to Register Screen
  static Future<T?> toRegister<T>(
    BuildContext context, {
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthRegisterScreen()),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthRegisterScreen()),
    );
  }

  /// Navigate to Anime Detail Screen
  static Future<T?> toAnimeDetail<T>(
    BuildContext context, {
    required String animeId,
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AnimeDetailScreen(id: animeId),
          settings: RouteSettings(name: '/anime/$animeId'),
        ),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(id: animeId),
        settings: RouteSettings(name: '/anime/$animeId'),
      ),
    );
  }

  /// Navigate to Episode Watch Screen
  static Future<T?> toEpisodeWatch<T>(
    BuildContext context, {
    required String episodeId,
    bool replace = false,
  }) {
    if (replace) {
      return Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EpisodeWatchScreen(episodeId: episodeId),
          settings: RouteSettings(name: '/episode/$episodeId'),
        ),
      );
    }
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EpisodeWatchScreen(episodeId: episodeId),
        settings: RouteSettings(name: '/episode/$episodeId'),
      ),
    );
  }

  /// Navigate back
  static void back(BuildContext context, [dynamic result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, result);
    }
  }

  /// Navigate back until condition
  static void backUntil(BuildContext context, bool Function(Route) predicate) {
    Navigator.popUntil(context, predicate);
  }

  /// Navigate back to home
  static void backToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  /// Remove all routes and navigate to a new screen
  static Future<T?> removeAllAndNavigate<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }

  /// Remove all routes and navigate to home
  static Future<T?> removeAllAndGoHome<T>(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const NavigationWrapper()),
      (route) => false,
    );
  }

  /// Remove all routes and navigate to login
  static Future<T?> removeAllAndGoLogin<T>(BuildContext context) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
      (route) => false,
    );
  }

  /// Show dialog helper
  static Future<T?> showDialogHelper<T>(BuildContext context, Widget dialog) {
    return showDialog<T>(context: context, builder: (_) => dialog);
  }

  /// Show bottom sheet helper
  static Future<T?> showBottomSheetHelper<T>(
    BuildContext context,
    Widget content,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (_) => content,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }
}
