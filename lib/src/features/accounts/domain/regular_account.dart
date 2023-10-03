part of 'account_base.dart';

@immutable
class RegularAccount extends Account {
  const RegularAccount._(
    super.isarObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
  });

  @override
  // TODO: implement transactionsList
  List<RegularTransaction> get transactionsList => List.from(databaseObject.transactions
      .map<RegularTransaction>((txn) => BaseTransaction.fromIsar(txn) as RegularTransaction));

  List<Transfer> get transferTransactionsToThisAccountList => List.from(
      databaseObject.transactionsToThisAccount.map<Transfer>((txn) => BaseTransaction.fromIsar(txn) as Transfer));
}
