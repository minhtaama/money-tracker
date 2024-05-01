import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  String toShortDate(BuildContext context, {ShortDateType? custom, bool noYear = false}) {
    final type = custom ?? context.appSettings.shortDateType;
    final formatter = NumberFormat("00");

    String sDay = formatter.format(day);
    String sYear = noYear ? '' : year.toString();
    String yearSeparator = noYear
        ? ''
        : switch (type) {
            ShortDateType.dmmy || ShortDateType.mmdy || ShortDateType.ydmm || ShortDateType.ymmd => ',',
            ShortDateType.dmy || ShortDateType.mdy || ShortDateType.ydm || ShortDateType.ymd => '/',
          };

    String sMonth = switch (type) {
      ShortDateType.dmmy ||
      ShortDateType.mmdy ||
      ShortDateType.ydmm ||
      ShortDateType.ymmd =>
        monthToString(context, short: true),
      ShortDateType.dmy ||
      ShortDateType.mdy ||
      ShortDateType.ydm ||
      ShortDateType.ymd =>
        formatter.format(month),
    };

    return switch (type) {
      ShortDateType.dmmy => '$sDay $sMonth$yearSeparator $sYear',
      ShortDateType.mmdy => '$sMonth $sDay$yearSeparator $sYear',
      ShortDateType.ydmm => '$sYear$yearSeparator $sDay $sMonth',
      ShortDateType.ymmd => '$sYear$yearSeparator $sMonth $sDay',
      ShortDateType.dmy => '$sDay/$sMonth$yearSeparator$sYear',
      ShortDateType.mdy => '$sMonth/$sDay$yearSeparator$sYear',
      ShortDateType.ydm => '$sYear$yearSeparator$sDay/$sMonth',
      ShortDateType.ymd => '$sYear$yearSeparator$sMonth/$sDay',
    };
  }

  String toLongDate(BuildContext context, {LongDateType? custom, bool noDay = false}) {
    final type = custom ?? context.appSettings.longDateType;

    String sDay = noDay ? '' : dayToString(context);
    String sYear = year.toString();
    String sMonth = monthToString(context);

    return switch (type) {
      LongDateType.dmy => '$sDay $sMonth, $sYear',
      LongDateType.mdy => '$sMonth $sDay, $sYear',
      LongDateType.ydm => '$sYear, $sDay $sMonth',
      LongDateType.ymd => '$sYear, $sMonth $sDay',
    };
  }

  String dayToString(BuildContext context) {
    String sDay = NumberFormat("##").format(day);

    final languageCode = context.appSettings.locale.languageCode;

    if (languageCode == 'vi') {
      return 'ngày $sDay';
    }

    if (languageCode == 'en') {
      String suffix = 'th';

      if (sDay.endsWith('1')) {
        suffix = 'st';
      } else if (sDay.endsWith('2')) {
        suffix = 'nd';
      } else if (sDay.endsWith('3')) {
        suffix = 'rd';
      }

      return '$sDay$suffix';
    }

    return sDay;
  }

  String monthToString(BuildContext context, {bool short = false}) {
    switch (month) {
      case 1:
        return short ? context.loc.jan : context.loc.january;
      case 2:
        return short ? context.loc.feb : context.loc.february;
      case 3:
        return short ? context.loc.mar : context.loc.march;
      case 4:
        return short ? context.loc.apr : context.loc.april;
      case 5:
        return short ? context.loc.may : context.loc.mayLong;
      case 6:
        return short ? context.loc.jun : context.loc.june;
      case 7:
        return short ? context.loc.jul : context.loc.july;
      case 8:
        return short ? context.loc.aug : context.loc.august;
      case 9:
        return short ? context.loc.sep : context.loc.september;
      case 10:
        return short ? context.loc.oct : context.loc.october;
      case 11:
        return short ? context.loc.nov : context.loc.november;
      case 12:
        return short ? context.loc.dec : context.loc.december;
      default:
        return '';
    }
  }

  String weekdayToString(BuildContext context, {bool short = false}) {
    switch (weekday) {
      case 1:
        return short ? context.loc.mon : context.loc.monday;
      case 2:
        return short ? context.loc.tue : context.loc.tuesday;
      case 3:
        return short ? context.loc.wed : context.loc.wednesday;
      case 4:
        return short ? context.loc.thu : context.loc.thursday;
      case 5:
        return short ? context.loc.fri : context.loc.friday;
      case 6:
        return short ? context.loc.sat : context.loc.saturday;
      case 7:
        return short ? context.loc.sun : context.loc.sunday;
      default:
        return '';
    }
  }

  DateTimeRange get dayRange {
    final begin = onlyYearMonthDay;
    final end = copyWith(hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: begin, end: end);
  }

  DateTimeRange weekRange(BuildContext context) {
    final userFirstDay = context.appSettings.firstDayOfWeek;

    final weekDayOfFirstDayOfWeekISO8601 = switch (userFirstDay) {
      FirstDayOfWeek.monday => 1,
      FirstDayOfWeek.sunday => 7,
      FirstDayOfWeek.saturday => 6,
      FirstDayOfWeek.localeDefault => switch (MaterialLocalizations.of(context).firstDayOfWeekIndex) {
          0 => 7, //0: Sun
          1 => 1, //1: Mon,
          2 => 2, //2: Tue
          3 => 3, //3: Wed
          4 => 4, //4: Thu
          5 => 5, //5: Fri
          6 => 6, //6: Sat
          _ => throw StateError('Wrong index of first day of week'),
        },
    };

    final offset = weekday >= weekDayOfFirstDayOfWeekISO8601
        ? weekday - weekDayOfFirstDayOfWeekISO8601
        : weekday - 1 + (8 - weekDayOfFirstDayOfWeekISO8601);

    final firstDay = copyWith(day: day - offset).onlyYearMonthDay;

    final lastDay = firstDay.add(const Duration(days: 6));

    return DateTimeRange(start: firstDay, end: lastDay);
  }

  List<DateTimeRange> weekRangesInMonth(BuildContext context) {
    final monthRange = this.monthRange;
    final result = <DateTimeRange>[];

    DateTime start = monthRange.start;
    int i = 0;

    while (start.isBefore(monthRange.end.onlyYearMonthDay)) {
      final weekRange = start.weekRange(context);
      result.add(weekRange);

      start = weekRange.end.onlyYearMonthDay.copyWith(day: weekRange.end.day + 1);
    }

    return result;
  }

  DateTimeRange get monthRange {
    DateTime dayBeginOfMonth = copyWith(day: 1).onlyYearMonthDay;
    DateTime dayEndOfMonth = copyWith(month: month + 1, day: 0, hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: dayBeginOfMonth, end: dayEndOfMonth);
  }

  DateTimeRange get yearRange {
    DateTime dayBeginOfYear = copyWith(day: 1, month: 1).onlyYearMonthDay;
    DateTime dayEndOfYear = copyWith(year: year + 1, month: 0, day: 0, hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: dayBeginOfYear, end: dayEndOfYear);
  }
}
