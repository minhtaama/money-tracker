part of 'transaction_base.dart';

@immutable
sealed class RegularTransaction extends Transaction {
  @override
  final RegularAccount? account;

  const RegularTransaction(super.isarObject, super.dateTime, super.amount, super.note, this.account);
}

@immutable
class Expense extends RegularTransaction implements TransactionWithCategory {
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
class Income extends RegularTransaction implements TransactionWithCategory {
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
class Transfer extends RegularTransaction {
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

  static Fee? _fromIsar(TransactionIsar txn) {
    if (txn.transferFeeIsar == null) {
      return null;
    }
    return Fee(txn.transferFeeIsar!.amount, txn.transferFeeIsar!.onDestination);
  }

  const Fee(this.amount, this.onDestination);
}
