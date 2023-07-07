import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';
import '../card_item.dart';

class CalKey extends StatelessWidget {
  const CalKey({
    Key? key,
    required this.text,
    required this.onInput,
    this.value,
  }) : super(key: key);
  final String text;
  final String? value;
  final ValueSetter<String> onInput;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.background3,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: InkWell(
        onTap: () => onInput(value ?? text),
        highlightColor: context.appTheme.backgroundNegative.withAlpha(105),
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: Text(
            text,
            style: kHeader2TextStyle,
          ),
        ),
      ),
    );
  }
}
