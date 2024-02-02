import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/domain/statement/statement.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../accounts/domain/account_base.dart';
import '../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../utils/enums.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';
import 'dart:math' as math;

class LineChartServices {
  LineChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  double getCashflow(DateTime lower, DateTime upper) {
    final list = transactionRepo.getTransactions(lower, upper);
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
    final list = transactionRepo.getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Expense || txn is CreditPayment) {
        result += txn.amount;
      }
    }
    return result;
  }

  double getIncomeAmount(DateTime lower, DateTime upper) {
    final list = transactionRepo.getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Income) {
        result += txn.amount;
      }
    }
    return result;
  }

  double getTotalAssets(DateTime displayDate) {
    final balanceAtDateTimes = transactionRepo.getSortedBalanceAtDateTimeList();

    // Find balDt include displayDate
    int index = balanceAtDateTimes.indexWhere((balDt) => displayDate.isSameMonthAs(balDt.date));

    // if not found, find nearest balDt before displayDate
    if (index == -1) {
      index = balanceAtDateTimes.lastIndexWhere((balDt) => displayDate.isInMonthAfter(balDt.date));
    }

    // If not found
    if (index == -1) {
      return 0;
    }

    return balanceAtDateTimes[index].amount;
  }

  double getAverageAssets() {
    double avg = 0;
    final balanceAtDateTimes = transactionRepo.getSortedBalanceAtDateTimeList();
    for (var balDt in balanceAtDateTimes) {
      avg += balDt.amount;
    }
    if (balanceAtDateTimes.isEmpty) {
      return 0;
    }
    return avg / balanceAtDateTimes.length;
  }

  CLCData getHomeScreenCLCData(ChartDataType type, DateTime displayDate) {
    final dayBeginOfMonth = DateTime(displayDate.year, displayDate.month);
    final dayEndOfMonth = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59);
    final today = DateTime.now();

    final double monthInitialAmount;

    // Modify monthInitialAmount if type is ChartDataType.totalBalance
    if (type == ChartDataType.totalAssets) {
      final balanceAtDateTimes = transactionRepo.getSortedBalanceAtDateTimeList();

      // Find nearest balDt before displayDate
      int index = balanceAtDateTimes.lastIndexWhere((balDt) => displayDate.isInMonthAfter(balDt.date));

      if (index == -1) {
        monthInitialAmount = 0;
      } else {
        monthInitialAmount = balanceAtDateTimes[index].amount;
      }
    } else {
      monthInitialAmount = 0;
    }

    final days = [for (int i = 1; i <= displayDate.daysInMonth; i++) i];

    Map<int, double> result = {for (int day in days) day: monthInitialAmount};

    void updateAmount(int day, BaseTransaction txn) {
      result.updateAll((key, value) {
        if (key >= day) {
          if (type == ChartDataType.cashflow || type == ChartDataType.totalAssets) {
            if (txn is CreditPayment || txn is Expense) {
              return value -= txn.amount;
            }
          }

          return value += txn.amount;
        }

        return value;
      });
    }

    final txns = transactionRepo
        .getTransactions(dayBeginOfMonth, dayEndOfMonth)
        .where(
          (txn) => switch (type) {
            ChartDataType.cashflow ||
            ChartDataType.totalAssets =>
              txn is Income || txn is Expense || txn is CreditPayment,
            ChartDataType.expense => txn is Expense || txn is CreditPayment,
            ChartDataType.income => txn is Income,
          },
        )
        .toList();

    if (txns.isNotEmpty) {
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

    if (type == ChartDataType.totalAssets) {
      final avg = getAverageAssets();
      if (avg > max) {
        max = avg;
      }
    }

    final minAbs = min.abs();

    final maxFromMin = max == min
        ? 0
        : max < 0 && min < 0
            ? min.abs() - max.abs()
            : max + minAbs;

    double getY(double amount) {
      if (maxFromMin == 0) {
        return 0.0;
      }
      if (amount == 0) {
        return minAbs / maxFromMin;
      }
      if (amount > 0) {
        return (amount + minAbs) / maxFromMin;
      } else {
        return (minAbs - amount.abs()) / maxFromMin;
      }
    }

    return CLCData(
      maxAmount: max,
      minAmount: min,
      spots: List<CLCSpot>.from(
        result.entries.map(
          (e) => CLCSpot(e.key.toDouble(), getY(e.value),
              amount: e.value, checkpoint: e.key == today.day && today.isSameMonthAs(displayDate)),
        ),
      ),
    );
  }

  CLCData getCreditCLCData(CreditAccount account, DateTime displayStatementDate) {
    final today = DateTime.now().onlyYearMonthDay;
    final creditLimit = account.creditLimit;
    final statement = account.statementAt(displayStatementDate);

    final double carryOver;
    final List<BaseCreditTransaction> txns;
    final List<DateTime> days;

    if (statement != null) {
      carryOver = statement.previousStatement.balanceToPay;
      txns =
          statement.transactionsInBillingCycle.followedBy(statement.transactionsInGracePeriod).toList();
      days = [
        for (DateTime day = statement.startDate;
            !day.isAfter(statement.dueDate);
            day = day.copyWith(day: day.day + 1))
          day
      ];
    } else {
      carryOver = 0;
      txns = [];
      days = [];
    }

    print(days.map((e) => '${e.day}/${e.month}'));

    Map<DateTime, double> result = {for (DateTime day in days) day: creditLimit - carryOver};

    void updateAmount(DateTime day, BaseCreditTransaction txn) {
      result.updateAll((key, value) {
        if (!key.isBefore(day)) {
          if (txn is CreditPayment) {
            return value += txn.amount;
          }

          return value -= txn.amount;
        }

        return value;
      });
    }

    if (txns.isNotEmpty) {
      for (int i = 0; i <= txns.length - 1; i++) {
        final txn = txns[i];
        final tDay = txn.dateTime.onlyYearMonthDay;

        if (tDay.isAtSameMomentAs(days[0])) {
          updateAmount(days[0], txn);
        }

        for (int j = 1; j <= days.length - 1; j++) {
          if (tDay.isAfter(days[j - 1]) && !tDay.isAfter(days[j])) {
            updateAmount(days[j], txn);
            break;
          }
        }
      }
    }

    double max = creditLimit;
    double min = 0;

    for (var entry in result.entries) {
      if (entry.value < min) {
        min = entry.value;
      }
    }

    final minAbs = min.abs();

    final maxFromMin = max == min
        ? 0
        : max < 0 && min < 0
            ? min.abs() - max.abs()
            : max + minAbs;

    double getY(double amount) {
      if (maxFromMin == 0) {
        return 0.0;
      }
      if (amount == 0) {
        return minAbs / maxFromMin;
      }
      if (amount > 0) {
        return (amount + minAbs) / maxFromMin;
      } else {
        return (minAbs - amount.abs()) / maxFromMin;
      }
    }

    return CLCData(
      maxAmount: max,
      minAmount: min,
      dateTimesToShow: [statement?.startDate, statement?.statementDate, statement?.dueDate],
      spots: List<CLCSpot>.from(
        result.entries.map(
          (e) => CLCSpot(
            e.key.getDaysDifferent(statement!.startDate).toDouble(),
            getY(e.value),
            amount: e.value,
            dateTime: e.key.onlyYearMonthDay,
            checkpoint: e.key == today,
          ),
        ),
      ),
    );
  }
}

@immutable
class CLCData {
  final List<CLCSpot> spots;

  /// if type is totalAssets, average amount ever will be used to compare too.
  final double maxAmount;
  final double minAmount;

  /// Only for credit: startDate -> statementDate -> dueDate
  final List<DateTime?>? dateTimesToShow;

  const CLCData(
      {required this.spots, required this.maxAmount, required this.minAmount, this.dateTimesToShow});
}

/////////////////// PROVIDERS //////////////////////////

final customLineChartServicesProvider = Provider<LineChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return LineChartServices(repo);
  },
);
