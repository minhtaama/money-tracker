import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.onTap,
  }) : super(key: key);
  final String title;
  final String icon;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 200,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgIcon(
                    icon,
                    color: context.appTheme.backgroundNegative,
                  ),
                  Gap.w16,
                  Expanded(
                    child: Text(
                      title,
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.backgroundNegative,
                      ),
                    ),
                  ),
                  Text(
                    'See all',
                    style: kHeader3TextStyle.copyWith(
                      fontSize: 13,
                      color: context.appTheme.backgroundNegative.withOpacity(0.6),
                    ),
                  ),
                  Gap.w4,
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: child,
            )
          ],
        ),
      ),
    );
  }
}
