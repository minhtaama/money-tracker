import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CardItem extends StatelessWidget {
  /// A common widget for this project
  const CardItem(
      {Key? key,
      this.child,
      this.color,
      this.height,
      this.width,
      this.isGradient = false,
      this.borderRadius,
      this.margin = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
      this.elevation = 1})
      : super(key: key);
  final Color? color;
  final double? height;
  final double? width;
  final double elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final bool isGradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = context.appTheme.background3;

    return Padding(
      padding: margin,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 20,
          minWidth: 20,
        ),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color ?? defaultBgColor,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: elevation == 0
              ? null
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
                ],
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
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
