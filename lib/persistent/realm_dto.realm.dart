// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realm_dto.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class AccountDb extends _AccountDb with RealmEntity, RealmObjectBase, RealmObject {
AccountDb(
ObjectId id,
int type,
String name,
int colorIndex,
String iconCategory,
int iconIndex,
{
int? order,
CreditDetailsDb? creditDetails,
}
) {
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
if (!isManaged) { throw RealmError('Using backlinks is only possible for managed objects.'); }
return RealmObjectBase.get<TransactionDb>(this, 'transactions') as RealmResults<TransactionDb>;}
@override
set transactions(covariant RealmResults<TransactionDb> value) => throw RealmUnsupportedSetError();

@override
RealmResults<TransactionDb> get transferTransactions {
if (!isManaged) { throw RealmError('Using backlinks is only possible for managed objects.'); }
return RealmObjectBase.get<TransactionDb>(this, 'transferTransactions') as RealmResults<TransactionDb>;}
@override
set transferTransactions(covariant RealmResults<TransactionDb> value) => throw RealmUnsupportedSetError();

@override
Stream<RealmObjectChanges<AccountDb>> get changes => RealmObjectBase.getChanges<AccountDb>(this);

@override
Stream<RealmObjectChanges<AccountDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<AccountDb>(this, keyPaths);

@override
AccountDb freeze() => RealmObjectBase.freezeObject<AccountDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'name': name.toEJson(),
'colorIndex': colorIndex.toEJson(),
'iconCategory': iconCategory.toEJson(),
'iconIndex': iconIndex.toEJson(),
'order': order.toEJson(),
'creditDetails': creditDetails.toEJson(),
};
}
static EJsonValue _toEJson(AccountDb value) => value.toEJson();
static AccountDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'name': EJsonValue name,
'colorIndex': EJsonValue colorIndex,
'iconCategory': EJsonValue iconCategory,
'iconIndex': EJsonValue iconIndex,
'order': EJsonValue order,
'creditDetails': EJsonValue creditDetails,
} => AccountDb(
fromEJson(id),
fromEJson(type),
fromEJson(name),
fromEJson(colorIndex),
fromEJson(iconCategory),
fromEJson(iconIndex),
order: fromEJson(order),
creditDetails: fromEJson(creditDetails),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(AccountDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, AccountDb, 'AccountDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('name', RealmPropertyType.string),
SchemaProperty('colorIndex', RealmPropertyType.int),
SchemaProperty('iconCategory', RealmPropertyType.string),
SchemaProperty('iconIndex', RealmPropertyType.int),
SchemaProperty('order', RealmPropertyType.int, optional: true),
SchemaProperty('creditDetails', RealmPropertyType.object, optional: true,linkTarget: 'CreditDetailsDb'),
SchemaProperty('transactions', RealmPropertyType.linkingObjects, linkOriginProperty: 'account',collectionType: RealmCollectionType.list,linkTarget: 'TransactionDb'),
SchemaProperty('transferTransactions', RealmPropertyType.linkingObjects, linkOriginProperty: 'transferAccount',collectionType: RealmCollectionType.list,linkTarget: 'TransactionDb'),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class CreditDetailsDb extends _CreditDetailsDb with RealmEntity, RealmObjectBase, EmbeddedObject {
static var _defaultsSet = false;

CreditDetailsDb(
double creditBalance,
int statementDay,
int paymentDueDay,
int statementType,
{
double apr = 5,
}
) {
if (!_defaultsSet) {
  _defaultsSet = RealmObjectBase.setDefaults<CreditDetailsDb>({
'apr': 5,
  });
}
RealmObjectBase.set(this, 'creditBalance', creditBalance);
RealmObjectBase.set(this, 'apr', apr);
RealmObjectBase.set(this, 'statementDay', statementDay);
RealmObjectBase.set(this, 'paymentDueDay', paymentDueDay);
RealmObjectBase.set(this, 'statementType', statementType);
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
int get statementType => RealmObjectBase.get<int>(this, 'statementType') as int;
@override
set statementType(int value) => RealmObjectBase.set(this, 'statementType', value);

@override
Stream<RealmObjectChanges<CreditDetailsDb>> get changes => RealmObjectBase.getChanges<CreditDetailsDb>(this);

@override
Stream<RealmObjectChanges<CreditDetailsDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<CreditDetailsDb>(this, keyPaths);

@override
CreditDetailsDb freeze() => RealmObjectBase.freezeObject<CreditDetailsDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'creditBalance': creditBalance.toEJson(),
'apr': apr.toEJson(),
'statementDay': statementDay.toEJson(),
'paymentDueDay': paymentDueDay.toEJson(),
'statementType': statementType.toEJson(),
};
}
static EJsonValue _toEJson(CreditDetailsDb value) => value.toEJson();
static CreditDetailsDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'creditBalance': EJsonValue creditBalance,
'apr': EJsonValue apr,
'statementDay': EJsonValue statementDay,
'paymentDueDay': EJsonValue paymentDueDay,
'statementType': EJsonValue statementType,
} => CreditDetailsDb(
fromEJson(creditBalance),
fromEJson(statementDay),
fromEJson(paymentDueDay),
fromEJson(statementType),
apr: fromEJson(apr),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(CreditDetailsDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.embeddedObject, CreditDetailsDb, 'CreditDetailsDb', [
SchemaProperty('creditBalance', RealmPropertyType.double),
SchemaProperty('apr', RealmPropertyType.double),
SchemaProperty('statementDay', RealmPropertyType.int),
SchemaProperty('paymentDueDay', RealmPropertyType.int),
SchemaProperty('statementType', RealmPropertyType.int),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class CategoryDb extends _CategoryDb with RealmEntity, RealmObjectBase, RealmObject {
CategoryDb(
ObjectId id,
int type,
String name,
int colorIndex,
String iconCategory,
int iconIndex,
{
int? order,
}
) {
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
if (!isManaged) { throw RealmError('Using backlinks is only possible for managed objects.'); }
return RealmObjectBase.get<CategoryTagDb>(this, 'tags') as RealmResults<CategoryTagDb>;}
@override
set tags(covariant RealmResults<CategoryTagDb> value) => throw RealmUnsupportedSetError();

@override
Stream<RealmObjectChanges<CategoryDb>> get changes => RealmObjectBase.getChanges<CategoryDb>(this);

@override
Stream<RealmObjectChanges<CategoryDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<CategoryDb>(this, keyPaths);

@override
CategoryDb freeze() => RealmObjectBase.freezeObject<CategoryDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'name': name.toEJson(),
'colorIndex': colorIndex.toEJson(),
'iconCategory': iconCategory.toEJson(),
'iconIndex': iconIndex.toEJson(),
'order': order.toEJson(),
};
}
static EJsonValue _toEJson(CategoryDb value) => value.toEJson();
static CategoryDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'name': EJsonValue name,
'colorIndex': EJsonValue colorIndex,
'iconCategory': EJsonValue iconCategory,
'iconIndex': EJsonValue iconIndex,
'order': EJsonValue order,
} => CategoryDb(
fromEJson(id),
fromEJson(type),
fromEJson(name),
fromEJson(colorIndex),
fromEJson(iconCategory),
fromEJson(iconIndex),
order: fromEJson(order),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(CategoryDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, CategoryDb, 'CategoryDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('name', RealmPropertyType.string),
SchemaProperty('colorIndex', RealmPropertyType.int),
SchemaProperty('iconCategory', RealmPropertyType.string),
SchemaProperty('iconIndex', RealmPropertyType.int),
SchemaProperty('order', RealmPropertyType.int, optional: true),
SchemaProperty('tags', RealmPropertyType.linkingObjects, linkOriginProperty: 'category',collectionType: RealmCollectionType.list,linkTarget: 'CategoryTagDb'),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class CategoryTagDb extends _CategoryTagDb with RealmEntity, RealmObjectBase, RealmObject {
CategoryTagDb(
ObjectId id,
String name,
{
CategoryDb? category,
int? order,
}
) {
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
Stream<RealmObjectChanges<CategoryTagDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<CategoryTagDb>(this, keyPaths);

@override
CategoryTagDb freeze() => RealmObjectBase.freezeObject<CategoryTagDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'name': name.toEJson(),
'category': category.toEJson(),
'order': order.toEJson(),
};
}
static EJsonValue _toEJson(CategoryTagDb value) => value.toEJson();
static CategoryTagDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'name': EJsonValue name,
'category': EJsonValue category,
'order': EJsonValue order,
} => CategoryTagDb(
fromEJson(id),
fromEJson(name),
category: fromEJson(category),
order: fromEJson(order),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(CategoryTagDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, CategoryTagDb, 'CategoryTagDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('name', RealmPropertyType.string),
SchemaProperty('category', RealmPropertyType.object, optional: true,linkTarget: 'CategoryDb'),
SchemaProperty('order', RealmPropertyType.int, optional: true),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class TransactionDb extends _TransactionDb with RealmEntity, RealmObjectBase, RealmObject {
static var _defaultsSet = false;

TransactionDb(
ObjectId id,
int type,
DateTime dateTime,
double amount,
{
String? note,
AccountDb? account,
CategoryDb? category,
CategoryTagDb? categoryTag,
bool isInitialTransaction = false,
AccountDb? transferAccount,
TransferFeeDb? transferFee,
CreditInstallmentDetailsDb? creditInstallmentDetails,
CreditPaymentDetailsDb? creditPaymentDetails,
Iterable<TransactionDb> creditCheckpointFinishedInstallments = const [],
RecurrenceDb? recurrence,
}
) {
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
RealmObjectBase.set(this, 'creditInstallmentDetails', creditInstallmentDetails);
RealmObjectBase.set(this, 'creditPaymentDetails', creditPaymentDetails);
RealmObjectBase.set<RealmList<TransactionDb>>(this, 'creditCheckpointFinishedInstallments', RealmList<TransactionDb>(creditCheckpointFinishedInstallments));
RealmObjectBase.set(this, 'recurrence', recurrence);
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
CreditInstallmentDetailsDb? get creditInstallmentDetails => RealmObjectBase.get<CreditInstallmentDetailsDb>(this, 'creditInstallmentDetails') as CreditInstallmentDetailsDb?;
@override
set creditInstallmentDetails(covariant CreditInstallmentDetailsDb? value) => RealmObjectBase.set(this, 'creditInstallmentDetails', value);

@override
CreditPaymentDetailsDb? get creditPaymentDetails => RealmObjectBase.get<CreditPaymentDetailsDb>(this, 'creditPaymentDetails') as CreditPaymentDetailsDb?;
@override
set creditPaymentDetails(covariant CreditPaymentDetailsDb? value) => RealmObjectBase.set(this, 'creditPaymentDetails', value);

@override
RealmList<TransactionDb> get creditCheckpointFinishedInstallments => RealmObjectBase.get<TransactionDb>(this, 'creditCheckpointFinishedInstallments') as RealmList<TransactionDb>;
@override
set creditCheckpointFinishedInstallments(covariant RealmList<TransactionDb> value) => throw RealmUnsupportedSetError();

@override
RecurrenceDb? get recurrence => RealmObjectBase.get<RecurrenceDb>(this, 'recurrence') as RecurrenceDb?;
@override
set recurrence(covariant RecurrenceDb? value) => RealmObjectBase.set(this, 'recurrence', value);

@override
Stream<RealmObjectChanges<TransactionDb>> get changes => RealmObjectBase.getChanges<TransactionDb>(this);

@override
Stream<RealmObjectChanges<TransactionDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<TransactionDb>(this, keyPaths);

@override
TransactionDb freeze() => RealmObjectBase.freezeObject<TransactionDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'dateTime': dateTime.toEJson(),
'amount': amount.toEJson(),
'note': note.toEJson(),
'account': account.toEJson(),
'category': category.toEJson(),
'categoryTag': categoryTag.toEJson(),
'isInitialTransaction': isInitialTransaction.toEJson(),
'transferAccount': transferAccount.toEJson(),
'transferFee': transferFee.toEJson(),
'creditInstallmentDetails': creditInstallmentDetails.toEJson(),
'creditPaymentDetails': creditPaymentDetails.toEJson(),
'creditCheckpointFinishedInstallments': creditCheckpointFinishedInstallments.toEJson(),
'recurrence': recurrence.toEJson(),
};
}
static EJsonValue _toEJson(TransactionDb value) => value.toEJson();
static TransactionDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'dateTime': EJsonValue dateTime,
'amount': EJsonValue amount,
'note': EJsonValue note,
'account': EJsonValue account,
'category': EJsonValue category,
'categoryTag': EJsonValue categoryTag,
'isInitialTransaction': EJsonValue isInitialTransaction,
'transferAccount': EJsonValue transferAccount,
'transferFee': EJsonValue transferFee,
'creditInstallmentDetails': EJsonValue creditInstallmentDetails,
'creditPaymentDetails': EJsonValue creditPaymentDetails,
'creditCheckpointFinishedInstallments': EJsonValue creditCheckpointFinishedInstallments,
'recurrence': EJsonValue recurrence,
} => TransactionDb(
fromEJson(id),
fromEJson(type),
fromEJson(dateTime),
fromEJson(amount),
note: fromEJson(note),
account: fromEJson(account),
category: fromEJson(category),
categoryTag: fromEJson(categoryTag),
isInitialTransaction: fromEJson(isInitialTransaction),
transferAccount: fromEJson(transferAccount),
transferFee: fromEJson(transferFee),
creditInstallmentDetails: fromEJson(creditInstallmentDetails),
creditPaymentDetails: fromEJson(creditPaymentDetails),
creditCheckpointFinishedInstallments: fromEJson(creditCheckpointFinishedInstallments),
recurrence: fromEJson(recurrence),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(TransactionDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, TransactionDb, 'TransactionDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('dateTime', RealmPropertyType.timestamp, indexType: RealmIndexType.regular),
SchemaProperty('amount', RealmPropertyType.double),
SchemaProperty('note', RealmPropertyType.string, optional: true),
SchemaProperty('account', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('category', RealmPropertyType.object, optional: true,linkTarget: 'CategoryDb'),
SchemaProperty('categoryTag', RealmPropertyType.object, optional: true,linkTarget: 'CategoryTagDb'),
SchemaProperty('isInitialTransaction', RealmPropertyType.bool),
SchemaProperty('transferAccount', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('transferFee', RealmPropertyType.object, optional: true,linkTarget: 'TransferFeeDb'),
SchemaProperty('creditInstallmentDetails', RealmPropertyType.object, optional: true,linkTarget: 'CreditInstallmentDetailsDb'),
SchemaProperty('creditPaymentDetails', RealmPropertyType.object, optional: true,linkTarget: 'CreditPaymentDetailsDb'),
SchemaProperty('creditCheckpointFinishedInstallments', RealmPropertyType.object, linkTarget: 'TransactionDb',collectionType: RealmCollectionType.list),
SchemaProperty('recurrence', RealmPropertyType.object, optional: true,linkTarget: 'RecurrenceDb'),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class TransferFeeDb extends _TransferFeeDb with RealmEntity, RealmObjectBase, EmbeddedObject {
static var _defaultsSet = false;

TransferFeeDb(
{
double amount = 0,
bool chargeOnDestination = false,
}
) {
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
Stream<RealmObjectChanges<TransferFeeDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<TransferFeeDb>(this, keyPaths);

@override
TransferFeeDb freeze() => RealmObjectBase.freezeObject<TransferFeeDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'amount': amount.toEJson(),
'chargeOnDestination': chargeOnDestination.toEJson(),
};
}
static EJsonValue _toEJson(TransferFeeDb value) => value.toEJson();
static TransferFeeDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'amount': EJsonValue amount,
'chargeOnDestination': EJsonValue chargeOnDestination,
} => TransferFeeDb(
amount: fromEJson(amount),
chargeOnDestination: fromEJson(chargeOnDestination),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(TransferFeeDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.embeddedObject, TransferFeeDb, 'TransferFeeDb', [
SchemaProperty('amount', RealmPropertyType.double),
SchemaProperty('chargeOnDestination', RealmPropertyType.bool),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class CreditInstallmentDetailsDb extends _CreditInstallmentDetailsDb with RealmEntity, RealmObjectBase, EmbeddedObject {
CreditInstallmentDetailsDb(
{
int? monthsToPay,
double? paymentAmount,
}
) {
RealmObjectBase.set(this, 'monthsToPay', monthsToPay);
RealmObjectBase.set(this, 'paymentAmount', paymentAmount);
}

CreditInstallmentDetailsDb._();

@override
int? get monthsToPay => RealmObjectBase.get<int>(this, 'monthsToPay') as int?;
@override
set monthsToPay(int? value) => RealmObjectBase.set(this, 'monthsToPay', value);

@override
double? get paymentAmount => RealmObjectBase.get<double>(this, 'paymentAmount') as double?;
@override
set paymentAmount(double? value) => RealmObjectBase.set(this, 'paymentAmount', value);

@override
Stream<RealmObjectChanges<CreditInstallmentDetailsDb>> get changes => RealmObjectBase.getChanges<CreditInstallmentDetailsDb>(this);

@override
Stream<RealmObjectChanges<CreditInstallmentDetailsDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<CreditInstallmentDetailsDb>(this, keyPaths);

@override
CreditInstallmentDetailsDb freeze() => RealmObjectBase.freezeObject<CreditInstallmentDetailsDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'monthsToPay': monthsToPay.toEJson(),
'paymentAmount': paymentAmount.toEJson(),
};
}
static EJsonValue _toEJson(CreditInstallmentDetailsDb value) => value.toEJson();
static CreditInstallmentDetailsDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'monthsToPay': EJsonValue monthsToPay,
'paymentAmount': EJsonValue paymentAmount,
} => CreditInstallmentDetailsDb(
monthsToPay: fromEJson(monthsToPay),
paymentAmount: fromEJson(paymentAmount),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(CreditInstallmentDetailsDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.embeddedObject, CreditInstallmentDetailsDb, 'CreditInstallmentDetailsDb', [
SchemaProperty('monthsToPay', RealmPropertyType.int, optional: true),
SchemaProperty('paymentAmount', RealmPropertyType.double, optional: true),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class CreditPaymentDetailsDb extends _CreditPaymentDetailsDb with RealmEntity, RealmObjectBase, EmbeddedObject {
static var _defaultsSet = false;

CreditPaymentDetailsDb(
{
bool isFullPayment = false,
bool isAdjustToAPRChanges = false,
double adjustment = 0,
}
) {
if (!_defaultsSet) {
  _defaultsSet = RealmObjectBase.setDefaults<CreditPaymentDetailsDb>({
'isFullPayment': false,
'isAdjustToAPRChanges': false,
'adjustment': 0,
  });
}
RealmObjectBase.set(this, 'isFullPayment', isFullPayment);
RealmObjectBase.set(this, 'isAdjustToAPRChanges', isAdjustToAPRChanges);
RealmObjectBase.set(this, 'adjustment', adjustment);
}

CreditPaymentDetailsDb._();

@override
bool get isFullPayment => RealmObjectBase.get<bool>(this, 'isFullPayment') as bool;
@override
set isFullPayment(bool value) => RealmObjectBase.set(this, 'isFullPayment', value);

@override
bool get isAdjustToAPRChanges => RealmObjectBase.get<bool>(this, 'isAdjustToAPRChanges') as bool;
@override
set isAdjustToAPRChanges(bool value) => RealmObjectBase.set(this, 'isAdjustToAPRChanges', value);

@override
double get adjustment => RealmObjectBase.get<double>(this, 'adjustment') as double;
@override
set adjustment(double value) => RealmObjectBase.set(this, 'adjustment', value);

@override
Stream<RealmObjectChanges<CreditPaymentDetailsDb>> get changes => RealmObjectBase.getChanges<CreditPaymentDetailsDb>(this);

@override
Stream<RealmObjectChanges<CreditPaymentDetailsDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<CreditPaymentDetailsDb>(this, keyPaths);

@override
CreditPaymentDetailsDb freeze() => RealmObjectBase.freezeObject<CreditPaymentDetailsDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'isFullPayment': isFullPayment.toEJson(),
'isAdjustToAPRChanges': isAdjustToAPRChanges.toEJson(),
'adjustment': adjustment.toEJson(),
};
}
static EJsonValue _toEJson(CreditPaymentDetailsDb value) => value.toEJson();
static CreditPaymentDetailsDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'isFullPayment': EJsonValue isFullPayment,
'isAdjustToAPRChanges': EJsonValue isAdjustToAPRChanges,
'adjustment': EJsonValue adjustment,
} => CreditPaymentDetailsDb(
isFullPayment: fromEJson(isFullPayment),
isAdjustToAPRChanges: fromEJson(isAdjustToAPRChanges),
adjustment: fromEJson(adjustment),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(CreditPaymentDetailsDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.embeddedObject, CreditPaymentDetailsDb, 'CreditPaymentDetailsDb', [
SchemaProperty('isFullPayment', RealmPropertyType.bool),
SchemaProperty('isAdjustToAPRChanges', RealmPropertyType.bool),
SchemaProperty('adjustment', RealmPropertyType.double),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class TemplateTransactionDb extends _TemplateTransactionDb with RealmEntity, RealmObjectBase, RealmObject {
TemplateTransactionDb(
ObjectId id,
int type,
{
DateTime? dateTime,
double? amount,
String? note,
AccountDb? account,
CategoryDb? category,
CategoryTagDb? categoryTag,
AccountDb? transferAccount,
TransferFeeDb? transferFee,
int? order,
}
) {
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'type', type);
RealmObjectBase.set(this, 'dateTime', dateTime);
RealmObjectBase.set(this, 'amount', amount);
RealmObjectBase.set(this, 'note', note);
RealmObjectBase.set(this, 'account', account);
RealmObjectBase.set(this, 'category', category);
RealmObjectBase.set(this, 'categoryTag', categoryTag);
RealmObjectBase.set(this, 'transferAccount', transferAccount);
RealmObjectBase.set(this, 'transferFee', transferFee);
RealmObjectBase.set(this, 'order', order);
}

TemplateTransactionDb._();

@override
ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
@override
set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

@override
int get type => RealmObjectBase.get<int>(this, 'type') as int;
@override
set type(int value) => RealmObjectBase.set(this, 'type', value);

@override
DateTime? get dateTime => RealmObjectBase.get<DateTime>(this, 'dateTime') as DateTime?;
@override
set dateTime(DateTime? value) => RealmObjectBase.set(this, 'dateTime', value);

@override
double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
@override
set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

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
AccountDb? get transferAccount => RealmObjectBase.get<AccountDb>(this, 'transferAccount') as AccountDb?;
@override
set transferAccount(covariant AccountDb? value) => RealmObjectBase.set(this, 'transferAccount', value);

@override
TransferFeeDb? get transferFee => RealmObjectBase.get<TransferFeeDb>(this, 'transferFee') as TransferFeeDb?;
@override
set transferFee(covariant TransferFeeDb? value) => RealmObjectBase.set(this, 'transferFee', value);

@override
int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
@override
set order(int? value) => RealmObjectBase.set(this, 'order', value);

@override
Stream<RealmObjectChanges<TemplateTransactionDb>> get changes => RealmObjectBase.getChanges<TemplateTransactionDb>(this);

@override
Stream<RealmObjectChanges<TemplateTransactionDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<TemplateTransactionDb>(this, keyPaths);

@override
TemplateTransactionDb freeze() => RealmObjectBase.freezeObject<TemplateTransactionDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'dateTime': dateTime.toEJson(),
'amount': amount.toEJson(),
'note': note.toEJson(),
'account': account.toEJson(),
'category': category.toEJson(),
'categoryTag': categoryTag.toEJson(),
'transferAccount': transferAccount.toEJson(),
'transferFee': transferFee.toEJson(),
'order': order.toEJson(),
};
}
static EJsonValue _toEJson(TemplateTransactionDb value) => value.toEJson();
static TemplateTransactionDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'dateTime': EJsonValue dateTime,
'amount': EJsonValue amount,
'note': EJsonValue note,
'account': EJsonValue account,
'category': EJsonValue category,
'categoryTag': EJsonValue categoryTag,
'transferAccount': EJsonValue transferAccount,
'transferFee': EJsonValue transferFee,
'order': EJsonValue order,
} => TemplateTransactionDb(
fromEJson(id),
fromEJson(type),
dateTime: fromEJson(dateTime),
amount: fromEJson(amount),
note: fromEJson(note),
account: fromEJson(account),
category: fromEJson(category),
categoryTag: fromEJson(categoryTag),
transferAccount: fromEJson(transferAccount),
transferFee: fromEJson(transferFee),
order: fromEJson(order),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(TemplateTransactionDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, TemplateTransactionDb, 'TemplateTransactionDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('dateTime', RealmPropertyType.timestamp, optional: true,indexType: RealmIndexType.regular),
SchemaProperty('amount', RealmPropertyType.double, optional: true),
SchemaProperty('note', RealmPropertyType.string, optional: true),
SchemaProperty('account', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('category', RealmPropertyType.object, optional: true,linkTarget: 'CategoryDb'),
SchemaProperty('categoryTag', RealmPropertyType.object, optional: true,linkTarget: 'CategoryTagDb'),
SchemaProperty('transferAccount', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('transferFee', RealmPropertyType.object, optional: true,linkTarget: 'TransferFeeDb'),
SchemaProperty('order', RealmPropertyType.int, optional: true),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class RecurrenceDb extends _RecurrenceDb with RealmEntity, RealmObjectBase, RealmObject {
static var _defaultsSet = false;

RecurrenceDb(
ObjectId id,
int type,
int repeatInterval,
DateTime startOn,
{
Iterable<DateTime> repeatOn = const [],
DateTime? endOn,
bool autoCreateTransaction = false,
TransactionDataDb? transactionData,
Iterable<DateTime> skippedOn = const [],
int? order,
}
) {
if (!_defaultsSet) {
  _defaultsSet = RealmObjectBase.setDefaults<RecurrenceDb>({
'autoCreateTransaction': false,
  });
}
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'type', type);
RealmObjectBase.set(this, 'repeatInterval', repeatInterval);
RealmObjectBase.set<RealmList<DateTime>>(this, 'repeatOn', RealmList<DateTime>(repeatOn));
RealmObjectBase.set(this, 'startOn', startOn);
RealmObjectBase.set(this, 'endOn', endOn);
RealmObjectBase.set(this, 'autoCreateTransaction', autoCreateTransaction);
RealmObjectBase.set(this, 'transactionData', transactionData);
RealmObjectBase.set<RealmList<DateTime>>(this, 'skippedOn', RealmList<DateTime>(skippedOn));
RealmObjectBase.set(this, 'order', order);
}

RecurrenceDb._();

@override
ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
@override
set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

@override
int get type => RealmObjectBase.get<int>(this, 'type') as int;
@override
set type(int value) => RealmObjectBase.set(this, 'type', value);

@override
int get repeatInterval => RealmObjectBase.get<int>(this, 'repeatInterval') as int;
@override
set repeatInterval(int value) => RealmObjectBase.set(this, 'repeatInterval', value);

@override
RealmList<DateTime> get repeatOn => RealmObjectBase.get<DateTime>(this, 'repeatOn') as RealmList<DateTime>;
@override
set repeatOn(covariant RealmList<DateTime> value) => throw RealmUnsupportedSetError();

@override
DateTime get startOn => RealmObjectBase.get<DateTime>(this, 'startOn') as DateTime;
@override
set startOn(DateTime value) => RealmObjectBase.set(this, 'startOn', value);

@override
DateTime? get endOn => RealmObjectBase.get<DateTime>(this, 'endOn') as DateTime?;
@override
set endOn(DateTime? value) => RealmObjectBase.set(this, 'endOn', value);

@override
bool get autoCreateTransaction => RealmObjectBase.get<bool>(this, 'autoCreateTransaction') as bool;
@override
set autoCreateTransaction(bool value) => RealmObjectBase.set(this, 'autoCreateTransaction', value);

@override
TransactionDataDb? get transactionData => RealmObjectBase.get<TransactionDataDb>(this, 'transactionData') as TransactionDataDb?;
@override
set transactionData(covariant TransactionDataDb? value) => RealmObjectBase.set(this, 'transactionData', value);

@override
RealmList<DateTime> get skippedOn => RealmObjectBase.get<DateTime>(this, 'skippedOn') as RealmList<DateTime>;
@override
set skippedOn(covariant RealmList<DateTime> value) => throw RealmUnsupportedSetError();

@override
int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
@override
set order(int? value) => RealmObjectBase.set(this, 'order', value);

@override
RealmResults<TransactionDb> get addedTransactions {
if (!isManaged) { throw RealmError('Using backlinks is only possible for managed objects.'); }
return RealmObjectBase.get<TransactionDb>(this, 'addedTransactions') as RealmResults<TransactionDb>;}
@override
set addedTransactions(covariant RealmResults<TransactionDb> value) => throw RealmUnsupportedSetError();

@override
Stream<RealmObjectChanges<RecurrenceDb>> get changes => RealmObjectBase.getChanges<RecurrenceDb>(this);

@override
Stream<RealmObjectChanges<RecurrenceDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<RecurrenceDb>(this, keyPaths);

@override
RecurrenceDb freeze() => RealmObjectBase.freezeObject<RecurrenceDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'repeatInterval': repeatInterval.toEJson(),
'repeatOn': repeatOn.toEJson(),
'startOn': startOn.toEJson(),
'endOn': endOn.toEJson(),
'autoCreateTransaction': autoCreateTransaction.toEJson(),
'transactionData': transactionData.toEJson(),
'skippedOn': skippedOn.toEJson(),
'order': order.toEJson(),
};
}
static EJsonValue _toEJson(RecurrenceDb value) => value.toEJson();
static RecurrenceDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'repeatInterval': EJsonValue repeatInterval,
'repeatOn': EJsonValue repeatOn,
'startOn': EJsonValue startOn,
'endOn': EJsonValue endOn,
'autoCreateTransaction': EJsonValue autoCreateTransaction,
'transactionData': EJsonValue transactionData,
'skippedOn': EJsonValue skippedOn,
'order': EJsonValue order,
} => RecurrenceDb(
fromEJson(id),
fromEJson(type),
fromEJson(repeatInterval),
fromEJson(startOn),
repeatOn: fromEJson(repeatOn),
endOn: fromEJson(endOn),
autoCreateTransaction: fromEJson(autoCreateTransaction),
transactionData: fromEJson(transactionData),
skippedOn: fromEJson(skippedOn),
order: fromEJson(order),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(RecurrenceDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, RecurrenceDb, 'RecurrenceDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('repeatInterval', RealmPropertyType.int),
SchemaProperty('repeatOn', RealmPropertyType.timestamp, collectionType: RealmCollectionType.list),
SchemaProperty('startOn', RealmPropertyType.timestamp),
SchemaProperty('endOn', RealmPropertyType.timestamp, optional: true),
SchemaProperty('autoCreateTransaction', RealmPropertyType.bool),
SchemaProperty('transactionData', RealmPropertyType.object, optional: true,linkTarget: 'TransactionDataDb'),
SchemaProperty('skippedOn', RealmPropertyType.timestamp, collectionType: RealmCollectionType.list),
SchemaProperty('order', RealmPropertyType.int, optional: true),
SchemaProperty('addedTransactions', RealmPropertyType.linkingObjects, linkOriginProperty: 'recurrence',collectionType: RealmCollectionType.list,linkTarget: 'TransactionDb'),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class TransactionDataDb extends _TransactionDataDb with RealmEntity, RealmObjectBase, EmbeddedObject {
TransactionDataDb(
int type,
{
DateTime? dateTime,
double? amount,
String? note,
AccountDb? account,
CategoryDb? category,
CategoryTagDb? categoryTag,
AccountDb? transferAccount,
TransferFeeDb? transferFee,
}
) {
RealmObjectBase.set(this, 'type', type);
RealmObjectBase.set(this, 'dateTime', dateTime);
RealmObjectBase.set(this, 'amount', amount);
RealmObjectBase.set(this, 'note', note);
RealmObjectBase.set(this, 'account', account);
RealmObjectBase.set(this, 'category', category);
RealmObjectBase.set(this, 'categoryTag', categoryTag);
RealmObjectBase.set(this, 'transferAccount', transferAccount);
RealmObjectBase.set(this, 'transferFee', transferFee);
}

TransactionDataDb._();

@override
int get type => RealmObjectBase.get<int>(this, 'type') as int;
@override
set type(int value) => RealmObjectBase.set(this, 'type', value);

@override
DateTime? get dateTime => RealmObjectBase.get<DateTime>(this, 'dateTime') as DateTime?;
@override
set dateTime(DateTime? value) => RealmObjectBase.set(this, 'dateTime', value);

@override
double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
@override
set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

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
AccountDb? get transferAccount => RealmObjectBase.get<AccountDb>(this, 'transferAccount') as AccountDb?;
@override
set transferAccount(covariant AccountDb? value) => RealmObjectBase.set(this, 'transferAccount', value);

@override
TransferFeeDb? get transferFee => RealmObjectBase.get<TransferFeeDb>(this, 'transferFee') as TransferFeeDb?;
@override
set transferFee(covariant TransferFeeDb? value) => RealmObjectBase.set(this, 'transferFee', value);

@override
Stream<RealmObjectChanges<TransactionDataDb>> get changes => RealmObjectBase.getChanges<TransactionDataDb>(this);

@override
Stream<RealmObjectChanges<TransactionDataDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<TransactionDataDb>(this, keyPaths);

@override
TransactionDataDb freeze() => RealmObjectBase.freezeObject<TransactionDataDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'type': type.toEJson(),
'dateTime': dateTime.toEJson(),
'amount': amount.toEJson(),
'note': note.toEJson(),
'account': account.toEJson(),
'category': category.toEJson(),
'categoryTag': categoryTag.toEJson(),
'transferAccount': transferAccount.toEJson(),
'transferFee': transferFee.toEJson(),
};
}
static EJsonValue _toEJson(TransactionDataDb value) => value.toEJson();
static TransactionDataDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'type': EJsonValue type,
'dateTime': EJsonValue dateTime,
'amount': EJsonValue amount,
'note': EJsonValue note,
'account': EJsonValue account,
'category': EJsonValue category,
'categoryTag': EJsonValue categoryTag,
'transferAccount': EJsonValue transferAccount,
'transferFee': EJsonValue transferFee,
} => TransactionDataDb(
fromEJson(type),
dateTime: fromEJson(dateTime),
amount: fromEJson(amount),
note: fromEJson(note),
account: fromEJson(account),
category: fromEJson(category),
categoryTag: fromEJson(categoryTag),
transferAccount: fromEJson(transferAccount),
transferFee: fromEJson(transferFee),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(TransactionDataDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.embeddedObject, TransactionDataDb, 'TransactionDataDb', [
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('dateTime', RealmPropertyType.timestamp, optional: true,indexType: RealmIndexType.regular),
SchemaProperty('amount', RealmPropertyType.double, optional: true),
SchemaProperty('note', RealmPropertyType.string, optional: true),
SchemaProperty('account', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('category', RealmPropertyType.object, optional: true,linkTarget: 'CategoryDb'),
SchemaProperty('categoryTag', RealmPropertyType.object, optional: true,linkTarget: 'CategoryTagDb'),
SchemaProperty('transferAccount', RealmPropertyType.object, optional: true,linkTarget: 'AccountDb'),
SchemaProperty('transferFee', RealmPropertyType.object, optional: true,linkTarget: 'TransferFeeDb'),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class BudgetDb extends _BudgetDb with RealmEntity, RealmObjectBase, RealmObject {
BudgetDb(
ObjectId id,
int type,
int periodType,
String name,
double amount,
{
Iterable<AccountDb> accounts = const [],
Iterable<CategoryDb> categories = const [],
int? order,
}
) {
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'type', type);
RealmObjectBase.set(this, 'periodType', periodType);
RealmObjectBase.set(this, 'name', name);
RealmObjectBase.set(this, 'amount', amount);
RealmObjectBase.set<RealmList<AccountDb>>(this, 'accounts', RealmList<AccountDb>(accounts));
RealmObjectBase.set<RealmList<CategoryDb>>(this, 'categories', RealmList<CategoryDb>(categories));
RealmObjectBase.set(this, 'order', order);
}

BudgetDb._();

@override
ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
@override
set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

@override
int get type => RealmObjectBase.get<int>(this, 'type') as int;
@override
set type(int value) => RealmObjectBase.set(this, 'type', value);

@override
int get periodType => RealmObjectBase.get<int>(this, 'periodType') as int;
@override
set periodType(int value) => RealmObjectBase.set(this, 'periodType', value);

@override
String get name => RealmObjectBase.get<String>(this, 'name') as String;
@override
set name(String value) => RealmObjectBase.set(this, 'name', value);

@override
double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
@override
set amount(double value) => RealmObjectBase.set(this, 'amount', value);

@override
RealmList<AccountDb> get accounts => RealmObjectBase.get<AccountDb>(this, 'accounts') as RealmList<AccountDb>;
@override
set accounts(covariant RealmList<AccountDb> value) => throw RealmUnsupportedSetError();

@override
RealmList<CategoryDb> get categories => RealmObjectBase.get<CategoryDb>(this, 'categories') as RealmList<CategoryDb>;
@override
set categories(covariant RealmList<CategoryDb> value) => throw RealmUnsupportedSetError();

@override
int? get order => RealmObjectBase.get<int>(this, 'order') as int?;
@override
set order(int? value) => RealmObjectBase.set(this, 'order', value);

@override
Stream<RealmObjectChanges<BudgetDb>> get changes => RealmObjectBase.getChanges<BudgetDb>(this);

@override
Stream<RealmObjectChanges<BudgetDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<BudgetDb>(this, keyPaths);

@override
BudgetDb freeze() => RealmObjectBase.freezeObject<BudgetDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'type': type.toEJson(),
'periodType': periodType.toEJson(),
'name': name.toEJson(),
'amount': amount.toEJson(),
'accounts': accounts.toEJson(),
'categories': categories.toEJson(),
'order': order.toEJson(),
};
}
static EJsonValue _toEJson(BudgetDb value) => value.toEJson();
static BudgetDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'type': EJsonValue type,
'periodType': EJsonValue periodType,
'name': EJsonValue name,
'amount': EJsonValue amount,
'accounts': EJsonValue accounts,
'categories': EJsonValue categories,
'order': EJsonValue order,
} => BudgetDb(
fromEJson(id),
fromEJson(type),
fromEJson(periodType),
fromEJson(name),
fromEJson(amount),
accounts: fromEJson(accounts),
categories: fromEJson(categories),
order: fromEJson(order),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(BudgetDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, BudgetDb, 'BudgetDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('type', RealmPropertyType.int),
SchemaProperty('periodType', RealmPropertyType.int),
SchemaProperty('name', RealmPropertyType.string),
SchemaProperty('amount', RealmPropertyType.double),
SchemaProperty('accounts', RealmPropertyType.object, linkTarget: 'AccountDb',collectionType: RealmCollectionType.list),
SchemaProperty('categories', RealmPropertyType.object, linkTarget: 'CategoryDb',collectionType: RealmCollectionType.list),
SchemaProperty('order', RealmPropertyType.int, optional: true),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class SettingsDb extends _SettingsDb with RealmEntity, RealmObjectBase, RealmObject {
static var _defaultsSet = false;

SettingsDb(
int id,
{
int themeIndex = 0,
int themeType = 0,
int currencyIndex = 101,
String locale = 'en',
bool showDecimalDigits = false,
int longDateType = 0,
int shortDateType = 0,
int currencyType = 0,
int? firstDayOfWeek,
}
) {
if (!_defaultsSet) {
  _defaultsSet = RealmObjectBase.setDefaults<SettingsDb>({
'id': 0,
'themeIndex': 0,
'themeType': 0,
'currencyIndex': 101,
'locale': 'en',
'showDecimalDigits': false,
'longDateType': 0,
'shortDateType': 0,
'currencyType': 0,
  });
}
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'themeIndex', themeIndex);
RealmObjectBase.set(this, 'themeType', themeType);
RealmObjectBase.set(this, 'currencyIndex', currencyIndex);
RealmObjectBase.set(this, 'locale', locale);
RealmObjectBase.set(this, 'showDecimalDigits', showDecimalDigits);
RealmObjectBase.set(this, 'longDateType', longDateType);
RealmObjectBase.set(this, 'shortDateType', shortDateType);
RealmObjectBase.set(this, 'currencyType', currencyType);
RealmObjectBase.set(this, 'firstDayOfWeek', firstDayOfWeek);
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
String get locale => RealmObjectBase.get<String>(this, 'locale') as String;
@override
set locale(String value) => RealmObjectBase.set(this, 'locale', value);

@override
bool get showDecimalDigits => RealmObjectBase.get<bool>(this, 'showDecimalDigits') as bool;
@override
set showDecimalDigits(bool value) => RealmObjectBase.set(this, 'showDecimalDigits', value);

@override
int get longDateType => RealmObjectBase.get<int>(this, 'longDateType') as int;
@override
set longDateType(int value) => RealmObjectBase.set(this, 'longDateType', value);

@override
int get shortDateType => RealmObjectBase.get<int>(this, 'shortDateType') as int;
@override
set shortDateType(int value) => RealmObjectBase.set(this, 'shortDateType', value);

@override
int get currencyType => RealmObjectBase.get<int>(this, 'currencyType') as int;
@override
set currencyType(int value) => RealmObjectBase.set(this, 'currencyType', value);

@override
int? get firstDayOfWeek => RealmObjectBase.get<int>(this, 'firstDayOfWeek') as int?;
@override
set firstDayOfWeek(int? value) => RealmObjectBase.set(this, 'firstDayOfWeek', value);

@override
Stream<RealmObjectChanges<SettingsDb>> get changes => RealmObjectBase.getChanges<SettingsDb>(this);

@override
Stream<RealmObjectChanges<SettingsDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<SettingsDb>(this, keyPaths);

@override
SettingsDb freeze() => RealmObjectBase.freezeObject<SettingsDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'themeIndex': themeIndex.toEJson(),
'themeType': themeType.toEJson(),
'currencyIndex': currencyIndex.toEJson(),
'locale': locale.toEJson(),
'showDecimalDigits': showDecimalDigits.toEJson(),
'longDateType': longDateType.toEJson(),
'shortDateType': shortDateType.toEJson(),
'currencyType': currencyType.toEJson(),
'firstDayOfWeek': firstDayOfWeek.toEJson(),
};
}
static EJsonValue _toEJson(SettingsDb value) => value.toEJson();
static SettingsDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'themeIndex': EJsonValue themeIndex,
'themeType': EJsonValue themeType,
'currencyIndex': EJsonValue currencyIndex,
'locale': EJsonValue locale,
'showDecimalDigits': EJsonValue showDecimalDigits,
'longDateType': EJsonValue longDateType,
'shortDateType': EJsonValue shortDateType,
'currencyType': EJsonValue currencyType,
'firstDayOfWeek': EJsonValue firstDayOfWeek,
} => SettingsDb(
fromEJson(id),
themeIndex: fromEJson(themeIndex),
themeType: fromEJson(themeType),
currencyIndex: fromEJson(currencyIndex),
locale: fromEJson(locale),
showDecimalDigits: fromEJson(showDecimalDigits),
longDateType: fromEJson(longDateType),
shortDateType: fromEJson(shortDateType),
currencyType: fromEJson(currencyType),
firstDayOfWeek: fromEJson(firstDayOfWeek),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(SettingsDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, SettingsDb, 'SettingsDb', [
SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
SchemaProperty('themeIndex', RealmPropertyType.int),
SchemaProperty('themeType', RealmPropertyType.int),
SchemaProperty('currencyIndex', RealmPropertyType.int),
SchemaProperty('locale', RealmPropertyType.string),
SchemaProperty('showDecimalDigits', RealmPropertyType.bool),
SchemaProperty('longDateType', RealmPropertyType.int),
SchemaProperty('shortDateType', RealmPropertyType.int),
SchemaProperty('currencyType', RealmPropertyType.int),
SchemaProperty('firstDayOfWeek', RealmPropertyType.int, optional: true),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class PersistentValuesDb extends _PersistentValuesDb with RealmEntity, RealmObjectBase, RealmObject {
static var _defaultsSet = false;

PersistentValuesDb(
int id,
{
int chartDataTypeInHomescreen = 0,
bool showAmount = true,
Iterable<int> dashboardOrder = const [],
Iterable<int> hiddenDashboardWidgets = const [],
}
) {
if (!_defaultsSet) {
  _defaultsSet = RealmObjectBase.setDefaults<PersistentValuesDb>({
'id': 0,
'chartDataTypeInHomescreen': 0,
'showAmount': true,
  });
}
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'chartDataTypeInHomescreen', chartDataTypeInHomescreen);
RealmObjectBase.set(this, 'showAmount', showAmount);
RealmObjectBase.set<RealmList<int>>(this, 'dashboardOrder', RealmList<int>(dashboardOrder));
RealmObjectBase.set<RealmList<int>>(this, 'hiddenDashboardWidgets', RealmList<int>(hiddenDashboardWidgets));
}

PersistentValuesDb._();

@override
int get id => RealmObjectBase.get<int>(this, 'id') as int;

@override
int get chartDataTypeInHomescreen => RealmObjectBase.get<int>(this, 'chartDataTypeInHomescreen') as int;
@override
set chartDataTypeInHomescreen(int value) => RealmObjectBase.set(this, 'chartDataTypeInHomescreen', value);

@override
bool get showAmount => RealmObjectBase.get<bool>(this, 'showAmount') as bool;
@override
set showAmount(bool value) => RealmObjectBase.set(this, 'showAmount', value);

@override
RealmList<int> get dashboardOrder => RealmObjectBase.get<int>(this, 'dashboardOrder') as RealmList<int>;
@override
set dashboardOrder(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

@override
RealmList<int> get hiddenDashboardWidgets => RealmObjectBase.get<int>(this, 'hiddenDashboardWidgets') as RealmList<int>;
@override
set hiddenDashboardWidgets(covariant RealmList<int> value) => throw RealmUnsupportedSetError();

@override
Stream<RealmObjectChanges<PersistentValuesDb>> get changes => RealmObjectBase.getChanges<PersistentValuesDb>(this);

@override
Stream<RealmObjectChanges<PersistentValuesDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<PersistentValuesDb>(this, keyPaths);

@override
PersistentValuesDb freeze() => RealmObjectBase.freezeObject<PersistentValuesDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'chartDataTypeInHomescreen': chartDataTypeInHomescreen.toEJson(),
'showAmount': showAmount.toEJson(),
'dashboardOrder': dashboardOrder.toEJson(),
'hiddenDashboardWidgets': hiddenDashboardWidgets.toEJson(),
};
}
static EJsonValue _toEJson(PersistentValuesDb value) => value.toEJson();
static PersistentValuesDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'chartDataTypeInHomescreen': EJsonValue chartDataTypeInHomescreen,
'showAmount': EJsonValue showAmount,
'dashboardOrder': EJsonValue dashboardOrder,
'hiddenDashboardWidgets': EJsonValue hiddenDashboardWidgets,
} => PersistentValuesDb(
fromEJson(id),
chartDataTypeInHomescreen: fromEJson(chartDataTypeInHomescreen),
showAmount: fromEJson(showAmount),
dashboardOrder: fromEJson(dashboardOrder),
hiddenDashboardWidgets: fromEJson(hiddenDashboardWidgets),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(PersistentValuesDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, PersistentValuesDb, 'PersistentValuesDb', [
SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
SchemaProperty('chartDataTypeInHomescreen', RealmPropertyType.int),
SchemaProperty('showAmount', RealmPropertyType.bool),
SchemaProperty('dashboardOrder', RealmPropertyType.int, collectionType: RealmCollectionType.list),
SchemaProperty('hiddenDashboardWidgets', RealmPropertyType.int, collectionType: RealmCollectionType.list),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
class BalanceAtDateTimeDb extends _BalanceAtDateTimeDb with RealmEntity, RealmObjectBase, RealmObject {
BalanceAtDateTimeDb(
ObjectId id,
DateTime date,
double amount,
) {
RealmObjectBase.set(this, 'id', id);
RealmObjectBase.set(this, 'date', date);
RealmObjectBase.set(this, 'amount', amount);
}

BalanceAtDateTimeDb._();

@override
ObjectId get id => RealmObjectBase.get<ObjectId>(this, 'id') as ObjectId;
@override
set id(ObjectId value) => RealmObjectBase.set(this, 'id', value);

@override
DateTime get date => RealmObjectBase.get<DateTime>(this, 'date') as DateTime;
@override
set date(DateTime value) => RealmObjectBase.set(this, 'date', value);

@override
double get amount => RealmObjectBase.get<double>(this, 'amount') as double;
@override
set amount(double value) => RealmObjectBase.set(this, 'amount', value);

@override
Stream<RealmObjectChanges<BalanceAtDateTimeDb>> get changes => RealmObjectBase.getChanges<BalanceAtDateTimeDb>(this);

@override
Stream<RealmObjectChanges<BalanceAtDateTimeDb>> changesFor([List<String>? keyPaths]) => RealmObjectBase.getChangesFor<BalanceAtDateTimeDb>(this, keyPaths);

@override
BalanceAtDateTimeDb freeze() => RealmObjectBase.freezeObject<BalanceAtDateTimeDb>(this);

EJsonValue toEJson() {
return <String, dynamic>{
'id': id.toEJson(),
'date': date.toEJson(),
'amount': amount.toEJson(),
};
}
static EJsonValue _toEJson(BalanceAtDateTimeDb value) => value.toEJson();
static BalanceAtDateTimeDb _fromEJson(EJsonValue ejson) {
return switch (ejson) {
{
'id': EJsonValue id,
'date': EJsonValue date,
'amount': EJsonValue amount,
} => BalanceAtDateTimeDb(
fromEJson(id),
fromEJson(date),
fromEJson(amount),
),
_ => raiseInvalidEJson(ejson),
};
}
static final schema = () {
RealmObjectBase.registerFactory(BalanceAtDateTimeDb._);
register(_toEJson, _fromEJson);
return SchemaObject(ObjectType.realmObject, BalanceAtDateTimeDb, 'BalanceAtDateTimeDb', [
SchemaProperty('id', RealmPropertyType.objectid, primaryKey: true),
SchemaProperty('date', RealmPropertyType.timestamp),
SchemaProperty('amount', RealmPropertyType.double),
]);
}();

@override
SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
