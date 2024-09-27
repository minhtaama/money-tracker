import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/progress_circle.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/budget/data/budget_repo.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/custom_inkwell.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../budget/application/budget_services.dart';
import '../../budget/domain/budget.dart';
import '../../calculator_input/application/calculator_service.dart';

class BudgetReportWidget extends ConsumerWidget {
  const BudgetReportWidget({super.key, required this.reportPeriod, required this.dateTimes});

  final List<DateTime> dateTimes;
  final ReportPeriod reportPeriod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetList = ref.watch(budgetsRepositoryRealmProvider).getList();

    return ReportWrapper(
      title: context.loc.budgets,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        child: Column(
          children: budgetList
              .map((budget) => _DailyBudget(budget: budget, reportPeriod: reportPeriod, dateTimes: dateTimes))
              .toList(),
        ),
        //child: _DailyBudget(budgetDetail: list[0], reportPeriod: reportPeriod, dateTimes: dateTimes),
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({super.key, required this.budget});

  final BaseBudget budget;

  Widget _icons(BuildContext context) {
    return switch (budget) {
      CategoryBudget() => Wrap(
          alignment: WrapAlignment.end,
          children: (budget as CategoryBudget)
              .categories
              .map((cat) => SvgIcon(
                    cat.iconPath,
                    color: context.appTheme.onBackground,
                    size: 20,
                    padding: const EdgeInsets.all(3),
                  ))
              .toList()
            ..insert(
              0,
              SvgIcon(
                AppIcons.categoriesBulk,
                color: context.appTheme.onBackground.withOpacity(0.35),
                padding: const EdgeInsets.only(top: 3, bottom: 3, right: 12),
                size: 20,
              ),
            ),
        ),
      AccountBudget() => Wrap(
          alignment: WrapAlignment.end,
          children: (budget as AccountBudget)
              .accounts
              .map((acc) => SvgIcon(
                    acc.iconPath,
                    color: context.appTheme.onBackground,
                    size: 20,
                    padding: const EdgeInsets.all(3),
                  ))
              .toList()
            ..insert(
              0,
              SvgIcon(
                AppIcons.accountsBulk,
                color: context.appTheme.onBackground,
                padding: const EdgeInsets.only(top: 3, bottom: 3, right: 12),
                size: 20,
              ),
            ),
        )
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.name,
                  style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  textBaseline: TextBaseline.alphabetic,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  children: [
                    Text(
                      CalService.formatCurrency(context, budget.amount),
                      style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                    ),
                    Gap.w4,
                    Text(
                      context.appSettings.currency.code,
                      style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                    ),
                    Text(
                      budget.periodType.asSuffix,
                      style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _icons(context)),
        ],
      ),
    );
  }
}

class _DailyBudget extends ConsumerWidget {
  const _DailyBudget({
    super.key,
    required this.budget,
    required this.reportPeriod,
    required this.dateTimes,
  });

  final BaseBudget budget;
  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  Widget item(BuildContext context, DateTime dateTime, BudgetServices budgetService) {
    final budgetDetail = budgetService.getBudgetDetail(context, budget, dateTime);

    return CustomPaint(
      painter: ProgressCircle(
        context,
        currentProgress: budgetDetail.currentAmount / budgetDetail.budget.amount,
        completeColor: context.appTheme.negative,
      ),
      child: CardItem(
        color: Colors.transparent,
        height: 55,
        width: 60,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: CustomInkWell(
          inkColor: context.appTheme.primary,
          onTap: () {
            HapticFeedback.vibrate();
          },
          child: Center(
            child: Text(
              dateTime.day.toString(),
              style: kHeader2TextStyle.copyWith(
                  color: dateTime.day == DateTime.now().day ? context.appTheme.primary : context.appTheme.onBackground,
                  fontSize: 15,
                  height: 0.99),
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> _buildTableRow(BuildContext context, BudgetServices budgetServices) {
    if (reportPeriod == ReportPeriod.week) {
      return [
        TableRow(
          children: [
            for (int i = dateTimes.first.day; i <= dateTimes.last.day; i++)
              Text(
                dateTimes.first.copyWith(day: i).weekdayToString(context, short: true),
                style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground),
                textAlign: TextAlign.center,
              )
          ],
        ),
        TableRow(
          children: [
            for (int i = dateTimes.first.day; i <= dateTimes.last.day; i++)
              item(context, dateTimes.first.copyWith(day: i), budgetServices),
          ],
        ),
      ];
    } else {
      return [
        TableRow(children: [
          Gap.noGap,
          for (int i = 1; i <= 6; i++) item(context, dateTimes.first.copyWith(day: i), budgetServices)
        ]),
        TableRow(
            children: [for (int i = 7; i <= 13; i++) item(context, dateTimes.first.copyWith(day: i), budgetServices)]),
        TableRow(
            children: [for (int i = 14; i <= 20; i++) item(context, dateTimes.first.copyWith(day: i), budgetServices)]),
        TableRow(
            children: [for (int i = 21; i <= 27; i++) item(context, dateTimes.first.copyWith(day: i), budgetServices)]),
        TableRow(
          children: [
            for (int i = 28; i <= 31; i++)
              i > dateTimes.last.day ? Gap.noGap : item(context, dateTimes.first.copyWith(day: i), budgetServices),
            Gap.noGap,
            Gap.noGap,
            Gap.noGap
          ],
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetServices = ref.watch(budgetServicesProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
      child: Column(
        children: [
          _BudgetHeader(budget: budget),
          Table(children: _buildTableRow(context, budgetServices)),
        ],
      ),
    );
  }
}
