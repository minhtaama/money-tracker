part of 'statement.dart';

@immutable
class StatementWithAverageDailyBalance extends Statement {
  const StatementWithAverageDailyBalance._(
    super._spentInPrvGracePeriod,
    super._spentInBillingCycleAfterPrvGracePeriod,
    super._spentInGracePeriod,
    super._paidInPrvGracePeriodForCurStatement,
    super._paidInPrvGracePeriodForPrvStatement,
    super._paidInBillingCycleAfterPrvGracePeriod,
    super._paidInGracePeriod,
    super._averageDailyBalance, {
    required super.apr,
    required super.previousStatement,
    required super.startDate,
    required super.endDate,
    required super.dueDate,
    required super.transactionsInBillingCycle,
    required super.transactionsInGracePeriod,
  });

  factory StatementWithAverageDailyBalance._create({
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required int statementDay,
    required int paymentDueDay,
    required double apr,
    required List<BaseCreditTransaction> transactionsList,
  }) {
    final DateTime endDate = startDate.copyWith(month: startDate.month + 1, day: startDate.day - 1).onlyYearMonthDay;
    final DateTime dueDate = statementDay >= paymentDueDay
        ? startDate.copyWith(month: startDate.month + 2, day: paymentDueDay).onlyYearMonthDay
        : startDate.copyWith(month: startDate.month + 1, day: paymentDueDay).onlyYearMonthDay;

    List<BaseCreditTransaction> txnsInBillingCycle = List.empty(growable: true);
    List<BaseCreditTransaction> txnsInGracePeriod = List.empty(growable: true);
    double spentInPreviousGracePeriod = 0;
    double spentInBillingCycleAfterPreviousGracePeriod = 0;
    double spentInGracePeriod = 0;
    double paidInPreviousGracePeriodForThis = 0;
    double paidInPreviousGracePeriodForPrevious = 0;
    double paidInBillingCycleAfterPreviousGracePeriod = 0;
    double paidInGracePeriod = 0;

    double pendingOfPreviousStatement = previousStatement.pendingForGracePeriod;

    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.carryOverWithInterest;
    DateTime tCheckpointDateTime = startDate;

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
            spentInBillingCycleAfterPreviousGracePeriod += txn.amount;
          } else {
            spentInPreviousGracePeriod += txn.amount;
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
            paidInBillingCycleAfterPreviousGracePeriod += txn.amount;

            tCurrentBalance -= txn.amount;
          } else {
            paidInPreviousGracePeriodForPrevious += math.min(txn.amount, pendingOfPreviousStatement);
            paidInPreviousGracePeriodForThis += math.max(0, txn.amount - pendingOfPreviousStatement);
            pendingOfPreviousStatement = math.max(0, pendingOfPreviousStatement - paidInPreviousGracePeriodForPrevious);

            tCurrentBalance -= paidInPreviousGracePeriodForThis;
          }
        }
      }

      if (i >= 1) {
        tCheckpointDateTime = transactionsList[i - 1].dateTime;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);

    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    return StatementWithAverageDailyBalance._(
      spentInPreviousGracePeriod,
      spentInBillingCycleAfterPreviousGracePeriod,
      spentInGracePeriod,
      paidInPreviousGracePeriodForThis,
      paidInPreviousGracePeriodForPrevious,
      paidInBillingCycleAfterPreviousGracePeriod,
      paidInGracePeriod,
      averageDailyBalance,
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
