/// String manipulation utilities for the Nanonime app
///
/// This file contains helper functions for common string operations
/// used throughout the application.

class StringUtils {
  // Prevent instantiation
  StringUtils._();

  /// Check if a string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.isEmpty;
  }

  /// Check if a string is null, empty, or contains only whitespace
  static bool isNullOrWhitespace(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Capitalize the first letter of a string
  /// Example: "hello world" -> "Hello world"
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize the first letter of each word
  /// Example: "hello world" -> "Hello World"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Truncate a string to a specified length with ellipsis
  /// Example: truncate("Hello World", 8) -> "Hello..."
  static String truncate(
    String text,
    int maxLength, {
    String ellipsis = '...',
  }) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength - ellipsis.length) + ellipsis;
  }

  /// Remove HTML tags from a string
  static String stripHtmlTags(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Convert a string to a URL-friendly slug
  /// Example: "Hello World!" -> "hello-world"
  static String toSlug(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .trim();
  }

  /// Extract numbers from a string
  /// Example: "Episode 12" -> "12"
  static String extractNumbers(String text) {
    return text.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Parse episode number from various formats
  /// Example: "Episode 12", "Ep 12", "12" -> 12
  static int? parseEpisodeNumber(String text) {
    final numbers = extractNumbers(text);
    if (numbers.isEmpty) return null;
    return int.tryParse(numbers);
  }

  /// Format episode title
  /// Example: "episode-12-subtitle" -> "Episode 12: Subtitle"
  static String formatEpisodeTitle(String text) {
    if (text.isEmpty) return text;

    // Replace hyphens and underscores with spaces
    String formatted = text.replaceAll(RegExp(r'[-_]'), ' ');

    // Capitalize first letter of each word
    formatted = capitalizeWords(formatted);

    return formatted;
  }

  /// Remove extra whitespace from a string
  static String removeExtraWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Check if a string contains only digits
  static bool isNumeric(String text) {
    return RegExp(r'^\d+$').hasMatch(text);
  }

  /// Check if a string is a valid email
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  /// Check if a string is a valid URL
  static bool isValidUrl(String url) {
    return RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    ).hasMatch(url);
  }

  /// Format anime ID from URL or path
  /// Example: "/anime/naruto-shippuden" -> "naruto-shippuden"
  static String formatAnimeId(String id) {
    return id.replaceAll(RegExp(r'^/anime/'), '').trim();
  }

  /// Format file size from bytes to human readable format
  /// Example: 1024 -> "1.0 KB", 1048576 -> "1.0 MB"
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Parse quality from string
  /// Example: "1080p", "720p" -> 1080, 720
  static int? parseQuality(String quality) {
    final match = RegExp(r'(\d+)p?').firstMatch(quality.toLowerCase());
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    return null;
  }

  /// Format quality string
  /// Example: "1080" -> "1080p", "720p" -> "720p"
  static String formatQuality(String quality) {
    if (quality.isEmpty) return quality;
    if (quality.endsWith('p')) return quality;
    return '${quality}p';
  }

  /// Clean anime title by removing unnecessary parts
  static String cleanAnimeTitle(String title) {
    return title
        .replaceAll(
          RegExp(r'\s*\([^)]*\)\s*'),
          '',
        ) // Remove parentheses content
        .replaceAll(RegExp(r'\s*\[[^\]]*\]\s*'), '') // Remove brackets content
        .trim();
  }

  /// Extract season and episode from title
  /// Example: "S01E12" -> {"season": 1, "episode": 12}
  static Map<String, int>? extractSeasonEpisode(String text) {
    final match = RegExp(
      r'S(\d+)E(\d+)',
      caseSensitive: false,
    ).firstMatch(text.toUpperCase());

    if (match != null && match.groupCount >= 2) {
      final season = int.tryParse(match.group(1) ?? '');
      final episode = int.tryParse(match.group(2) ?? '');

      if (season != null && episode != null) {
        return {'season': season, 'episode': episode};
      }
    }
    return null;
  }

  /// Pluralize a word based on count
  /// Example: pluralize("episode", 1) -> "episode", pluralize("episode", 2) -> "episodes"
  static String pluralize(String word, int count, {String? plural}) {
    if (count == 1) return word;
    return plural ?? '${word}s';
  }

  /// Generate initials from a name
  /// Example: "John Doe" -> "JD"
  static String getInitials(String name, {int maxLength = 2}) {
    if (name.isEmpty) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase())
        .take(maxLength)
        .join();

    return initials;
  }

  /// Mask sensitive information
  /// Example: maskString("password123", 3) -> "pas*****123"
  static String maskString(String text, int visibleChars) {
    if (text.length <= visibleChars * 2) {
      return '*' * text.length;
    }

    final start = text.substring(0, visibleChars);
    final end = text.substring(text.length - visibleChars);
    final masked = '*' * (text.length - visibleChars * 2);

    return '$start$masked$end';
  }

  /// Convert snake_case to camelCase
  static String snakeToCamel(String text) {
    return text.replaceAllMapped(
      RegExp(r'_([a-z])'),
      (match) => match.group(1)!.toUpperCase(),
    );
  }

  /// Convert camelCase to snake_case
  static String camelToSnake(String text) {
    return text
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }
}
