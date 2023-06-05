import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CardItem extends StatelessWidget {
  /// A common widget for this project
  const CardItem({Key? key, required this.child, this.color, this.height, this.width}) : super(key: key);
  final Widget child;
  final Color? color;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 20,
          minWidth: 20,
        ),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: color ?? context.appTheme.background2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(1, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
          child: child,
        ),
      ),
    );
  }
}
