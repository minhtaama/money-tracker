import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/progress_bar.dart';
import 'package:money_tracker_app/src/common_widgets/progress_circle.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/budget/data/budget_repo.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

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
              .map((budget) => switch (budget.periodType) {
                    BudgetPeriodType.daily =>
                      _DailyBudget(budget: budget, reportPeriod: reportPeriod, dateTimes: dateTimes),
                    BudgetPeriodType.weekly =>
                      _WeeklyBudget(budget: budget, reportPeriod: reportPeriod, dateTimes: dateTimes),
                    BudgetPeriodType.monthly ||
                    BudgetPeriodType.yearly =>
                      _MonthlyAndYearlyBudget(budget: budget, dateTimes: dateTimes),
                  })
              .toList(),
        ),
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

    final colorList = budget is CategoryBudget
        ? (budget as CategoryBudget).categories.map((e) => e.backgroundColor)
        : (budget as AccountBudget).accounts.map((e) => e.backgroundColor);

    return CustomPaint(
      painter: ProgressCircle(
        context,
        currentProgress: budgetDetail.currentAmount / budgetDetail.budget.amount,
        completeColor: context.appTheme.negative,
        completeColors: colorList.toList(),
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
                height: 0.99,
              ),
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
          SizedBox(
            height: 55,
            width: 60,
            child: Center(
              child: Text(
                dateTimes.first.monthToString(context, short: true),
                style: kHeader1TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.65), fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ),
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
          reportPeriod == ReportPeriod.week ? Gap.h12 : Gap.noGap,
          Table(children: _buildTableRow(context, budgetServices)),
        ],
      ),
    );
  }
}

class _WeeklyBudget extends ConsumerWidget {
  const _WeeklyBudget({
    super.key,
    required this.budget,
    required this.reportPeriod,
    required this.dateTimes,
  });

  final BaseBudget budget;
  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  Widget item(BuildContext context, int i, DateTimeRange range, BudgetServices budgetServices) {
    final budgetDetail = budgetServices.getBudgetDetail(context, budget, range.start);

    return Column(
      children: [
        Row(
          children: [
            reportPeriod == ReportPeriod.week
                ? Gap.noGap
                : Text(
                    context.loc.nthWeek((i + 1).toString()),
                    style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
            const Spacer(),
            Text(
              '${range.start.toShortDate(context)} - ${range.end.toShortDate(context)}',
              style: kHeader4TextStyle.copyWith(color: context.appTheme.onBackground.withOpacity(0.65), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        Gap.h4,
        ProgressBar(
          color: context.appTheme.negative,
          percentage: budgetDetail.currentAmount / budgetDetail.budget.amount,
        ),
        Gap.h12,
      ],
    );
  }

  List<Widget> _buildRow(BuildContext context, BudgetServices budgetServices) {
    if (reportPeriod == ReportPeriod.week) {
      return [
        item(context, 0, DateTimeRange(start: dateTimes.first, end: dateTimes.last), budgetServices),
      ];
    } else {
      final rows = <Widget>[];
      final weeks = dateTimes.first.weekRangesInMonth(context);

      for (int i = 0; i < weeks.length; i++) {
        final range = weeks[i];
        rows.add(
          item(context, i, range, budgetServices),
        );
      }

      return rows;
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
          Gap.h12,
          ..._buildRow(context, budgetServices),
        ],
      ),
    );
  }
}

class _MonthlyAndYearlyBudget extends ConsumerWidget {
  const _MonthlyAndYearlyBudget({
    super.key,
    required this.budget,
    required this.dateTimes,
  });

  final BaseBudget budget;
  final List<DateTime> dateTimes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetServices = ref.watch(budgetServicesProvider);
    final budgetDetail = budgetServices.getBudgetDetail(context, budget, dateTimes.first);

    final colorList = budget is CategoryBudget
        ? (budget as CategoryBudget).categories.map((e) => e.backgroundColor)
        : (budget as AccountBudget).accounts.map((e) => e.backgroundColor);

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
      child: Column(
        children: [
          _BudgetHeader(budget: budget),
          Gap.h12,
          Row(
            children: [
              SizedBox(
                height: 150,
                width: 150,
                child: CustomPaint(
                  painter: ProgressCircle(
                    context,
                    currentProgress: budgetDetail.currentAmount / budgetDetail.budget.amount,
                    completeColor: context.appTheme.negative,
                    completeColors: colorList.toList(),
                    strokeWidth: 11,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        budget.periodType == BudgetPeriodType.monthly
                            ? Text(
                                dateTimes.first.monthToString(context),
                                style: kHeader3TextStyle.copyWith(
                                    color: context.appTheme.onBackground.withOpacity(0.65), fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )
                            : Gap.noGap,
                        Text(
                          dateTimes.first.year.toString(),
                          style: kHeader1TextStyle.copyWith(
                            color: context.appTheme.onBackground.withOpacity(0.65),
                            fontSize: 30,
                            height: 0.99,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyAmount(
                    amount: budgetDetail.currentAmount,
                    style: kHeader1TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 25,
                    ),
                  ),
                  MoneyAmount(
                    amount: budgetDetail.budget.amount,
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.onBackground.withOpacity(0.65),
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
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
                    color: cat.backgroundColor,
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
                    color: acc.backgroundColor,
                    size: 20,
                    padding: const EdgeInsets.all(3),
                  ))
              .toList()
            ..insert(
              0,
              SvgIcon(
                AppIcons.accountsBulk,
                color: context.appTheme.onBackground.withOpacity(0.35),
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
      padding: const EdgeInsets.only(bottom: 8.0, top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.name,
                  style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
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
                      context.appSettings.currency.symbol,
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
