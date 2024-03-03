import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({
    super.key,
    required this.title,
    required this.child,
    this.onTap,
  });
  final String title;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.appTheme.background0,
          borderRadius: BorderRadius.circular(16),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.05),
          //     offset: const Offset(0, 0.05),
          //   ),
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.2),
          //     blurRadius: 0,
          //     spreadRadius: 0.2,
          //     offset: const Offset(0, 0),
          //   ),
          // ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          children: [
            Text(
              title,
              style: kHeader3TextStyle.copyWith(
                color: context.appTheme.onBackground,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
