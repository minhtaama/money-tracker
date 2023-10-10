part of 'transaction_base.dart';

@immutable
sealed class BaseRegularTransaction extends BaseTransaction {
  const BaseRegularTransaction(super.isarObject, super.dateTime, super.amount, super.note, super.account);
}

@immutable
class Expense extends BaseRegularTransaction implements BaseTransactionWithCategory {
  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  const Expense._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this.category,
    this.categoryTag,
  );
}

@immutable
class Income extends BaseRegularTransaction implements BaseTransactionWithCategory {
  @override
  final Category? category;

  @override
  final CategoryTag? categoryTag;

  final bool isInitialTransaction;

  const Income._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account,
    this.category,
    this.categoryTag, {
    required this.isInitialTransaction,
  });
}

@immutable
class Transfer extends BaseRegularTransaction {
  final RegularAccount? toAccount;
  final Fee? fee;

  const Transfer._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note,
    super.account, {
    required this.toAccount,
    required this.fee,
  });
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
