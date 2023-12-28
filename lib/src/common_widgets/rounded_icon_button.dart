import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    super.key,
    required this.iconPath,
    this.label,
    this.labelSize,
    this.backgroundColor,
    this.size,
    this.iconPadding = 12,
    this.onTap,
    this.iconColor,
    this.inkColor,
  });

  final String iconPath;
  final String? label;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? inkColor;
  final double? size;
  final double? labelSize;
  final double iconPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return label != null
        ? ConstrainedBox(
            constraints: BoxConstraints(maxWidth: (size ?? 20) * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CardItem(
                  width: size ?? 24,
                  height: size ?? 24,
                  color: backgroundColor,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(1000),
                  elevation: 0,
                  isGradient: true,
                  child: Material(
                    color: Colors.transparent,
                    child: CustomInkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(10000),
                      inkColor: inkColor ?? iconColor ?? context.appTheme.onPrimary,
                      child: Padding(
                        padding: EdgeInsets.all(iconPadding),
                        child: FittedBox(
                          child: SvgIcon(
                            iconPath,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Text(
                    label!,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: labelSize ?? (size != null ? size! / 4 : 20),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          )
        : SizedBox(
            width: size ?? 48,
            height: size ?? 48,
            child: CardItem(
              color: backgroundColor ?? Colors.transparent,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(1000),
              elevation: 0,
              isGradient: true,
              child: CustomInkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10000),
                inkColor: iconColor ?? AppColors.grey(context),
                child: Padding(
                  padding: EdgeInsets.all(iconPadding),
                  child: FittedBox(
                    child: SvgIcon(
                      iconPath,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
