import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../theme_and_ui/icons.dart';

class DashboardWidget extends StatelessWidget {
  const DashboardWidget({
    super.key,
    required this.title,
    this.emptyTitle,
    this.isEmpty = false,
    required this.child,
    this.onTap,
  });
  final String title;
  final String? emptyTitle;
  final bool isEmpty;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CardItem(
        color: isEmpty ? Colors.transparent : context.appTheme.background0,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appTheme.onBackground.withOpacity(isEmpty ? 0.3 : 0), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: isEmpty
            ? IconWithText(
                header: emptyTitle,
                iconPath: AppIcons.receiptEdit,
                iconSize: 30,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 14,
                    ),
                  ),
                  Gap.h12,
                  child,
                ],
              ),
      ),
    );
  }
}
