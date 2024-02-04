part of 'base_class/statement.dart';

@immutable
class StatementPayOnlyInGracePeriod extends Statement {
  const StatementPayOnlyInGracePeriod._(
    this._interest, {
    required super.previousStatement,
    required super.spentInBillingCycle,
    required super.spentInBillingCycleExcludeInstallments,
    required super.spentInGracePeriod,
    required super.spentInGracePeriodExcludeInstallments,
    required super.paidInBillingCycle,
    required super.paidInBillingCycleInPreviousGracePeriod,
    required super.paidInGracePeriod,
    required super.apr,
    required super.checkpoint,
    required super.startDate,
    required super.endDate,
    required super.dueDate,
    required super.installments,
    required super.transactionsInBillingCycle,
    required super.transactionsInGracePeriod,
  });

  factory StatementPayOnlyInGracePeriod._create({
    required PreviousStatement previousStatement,
    required Checkpoint? checkpoint,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime dueDate,
    required double apr,
    required List<Installment> installments,
    required List<BaseCreditTransaction> txnsInBillingCycle,
    required List<BaseCreditTransaction> txnsInGracePeriod,
  }) {
    double spentInBillingCycle = 0;
    double spentInBillingCycleExcludeInstallments = 0;
    double spentInGracePeriod = 0;
    double spentInGracePeriodExcludeInstallments = 0;
    double paidInBillingCycleInPreviousGracePeriod = 0;
    double paidInGracePeriod = 0;

    double installmentsAmount = 0;

    for (Installment inst in installments) {
      installmentsAmount += inst.txn.paymentAmount!;
    }

    //////////// TEMPORARY VARIABLES FOR THE LOOP TO CALCULATE INTEREST /////////////////
    // Calculate sum of daily balance from `tCheckpointDateTime` to current Txn DateTime
    // If this is the first Txn in the list, `tCheckpointDateTime` is `Statement.startDate`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.balanceAtEndDate +
        previousStatement.interestToThisStatement +
        installmentsAmount;
    DateTime tCheckpointDateTime = startDate;
    //////////////////////////////////////////////////////////////

    for (int i = 0; i <= txnsInBillingCycle.length - 1; i++) {
      final txn = txnsInBillingCycle[i];

      if (txn is CreditSpending) {
        spentInBillingCycle += txn.amount;

        if (!txn.hasInstallment) {
          spentInBillingCycleExcludeInstallments += txn.amount;
        }

        tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
        tCurrentBalance += txn.amount;
      }

      if (txn is CreditPayment) {
        if (!txn.dateTime.isAfter(previousStatement.dueDate)) {
          paidInBillingCycleInPreviousGracePeriod += txn.afterAdjustedAmount;
        }

        tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(txn.dateTime);
        tCurrentBalance -= txn.amount;
      }

      tCheckpointDateTime = txnsInBillingCycle[i].dateTime;
    }

    for (int i = 0; i <= txnsInGracePeriod.length - 1; i++) {
      final txn = txnsInGracePeriod[i];

      if (txn is CreditSpending) {
        spentInGracePeriod += txn.amount;

        if (!txn.hasInstallment) {
          spentInGracePeriodExcludeInstallments += txn.amount;
        }
      }

      if (txn is CreditPayment) {
        paidInGracePeriod += txn.afterAdjustedAmount;
      }
    }

    tDailyBalanceSum += tCurrentBalance * tCheckpointDateTime.getDaysDifferent(endDate);

    double averageDailyBalance = tDailyBalanceSum / startDate.getDaysDifferent(endDate);

    // The interest of this statement
    double interest = averageDailyBalance * (apr / (365 * 100)) * startDate.getDaysDifferent(endDate);

    return StatementPayOnlyInGracePeriod._(
      interest,
      previousStatement: previousStatement,
      spentInBillingCycle: spentInBillingCycle,
      spentInBillingCycleExcludeInstallments: spentInBillingCycleExcludeInstallments,
      spentInGracePeriod: spentInGracePeriod,
      spentInGracePeriodExcludeInstallments: spentInGracePeriodExcludeInstallments,
      paidInBillingCycle: paidInBillingCycleInPreviousGracePeriod,
      paidInBillingCycleInPreviousGracePeriod: paidInBillingCycleInPreviousGracePeriod,
      paidInGracePeriod: paidInGracePeriod,
      checkpoint: checkpoint,
      startDate: startDate,
      endDate: endDate,
      dueDate: dueDate,
      installments: installments,
      transactionsInBillingCycle: txnsInBillingCycle,
      transactionsInGracePeriod: txnsInGracePeriod,
      apr: apr,
    );
  }

  @override
  final double _interest;

  /// The total amount of payment that is for this statement
  /// Will not be counted twice with payment-in-previous-grace-period amount
  /// for previous statement. Read the code for more understanding.
  @override
  double get paidForThisStatement => _paidInGracePeriod;

  @override
  double balanceToPayAt(DateTime dateTime) {
    if (dateTime.isBefore(statementDate)) {
      return 0;
    }

    final double x;

    if (checkpoint != null) {
      if (!dateTime.onlyYearMonthDay.isAfter(endDate)) {
        x = 0;
      } else {
        x = checkpoint!.unpaidToPay - _paidInGracePeriod;
      }
    } else {
      x = (spentToPayAtStartDate - _paidInBillingCycle) +
          interestFromPrevious +
          installmentsAmountToPay +
          spentInBillingCycleExcludeInstallments -
          _paidInGracePeriod;
    }

    if (x < 0) {
      return 0;
    } else {
      return double.parse(x.toStringAsFixed(2));
    }
  }
}
