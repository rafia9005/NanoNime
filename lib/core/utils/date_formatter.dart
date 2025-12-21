import 'package:intl/intl.dart';

class DateFormatter {
  // Prevent instantiation
  DateFormatter._();

  /// Format a DateTime object to a readable date string
  /// Example: "Jan 15, 2024"
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format a DateTime object to a readable time string
  /// Example: "14:30"
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format a DateTime object to a full date and time string
  /// Example: "Jan 15, 2024 at 14:30"
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy at HH:mm').format(date);
  }

  /// Format a DateTime object to a relative time string
  /// Example: "2 hours ago", "Just now", "Yesterday"
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Parse a date string to DateTime object
  /// Supports various common formats
  static DateTime? parseDate(String dateString) {
    try {
      // Try parsing ISO 8601 format first
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Try common date format
        return DateFormat('MMM dd, yyyy').parse(dateString);
      } catch (e) {
        // Return null if parsing fails
        return null;
      }
    }
  }

  /// Format release date from anime data (handles various formats)
  /// Example input: "Minggu, 15 Jan 2024" or "2024-01-15"
  /// Example output: "Jan 15, 2024"
  static String formatAnimeReleaseDate(String dateString) {
    if (dateString.isEmpty || dateString == '-' || dateString == 'Unknown') {
      return 'Unknown';
    }

    // Try to parse the date
    final parsedDate = parseDate(dateString);
    if (parsedDate != null) {
      return formatDate(parsedDate);
    }

    // If parsing fails, return the original string
    return dateString;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if a date is within the current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Format duration in seconds to readable format
  /// Example: "1h 30m", "45m", "2h 15m 30s"
  static String formatDuration(int seconds, {bool showSeconds = false}) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    final parts = <String>[];
    if (hours > 0) {
      parts.add('${hours}h');
    }
    if (minutes > 0) {
      parts.add('${minutes}m');
    }
    if (showSeconds && secs > 0) {
      parts.add('${secs}s');
    }

    return parts.isEmpty ? '0m' : parts.join(' ');
  }

  /// Format episode duration from string (handles "XX min" format)
  /// Example input: "24 min per ep"
  /// Example output: "24 min"
  static String formatEpisodeDuration(String duration) {
    if (duration.isEmpty || duration == '-' || duration == 'Unknown') {
      return '-';
    }
    // Clean up common patterns
    return duration
        .replaceAll('per ep', '')
        .replaceAll('per episode', '')
        .trim();
  }
}
