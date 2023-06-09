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
      this.margin,
      this.elevation = 1})
      : super(key: key);
  final Color? color;
  final double? height;
  final double? width;
  final double elevation;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final bool isGradient;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final defaultBgColor = Color.lerp(context.appTheme.background2, context.appTheme.secondary, 0.03)!;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                      blurRadius: 2 + elevation,
                      offset: Offset(1, 2 + elevation)),
                ],
          gradient: isGradient
              ? LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    color ?? defaultBgColor,
                    Color.lerp(color ?? defaultBgColor, context.appTheme.background2, 0.35)!
                  ],
                  stops: const [0.15, 1],
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: child ?? SizedBox(),
        ),
      ),
    );
  }
}
