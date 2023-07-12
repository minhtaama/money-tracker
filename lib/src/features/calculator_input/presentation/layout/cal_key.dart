import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../utils/constants.dart';

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
      color: AppColors.darkerGrey,
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
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
            style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 25),
          ),
        ),
      ),
    );
  }
}
