// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAccountIsarCollection on Isar {
  IsarCollection<AccountIsar> get accountIsars => this.collection();
}

const AccountIsarSchema = CollectionSchema(
  name: r'AccountIsar',
  id: 8468693532541457158,
  properties: {
    r'colorIndex': PropertySchema(
      id: 0,
      name: r'colorIndex',
      type: IsarType.long,
    ),
    r'iconCategory': PropertySchema(
      id: 1,
      name: r'iconCategory',
      type: IsarType.string,
    ),
    r'iconIndex': PropertySchema(
      id: 2,
      name: r'iconIndex',
      type: IsarType.long,
    ),
    r'initialBalance': PropertySchema(
      id: 3,
      name: r'initialBalance',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 4,
      name: r'name',
      type: IsarType.string,
    ),
    r'order': PropertySchema(
      id: 5,
      name: r'order',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 6,
      name: r'type',
      type: IsarType.byte,
      enumMap: _AccountIsartypeEnumValueMap,
    )
  },
  estimateSize: _accountIsarEstimateSize,
  serialize: _accountIsarSerialize,
  deserialize: _accountIsarDeserialize,
  deserializeProp: _accountIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _accountIsarGetId,
  getLinks: _accountIsarGetLinks,
  attach: _accountIsarAttach,
  version: '3.1.0+1',
);

int _accountIsarEstimateSize(
  AccountIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.iconCategory.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _accountIsarSerialize(
  AccountIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.colorIndex);
  writer.writeString(offsets[1], object.iconCategory);
  writer.writeLong(offsets[2], object.iconIndex);
  writer.writeDouble(offsets[3], object.initialBalance);
  writer.writeString(offsets[4], object.name);
  writer.writeLong(offsets[5], object.order);
  writer.writeByte(offsets[6], object.type.index);
}

AccountIsar _accountIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AccountIsar();
  object.colorIndex = reader.readLong(offsets[0]);
  object.iconCategory = reader.readString(offsets[1]);
  object.iconIndex = reader.readLong(offsets[2]);
  object.id = id;
  object.initialBalance = reader.readDouble(offsets[3]);
  object.name = reader.readString(offsets[4]);
  object.order = reader.readLongOrNull(offsets[5]);
  object.type =
      _AccountIsartypeValueEnumMap[reader.readByteOrNull(offsets[6])] ??
          AccountType.onHand;
  return object;
}

P _accountIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (_AccountIsartypeValueEnumMap[reader.readByteOrNull(offset)] ??
          AccountType.onHand) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _AccountIsartypeEnumValueMap = {
  'onHand': 0,
  'credit': 1,
};
const _AccountIsartypeValueEnumMap = {
  0: AccountType.onHand,
  1: AccountType.credit,
};

Id _accountIsarGetId(AccountIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _accountIsarGetLinks(AccountIsar object) {
  return [];
}

void _accountIsarAttach(
    IsarCollection<dynamic> col, Id id, AccountIsar object) {
  object.id = id;
}

extension AccountIsarQueryWhereSort
    on QueryBuilder<AccountIsar, AccountIsar, QWhere> {
  QueryBuilder<AccountIsar, AccountIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AccountIsarQueryWhere
    on QueryBuilder<AccountIsar, AccountIsar, QWhereClause> {
  QueryBuilder<AccountIsar, AccountIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<AccountIsar, AccountIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterWhereClause> idBetween(
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

extension AccountIsarQueryFilter
    on QueryBuilder<AccountIsar, AccountIsar, QFilterCondition> {
  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      colorIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      colorIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      colorIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colorIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      colorIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colorIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'iconCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'iconCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'iconCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'iconIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'iconIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'iconIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      iconIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'iconIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      initialBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'initialBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      initialBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'initialBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      initialBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'initialBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      initialBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'initialBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> orderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'order',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      orderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'order',
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> orderEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition>
      orderGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> orderLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'order',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> orderBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'order',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> typeEqualTo(
      AccountType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> typeGreaterThan(
    AccountType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> typeLessThan(
    AccountType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
      ));
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterFilterCondition> typeBetween(
    AccountType lower,
    AccountType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AccountIsarQueryObject
    on QueryBuilder<AccountIsar, AccountIsar, QFilterCondition> {}

extension AccountIsarQueryLinks
    on QueryBuilder<AccountIsar, AccountIsar, QFilterCondition> {}

extension AccountIsarQuerySortBy
    on QueryBuilder<AccountIsar, AccountIsar, QSortBy> {
  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByColorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorIndex', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByColorIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorIndex', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByIconCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCategory', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy>
      sortByIconCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCategory', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByIconIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconIndex', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByIconIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconIndex', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByInitialBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialBalance', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy>
      sortByInitialBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialBalance', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AccountIsarQuerySortThenBy
    on QueryBuilder<AccountIsar, AccountIsar, QSortThenBy> {
  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByColorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorIndex', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByColorIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colorIndex', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByIconCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCategory', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy>
      thenByIconCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconCategory', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByIconIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconIndex', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByIconIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'iconIndex', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByInitialBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialBalance', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy>
      thenByInitialBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialBalance', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'order', Sort.desc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension AccountIsarQueryWhereDistinct
    on QueryBuilder<AccountIsar, AccountIsar, QDistinct> {
  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByColorIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colorIndex');
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByIconCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconCategory', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByIconIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'iconIndex');
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByInitialBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialBalance');
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'order');
    });
  }

  QueryBuilder<AccountIsar, AccountIsar, QDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type');
    });
  }
}

extension AccountIsarQueryProperty
    on QueryBuilder<AccountIsar, AccountIsar, QQueryProperty> {
  QueryBuilder<AccountIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AccountIsar, int, QQueryOperations> colorIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colorIndex');
    });
  }

  QueryBuilder<AccountIsar, String, QQueryOperations> iconCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconCategory');
    });
  }

  QueryBuilder<AccountIsar, int, QQueryOperations> iconIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'iconIndex');
    });
  }

  QueryBuilder<AccountIsar, double, QQueryOperations> initialBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialBalance');
    });
  }

  QueryBuilder<AccountIsar, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<AccountIsar, int?, QQueryOperations> orderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'order');
    });
  }

  QueryBuilder<AccountIsar, AccountType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
