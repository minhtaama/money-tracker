import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/progress_bar.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/budget/application/budget_services.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/dashboard/presentation/components/dashboard_widget.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../utils/constants.dart';

class BudgetsWidget extends ConsumerWidget {
  const BudgetsWidget({super.key});

  List<Widget> _itemIcons(BuildContext context, BudgetDetail budgetDetail) {
    final budget = budgetDetail.budget;
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetService = ref.watch(budgetServicesProvider);
    final list = budgetService.getBudgetDetails(context, DateTime.now());

    return DashboardWidget(
      title: 'Budgets'.hardcoded,
      emptyTitle: 'No budgets available'.hardcoded,
      isEmpty: list.isEmpty,
      child: Column(
        children: list.map((e) {
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
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    ..._itemIcons(context, e),
                  ],
                ),
              ),
              ProgressBar(
                color: e.currentAmount / e.budget.amount < 0.8 ? context.appTheme.positive : context.appTheme.negative,
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
                        fontSize: 12,
                      ),
                      symbolStyle: kHeader3TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '/${CalService.formatCurrency(context, e.budget.amount)}',
                      style: kHeader3TextStyle.copyWith(
                        color: context.appTheme.onBackground.withOpacity(0.65),
                        fontSize: 10,
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
      ),
    );
  }
}
