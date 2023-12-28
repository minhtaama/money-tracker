import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../utils/constants.dart';
import '../../../common_widgets/card_item.dart';

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
            ? context.appTheme.background0
            : isIncome
                ? context.appTheme.primary
                : context.appTheme.accent1,
        isGradient: true,
        width: double.infinity,
        height: 100,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.onBackground
                  : isIncome
                      ? context.appTheme.onPrimary
                      : context.appTheme.onAccent,
              fontSize: 20),
        ),
      ),
    );
  }
}
