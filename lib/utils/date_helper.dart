class DateHelper {
  const DateHelper._();

  static String todayIso() => isoForDate(DateTime.now());

  static String yesterdayIso() =>
      isoForDate(DateTime.now().subtract(const Duration(days: 1)));

  /// Formats any DateTime as "YYYY-MM-DD".
  static String isoForDate(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}
