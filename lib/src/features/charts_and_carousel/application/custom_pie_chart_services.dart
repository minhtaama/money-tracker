import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

class PieChartServices {
  PieChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  double getMonthlyExpenseAmount(DateTime dateTime) {
    final txnsList = transactionRepo
        .getTransactions(dateTime.copyWith(day: 1), dateTime.copyWith(month: dateTime.month + 1, day: 0))
        .whereType<Expense>()
        .toList();

    if (txnsList.isEmpty) {
      return 0;
    }

    return txnsList.map((e) => e.amount).reduce((value, element) => value + element);
  }

  Map<Category, double> getMonthlyExpenseData(DateTime dateTime) {
    final txnsList = transactionRepo
        .getTransactions(dateTime.copyWith(day: 1), dateTime.copyWith(month: dateTime.month + 1, day: 0))
        .whereType<Expense>()
        .toList();
    final map = <Category, double>{};

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category!] = map[txn.category!]! + txn.amount;
      } else if (txn.category == null) {
        map[DeletedCategory()] = txn.amount;
      } else {
        map[txn.category!] = txn.amount;
      }
    }

    return map;
  }

  double getMonthlyIncomeAmount(DateTime dateTime) {
    final txnsList = transactionRepo
        .getTransactions(dateTime.copyWith(day: 1), dateTime.copyWith(month: dateTime.month + 1, day: 0))
        .whereType<Income>()
        .toList();

    if (txnsList.isEmpty) {
      return 0;
    }

    return txnsList.map((e) => e.amount).reduce((value, element) => value + element);
  }

  Map<Category, double> getMonthlyIncomeData(DateTime dateTime, BuildContext context) {
    final txnsList = transactionRepo
        .getTransactions(dateTime.copyWith(day: 1), dateTime.copyWith(month: dateTime.month + 1, day: 0))
        .whereType<Income>()
        .toList();

    final map = <Category, double>{};

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category!] = map[txn.category!]! + txn.amount;
      } else if (txn.isInitialTransaction) {
        map[Category.initialIncome(context)] = txn.amount;
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
