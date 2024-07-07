import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../theme_and_ui/colors.dart';

class CardItem extends StatelessWidget {
  /// A common widget for this project
  const CardItem(
      {super.key,
      this.duration,
      this.curve,
      this.child,
      this.color,
      this.height,
      this.width,
      this.constraints,
      this.isGradient = false,
      this.borderRadius,
      this.boxShadow,
      this.border,
      this.margin = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      this.elevation = 0,
      this.clip = true,
      this.alignment});
  final Duration? duration;
  final Curve? curve;
  final Color? color;
  final double? height;
  final double? width;
  final BoxConstraints? constraints;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final bool isGradient;
  final Widget? child;
  final Alignment? alignment;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = context.appTheme.background0;

    return AnimatedContainer(
      duration: duration ?? k350msDuration,
      curve: curve ?? Curves.easeInOut,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? defaultBgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        border: border,
        boxShadow: boxShadow ??
            (elevation == 0
                ? []
                : [
                    BoxShadow(
                      color: AppColors.black.withOpacity(elevation * 0.05 + 0.1),
                      blurRadius: (elevation * 2 + 1).clamp(0, 30),
                      spreadRadius: 0,
                    ),
                  ]),
        gradient: isGradient
            ? LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  color ?? defaultBgColor,
                  Color.lerp(color ?? defaultBgColor, context.appTheme.background2, 0.2)!
                ],
                stops: const [0.15, 1],
              )
            : null,
      ),
      child: ClipRRect(
        clipBehavior: clip ? Clip.antiAliasWithSaveLayer : Clip.none,
        borderRadius: borderRadius?.subtract(BorderRadius.circular(1)) ?? BorderRadius.circular(8),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
