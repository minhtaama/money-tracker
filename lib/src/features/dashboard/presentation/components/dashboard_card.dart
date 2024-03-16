import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.widthConstraint = true,
  });
  final String title;
  final String icon;
  final VoidCallback? onTap;
  final bool widthConstraint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widthConstraint ? Gap.screenWidth(context) / 2 - 12 : null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: context.appTheme.background0,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              SvgIcon(
                icon,
                color: context.appTheme.onBackground,
                size: 25,
              ),
              Gap.w16,
              Expanded(
                child: Text(
                  title,
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                  ),
                  textAlign: !widthConstraint ? TextAlign.center : null,
                ),
              ),
              !widthConstraint ? const SizedBox(width: 31) : Gap.noGap,
            ],
          ),
        ),
      ),
    );
  }
}
