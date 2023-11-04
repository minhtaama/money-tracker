part of 'statement.dart';

@immutable
class StatementWithAverageDailyBalance extends Statement {
  const StatementWithAverageDailyBalance._(
    this._interest,
    super._spentInBillingCycle,
    super._spentInBillingCycleExcludeInstallments,
    super._paidInBillingCycle,
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

  @override
  final double _interest;

  factory StatementWithAverageDailyBalance._create({
    required PreviousStatement previousStatement,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required double apr,
    required List<CreditSpending> installmentTransactionsToPay,
    required List<BaseCreditTransaction> txnsInBillingCycle,
    required List<BaseCreditTransaction> txnsInGracePeriod,
  }) {
    double totalSpentInBillingCycle = 0;
    double spentInBillingCycleExcludeInstallments = 0;
    double paidInBillingCycle = 0;
    double paidInGracePeriod = 0;

    //////////// TEMPORARY VARIABLES FOR THE LOOP /////////////////
    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement._balanceAtEndDate + previousStatement.interest;
    DateTime tCheckpointDateTime = startDate;
    //////////////////////////////////////////////////////////////

    for (int i = 0; i <= txnsInBillingCycle.length - 1; i++) {
      final txn = txnsInBillingCycle[i];

      if (txn is CreditSpending) {
        totalSpentInBillingCycle += txn.amount;

        if (!txn.hasInstallment) {
          spentInBillingCycleExcludeInstallments += txn.amount;
        }

        tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
        tCurrentBalance += txn.amount;
      }

      if (txn is CreditPayment) {
        paidInBillingCycle += txn.amount;

        tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
        tCurrentBalance -= txn.amount;
      }

      tCheckpointDateTime = txnsInBillingCycle[i].dateTime;
    }

    for (int i = 0; i <= txnsInGracePeriod.length - 1; i++) {
      final txn = txnsInGracePeriod[i];

      if (txn is CreditPayment) {
        paidInGracePeriod += txn.amount;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);

    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    // The interest of this statement
    double interest = averageDailyBalance * (apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

    return StatementWithAverageDailyBalance._(
      interest,
      totalSpentInBillingCycle,
      spentInBillingCycleExcludeInstallments,
      paidInBillingCycle,
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
