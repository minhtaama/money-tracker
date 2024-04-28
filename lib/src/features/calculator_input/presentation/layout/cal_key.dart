import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../utils/constants.dart';

class CalKey extends StatelessWidget {
  const CalKey({
    super.key,
    required this.text,
    required this.onInput,
    this.value,
  });
  final String text;
  final String? value;
  final ValueSetter<String> onInput;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: AppColors.greyBgr(context),
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: () => onInput(value ?? text),
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: Text(
            text,
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 25),
          ),
        ),
      ),
    );
  }
}
