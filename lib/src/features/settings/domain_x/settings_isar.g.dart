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
    r'currency': PropertySchema(
      id: 0,
      name: r'currency',
      type: IsarType.byte,
      enumMap: _SettingsIsarcurrencyEnumValueMap,
    ),
    r'currentThemeIndex': PropertySchema(
      id: 1,
      name: r'currentThemeIndex',
      type: IsarType.long,
    ),
    r'themeType': PropertySchema(
      id: 2,
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
  writer.writeByte(offsets[0], object.currency.index);
  writer.writeLong(offsets[1], object.currentThemeIndex);
  writer.writeByte(offsets[2], object.themeType.index);
}

SettingsIsar _settingsIsarDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsIsar();
  object.currency =
      _SettingsIsarcurrencyValueEnumMap[reader.readByteOrNull(offsets[0])] ??
          Currency.all;
  object.currentThemeIndex = reader.readLong(offsets[1]);
  object.themeType =
      _SettingsIsarthemeTypeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          ThemeType.light;
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
      return (_SettingsIsarcurrencyValueEnumMap[
              reader.readByteOrNull(offset)] ??
          Currency.all) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (_SettingsIsarthemeTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ThemeType.light) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsIsarcurrencyEnumValueMap = {
  'all': 0,
  'afn': 1,
  'ars': 2,
  'awg': 3,
  'aud': 4,
  'bsd': 5,
  'bbd': 6,
  'byn': 7,
  'bzd': 8,
  'bmd': 9,
  'bob': 10,
  'bam': 11,
  'bwp': 12,
  'bgn': 13,
  'brl': 14,
  'bnd': 15,
  'khr': 16,
  'cad': 17,
  'kyd': 18,
  'clp': 19,
  'cny': 20,
  'cop': 21,
  'crc': 22,
  'hrk': 23,
  'cup': 24,
  'czk': 25,
  'dkk': 26,
  'dop': 27,
  'xcd': 28,
  'egp': 29,
  'svc': 30,
  'eur': 31,
  'fkp': 32,
  'fjd': 33,
  'ghs': 34,
  'gip': 35,
  'gtq': 36,
  'ggp': 37,
  'gyd': 38,
  'hnl': 39,
  'hkd': 40,
  'huf': 41,
  'isk': 42,
  'inr': 43,
  'idr': 44,
  'irr': 45,
  'imp': 46,
  'ils': 47,
  'jmd': 48,
  'jpy': 49,
  'jep': 50,
  'kzt': 51,
  'kpw': 52,
  'krw': 53,
  'kgs': 54,
  'lak': 55,
  'lbp': 56,
  'lrd': 57,
  'mkd': 58,
  'myr': 59,
  'mur': 60,
  'mxn': 61,
  'mnt': 62,
  'mzn': 63,
  'nad': 64,
  'npr': 65,
  'ang': 66,
  'nzd': 67,
  'nio': 68,
  'ngn': 69,
  'nok': 70,
  'omr': 71,
  'pkr': 72,
  'pab': 73,
  'pyg': 74,
  'pen': 75,
  'php': 76,
  'pln': 77,
  'qar': 78,
  'ron': 79,
  'rub': 80,
  'shp': 81,
  'sar': 82,
  'rsd': 83,
  'scr': 84,
  'sgd': 85,
  'sbd': 86,
  'sos': 87,
  'zar': 88,
  'lkr': 89,
  'sek': 90,
  'chf': 91,
  'srd': 92,
  'syp': 93,
  'twd': 94,
  'thb': 95,
  'ttd': 96,
  'try0': 97,
  'tvd': 98,
  'uah': 99,
  'gbp': 100,
  'usd': 101,
  'uyu': 102,
  'uzs': 103,
  'vef': 104,
  'vnd': 105,
  'yer': 106,
  'zwd': 107,
};
const _SettingsIsarcurrencyValueEnumMap = {
  0: Currency.all,
  1: Currency.afn,
  2: Currency.ars,
  3: Currency.awg,
  4: Currency.aud,
  5: Currency.bsd,
  6: Currency.bbd,
  7: Currency.byn,
  8: Currency.bzd,
  9: Currency.bmd,
  10: Currency.bob,
  11: Currency.bam,
  12: Currency.bwp,
  13: Currency.bgn,
  14: Currency.brl,
  15: Currency.bnd,
  16: Currency.khr,
  17: Currency.cad,
  18: Currency.kyd,
  19: Currency.clp,
  20: Currency.cny,
  21: Currency.cop,
  22: Currency.crc,
  23: Currency.hrk,
  24: Currency.cup,
  25: Currency.czk,
  26: Currency.dkk,
  27: Currency.dop,
  28: Currency.xcd,
  29: Currency.egp,
  30: Currency.svc,
  31: Currency.eur,
  32: Currency.fkp,
  33: Currency.fjd,
  34: Currency.ghs,
  35: Currency.gip,
  36: Currency.gtq,
  37: Currency.ggp,
  38: Currency.gyd,
  39: Currency.hnl,
  40: Currency.hkd,
  41: Currency.huf,
  42: Currency.isk,
  43: Currency.inr,
  44: Currency.idr,
  45: Currency.irr,
  46: Currency.imp,
  47: Currency.ils,
  48: Currency.jmd,
  49: Currency.jpy,
  50: Currency.jep,
  51: Currency.kzt,
  52: Currency.kpw,
  53: Currency.krw,
  54: Currency.kgs,
  55: Currency.lak,
  56: Currency.lbp,
  57: Currency.lrd,
  58: Currency.mkd,
  59: Currency.myr,
  60: Currency.mur,
  61: Currency.mxn,
  62: Currency.mnt,
  63: Currency.mzn,
  64: Currency.nad,
  65: Currency.npr,
  66: Currency.ang,
  67: Currency.nzd,
  68: Currency.nio,
  69: Currency.ngn,
  70: Currency.nok,
  71: Currency.omr,
  72: Currency.pkr,
  73: Currency.pab,
  74: Currency.pyg,
  75: Currency.pen,
  76: Currency.php,
  77: Currency.pln,
  78: Currency.qar,
  79: Currency.ron,
  80: Currency.rub,
  81: Currency.shp,
  82: Currency.sar,
  83: Currency.rsd,
  84: Currency.scr,
  85: Currency.sgd,
  86: Currency.sbd,
  87: Currency.sos,
  88: Currency.zar,
  89: Currency.lkr,
  90: Currency.sek,
  91: Currency.chf,
  92: Currency.srd,
  93: Currency.syp,
  94: Currency.twd,
  95: Currency.thb,
  96: Currency.ttd,
  97: Currency.try0,
  98: Currency.tvd,
  99: Currency.uah,
  100: Currency.gbp,
  101: Currency.usd,
  102: Currency.uyu,
  103: Currency.uzs,
  104: Currency.vef,
  105: Currency.vnd,
  106: Currency.yer,
  107: Currency.zwd,
};
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

void _settingsIsarAttach(
    IsarCollection<dynamic> col, Id id, SettingsIsar object) {}

extension SettingsIsarQueryWhereSort
    on QueryBuilder<SettingsIsar, SettingsIsar, QWhere> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsIsarQueryWhere
    on QueryBuilder<SettingsIsar, SettingsIsar, QWhereClause> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
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

extension SettingsIsarQueryFilter
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currencyEqualTo(Currency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currencyGreaterThan(
    Currency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currencyLessThan(
    Currency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currencyBetween(
    Currency lower,
    Currency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currentThemeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentThemeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currentThemeIndexGreaterThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currentThemeIndexLessThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      currentThemeIndexBetween(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition> idEqualTo(
      Id value) {
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      themeTypeEqualTo(ThemeType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeType',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      themeTypeGreaterThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      themeTypeLessThan(
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

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterFilterCondition>
      themeTypeBetween(
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

extension SettingsIsarQueryObject
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQueryLinks
    on QueryBuilder<SettingsIsar, SettingsIsar, QFilterCondition> {}

extension SettingsIsarQuerySortBy
    on QueryBuilder<SettingsIsar, SettingsIsar, QSortBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByCurrentThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      sortByCurrentThemeIndexDesc() {
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

extension SettingsIsarQuerySortThenBy
    on QueryBuilder<SettingsIsar, SettingsIsar, QSortThenBy> {
  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy> thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByCurrentThemeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentThemeIndex', Sort.asc);
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QAfterSortBy>
      thenByCurrentThemeIndexDesc() {
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

extension SettingsIsarQueryWhereDistinct
    on QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> {
  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct> distinctByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency');
    });
  }

  QueryBuilder<SettingsIsar, SettingsIsar, QDistinct>
      distinctByCurrentThemeIndex() {
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

extension SettingsIsarQueryProperty
    on QueryBuilder<SettingsIsar, SettingsIsar, QQueryProperty> {
  QueryBuilder<SettingsIsar, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsIsar, Currency, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<SettingsIsar, int, QQueryOperations>
      currentThemeIndexProperty() {
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
