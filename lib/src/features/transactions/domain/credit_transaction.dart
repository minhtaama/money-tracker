part of 'transaction_base.dart';

sealed class BaseCreditTransaction extends BaseTransaction {
  const BaseCreditTransaction(super.databaseObject, super.dateTime, super.amount, super.note, super.account);
}

@immutable
class CreditSpending extends BaseCreditTransaction implements BaseTransactionWithCategory {
  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  final int? monthsToPay;

  final double? paymentAmount;

  bool get hasInstallment => monthsToPay != null;

  const CreditSpending._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this.category,
    this.categoryTag, {
    required this.monthsToPay,
    required this.paymentAmount,
  });

  @override
  String toString() {
    return 'CreditSpending{amount: $amount, paymentAmount: $paymentAmount, monthsToPay: $monthsToPay}';
  }
}

@immutable
class CreditPayment extends BaseCreditTransaction implements ITransferable {
  @override
  final RegularAccount? transferAccount;

  const CreditPayment._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required this.transferAccount,
  });
}
