import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../utils/enums.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';
import 'dart:math' as math;

class BarChartServices {
  BarChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  /// Key runs from 0 (first day of week) to 6 (last day of week)
  Map<int, ({double spending, double income, double ySpending, double yIncome})> getWeeklyReportData(
      BuildContext context, DateTime dateTime) {
    final range = dateTime.weekRange(context);

    final txnsList = transactionRepo.getTransactions(range.start, range.end).toList();

    print(txnsList);

    double maxTemp = double.minPositive;
    final List<({int index, double spending, double income})> listTemp = [];

    final weekDays = <int>[1, 2, 3, 4, 5, 6, 7];

    reorderFirstDayOfWeek(context, weekDays);

    for (int i = 0; i <= weekDays.length - 1; i++) {
      final weekDay = weekDays[i];
      final txnsInWeekday = List<BaseTransaction>.from(txnsList).where((txn) => txn.dateTime.weekday == weekDay);

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
      listTemp.add((index: i, spending: spending, income: income));
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

  /// Call this function to re-order `weekDays` list to database's `firstDayOfWeek`
  ///
  /// The original list must have Monday as index 0.
  void reorderFirstDayOfWeek(BuildContext context, List weekDays) {
    final offset = switch (context.appSettings.firstDayOfWeek) {
      FirstDayOfWeek.monday => 0,
      FirstDayOfWeek.sunday => -1,
      FirstDayOfWeek.saturday => -2,
      FirstDayOfWeek.localeDefault => switch (MaterialLocalizations.of(context).firstDayOfWeekIndex) {
          0 => -1, //Sun
          1 => 0, //Mon
          2 => -6, //Tue
          3 => -5, //Wed
          4 => -4, //Thu
          5 => -3, //Fri
          6 => -2, //Sat
          _ => throw StateError('Wrong index of first day of week'),
        },
    };

    if (offset != 0) {
      final subList = weekDays.sublist(weekDays.length + offset, weekDays.length);

      weekDays
        ..removeRange(weekDays.length + offset, weekDays.length)
        ..insertAll(0, subList);
    }
  }
}

/////////////////// PROVIDERS //////////////////////////

final customBarChartServicesProvider = Provider<BarChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return BarChartServices(repo);
  },
);
