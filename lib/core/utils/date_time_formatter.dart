import 'package:intl/intl.dart';

/// Clean, localized date and time formatting utilities for SOMNA.
class DateTimeFormatter {
  DateTimeFormatter._();

  static final DateFormat _timeFormat = DateFormat.jm(); // 11:30 PM
  static final DateFormat _dayOfWeekFormat = DateFormat.E(); // Mon
  static final DateFormat _shortDateFormat = DateFormat('MMM d'); // Oct 26
  static final DateFormat _monthYearFormat =
      DateFormat('MMMM yyyy'); // October 2026
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, yyyy');

  /// Formats time of day, e.g. "11:30 PM".
  static String formatTime(DateTime dt) {
    return _timeFormat.format(dt.toLocal());
  }

  /// Formats short date, e.g. "Oct 26".
  static String formatShortDate(DateTime dt) {
    return _shortDateFormat.format(dt.toLocal());
  }

  /// Formats day of week, e.g. "Mon".
  static String formatDayOfWeek(DateTime dt) {
    return _dayOfWeekFormat.format(dt.toLocal());
  }

  /// Formats month and year, e.g. "October 2026".
  static String formatMonthYear(DateTime dt) {
    return _monthYearFormat.format(dt.toLocal());
  }

  /// Formats full human date, e.g. "Monday, October 26, 2026".
  static String formatFullDate(DateTime dt) {
    return _fullDateFormat.format(dt.toLocal());
  }

  /// Formats minutes into hours and minutes, e.g. "7h 45m" or "42m".
  static String formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  /// Formats a [Duration] into "7h 45m" or "42m".
  static String formatDuration(Duration d) {
    return formatMinutes(d.inMinutes);
  }

  /// Formats elapsed timer into "HH:MM:SS" or "MM:SS".
  static String formatTimer(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  /// Formats relative session context:
  /// - If the session ended today: "Last Night" or "Today"
  /// - If yesterday: "Yesterday"
  /// - Otherwise: "Mon, Oct 26"
  static String formatRelativeDay(DateTime sessionEnd, [DateTime? now]) {
    final current = (now ?? DateTime.now()).toLocal();
    final endLocal = sessionEnd.toLocal();

    final today = DateTime(current.year, current.month, current.day);
    final sessionDay = DateTime(endLocal.year, endLocal.month, endLocal.day);

    final differenceDays = today.difference(sessionDay).inDays;

    if (differenceDays == 0) {
      return 'Last Night';
    } else if (differenceDays == 1) {
      return 'Yesterday';
    } else if (differenceDays < 7) {
      return DateFormat('EEEE').format(endLocal); // e.g. "Friday"
    }
    return DateFormat('EEE, MMM d').format(endLocal);
  }

  /// Formats a session interval:
  /// e.g. "11:15 PM – 7:30 AM" or "Oct 24, 11:15 PM – Oct 25, 7:30 AM"
  static String formatSessionInterval(DateTime start, DateTime? end) {
    final sLocal = start.toLocal();
    final startTimeStr = _timeFormat.format(sLocal);

    if (end == null) {
      return '$startTimeStr – Tracking...';
    }

    final eLocal = end.toLocal();
    final endTimeStr = _timeFormat.format(eLocal);

    if (sLocal.day == eLocal.day &&
        sLocal.month == eLocal.month &&
        sLocal.year == eLocal.year) {
      return '$startTimeStr – $endTimeStr';
    }

    return '$startTimeStr – $endTimeStr (+1d)';
  }
}
