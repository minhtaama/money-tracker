part of 'statement.dart';

@immutable
class Checkpoint {
  /// Can't be **negative**. The total of balance that user has spent at the checkpoint
  final double oustdBalance;

  /// Can't be **negative**. The total amount that haven't been paid of all installments in
  /// the statement has this checkpoint
  ///
  /// unpaidOfInstallment is always lower than `oustdBalance`, as the calculation of
  /// [_CreditAccountExtension._unpaidOfInstallmentsAtCheckpoint] in account_base.dart.
  final double unpaidOfInstallments;

  /// unpaidOfInstallment is always lower than `oustdBalance`, as the calculation of
  /// [_CreditAccountExtension._modifyInstallmentsAtCheckpoint] in account_base.dart.
  ///
  /// But we put `math.max()` to make sure it always has to.
  double get unpaidToPay => math.max(0, oustdBalance - unpaidOfInstallments);

  const Checkpoint(this.oustdBalance, this.unpaidOfInstallments);
}

@immutable
class Installment {
  final CreditSpending txn;

  /// This is not equal the [txn.monthsToPay] at the first
  /// payment month.
  ///
  /// **[monthsLeft] (at-first-payment-month) == [txn.monthsToPay!] - 1**
  ///
  /// **[monthsLeft] (at-last-payment-month) == 0**
  ///
  final int monthsLeft;

  double get unpaidAmount => txn.paymentAmount! * monthsLeft;

  const Installment(this.txn, this.monthsLeft);

  @override
  String toString() {
    return 'Installment{txn: $txn, monthsLeft: $monthsLeft}';
  }
}

typedef StmDateData = ({
  DateTime start,
  DateTime end,
  DateTime due,
  DateTime previousDue,
  DateTime statement,
});

typedef StmTxnsData = ({
  List<Installment> installmentsToPay,
  List<BaseCreditTransaction> inBillingCycle,
  List<BaseCreditTransaction> inGracePeriod,
});

typedef _StmRawSpentData = ({
  ({double all, double toPay}) inBillingCycle,
  ({double all, double toPay}) inGracePeriod,
});

typedef _StmRawPaidData = ({
  ({double all, double inPreviousGracePeriod}) inBillingCycle,
  double inGracePeriod,
});

typedef StmSpentData = ({
  ({double all, double toPay, double hasInstallment}) inBillingCycle,
  double inGracePeriod,
});

typedef StmCarryWithInterestData = ({
  double totalBalance,
  double balanceToPay,
  double interest,
});

typedef StmCarryWithoutInterestData = ({
  double totalBalance,
  double balanceToPay,
});

typedef StmEndPoint = ({double totalSpent, double spentToPay});

typedef StmStartPoint = ({double totalRemaining, double remainingToPay});
