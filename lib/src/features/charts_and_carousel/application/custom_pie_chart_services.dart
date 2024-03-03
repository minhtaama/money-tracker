import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

class PieChartServices {
  PieChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  Map<Category, double> getMonthlyExpenseData(DateTime dateTime, BuildContext context) {
    final txnsList = transactionRepo
        .getTransactions(dateTime.copyWith(day: 1), dateTime.copyWith(month: dateTime.month + 1, day: 0))
        .whereType<Expense>()
        .toList();
    final map = <Category, double>{};

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category!] = map[txn.category!]! + txn.amount;
      } else {
        map[txn.category!] = txn.amount;
      }
    }

    return map;
  }
}
/////////////////// PROVIDERS //////////////////////////

final customPieChartServicesProvider = Provider<PieChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return PieChartServices(repo);
  },
);
