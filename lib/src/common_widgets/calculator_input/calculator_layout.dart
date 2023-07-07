import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../utils/constants.dart';
import 'backspace_key.dart';
import 'cal_key.dart';
import 'equal_key.dart';

class CalculatorLayout extends StatelessWidget {
  const CalculatorLayout({
    Key? key,
    required this.onInput,
    required this.onEqual,
  }) : super(key: key);
  final ValueSetter<String> onInput;
  final VoidCallback onEqual;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      crossAxisCount: 4,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        CalKey(text: '1', onInput: onInput),
        CalKey(text: '2', onInput: onInput),
        CalKey(text: '3', onInput: onInput),
        CalKey(text: '+', onInput: onInput),
        CalKey(text: '4', onInput: onInput),
        CalKey(text: '5', onInput: onInput),
        CalKey(text: '6', onInput: onInput),
        CalKey(text: '-', onInput: onInput),
        CalKey(text: '7', onInput: onInput),
        CalKey(text: '8', onInput: onInput),
        CalKey(text: '9', onInput: onInput),
        CalKey(text: '×', value: '*', onInput: onInput),
        CalKey(text: '0', onInput: onInput),
        CalKey(text: '.', onInput: onInput),
        EqualKey(onEqual: onEqual),
        CalKey(text: '÷', value: '/', onInput: onInput),
      ],
    );
  }
}

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({Key? key, required this.result, required this.onBackspace}) : super(key: key);
  final String result;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 100,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide()),
              ),
              child: Text(
                result,
                style: kHeader1TextStyle,
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Gap.w8,
          BackspaceKey(onBackspace: onBackspace),
        ],
      ),
    );
  }
}
