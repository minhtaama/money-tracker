import 'package:realm/realm.dart';
import '../src/utils/enums.dart';

part 'realm_dto.g.dart';

abstract interface class _IOrderable {
  int? order;
}

abstract interface class _IColorAndIcon {
  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;
}

/////////////////////////////////////// ACCOUNT ////////////////////////////////////

@RealmModel()
class _AccountDb implements _IColorAndIcon, _IOrderable {
  @PrimaryKey()
  late ObjectId id;

  /// Currently, Realm do not support Dart Enum
  ///
  /// 0 == AccountType.regular
  ///
  /// 1, else == AccountType.credit
  late int type;

  @override
  late String name;
  @override
  late int colorIndex;
  @override
  late String iconCategory;
  @override
  late int iconIndex;

  @override
  int? order;

  /// All transactions made from this account.
  /// If type is [AccountType.credit], then this property will only carry [TransactionType.creditSpending] and [TransactionType.creditPayment]
  /// If type is [AccountType.regular], then this property will only carry [TransactionType.expense], [TransactionType.income] and [TransactionType.transfer]
  @Backlink(#account)
  late Iterable<_TransactionDb> transactions;

  /// Transactions that transfer-to/away-to-pay-from this account (need for calculating total money).
  /// If type [AccountType.regular], only carry type [TransactionType.transfer]
  /// If type [AccountType.credit], only carry type [TransactionType.creditPayment]
  @Backlink(#transferAccount)
  late Iterable<_TransactionDb> transferTransactions;

  /// Only specify this property if type is [AccountType.credit]
  late _CreditDetailsDb? creditDetails;
}

@RealmModel(ObjectType.embeddedObject)
class _CreditDetailsDb {
  late double creditBalance;

  double apr = 5;

  late int statementDay;

  late int paymentDueDay;
}

/////////////////////////////////////// CATEGORY ////////////////////////////////////

@RealmModel()
class _CategoryDb implements _IOrderable, _IColorAndIcon {
  @PrimaryKey()
  late ObjectId id;

  /// Currently, Realm do not support Dart Enum
  ///
  /// 0 == CategoryType.expense
  ///
  /// 1, else == CategoryType.income
  late int type;

  @override
  late String name;
  @override
  late int colorIndex;
  @override
  late String iconCategory;
  @override
  late int iconIndex;

  @override
  int? order;

  @Backlink(#category)
  late Iterable<_CategoryTagDb> tags;
}

@RealmModel()
class _CategoryTagDb implements _IOrderable {
  @PrimaryKey()
  late ObjectId id;

  late String name;

  _CategoryDb? category;

  @override
  int? order;
}

/////////////////////////////////////// TRANSACTION ////////////////////////////////////

@RealmModel()
class _TransactionDb {
  @PrimaryKey()
  late ObjectId id;

  /// Currently, Realm do not support Dart Enum
  ///
  /// 0 == TransactionType.expense
  ///
  /// 1 == TransactionType.income
  ///
  /// 2 == TransactionType.transfer
  ///
  /// 3 == TransactionType.creditSpending
  ///
  /// 4 == TransactionType.creditPayment
  ///
  /// 5, else == TransactionType.creditCheckpoint
  late int type;

  @Indexed()
  late DateTime dateTime;

  late double amount;

  String? note;

  late _AccountDb? account;

  /// **Only specify this if type is NOT [TransactionType.transfer] and [TransactionType.creditPayment]**
  late _CategoryDb? category;

  /// **Only specify this if type is NOT [TransactionType.transfer] and [TransactionType.creditPayment]**
  late _CategoryTagDb? categoryTag;

  /// Only specify this to `true` when **first creating new Regular account**  and type is [TransactionType.income]**
  bool isInitialTransaction = false;

  /// **Only specify this if type is [TransactionType.transfer] and [TransactionType.creditPayment]**
  /// add value to account if Transaction is Transfer, minus value if creditPayment
  late _AccountDb? transferAccount;

  /// **Only specify this if type is [TransactionType.transfer]**
  _TransferFeeDb? transferFee;

  /// **Only specify this if type is [TransactionType.creditSpending]**
  _CreditInstallmentDetailsDb? creditInstallmentDetails;

  /// **Only specify this if type is [TransactionType.creditPayment]**
  _CreditPaymentDetailsDb? creditPaymentDetails;

  /// **Only specify this if type is [TransactionType.creditCheckpoint]**
  late List<_TransactionDb> creditCheckpointFinishedInstallments;
}

@RealmModel(ObjectType.embeddedObject)
class _TransferFeeDb {
  double amount = 0;

  /// Specify this to `true` if the fee is charged on the destination account
  /// `false` if the fee is charge on the account has money transferred away
  bool chargeOnDestination = false;
}

@RealmModel(ObjectType.embeddedObject)
class _CreditInstallmentDetailsDb {
  int? monthsToPay;

  double? paymentAmount;
}

@RealmModel(ObjectType.embeddedObject)
class _CreditPaymentDetailsDb {
  bool isFullPayment = false;

  double adjustment = 0;
}

///////////////////////////////////// SETTINGS AND PERSISTENT VALUES /////////////////////////////////
///////////////////////////////// ALL FIELDS MUST HAVE A DEFAULT VALUE ///////////////////////////////
@RealmModel()
class _SettingsDb {
  @PrimaryKey()
  final int id = 0;

  int themeIndex = 0;

  /// Currently, Realm do not support Dart Enum
  ///
  /// 0 == ThemeType.light
  ///
  /// 1 == ThemeType.dark
  ///
  /// 2, else == ThemeType.system
  int themeType = 0;

  /// Currently, Realm do not support Dart Enum
  int currencyIndex = 101; // Currency.usd

  bool showDecimalDigits = false;
}

@RealmModel()
class _PersistentValuesDb {
  @PrimaryKey()
  final int id = 0;

  // ChartDataType.cashflow => 0
  // ChartDataType.expense => 1
  // ChartDataType.income => 2, else
  int chartDataTypeInHomescreen = 0;

  bool showAmount = true;
}

@RealmModel()
class _BalanceAtDateTimeDb {
  @PrimaryKey()
  late ObjectId id;

  late DateTime date;

  late double amount;
}
