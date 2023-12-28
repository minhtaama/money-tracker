import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../utils/constants.dart';
import 'backspace_key.dart';
import 'cal_key.dart';
import 'equal_key.dart';

class CalDisplay extends StatelessWidget {
  const CalDisplay({
    Key? key,
    required this.previousExpression,
    required this.result,
  }) : super(key: key);
  final String previousExpression;
  final String result;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            height: 27,
            width: double.infinity,
            child: FittedBox(
              alignment: Alignment.centerRight,
              child: Text(
                previousExpression,
                style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.6)),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              reverse: true,
              child: EasyRichText(
                result,
                defaultStyle: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground),
                textAlign: TextAlign.right,
                patternList: [
                  EasyRichTextPattern(
                    targetString: '[\\+\\-*/]',
                    style: kHeader1TextStyle.copyWith(color: context.appTheme.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeysLayout extends StatelessWidget {
  const KeysLayout({
    Key? key,
    required this.onInput,
    required this.onEqual,
    required this.onBackspace,
    required this.onAC,
    required this.onDone,
  }) : super(key: key);
  final ValueSetter<String> onInput;
  final VoidCallback onEqual;
  final VoidCallback onBackspace;
  final VoidCallback onAC;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ACKey(onAC: onAC),
                CalKey(text: '×', value: '*', onInput: onInput),
                CalKey(text: '÷', value: '/', onInput: onInput),
                BackspaceKey(onBackspace: onBackspace),
              ],
            ),
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
                EqualKey(onEqual: onEqual),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CalKey(text: '0', onInput: onInput),
                CalKey(text: 'k', value: '000', onInput: onInput),
                CalKey(text: '.', onInput: onInput),
                DoneKey(onDone: onDone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
