import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

class PieChartServices {
  PieChartServices(this.transactionRepo, this.accountRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  final AccountRepositoryRealmDb accountRepo;

  /// If `dateTime2` is null, then returns data of whole `dateTime`'s month
  /// Else, returns date from `dateTime` to `dateTime2`
  double getExpenseAmount(DateTime dateTime, [DateTime? dateTime2]) {
    final range = dateTime2 == null
        ? DateTimeRange(
            start: dateTime.copyWith(day: 1, hour: 0, minute: 0, second: 1),
            end: dateTime.copyWith(month: dateTime.month + 1, day: 0, hour: 23, minute: 59, second: 59))
        : DateTimeRange(
            start: dateTime.copyWith(hour: 0, minute: 0, second: 1),
            end: dateTime2.copyWith(hour: 23, minute: 59, second: 59));

    final txnsList = transactionRepo.getTransactions(range.start, range.end).whereType<Expense>().toList();

    if (txnsList.isEmpty) {
      return 0;
    }

    return txnsList.map((e) => e.amount).reduce((value, element) => value + element);
  }

  /// If `dateTime2` is null, then returns data of whole `dateTime`'s month
  /// Else, returns date from `dateTime` to `dateTime2`
  List<MapEntry<Category, double>> getExpenseData({
    required DateTime dateTime,
    DateTime? dateTime2,
    bool useOther = true,
  }) {
    final range = dateTime2 == null
        ? DateTimeRange(
            start: dateTime.copyWith(day: 1, hour: 0, minute: 0, second: 1),
            end: dateTime.copyWith(month: dateTime.month + 1, day: 0, hour: 23, minute: 59, second: 59))
        : DateTimeRange(
            start: dateTime.copyWith(hour: 0, minute: 0, second: 1),
            end: dateTime2.copyWith(hour: 23, minute: 59, second: 59));

    final txnsList = transactionRepo.getTransactions(range.start, range.end).whereType<Expense>().toList();

    final map = <Category, double>{};

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category] = map[txn.category]! + txn.amount;
      } else {
        map[txn.category] = txn.amount;
      }
    }

    return useOther ? _modifyDataList(map, OthersCategory()) : map.entries.toList()
      ..sort((a, b) => (b.value - a.value).toInt());
  }

  /// If `dateTime2` is null, then returns data of whole `dateTime`'s month
  /// Else, returns date from `dateTime` to `dateTime2`
  double getIncomeAmount(DateTime dateTime, [DateTime? dateTime2]) {
    final range = dateTime2 == null
        ? DateTimeRange(
            start: dateTime.copyWith(day: 1, hour: 0, minute: 0, second: 1),
            end: dateTime.copyWith(month: dateTime.month + 1, day: 0, hour: 23, minute: 59, second: 59))
        : DateTimeRange(
            start: dateTime.copyWith(hour: 0, minute: 0, second: 1),
            end: dateTime2.copyWith(hour: 23, minute: 59, second: 59));

    final txnsList = transactionRepo.getTransactions(range.start, range.end).whereType<Income>().toList();

    if (txnsList.isEmpty) {
      return 0;
    }

    return txnsList.map((e) => e.amount).reduce((value, element) => value + element);
  }

  /// If `dateTime2` is null, then returns data of whole `dateTime`'s month
  /// Else, returns date from `dateTime` to `dateTime2`
  List<MapEntry<Category, double>> getIncomeData(
    BuildContext context, {
    required DateTime dateTime,
    DateTime? dateTime2,
    bool useOther = true,
  }) {
    final range = dateTime2 == null
        ? DateTimeRange(
            start: dateTime.copyWith(day: 1, hour: 0, minute: 0, second: 1),
            end: dateTime.copyWith(month: dateTime.month + 1, day: 0, hour: 23, minute: 59, second: 59))
        : DateTimeRange(
            start: dateTime.copyWith(hour: 0, minute: 0, second: 1),
            end: dateTime2.copyWith(hour: 23, minute: 59, second: 59));

    final txnsList = transactionRepo.getTransactions(range.start, range.end).whereType<Income>().toList();

    final map = <Category, double>{};
    final initialIncome = Category.initialIncome(context);

    for (int i = 0; i < txnsList.length; i++) {
      final txn = txnsList[i];
      if (map.containsKey(txn.category)) {
        map[txn.category] = map[txn.category]! + txn.amount;
      } else if (txn.isInitialTransaction) {
        map[initialIncome] = (map[initialIncome] ?? 0) + txn.amount;
      } else {
        map[txn.category] = txn.amount;
      }
    }

    return useOther ? _modifyDataList(map, OthersCategory()) : map.entries.toList()
      ..sort((a, b) => (b.value - a.value).toInt());
  }

  /// To sort the data from largest to smallest value, and group smallest to `others` category
  List<MapEntry<T, double>> _modifyDataList<T>(Map<T, double> data, T othersDisplay) {
    final dataList = data.entries.toList()..sort((a, b) => (b.value - a.value).toInt());

    if (dataList.length - 1 >= 5) {
      final sumAll = dataList.map((e) => e.value).reduce((value, element) => value + element);
      double sumOfSmallest = 0;
      int i = dataList.length - 1;
      while (i >= 3) {
        final entry = dataList[i];

        sumOfSmallest += entry.value;

        if (sumOfSmallest >= sumAll * 0.15) {
          break;
        }

        i--;
      }

      if (i < dataList.length - 1) {
        final othersValue =
            dataList.sublist(i, dataList.length).map((e) => e.value).reduce((value, element) => value + element);

        dataList.removeRange(i, dataList.length);
        dataList.add(MapEntry<T, double>(othersDisplay, othersValue));
      }
    }

    return dataList;
  }
}
/////////////////// PROVIDERS //////////////////////////

final customPieChartServicesProvider = Provider<PieChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);
    final accRepo = ref.watch(accountRepositoryProvider);

    return PieChartServices(repo, accRepo);
  },
);
