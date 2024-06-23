part of 'account_base.dart';

@immutable
class SavingAccountInfo extends AccountInfo {
  const SavingAccountInfo._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    super.isNotExistInDatabase,
  });

  factory SavingAccountInfo.forAdjustmentCreditPayment() => SavingAccountInfo._(
        AccountDb(ObjectId(), 0, '', 0, '', 0),
        name: 'Auto-adjustment'.hardcoded,
        iconColor: AppColors.black,
        backgroundColor: AppColors.white,
        iconPath: AppIcons.defaultIcon,
        isNotExistInDatabase: true,
      );
}

@immutable
class SavingAccount extends Account {
  /// Transfer out of this saving account
  @override
  final List<Transfer> transactionsList;

  final List<Transfer> transferInList;

  final DateTime? targetDate;

  final double targetAmount;

  const SavingAccount._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.transactionsList,
    required this.transferInList,
    required this.targetDate,
    required this.targetAmount,
  });
}
