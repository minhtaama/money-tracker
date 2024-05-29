import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/reports/presentation/reports_screen.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
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

class CategoryReport extends ConsumerStatefulWidget {
  const CategoryReport({super.key, required this.dateTimes});

  final List<DateTime> dateTimes;

  @override
  ConsumerState<CategoryReport> createState() => _CategoryReportState();
}

class _CategoryReportState extends ConsumerState<CategoryReport> {
  // int _touchedIndexExpense = -1;
  //
  // int _touchedIndexIncome = -1;

  @override
  Widget build(BuildContext context) {
    final pieServices = ref.watch(customPieChartServicesProvider);

    final listExpense = pieServices.getExpenseData(widget.dateTimes.first, widget.dateTimes.last);
    final totalExpense = pieServices.getExpenseAmount(widget.dateTimes.first, widget.dateTimes.last);

    final listIncome = pieServices.getIncomeData(widget.dateTimes.first, context, widget.dateTimes.last);
    final totalIncome = pieServices.getIncomeAmount(widget.dateTimes.first, widget.dateTimes.last);

    return ReportWrapper(
      svgPath: AppIcons.undrawShopping2,
      title: 'Expense & Income'.hardcoded,
      illustrationSize: 110,
      illustrationOffset: -20,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _pieChart(
                    listExpense,
                    isExpense: true,
                  ),
                ),
                Gap.w24,
                Expanded(
                  child: _pieChart(
                    listIncome,
                    isExpense: false,
                  ),
                ),
              ],
            ),
            Gap.h12,
            ..._labels(
              listExpense,
              listIncome,
              totalExpense,
              totalIncome,
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
      ),
    );
  }

  List<Widget> _labels(List<MapEntry<Category, double>> expenseList, List<MapEntry<Category, double>> incomeList,
      double totalExpense, double totalIncome,
      {required void Function(Category) onTap}) {
    Widget label(MapEntry<Category, double> e) => CustomInkWell(
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
                  child: Text(
                    e.key.name,
                    style: kHeader4TextStyle.copyWith(
                      color: context.appTheme.onBackground,
                      fontSize: 14,
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

    final expenseLabels = expenseList.map((e) => label(e)).toList();

    final incomeLabels = incomeList.map((e) => label(e)).toList();

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

  Widget _pieChart(List<MapEntry<Category, double>> list, {required bool isExpense, void Function(int)? onChartTap}) {
    return SizedBox(
      height: 150,
      child: CustomPieChart<Category>(
        key: ValueKey(list.toString()),
        values: list,
        center: SvgIcon(
          isExpense ? AppIcons.upload : AppIcons.download,
          color: isExpense ? context.appTheme.negative.withOpacity(0.65) : context.appTheme.positive.withOpacity(0.65),
          size: 25,
        ),
        onChartTap: onChartTap,
      ),
    );
  }
}
