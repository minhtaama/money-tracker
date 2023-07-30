import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class RoundedIconButton extends StatelessWidget {
  const RoundedIconButton({
    Key? key,
    required this.iconPath,
    this.label,
    required this.backgroundColor,
    this.size,
    this.iconPadding = 12,
    this.onTap,
    this.iconColor,
  }) : super(key: key);

  final String iconPath;
  final String? label;
  final Color backgroundColor;
  final Color? iconColor;
  final double? size;
  final double iconPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return label != null
        ? Column(
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
                child: CustomInkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(10000),
                  inkColor: iconColor ?? context.appTheme.primaryNegative,
                  child: Padding(
                    padding: EdgeInsets.all(iconPadding),
                    child: SvgIcon(
                      iconPath,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Text(
                  label!,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.backgroundNegative,
                    fontSize: size != null ? size! / 4 : 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          )
        : Container(
            width: size ?? 48,
            height: size ?? 48,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(1000),
            ),
            child: InkWell(
              onTap: () async {
                // wait for button animation
                await Future.delayed(const Duration(milliseconds: 100));
                onTap?.call();
              },
              splashColor: (iconColor ?? context.appTheme.primaryNegative).withAlpha(105),
              highlightColor: (iconColor ?? context.appTheme.primaryNegative).withAlpha(105),
              borderRadius: BorderRadius.circular(1000),
              child: Padding(
                padding: EdgeInsets.all(iconPadding),
                child: SvgIcon(
                  iconPath,
                  color: iconColor,
                ),
              ),
            ),
          );
  }
}
