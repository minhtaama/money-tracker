import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    super.key,
    required this.onBackspace,
  });
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.negative,
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: onBackspace,
        inkColor: context.appTheme.onBackground,
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: SvgIcon(
            AppIcons.backspace,
            color: context.appTheme.onNegative,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class ACKey extends StatelessWidget {
  const ACKey({
    super.key,
    required this.onAC,
  });
  final VoidCallback onAC;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.negative,
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: onAC,
        inkColor: context.appTheme.onBackground,
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: Text(
            'AC',
            style: kHeader2TextStyle.copyWith(color: context.appTheme.onNegative),
          ),
        ),
      ),
    );
  }
}
