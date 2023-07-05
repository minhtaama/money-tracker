import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../utils/constants.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    Key? key,
    required this.title,
    required this.iconPath,
    required this.color,
    required this.iconColor,
    this.onTap,
  }) : super(key: key);
  final String title;
  final String iconPath;
  final Color color;
  final Color iconColor;
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
                    iconPath,
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
            const Expanded(child: Text('Other function')),
          ],
        ),
      ),
    );
  }
}
