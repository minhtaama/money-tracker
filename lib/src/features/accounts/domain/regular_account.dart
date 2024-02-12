part of 'account_base.dart';

@immutable
class RegularAccount extends Account {
  @override
  final List<BaseRegularTransaction> transactionsList;

  final List<ITransferable> transferTransactionsList;

  static RegularAccount forAdjustmentCreditPayment() => RegularAccount._(
        AccountDb(ObjectId(), 0, '', 0, '', 0),
        name: 'Adjustment',
        iconColor: AppColors.black,
        backgroundColor: AppColors.white,
        iconPath: AppIcons.defaultIcon,
        transactionsList: const [],
        transferTransactionsList: const [],
      );

  const RegularAccount._(
    super.databaseObject, {
    required super.name,
    required super.iconColor,
    required super.backgroundColor,
    required super.iconPath,
    required this.transactionsList,
    required this.transferTransactionsList,
  });
}
