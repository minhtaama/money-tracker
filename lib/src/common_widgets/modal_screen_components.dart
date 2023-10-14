import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'icon_with_text_button.dart';
import 'rounded_icon_button.dart';
import '../theme_and_ui/colors.dart';
import '../theme_and_ui/icons.dart';
import '../utils/constants.dart';

class CurrencyIcon extends StatelessWidget {
  const CurrencyIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: 50,
      width: 50,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: EdgeInsets.zero,
      color: AppColors.greyBgr(context),
      borderRadius: BorderRadius.circular(1000),
      child: FittedBox(
        child: Text(
          context.currentSettings.currency.symbol ?? context.currentSettings.currency.code,
          style: kHeader1TextStyle.copyWith(
            color: context.appTheme.backgroundNegative,
          ),
        ),
      ),
    );
  }
}

class TextHeader extends StatelessWidget {
  const TextHeader(this.text, {super.key, this.fontSize = 15});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          kHeader2TextStyle.copyWith(fontSize: fontSize, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
    );
  }
}

class BottomButtons extends StatelessWidget {
  const BottomButtons(
      {super.key,
      required this.isBigButtonDisabled,
      required this.onBigButtonTap,
      this.smallButtonIcon,
      this.onSmallButtonTap,
      this.bigButtonIcon,
      this.bigButtonLabel});
  final bool isBigButtonDisabled;
  final String? smallButtonIcon;
  final VoidCallback? onSmallButtonTap;
  final String? bigButtonIcon;
  final String? bigButtonLabel;
  final VoidCallback onBigButtonTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundedIconButton(
          iconPath: smallButtonIcon ?? AppIcons.back,
          backgroundColor: context.appTheme.primary,
          iconColor: context.appTheme.primaryNegative,
          size: 55,
          onTap: onSmallButtonTap ?? () => context.pop(),
        ),
        const Spacer(),
        IconWithTextButton(
          iconPath: bigButtonIcon ?? AppIcons.add,
          label: bigButtonLabel ?? 'Add',
          backgroundColor: context.appTheme.accent,
          isDisabled: isBigButtonDisabled,
          onTap: onBigButtonTap,
        ),
      ],
    );
  }
}
