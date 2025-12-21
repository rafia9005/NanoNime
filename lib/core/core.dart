/// Core layer barrel file
///
/// This file exports all core functionality including constants, theme, and utilities.
/// Import this file to access all core features of the application.
///
/// Example:
/// ```dart
/// import 'package:nanonime/core/core.dart';
///
/// // Access constants
/// AppConstants.appName;
///
/// // Access theme
/// AppTheme.darkTheme;
/// AppColors.primary;
///
/// // Access utilities
/// StringUtils.capitalize('hello');
/// DateFormatter.formatDate(DateTime.now());
/// ```

// Constants
export 'constants/app_constants.dart';

// Theme
export 'theme/colors.dart';
export 'theme/app_theme.dart';

// Utils
export 'utils/date_formatter.dart';
export 'utils/string_utils.dart';
export 'utils/utils.dart';
