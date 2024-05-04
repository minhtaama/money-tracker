import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/icons.dart';

class EqualKey extends StatelessWidget {
  const EqualKey({
    super.key,
    required this.onEqual,
  });
  final VoidCallback onEqual;

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
        onTap: () => onEqual(),
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: Text('=', style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground)),
        ),
      ),
    );
  }
}

class DoneKey extends StatelessWidget {
  const DoneKey({
    super.key,
    required this.onDone,
  });
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.accent1,
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: () => onDone(),
        inkColor: context.appTheme.onBackground,
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: SvgIcon(
            AppIcons.done,
            color: context.appTheme.onAccent,
            size: 30,
          ),
        ),
      ),
    );
  }
}
