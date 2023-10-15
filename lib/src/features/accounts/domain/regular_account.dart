part of 'account_base.dart';

@immutable
class RegularAccount extends Account {
  @override
  final List<BaseRegularTransaction> transactionsList;

  // TODO: MAKE AN INTERFACE OF TRANSFER TRANSACTION (include Transfer and Credit Payment)
  final List<ITransferable> transferTransactionsList;

  const RegularAccount._(
    super.databaseObject, {
    required super.name,
    required super.color,
    required super.backgroundColor,
    required super.iconPath,
    required this.transactionsList,
    required this.transferTransactionsList,
  });

  // @override
  // List<BaseRegularTransaction> get transactionsList {
  //   final List<BaseRegularTransaction> list = List.from(databaseObject.transactions
  //       .query('SORT(dateTime ASC)')
  //       .map<BaseRegularTransaction>((txn) => BaseTransaction.fromIsar(txn) as BaseRegularTransaction));
  //   return list;
  // }

  // List<Transfer> get transferTransactionsList =>
  //     List.from(databaseObject.transferTransactions.map<Transfer>((txn) => BaseTransaction.fromIsar(txn) as Transfer));
}
