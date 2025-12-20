/// Application-wide constants
///
/// This file contains all constant values used throughout the app
/// such as API endpoints, configuration values, and other immutable data.

class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'Nanonime';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Watch anime streaming app';

  // API Configuration
  // Note: API_URL is loaded from .env file via flutter_dotenv
  // Use ApiService.baseUrl for runtime access to the API URL

  // Asset Paths
  static const String assetsPath = 'assets';
  static const String imagesPath = '$assetsPath/images';
  static const String iconsPath = '$assetsPath/icons';
  static const String fontsPath = '$assetsPath/fonts';

  // Timing & Animation
  static const int splashDuration = 3000; // milliseconds
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 3.0;

  // Grid Configuration
  static const double gridMaxCrossAxisExtent = 180.0;
  static const double gridMainAxisSpacing = 12.0;
  static const double gridCrossAxisSpacing = 12.0;
  static const double gridChildAspectRatio = 0.60;

  // Network & Cache
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration cacheExpiration = Duration(hours: 1);

  // Routes
  static const String splashRoute = '/splash';
  static const String homeRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String animeDetailRoute = '/anime';
  static const String episodeWatchRoute = '/episode';
  static const String searchRoute = '/search';
  static const String settingsRoute = '/settings';

  // Error Messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String unknownErrorMessage = 'An unknown error occurred';
  static const String noDataMessage = 'No data available';
  static const String loadingMessage = 'Loading...';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Video Player
  static const double defaultVideoAspectRatio = 16 / 9;
  static const double maxVideoLoadingRetries = 3;
}
