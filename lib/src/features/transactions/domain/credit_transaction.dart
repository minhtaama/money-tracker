part of 'transaction_base.dart';

sealed class BaseCreditTransaction extends BaseTransaction {
  const BaseCreditTransaction(
      super.databaseObject, super.dateTime, super.amount, super.note, super.account);
}

@immutable
class CreditSpending extends BaseCreditTransaction implements BaseTransactionWithCategory {
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
    super.account,
    this.category,
    this.categoryTag, {
    required this.installmentAmount,
  });

  @override
  String toString() {
    return 'CreditSpending{dateTime: $dateTime, amount: $amount}';
  }
}

@immutable
class CreditPayment extends BaseCreditTransaction {
  final Account? fromRegularAccount;

  const CreditPayment._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required this.fromRegularAccount,
  });
}

extension SpendingDetails on CreditSpending {
  bool get hasInstallment {
    return installmentAmount != null;
  }
}
