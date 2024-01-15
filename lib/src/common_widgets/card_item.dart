import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CardItem extends StatelessWidget {
  /// A common widget for this project
  const CardItem(
      {super.key,
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
      this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      this.elevation = 1,
      this.clip = true,
      this.alignment});
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
      duration: k250msDuration,
      curve: Curves.easeOut,
      margin: margin,
      constraints: constraints,
      alignment: alignment,
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? defaultBgColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: border,
        boxShadow: boxShadow ??
            (elevation == 0
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(elevation * 0.1),
                      blurRadius: 0.5 + elevation,
                      spreadRadius: 0.5 * elevation,
                      offset: Offset(0, 1 + elevation),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 0,
                      spreadRadius: 0.2,
                      offset: const Offset(0, 0),
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
        borderRadius: borderRadius?.subtract(BorderRadius.circular(1)) ?? BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
