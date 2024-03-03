import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

class PieChartServices {
  PieChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  List<PieChartSectionData> getExpenseData(DateTime lower, DateTime upper) {
    final txnsList = transactionRepo.getTransactions(lower, upper).whereType<Expense>().toList();
    final map = <Category, double>{};

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category!] = map[txn.category!]! + txn.amount;
      } else {
        map[txn.category!] = txn.amount;
      }
    }

    return map.entries
        .map((e) => PieChartSectionData(
              value: e.value,
            ))
        .toList();
  }
}
/////////////////// PROVIDERS //////////////////////////

final customPieChartServicesProvider = Provider<PieChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return PieChartServices(repo);
  },
);
