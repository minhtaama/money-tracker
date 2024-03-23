// Use .hardcoded on hardcoded string to find it easier
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

extension StringHardCoded on String {
  String get hardcoded => this;

  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension DoubleExtension on double {
  double roundBySetting(BuildContext context) {
    if (context.appSettings.showDecimalDigits) {
      return roundTo2DP();
    } else {
      return roundToDouble();
    }
  }

  double roundTo2DP() => double.parse((this).toStringAsFixed(2));
}
