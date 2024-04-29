part of 'base_class/statement.dart';

@immutable
class StatementPayOnlyInGracePeriod extends Statement {
  const StatementPayOnlyInGracePeriod._(
    this._interest, {
    required super.previousStatement,
    required super.rawSpent,
    required super.rawPaid,
    required super.apr,
    required super.checkpoint,
    required super.date,
    required super.transactions,
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
    // If this is the first Txn in the list, `tCheckpointDateTime` is `statement.date.start`
    double tDailyBalanceSum = 0;
    // The current balance right before the point of this txn happens
    double tCurrentBalance = previousStatement.balanceAtEndDate + previousStatement.interest + installmentsAmount;
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
        if (!txn.dateTime.onlyYearMonthDay.isAfter(previousStatement.dueDate)) {
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
      rawSpent: (
        inBillingCycle: (all: spentInBillingCycle, toPay: spentInBillingCycleExcludeInstallments),
        inGracePeriod: (all: spentInGracePeriod, toPay: spentInGracePeriodExcludeInstallments)
      ),
      rawPaid: (
        inBillingCycle: (
          all: paidInBillingCycleInPreviousGracePeriod,
          inPreviousGracePeriod: paidInBillingCycleInPreviousGracePeriod
        ),
        inGracePeriod: paidInGracePeriod,
      ),
      checkpoint: checkpoint,
      date: (start: startDate, end: endDate, due: dueDate),
      transactions: (
        installmentsToPay: installments,
        inBillingCycle: txnsInBillingCycle,
        inGracePeriod: txnsInGracePeriod
      ),
      apr: apr,
    );
  }

  @override
  final double _interest;

  // @override
  // double get paid => _rawPaid.inGracePeriod;

  @override
  double balanceToPayAt(DateTime dateTime) {
    if (dateTime.isBefore(date.statement)) {
      return 0;
    }

    final double x;

    if (checkpoint != null) {
      if (!dateTime.onlyYearMonthDay.isAfter(date.end)) {
        x = 0;
      } else {
        x = checkpoint!.unpaidToPay - _rawPaid.inGracePeriod;
      }
    } else {
      x = carry.balanceToPay +
          carry.interest +
          installmentsToPay +
          _rawSpent.inBillingCycle.toPay -
          _rawPaid.inGracePeriod;
    }

    if (x < 0) {
      return 0;
    } else {
      return double.parse(x.toStringAsFixed(2));
    }
  }
}
