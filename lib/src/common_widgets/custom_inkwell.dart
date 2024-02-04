import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.inkColor,
    required this.child,
  });
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color? inkColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return onTap != null || onLongPress != null
        ? InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            splashColor: inkColor != null && inkColor!.opacity == 1
                ? inkColor!.withOpacity(0.3)
                : inkColor ?? Colors.transparent,
            highlightColor: inkColor != null && inkColor!.opacity == 1
                ? inkColor!.withOpacity(0.3)
                : inkColor ?? Colors.transparent,
            borderRadius: borderRadius,
            child: child,
          )
        : child;
  }
}
