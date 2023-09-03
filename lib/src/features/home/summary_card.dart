import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../common_widgets/card_item.dart';
import '../../utils/constants.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.isIncome,
  });

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CardItem(
        color: context.appTheme.isDarkTheme
            ? context.appTheme.background3
            : isIncome
                ? context.appTheme.primary
                : context.appTheme.accent,
        isGradient: true,
        width: double.infinity,
        height: 100,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.backgroundNegative
                  : isIncome
                      ? context.appTheme.primaryNegative
                      : context.appTheme.accentNegative,
              fontSize: 20),
        ),
      ),
    );
  }
}
