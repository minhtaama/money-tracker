part of 'transaction_base.dart';

sealed class BaseCreditTransaction extends BaseTransaction {
  const BaseCreditTransaction(
    super.databaseObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
  );
}

@immutable
class CreditSpending extends BaseCreditTransaction implements IBaseTransactionWithCategory {
  @override
  final Category? _category;

  @override
  Category get category => _category ?? DeletedCategory();

  @override
  final CategoryTag? categoryTag;

  final int? monthsToPay;

  final double? paymentAmount;

  final bool paymentStartFromNextStatement;

  bool get hasInstallment => monthsToPay != null;

  const CreditSpending._(
    super._databaseObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this._category,
    this.categoryTag, {
    required this.monthsToPay,
    required this.paymentAmount,
    required this.paymentStartFromNextStatement,
  });

  @override
  String toString() {
    return 'CreditSpending{amount: $amount, paymentAmount: $paymentAmount, monthsToPay: $monthsToPay}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreditSpending && runtimeType == other.runtimeType && databaseObject.id == other.databaseObject.id;

  @override
  int get hashCode => databaseObject.id.hashCode;
}

@immutable
class CreditPayment extends BaseCreditTransaction implements ITransferable {
  @override
  AccountInfo get transferAccount {
    if (_transferAccount != null) {
      return _transferAccount;
    }

    if (isAdjustToAPRChange) {
      return RegularAccountInfo.forAdjustmentCreditPayment();
    }

    return DeletedAccount();
  }

  @override
  String? get note => isAdjustToAPRChange
      ? 'Because the APR data of account "${account.name}" has been changed since it is first created, this transaction is created automatic to keep the balance of closed statements stay the same.'
          .hardcoded
      : super.note;

  final RegularAccountInfo? _transferAccount;

  final bool isFullPayment;

  final bool isAdjustToAPRChange;

  /// This value can be negative. Only used to calculate account balance
  final double adjustment;

  double get afterAdjustedAmount => amount + adjustment;

  const CreditPayment._(
    super._databaseObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required RegularAccountInfo? transferAccount,
    required this.isFullPayment,
    required this.isAdjustToAPRChange,
    required this.adjustment,
  }) : _transferAccount = transferAccount;
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
