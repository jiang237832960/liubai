import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FormatUtils {
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours小时';
    }
    return '$hours小时$mins分钟';
  }

  static String formatDurationShort(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '${hours}h';
    }
    return '${hours}h${mins}m';
  }

  static String formatDurationMs(int milliseconds) {
    return formatDuration((milliseconds / 60000).round());
  }

  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  static String formatDate(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(time.year, time.month, time.day);

    if (date == today) {
      return '今天';
    } else if (date == yesterday) {
      return '昨天';
    } else {
      return DateFormat('M月d日').format(time);
    }
  }

  static String formatDateShort(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.month}/${date.day}';
  }

  static String formatDayOfWeek(String dateStr) {
    final date = DateTime.parse(dateStr);
    const days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return days[date.weekday - 1];
  }

  static String formatPercentage(double value) {
    return '${(value * 100).toInt()}%';
  }

  static int durationToMinutes(Duration duration) {
    return duration.inMinutes;
  }
}

class ColorUtils {
  static int colorToInt(int r, int g, int b) {
    return (0xFF << 24) | (r << 16) | (g << 8) | b;
  }

  static int colorToIntFromColor(Color color) {
    return color.value;
  }
}

class DateTimeUtils {
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }
}
