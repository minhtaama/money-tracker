import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../theme_and_ui/colors.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import 'layout/calculator_layout.dart';

class CalculatorInput extends StatefulWidget {
  /// This class is the entry point to open a calculator. In this class, the `onFormattedResultOutput`
  /// will return the result (__type String__) formatted with grouping by thousands (separated with ",").
  /// The result is only returned by calculation of the [_Calculator] widget.
  const CalculatorInput(
      {Key? key,
      required this.onFormattedResultOutput,
      required this.focusColor,
      required this.hintText})
      : super(key: key);
  final ValueChanged<String> onFormattedResultOutput;
  final Color focusColor;
  final String hintText;

  @override
  State<CalculatorInput> createState() => _CalculatorInputState();
}

class _CalculatorInputState extends State<CalculatorInput> {
  late String _stringValue;

  late TextEditingController _controller;

  @override
  void initState() {
    _stringValue = '';
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.backgroundNegative,
      ),
      decoration: InputDecoration(
        focusColor: context.appTheme.primary,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.grey, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: widget.focusColor, width: 2),
        ),
        hintText: widget.hintText,
        hintStyle: kHeader2TextStyle.copyWith(
          color: context.appTheme.backgroundNegative.withOpacity(0.5),
          fontSize: 18,
        ),
      ),
      readOnly: true,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        showCustomModalBottomSheet(
            context: context,
            hasHandle: false,
            wrapWithScrollView: false,
            enableDrag: false,
            child: _Calculator(
              initialValue: _stringValue,
              formattedResultOutput: (value) {
                // Replace '0' value with empty to show hint text
                _stringValue = value == '0' ? '' : value;
                // Update controller value to display in TextField
                _controller.text = _stringValue;
                // Call the callback to return the result value
                widget.onFormattedResultOutput(_stringValue);
              },
            ));
      },
    );
  }
}

class _Calculator extends StatefulWidget {
  /// This widget take a __String__ `initialValue` as a value to represent the
  /// current input if user want to update their calculation. By pressing the "=" button,
  /// the function will be calculated and the result will return as an argument in
  /// `formattedResultOutput`.
  const _Calculator({Key? key, required this.initialValue, required this.formattedResultOutput})
      : super(key: key);

  /// The initial number value in type __String__. It can be in grouping thousand
  /// format or not in any format. __Must not include any characters other than 0 to 9__
  final String initialValue;

  /// The value returned, which is formatted in thousands grouping and has type __String__
  final ValueSetter<String> formattedResultOutput;

  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  /// The mathematical expressions __without any format__ (use for interpreting by function_tree)
  late String _rawString;

  /// The mathematical expressions __with grouping format and spacing around operator__ (use for displaying in the widget)
  late String _formattedString;

  @override
  void initState() {
    // Un-format the initialValue (without "," symbol)
    _rawString = widget.initialValue.isEmpty ? '0' : _unformatNumberGrouping(widget.initialValue);

    // Reformat again to display
    _formattedString = _formatNumberInGroup(_rawString);

    if (kDebugMode) {
      print('rawString: $_rawString');
      print('formatted: $_formattedString');
    }

    super.initState();
  }

  void _add(String value) {
    // Adding an operator
    final exp = RegExp(r'[+\-*/]');
    if (exp.hasMatch(value)) {
      // Only add operator if the latest character is not an operator
      if (!exp.hasMatch(_rawString[_rawString.length - 1])) {
        // Calculate the previous mathematical expression
        _equal();
        // Then add the new operator.
        _rawString = '$_rawString$value';
        _formattedString = _formatNumberInGroup(_rawString);
      }
    }

    // Adding a dot
    if (value == '.') {
      if (!_isLatestNumberHasDot()) {
        _rawString = '$_rawString$value';
        _formattedString = '$_formattedString$value';
      }
    }

    // Adding a number
    if (RegExp(r'[0-9]').hasMatch(value)) {
      _rawString = '$_rawString$value';
      if (_isLatestNumberHasDot()) {
        _formattedString = '$_formattedString$value';
      } else {
        _formattedString = _formatNumberInGroup(_rawString);
      }
    }

    setState(() {});

    if (kDebugMode) {
      print('rawString: $_rawString');
      print('formatted: $_formattedString');
    }
  }

  void _backspace() {
    // Delete the _rawString
    if (_rawString.isNotEmpty) {
      _rawString = _rawString.substring(0, _rawString.length - 1);
    }
    if (_rawString.isEmpty) {
      _rawString = '0';
    }

    // Only format if latest number do not have dot
    if (_isLatestNumberHasDot()) {
      _formattedString = _formattedString.substring(0, _formattedString.length - 1);
    } else {
      _formattedString = _formatNumberInGroup(_rawString);
    }

    setState(() {});

    if (kDebugMode) {
      print('rawString: $_rawString');
      print('formatted: $_formattedString');
    }
  }

  /// Calculate the expression
  void _equal() {
    String result;

    // Try calling the interpret() function to calculate the mathematics expression
    try {
      result = _rawString.interpret().toString();

      // Must reformat then unformat because when user try calculate "122,000.000",
      // we must format `_rawString` to "122000", rather than "122000.0".
      _rawString = _unformatNumberGrouping(_formatNumberInGroup(result)).trim();
      _formattedString = _formatNumberInGroup(_rawString);

      // Push the result to the callback with grouping format and trim the String
      widget.formattedResultOutput(_formattedString.trim());

      setState(() {});

      if (kDebugMode) {
        print('rawString: $_rawString');
        print('formatted: $_formattedString');
      }
    } catch (_) {
      if (kDebugMode) {
        print('Error: Mathematical Expression is not correct');
      }
    }
  }

  /// This function takes the argument only in type __String__. It use Regex to find all
  /// the number sequences in the String and replace each sequence with the
  /// grouping thousand formatted sequence, and separate numbers and operators by the space
  /// character. The returned value will be in type __String__
  String _formatNumberInGroup(String value) {
    NumberFormat formatter = NumberFormat.decimalPattern('en_us');

    if (value == '') {
      return '0';
    }

    String newValue = ' $value'.replaceAllMapped(RegExp(r'([0-9.]+)'), (match) {
      //match[0] returns whole string of this match
      return formatter.format(double.parse(match[0]!));
    });
    return newValue.replaceAllMapped(RegExp(r'[+\-*/]'), (match) => ' ${match[0]} ');
  }

  /// Delete all "," symbol in the String
  String _unformatNumberGrouping(String value) {
    return value.split(',').join();
  }

  bool _isLatestNumberHasDot() {
    // RegExp finds all number sequences has a space character positive look behind
    RegExp exp = RegExp(r'(?<=\s)([0-9,.]+)?');

    // The String input to find matches has a space character at 0 index
    final list = exp.allMatches(' $_formattedString').toList();

    String latestNumber = list.isNotEmpty ? list[list.length - 1][0] ?? '' : '';

    if (RegExp(r'\.').hasMatch(latestNumber)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // TODO: Add a small display to show previous mathematical expression
        CalculatorDisplay(
          result: _formattedString,
        ),
        Gap.h24,
        CalculatorLayout(
          onInput: _add,
          onEqual: _equal,
          onBackspace: _backspace,
        ),
      ],
    );
  }
}
