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
  List<BaseRegularTransaction> get transactionsList {
    final List<BaseRegularTransaction> list = List.from(databaseObject.transactions
        .query('SORT(dateTime ASC)')
        .map<BaseRegularTransaction>((txn) => BaseTransaction.fromIsar(txn) as BaseRegularTransaction));
    // list.sort((a, b) {
    //   return a.dateTime.compareTo(b.dateTime);
    // });
    return list;
  }

  List<Transfer> get transferTransactionsList =>
      List.from(databaseObject.transferTransactions.map<Transfer>((txn) => BaseTransaction.fromIsar(txn) as Transfer));
}
