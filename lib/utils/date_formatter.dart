import 'package:intl/intl.dart';

/// Locale-aware date formatting.
/// All methods respect the current app locale automatically.
class DateFormatter {
  static String relative(DateTime date, {String? locale}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return _t('today');
    if (diff == 1) return _t('yesterday');
    if (diff < 7) {
      return DateFormat.E(locale).format(date);
    }
    return DateFormat.yMMMd(locale).format(date);
  }

  static String full(DateTime date, {String? locale}) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  static String short(DateTime date, {String? locale}) {
    return DateFormat.MMMd(locale).format(date);
  }

  static String time(DateTime date, {String? locale}) {
    return DateFormat.jm(locale).format(date);
  }

  static String dateTime(DateTime date, {String? locale}) {
    return DateFormat.yMMMd(locale).add_jm().format(date);
  }

  // Simple fallback until ARB localization is wired in Batch 6.
  // In production, these strings come from AppLocalizations.
  static String _t(String key) {
    switch (key) {
      case 'today':
        return 'Today';
      case 'yesterday':
        return 'Yesterday';
      default:
        return key;
    }
  }
}
