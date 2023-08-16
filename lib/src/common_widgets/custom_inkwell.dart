import 'package:flutter/material.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    Key? key,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    required this.inkColor,
    required this.child,
  }) : super(key: key);
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final Color inkColor;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        // wait for button animation
        await Future.delayed(const Duration(milliseconds: 100));
        onTap != null ? onTap!() : () {};
      },
      onLongPress: onLongPress,
      splashColor: inkColor.opacity == 1 ? inkColor.withOpacity(0.3) : inkColor,
      highlightColor:
          inkColor.opacity == 1 ? inkColor.withOpacity(0.3) : inkColor,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
