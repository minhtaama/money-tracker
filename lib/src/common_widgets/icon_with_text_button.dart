import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class IconWithTextButton extends StatelessWidget {
  const IconWithTextButton({
    Key? key,
    required this.iconPath,
    required this.label,
    this.labelSize,
    required this.backgroundColor,
    this.height = 55,
    this.width = 150,
    this.padding,
    this.border,
    this.borderRadius,
    this.isDisabled = false,
    this.onTap,
    this.color,
    this.iconSize,
  }) : super(key: key);

  final String iconPath;
  final double? iconSize;
  final String label;
  final double? labelSize;
  final Color backgroundColor;
  final Color? color;
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
      color: isDisabled ? AppColors.grey(context) : backgroundColor,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      border: border,
      borderRadius: borderRadius ?? BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: CustomInkWell(
        onTap: onTap,
        inkColor: color ?? context.appTheme.primaryNegative,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 14),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgIcon(
                  iconPath,
                  color: isDisabled ? context.appTheme.backgroundNegative : color ?? context.appTheme.accentNegative,
                  size: iconSize ?? 30,
                ),
                Gap.w8,
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: kHeader2TextStyle.copyWith(
                        color:
                            isDisabled ? context.appTheme.backgroundNegative : color ?? context.appTheme.accentNegative,
                        fontSize: labelSize,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
