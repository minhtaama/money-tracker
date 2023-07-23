import 'package:intl/intl.dart';

class CalculatorService {
  static String formatCurrency(double value, {bool allowSubCurrency = false}) {
    //TODO: add a variable to modify decimal digits
    NumberFormat formatter;

    if (value >= 1000000000.0) {
      final shortValue = value / 1000000000;
      formatter = NumberFormat('###,###.##');
      return '${formatter.format(shortValue)} B';
    }
    if (value >= 100000000.0) {
      final shortValue = value / 1000000;
      formatter = NumberFormat('###,###.##');
      return '${formatter.format(shortValue)} M';
    }
    formatter = NumberFormat.decimalPatternDigits(decimalDigits: allowSubCurrency ? 2 : 0);
    return formatter.format(value);
  }

  static String unformatNumberGrouping(String value) {
    return value.split(',').join();
  }
}
