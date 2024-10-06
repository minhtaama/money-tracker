import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final types = budgetList.map((e) => e.periodType);

    return ReportWrapperSwitcher(
      title: context.loc.budgets,
      showButton: types.contains(BudgetPeriodType.monthly) || types.contains(BudgetPeriodType.yearly),
      firstChild: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        child: Column(
          children: budgetList
              .map<Widget>((budget) => switch (budget.periodType) {
                    BudgetPeriodType.daily =>
                      _DailyBudget(budget: budget, reportPeriod: reportPeriod, dateTimes: dateTimes),
                    BudgetPeriodType.weekly =>
                      _WeeklyBudget(budget: budget, reportPeriod: reportPeriod, dateTimes: dateTimes),
                    BudgetPeriodType.monthly || BudgetPeriodType.yearly => Gap.noGap,
                  })
              .toList(),
        ),
      ),
      secondChild: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 5.0, right: 5.0),
        child: Column(
          children: budgetList
              .map<Widget>((budget) => switch (budget.periodType) {
                    BudgetPeriodType.daily => Gap.noGap,
                    BudgetPeriodType.weekly => Gap.noGap,
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
    required this.budget,
    required this.reportPeriod,
    required this.dateTimes,
  });

  final BaseBudget budget;
  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  Widget _item(BuildContext context, DateTime dateTime, BudgetServices budgetService) {
    final budgetDetail = budgetService.getBudgetDetail(context, budget, dateTime);

    final colorList = budget is CategoryBudget
        ? (budget as CategoryBudget).categories.map((e) => e.backgroundColor)
        : (budget as AccountBudget).accounts.map((e) => e.backgroundColor);

    return ProgressCircle(
      key: ValueKey(dateTime.day),
      duration: k250msDuration,
      currentProgress: budgetDetail.currentAmount / budgetDetail.budget.amount,
      completeColor: context.appTheme.negative,
      completeColors: colorList.toList(),
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

  Widget _notInCurrentMonthItem(BuildContext context, DateTime dateTime) {
    return SizedBox(
      height: 55,
      width: 60,
      child: Center(
        child: Text(
          dateTime.day.toString(),
          style: kHeader2TextStyle.copyWith(
            color: context.appTheme.onBackground.withOpacity(0.55),
            fontSize: 15,
            height: 0.99,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  TableRow _firstTableRow(BuildContext context) {
    final weekRange = dateTimes.first.weekRange(context).toList();

    return TableRow(
      key: const ValueKey('RowAlpha'),
      children: [
        for (DateTime day in weekRange)
          Text(
            day.weekdayToString(context, short: true),
            style: kHeader1TextStyle.copyWith(
              color: day.weekday == 7 ? context.appTheme.negative : context.appTheme.onBackground,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          )
      ],
    );
  }

  List<TableRow> _buildTableRow(BuildContext context, BudgetServices budgetServices) {
    if (reportPeriod == ReportPeriod.week) {
      return [
        _firstTableRow(context),
        TableRow(
          key: const ValueKey('Row2'),
          children: [
            for (int i = dateTimes.first.day; i <= dateTimes.last.day; i++)
              _item(context, dateTimes.first.copyWith(day: i), budgetServices),
          ],
        ),
      ];
    } else {
      final firstWeekRange = dateTimes.first.weekRange(context).toList();
      final secondWeekRange = firstWeekRange.last.add(const Duration(days: 1)).weekRange(context).toList();
      final thirdWeekRange = secondWeekRange.last.add(const Duration(days: 1)).weekRange(context).toList();
      final forthWeekRange = thirdWeekRange.last.add(const Duration(days: 1)).weekRange(context).toList();
      final fifthWeekRange = forthWeekRange.last.add(const Duration(days: 1)).weekRange(context).toList();
      final sixthWeekRange = fifthWeekRange.last.add(const Duration(days: 1)).weekRange(context).toList();

      final result = [
        _firstTableRow(context),
        TableRow(
          key: const ValueKey('Row1A'),
          children: [
            for (DateTime day in firstWeekRange)
              day.month == dateTimes.first.month
                  ? _item(context, day, budgetServices)
                  : _notInCurrentMonthItem(context, day),
          ],
        ),
        TableRow(
          key: const ValueKey('Row2A'),
          children: [
            for (DateTime day in secondWeekRange) _item(context, day, budgetServices),
          ],
        ),
        TableRow(
          key: const ValueKey('Row3A'),
          children: [
            for (DateTime day in thirdWeekRange) _item(context, day, budgetServices),
          ],
        ),
        TableRow(
          key: const ValueKey('Row4A'),
          children: [
            for (DateTime day in forthWeekRange) _item(context, day, budgetServices),
          ],
        ),
        TableRow(
          key: const ValueKey('Row5A'),
          children: [
            for (DateTime day in fifthWeekRange)
              day.month == dateTimes.first.month
                  ? _item(context, day, budgetServices)
                  : _notInCurrentMonthItem(context, day),
          ],
        ),
      ];

      if (sixthWeekRange.first.month == dateTimes.first.month) {
        result.add(
          TableRow(
            key: const ValueKey('Row6A'),
            children: [
              for (DateTime day in sixthWeekRange)
                day.month == dateTimes.first.month
                    ? _item(context, day, budgetServices)
                    : _notInCurrentMonthItem(context, day),
            ],
          ),
        );
      }

      return result;
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
                child: ProgressCircle(
                  duration: k250msDuration,
                  currentProgress: budgetDetail.currentAmount / budgetDetail.budget.amount,
                  completeColor: context.appTheme.negative,
                  completeColors: colorList.toList(),
                  strokeWidth: 11,
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
  const _BudgetHeader({required this.budget});

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
