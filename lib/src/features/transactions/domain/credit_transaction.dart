part of 'transaction_base.dart';

sealed class BaseCreditTransaction extends BaseTransaction {
  const BaseCreditTransaction(
      super.databaseObject, super.dateTime, super.amount, super.note, super.account);
}

@immutable
class CreditSpending extends BaseCreditTransaction implements IBaseTransactionWithCategory {
  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  final int? monthsToPay;

  final double? paymentAmount;

  bool get hasInstallment => monthsToPay != null;

  const CreditSpending._(
    super._databaseObject,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditSpending &&
          runtimeType == other.runtimeType &&
          databaseObject.id == other.databaseObject.id;

  @override
  int get hashCode => databaseObject.id.hashCode;
}

@immutable
class CreditPayment extends BaseCreditTransaction implements ITransferable {
  @override
  final RegularAccount? transferAccount;

  final CreditPaymentType type;

  final double? adjustedBalance;

  const CreditPayment._(
    super._databaseObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required this.transferAccount,
    required this.type,
    required this.adjustedBalance,
  });
}

class CreditCheckpoint extends BaseCreditTransaction {
  final List<CreditSpending> finishedInstallments;

  const CreditCheckpoint._(
    super._databaseObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required this.finishedInstallments,
  });
}
