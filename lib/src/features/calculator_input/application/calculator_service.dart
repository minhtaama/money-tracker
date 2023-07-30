import 'package:intl/intl.dart';

class CalculatorService {
  static String formatCurrency(double value,
      {bool enableDecimalDigits = false, bool hideNumber = false}) {
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
    formatter = NumberFormat.decimalPatternDigits(decimalDigits: enableDecimalDigits ? 2 : 0);

    if (hideNumber) {
      return '***';
    } else {
      return formatter.format(value);
    }
  }

  static String unformatNumberGrouping(String value) {
    return value.split(',').join();
  }
}
