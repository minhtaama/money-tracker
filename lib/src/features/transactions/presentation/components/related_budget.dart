import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/budget/domain/budget.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/money_amount.dart';
import '../../../../common_widgets/progress_bar.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../budget/application/budget_services.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../controllers/regular_txn_form_controller.dart';

class RelatedBudget extends ConsumerStatefulWidget {
  const RelatedBudget({super.key, required this.transactionType});

  final TransactionType transactionType;

  @override
  ConsumerState<RelatedBudget> createState() => _RelatedBudgetState();
}

class _RelatedBudgetState extends ConsumerState<RelatedBudget> {
  bool _showContent = true;

  @override
  Widget build(BuildContext context) {
    assert(widget.transactionType == TransactionType.expense);

    final regularTransactionFormState =
        ref.watch(regularTransactionFormNotifierProvider(widget.transactionType));

    final list = ref
        .watch(budgetServicesProvider)
        .getBudgetDetails(context, regularTransactionFormState.dateTime ?? DateTime.now())
        .where(
      (budgetDetail) {
        final budget = budgetDetail.budget;
        return switch (budget) {
          CategoryBudget() => budget.categories.contains(regularTransactionFormState.category),
          AccountBudget() =>
            budget.accounts.contains(regularTransactionFormState.account?.toAccountInfo()),
        };
      },
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        list.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(4.0),
                child: IconWithText(
                  forceIconOnTop: true,
                  iconPath: AppIcons.budgetsBulk,
                  header: context.loc.relatedBudgetsWillBeShownHere,
                  text: context.loc.tapToHide,
                  onTap: () => setState(() {
                    _showContent = false;
                  }),
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        'Budget(s) at ${(regularTransactionFormState.dateTime ?? DateTime.now()).toShortDate(context)}',
                        style: kHeader2TextStyle.copyWith(
                          color: AppColors.grey(context),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    RoundedIconButton(
                      iconPath: AppIcons.closeLight,
                      size: 23,
                      iconPadding: 3,
                      backgroundColor: Colors.transparent,
                      onTap: () => setState(() {
                        _showContent = false;
                      }),
                    ),
                  ],
                ),
              ),
        ...list.map((e) => _budgetWidget(context, e, regularTransactionFormState))
      ],
    );

    final button = CustomInkWell(
      inkColor: AppColors.grey(context),
      borderRadius: BorderRadius.circular(13),
      onTap: () => setState(() {
        _showContent = true;
      }),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgIcon(
              AppIcons.budgetsBulk,
              color: context.appTheme.onBackground,
              size: 18,
            ),
            Gap.w4,
            Text(
              context.loc.showBudgets,
              style: kHeader2TextStyle.copyWith(
                color: AppColors.grey(context),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );

    return CardItem(
      color: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
      elevation: context.isBigScreen && !context.appTheme.isDarkTheme ? 4.5 : 20,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(6),
      child: AnimatedCrossFade(
        duration: k250msDuration,
        sizeCurve: Curves.fastOutSlowIn,
        firstChild: content,
        secondChild: button,
        crossFadeState: _showContent ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      ),
    );
  }

  Widget _budgetWidget(
      BuildContext context, BudgetDetail budgetDetail, RegularTransactionFormState formState) {
    final double percentage = (budgetDetail.currentAmount / budgetDetail.budget.amount).clamp(0, 1);
    final double secondaryPercentage =
        ((budgetDetail.currentAmount + (formState.amount ?? 0)) / budgetDetail.budget.amount)
            .clamp(0, 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 1.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      budgetDetail.budget.name,
                      style: kHeader2TextStyle.copyWith(
                        color: context.appTheme.onBackground,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Gap.w4,
                  constraints.maxWidth < 300
                      ? Gap.noGap
                      : MoneyAmount(
                          key: ValueKey(budgetDetail.budget.id),
                          amount: budgetDetail.currentAmount + (formState.amount ?? 0),
                          style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground,
                            fontSize: 12,
                          ),
                        ),
                  constraints.maxWidth < 300
                      ? Gap.noGap
                      : Text(
                          context.appSettings.currency.symbol ?? '',
                          style: kHeader3TextStyle.copyWith(
                            color: context.appTheme.onBackground.withOpacity(0.65),
                            fontSize: 10,
                          ),
                        ),
                  constraints.maxWidth < 300
                      ? Gap.noGap
                      : Text(
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
              key: ValueKey(budgetDetail.budget.id),
              color: context.appTheme.primary,
              secondaryColor:
                  (budgetDetail.currentAmount + (formState.amount ?? 0)) / budgetDetail.budget.amount <
                          0.8
                      ? context.appTheme.positive
                      : context.appTheme.negative,
              percentage: percentage,
              secondaryPercentage: secondaryPercentage,
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
