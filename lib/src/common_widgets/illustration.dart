import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/colors.dart';
import '../theme_and_ui/icons.dart';
import '../utils/constants.dart';

class RandomIllustration extends StatelessWidget {
  const RandomIllustration(this.seed, {super.key, required this.text});

  final int seed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final images = [
      AppIcons.undrawCart,
      AppIcons.undrawCoffee,
      AppIcons.undrawCreditCard,
      AppIcons.undrawShopping,
      AppIcons.undrawShopping2,
      AppIcons.undrawSofa,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SvgPicture.asset(
            images[seed % images.length],
            colorFilter: ColorFilter.mode(
                context.appTheme.primary
                    .lerpWithOnBg(context, context.appTheme.isDarkTheme ? 0.25 : 0)
                    .withOpacity(context.appTheme.isDarkTheme ? 0.25 : 0.15),
                BlendMode.srcATop),
            fit: BoxFit.contain,
            height: 110,
            width: 110,
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

class Illustration extends StatelessWidget {
  const Illustration(this.svgPath, {super.key, required this.text});

  final String svgPath;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          SvgPicture.asset(
            svgPath,
            colorFilter: ColorFilter.mode(
                context.appTheme.primary
                    .lerpWithOnBg(context, context.appTheme.isDarkTheme ? 0.25 : 0)
                    .withOpacity(context.appTheme.isDarkTheme ? 0.25 : 0.15),
                BlendMode.srcATop),
            fit: BoxFit.contain,
            height: 110,
            width: 110,
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
