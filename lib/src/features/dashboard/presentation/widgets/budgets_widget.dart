import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/budget/application/budget_services.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';

class BudgetsWidget extends ConsumerStatefulWidget {
  const BudgetsWidget({super.key});

  @override
  ConsumerState<BudgetsWidget> createState() => _BudgetsWidgetState();
}

class _BudgetsWidgetState extends ConsumerState<BudgetsWidget> {
  @override
  Widget build(BuildContext context) {
    final budgetService = ref.watch(budgetServicesProvider);
    final list = budgetService.getBudgetDetails(DateTime.now());

    return Column(
      children: list.map((e) {
        List<Widget> itemIcons() {
          final budget = e.budget;
          return switch (budget) {
            AccountBudget() => budget.accounts
                .map((e) => Padding(
                      padding: const EdgeInsets.only(left: 1.5),
                      child: RoundedIconButton(
                        iconPath: e.iconPath,
                        iconColor: context.appTheme.onBackground,
                        size: 17,
                        iconPadding: 0,
                      ),
                    ))
                .toList(),
            CategoryBudget() => budget.categories
                .map((e) => Padding(
                      padding: const EdgeInsets.only(left: 1.5),
                      child: RoundedIconButton(
                        iconPath: e.iconPath,
                        iconColor: context.appTheme.onBackground,
                        size: 17,
                        iconPadding: 0,
                      ),
                    ))
                .toList(),
          };
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0, bottom: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    e.budget.name,
                    style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  ...itemIcons(),
                ],
              ),
            ),
            _BudgetBar(
              color: e.currentAmount / e.budget.amount < 0.8
                  ? context.appTheme.positive
                  : context.appTheme.negative,
              percentage: (e.currentAmount / e.budget.amount).clamp(0, 1),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 1.0, top: 5.0, bottom: 10.0),
              child: Row(
                textBaseline: TextBaseline.alphabetic,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                children: [
                  MoneyAmount(
                    amount: e.currentAmount,
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    context.appSettings.currency.symbol ?? '',
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    ' / ${CalService.formatCurrency(context, e.budget.amount)}',
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${DateTime.now().getDaysDifferent(e.range.end)} days left',
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          ],
        );
      }).toList(),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  const _BudgetBar({required this.color, required this.percentage});

  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: double.infinity,
      duration: k250msDuration,
      height: 18,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.greyBgr(context),
        gradient: LinearGradient(
          colors: [color, context.appTheme.onBackground.withOpacity(0.1)],
          stops: [percentage, percentage],
        ),
      ),
    );
  }
}
