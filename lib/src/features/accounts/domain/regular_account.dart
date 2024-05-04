part of 'account_base.dart';

@immutable
class RegularAccountInfo extends AccountInfo {
  const RegularAccountInfo._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    super.isNotExistInDatabase,
  });

  factory RegularAccountInfo.forAdjustmentCreditPayment() => RegularAccountInfo._(
        AccountDb(ObjectId(), 0, '', 0, '', 0),
        name: 'Auto-adjustment'.hardcoded,
        iconColor: AppColors.black,
        backgroundColor: AppColors.white,
        iconPath: AppIcons.defaultIcon,
        isNotExistInDatabase: true,
      );
}

@immutable
class RegularAccount extends Account {
  @override
  final List<BaseRegularTransaction> transactionsList;

  final List<ITransferable> transferTransactionsList;

  const RegularAccount._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.transactionsList,
    required this.transferTransactionsList,
  });

  AccountInfo toAccountInfo() {
    return Account.fromDatabaseInfoOnly(databaseObject)!;
  }
}
