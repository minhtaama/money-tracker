import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/custom_inkwell.dart';
import '../../../common_widgets/modal_and_dialog.dart';
import '../../../common_widgets/money_amount.dart';
import '../../../common_widgets/svg_icon.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/constants.dart';
import '../../charts_and_carousel/application/custom_pie_chart_services.dart';
import '../../charts_and_carousel/presentation/custom_pie_chart.dart';

class CategoryReport extends StatelessWidget {
  const CategoryReport({super.key, required this.reportPeriod, required this.dateTimes});

  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  @override
  Widget build(BuildContext context) {
    return ReportWrapperSwitcher(
      title: context.loc.categories,
      firstChild: _CategoryReportSmall(reportPeriod: reportPeriod, dateTimes: dateTimes),
      secondChild: _CategoryReportDetails(reportPeriod: reportPeriod, dateTimes: dateTimes),
    );
  }
}

class _CategoryReportSmall extends ConsumerStatefulWidget {
  const _CategoryReportSmall({super.key, required this.reportPeriod, required this.dateTimes});

  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  @override
  ConsumerState<_CategoryReportSmall> createState() => _CategoryReportSmallState();
}

class _CategoryReportSmallState extends ConsumerState<_CategoryReportSmall> {
  late final _pieServices = ref.read(customPieChartServicesProvider);

  late List<MapEntry<Category, double>> _pieExpenseData = _pieServices.getExpenseData(
    dateTime: widget.dateTimes.first,
    dateTime2: widget.dateTimes.last,
  );

  late List<MapEntry<Category, double>> _pieIncomeData = _pieServices.getIncomeData(
    context,
    dateTime: widget.dateTimes.first,
    dateTime2: widget.dateTimes.last,
  );

  late List<MapEntry<Category, double>> _listExpenseData = _pieServices.getExpenseData(
    dateTime: widget.dateTimes.first,
    dateTime2: widget.dateTimes.last,
    useOther: false,
  );

  late List<MapEntry<Category, double>> _listIncomeData = _pieServices.getIncomeData(
    context,
    dateTime: widget.dateTimes.first,
    dateTime2: widget.dateTimes.last,
    useOther: false,
  );

  late double _totalExpense = _pieServices.getExpenseAmount(
    widget.dateTimes.first,
    widget.dateTimes.last,
  );
  late double _totalIncome = _pieServices.getIncomeAmount(
    widget.dateTimes.first,
    widget.dateTimes.last,
  );

  @override
  void didUpdateWidget(covariant _CategoryReportSmall oldWidget) {
    if (widget.dateTimes != oldWidget.dateTimes) {
      setState(() {
        _pieExpenseData = _pieServices.getExpenseData(
          dateTime: widget.dateTimes.first,
          dateTime2: widget.dateTimes.last,
        );
        _pieIncomeData = _pieServices.getIncomeData(
          context,
          dateTime: widget.dateTimes.first,
          dateTime2: widget.dateTimes.last,
        );
        _listExpenseData = _pieServices.getExpenseData(
          dateTime: widget.dateTimes.first,
          dateTime2: widget.dateTimes.last,
          useOther: false,
        );
        _listIncomeData = _pieServices.getIncomeData(
          context,
          dateTime: widget.dateTimes.first,
          dateTime2: widget.dateTimes.last,
          useOther: false,
        );
        _totalExpense = _pieServices.getExpenseAmount(
          widget.dateTimes.first,
          widget.dateTimes.last,
        );
        _totalIncome = _pieServices.getIncomeAmount(
          widget.dateTimes.first,
          widget.dateTimes.last,
        );

        _touchedIndexExpense = -1;
        _touchedIndexIncome = -1;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  int _touchedIndexExpense = -1;

  int _touchedIndexIncome = -1;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _pieChart(
                  _pieExpenseData,
                  isExpense: true,
                  touchedIndex: _touchedIndexExpense,
                  onChartTap: (index) {
                    if (_touchedIndexExpense == index || index == -1) {
                      setState(() {
                        _touchedIndexExpense = -1;
                        _touchedIndexIncome = -1;
                      });
                    } else {
                      setState(() {
                        _touchedIndexIncome = -2;
                        _touchedIndexExpense = index;
                      });
                    }
                  },
                ),
              ),
              Gap.w24,
              Expanded(
                child: _pieChart(
                  _pieIncomeData,
                  isExpense: false,
                  touchedIndex: _touchedIndexIncome,
                  onChartTap: (index) {
                    if (_touchedIndexIncome == index || index == -1) {
                      setState(() {
                        _touchedIndexExpense = -1;
                        _touchedIndexIncome = -1;
                      });
                    } else {
                      setState(() {
                        _touchedIndexExpense = -2;
                        _touchedIndexIncome = index;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          Gap.h12,
          ..._labels(
            _listExpenseData,
            _listIncomeData,
            _totalExpense,
            _totalIncome,
            onTap: (category) {
              showCustomModal(
                context: context,
                builder: (controller, isScrollable) {
                  final transactionRepo = ref.read(transactionRepositoryRealmProvider);
                  final transactions = transactionRepo
                      .getTransactions(widget.dateTimes.first, widget.dateTimes.last)
                      .where((txn) =>
                          txn is IBaseTransactionWithCategory &&
                          (txn as IBaseTransactionWithCategory).category == category)
                      .toList();

                  return TransactionsModalScreen(
                    controller,
                    isScrollable,
                    transactions: transactions,
                    dayBeginOfMonth: widget.dateTimes.first,
                    dayEndOfMonth: widget.dateTimes.last,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _labels(
    List<MapEntry<Category, double>> expenseList,
    List<MapEntry<Category, double>> incomeList,
    double totalExpense,
    double totalIncome, {
    required void Function(Category) onTap,
  }) {
    Widget label(MapEntry<Category, double> e, {required bool Function() isTouched}) => CustomInkWell(
          onTap: () => onTap(e.key),
          inkColor: context.appTheme.onBackground,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: e.key.backgroundColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                Gap.w4,
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: k250msDuration,
                    style: kHeader4TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 14,
                      fontFamily: 'WixMadeforDisplay',
                      fontWeight: isTouched() ? FontWeight.w800 : null,
                    ),
                    child: Text(
                      e.key.name,
                    ),
                  ),
                ),
                MoneyAmount(
                  amount: e.value,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );

    Widget header(String text, double amount) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: kHeader4TextStyle.copyWith(
                    color: context.appTheme.onBackground.withOpacity(0.65),
                    fontSize: 14,
                    height: 0.99,
                  ),
                ),
              ),
              MoneyAmount(
                amount: amount,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.65),
                  fontSize: 14,
                  height: 0.99,
                ),
              ),
            ],
          ),
        );

    if (expenseList.isEmpty && incomeList.isEmpty) {
      return [];
    }

    final result = <Widget>[];

    final expenseLabels = expenseList
        .map((e) => label(
              e,
              isTouched: () {
                final touchedIndex = _touchedIndexExpense;

                if (touchedIndex < 0) {
                  return false;
                }

                final elIndex = expenseList.indexOf(e);
                final listLength = _listExpenseData.length;
                final pieLength = _pieExpenseData.length;

                if (listLength > pieLength) {
                  if (touchedIndex >= pieLength - 1 && elIndex >= pieLength - 1) {
                    return true;
                  }
                }

                return elIndex == touchedIndex;
              },
            ))
        .toList();

    final incomeLabels = incomeList
        .map((e) => label(
              e,
              isTouched: () {
                final touchedIndex = _touchedIndexIncome;

                if (touchedIndex < 0) {
                  return false;
                }

                final elIndex = incomeList.indexOf(e);
                final listLength = _listIncomeData.length;
                final pieLength = _pieIncomeData.length;

                if (listLength > pieLength) {
                  if (touchedIndex >= pieLength - 1 && elIndex >= pieLength - 1) {
                    return true;
                  }
                }

                return elIndex == touchedIndex;
              },
            ))
        .toList();

    if (expenseLabels.isNotEmpty) {
      result.addAll([
        header(context.loc.expense, totalExpense),
        Gap.divider(context, indent: 6),
        ...expenseLabels,
      ]);
    }

    if (expenseLabels.isNotEmpty && incomeLabels.isNotEmpty) {
      result.add(Gap.h16);
    }

    if (incomeLabels.isNotEmpty) {
      result.addAll([
        header(context.loc.income, totalIncome),
        Gap.divider(context, indent: 6),
        ...incomeLabels,
      ]);
    }

    return result;
  }

  Widget _pieChart(List<MapEntry<Category, double>> list,
      {required bool isExpense, int? touchedIndex, void Function(int)? onChartTap}) {
    return SizedBox(
      height: 150,
      child: CustomPieChart<Category>(
        key: ValueKey(list.toString()),
        values: list,
        center: SvgIcon(
          isExpense ? AppIcons.uploadLight : AppIcons.downloadLight,
          color: isExpense
              ? context.appTheme.negative.withOpacity(0.65)
              : context.appTheme.positive.withOpacity(0.65),
          size: 25,
        ),
        onChartTap: onChartTap,
        touchedIndex: touchedIndex,
      ),
    );
  }
}

class _CategoryReportDetails extends ConsumerStatefulWidget {
  const _CategoryReportDetails({super.key, required this.reportPeriod, required this.dateTimes});

  final ReportPeriod reportPeriod;
  final List<DateTime> dateTimes;

  @override
  ConsumerState<_CategoryReportDetails> createState() => _CategoryReportDetailsState();
}

class _CategoryReportDetailsState extends ConsumerState<_CategoryReportDetails> {
  late final _pieServices = ref.read(customPieChartServicesProvider);

  late final List<_CategoryComparison> _expenseDataList = [];
  late final List<_CategoryComparison> _incomeDataList = [];

  late DateTimeRange _previousPeriod;

  late DateTimeRange _lastSamePeriod;

  void _getPeriods() {
    _previousPeriod = widget.reportPeriod == ReportPeriod.month
        ? DateTimeRange(
            start: widget.dateTimes.first.copyWith(month: widget.dateTimes.first.month - 1),
            end: widget.dateTimes.last.copyWith(month: widget.dateTimes.last.month - 1),
          )
        : DateTimeRange(
            start: widget.dateTimes.first.subtract(const Duration(days: 7)),
            end: widget.dateTimes.last.subtract(const Duration(days: 7)),
          );

    _lastSamePeriod = widget.reportPeriod == ReportPeriod.month
        ? DateTimeRange(
            start: widget.dateTimes.first.copyWith(year: widget.dateTimes.first.year - 1),
            end: widget.dateTimes.last.copyWith(year: widget.dateTimes.last.year - 1),
          )
        : DateTimeRange(
            start: widget.dateTimes.first.copyWith(month: widget.dateTimes.first.month - 1),
            end: widget.dateTimes.last.copyWith(month: widget.dateTimes.last.month - 1),
          );
  }

  void _getDataList() {
    _expenseDataList.clear();
    _incomeDataList.clear();

    List<MapEntry<Category, double>> expenseThisPeriod = _pieServices.getExpenseData(
      dateTime: widget.dateTimes.first,
      dateTime2: widget.dateTimes.last,
      useOther: false,
    );

    List<MapEntry<Category, double>> expensePreviousPeriod = _pieServices.getExpenseData(
      dateTime: _previousPeriod.start,
      dateTime2: _previousPeriod.end,
      useOther: false,
    );

    List<MapEntry<Category, double>> expenseLastSamePeriod = _pieServices.getExpenseData(
      dateTime: _lastSamePeriod.start,
      dateTime2: _lastSamePeriod.end,
      useOther: false,
    );

    List<MapEntry<Category, double>> incomeThisPeriod = _pieServices.getIncomeData(
      context,
      dateTime: widget.dateTimes.first,
      dateTime2: widget.dateTimes.last,
      useOther: false,
    );

    List<MapEntry<Category, double>> incomePreviousPeriod = _pieServices.getIncomeData(
      context,
      dateTime: _previousPeriod.start,
      dateTime2: _previousPeriod.end,
      useOther: false,
    );

    List<MapEntry<Category, double>> incomeLastSamePeriod = _pieServices.getIncomeData(
      context,
      dateTime: _lastSamePeriod.start,
      dateTime2: _lastSamePeriod.end,
      useOther: false,
    );

    for (var entry in expenseThisPeriod) {
      _expenseDataList.add(
        _CategoryComparison(
          category: entry.key,
          thisPeriod: entry.value,
          previousPeriod: expensePreviousPeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
          lastSamePeriod: expenseLastSamePeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
        ),
      );
    }

    for (var entry in incomeThisPeriod) {
      _expenseDataList.add(
        _CategoryComparison(
          category: entry.key,
          thisPeriod: entry.value,
          previousPeriod: incomePreviousPeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
          lastSamePeriod: incomeLastSamePeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
        ),
      );
    }
  }

  @override
  void initState() {
    _getPeriods();
    _getDataList();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CategoryReportDetails oldWidget) {
    _getPeriods();
    _getDataList();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_previousPeriod.toString()),
          Text(_lastSamePeriod.toString()),
          ..._expenseDataList.map((e) => Row(
                children: [
                  Text(e.category.name),
                  Text(e.thisPeriod.toString()),
                  Text(e.previousPeriod.toString()),
                  Text(e.lastSamePeriod.toString()),
                ],
              )),
          ..._incomeDataList.map((e) => Row(
                children: [
                  Text(e.category.name),
                  Text(e.thisPeriod.toString()),
                  Text(e.previousPeriod.toString()),
                  Text(e.lastSamePeriod.toString()),
                ],
              )),
        ],
      ),
    );
  }

  Widget label(MapEntry<Category, double> e, {required bool Function() isTouched}) => CustomInkWell(
        onTap: () {},
        inkColor: context.appTheme.onBackground,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: e.key.backgroundColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Gap.w4,
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: k250msDuration,
                  style: kHeader4TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                    fontSize: 14,
                    fontFamily: 'WixMadeforDisplay',
                    fontWeight: isTouched() ? FontWeight.w800 : null,
                  ),
                  child: Text(
                    e.key.name,
                  ),
                ),
              ),
              MoneyAmount(
                amount: e.value,
                style: kHeader2TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );

  Widget header(String text, double amount) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                text,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.65),
                  fontSize: 14,
                  height: 0.99,
                ),
              ),
            ),
            MoneyAmount(
              amount: amount,
              style: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground.withOpacity(0.65),
                fontSize: 14,
                height: 0.99,
              ),
            ),
          ],
        ),
      );
}

class _CategoryComparison {
  final Category category;
  final double thisPeriod;
  final double previousPeriod;
  final double lastSamePeriod;

  _CategoryComparison(
      {required this.category,
      required this.thisPeriod,
      required this.previousPeriod,
      required this.lastSamePeriod});
}
