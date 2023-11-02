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
    required super.installmentTransactionsToPay,
    required super.transactionsInBillingCycle,
    required super.transactionsInGracePeriod,
  });

  /// This is the interest of this statement, only add this value to next statement
  /// if this statement is not paid in full or previous statement has a carry over amount.
  @override
  final double _interest;

  factory StatementWithAverageDailyBalance._create({
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required double apr,
    required List<BaseCreditTransaction> installmentTransactionsToPay,
    required List<BaseCreditTransaction> transactionsList,
  }) {
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
      installmentTransactionsToPay: installmentTransactionsToPay,
      transactionsInBillingCycle: txnsInBillingCycle,
      transactionsInGracePeriod: txnsInGracePeriod,
      apr: apr,
    );
  }

  @override
  String toString() {
    return '{startDate: $startDate}';
  }
}
