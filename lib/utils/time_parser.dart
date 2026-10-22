/// Helpers for the "HH:mm" reminder format used across the app.
class TimeParser {
  const TimeParser._();

  /// Parses "HH:mm" into (hour, minute).
  /// Returns null on any malformed input.
  static ({int hour, int minute})? parse(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return (hour: hour, minute: minute);
  }

  /// Formats a time as "HH:mm".
  static String format(int hour, int minute) {
    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }
}
