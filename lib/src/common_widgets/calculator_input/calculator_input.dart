import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../theme_and_ui/colors.dart';
import '../../utils/constants.dart';
import 'package:intl/intl.dart';
import 'calculator_layout.dart';

class CalculatorInput extends StatefulWidget {
  /// This class is the entry point to open a calculator. In this class, the `onFormattedResultOutput`
  /// will return the result (__type String__) formatted with grouping by thousands (separated with ",").
  /// The result is only returned by calculation of the [Calculator] widget.
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
            child: Calculator(
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

class Calculator extends StatefulWidget {
  /// This widget take a __String__ `initialValue` as a value to represent the
  /// current input if user want to update their calculation. By pressing the "=" button,
  /// the function will be calculated and the result will return as an argument in
  /// `formattedResultOutput`.
  const Calculator({Key? key, required this.initialValue, required this.formattedResultOutput})
      : super(key: key);

  /// The initial number value in type __String__. It can be in grouping thousand
  /// format or not in any format. __Must not include any characters other than 0 to 9__
  final String initialValue;

  /// The value returned, which is formatted in thousands grouping and has type __String__
  final ValueSetter<String> formattedResultOutput;

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  /// The mathematical expressions __without any format__ (use for interpreting by function_tree)
  late String _rawString;

  /// The mathematical expressions __with grouping format__ (use for displaying in the widget)
  late String _formattedString;

  @override
  void initState() {
    // Format the initialValue without "," symbol and prevent empty display by displaying "0" number
    _rawString = widget.initialValue.isEmpty ? '0' : _unformatNumberGrouping(widget.initialValue);
    _formattedString = _formatNumberInGroup(_rawString);
    super.initState();
  }

  /// Add a number or a mathematical operator to the expression
  void _add(String value) {
    // Add the value to the mathematical expressions
    _rawString = '$_rawString$value';
    _formattedString = _formatNumberInGroup(_rawString);
    setState(() {});
  }

  /// Delete the latest character in the expression
  void _backspace() {
    if (_rawString.isNotEmpty) {
      _rawString = _rawString.substring(0, _rawString.length - 1);
    }
    // Prevent empty display by displaying "0" number
    if (_rawString.isEmpty) {
      _rawString = '0';
    }
    _formattedString = _formatNumberInGroup(_rawString);
    setState(() {});
  }

  /// Calculate the expression
  void _equal() {
    // Call the interpret() function to calculate the mathematics expression
    final result = _rawString.interpret();
    // Push the result to the callback with grouping format
    widget.formattedResultOutput(_formatNumberInGroup(result));
    // pop!
    context.pop();
  }

  /// This function takes the argument only in type __String__ or __num__.
  ///
  /// When the argument is in type __String__, it use Regex to find all the number sequences
  /// in the String and replace each sequence with the grouping thousand formatted sequence.
  ///
  /// The returned value will be in type __String__
  String _formatNumberInGroup(dynamic value) {
    NumberFormat formatter = NumberFormat.decimalPattern('en_us');
    if (value is String) {
      RegExp exp = RegExp(r'(\d+)');
      return value.replaceAllMapped(exp, (match) {
        //Match[0] returns whole match of the regex.
        return formatter.format(double.parse(match[0]!));
      });
    } else if (value is num) {
      return formatter.format(value);
    } else {
      throw UnsupportedError('value input is not in type String or num');
    }
  }

  /// Delete all "," symbol in the String
  String _unformatNumberGrouping(String value) {
    return value.split(',').join();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CalculatorDisplay(
          result: _formattedString,
          onBackspace: _backspace,
        ),
        Gap.h24,
        CalculatorLayout(
          onInput: _add,
          onEqual: _equal,
        ),
      ],
    );
  }
}
