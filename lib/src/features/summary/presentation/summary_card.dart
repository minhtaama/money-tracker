import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });
  final String title;
  final String icon;
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
        child: Row(
          children: [
            SvgIcon(
              icon,
              color: context.appTheme.onBackground,
            ),
            Gap.w16,
            Expanded(
              child: Text(
                title,
                style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                ),
              ),
            ),
            Text(
              'See all',
              style: kHeader3TextStyle.copyWith(
                fontSize: 13,
                color: context.appTheme.onBackground.withOpacity(0.6),
              ),
            ),
            Gap.w4,
          ],
        ),
      ),
    );
  }
}
