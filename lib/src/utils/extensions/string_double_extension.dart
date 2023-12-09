// Use .hardcoded on hardcoded string to find it easier
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

extension StringHardCoded on String {
  String get hardcoded => this;
}

extension DoubleExtension on double {
  double roundUsingAppSetting(BuildContext context) {
    if (context.currentSettings.showDecimalDigits) {
      return double.parse(toStringAsFixed(2));
    } else {
      return roundToDouble();
    }
  }
}
