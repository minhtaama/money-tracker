part of 'transaction_base.dart';

@immutable
sealed class BaseRegularTransaction extends BaseTransaction {
  const BaseRegularTransaction(
      super.isarObject, super.dateTime, super.amount, super.note, super.account);

  abstract final TransactionType type;
}

@immutable
class Expense extends BaseRegularTransaction implements IBaseTransactionWithCategory {
  @override
  final TransactionType type = TransactionType.expense;

  @override
  final Category? _category;

  @override
  Category get category => _category != null ? _category! : DeletedCategory();

  @override
  final CategoryTag? categoryTag;

  const Expense._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this._category,
    this.categoryTag,
  );
}

@immutable
class Income extends BaseRegularTransaction implements IBaseTransactionWithCategory {
  @override
  final TransactionType type = TransactionType.income;

  @override
  final Category? _category;

  @override
  Category get category => _category != null ? _category! : DeletedCategory();

  @override
  final CategoryTag? categoryTag;

  final bool isInitialTransaction;

  const Income._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this._category,
    this.categoryTag, {
    required this.isInitialTransaction,
  });
}

@immutable
class Transfer extends BaseRegularTransaction implements ITransferable {
  @override
  final TransactionType type = TransactionType.transfer;

  @override
  AccountInfo get transferAccount => _transferAccount != null ? _transferAccount! : DeletedAccount();

  final RegularAccountInfo? _transferAccount;
  final Fee? fee;

  const Transfer._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required RegularAccountInfo? transferAccount,
    required this.fee,
  }) : _transferAccount = transferAccount;
}

@immutable
class Fee {
  final double amount;
  final bool onDestination;

  static Fee? _fromDatabase(TransactionDb txn) {
    if (txn.transferFee == null) {
      return null;
    }
    return Fee(txn.transferFee!.amount, txn.transferFee!.chargeOnDestination);
  }

  const Fee(this.amount, this.onDestination);
}
