// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTransactionIsarCollection on Isar {
  IsarCollection<TransactionIsar> get transactionIsars => this.collection();
}

const TransactionIsarSchema = CollectionSchema(
  name: r'TransactionIsar',
  id: -3328880118366817659,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'dateTime': PropertySchema(
      id: 1,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'isInitialTransaction': PropertySchema(
      id: 2,
      name: r'isInitialTransaction',
      type: IsarType.bool,
    ),
    r'note': PropertySchema(
      id: 3,
      name: r'note',
      type: IsarType.string,
    ),
    r'paymentAmount': PropertySchema(
      id: 4,
      name: r'paymentAmount',
      type: IsarType.double,
    ),
    r'paymentPeriod': PropertySchema(
      id: 5,
      name: r'paymentPeriod',
      type: IsarType.long,
    ),
    r'transactionType': PropertySchema(
      id: 6,
      name: r'transactionType',
      type: IsarType.byte,
      enumMap: _TransactionIsartransactionTypeEnumValueMap,
    )
  },
  estimateSize: _transactionIsarEstimateSize,
  serialize: _transactionIsarSerialize,
  deserialize: _transactionIsarDeserialize,
  deserializeProp: _transactionIsarDeserializeProp,
  idName: r'id',
  indexes: {
    r'dateTime': IndexSchema(
      id: -138851979697481250,
      name: r'dateTime',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateTime',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'categoryLink': LinkSchema(
      id: 7819912186380829208,
      name: r'categoryLink',
      target: r'CategoryIsar',
      single: true,
    ),
    r'categoryTagLink': LinkSchema(
      id: -9058350721895494417,
      name: r'categoryTagLink',
      target: r'CategoryTagIsar',
      single: true,
    ),
    r'accountLink': LinkSchema(
      id: 2724955280269696873,
      name: r'accountLink',
      target: r'AccountIsar',
      single: true,
    ),
    r'toAccountLink': LinkSchema(
      id: 1505148871931788995,
      name: r'toAccountLink',
      target: r'AccountIsar',
      single: true,
    ),
    r'paymentTxnsBacklinks': LinkSchema(
      id: -7252896500683990276,
      name: r'paymentTxnsBacklinks',
      target: r'TransactionIsar',
      single: false,
      linkName: r'asPaymentOfCreditTxnLink',
    ),
    r'asPaymentOfCreditTxnLink': LinkSchema(
      id: 8406798734038396204,
      name: r'asPaymentOfCreditTxnLink',
      target: r'TransactionIsar',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _transactionIsarGetId,
  getLinks: _transactionIsarGetLinks,
  attach: _transactionIsarAttach,
  version: '3.1.0+1',
);

int _transactionIsarEstimateSize(
  TransactionIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _transactionIsarSerialize(
  TransactionIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeBool(offsets[2], object.isInitialTransaction);
  writer.writeString(offsets[3], object.note);
  writer.writeDouble(offsets[4], object.paymentAmount);
  writer.writeLong(offsets[5], object.paymentPeriod);
  writer.writeByte(offsets[6], object.transactionType.index);
}

TransactionIsar _transactionIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransactionIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.id = id;
  object.isInitialTransaction = reader.readBool(offsets[2]);
  object.note = reader.readStringOrNull(offsets[3]);
  object.paymentAmount = reader.readDoubleOrNull(offsets[4]);
  object.paymentPeriod = reader.readLongOrNull(offsets[5]);
  object.transactionType = _TransactionIsartransactionTypeValueEnumMap[
          reader.readByteOrNull(offsets[6])] ??
      TransactionType.income;
  return object;
}

P _transactionIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (_TransactionIsartransactionTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransactionType.income) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TransactionIsartransactionTypeEnumValueMap = {
  'income': 0,
  'expense': 1,
  'transfer': 2,
  'creditSpending': 3,
  'creditPayment': 4,
};
const _TransactionIsartransactionTypeValueEnumMap = {
  0: TransactionType.income,
  1: TransactionType.expense,
  2: TransactionType.transfer,
  3: TransactionType.creditSpending,
  4: TransactionType.creditPayment,
};

Id _transactionIsarGetId(TransactionIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _transactionIsarGetLinks(TransactionIsar object) {
  return [
    object.categoryLink,
    object.categoryTagLink,
    object.accountLink,
    object.toAccountLink,
    object.paymentTxnsBacklinks,
    object.asPaymentOfCreditTxnLink
  ];
}

void _transactionIsarAttach(
    IsarCollection<dynamic> col, Id id, TransactionIsar object) {
  object.id = id;
  object.categoryLink
      .attach(col, col.isar.collection<CategoryIsar>(), r'categoryLink', id);
  object.categoryTagLink.attach(
      col, col.isar.collection<CategoryTagIsar>(), r'categoryTagLink', id);
  object.accountLink
      .attach(col, col.isar.collection<AccountIsar>(), r'accountLink', id);
  object.toAccountLink
      .attach(col, col.isar.collection<AccountIsar>(), r'toAccountLink', id);
  object.paymentTxnsBacklinks.attach(
      col, col.isar.collection<TransactionIsar>(), r'paymentTxnsBacklinks', id);
  object.asPaymentOfCreditTxnLink.attach(col,
      col.isar.collection<TransactionIsar>(), r'asPaymentOfCreditTxnLink', id);
}

extension TransactionIsarQueryWhereSort
    on QueryBuilder<TransactionIsar, TransactionIsar, QWhere> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhere> anyDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateTime'),
      );
    });
  }
}

extension TransactionIsarQueryWhere
    on QueryBuilder<TransactionIsar, TransactionIsar, QWhereClause> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      dateTimeEqualTo(DateTime dateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateTime',
        value: [dateTime],
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      dateTimeNotEqualTo(DateTime dateTime) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [],
              upper: [dateTime],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [dateTime],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [dateTime],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dateTime',
              lower: [],
              upper: [dateTime],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      dateTimeGreaterThan(
    DateTime dateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [dateTime],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      dateTimeLessThan(
    DateTime dateTime, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [],
        upper: [dateTime],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterWhereClause>
      dateTimeBetween(
    DateTime lowerDateTime,
    DateTime upperDateTime, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'dateTime',
        lower: [lowerDateTime],
        includeLower: includeLower,
        upper: [upperDateTime],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TransactionIsarQueryFilter
    on QueryBuilder<TransactionIsar, TransactionIsar, QFilterCondition> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      amountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      amountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      amountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'amount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      amountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'amount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      isInitialTransactionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isInitialTransaction',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentAmount',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentAmount',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentAmountBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'paymentPeriod',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'paymentPeriod',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentPeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentPeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentPeriod',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentPeriodBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentPeriod',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transactionTypeEqualTo(TransactionType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'transactionType',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transactionTypeGreaterThan(
    TransactionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'transactionType',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transactionTypeLessThan(
    TransactionType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'transactionType',
        value: value,
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transactionTypeBetween(
    TransactionType lower,
    TransactionType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'transactionType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TransactionIsarQueryObject
    on QueryBuilder<TransactionIsar, TransactionIsar, QFilterCondition> {}

extension TransactionIsarQueryLinks
    on QueryBuilder<TransactionIsar, TransactionIsar, QFilterCondition> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      categoryLink(FilterQuery<CategoryIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'categoryLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      categoryLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'categoryLink', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      categoryTagLink(FilterQuery<CategoryTagIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'categoryTagLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      categoryTagLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'categoryTagLink', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      accountLink(FilterQuery<AccountIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'accountLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      accountLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'accountLink', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      toAccountLink(FilterQuery<AccountIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'toAccountLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      toAccountLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'toAccountLink', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinks(FilterQuery<TransactionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'paymentTxnsBacklinks');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnsBacklinks', length, true, length, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnsBacklinks', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnsBacklinks', 0, false, 999999, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnsBacklinks', 0, true, length, include);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnsBacklinks', length, include, 999999, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnsBacklinksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnsBacklinks', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      asPaymentOfCreditTxnLink(FilterQuery<TransactionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'asPaymentOfCreditTxnLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      asPaymentOfCreditTxnLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'asPaymentOfCreditTxnLink', 0, true, 0, true);
    });
  }
}

extension TransactionIsarQuerySortBy
    on QueryBuilder<TransactionIsar, TransactionIsar, QSortBy> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByIsInitialTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitialTransaction', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByIsInitialTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitialTransaction', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByPaymentPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentPeriod', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByPaymentPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentPeriod', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByTransactionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionType', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      sortByTransactionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionType', Sort.desc);
    });
  }
}

extension TransactionIsarQuerySortThenBy
    on QueryBuilder<TransactionIsar, TransactionIsar, QSortThenBy> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByIsInitialTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitialTransaction', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByIsInitialTransactionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isInitialTransaction', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAmount', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByPaymentAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentAmount', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByPaymentPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentPeriod', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByPaymentPeriodDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentPeriod', Sort.desc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByTransactionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionType', Sort.asc);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterSortBy>
      thenByTransactionTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'transactionType', Sort.desc);
    });
  }
}

extension TransactionIsarQueryWhereDistinct
    on QueryBuilder<TransactionIsar, TransactionIsar, QDistinct> {
  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct> distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct>
      distinctByIsInitialTransaction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isInitialTransaction');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct>
      distinctByPaymentAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentAmount');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct>
      distinctByPaymentPeriod() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentPeriod');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QDistinct>
      distinctByTransactionType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'transactionType');
    });
  }
}

extension TransactionIsarQueryProperty
    on QueryBuilder<TransactionIsar, TransactionIsar, QQueryProperty> {
  QueryBuilder<TransactionIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TransactionIsar, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<TransactionIsar, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<TransactionIsar, bool, QQueryOperations>
      isInitialTransactionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isInitialTransaction');
    });
  }

  QueryBuilder<TransactionIsar, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<TransactionIsar, double?, QQueryOperations>
      paymentAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentAmount');
    });
  }

  QueryBuilder<TransactionIsar, int?, QQueryOperations>
      paymentPeriodProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentPeriod');
    });
  }

  QueryBuilder<TransactionIsar, TransactionType, QQueryOperations>
      transactionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionType');
    });
  }
}
