import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    Key? key,
    this.onTap,
    this.borderRadius,
    required this.inkColor,
    required this.child,
  }) : super(key: key);
  final VoidCallback? onTap;
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
      splashColor: inkColor.withOpacity(0.3),
      highlightColor: Colors.transparent,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
