import 'package:flutter/material.dart';
import '../theming/app_theme.dart';

class CardItem extends StatelessWidget {
  const CardItem({Key? key, required this.child, this.color}) : super(key: key);
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: color ?? AppTheme.of(context).background2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2, offset: const Offset(1, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(child: child),
        ),
      ),
    );
  }
}
