import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
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
      ShortDateType.dmmy => '$sDay $sMonth$yearSeparator $sYear'.capitalize(),
      ShortDateType.mmdy => '$sMonth $sDay$yearSeparator $sYear'.capitalize(),
      ShortDateType.ydmm => '$sYear$yearSeparator $sDay $sMonth'.capitalize(),
      ShortDateType.ymmd => '$sYear$yearSeparator $sMonth $sDay'.capitalize(),
      ShortDateType.dmy => '$sDay/$sMonth$yearSeparator$sYear'.capitalize(),
      ShortDateType.mdy => '$sMonth/$sDay$yearSeparator$sYear'.capitalize(),
      ShortDateType.ydm => '$sYear$yearSeparator$sDay/$sMonth'.capitalize(),
      ShortDateType.ymd => '$sYear$yearSeparator$sMonth/$sDay'.capitalize(),
    };
  }

  String toLongDate(BuildContext context, {LongDateType? custom, bool noDay = false}) {
    final type = custom ?? context.appSettings.longDateType;

    String sDay = noDay ? '' : dayToString(context);
    String sYear = year.toString();
    String sMonth = monthToString(context);

    return switch (type) {
      LongDateType.dmy => '$sDay $sMonth, $sYear'.capitalize(),
      LongDateType.mdy => '$sMonth $sDay, $sYear'.capitalize(),
      LongDateType.ydm => '$sYear, $sDay $sMonth'.capitalize(),
      LongDateType.ymd => '$sYear, $sMonth $sDay'.capitalize(),
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
        return short ? context.localize.jan : context.localize.january;
      case 2:
        return short ? context.localize.feb : context.localize.february;
      case 3:
        return short ? context.localize.mar : context.localize.march;
      case 4:
        return short ? context.localize.apr : context.localize.april;
      case 5:
        return short ? context.localize.may : context.localize.mayLong;
      case 6:
        return short ? context.localize.jun : context.localize.june;
      case 7:
        return short ? context.localize.jul : context.localize.july;
      case 8:
        return short ? context.localize.aug : context.localize.august;
      case 9:
        return short ? context.localize.sep : context.localize.september;
      case 10:
        return short ? context.localize.oct : context.localize.october;
      case 11:
        return short ? context.localize.nov : context.localize.november;
      case 12:
        return short ? context.localize.dec : context.localize.december;
      default:
        return '';
    }
  }

  String weekdayToString(BuildContext context, {bool short = false}) {
    switch (weekday) {
      case 1:
        return short ? context.localize.mon : context.localize.monday;
      case 2:
        return short ? context.localize.tue : context.localize.tuesday;
      case 3:
        return short ? context.localize.wed : context.localize.wednesday;
      case 4:
        return short ? context.localize.thu : context.localize.thursday;
      case 5:
        return short ? context.localize.fri : context.localize.friday;
      case 6:
        return short ? context.localize.sat : context.localize.saturday;
      case 7:
        return short ? context.localize.sun : context.localize.sunday;
      default:
        return '';
    }
  }

  DateTimeRange get dayRange {
    final begin = onlyYearMonthDay;
    final end = copyWith(hour: 23, minute: 59, second: 59);

    return DateTimeRange(start: begin, end: end);
  }

  DateTimeRange get weekRange {
    // TODO: set first day of week
    final firstDayOfWeek = copyWith(day: day - weekday); //Monday
    final lastDayOfWeek = copyWith(day: day + 7 - weekday, hour: 23, minute: 59, second: 59); //Sunday

    return DateTimeRange(start: firstDayOfWeek, end: lastDayOfWeek);
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
