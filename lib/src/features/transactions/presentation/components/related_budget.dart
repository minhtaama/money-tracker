import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../common_widgets/money_amount.dart';
import '../../../../common_widgets/progress_bar.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../budget/application/budget_services.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../controllers/regular_txn_form_controller.dart';

class RelatedBudget extends ConsumerWidget {
  const RelatedBudget({super.key, required this.transactionType});

  final TransactionType transactionType;

  Widget _budget(BuildContext context, BudgetDetail budgetDetail, RegularTransactionFormState formState) {
    final double percentage = (budgetDetail.currentAmount / budgetDetail.budget.amount).clamp(0, 1);
    final double secondaryPercentage =
        ((budgetDetail.currentAmount + (formState.amount ?? 0)) / budgetDetail.budget.amount).clamp(0, 1);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 1.0, bottom: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  budgetDetail.budget.name,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                MoneyAmount(
                  amount: budgetDetail.currentAmount,
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 12,
                  ),
                ),
                Text(
                  context.appSettings.currency.symbol ?? '',
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground.withOpacity(0.65),
                    fontSize: 10,
                  ),
                ),
                Text(
                  ' / ${CalService.formatCurrency(context, budgetDetail.budget.amount)}',
                  style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.onBackground.withOpacity(0.65),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          ProgressBar(
            key: ValueKey(budgetDetail.budget.name),
            color: context.appTheme.primary,
            secondaryColor: (budgetDetail.currentAmount + (formState.amount ?? 0)) / budgetDetail.budget.amount < 0.8
                ? context.appTheme.positive
                : context.appTheme.negative,
            percentage: percentage,
            secondaryPercentage: secondaryPercentage,
            height: 12,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    assert(transactionType == TransactionType.expense);

    final regularTransactionFormState = ref.watch(regularTransactionFormNotifierProvider(transactionType));

    final budgetService = ref.watch(budgetServicesProvider);

    final list = budgetService.getBudgetDetails(regularTransactionFormState.dateTime ?? DateTime.now()).where(
      (budgetDetail) {
        final budget = budgetDetail.budget;
        return switch (budget) {
          CategoryBudget() => budget.categories.contains(regularTransactionFormState.category),
          AccountBudget() => budget.accounts.contains(regularTransactionFormState.account?.toAccountInfo()),
        };
      },
    );

    return CardItem(
      color: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
      elevation: context.isBigScreen && !context.appTheme.isDarkTheme ? 4.5 : 20,
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          list.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconWithText(
                    forceIconOnTop: true,
                    iconPath: AppIcons.budgets,
                    header: 'Related budget will be shown here',
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Related budget',
                    style: kHeader1TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 15,
                    ),
                  ),
                ),
          ...list.map((e) => _budget(context, e, regularTransactionFormState))
        ],
      ),
    );
  }
}
