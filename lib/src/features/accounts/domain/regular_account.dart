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
  List<RegularTransaction> get transactionsList => List.from(isarObject.txnOfThisAccountBacklinks
      .map<RegularTransaction>((e) => Transaction.fromIsar(e) as RegularTransaction));

  List<Transfer> get transferTransactionsToThisAccountList =>
      List.from(isarObject.txnToThisAccountBacklinks.map<Transfer>((e) => Transaction.fromIsar(e) as Transfer));
}
