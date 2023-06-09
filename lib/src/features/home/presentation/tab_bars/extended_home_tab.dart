import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../common_widgets/card_item.dart';

class ExtendedHomeTab extends StatelessWidget {
  const ExtendedHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('extended child tapped'),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        reverse: true,
        children: [
          Gap.h8,
          const TotalMoney(),
          const WelcomeText(),
        ],
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: kOuterChildHeight,
      margin: EdgeInsets.zero,
      color: context.appTheme.isDarkTheme ? context.appTheme.background3 : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgIcon(
            AppIcons.arrowLeft,
            color: context.appTheme.backgroundNegative,
          ),
          Gap.w4,
          FittedBox(
            child: Text(
              'December, 2023'.hardcoded,
              style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
            ),
          ),
          Gap.w4,
          SvgIcon(
            AppIcons.arrowRight,
            color: context.appTheme.backgroundNegative,
          ),
          Gap.w8,
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: SvgIcon(
              AppIcons.filter,
              color: context.appTheme.backgroundNegative,
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, Tâm'.hardcoded,
      style: kHeader2TextStyle.copyWith(
        color: context.appTheme.secondaryNegative,
        fontSize: 18,
      ),
    );
  }
}

class TotalMoney extends StatelessWidget {
  const TotalMoney({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: [
        Text(
          'VND'.hardcoded,
          style: kHeader4TextStyle.copyWith(
            fontWeight: FontWeight.w100,
            color: context.appTheme.secondaryNegative,
            fontSize: 36,
            letterSpacing: -2,
          ),
        ),
        Gap.w8,
        Text(
          '8'.hardcoded,
          style: kHeader1TextStyle.copyWith(
            color: context.appTheme.secondaryNegative,
            fontSize: 36,
          ),
        ),
        Text(
          ',540,000'.hardcoded,
          style: kHeader2TextStyle.copyWith(
            color: context.appTheme.secondaryNegative,
            fontSize: 25,
          ),
        ),
        const Expanded(child: SizedBox()),
        SvgIcon(
          AppIcons.eye,
          color: context.appTheme.secondaryNegative,
        ),
      ],
    );
  }
}
