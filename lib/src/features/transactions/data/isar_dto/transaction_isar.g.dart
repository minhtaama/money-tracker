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
    r'installmentIsar': PropertySchema(
      id: 2,
      name: r'installmentIsar',
      type: IsarType.object,
      target: r'InstallmentIsar',
    ),
    r'isInitialTransaction': PropertySchema(
      id: 3,
      name: r'isInitialTransaction',
      type: IsarType.bool,
    ),
    r'note': PropertySchema(
      id: 4,
      name: r'note',
      type: IsarType.string,
    ),
    r'transactionType': PropertySchema(
      id: 5,
      name: r'transactionType',
      type: IsarType.byte,
      enumMap: _TransactionIsartransactionTypeEnumValueMap,
    ),
    r'transferFeeIsar': PropertySchema(
      id: 6,
      name: r'transferFeeIsar',
      type: IsarType.object,
      target: r'TransferFeeIsar',
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
    r'paymentTxnBacklinks': LinkSchema(
      id: -4268113236040952822,
      name: r'paymentTxnBacklinks',
      target: r'TransactionIsar',
      single: false,
      linkName: r'spendingTxnLink',
    ),
    r'spendingTxnLink': LinkSchema(
      id: -3126156985708002684,
      name: r'spendingTxnLink',
      target: r'TransactionIsar',
      single: true,
    )
  },
  embeddedSchemas: {
    r'TransferFeeIsar': TransferFeeIsarSchema,
    r'InstallmentIsar': InstallmentIsarSchema
  },
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
    final value = object.installmentIsar;
    if (value != null) {
      bytesCount += 3 +
          InstallmentIsarSchema.estimateSize(
              value, allOffsets[InstallmentIsar]!, allOffsets);
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.transferFeeIsar;
    if (value != null) {
      bytesCount += 3 +
          TransferFeeIsarSchema.estimateSize(
              value, allOffsets[TransferFeeIsar]!, allOffsets);
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
  writer.writeObject<InstallmentIsar>(
    offsets[2],
    allOffsets,
    InstallmentIsarSchema.serialize,
    object.installmentIsar,
  );
  writer.writeBool(offsets[3], object.isInitialTransaction);
  writer.writeString(offsets[4], object.note);
  writer.writeByte(offsets[5], object.transactionType.index);
  writer.writeObject<TransferFeeIsar>(
    offsets[6],
    allOffsets,
    TransferFeeIsarSchema.serialize,
    object.transferFeeIsar,
  );
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
  object.installmentIsar = reader.readObjectOrNull<InstallmentIsar>(
    offsets[2],
    InstallmentIsarSchema.deserialize,
    allOffsets,
  );
  object.isInitialTransaction = reader.readBool(offsets[3]);
  object.note = reader.readStringOrNull(offsets[4]);
  object.transactionType = _TransactionIsartransactionTypeValueEnumMap[
          reader.readByteOrNull(offsets[5])] ??
      TransactionType.income;
  object.transferFeeIsar = reader.readObjectOrNull<TransferFeeIsar>(
    offsets[6],
    TransferFeeIsarSchema.deserialize,
    allOffsets,
  );
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
      return (reader.readObjectOrNull<InstallmentIsar>(
        offset,
        InstallmentIsarSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (_TransactionIsartransactionTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          TransactionType.income) as P;
    case 6:
      return (reader.readObjectOrNull<TransferFeeIsar>(
        offset,
        TransferFeeIsarSchema.deserialize,
        allOffsets,
      )) as P;
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
    object.paymentTxnBacklinks,
    object.spendingTxnLink
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
  object.paymentTxnBacklinks.attach(
      col, col.isar.collection<TransactionIsar>(), r'paymentTxnBacklinks', id);
  object.spendingTxnLink.attach(
      col, col.isar.collection<TransactionIsar>(), r'spendingTxnLink', id);
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
      installmentIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'installmentIsar',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      installmentIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'installmentIsar',
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

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transferFeeIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'transferFeeIsar',
      ));
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transferFeeIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'transferFeeIsar',
      ));
    });
  }
}

extension TransactionIsarQueryObject
    on QueryBuilder<TransactionIsar, TransactionIsar, QFilterCondition> {
  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      installmentIsar(FilterQuery<InstallmentIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'installmentIsar');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      transferFeeIsar(FilterQuery<TransferFeeIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'transferFeeIsar');
    });
  }
}

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
      paymentTxnBacklinks(FilterQuery<TransactionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'paymentTxnBacklinks');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnBacklinks', length, true, length, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, true, 0, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, false, 999999, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, true, length, include);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnBacklinks', length, include, 999999, true);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnBacklinks', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      spendingTxnLink(FilterQuery<TransactionIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'spendingTxnLink');
    });
  }

  QueryBuilder<TransactionIsar, TransactionIsar, QAfterFilterCondition>
      spendingTxnLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'spendingTxnLink', 0, true, 0, true);
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

  QueryBuilder<TransactionIsar, InstallmentIsar?, QQueryOperations>
      installmentIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentIsar');
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

  QueryBuilder<TransactionIsar, TransactionType, QQueryOperations>
      transactionTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transactionType');
    });
  }

  QueryBuilder<TransactionIsar, TransferFeeIsar?, QQueryOperations>
      transferFeeIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'transferFeeIsar');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const InstallmentIsarSchema = Schema(
  name: r'InstallmentIsar',
  id: -7546922404696347303,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'interestRate': PropertySchema(
      id: 1,
      name: r'interestRate',
      type: IsarType.double,
    ),
    r'rateOnRemaining': PropertySchema(
      id: 2,
      name: r'rateOnRemaining',
      type: IsarType.bool,
    )
  },
  estimateSize: _installmentIsarEstimateSize,
  serialize: _installmentIsarSerialize,
  deserialize: _installmentIsarDeserialize,
  deserializeProp: _installmentIsarDeserializeProp,
);

int _installmentIsarEstimateSize(
  InstallmentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _installmentIsarSerialize(
  InstallmentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDouble(offsets[1], object.interestRate);
  writer.writeBool(offsets[2], object.rateOnRemaining);
}

InstallmentIsar _installmentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InstallmentIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.interestRate = reader.readDouble(offsets[1]);
  object.rateOnRemaining = reader.readBool(offsets[2]);
  return object;
}

P _installmentIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension InstallmentIsarQueryFilter
    on QueryBuilder<InstallmentIsar, InstallmentIsar, QFilterCondition> {
  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
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

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
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

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
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

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
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

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
      interestRateEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
      interestRateGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
      interestRateLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'interestRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
      interestRateBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'interestRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<InstallmentIsar, InstallmentIsar, QAfterFilterCondition>
      rateOnRemainingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rateOnRemaining',
        value: value,
      ));
    });
  }
}

extension InstallmentIsarQueryObject
    on QueryBuilder<InstallmentIsar, InstallmentIsar, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const TransferFeeIsarSchema = Schema(
  name: r'TransferFeeIsar',
  id: -2216036765364288543,
  properties: {
    r'amount': PropertySchema(
      id: 0,
      name: r'amount',
      type: IsarType.double,
    ),
    r'onDestination': PropertySchema(
      id: 1,
      name: r'onDestination',
      type: IsarType.bool,
    )
  },
  estimateSize: _transferFeeIsarEstimateSize,
  serialize: _transferFeeIsarSerialize,
  deserialize: _transferFeeIsarDeserialize,
  deserializeProp: _transferFeeIsarDeserializeProp,
);

int _transferFeeIsarEstimateSize(
  TransferFeeIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _transferFeeIsarSerialize(
  TransferFeeIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeBool(offsets[1], object.onDestination);
}

TransferFeeIsar _transferFeeIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TransferFeeIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.onDestination = reader.readBool(offsets[1]);
  return object;
}

P _transferFeeIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension TransferFeeIsarQueryFilter
    on QueryBuilder<TransferFeeIsar, TransferFeeIsar, QFilterCondition> {
  QueryBuilder<TransferFeeIsar, TransferFeeIsar, QAfterFilterCondition>
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

  QueryBuilder<TransferFeeIsar, TransferFeeIsar, QAfterFilterCondition>
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

  QueryBuilder<TransferFeeIsar, TransferFeeIsar, QAfterFilterCondition>
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

  QueryBuilder<TransferFeeIsar, TransferFeeIsar, QAfterFilterCondition>
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

  QueryBuilder<TransferFeeIsar, TransferFeeIsar, QAfterFilterCondition>
      onDestinationEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onDestination',
        value: value,
      ));
    });
  }
}

extension TransferFeeIsarQueryObject
    on QueryBuilder<TransferFeeIsar, TransferFeeIsar, QFilterCondition> {}
