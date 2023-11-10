import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../utils/constants.dart';
import 'package:intl/intl.dart';
import 'layout/calculator_layout.dart';

class CalculatorInput extends StatefulWidget {
  /// This class is the entry point to open a calculator. In this class, the `onFormattedResultOutput`
  /// will return the result (__type String__) formatted with grouping by thousands (separated with ",").
  /// The result is only returned by calculation of the [_Calculator] widget.
  const CalculatorInput({
    Key? key,
    this.controller,
    required this.formattedResultOutput,
    required this.focusColor,
    required this.hintText,
    this.initialValue,
    this.disableErrorText = false,
    this.isDense = false,
    this.textAlign = TextAlign.start,
    this.validator,
    this.fontSize = 22,
    //this.initialValue,
  }) : super(key: key);
  final TextEditingController? controller;
  final ValueSetter<String> formattedResultOutput;
  final String? Function(String? value)? validator;
  final Color focusColor;
  final String hintText;
  final String? initialValue;
  final double fontSize;
  final bool disableErrorText;
  final bool isDense;
  final TextAlign textAlign;
  //final double? initialValue;

  @override
  State<CalculatorInput> createState() => _CalculatorInputState();
}

class _CalculatorInputState extends State<CalculatorInput> {
  late String _formattedStringValue;

  late TextEditingController _controller;

  @override
  void initState() {
    _formattedStringValue = '';
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant CalculatorInput oldWidget) {
  //   SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
  //     if (widget.initialValue != null && widget.initialValue != oldWidget.initialValue) {
  //       _formattedStringValue = _formatNumberInGroup(widget.initialValue.toString());
  //       _controller.text = _formattedStringValue;
  //       widget.formattedResultOutput(_formattedStringValue);
  //     }
  //   });
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      validator: widget.validator,
      textAlign: widget.textAlign,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.backgroundNegative,
        fontSize: widget.fontSize,
      ),
      decoration: InputDecoration(
        isDense: widget.isDense,
        focusColor: context.appTheme.primary,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appTheme.backgroundNegative.withOpacity(0.4), width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: widget.focusColor, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: context.appTheme.negative, width: 1),
        ),
        hintText: widget.hintText,
        hintStyle: kHeader2TextStyle.copyWith(
          color: context.appTheme.backgroundNegative.withOpacity(0.5),
          fontSize: 18,
        ),
        errorStyle: widget.disableErrorText
            ? const TextStyle(height: 0.1, color: Colors.transparent, fontSize: 0)
            : kHeader4TextStyle.copyWith(fontSize: 12, color: context.appTheme.negative),
        contentPadding: EdgeInsets.zero,
      ),
      readOnly: true,
      enableInteractiveSelection: false,
      enableSuggestions: false,
      onTap: () {
        showCustomModalBottomSheet(
            context: context,
            //hasHandle: false,
            wrapWithScrollView: true,
            //enableDrag: false,
            child: _Calculator(
              initialValue: _controller.text,
              resultOutput: (value) {
                setState(() {
                  // Replace '0' value with empty to show hint text
                  _formattedStringValue = value == '0' ? '' : value;
                  // Update controller value to display in TextField
                  _controller.text = _formattedStringValue;
                  // Call the callback to return the result value
                  widget.formattedResultOutput(_formattedStringValue);
                });
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
  const _Calculator({Key? key, required this.initialValue, required this.resultOutput}) : super(key: key);

  /// The initial number value in type __String__. It can be in grouping thousand
  /// format or not in any format. __Must not include any characters other than 0 to 9__
  final String initialValue;

  /// The value returned, which has no format and has type __String__
  final ValueChanged<String> resultOutput;

  @override
  State<_Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<_Calculator> {
  /// The mathematical expressions __without any format__ (use for interpreting by function_tree)
  late String _rawString;

  /// The mathematical expressions __with grouping format and spacing around operator__ (use for displaying in the widget)
  late String _formattedString;

  late String _previousExpression;

  @override
  void initState() {
    // Un-format the initialValue (without "," symbol)
    _rawString = widget.initialValue.isEmpty ? '0' : _unformatNumberGrouping(widget.initialValue);

    // Reformat again to display
    _formattedString = _formatNumberInGroup(_rawString);

    _previousExpression = '';

    if (kDebugMode) {
      print('rawString: $_rawString');
      print('formatted: $_formattedString');
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CalDisplay(
            previousExpression: _previousExpression,
            result: _formattedString,
          ),
          Gap.divider(context),
          KeysLayout(
            onInput: _add,
            onEqual: _equal,
            onBackspace: _backspace,
            onAC: _ac,
            onDone: () {
              _equal();
              context.pop();
            },
          ),
          Gap.h16,
        ],
      ),
    );
  }

  void _add(String value) {
    // Adding an operator
    final exp = RegExp(r'[+\-*/]');
    if (exp.hasMatch(value)) {
      // Only add if the latest character is not an operator
      if (!exp.hasMatch(_rawString[_rawString.length - 1])) {
        // calculate...
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
      // Only allow maximum 14 digits
      if (_unformatNumberGrouping(_getCurrentFormattedNumberInput()).length < 14) {
        if (value == '000') {
          if (_unformatNumberGrouping(_getCurrentFormattedNumberInput()).length < 11) {
            _rawString = '$_rawString$value';
          }
        } else {
          _rawString = '$_rawString$value';
        }
      }

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

      _previousExpression = _formattedString;

      // Must reformat then unformat because when user try calculate "122,000.000",
      // we must format `_rawString` to "122000", rather than "122000.0".
      _rawString = _unformatNumberGrouping(_formatNumberInGroup(result)).trim();

      _formattedString = _formatNumberInGroup(_rawString);

      // Push the raw result to the callback
      widget.resultOutput(_formattedString);

      setState(() {});

      if (kDebugMode) {
        print('rawString: $_rawString');
        print('formatted: $_formattedString');
      }
    } catch (_) {
      if (kDebugMode) {
        print(_.toString());
      }
    }
  }

  void _ac() {
    _rawString = '0';
    _formattedString = _formatNumberInGroup(_rawString);
    _previousExpression = '';
    setState(() {});
    if (kDebugMode) {
      print('rawString: $_rawString');
      print('formatted: $_formattedString');
    }
  }

  /// This function takes the argument only in type __String__. It use Regex to find all
  /// the number sequences in the String and replace each sequence with the
  /// grouping thousand formatted sequence, and separate numbers and operators by the space
  /// character. The returned value will be in type __String__
  String _formatNumberInGroup(String value) {
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

  /// Delete all "," symbol in the String
  String _unformatNumberGrouping(String value) {
    return value.split(',').join();
  }

  bool _isLatestNumberHasDot() {
    String latestNumber = _getCurrentFormattedNumberInput();

    if (RegExp(r'\.').hasMatch(latestNumber)) {
      return true;
    } else {
      return false;
    }
  }

  String _getCurrentFormattedNumberInput() {
    // RegExp finds all number sequences has a space character positive look behind
    RegExp exp = RegExp(r'(?<=\s)([0-9,.]+)?');

    // The String input has a space character at 0 index
    final list = exp.allMatches(' $_formattedString').toList();

    return list.isNotEmpty ? list[list.length - 1][0] ?? '' : '';
  }
}
