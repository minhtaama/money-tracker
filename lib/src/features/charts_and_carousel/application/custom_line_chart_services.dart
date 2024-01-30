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

class CustomLineChartServices {
  CustomLineChartServices(this.transactionRepo);

  final TransactionRepositoryRealmDb transactionRepo;

  void animateLineChartPosition(ScrollController controller, DateTime currentMonth) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      final position = controller.position;
      final today = DateTime.now();

      if (currentMonth.isInMonthAfter(today)) {
        controller.animateTo(
          position.minScrollExtent,
          duration: k1000msDuration,
          curve: Curves.easeInOutCubic,
        );
      } else if (currentMonth.isInMonthBefore(today)) {
        controller.animateTo(
          position.maxScrollExtent,
          duration: k1000msDuration,
          curve: Curves.easeInOutCubic,
        );
      } else if (currentMonth.isSameMonthAs(today)) {
        final todayOffset = ((today.day - 4.5) * kDayColumnLineChartWidth)
            .clamp(position.minScrollExtent, position.maxScrollExtent);

        controller.animateTo(
          todayOffset,
          duration: k1000msDuration,
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

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

    // final days = displayDate.daysInMonth == 31 || displayDate.daysInMonth == 30
    //     ? [1, 8, 15, 23, dayEndOfMonth.day]
    //     : [1, 7, 14, 21, dayEndOfMonth.day];
    //
    // // Modify days list if today is in displayDate
    // if (today.isSameMonthAs(displayDate)) {
    //   if (!days.contains(today.day)) {
    //     int index = days.indexWhere((day) => day <= (today.day + 2) && day >= (today.day - 3));
    //     if (index != -1) {
    //       days[index] = today.day;
    //     } else {
    //       index = days.lastIndexWhere((day) => day < today.day);
    //       days.insert(index + 1, today.day);
    //     }
    //   }
    // }

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

    if (txns.isEmpty) {
      result.addEntries([
        MapEntry(days[0], monthInitialAmount),
        MapEntry(days[1], monthInitialAmount),
        MapEntry(days[2], monthInitialAmount),
        MapEntry(days[3], monthInitialAmount),
        MapEntry(days[4], monthInitialAmount),
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

  CLCData getCreditCLCData(CreditAccount account, DateTime displayDate) {
    final today = DateTime.now();

    final statement = account.statementAt(displayDate);

    final double carryOver;
    final List<BaseCreditTransaction> txns;

    if (statement != null) {
      carryOver = statement.previousStatement.balanceToPay;
      txns =
          statement.transactionsInBillingCycle.followedBy(statement.transactionsInGracePeriod).toList();
    } else {
      carryOver = 0;
      txns = [];
    }

    //final days = [for (int i = 1; i <= displayDate.daysInMonth; i++) i];
    final List<int> days = [1];
    for (BaseCreditTransaction txn in txns) {
      if (!days.contains(txn.dateTime.day)) {
        days.add(txn.dateTime.day);
      }
    }
    days.add(displayDate.daysInMonth);

    Map<int, double> result = {for (int day in days) day: carryOver};

    void updateAmount(int day, BaseCreditTransaction txn) {
      result.updateAll((key, value) {
        if (key >= day) {
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
}

@immutable
class CLCData {
  final List<CLCSpot> spots;

  /// if type is totalAssets, average amount ever will be used to compare too.
  final double maxAmount;
  final double minAmount;

  const CLCData({required this.spots, required this.maxAmount, required this.minAmount});
}

/////////////////// PROVIDERS //////////////////////////

final customLineChartServicesProvider = Provider<CustomLineChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return CustomLineChartServices(repo);
  },
);
