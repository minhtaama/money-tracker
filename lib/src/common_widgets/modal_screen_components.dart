import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'custom_section.dart';
import 'icon_with_text_button.dart';
import 'rounded_icon_button.dart';
import '../theme_and_ui/colors.dart';
import '../theme_and_ui/icons.dart';
import '../utils/constants.dart';

class ModalHeader extends StatelessWidget {
  const ModalHeader({
    super.key,
    required this.title,
    this.trailing,
    this.secondaryTitle,
  });
  final String title;
  final Widget? trailing;
  final String? secondaryTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ModalRoute.of(context)!.canPop
            ? RoundedIconButton(
                iconPath: AppIcons.back,
                backgroundColor: Colors.transparent,
                iconColor: context.appTheme.onBackground,
                onTap: () => context.pop(),
              )
            : const SizedBox(),
        Gap.w4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: kHeader1TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                  fontSize: 23,
                ),
              ),
              secondaryTitle != null
                  ? Text(
                      secondaryTitle!,
                      style: kNormalTextStyle.copyWith(
                        color: context.appTheme.onBackground.withOpacity(0.8),
                      ),
                    )
                  : Gap.noGap,
            ],
          ),
        ),
        trailing ?? const SizedBox(),
      ],
    );
  }
}

class ModalBody extends StatelessWidget {
  const ModalBody({
    super.key,
    required this.formKey,
    required this.controller,
    required this.header,
    required this.body,
    required this.footer,
  });

  final ScrollController controller;
  final GlobalKey<FormState> formKey;
  final Widget header;
  final List<Widget> body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        Flexible(
          child: SingleChildScrollView(
            controller: controller,
            child: Form(
              key: formKey,
              child: CustomSection(
                crossAxisAlignment: CrossAxisAlignment.start,
                isWrapByCard: false,
                sectionsClipping: false,
                sections: body,
              ),
            ),
          ),
        ),
        footer,
      ],
    );
  }
}

class ModalFooter extends StatelessWidget {
  const ModalFooter({
    super.key,
    required this.isBigButtonDisabled,
    required this.onBigButtonTap,
    this.smallButtonIcon,
    this.onSmallButtonTap,
    this.bigButtonIcon,
    this.bigButtonLabel,
    this.optional,
  });
  final bool isBigButtonDisabled;
  final String? smallButtonIcon;
  final VoidCallback? onSmallButtonTap;
  final String? bigButtonIcon;
  final String? bigButtonLabel;
  final VoidCallback onBigButtonTap;
  final Widget? optional;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        smallButtonIcon != null
            ? RoundedIconButton(
                iconPath: smallButtonIcon ?? AppIcons.back,
                backgroundColor: Colors.transparent,
                iconColor: context.appTheme.primary,
                iconPadding: 10,
                onTap: onSmallButtonTap,
              )
            : Gap.noGap,
        const Spacer(),
        optional ?? Gap.noGap,
        Gap.w16,
        IconWithTextButton(
          iconPath: bigButtonIcon ?? AppIcons.add,
          label: bigButtonLabel ?? 'Add',
          backgroundColor: context.appTheme.accent1,
          isDisabled: isBigButtonDisabled,
          onTap: onBigButtonTap,
          width: 120,
          padding: const EdgeInsets.only(left: 12, right: 18),
        ),
        Gap.w8,
      ],
    );
  }
}

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
          context.appSettings.currency.symbol ?? context.appSettings.currency.code,
          style: kHeader1TextStyle.copyWith(
            color: context.appTheme.onBackground,
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
      style: kHeader2TextStyle.copyWith(fontSize: fontSize, color: context.appTheme.onBackground.withOpacity(0.5)),
    );
  }
}
