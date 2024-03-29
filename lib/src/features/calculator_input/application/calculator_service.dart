import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CalService {
  static String formatCurrency(BuildContext context, double value,
      {bool forceWithDecimalDigits = false, bool isAbs = false}) {
    NumberFormat formatter;

    if (isAbs) {
      value = value.abs();
    }

    if (value >= 1000000000.0) {
      final shortValue = value / 1000000000;
      formatter = NumberFormat('###,###.##');
      return context.appPersistentValues.showAmount ? '${formatter.format(shortValue)} B' : '***';
    }

    if (value >= 100000000.0) {
      final shortValue = value / 1000000;
      formatter = NumberFormat('###,###.##');
      return context.appPersistentValues.showAmount ? '${formatter.format(shortValue)} M' : '***';
    }

    formatter = NumberFormat.decimalPatternDigits(
        decimalDigits: context.appSettings.showDecimalDigits || forceWithDecimalDigits ? 2 : 0);

    return context.appPersistentValues.showAmount ? formatter.format(value) : '***';
  }

  /// This function takes the argument only in type __String__. It use Regex to find all
  /// the number sequences in the String and replace each sequence with the
  /// grouping thousand formatted sequence, and separate numbers and operators by the space
  /// character. The returned value will be in type __String__
  static String formatNumberInGroup(String value) {
    NumberFormat formatter = NumberFormat("###,###.##");

    if (value == '') {
      return '0';
    }

    String newValue = ' $value'.replaceAllMapped(RegExp(r'([0-9.]+)'), (match) {
      //match[0] returns whole string of this match
      return formatter.format(double.parse(match[0]!));
    });
    return newValue.replaceAllMapped(RegExp(r'[+\-*/]'), (match) => ' ${match[0]} ');
  }

  static String unformatNumberGrouping(String value) {
    return value.split(',').join();
  }

  static double? formatToDouble(String? formattedValue) {
    if (formattedValue == null) {
      return null;
    }

    try {
      double value = double.parse(formattedValue.split(',').join());
      if (value == double.infinity || value == double.negativeInfinity) {
        return null;
      } else {
        return value;
      }
    } catch (e) {
      return null;
    }
  }
}
