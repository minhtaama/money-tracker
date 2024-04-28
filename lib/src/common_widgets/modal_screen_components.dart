import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
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
    this.subTitle,
    this.withBackButton = true,
  });
  final String title;
  final Widget? trailing;
  final String? secondaryTitle;
  final Widget? subTitle;
  final bool withBackButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ModalRoute.of(context)!.canPop && withBackButton
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
                    height: 1.2,
                  ),
                ),
                secondaryTitle != null
                    ? Text(
                        secondaryTitle!,
                        style: kHeader3TextStyle.copyWith(
                          color: context.appTheme.onBackground.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      )
                    : Gap.noGap,
                subTitle ?? Gap.noGap,
              ],
            ),
          ),
          trailing ?? const SizedBox(),
        ],
      ),
    );
  }
}

class ModalContent extends StatefulWidget {
  const ModalContent({
    super.key,
    this.formKey,
    this.controller,
    this.isScrollable = false,
    this.onReorder,
    required this.header,
    required this.body,
    required this.footer,
  });

  final ScrollController? controller;
  final bool isScrollable;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final GlobalKey<FormState>? formKey;
  final Widget header;
  final List<Widget> body;
  final Widget footer;

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  final _footerKey = GlobalKey();
  double _footerHeight = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _footerHeight = _footerKey.currentContext!.size!.height;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;
    final padding =
        (MediaQuery.of(context).viewInsets.bottom - _footerHeight - 8 - 12).clamp(0.0, double.infinity);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.header,
        Gap.h12,
        Flexible(
          child: Padding(
            padding: EdgeInsets.only(bottom: padding),
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: widget.controller,
                  child: Form(
                    key: widget.formKey,
                    child: CustomSection(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      onReorder: widget.onReorder,
                      isWrapByCard: false,
                      sectionsClipping: false,
                      sections: widget.body,
                    ),
                  ),
                ),
                Positioned(
                  top: -0.2,
                  left: 0,
                  right: 0,
                  child: _AnimatedFading(
                    isFade: widget.isScrollable,
                    position: _FadingPosition.top,
                  ),
                ),
                Positioned(
                  bottom: -0.2,
                  left: 0,
                  right: 0,
                  child: _AnimatedFading(
                    isFade: widget.isScrollable,
                    position: _FadingPosition.bottom,
                  ),
                ),
              ],
            ),
          ),
        ),
        Gap.h12,
        SizedBox(key: _footerKey, child: widget.footer),
        Gap.h8,
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
  });
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
        Gap.w16,
        smallButtonIcon != null
            ? RoundedIconButton(
                iconPath: smallButtonIcon ?? AppIcons.back,
                backgroundColor: context.appTheme.negative.withOpacity(0.85),
                iconColor: context.appTheme.onNegative,
                iconPadding: 10,
                onTap: onSmallButtonTap,
              )
            : Gap.noGap,
        const Spacer(),
        IconWithTextButton(
          iconPath: bigButtonIcon ?? AppIcons.add,
          label: bigButtonLabel ?? 'Add',
          backgroundColor: context.appTheme.accent1,
          isDisabled: isBigButtonDisabled,
          onTap: onBigButtonTap,
          width: 150,
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
          context.appSettings.currency.symbol,
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
      style: kHeader2TextStyle.copyWith(
          fontSize: fontSize, color: context.appTheme.onBackground.withOpacity(0.5)),
    );
  }
}

class _AnimatedFading extends StatelessWidget {
  const _AnimatedFading({required this.isFade, required this.position});

  final bool isFade;
  final _FadingPosition position;

  @override
  Widget build(BuildContext context) {
    final color =
        context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;

    return IgnorePointer(
      child: AnimatedContainer(
        duration: k250msDuration,
        //height: context.appTheme.isDarkTheme ? 22 : 15,
        height: 10,
        decoration: BoxDecoration(
          color: AppColors.grey(context).withOpacity(isFade ? 1 : 0),
          gradient: LinearGradient(
            begin: position == _FadingPosition.top ? Alignment.topCenter : Alignment.bottomCenter,
            end: position == _FadingPosition.top ? Alignment.bottomCenter : Alignment.topCenter,
            colors: [
              color.withOpacity(isFade ? 0.7 : 0),
              color.withOpacity(0),
            ],
            stops: const [0, 1],
          ),
        ),
      ),
    );
  }
}

enum _FadingPosition {
  top,
  bottom,
}
