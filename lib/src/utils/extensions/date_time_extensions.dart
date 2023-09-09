import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

extension DateTimeExtensions on DateTime {
  /// Returns [DateTime] without timestamp.

  DateTime get onlyYearMonth => DateTime(year, month);

  int getMonthsDifferent(DateTime date) {
    if (year == date.year) return ((date.month - month).abs() + 1);

    int months = ((date.year - year).abs() - 1) * 12;

    if (date.year >= year) {
      months += date.month + (13 - month);
    } else {
      months += month + (13 - date.month);
    }

    return months;
  }

  String getFormattedDate({
    DateTimeType type = DateTimeType.ddmmyyyy,
    bool hasDay = true,
    bool hasMonth = true,
    bool hasYear = true,
  }) {
    NumberFormat formatter = NumberFormat("00");
    String monthF = hasMonth
        ? switch (type) {
            DateTimeType.ddmmyyyy || DateTimeType.mmddyyyy => formatter.format(month),
            DateTimeType.ddmmmmyyyy || DateTimeType.mmmmddyyyy => _monthString(),
            DateTimeType.ddmmmyyyy || DateTimeType.mmmddyyyy => _monthStringShort(),
          }
        : '';
    String dayF = hasDay ? formatter.format(day) : '';
    String yearF = hasYear ? year.toString() : '';

    switch (type) {
      case DateTimeType.ddmmyyyy:
        return '$dayF${hasDay && hasMonth ? '/' : ''}$monthF${hasMonth && hasYear ? '/' : ''}$yearF';
      case DateTimeType.ddmmmmyyyy || DateTimeType.ddmmmyyyy:
        return '$dayF${hasDay && hasMonth ? ' ' : ''}$monthF${hasYear ? ', ' : ''}$yearF';
      case DateTimeType.mmddyyyy:
        return '$monthF${hasDay && hasMonth ? '/' : ''}$dayF${hasDay && hasYear ? '/' : ''}$yearF';
      case DateTimeType.mmmmddyyyy || DateTimeType.mmmddyyyy:
        return '$monthF${hasDay && hasMonth ? ' ' : ''}$dayF${hasYear ? ', ' : ''}$yearF';
    }
  }

  String _monthString() {
    switch (month) {
      case 1:
        return 'January'.hardcoded;
      case 2:
        return 'February'.hardcoded;
      case 3:
        return 'March'.hardcoded;
      case 4:
        return 'April'.hardcoded;
      case 5:
        return 'May'.hardcoded;
      case 6:
        return 'June'.hardcoded;
      case 7:
        return 'July'.hardcoded;
      case 8:
        return 'August'.hardcoded;
      case 9:
        return 'September'.hardcoded;
      case 10:
        return 'October'.hardcoded;
      case 11:
        return 'November'.hardcoded;
      case 12:
        return 'December'.hardcoded;
      default:
        return '';
    }
  }

  String _monthStringShort() {
    switch (month) {
      case 1:
        return 'JAN'.hardcoded;
      case 2:
        return 'FEB'.hardcoded;
      case 3:
        return 'MAR'.hardcoded;
      case 4:
        return 'APR'.hardcoded;
      case 5:
        return 'MAY'.hardcoded;
      case 6:
        return 'JUN'.hardcoded;
      case 7:
        return 'JUL'.hardcoded;
      case 8:
        return 'AUG'.hardcoded;
      case 9:
        return 'SEP'.hardcoded;
      case 10:
        return 'OCT'.hardcoded;
      case 11:
        return 'NOV'.hardcoded;
      case 12:
        return 'DEC'.hardcoded;
      default:
        return '';
    }
  }

  String weekdayString() {
    switch (weekday) {
      case 1:
        return 'Monday'.hardcoded;
      case 2:
        return 'Tuesday'.hardcoded;
      case 3:
        return 'Wednesday'.hardcoded;
      case 4:
        return 'Thursday'.hardcoded;
      case 5:
        return 'Friday'.hardcoded;
      case 6:
        return 'Saturday'.hardcoded;
      case 7:
        return 'Sunday'.hardcoded;
      default:
        return '';
    }
  }
}
