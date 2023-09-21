part of 'transaction_base.dart';

@immutable
class CreditSpending extends Transaction implements TransactionWithCategory {
  @override
  final CreditAccount? creditAccount;

  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  final double? installmentAmount;

  const CreditSpending._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    this.category,
    this.categoryTag, {
    required this.creditAccount,
    required this.installmentAmount,
  });
}

extension SpendingDetails on CreditSpending {
  List<CreditPayment> get paymentTransactions {
    final payments = <CreditPayment>[];
    for (TransactionIsar txn in isarObject.paymentTxnBacklinks.toList()) {
      payments.add(Transaction.fromIsar(txn) as CreditPayment);
    }
    return payments;
  }

  bool get isDone {
    return paidAmount >= amount;
  }

  bool get hasInstallment {
    return installmentAmount != null;
  }

  double get paidAmount {
    double paidAmount = 0;
    for (CreditPayment txn in paymentTransactions) {
      paidAmount += txn.amount;
    }
    return paidAmount;
  }

  double get minimumPaymentAmount {
    if (hasInstallment) {
      return paymentAmount;
    }
    return min(amount - paidAmount, amount * 5 / 100);
  }

  double get paymentAmount {
    if (hasInstallment) {
      return min(amount - paidAmount, installmentAmount!);
    }
    return amount - paidAmount;
  }
}
