import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class IconWithTextButton extends StatelessWidget {
  const IconWithTextButton({
    super.key,
    required this.iconPath,
    this.label,
    this.subLabel,
    this.labelSize,
    required this.backgroundColor,
    this.height = 55,
    this.width,
    this.padding,
    this.border,
    this.borderRadius,
    this.isDisabled = false,
    this.onTap,
    this.color,
    this.inkColor,
    this.iconSize,
    this.iconScaleUp = false,
  });

  final String iconPath;
  final double? iconSize;
  final bool iconScaleUp;
  final String? label;
  final String? subLabel;
  final double? labelSize;
  final Color backgroundColor;
  final Color? color;
  final Color? inkColor;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      height: height,
      width: width,
      color: isDisabled ? AppColors.greyBgr(context) : backgroundColor,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      border: border,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: onTap,
        inkColor: inkColor ?? color ?? context.appTheme.onPrimary,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform(
                transform: !iconScaleUp
                    ? Matrix4.identity()
                    : (Matrix4.identity()
                      ..scale(1.9)
                      ..translate(-12.0, -3)),
                child: SvgIcon(
                  iconPath,
                  color: isDisabled ? context.appTheme.onBackground : color ?? context.appTheme.onAccent,
                  size: iconSize ?? 28,
                ),
              ),
              label != null ? Gap.w8 : Gap.noGap,
              width != null
                  ? label == null
                      ? Gap.noGap
                      : Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _texts(context),
                          ),
                        )
                  : label == null
                      ? Gap.noGap
                      : Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _texts(context),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: kHeader2TextStyle.copyWith(
            color: isDisabled ? context.appTheme.onBackground : color ?? context.appTheme.onAccent,
            fontSize: labelSize,
          ),
          textAlign: TextAlign.center,
        ),
        subLabel != null
            ? Text(
                subLabel!,
                style: kHeader3TextStyle.copyWith(
                  color: isDisabled ? context.appTheme.onBackground : color ?? context.appTheme.onAccent,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              )
            : Gap.noGap,
      ],
    );
  }
}
