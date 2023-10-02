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
class _AccountRealm implements _IColorAndIcon, _IOrderable {
  @PrimaryKey()
  late int id;

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
  @Backlink(#account)
  late Iterable<_TransactionRealm> transactions;

  /// Transactions that transfer to this account (need for calculating total money).
  /// Only for type [AccountType.regular].
  @Backlink(#transferTo)
  late Iterable<_TransactionRealm> transactionsToThisAccount;

  /// Only specify this property if type is [AccountType.credit]
  late _CreditDetailsRealm? creditDetails;
}

@RealmModel(ObjectType.embeddedObject)
class _CreditDetailsRealm {
  late double creditBalance;

  /// As in percent. This interestRate is only count
  /// if payment this month is not finish.
  double apr = 5;

  late int statementDay;

  late int paymentDueDay;
}

/////////////////////////////////////// CATEGORY ////////////////////////////////////

@RealmModel()
class _CategoryRealm implements _IOrderable, _IColorAndIcon {
  @PrimaryKey()
  late int id;

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

  late List<_CategoryTagRealm> tags;
}

@RealmModel(ObjectType.embeddedObject)
class _CategoryTagRealm {
  late String name;

  int? order;
}

/////////////////////////////////////// TRANSACTION ////////////////////////////////////

@RealmModel()
class _TransactionRealm {
  @PrimaryKey()
  late int id;

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
  /// 4, else == TransactionType.creditPayment
  late int type;

  late DateTime dateTime;

  late double amount;

  String? note;

  late _AccountRealm? account;

  /// **Only specify this if type is NOT [TransactionType.transfer]**
  late _CategoryRealm? category;

  /// **Only specify this if type is NOT [TransactionType.transfer]**
  late _CategoryTagRealm? categoryTag;

  /// Only specify this to `true` when **first creating new account**  and type is [TransactionType.income]**
  bool isInitialTransaction = false;

  /// **Only specify this if type is [TransactionType.transfer] and [TransactionType.creditPayment]**
  late _AccountRealm? transferTo;

  /// **Only specify this if type is [TransactionType.transfer]**
  _TransferFeeRealm? transferFee;

  /// Payments of this credit spending. **Only available if type is [TransactionType.creditSpending]**
  @Backlink(#spendingTransactions)
  late Iterable<_TransactionRealm> paymentTransactions;

  /// **Only specify this if type is [TransactionType.creditSpending]**
  double? installmentAmount;

  /// **Only specify this if type is [TransactionType.creditPayment]**
  late _TransactionRealm? spendingTransactions;
}

@RealmModel(ObjectType.embeddedObject)
class _TransferFeeRealm {
  double amount = 0;

  /// Specify this to `true` if the fee is charged on the destination account
  /// `false` if the fee is charge on the account has money transferred away
  bool chargeOnDestination = false;
}

/////////////////////////////////////////////// SETTINGS ////////////////////////////////////////////////
@RealmModel()
class _SettingsRealm {
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
}
