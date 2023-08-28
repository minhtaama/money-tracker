// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_transaction_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditSpendingIsarCollection on Isar {
  IsarCollection<CreditSpendingIsar> get creditSpendingIsars =>
      this.collection();
}

const CreditSpendingIsarSchema = CollectionSchema(
  name: r'CreditSpendingIsar',
  id: 8950455411148607152,
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
    r'installmentDetails': PropertySchema(
      id: 2,
      name: r'installmentDetails',
      type: IsarType.object,
      target: r'InstallmentDetails',
    ),
    r'note': PropertySchema(
      id: 3,
      name: r'note',
      type: IsarType.string,
    )
  },
  estimateSize: _creditSpendingIsarEstimateSize,
  serialize: _creditSpendingIsarSerialize,
  deserialize: _creditSpendingIsarDeserialize,
  deserializeProp: _creditSpendingIsarDeserializeProp,
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
      id: -7229664159589297502,
      name: r'categoryLink',
      target: r'CategoryIsar',
      single: true,
    ),
    r'categoryTagLink': LinkSchema(
      id: -6155028065321962391,
      name: r'categoryTagLink',
      target: r'CategoryTagIsar',
      single: true,
    ),
    r'creditAccountLink': LinkSchema(
      id: 3063992616581264976,
      name: r'creditAccountLink',
      target: r'AccountIsar',
      single: true,
    ),
    r'paymentTxnBacklinks': LinkSchema(
      id: 1120369630506754481,
      name: r'paymentTxnBacklinks',
      target: r'CreditPaymentIsar',
      single: false,
      linkName: r'spendingTxnLink',
    )
  },
  embeddedSchemas: {r'InstallmentDetails': InstallmentDetailsSchema},
  getId: _creditSpendingIsarGetId,
  getLinks: _creditSpendingIsarGetLinks,
  attach: _creditSpendingIsarAttach,
  version: '3.1.0+1',
);

int _creditSpendingIsarEstimateSize(
  CreditSpendingIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.installmentDetails;
    if (value != null) {
      bytesCount += 3 +
          InstallmentDetailsSchema.estimateSize(
              value, allOffsets[InstallmentDetails]!, allOffsets);
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _creditSpendingIsarSerialize(
  CreditSpendingIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeObject<InstallmentDetails>(
    offsets[2],
    allOffsets,
    InstallmentDetailsSchema.serialize,
    object.installmentDetails,
  );
  writer.writeString(offsets[3], object.note);
}

CreditSpendingIsar _creditSpendingIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditSpendingIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.id = id;
  object.installmentDetails = reader.readObjectOrNull<InstallmentDetails>(
    offsets[2],
    InstallmentDetailsSchema.deserialize,
    allOffsets,
  );
  object.note = reader.readStringOrNull(offsets[3]);
  return object;
}

P _creditSpendingIsarDeserializeProp<P>(
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
      return (reader.readObjectOrNull<InstallmentDetails>(
        offset,
        InstallmentDetailsSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditSpendingIsarGetId(CreditSpendingIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditSpendingIsarGetLinks(
    CreditSpendingIsar object) {
  return [
    object.categoryLink,
    object.categoryTagLink,
    object.creditAccountLink,
    object.paymentTxnBacklinks
  ];
}

void _creditSpendingIsarAttach(
    IsarCollection<dynamic> col, Id id, CreditSpendingIsar object) {
  object.id = id;
  object.categoryLink
      .attach(col, col.isar.collection<CategoryIsar>(), r'categoryLink', id);
  object.categoryTagLink.attach(
      col, col.isar.collection<CategoryTagIsar>(), r'categoryTagLink', id);
  object.creditAccountLink.attach(
      col, col.isar.collection<AccountIsar>(), r'creditAccountLink', id);
  object.paymentTxnBacklinks.attach(col,
      col.isar.collection<CreditPaymentIsar>(), r'paymentTxnBacklinks', id);
}

extension CreditSpendingIsarQueryWhereSort
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QWhere> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhere>
      anyDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateTime'),
      );
    });
  }
}

extension CreditSpendingIsarQueryWhere
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QWhereClause> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
      dateTimeEqualTo(DateTime dateTime) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dateTime',
        value: [dateTime],
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterWhereClause>
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

extension CreditSpendingIsarQueryFilter
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QFilterCondition> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      installmentDetailsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'installmentDetails',
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      installmentDetailsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'installmentDetails',
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }
}

extension CreditSpendingIsarQueryObject
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QFilterCondition> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      installmentDetails(FilterQuery<InstallmentDetails> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'installmentDetails');
    });
  }
}

extension CreditSpendingIsarQueryLinks
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QFilterCondition> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      categoryLink(FilterQuery<CategoryIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'categoryLink');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      categoryLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'categoryLink', 0, true, 0, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      categoryTagLink(FilterQuery<CategoryTagIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'categoryTagLink');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      categoryTagLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'categoryTagLink', 0, true, 0, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      creditAccountLink(FilterQuery<AccountIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'creditAccountLink');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      creditAccountLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'creditAccountLink', 0, true, 0, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinks(FilterQuery<CreditPaymentIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'paymentTxnBacklinks');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnBacklinks', length, true, length, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinksIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, true, 0, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinksIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, false, 999999, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'paymentTxnBacklinks', 0, true, length, include);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
      paymentTxnBacklinksLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'paymentTxnBacklinks', length, include, 999999, true);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterFilterCondition>
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
}

extension CreditSpendingIsarQuerySortBy
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QSortBy> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension CreditSpendingIsarQuerySortThenBy
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QSortThenBy> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QAfterSortBy>
      thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }
}

extension CreditSpendingIsarQueryWhereDistinct
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QDistinct> {
  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QDistinct>
      distinctByNote({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }
}

extension CreditSpendingIsarQueryProperty
    on QueryBuilder<CreditSpendingIsar, CreditSpendingIsar, QQueryProperty> {
  QueryBuilder<CreditSpendingIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditSpendingIsar, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<CreditSpendingIsar, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<CreditSpendingIsar, InstallmentDetails?, QQueryOperations>
      installmentDetailsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'installmentDetails');
    });
  }

  QueryBuilder<CreditSpendingIsar, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCreditPaymentIsarCollection on Isar {
  IsarCollection<CreditPaymentIsar> get creditPaymentIsars => this.collection();
}

const CreditPaymentIsarSchema = CollectionSchema(
  name: r'CreditPaymentIsar',
  id: 5474839784627677796,
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
    )
  },
  estimateSize: _creditPaymentIsarEstimateSize,
  serialize: _creditPaymentIsarSerialize,
  deserialize: _creditPaymentIsarDeserialize,
  deserializeProp: _creditPaymentIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'creditAccountLink': LinkSchema(
      id: -994780482880883161,
      name: r'creditAccountLink',
      target: r'AccountIsar',
      single: true,
    ),
    r'spendingTxnLink': LinkSchema(
      id: -2947234698278629845,
      name: r'spendingTxnLink',
      target: r'CreditSpendingIsar',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _creditPaymentIsarGetId,
  getLinks: _creditPaymentIsarGetLinks,
  attach: _creditPaymentIsarAttach,
  version: '3.1.0+1',
);

int _creditPaymentIsarEstimateSize(
  CreditPaymentIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _creditPaymentIsarSerialize(
  CreditPaymentIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDateTime(offsets[1], object.dateTime);
}

CreditPaymentIsar _creditPaymentIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CreditPaymentIsar();
  object.amount = reader.readDouble(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.id = id;
  return object;
}

P _creditPaymentIsarDeserializeProp<P>(
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _creditPaymentIsarGetId(CreditPaymentIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _creditPaymentIsarGetLinks(
    CreditPaymentIsar object) {
  return [object.creditAccountLink, object.spendingTxnLink];
}

void _creditPaymentIsarAttach(
    IsarCollection<dynamic> col, Id id, CreditPaymentIsar object) {
  object.id = id;
  object.creditAccountLink.attach(
      col, col.isar.collection<AccountIsar>(), r'creditAccountLink', id);
  object.spendingTxnLink.attach(
      col, col.isar.collection<CreditSpendingIsar>(), r'spendingTxnLink', id);
}

extension CreditPaymentIsarQueryWhereSort
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QWhere> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CreditPaymentIsarQueryWhere
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QWhereClause> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhereClause>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterWhereClause>
      idBetween(
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
}

extension CreditPaymentIsarQueryFilter
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QFilterCondition> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
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
}

extension CreditPaymentIsarQueryObject
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QFilterCondition> {}

extension CreditPaymentIsarQueryLinks
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QFilterCondition> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      creditAccountLink(FilterQuery<AccountIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'creditAccountLink');
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      creditAccountLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'creditAccountLink', 0, true, 0, true);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      spendingTxnLink(FilterQuery<CreditSpendingIsar> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'spendingTxnLink');
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterFilterCondition>
      spendingTxnLinkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'spendingTxnLink', 0, true, 0, true);
    });
  }
}

extension CreditPaymentIsarQuerySortBy
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QSortBy> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      sortByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      sortByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }
}

extension CreditPaymentIsarQuerySortThenBy
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QSortThenBy> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      thenByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.asc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      thenByAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'amount', Sort.desc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension CreditPaymentIsarQueryWhereDistinct
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QDistinct> {
  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QDistinct>
      distinctByAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'amount');
    });
  }

  QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }
}

extension CreditPaymentIsarQueryProperty
    on QueryBuilder<CreditPaymentIsar, CreditPaymentIsar, QQueryProperty> {
  QueryBuilder<CreditPaymentIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CreditPaymentIsar, double, QQueryOperations> amountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'amount');
    });
  }

  QueryBuilder<CreditPaymentIsar, DateTime, QQueryOperations>
      dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const InstallmentDetailsSchema = Schema(
  name: r'InstallmentDetails',
  id: 978435878101923127,
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
    r'rateBasedOnRemainingInstallmentUnpaid': PropertySchema(
      id: 2,
      name: r'rateBasedOnRemainingInstallmentUnpaid',
      type: IsarType.bool,
    )
  },
  estimateSize: _installmentDetailsEstimateSize,
  serialize: _installmentDetailsSerialize,
  deserialize: _installmentDetailsDeserialize,
  deserializeProp: _installmentDetailsDeserializeProp,
);

int _installmentDetailsEstimateSize(
  InstallmentDetails object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _installmentDetailsSerialize(
  InstallmentDetails object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.amount);
  writer.writeDouble(offsets[1], object.interestRate);
  writer.writeBool(offsets[2], object.rateBasedOnRemainingInstallmentUnpaid);
}

InstallmentDetails _installmentDetailsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InstallmentDetails();
  object.amount = reader.readDouble(offsets[0]);
  object.interestRate = reader.readDouble(offsets[1]);
  object.rateBasedOnRemainingInstallmentUnpaid = reader.readBool(offsets[2]);
  return object;
}

P _installmentDetailsDeserializeProp<P>(
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

extension InstallmentDetailsQueryFilter
    on QueryBuilder<InstallmentDetails, InstallmentDetails, QFilterCondition> {
  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
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

  QueryBuilder<InstallmentDetails, InstallmentDetails, QAfterFilterCondition>
      rateBasedOnRemainingInstallmentUnpaidEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rateBasedOnRemainingInstallmentUnpaid',
        value: value,
      ));
    });
  }
}

extension InstallmentDetailsQueryObject
    on QueryBuilder<InstallmentDetails, InstallmentDetails, QFilterCondition> {}
