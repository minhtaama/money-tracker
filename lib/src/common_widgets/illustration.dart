import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/colors.dart';
import '../theme_and_ui/icons.dart';
import '../utils/constants.dart';
import 'card_item.dart';
import 'icon_with_text.dart';

class RandomIllustration extends StatelessWidget {
  const RandomIllustration(this.seed, {super.key, required this.text});

  final int seed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final images = [
      AppIcons.alienTwoTone,
      AppIcons.starTwoTone,
      AppIcons.deliveryTwoTone,
      AppIcons.heartBreakTwoTone,
      AppIcons.cartTwoTone,
      AppIcons.bagsTwoTone,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SvgPicture.asset(
            images[seed % images.length],
            colorFilter: ColorFilter.mode(
                context.appTheme.accent2.withOpacity(context.appTheme.isDarkTheme ? 0.35 : 0.55), BlendMode.srcATop),
            fit: BoxFit.contain,
            height: 55,
            width: 55,
          ),
          Gap.h24,
          Text(
            text,
            style: kHeader2TextStyle.copyWith(color: AppColors.grey(context), fontSize: 14),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}

class EmptyIllustration extends StatelessWidget {
  const EmptyIllustration(this.svgPath, this.text, {super.key, this.verticalPadding = 32});

  final String svgPath;
  final String text;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      color: Colors.transparent,
      clip: false,
      border: Border.all(color: context.appTheme.onBackground.withOpacity(0.3), width: 2),
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: verticalPadding),
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: IconWithText(
        header: text,
        iconPath: svgPath,
        iconSize: 30,
      ),
    );
  }
}
