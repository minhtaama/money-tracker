// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_dto.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class AccountDb extends _AccountDb with RealmEntity, RealmObjectBase, RealmObject {
  AccountDb(
    ObjectId id,
    int type,
    String name,
    int colorIndex,
    String iconCategory,
    int iconIndex, {
    int? order,
    CreditDetailsDb? creditDetails,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'colorIndex', colorIndex);
    RealmObjectBase.set(this, 'iconCategory', iconCategory);
    RealmObjectBase.set(this, 'iconIndex', iconIndex);
    RealmObjectBase.set(this, 'order', order);
    RealmObjectBase.set(this, 'creditDetails', creditDetails);
  }

  AccountDb._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get colorIndex => RealmObjectBase.get<int>(this, 'colorIndex') as int;
  @override
  set colorIndex(int value) => RealmObjectBase.set(this, 'colorIndex', value);

  @override
  String get iconCategory => RealmObjectBase.get<String>(this, 'iconCategory') as String;
  @override
  set iconCategory(String value) => RealmObjectBase.set(this, 'iconCategory', value);

  @override
  int get iconIndex => RealmObjectBase.get<int>(this, 'iconIndex') as int;
  @override
  set iconIndex(int value) => RealmObjectBase.set(this, 'iconIndex', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  CreditDetailsDb? get creditDetails => RealmObjectBase.get<CreditDetailsDb>(this, 'creditDetails') as CreditDetailsDb?;
  @override
  set creditDetails(covariant CreditDetailsDb? value) => RealmObjectBase.set(this, 'creditDetails', value);

  @override
  RealmResults<TransactionDb> get transactions {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TransactionDb>(this, 'transactions') as RealmResults<TransactionDb>;
  }

  @override
  set transactions(covariant RealmResults<TransactionDb> value) => throw RealmUnsupportedSetError();

  @override
  RealmResults<TransactionDb> get transferTransactions {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TransactionDb>(this, 'transferTransactions') as RealmResults<TransactionDb>;
  }

  @override
  set transferTransactions(covariant RealmResults<TransactionDb> value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AccountDb>> get changes => RealmObjectBase.getChanges<AccountDb>(this);

  @override
  AccountDb freeze() => RealmObjectBase.freezeObject<AccountDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AccountDb._);
    return const SchemaObject(ObjectType.realmObject, AccountDb, 'AccountDb', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('colorIndex', RealmPropertyType.int),
      SchemaProperty('iconCategory', RealmPropertyType.string),
      SchemaProperty('iconIndex', RealmPropertyType.int),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
      SchemaProperty('creditDetails', RealmPropertyType.object, optional: true, linkTarget: 'CreditDetailsDb'),
      SchemaProperty('transactions', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'account', collectionType: RealmCollectionType.list, linkTarget: 'TransactionDb'),
      SchemaProperty('transferTransactions', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'transferAccount', collectionType: RealmCollectionType.list, linkTarget: 'TransactionDb'),
    ]);
  }
}

class CreditDetailsDb extends _CreditDetailsDb with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  CreditDetailsDb(
    double creditBalance,
    int statementDay,
    int paymentDueDay, {
    double apr = 5,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CreditDetailsDb>({
        'apr': 5,
      });
    }
    RealmObjectBase.set(this, 'creditBalance', creditBalance);
    RealmObjectBase.set(this, 'apr', apr);
    RealmObjectBase.set(this, 'statementDay', statementDay);
    RealmObjectBase.set(this, 'paymentDueDay', paymentDueDay);
  }

  CreditDetailsDb._();

  @override
  double get creditBalance => RealmObjectBase.get<double>(this, 'creditBalance') as double;
  @override
  set creditBalance(double value) => RealmObjectBase.set(this, 'creditBalance', value);

  @override
  double get apr => RealmObjectBase.get<double>(this, 'apr') as double;
  @override
  set apr(double value) => RealmObjectBase.set(this, 'apr', value);

  @override
  int get statementDay => RealmObjectBase.get<int>(this, 'statementDay') as int;
  @override
  set statementDay(int value) => RealmObjectBase.set(this, 'statementDay', value);

  @override
  int get paymentDueDay => RealmObjectBase.get<int>(this, 'paymentDueDay') as int;
  @override
  set paymentDueDay(int value) => RealmObjectBase.set(this, 'paymentDueDay', value);

  @override
  Stream<RealmObjectChanges<CreditDetailsDb>> get changes => RealmObjectBase.getChanges<CreditDetailsDb>(this);

  @override
  CreditDetailsDb freeze() => RealmObjectBase.freezeObject<CreditDetailsDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CreditDetailsDb._);
    return const SchemaObject(ObjectType.embeddedObject, CreditDetailsDb, 'CreditDetailsDb', [
      SchemaProperty('creditBalance', RealmPropertyType.double),
      SchemaProperty('apr', RealmPropertyType.double),
      SchemaProperty('statementDay', RealmPropertyType.int),
      SchemaProperty('paymentDueDay', RealmPropertyType.int),
    ]);
  }
}

class CategoryDb extends _CategoryDb with RealmEntity, RealmObjectBase, RealmObject {
  CategoryDb(
    ObjectId id,
    int type,
    String name,
    int colorIndex,
    String iconCategory,
    int iconIndex, {
    int? order,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'colorIndex', colorIndex);
    RealmObjectBase.set(this, 'iconCategory', iconCategory);
    RealmObjectBase.set(this, 'iconIndex', iconIndex);
    RealmObjectBase.set(this, 'order', order);
  }

  CategoryDb._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  int get colorIndex => RealmObjectBase.get<int>(this, 'colorIndex') as int;
  @override
  set colorIndex(int value) => RealmObjectBase.set(this, 'colorIndex', value);

  @override
  String get iconCategory => RealmObjectBase.get<String>(this, 'iconCategory') as String;
  @override
  set iconCategory(String value) => RealmObjectBase.set(this, 'iconCategory', value);

  @override
  int get iconIndex => RealmObjectBase.get<int>(this, 'iconIndex') as int;
  @override
  set iconIndex(int value) => RealmObjectBase.set(this, 'iconIndex', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  RealmResults<CategoryTagDb> get tags {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<CategoryTagDb>(this, 'tags') as RealmResults<CategoryTagDb>;
  }

  @override
  set tags(covariant RealmResults<CategoryTagDb> value) => throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<CategoryDb>> get changes => RealmObjectBase.getChanges<CategoryDb>(this);

  @override
  CategoryDb freeze() => RealmObjectBase.freezeObject<CategoryDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CategoryDb._);
    return const SchemaObject(ObjectType.realmObject, CategoryDb, 'CategoryDb', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('colorIndex', RealmPropertyType.int),
      SchemaProperty('iconCategory', RealmPropertyType.string),
      SchemaProperty('iconIndex', RealmPropertyType.int),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
      SchemaProperty('tags', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'category', collectionType: RealmCollectionType.list, linkTarget: 'CategoryTagDb'),
    ]);
  }
}

class CategoryTagDb extends _CategoryTagDb with RealmEntity, RealmObjectBase, RealmObject {
  CategoryTagDb(
    ObjectId id,
    String name, {
    CategoryDb? category,
    int? order,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'order', order);
  }

  CategoryTagDb._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  CategoryDb? get category => RealmObjectBase.get<CategoryDb>(this, 'category') as CategoryDb?;
  @override
  set category(covariant CategoryDb? value) => RealmObjectBase.set(this, 'category', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  Stream<RealmObjectChanges<CategoryTagDb>> get changes => RealmObjectBase.getChanges<CategoryTagDb>(this);

  @override
  CategoryTagDb freeze() => RealmObjectBase.freezeObject<CategoryTagDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CategoryTagDb._);
    return const SchemaObject(ObjectType.realmObject, CategoryTagDb, 'CategoryTagDb', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('category', RealmPropertyType.object, optional: true, linkTarget: 'CategoryDb'),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
    ]);
  }
}

class TransactionDb extends _TransactionDb with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TransactionDb(
    ObjectId id,
    int type,
    DateTime dateTime,
    double amount, {
    String? note,
    AccountDb? account,
    CategoryDb? category,
    CategoryTagDb? categoryTag,
    bool isInitialTransaction = false,
    AccountDb? transferAccount,
    TransferFeeDb? transferFee,
    CreditPaymentDetails? creditPaymentDetails,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TransactionDb>({
        'isInitialTransaction': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'dateTime', dateTime);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'note', note);
    RealmObjectBase.set(this, 'account', account);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'categoryTag', categoryTag);
    RealmObjectBase.set(this, 'isInitialTransaction', isInitialTransaction);
    RealmObjectBase.set(this, 'transferAccount', transferAccount);
    RealmObjectBase.set(this, 'transferFee', transferFee);
    RealmObjectBase.set(this, 'creditPaymentDetails', creditPaymentDetails);
  }

  TransactionDb._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get dateTime => RealmObjectBase.get<DateTime>(this, 'dateTime') as DateTime;
  @override
  set dateTime(DateTime value) => RealmObjectBase.set(this, 'dateTime', value);

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String? get note => RealmObjectBase.get<String>(this, 'note') as String?;
  @override
  set note(String? value) => RealmObjectBase.set(this, 'note', value);

  @override
  AccountDb? get account => RealmObjectBase.get<AccountDb>(this, 'account') as AccountDb?;
  @override
  set account(covariant AccountDb? value) => RealmObjectBase.set(this, 'account', value);

  @override
  CategoryDb? get category => RealmObjectBase.get<CategoryDb>(this, 'category') as CategoryDb?;
  @override
  set category(covariant CategoryDb? value) => RealmObjectBase.set(this, 'category', value);

  @override
  CategoryTagDb? get categoryTag => RealmObjectBase.get<CategoryTagDb>(this, 'categoryTag') as CategoryTagDb?;
  @override
  set categoryTag(covariant CategoryTagDb? value) => RealmObjectBase.set(this, 'categoryTag', value);

  @override
  bool get isInitialTransaction => RealmObjectBase.get<bool>(this, 'isInitialTransaction') as bool;
  @override
  set isInitialTransaction(bool value) => RealmObjectBase.set(this, 'isInitialTransaction', value);

  @override
  AccountDb? get transferAccount => RealmObjectBase.get<AccountDb>(this, 'transferAccount') as AccountDb?;
  @override
  set transferAccount(covariant AccountDb? value) => RealmObjectBase.set(this, 'transferAccount', value);

  @override
  TransferFeeDb? get transferFee => RealmObjectBase.get<TransferFeeDb>(this, 'transferFee') as TransferFeeDb?;
  @override
  set transferFee(covariant TransferFeeDb? value) => RealmObjectBase.set(this, 'transferFee', value);

  @override
  CreditPaymentDetails? get creditPaymentDetails =>
      RealmObjectBase.get<CreditPaymentDetails>(this, 'creditPaymentDetails') as CreditPaymentDetails?;
  @override
  set creditPaymentDetails(covariant CreditPaymentDetails? value) =>
      RealmObjectBase.set(this, 'creditPaymentDetails', value);

  @override
  Stream<RealmObjectChanges<TransactionDb>> get changes => RealmObjectBase.getChanges<TransactionDb>(this);

  @override
  TransactionDb freeze() => RealmObjectBase.freezeObject<TransactionDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TransactionDb._);
    return const SchemaObject(ObjectType.realmObject, TransactionDb, 'TransactionDb', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('dateTime', RealmPropertyType.timestamp, indexType: RealmIndexType.regular),
      SchemaProperty('amount', RealmPropertyType.double),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('account', RealmPropertyType.object, optional: true, linkTarget: 'AccountDb'),
      SchemaProperty('category', RealmPropertyType.object, optional: true, linkTarget: 'CategoryDb'),
      SchemaProperty('categoryTag', RealmPropertyType.object, optional: true, linkTarget: 'CategoryTagDb'),
      SchemaProperty('isInitialTransaction', RealmPropertyType.bool),
      SchemaProperty('transferAccount', RealmPropertyType.object, optional: true, linkTarget: 'AccountDb'),
      SchemaProperty('transferFee', RealmPropertyType.object, optional: true, linkTarget: 'TransferFeeDb'),
      SchemaProperty('creditPaymentDetails', RealmPropertyType.object,
          optional: true, linkTarget: 'CreditPaymentDetails'),
    ]);
  }
}

class TransferFeeDb extends _TransferFeeDb with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  TransferFeeDb({
    double amount = 0,
    bool chargeOnDestination = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TransferFeeDb>({
        'amount': 0,
        'chargeOnDestination': false,
      });
    }
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'chargeOnDestination', chargeOnDestination);
  }

  TransferFeeDb._();

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  bool get chargeOnDestination => RealmObjectBase.get<bool>(this, 'chargeOnDestination') as bool;
  @override
  set chargeOnDestination(bool value) => RealmObjectBase.set(this, 'chargeOnDestination', value);

  @override
  Stream<RealmObjectChanges<TransferFeeDb>> get changes => RealmObjectBase.getChanges<TransferFeeDb>(this);

  @override
  TransferFeeDb freeze() => RealmObjectBase.freezeObject<TransferFeeDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TransferFeeDb._);
    return const SchemaObject(ObjectType.embeddedObject, TransferFeeDb, 'TransferFeeDb', [
      SchemaProperty('amount', RealmPropertyType.double),
      SchemaProperty('chargeOnDestination', RealmPropertyType.bool),
    ]);
  }
}

class CreditPaymentDetails extends _CreditPaymentDetails with RealmEntity, RealmObjectBase, EmbeddedObject {
  CreditPaymentDetails({
    int? monthsToPay,
    double? paymentAmount,
  }) {
    RealmObjectBase.set(this, 'monthsToPay', monthsToPay);
    RealmObjectBase.set(this, 'paymentAmount', paymentAmount);
  }

  CreditPaymentDetails._();

  @override
  int? get monthsToPay => RealmObjectBase.get<int>(this, 'monthsToPay') as int?;
  @override
  set monthsToPay(int? value) => RealmObjectBase.set(this, 'monthsToPay', value);

  @override
  double? get paymentAmount => RealmObjectBase.get<double>(this, 'paymentAmount') as double?;
  @override
  set paymentAmount(double? value) => RealmObjectBase.set(this, 'paymentAmount', value);

  @override
  Stream<RealmObjectChanges<CreditPaymentDetails>> get changes =>
      RealmObjectBase.getChanges<CreditPaymentDetails>(this);

  @override
  CreditPaymentDetails freeze() => RealmObjectBase.freezeObject<CreditPaymentDetails>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CreditPaymentDetails._);
    return const SchemaObject(ObjectType.embeddedObject, CreditPaymentDetails, 'CreditPaymentDetails', [
      SchemaProperty('monthsToPay', RealmPropertyType.int, optional: true),
      SchemaProperty('paymentAmount', RealmPropertyType.double, optional: true),
    ]);
  }
}

class SettingsDb extends _SettingsDb with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SettingsDb(
    int id, {
    int themeIndex = 0,
    int themeType = 0,
    int currencyIndex = 101,
    bool showBalanceInHomeScreen = true,
    bool showDecimalDigits = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SettingsDb>({
        'id': 0,
        'themeIndex': 0,
        'themeType': 0,
        'currencyIndex': 101,
        'showBalanceInHomeScreen': true,
        'showDecimalDigits': false,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'themeIndex', themeIndex);
    RealmObjectBase.set(this, 'themeType', themeType);
    RealmObjectBase.set(this, 'currencyIndex', currencyIndex);
    RealmObjectBase.set(this, 'showBalanceInHomeScreen', showBalanceInHomeScreen);
    RealmObjectBase.set(this, 'showDecimalDigits', showDecimalDigits);
  }

  SettingsDb._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;

  @override
  int get themeIndex => RealmObjectBase.get<int>(this, 'themeIndex') as int;
  @override
  set themeIndex(int value) => RealmObjectBase.set(this, 'themeIndex', value);

  @override
  int get themeType => RealmObjectBase.get<int>(this, 'themeType') as int;
  @override
  set themeType(int value) => RealmObjectBase.set(this, 'themeType', value);

  @override
  int get currencyIndex => RealmObjectBase.get<int>(this, 'currencyIndex') as int;
  @override
  set currencyIndex(int value) => RealmObjectBase.set(this, 'currencyIndex', value);

  @override
  bool get showBalanceInHomeScreen => RealmObjectBase.get<bool>(this, 'showBalanceInHomeScreen') as bool;
  @override
  set showBalanceInHomeScreen(bool value) => RealmObjectBase.set(this, 'showBalanceInHomeScreen', value);

  @override
  bool get showDecimalDigits => RealmObjectBase.get<bool>(this, 'showDecimalDigits') as bool;
  @override
  set showDecimalDigits(bool value) => RealmObjectBase.set(this, 'showDecimalDigits', value);

  @override
  Stream<RealmObjectChanges<SettingsDb>> get changes => RealmObjectBase.getChanges<SettingsDb>(this);

  @override
  SettingsDb freeze() => RealmObjectBase.freezeObject<SettingsDb>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(SettingsDb._);
    return const SchemaObject(ObjectType.realmObject, SettingsDb, 'SettingsDb', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('themeIndex', RealmPropertyType.int),
      SchemaProperty('themeType', RealmPropertyType.int),
      SchemaProperty('currencyIndex', RealmPropertyType.int),
      SchemaProperty('showBalanceInHomeScreen', RealmPropertyType.bool),
      SchemaProperty('showDecimalDigits', RealmPropertyType.bool),
    ]);
  }
}
