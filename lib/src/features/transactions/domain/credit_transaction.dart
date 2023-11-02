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

  final double? installmentAmount;

  bool get hasInstallmentPayment => installmentAmount != null;

  const CreditSpending._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this.category,
    this.categoryTag, {
    required this.installmentAmount,
  });
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

extension SpendingDetails on CreditSpending {
  bool get hasInstallment {
    return installmentAmount != null;
  }
}
