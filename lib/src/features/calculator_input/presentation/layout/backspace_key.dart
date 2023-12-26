import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    Key? key,
    required this.onBackspace,
  }) : super(key: key);
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
      child: InkWell(
        onTap: onBackspace,
        highlightColor: context.appTheme.negative.withAlpha(105),
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
    Key? key,
    required this.onAC,
  }) : super(key: key);
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
      child: InkWell(
        onTap: onAC,
        highlightColor: context.appTheme.onBackground.withAlpha(105),
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
