import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/domain/statement/base_class/statement.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import '../../accounts/domain/account_base.dart';
import '../../charts_and_carousel/presentation/custom_line_chart.dart';
import '../../../utils/enums.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';

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

  CLCData getCLCDataForHomeScreen(LineChartDataType type, DateTime displayDate) {
    final dayBeginOfMonth = DateTime(displayDate.year, displayDate.month);
    final dayEndOfMonth = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59);
    final today = DateTime.now();

    final double monthInitialAmount;

    // Modify monthInitialAmount if type is ChartDataType.totalBalance
    if (type == LineChartDataType.totalAssets) {
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
          if (type == LineChartDataType.cashflow || type == LineChartDataType.totalAssets) {
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
            LineChartDataType.cashflow ||
            LineChartDataType.totalAssets =>
              txn is Income || txn is Expense || txn is CreditPayment,
            LineChartDataType.expense => txn is Expense || txn is CreditPayment,
            LineChartDataType.income => txn is Income,
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

    if (type == LineChartDataType.totalAssets) {
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
              amount: e.value, isToday: e.key == today.day && today.isSameMonthAs(displayDate)),
        ),
      ),
    );
  }

  CLCData getCLCDataOfCreditAsset(CreditAccount account, DateTime displayStatementDate) {
    final today = DateTime.now().onlyYearMonthDay;
    final creditLimit = account.creditLimit;
    final statement = account.statementAt(displayStatementDate, upperGapAtDueDate: true);

    final double amountAtStartDate;
    final double amountAtEndDate;
    final double amountToPayAtEndDate;
    final double spentInGracePeriod;
    final double spentHasInstallment;
    final double balanceRemaining;
    final List<BaseCreditTransaction> txns;
    final List<DateTime> days;
    final DateTime startDate;
    final DateTime previousDueDate;
    final DateTime statementDate;
    final DateTime dueDate;

    if (statement != null) {
      amountAtStartDate = statement.startPoint.totalRemaining + statement.carry.interest;
      amountAtEndDate = statement.endPoint.totalSpent + statement.carry.interest;
      amountToPayAtEndDate = statement.endPoint.spentToPay + statement.carry.interest;
      spentInGracePeriod = statement.spent.inGracePeriod;
      spentHasInstallment = statement.spent.inBillingCycle.hasInstallment;
      balanceRemaining = statement.balance;
      txns = statement.transactions.inBillingCycle.followedBy(statement.transactions.inGracePeriod).toList();
      startDate = statement.date.start;
      previousDueDate = statement.date.previousDue;
      statementDate = statement.date.statement;
      dueDate = statement.date.due;
    } else {
      amountAtStartDate = 0;
      amountAtEndDate = 0;
      amountToPayAtEndDate = 0;
      spentInGracePeriod = 0;
      spentHasInstallment = 0;
      balanceRemaining = 0;
      txns = [];
      startDate = DateTime(displayStatementDate.year, displayStatementDate.month - 1, account.statementDay);
      previousDueDate = Calendar.minDate;
      statementDate = startDate.copyWith(month: startDate.month + 1);
      dueDate = account.statementDay >= account.paymentDueDay
          ? startDate.copyWith(month: startDate.month + 2, day: account.paymentDueDay).onlyYearMonthDay
          : startDate.copyWith(month: startDate.month + 1, day: account.paymentDueDay).onlyYearMonthDay;
    }

    // Credit amount after full payment
    final creditAfterFullPayment = statement?.checkpoint != null
        ? creditLimit - spentHasInstallment
        // (creditLimit - amountAtEndDate) is the amount of total spent (include installment)
        // then add the amount must pay: (amountToPayAtEndDate)
        : creditLimit - amountAtEndDate - spentInGracePeriod + amountToPayAtEndDate;

    days = [for (DateTime day = startDate; !day.isAfter(dueDate); day = day.copyWith(day: day.day + 1)) day];

    Map<DateTime, double> result = {for (DateTime day in days) day: creditLimit - amountAtStartDate};

    void updateAmount(DateTime day, BaseCreditTransaction txn, {required double countAsInstallmentAmount}) {
      result.updateAll((key, value) {
        if (!key.isBefore(day)) {
          if (txn is CreditPayment) {
            return value += txn.afterAdjustedAmount;
          }

          if (txn is CreditSpending) {
            return value -= txn.amount;
          }

          if (txn is CreditCheckpoint) {
            //return value = txn.amount;
            return value = account.creditLimit - txn.amount;
          }
        }

        return value;
      });
    }

    if (txns.isNotEmpty) {
      double countAsInstallmentAmount = 0;

      for (int i = 0; i <= txns.length - 1; i++) {
        final txn = txns[i];
        final tDay = txn.dateTime.onlyYearMonthDay;

        if (txn is CreditSpending && txn.hasInstallment) {
          countAsInstallmentAmount += txn.amount;
        }

        if (tDay.isAtSameMomentAs(days[0])) {
          updateAmount(days[0], txn, countAsInstallmentAmount: countAsInstallmentAmount);
        }

        for (int j = 1; j <= days.length - 1; j++) {
          if (tDay.isAfter(days[j - 1]) && !tDay.isAfter(days[j])) {
            updateAmount(days[j], txn, countAsInstallmentAmount: countAsInstallmentAmount);
            break;
          }
        }
      }
    }

    double min = creditLimit - amountAtStartDate;
    double max = min < 0 ? 0 : creditLimit;

    for (var entry in result.entries) {
      if (entry.value < min) {
        min = entry.value;
      }
    }

    final maxFromMin = max == min
        ? 0
        : max < 0 && min < 0
            ? min.abs() - max.abs()
            : max >= 0 && min >= 0
                ? max - min
                : max + min.abs();

    double getY(double amount) {
      if (maxFromMin == 0) {
        return 1.0;
      }
      if (amount == 0) {
        return min.abs() / maxFromMin;
      }
      if (amount > 0) {
        return (amount - min.abs()) / maxFromMin;
      } else {
        return (min.abs() - amount.abs()) / maxFromMin;
      }
    }

    double getX(DateTime dateTime) => dateTime.getDaysDifferent(startDate).toDouble();

    return CLCDataForCredit(
      maxAmount: max,
      minAmount: min,
      dateTimesToShow: [startDate, previousDueDate, statementDate, dueDate],
      extraLineY: getY(creditAfterFullPayment),
      balanceRemaining: balanceRemaining,
      spots: List<CLCSpotForCredit>.from(
        result.entries.map(
          (e) => CLCSpotForCredit(
            getX(e.key),
            getY(e.value),
            amount: e.value,
            dateTime: e.key.onlyYearMonthDay,
            isToday: e.key == today,
            isStatementDay: e.key == statementDate,
            isPreviousDueDay: e.key == previousDueDate,
          ),
        ),
      ),
    );
  }

  CLCData getCLCDataOfRegularAsset(RegularAccount regularAccount, DateTime lower, DateTime upper) {
    final range = DateTimeRange(
      start: lower.onlyYearMonthDay,
      end: upper.copyWith(hour: 23, minute: 59, second: 59),
    );

    final today = DateTime.now();

    final days = range.toList();

    final initialAmount = _findInitialAmount(
      dayBegin: range.start,
      transactionsList: regularAccount.transactionsList,
      transferTransactionsList: regularAccount.transferTransactionsList,
    );

    final txns = transactionRepo.getTransactionsOfAccount(regularAccount, range.start, range.end);

    final result = _getValueInEachDateMap(
      range,
      initialAmount,
      txns: txns,
      updateAmountLogic: (txn, value) {
        if (txn is CreditPayment || txn is Expense) {
          return value - txn.amount;
        }

        if (txn is Transfer) {
          if (txn.account.id == regularAccount.id) {
            return value - txn.amount;
          }
          if (txn.transferAccount.id == regularAccount.id) {
            return value + txn.amount;
          }
        }

        return value + txn.amount;
      },
    );

    final clamp = _getMaxMin([result]);

    return CLCData(
      maxAmount: clamp.max,
      minAmount: clamp.min,
      spots: List<CLCSpot>.from(
        result.entries.map(
          (e) => CLCSpot(
            days.indexOf(e.key).toDouble() + 1,
            _getY(e.value, clamp.minAbs, clamp.maxFromMin),
            amount: e.value,
            isToday: e.key.isSameDayAs(today) && today.isSameMonthAs(lower),
            dateTime: e.key,
          ),
        ),
      ),
    );
  }

  CLCData2 getCLCDataForReportScreenOnRegularAccount(
      List<RegularAccount> regularAccounts, DateTime lower, DateTime upper) {
    final range = DateTimeRange(
      start: lower.onlyYearMonthDay,
      end: upper.copyWith(hour: 23, minute: 59, second: 59),
    );

    final today = DateTime.now();

    final days = range.toList();

    final List<Map<DateTime, double>> mapList = <Map<DateTime, double>>[];

    for (int i = 0; i < regularAccounts.length; i++) {
      final account = regularAccounts[i];

      final txns = transactionRepo.getTransactionsOfAccount(account, range.start, range.end);

      final initialAmount = _findInitialAmount(
        dayBegin: range.start,
        transactionsList: account.transactionsList,
        transferTransactionsList: account.transferTransactionsList,
      );

      final map = _getValueInEachDateMap(
        range,
        initialAmount,
        txns: txns,
        updateAmountLogic: (txn, value) {
          if (txn is CreditPayment || txn is Expense) {
            return value - txn.amount;
          }

          if (txn is Transfer) {
            if (txn.account.id == account.id) {
              return value - txn.amount;
            }
            if (txn.transferAccount.id == account.id) {
              return value + txn.amount;
            }
          }

          return value + txn.amount;
        },
      );
      mapList.add(map);
    }

    final clamp = _getMaxMin(mapList);

    final List<CLCData2Line> lines = [];

    for (int i = 0; i < regularAccounts.length; i++) {
      lines.add(
        CLCData2Line(
          regularAccounts[i].toAccountInfo(),
          List<CLCSpot>.from(
            mapList[i].entries.map(
                  (e) => CLCSpot(
                    days.indexOf(e.key).toDouble() + 1,
                    _getY(e.value, clamp.minAbs, clamp.maxFromMin),
                    amount: e.value,
                    isToday: e.key.isSameDayAs(today) && today.isSameMonthAs(lower),
                    dateTime: e.key,
                  ),
                ),
          ),
        ),
      );
    }

    return CLCData2(
      range: range,
      maxAmount: clamp.max,
      minAmount: clamp.min,
      lines: lines,
    );
  }
}

extension _HelperFunctionsOnLineChart on LineChartServices {
  /// Find initial amount to calculate the first spot in the chart
  double _findInitialAmount({
    required DateTime dayBegin,
    required List<BaseRegularTransaction> transactionsList,
    List<ITransferable>? transferTransactionsList,
  }) {
    double initialAmount = 0;

    final txnMaxIndex = transactionsList.length - 1;

    for (int i = 0; i <= txnMaxIndex; i++) {
      final preTxn = transactionsList[i];
      if (preTxn.dateTime.isBefore(dayBegin.onlyYearMonthDay)) {
        if (preTxn is Expense || preTxn is Transfer) {
          initialAmount -= preTxn.amount;
          continue;
        }

        initialAmount += preTxn.amount;
        continue;
      }

      break;
    }

    if (transferTransactionsList != null) {
      final txnTransferMaxIndex = transferTransactionsList.length - 1;
      final transferTxnList = transferTransactionsList;

      for (int i = 0; i <= txnTransferMaxIndex; i++) {
        final preTxn = transferTxnList[i];
        if ((preTxn as BaseTransaction).dateTime.isBefore(dayBegin.onlyYearMonthDay)) {
          if (preTxn is CreditPayment) {
            initialAmount -= preTxn.amount;
            continue;
          }

          if (preTxn is Transfer) {
            initialAmount += preTxn.amount;
            continue;
          }
        }

        break;
      }
    }

    return initialAmount;
  }

  /// This function returns a map, which key is a date and value is the money amount
  /// in that date.
  ///
  /// The [updateAmountLogic] is used to give logic for how the money amount is changed
  /// for each transaction in the list.
  ///
  ///
  /// ### EXAMPLE:
  /// ```
  /// updateAmountLogic: (txn, value) {
  ///         if (txn is CreditPayment || txn is Expense) {
  ///           return value - txn.amount;
  ///         }
  ///
  ///         if (txn is Transfer) {
  ///           if (txn.account.id == regularAccount.id) {
  ///             return value - txn.amount;
  ///           }
  ///           if (txn.transferAccount.id == regularAccount.id) {
  ///             return value + txn.amount;
  ///           }
  ///         }
  ///
  ///         return value + txn.amount;
  ///       },
  /// ```
  Map<DateTime, double> _getValueInEachDateMap(
    DateTimeRange range,
    double initialAmount, {
    required List<BaseTransaction> txns,
    required double Function(BaseTransaction transaction, double value) updateAmountLogic,
  }) {
    final days = range.toList();

    Map<DateTime, double> result = {for (DateTime day in days) day: initialAmount};

    void updateAmount(DateTime day, BaseTransaction txn) {
      result.updateAll((key, value) {
        if (!key.isBefore(day)) {
          return updateAmountLogic(txn, value);
        }

        return value;
      });
    }

    if (txns.isNotEmpty) {
      for (int i = 0; i <= txns.length - 1; i++) {
        final txn = txns[i];
        final tDay = txn.dateTime.onlyYearMonthDay;

        if (tDay.isSameDayAs(days[0])) {
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

    return result;
  }

  ({double max, double min, double minAbs, double maxFromMin}) _getMaxMin(List<Map<DateTime, double>> mapList) {
    double max = double.negativeInfinity;
    double min = 0;

    for (var map in mapList) {
      for (var entry in map.entries) {
        if (entry.value > max) {
          max = entry.value;
        }
        if (entry.value < min) {
          min = entry.value;
        }
      }
    }

    final minAbs = min.abs();

    final maxFromMin = max == min
        ? 0.0
        : max < 0.0 && min < 0.0
            ? min.abs() - max.abs()
            : max + minAbs;

    return (max: max, min: min, minAbs: minAbs, maxFromMin: maxFromMin);
  }

  double _getY(double amount, double minAbs, double maxFromMin) {
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
}

@immutable
class CLCData {
  final List<CLCSpot> spots;

  /// if type is totalAssets, average amount ever will be used to compare too.
  final double maxAmount;
  final double minAmount;

  const CLCData({required this.spots, required this.maxAmount, required this.minAmount});

  @override
  String toString() {
    return 'CLCData{spots: $spots, maxAmount: $maxAmount, minAmount: $minAmount}';
  }
}

class CLCData2 {
  final DateTimeRange range;

  final double maxAmount;
  final double minAmount;

  final List<CLCData2Line> lines;

  const CLCData2({
    required this.maxAmount,
    required this.minAmount,
    required this.range,
    required this.lines,
  });

  @override
  String toString() {
    return 'CLCData2{range: $range, maxAmount: $maxAmount, minAmount: $minAmount, lines: $lines}';
  }
}

class CLCDataForCredit extends CLCData {
  /// Only for credit: startDate -> statementDate -> dueDate
  final List<DateTime> dateTimesToShow;

  final double extraLineY;

  final double balanceRemaining;

  const CLCDataForCredit({
    required super.spots,
    required super.maxAmount,
    required super.minAmount,
    required this.dateTimesToShow,
    required this.extraLineY,
    required this.balanceRemaining,
  });
}

class CLCSpot extends FlSpot {
  /// Custom Line Chart Spot, use with [CustomLineChart]. This class extends [FlSpot],
  /// which has additional `amount` and `checkpoint` property.
  ///
  /// The X-axis represents day,
  ///
  /// The Y-axis represents the ratio of the `amount` at that point to the highest `amount`
  CLCSpot(super.x, super.y, {required this.amount, this.isToday = false, this.dateTime});

  /// To store original amount of y-axis
  final double amount;

  /// To store original value (as DateTime) of x-axis.
  ///
  /// If null, use x-axis to represent bottom labels.
  final DateTime? dateTime;

  /// Is the spot where line turn from solid to dashed.
  ///
  /// Only works when type is [_CustomLineType.solidToDashed]
  final bool isToday;
}

class CLCSpotForCredit extends CLCSpot {
  CLCSpotForCredit(
    super.x,
    super.y, {
    required super.amount,
    super.dateTime,
    super.isToday = false,
    required this.isStatementDay,
    required this.isPreviousDueDay,
  });

  final bool isStatementDay;
  final bool isPreviousDueDay;
}

class CLCData2Line {
  final List<CLCSpot> spots;
  final AccountInfo accountInfo;

  CLCData2Line(this.accountInfo, this.spots);
}

/////////////////// PROVIDERS //////////////////////////

final customLineChartServicesProvider = Provider<LineChartServices>(
  (ref) {
    final repo = ref.watch(transactionRepositoryRealmProvider);

    return LineChartServices(repo);
  },
);
