import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../utils/constants.dart';
import 'backspace_key.dart';
import 'cal_key.dart';
import 'equal_key.dart';

class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({Key? key, required this.result}) : super(key: key);
  final String result;

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
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: EasyRichText(
                  result,
                  defaultStyle: kHeader1TextStyle,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  patternList: [
                    EasyRichTextPattern(
                      targetString: '[\\+\\-*/]',
                      style: kHeader1TextStyle.copyWith(color: context.appTheme.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalculatorLayout extends StatelessWidget {
  const CalculatorLayout({
    Key? key,
    required this.onInput,
    required this.onEqual,
    required this.onBackspace,
  }) : super(key: key);
  final ValueSetter<String> onInput;
  final VoidCallback onEqual;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalKey(text: '7', onInput: onInput),
            CalKey(text: '8', onInput: onInput),
            CalKey(text: '9', onInput: onInput),
            CalKey(text: '+', onInput: onInput),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalKey(text: '4', onInput: onInput),
            CalKey(text: '5', onInput: onInput),
            CalKey(text: '6', onInput: onInput),
            CalKey(text: '-', onInput: onInput),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalKey(text: '1', onInput: onInput),
            CalKey(text: '2', onInput: onInput),
            CalKey(text: '3', onInput: onInput),
            CalKey(text: '×', value: '*', onInput: onInput),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CalKey(text: '0', onInput: onInput),
            CalKey(text: '00', onInput: onInput),
            CalKey(text: 'k', value: '000', onInput: onInput),
            CalKey(text: '÷', value: '/', onInput: onInput),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            EqualKey(onEqual: onEqual),
            CalKey(text: '.', onInput: onInput),
            BackspaceKey(onBackspace: onBackspace),
          ],
        ),
      ],
    );
  }
}
