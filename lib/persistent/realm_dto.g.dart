// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_dto.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

class AccountRealm extends _AccountRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  AccountRealm(
    ObjectId id,
    int type,
    String name,
    int colorIndex,
    String iconCategory,
    int iconIndex, {
    int? order,
    CreditDetailsRealm? creditDetails,
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

  AccountRealm._();

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
  String get iconCategory =>
      RealmObjectBase.get<String>(this, 'iconCategory') as String;
  @override
  set iconCategory(String value) =>
      RealmObjectBase.set(this, 'iconCategory', value);

  @override
  int get iconIndex => RealmObjectBase.get<int>(this, 'iconIndex') as int;
  @override
  set iconIndex(int value) => RealmObjectBase.set(this, 'iconIndex', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  CreditDetailsRealm? get creditDetails =>
      RealmObjectBase.get<CreditDetailsRealm>(this, 'creditDetails')
          as CreditDetailsRealm?;
  @override
  set creditDetails(covariant CreditDetailsRealm? value) =>
      RealmObjectBase.set(this, 'creditDetails', value);

  @override
  RealmResults<TransactionRealm> get transactions {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TransactionRealm>(this, 'transactions')
        as RealmResults<TransactionRealm>;
  }

  @override
  set transactions(covariant RealmResults<TransactionRealm> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmResults<TransactionRealm> get transactionsToThisAccount {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TransactionRealm>(
        this, 'transactionsToThisAccount') as RealmResults<TransactionRealm>;
  }

  @override
  set transactionsToThisAccount(
          covariant RealmResults<TransactionRealm> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<AccountRealm>> get changes =>
      RealmObjectBase.getChanges<AccountRealm>(this);

  @override
  AccountRealm freeze() => RealmObjectBase.freezeObject<AccountRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(AccountRealm._);
    return const SchemaObject(
        ObjectType.realmObject, AccountRealm, 'AccountRealm', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('colorIndex', RealmPropertyType.int),
      SchemaProperty('iconCategory', RealmPropertyType.string),
      SchemaProperty('iconIndex', RealmPropertyType.int),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
      SchemaProperty('creditDetails', RealmPropertyType.object,
          optional: true, linkTarget: 'CreditDetailsRealm'),
      SchemaProperty('transactions', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'account',
          collectionType: RealmCollectionType.list,
          linkTarget: 'TransactionRealm'),
      SchemaProperty(
          'transactionsToThisAccount', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'transferTo',
          collectionType: RealmCollectionType.list,
          linkTarget: 'TransactionRealm'),
    ]);
  }
}

class CreditDetailsRealm extends _CreditDetailsRealm
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  CreditDetailsRealm(
    double creditBalance,
    int statementDay,
    int paymentDueDay, {
    double apr = 5,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CreditDetailsRealm>({
        'apr': 5,
      });
    }
    RealmObjectBase.set(this, 'creditBalance', creditBalance);
    RealmObjectBase.set(this, 'apr', apr);
    RealmObjectBase.set(this, 'statementDay', statementDay);
    RealmObjectBase.set(this, 'paymentDueDay', paymentDueDay);
  }

  CreditDetailsRealm._();

  @override
  double get creditBalance =>
      RealmObjectBase.get<double>(this, 'creditBalance') as double;
  @override
  set creditBalance(double value) =>
      RealmObjectBase.set(this, 'creditBalance', value);

  @override
  double get apr => RealmObjectBase.get<double>(this, 'apr') as double;
  @override
  set apr(double value) => RealmObjectBase.set(this, 'apr', value);

  @override
  int get statementDay => RealmObjectBase.get<int>(this, 'statementDay') as int;
  @override
  set statementDay(int value) =>
      RealmObjectBase.set(this, 'statementDay', value);

  @override
  int get paymentDueDay =>
      RealmObjectBase.get<int>(this, 'paymentDueDay') as int;
  @override
  set paymentDueDay(int value) =>
      RealmObjectBase.set(this, 'paymentDueDay', value);

  @override
  Stream<RealmObjectChanges<CreditDetailsRealm>> get changes =>
      RealmObjectBase.getChanges<CreditDetailsRealm>(this);

  @override
  CreditDetailsRealm freeze() =>
      RealmObjectBase.freezeObject<CreditDetailsRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CreditDetailsRealm._);
    return const SchemaObject(
        ObjectType.embeddedObject, CreditDetailsRealm, 'CreditDetailsRealm', [
      SchemaProperty('creditBalance', RealmPropertyType.double),
      SchemaProperty('apr', RealmPropertyType.double),
      SchemaProperty('statementDay', RealmPropertyType.int),
      SchemaProperty('paymentDueDay', RealmPropertyType.int),
    ]);
  }
}

class CategoryRealm extends _CategoryRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  CategoryRealm(
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

  CategoryRealm._();

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
  String get iconCategory =>
      RealmObjectBase.get<String>(this, 'iconCategory') as String;
  @override
  set iconCategory(String value) =>
      RealmObjectBase.set(this, 'iconCategory', value);

  @override
  int get iconIndex => RealmObjectBase.get<int>(this, 'iconIndex') as int;
  @override
  set iconIndex(int value) => RealmObjectBase.set(this, 'iconIndex', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  RealmResults<CategoryTagRealm> get tags {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<CategoryTagRealm>(this, 'tags')
        as RealmResults<CategoryTagRealm>;
  }

  @override
  set tags(covariant RealmResults<CategoryTagRealm> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<CategoryRealm>> get changes =>
      RealmObjectBase.getChanges<CategoryRealm>(this);

  @override
  CategoryRealm freeze() => RealmObjectBase.freezeObject<CategoryRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CategoryRealm._);
    return const SchemaObject(
        ObjectType.realmObject, CategoryRealm, 'CategoryRealm', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('colorIndex', RealmPropertyType.int),
      SchemaProperty('iconCategory', RealmPropertyType.string),
      SchemaProperty('iconIndex', RealmPropertyType.int),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
      SchemaProperty('tags', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'category',
          collectionType: RealmCollectionType.list,
          linkTarget: 'CategoryTagRealm'),
    ]);
  }
}

class CategoryTagRealm extends _CategoryTagRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  CategoryTagRealm(
    ObjectId id,
    String name, {
    CategoryRealm? category,
    int? order,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'category', category);
    RealmObjectBase.set(this, 'order', order);
  }

  CategoryTagRealm._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  CategoryRealm? get category =>
      RealmObjectBase.get<CategoryRealm>(this, 'category') as CategoryRealm?;
  @override
  set category(covariant CategoryRealm? value) =>
      RealmObjectBase.set(this, 'category', value);

  @override
  int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
  @override
  set order(int? value) => RealmObjectBase.set(this, 'order', value);

  @override
  Stream<RealmObjectChanges<CategoryTagRealm>> get changes =>
      RealmObjectBase.getChanges<CategoryTagRealm>(this);

  @override
  CategoryTagRealm freeze() =>
      RealmObjectBase.freezeObject<CategoryTagRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(CategoryTagRealm._);
    return const SchemaObject(
        ObjectType.realmObject, CategoryTagRealm, 'CategoryTagRealm', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('category', RealmPropertyType.object,
          optional: true, linkTarget: 'CategoryRealm'),
      SchemaProperty('order', RealmPropertyType.int, optional: true),
    ]);
  }
}

class TransactionRealm extends _TransactionRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TransactionRealm(
    ObjectId id,
    int type,
    DateTime dateTime,
    double amount, {
    String? note,
    AccountRealm? account,
    CategoryRealm? category,
    CategoryTagRealm? categoryTag,
    bool isInitialTransaction = false,
    AccountRealm? transferTo,
    TransferFeeRealm? transferFee,
    double? installmentAmount,
    TransactionRealm? spendingTransactions,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TransactionRealm>({
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
    RealmObjectBase.set(this, 'transferTo', transferTo);
    RealmObjectBase.set(this, 'transferFee', transferFee);
    RealmObjectBase.set(this, 'installmentAmount', installmentAmount);
    RealmObjectBase.set(this, 'spendingTransactions', spendingTransactions);
  }

  TransactionRealm._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

  @override
  int get type => RealmObjectBase.get<int>(this, 'type') as int;
  @override
  set type(int value) => RealmObjectBase.set(this, 'type', value);

  @override
  DateTime get dateTime =>
      RealmObjectBase.get<DateTime>(this, 'dateTime') as DateTime;
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
  AccountRealm? get account =>
      RealmObjectBase.get<AccountRealm>(this, 'account') as AccountRealm?;
  @override
  set account(covariant AccountRealm? value) =>
      RealmObjectBase.set(this, 'account', value);

  @override
  CategoryRealm? get category =>
      RealmObjectBase.get<CategoryRealm>(this, 'category') as CategoryRealm?;
  @override
  set category(covariant CategoryRealm? value) =>
      RealmObjectBase.set(this, 'category', value);

  @override
  CategoryTagRealm? get categoryTag =>
      RealmObjectBase.get<CategoryTagRealm>(this, 'categoryTag')
          as CategoryTagRealm?;
  @override
  set categoryTag(covariant CategoryTagRealm? value) =>
      RealmObjectBase.set(this, 'categoryTag', value);

  @override
  bool get isInitialTransaction =>
      RealmObjectBase.get<bool>(this, 'isInitialTransaction') as bool;
  @override
  set isInitialTransaction(bool value) =>
      RealmObjectBase.set(this, 'isInitialTransaction', value);

  @override
  AccountRealm? get transferTo =>
      RealmObjectBase.get<AccountRealm>(this, 'transferTo') as AccountRealm?;
  @override
  set transferTo(covariant AccountRealm? value) =>
      RealmObjectBase.set(this, 'transferTo', value);

  @override
  TransferFeeRealm? get transferFee =>
      RealmObjectBase.get<TransferFeeRealm>(this, 'transferFee')
          as TransferFeeRealm?;
  @override
  set transferFee(covariant TransferFeeRealm? value) =>
      RealmObjectBase.set(this, 'transferFee', value);

  @override
  double? get installmentAmount =>
      RealmObjectBase.get<double>(this, 'installmentAmount') as double?;
  @override
  set installmentAmount(double? value) =>
      RealmObjectBase.set(this, 'installmentAmount', value);

  @override
  TransactionRealm? get spendingTransactions =>
      RealmObjectBase.get<TransactionRealm>(this, 'spendingTransactions')
          as TransactionRealm?;
  @override
  set spendingTransactions(covariant TransactionRealm? value) =>
      RealmObjectBase.set(this, 'spendingTransactions', value);

  @override
  RealmResults<TransactionRealm> get paymentTransactions {
    if (!isManaged) {
      throw RealmError('Using backlinks is only possible for managed objects.');
    }
    return RealmObjectBase.get<TransactionRealm>(this, 'paymentTransactions')
        as RealmResults<TransactionRealm>;
  }

  @override
  set paymentTransactions(covariant RealmResults<TransactionRealm> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<TransactionRealm>> get changes =>
      RealmObjectBase.getChanges<TransactionRealm>(this);

  @override
  TransactionRealm freeze() =>
      RealmObjectBase.freezeObject<TransactionRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TransactionRealm._);
    return const SchemaObject(
        ObjectType.realmObject, TransactionRealm, 'TransactionRealm', [
      SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.int),
      SchemaProperty('dateTime', RealmPropertyType.timestamp),
      SchemaProperty('amount', RealmPropertyType.double),
      SchemaProperty('note', RealmPropertyType.string, optional: true),
      SchemaProperty('account', RealmPropertyType.object,
          optional: true, linkTarget: 'AccountRealm'),
      SchemaProperty('category', RealmPropertyType.object,
          optional: true, linkTarget: 'CategoryRealm'),
      SchemaProperty('categoryTag', RealmPropertyType.object,
          optional: true, linkTarget: 'CategoryTagRealm'),
      SchemaProperty('isInitialTransaction', RealmPropertyType.bool),
      SchemaProperty('transferTo', RealmPropertyType.object,
          optional: true, linkTarget: 'AccountRealm'),
      SchemaProperty('transferFee', RealmPropertyType.object,
          optional: true, linkTarget: 'TransferFeeRealm'),
      SchemaProperty('installmentAmount', RealmPropertyType.double,
          optional: true),
      SchemaProperty('spendingTransactions', RealmPropertyType.object,
          optional: true, linkTarget: 'TransactionRealm'),
      SchemaProperty('paymentTransactions', RealmPropertyType.linkingObjects,
          linkOriginProperty: 'spendingTransactions',
          collectionType: RealmCollectionType.list,
          linkTarget: 'TransactionRealm'),
    ]);
  }
}

class TransferFeeRealm extends _TransferFeeRealm
    with RealmEntity, RealmObjectBase, EmbeddedObject {
  static var _defaultsSet = false;

  TransferFeeRealm({
    double amount = 0,
    bool chargeOnDestination = false,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TransferFeeRealm>({
        'amount': 0,
        'chargeOnDestination': false,
      });
    }
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'chargeOnDestination', chargeOnDestination);
  }

  TransferFeeRealm._();

  @override
  double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
  @override
  set amount(double value) => RealmObjectBase.set(this, 'amount', value);

  @override
  bool get chargeOnDestination =>
      RealmObjectBase.get<bool>(this, 'chargeOnDestination') as bool;
  @override
  set chargeOnDestination(bool value) =>
      RealmObjectBase.set(this, 'chargeOnDestination', value);

  @override
  Stream<RealmObjectChanges<TransferFeeRealm>> get changes =>
      RealmObjectBase.getChanges<TransferFeeRealm>(this);

  @override
  TransferFeeRealm freeze() =>
      RealmObjectBase.freezeObject<TransferFeeRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(TransferFeeRealm._);
    return const SchemaObject(
        ObjectType.embeddedObject, TransferFeeRealm, 'TransferFeeRealm', [
      SchemaProperty('amount', RealmPropertyType.double),
      SchemaProperty('chargeOnDestination', RealmPropertyType.bool),
    ]);
  }
}

class SettingsRealm extends _SettingsRealm
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SettingsRealm(
    int id, {
    int themeIndex = 0,
    int themeType = 0,
    int currencyIndex = 101,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SettingsRealm>({
        'id': 0,
        'themeIndex': 0,
        'themeType': 0,
        'currencyIndex': 101,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'themeIndex', themeIndex);
    RealmObjectBase.set(this, 'themeType', themeType);
    RealmObjectBase.set(this, 'currencyIndex', currencyIndex);
  }

  SettingsRealm._();

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
  int get currencyIndex =>
      RealmObjectBase.get<int>(this, 'currencyIndex') as int;
  @override
  set currencyIndex(int value) =>
      RealmObjectBase.set(this, 'currencyIndex', value);

  @override
  Stream<RealmObjectChanges<SettingsRealm>> get changes =>
      RealmObjectBase.getChanges<SettingsRealm>(this);

  @override
  SettingsRealm freeze() => RealmObjectBase.freezeObject<SettingsRealm>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(SettingsRealm._);
    return const SchemaObject(
        ObjectType.realmObject, SettingsRealm, 'SettingsRealm', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('themeIndex', RealmPropertyType.int),
      SchemaProperty('themeType', RealmPropertyType.int),
      SchemaProperty('currencyIndex', RealmPropertyType.int),
    ]);
  }
}
