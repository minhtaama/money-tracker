import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../../common_widgets/custom_line_chart.dart';
import '../../../utils/enums.dart';
import '../data/transaction_repo.dart';
import '../domain/transaction_base.dart';

class TransactionServices {
  TransactionServices(this.repo);

  final TransactionRepository repo;

  double getCashflow(DateTime lower, DateTime upper) {
    final list = repo.getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Income) {
        result += txn.amount;
      }
      if (txn is Expense || txn is CreditPayment) {
        result -= txn.amount;
      }
    }
    return result;
  }

  double getExpenseAmount(DateTime lower, DateTime upper) {
    final list = repo.getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Expense || txn is CreditPayment) {
        result += txn.amount;
      }
    }
    return result;
  }

  double getIncomeAmount(DateTime lower, DateTime upper) {
    final list = repo.getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Income) {
        result += txn.amount;
      }
    }
    return result;
  }

  List<CLCSpot> getLineChartSpots(ChartDataType type, DateTime displayDate) {
    final dayBeginOfMonth = DateTime(displayDate.year, displayDate.month);
    final dayEndOfMonth = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59);
    final today = DateTime.now();

    final days = displayDate.daysInMonth == 31 || displayDate.daysInMonth == 30
        ? [1, 8, 15, 23, dayEndOfMonth.day]
        : [1, 7, 14, 21, dayEndOfMonth.day];

    if (today.isSameMonthAs(displayDate)) {
      if (!days.contains(today.day)) {
        int index = days.lastIndexWhere((day) => day < today.day);
        days.insert(index + 1, today.day);
      }
    }

    Map<int, double> result = {for (int day in days) day: 0};

    void updateAmount(int day, BaseTransaction txn) {
      result.updateAll((key, value) {
        if (key >= day) {
          if (type == ChartDataType.cashflow) {
            if (txn is CreditPayment || txn is Expense) {
              return value -= txn.amount;
            }
          }

          return value += txn.amount;
        }

        return value;
      });
    }

    final txns = repo
        .getTransactions(dayBeginOfMonth, dayEndOfMonth)
        .where(
          (txn) => switch (type) {
            ChartDataType.cashflow => txn is Income || txn is Expense || txn is CreditPayment,
            ChartDataType.expense => txn is Expense || txn is CreditPayment,
            ChartDataType.income => txn is Income,
          },
        )
        .toList();

    if (txns.isEmpty) {
      result.addEntries([
        MapEntry(days[0], 0),
        MapEntry(days[1], 0),
        MapEntry(days[2], 0),
        MapEntry(days[3], 0),
        MapEntry(days[4], 0),
      ]);
    } else {
      for (int i = 0; i <= txns.length - 1; i++) {
        final txn = txns[i];
        final tDay = txn.dateTime.day;

        if (tDay == days[0]) {
          updateAmount(days[0], txn);
        }

        for (int j = 1; j <= days.length - 1; j++) {
          if (tDay > days[j - 1] && tDay <= days[j]) {
            updateAmount(days[j], txn);
            break;
          }
        }
      }
    }

    double max = double.negativeInfinity;
    double min = 0;

    for (var entry in result.entries) {
      if (entry.value > max) {
        max = entry.value;
      }
      if (entry.value < min) {
        min = entry.value;
      }
    }

    final minAbs = min.abs();
    final maxFromMin = max + minAbs;

    double getY(double value) {
      if (value == 0) {
        if (maxFromMin == 0) {
          return 0.0;
        }
        return minAbs / maxFromMin;
      }
      if (value > 0) {
        return (value + minAbs) / maxFromMin;
      } else {
        return (minAbs - value.abs()) / maxFromMin;
      }
    }

    return List<CLCSpot>.from(
      result.entries.map(
        (e) => CLCSpot(e.key.toDouble(), getY(e.value),
            amount: e.value, checkpoint: e.key == today.day && today.isSameMonthAs(displayDate)),
      ),
    );
  }
}

/////////////////// PROVIDERS //////////////////////////

final transactionServicesProvider = Provider<TransactionServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);
    return TransactionServices(repo);
  },
);
