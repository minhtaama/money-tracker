// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_isar.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsIsarCollection on Isar {
  IsarCollection<SettingsIsar> get settingsIsars => this.collection();
}

const SettingsIsarSchema = CollectionSchema(
  name: r'SettingsIsar',
  id: 5385768829924721998,
  properties: {
    r'currentThemeIndex': PropertySchema(
      id: 0,
      name: r'currentThemeIndex',
      type: IsarType.long,
    ),
    r'themeType': PropertySchema(
      id: 1,
      name: r'themeType',
      type: IsarType.byte,
      enumMap: _SettingsIsarthemeTypeEnumValueMap,
    )
  },
  estimateSize: _settingsIsarEstimateSize,
  serialize: _settingsIsarSerialize,
  deserialize: _settingsIsarDeserialize,
  deserializeProp: _settingsIsarDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsIsarGetId,
  getLinks: _settingsIsarGetLinks,
  attach: _settingsIsarAttach,
  version: '3.1.0+1',
);

int _settingsIsarEstimateSize(
  SettingsIsar object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _settingsIsarSerialize(
  SettingsIsar object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentThemeIndex);
  writer.writeByte(offsets[1], object.themeType.index);
}

SettingsIsar _settingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsar();
  object.currentThemeIndex = reader.readLong(offsets[0]);
  object.themeType =
      _SettingsIsarthemeTypeValueEnumMap[reader.readByteOrNull(offsets[1])] ?? ThemeType.light;
  return object;
}

P _settingsIsarDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (_SettingsIsarthemeTypeValueEnumMap[reader.readByteOrNull(offset)] ?? ThemeType.light) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsIsarthemeTypeEnumValueMap = {
  'light': 0,
  'dark': 1,
  'system': 2,
};
const _SettingsIsarthemeTypeValueEnumMap = {
  0: ThemeType.light,
  1: ThemeType.dark,
  2: ThemeType.system,
};

Id _settingsIsarGetId(SettingsIsar object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsIsarGetLinks(SettingsIsar object) {
  return [];
}

void _settingsIsarAttach(IsarCollection<dynamic> col, Id id, SettingsIsar object) {}

extension SettingsIsarQueryWhereSort on QueryBuilder<SettingsIsar, SettingsIsar, QWhere> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsIsarQueryWhere on QueryBuilder<SettingsIsar, SettingsIsar, QWhereClause> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idBetween(
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

extension SettingsIsarQueryFilter on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> currentThemeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> currentThemeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> currentThemeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> currentThemeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentThemeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> themeTypeEqualTo(ThemeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> themeTypeGreaterThan(
    ThemeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> themeTypeLessThan(
    ThemeType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> themeTypeBetween(
    ThemeType lower,
    ThemeType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsIsarQueryObject on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQueryLinks on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQuerySortBy on QueryBuilder<SettingsIsar, SettingsIsar, QSortBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByCurrentThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByCurrentThemeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByThemeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeType', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByThemeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeType', Sort.desc);
    });
  }
}

extension SettingsIsarQuerySortThenBy on QueryBuilder<SettingsIsar, SettingsIsar, QSortThenBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByCurrentThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByCurrentThemeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByThemeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeType', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByThemeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeType', Sort.desc);
    });
  }
}

extension SettingsIsarQueryWhereDistinct on QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> {
  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> distinctByCurrentThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentThemeIndex');
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> distinctByThemeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeType');
    });
  }
}

extension SettingsIsarQueryProperty on QueryBuilder<SettingsIsar, SettingsIsar, QQueryProperty> {
  QueryBuilder<SettingsIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsIsar, int, QQueryOperations> currentThemeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentThemeIndex');
    });
  }

  QueryBuilder<SettingsIsar, ThemeType, QQueryOperations> themeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeType');
    });
  }
}
