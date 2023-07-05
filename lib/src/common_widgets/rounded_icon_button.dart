import 'package:flutter/material.dart';
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

  double _getSize(GlobalKey key, BuildContext context) {
    final iconRenderBox = key.currentContext?.findRenderObject() as RenderBox;
    return iconRenderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    return label != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CardItem(
                key: key,
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
                  borderCircularRadiusValue: 1000,
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
                    fontSize: size != null ? size! / 4 : _getSize(key, context) / 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          )
        : CardItem(
            key: key,
            width: size ?? 48,
            height: size ?? 48,
            color: backgroundColor,
            padding: EdgeInsets.zero,
            margin: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(1000),
            elevation: 0,
            isGradient: true,
            child: InkWell(
              onTap: () async {
                // wait for button animation
                await Future.delayed(const Duration(milliseconds: 100));
                onTap != null ? onTap!() : () {};
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
