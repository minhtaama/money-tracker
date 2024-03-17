import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';
import 'dart:math' as math;

class BarChartServices {
  BarChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  /// Key runs from 0 (first day of week) to 6 (last day of week)
  Map<int, ({double spending, double income, double ySpending, double yIncome})> getWeeklyReportData(
      DateTime dateTime) {
    final range = dateTime.currentWeek;

    final txnsList = transactionRepo.getTransactions(range.start, range.end).toList();

    double maxTemp = double.minPositive;
    final List<({int index, double spending, double income})> listTemp = [];

    // From Monday to Sunday
    for (int i = 1; i <= 7; i++) {
      final txnsInWeekday =
          List<BaseTransaction>.from(txnsList).where((txn) => txn.dateTime.weekday == i);

      double spending = 0;
      double income = 0;

      for (BaseTransaction txn in txnsInWeekday) {
        if (txn is Income) {
          income += txn.amount;
        }
        if (txn is Expense) {
          spending += txn.amount;
        }
      }

      maxTemp = math.max(maxTemp, math.max(income, spending));
      listTemp.add((index: i - 1, spending: spending, income: income));
    }

    return {
      for (var e in listTemp)
        e.index: (
          spending: e.spending,
          income: e.income,
          ySpending: (e.spending / maxTemp).clamp(0.01, 1),
          yIncome: (e.income / maxTemp).clamp(0.01, 1),
        )
    };
  }
}

/////////////////// PROVIDERS //////////////////////////

final customBarChartServicesProvider = Provider<BarChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return BarChartServices(repo);
  },
);
