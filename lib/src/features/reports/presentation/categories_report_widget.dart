import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

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
  const _CategoryReportSmall({required this.reportPeriod, required this.dateTimes});

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
          color: isExpense ? context.appTheme.negative.withOpacity(0.65) : context.appTheme.positive.withOpacity(0.65),
          size: 25,
        ),
        onChartTap: onChartTap,
        touchedIndex: touchedIndex,
      ),
    );
  }
}

class _CategoryReportDetails extends ConsumerStatefulWidget {
  const _CategoryReportDetails({required this.reportPeriod, required this.dateTimes});

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

  bool _isCompareWithLastSamePeriod = false;

  void _getPeriods() {
    _previousPeriod = widget.reportPeriod == ReportPeriod.month
        ? DateTimeRange(
            start: widget.dateTimes.first.copyWith(month: widget.dateTimes.first.month - 1),
            end: widget.dateTimes.first.subtract(const Duration(days: 1)),
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

  void _getData() {
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

    _buildList(_expenseDataList, expenseThisPeriod, expensePreviousPeriod, expenseLastSamePeriod);
    _buildList(_incomeDataList, incomeThisPeriod, incomePreviousPeriod, incomeLastSamePeriod);

    final totalIncome = _incomeDataList.isEmpty
        ? _CategoryComparison(
            type: CategoryType.income,
            category: null,
            thisPeriod: 0.0,
            previousPeriod: 0.0,
            lastSamePeriod: 0.0,
          )
        : _incomeDataList.length == 1
            ? _incomeDataList[0].toNullCategory()
            : _incomeDataList.reduce(
                (val, e) => _CategoryComparison(
                  type: CategoryType.income,
                  category: null,
                  thisPeriod: val.thisPeriod + e.thisPeriod,
                  previousPeriod: val.previousPeriod + e.previousPeriod,
                  lastSamePeriod: val.lastSamePeriod + e.lastSamePeriod,
                ),
              );

    final totalExpense = _expenseDataList.isEmpty
        ? _CategoryComparison(
            type: CategoryType.expense,
            category: null,
            thisPeriod: 0.0,
            previousPeriod: 0.0,
            lastSamePeriod: 0.0,
          )
        : _expenseDataList.length == 1
            ? _expenseDataList[0].toNullCategory()
            : _expenseDataList.reduce(
                (val, e) => _CategoryComparison(
                  type: CategoryType.expense,
                  category: null,
                  thisPeriod: val.thisPeriod + e.thisPeriod,
                  previousPeriod: val.previousPeriod + e.previousPeriod,
                  lastSamePeriod: val.lastSamePeriod + e.lastSamePeriod,
                ),
              );

    _incomeDataList.insert(0, totalIncome);
    _expenseDataList.insert(0, totalExpense);
  }

  void _buildList(
    List<_CategoryComparison> list,
    List<MapEntry<Category, double>> mapListThisPeriod,
    List<MapEntry<Category, double>> mapListPreviousPeriod,
    List<MapEntry<Category, double>> mapListLastSamePeriod,
  ) {
    for (var entry in mapListThisPeriod) {
      if (entry.key.isInitialIncome) {
        continue;
      }

      list.add(
        _CategoryComparison(
          type: entry.key.type,
          category: entry.key,
          thisPeriod: entry.value,
          previousPeriod: mapListPreviousPeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
          lastSamePeriod: mapListLastSamePeriod
              .firstWhere((e) => e.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
        ),
      );
    }

    for (var entry in mapListPreviousPeriod) {
      // If we found element of map in list or the element of map is not exist in database,
      // then we don't add the element to list.
      list.firstWhere((e) => e.category == entry.key || entry.key.isInitialIncome, orElse: () {
        final newCat = _CategoryComparison(
          type: entry.key.type,
          category: entry.key,
          thisPeriod: 0,
          previousPeriod: mapListPreviousPeriod
              .firstWhere((e2) => e2.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
          lastSamePeriod: mapListLastSamePeriod
              .firstWhere((e2) => e2.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
        );

        list.add(newCat);

        return newCat;
      });
    }

    for (var entry in mapListLastSamePeriod) {
      // If we found element of map in list or the element of map is not exist in database,
      // then we don't add the element to list.
      list.firstWhere((e) => e.category == entry.key || entry.key.isInitialIncome, orElse: () {
        final newCat = _CategoryComparison(
          type: entry.key.type,
          category: entry.key,
          thisPeriod: 0,
          previousPeriod: mapListPreviousPeriod
              .firstWhere((e2) => e2.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
          lastSamePeriod: mapListLastSamePeriod
              .firstWhere((e2) => e2.key == entry.key, orElse: () => MapEntry(DeletedCategory(), 0))
              .value,
        );

        list.add(newCat);

        return newCat;
      });
    }
  }

  @override
  void initState() {
    _getPeriods();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _getData();
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _CategoryReportDetails oldWidget) {
    _getPeriods();
    _getData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _header(),
              Gap.divider(context, color: context.appTheme.onBackground.withOpacity(0.15)),
              ..._expenseDataList.map((e) => _label(e, _isCompareWithLastSamePeriod)),
              Gap.divider(context, color: context.appTheme.onBackground.withOpacity(0.15)),
              ..._incomeDataList.map((e) => _label(e, _isCompareWithLastSamePeriod)),
            ],
          ),
          Positioned.fill(
            child: _foregroundDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _label(_CategoryComparison e, bool isCompareWithLastSamePeriod) {
    final textColor = e.type == CategoryType.income ? context.appTheme.positive : context.appTheme.negative;

    final change = isCompareWithLastSamePeriod
        ? e.lastSamePeriod == 0 || e.thisPeriod == 0
            ? null
            : (((e.thisPeriod - e.lastSamePeriod) / e.lastSamePeriod) * 100).floor()
        : e.previousPeriod == 0 || e.thisPeriod == 0
            ? null
            : (((e.thisPeriod - e.previousPeriod) / e.previousPeriod) * 100).floor();

    final prefix = change == null
        ? ''
        : change > 0
            ? '+ '
            : change < 0
                ? '- '
                : '';

    final expenseChangeBgr = change == null
        ? AppColors.greyBgr(context)
        : change > 0
            ? context.appTheme.negative
            : change < 0
                ? context.appTheme.positive
                : AppColors.greyBgr(context);

    final incomeChangeBgr = change == null
        ? AppColors.greyBgr(context)
        : change > 0
            ? context.appTheme.positive
            : change < 0
                ? context.appTheme.negative
                : AppColors.greyBgr(context);

    final expenseChangeColor = change == null
        ? context.appTheme.onBackground
        : change > 0
            ? context.appTheme.onNegative
            : change < 0
                ? context.appTheme.onPositive
                : context.appTheme.onBackground;

    final incomeChangeColor = change == null
        ? context.appTheme.onBackground
        : change > 0
            ? context.appTheme.onPositive
            : change < 0
                ? context.appTheme.onNegative
                : context.appTheme.onBackground;

    final changeBgr = e.type == CategoryType.income ? incomeChangeBgr : expenseChangeBgr;

    final changeColor = e.type == CategoryType.income ? incomeChangeColor : expenseChangeColor;

    final totalText = e.type == CategoryType.income ? context.loc.totalIncome : context.loc.totalExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                e.category != null
                    ? SvgIcon(
                        e.category!.iconPath,
                        size: 20,
                        color: e.category!.backgroundColor.lerpWithOnBg(context, 0.1),
                      )
                    : Gap.noGap,
                Text(
                  e.category?.name ?? totalText,
                  style: kHeader4TextStyle.copyWith(
                    color: context.appTheme.onBackground.withOpacity(e.category == null ? 1 : 0.65),
                    fontSize: e.category == null ? 12 : 10,
                    height: e.category == null ? null : 0.99,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: Column(
                  children: [
                    MoneyAmount(
                      amount: e.thisPeriod,
                      style: kHeader3TextStyle.copyWith(
                        color: textColor.withOpacity(e.category == null ? 1 : 0.65),
                        fontSize: 12,
                        height: 0.99,
                      ),
                    ),
                    Gap.h8,
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                      decoration: BoxDecoration(
                        color: changeBgr.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        change == null ? '-' : '$prefix${change.abs()}%',
                        style: kHeader2TextStyle.copyWith(
                          color: changeColor,
                          fontSize: 11,
                          height: 0.99,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: MoneyAmount(
                  amount: e.previousPeriod,
                  style: kHeader3TextStyle.copyWith(
                    color: textColor.withOpacity(e.category == null ? 1 : 0.65),
                    fontSize: 12,
                    height: 0.99,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Center(
                child: MoneyAmount(
                  amount: e.lastSamePeriod,
                  style: kHeader3TextStyle.copyWith(
                    color: textColor.withOpacity(e.category == null ? 1 : 0.65),
                    fontSize: 12,
                    height: 0.99,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Gap.noGap,
          ),
          Expanded(
            flex: 3,
            child: Text(
              'This period'.hardcoded,
              style: kHeader4TextStyle.copyWith(
                color: context.appTheme.onBackground.withOpacity(0.65),
                fontSize: 12,
                height: 0.99,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Previous period'.hardcoded,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.65),
                  fontSize: 12,
                  height: 0.99,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Same last period'.hardcoded,
                style: kHeader4TextStyle.copyWith(
                  color: context.appTheme.onBackground.withOpacity(0.65),
                  fontSize: 12,
                  height: 0.99,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );

  Widget _foregroundDecoration() {
    Widget decoration1() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: context.appTheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              //border: Border.all(color: context.appTheme.primary),
            ),
          ),
        );

    Widget decoration2(double opacity) => AnimatedOpacity(
          duration: k150msDuration,
          curve: Curves.fastOutSlowIn,
          opacity: opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.appTheme.primary.withOpacity(0.65)),
            ),
          ),
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: 2,
          child: Gap.noGap,
        ),
        Expanded(
          flex: 3,
          child: decoration1(),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: CustomInkWell(
              onTap: () {
                if (_isCompareWithLastSamePeriod) {
                  setState(() {
                    _isCompareWithLastSamePeriod = false;
                  });
                }
              },
              inkColor: context.appTheme.primary,
              borderRadius: BorderRadius.circular(7),
              child: decoration2(_isCompareWithLastSamePeriod ? 0 : 1),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: CustomInkWell(
              onTap: () {
                if (!_isCompareWithLastSamePeriod) {
                  setState(() {
                    _isCompareWithLastSamePeriod = true;
                  });
                }
              },
              inkColor: context.appTheme.primary,
              borderRadius: BorderRadius.circular(7),
              child: decoration2(_isCompareWithLastSamePeriod ? 1 : 0),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryComparison {
  final CategoryType type;
  final Category? category;
  final double thisPeriod;
  final double previousPeriod;
  final double lastSamePeriod;

  _CategoryComparison(
      {required this.type,
      required this.category,
      required this.thisPeriod,
      required this.previousPeriod,
      required this.lastSamePeriod});

  _CategoryComparison toNullCategory() {
    return _CategoryComparison(
      type: type,
      category: null,
      thisPeriod: thisPeriod,
      previousPeriod: previousPeriod,
      lastSamePeriod: lastSamePeriod,
    );
  }
}
