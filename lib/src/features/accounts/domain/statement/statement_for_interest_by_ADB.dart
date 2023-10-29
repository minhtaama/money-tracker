part of 'statement.dart';

@immutable
class StatementWithAverageDailyBalance extends Statement {
  const StatementWithAverageDailyBalance._(
    this._interest,
    super._spentInPrvGracePeriod,
    super._spentInBillingCycleAfterPrvGracePeriod,
    super._spentInGracePeriod,
    super._paidInPrvGracePeriodForCurStatement,
    super._paidInPrvGracePeriodForPrvStatement,
    super._paidInBillingCycleAfterPrvGracePeriod,
    super._paidInGracePeriod, {
    required super.apr,
    required super.previousStatement,
    required super.startDate,
    required super.endDate,
    required super.dueDate,
    required super.transactionsInBillingCycle,
    required super.transactionsInGracePeriod,
  });

  @override
  final double _interest;

  factory StatementWithAverageDailyBalance._create({
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required int statementDay,
    required int paymentDueDay,
    required double apr,
    required List<BaseCreditTransaction> transactionsList,
  }) {
    final DateTime endDate =
        startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;
    final DateTime dueDate = statementDay >= paymentDueDay
        ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
        : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

    List<BaseCreditTransaction> txnsInBillingCycle = List.empty(growable: true);
    List<BaseCreditTransaction> txnsInGracePeriod = List.empty(growable: true);
    double spentInPrvGracePeriod = 0;
    double spentInBillingCycleAfterPrvGracePeriod = 0;
    double spentInGracePeriod = 0;
    double paidInPrvGracePeriodForCurStatement = 0;
    double paidInPrvGracePeriodForPrvStatement = 0;
    double paidInBillingCycleAfterPrvGracePeriod = 0;
    double paidInGracePeriod = 0;

    //////////// TEMPORARY VARIABLES FOR THE LOOP /////////////////
    double tPendingOfPreviousStatement = previousStatement.balanceAtEndDate;
    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.carryOver;
    DateTime tCheckpointDateTime = startDate;
    //////////////////////////////////////////////////////////////

    for (int i = 0; i <= transactionsList.length - 1; i++) {
      final txn = transactionsList[i];

      if (txn.dateTime.isBefore(startDate)) {
        continue;
      }

      if (txn.dateTime.isAfter(dueDate.copyWith(day: dueDate.day + 1))) {
        if (i >= 1) {
          tCheckpointDateTime = transactionsList[i - 1].dateTime;
        }
        break;
      }

      if (txn is CreditSpending) {
        if (txn.dateTime.onlyYearMonthDay.isAfter(endDate)) {
          spentInGracePeriod += txn.amount;
          txnsInGracePeriod.add(txn);
        } else {
          if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
            spentInBillingCycleAfterPrvGracePeriod += txn.amount;
          } else {
            spentInPrvGracePeriod += txn.amount;
          }
          txnsInBillingCycle.add(txn);

          // Calculate tDailyBalanceSum before this txn happens
          tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
          tCurrentBalance += txn.amount;
        }
      }

      if (txn is CreditPayment) {
        if (txn.dateTime.onlyYearMonthDay.isAfter(endDate)) {
          paidInGracePeriod += txn.amount;
          txnsInGracePeriod.add(txn);
        } else {
          txnsInBillingCycle.add(txn);
          tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);

          if (txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
            paidInBillingCycleAfterPrvGracePeriod += txn.amount;

            tCurrentBalance -= txn.amount;
          } else {
            paidInPrvGracePeriodForPrvStatement += math.min(txn.amount, tPendingOfPreviousStatement);
            paidInPrvGracePeriodForCurStatement += math.max(0, txn.amount - tPendingOfPreviousStatement);
            tPendingOfPreviousStatement =
                math.max(0, tPendingOfPreviousStatement - paidInPrvGracePeriodForPrvStatement);

            tCurrentBalance -= paidInPrvGracePeriodForCurStatement;
          }
        }
      }

      if (i >= 1) {
        tCheckpointDateTime = transactionsList[i - 1].dateTime;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);
    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    // The interest of this statement
    double interest = averageDailyBalance * (apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

    return StatementWithAverageDailyBalance._(
      interest,
      spentInPrvGracePeriod,
      spentInBillingCycleAfterPrvGracePeriod,
      spentInGracePeriod,
      paidInPrvGracePeriodForCurStatement,
      paidInPrvGracePeriodForPrvStatement,
      paidInBillingCycleAfterPrvGracePeriod,
      paidInGracePeriod,
      previousStatement: previousStatement,
      startDate: startDate,
      endDate: endDate,
      dueDate: dueDate,
      transactionsInBillingCycle: txnsInBillingCycle,
      transactionsInGracePeriod: txnsInGracePeriod,
      apr: apr,
    );
  }
}
