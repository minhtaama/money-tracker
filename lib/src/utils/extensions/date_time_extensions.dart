import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

extension DateTimeExtensions on DateTime {
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  /// Returns [DateTime] without timestamp.
  DateTime get onlyYearMonth => DateTime(year, month);

  /// Returns [DateTime] without timestamp.
  DateTime get onlyYearMonthDay => DateTime(year, month, day);

  bool isSameMonthAs(DateTime date) {
    return year == date.year && month == date.month;
  }

  bool isInMonthBefore(DateTime date) {
    return year < date.year || year == date.year && month < date.month;
  }

  bool isInMonthAfter(DateTime date) {
    return year > date.year || year == date.year && month > date.month;
  }

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

  int getDaysDifferent(DateTime date) {
    final current = onlyYearMonthDay;
    final until = date.onlyYearMonthDay;

    Duration diff = current.difference(until);

    return diff.inDays.abs();
  }

  String getFormattedDate({
    DateTimeFormat format = DateTimeFormat.ddmmyyyy,
    bool hasDay = true,
    bool hasMonth = true,
    bool hasYear = true,
  }) {
    NumberFormat formatter = NumberFormat("00");
    String monthF = hasMonth
        ? switch (format) {
            DateTimeFormat.ddmmyyyy || DateTimeFormat.mmddyyyy => formatter.format(month),
            DateTimeFormat.ddmmmmyyyy || DateTimeFormat.mmmmddyyyy => _monthString(),
            DateTimeFormat.ddmmmyyyy || DateTimeFormat.mmmddyyyy => _monthStringShort(),
          }
        : '';
    String dayF = hasDay ? formatter.format(day) : '';
    String yearF = hasYear ? year.toString() : '';

    switch (format) {
      case DateTimeFormat.ddmmyyyy:
        return '$dayF${hasDay && hasMonth ? '/' : ''}$monthF${hasMonth && hasYear ? '/' : ''}$yearF';
      case DateTimeFormat.ddmmmmyyyy || DateTimeFormat.ddmmmyyyy:
        return '$dayF${hasDay && hasMonth ? ' ' : ''}$monthF${hasYear ? ', ' : ''}$yearF';
      case DateTimeFormat.mmddyyyy:
        return '$monthF${hasDay && hasMonth ? '/' : ''}$dayF${hasDay && hasYear ? '/' : ''}$yearF';
      case DateTimeFormat.mmmmddyyyy || DateTimeFormat.mmmddyyyy:
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

  String weekdayString([bool short = false]) {
    switch (weekday) {
      case 1:
        return short ? 'MON' : 'Monday'.hardcoded;
      case 2:
        return short ? 'TUE' : 'Tuesday'.hardcoded;
      case 3:
        return short ? 'WED' : 'Wednesday'.hardcoded;
      case 4:
        return short ? 'THU' : 'Thursday'.hardcoded;
      case 5:
        return short ? 'FRI' : 'Friday'.hardcoded;
      case 6:
        return short ? 'SAT' : 'Saturday'.hardcoded;
      case 7:
        return short ? 'SUN' : 'Sunday'.hardcoded;
      default:
        return '';
    }
  }

  DateTimeRange get currentDay {
    final begin = onlyYearMonthDay;
    final end = copyWith(hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: begin, end: end);
  }

  DateTimeRange get currentWeek {
    // TODO: set first day of week
    final firstDayOfWeek = copyWith(day: day - weekday); //Monday
    final lastDayOfWeek = copyWith(day: day + 7 - weekday, hour: 23, minute: 59, second: 59); //Sunday

    return DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
  }

  DateTimeRange get currentMonth {
    DateTime dayBeginOfMonth = copyWith(day: 1).onlyYearMonthDay;
    DateTime dayEndOfMonth = copyWith(month: month + 1, day: 0, hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: dayBeginOfMonth, end: dayEndOfMonth);
  }

  DateTimeRange get currentYear {
    DateTime dayBeginOfYear = copyWith(day: 1, month: 1).onlyYearMonthDay;
    DateTime dayEndOfYear = copyWith(year: year + 1, month: 0, day: 0, hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: dayBeginOfYear, end: dayEndOfYear);
  }
}
