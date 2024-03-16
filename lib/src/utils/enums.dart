import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

enum TransactionType {
  expense,
  income,
  transfer,
  creditSpending,
  creditPayment,
  creditCheckpoint,
  installmentToPay;

  int get databaseValue {
    return switch (this) {
      TransactionType.expense => 0,
      TransactionType.income => 1,
      TransactionType.transfer => 2,
      TransactionType.creditSpending => 3,
      TransactionType.creditPayment => 4,
      TransactionType.creditCheckpoint => 5,
      TransactionType.installmentToPay => throw StateError('Can not put this type into database'),
    };
  }

  static TransactionType fromDatabaseValue(int value) {
    return switch (value) {
      0 => TransactionType.expense,
      1 => TransactionType.income,
      2 => TransactionType.transfer,
      3 => TransactionType.creditSpending,
      4 => TransactionType.creditPayment,
      5 => TransactionType.creditCheckpoint,
      _ => throw StateError('Type $value is not available for TransactionType'),
    };
  }
}

enum CategoryType {
  expense,
  income;

  int get databaseValue {
    return switch (this) {
      CategoryType.expense => 0,
      CategoryType.income => 1,
    };
  }

  static CategoryType fromDatabaseValue(int value) {
    return switch (value) {
      0 => CategoryType.expense,
      1 => CategoryType.income,
      _ => throw StateError('Type $value is not available for CategoryType'),
    };
  }
}

enum AccountType {
  regular,
  credit;

  int get databaseValue {
    return switch (this) {
      AccountType.regular => 0,
      AccountType.credit => 1,
    };
  }

  static AccountType fromDatabaseValue(int value) {
    return switch (value) {
      0 => AccountType.regular,
      1 => AccountType.credit,
      _ => throw StateError('Type $value is not available for CategoryType'),
    };
  }
}

enum StatementType {
  withAverageDailyBalance,
  payOnlyInGracePeriod;

  int get databaseValue {
    return switch (this) {
      StatementType.withAverageDailyBalance => 0,
      StatementType.payOnlyInGracePeriod => 1,
    };
  }

  static StatementType fromDatabaseValue(int value) {
    return switch (value) {
      0 => StatementType.withAverageDailyBalance,
      1 => StatementType.payOnlyInGracePeriod,
      _ => throw StateError('Type $value is not available for CategoryType'),
    };
  }
}

enum LineChartDataType {
  totalAssets,
  cashflow,
  expense,
  income;

  int get databaseValue {
    return switch (this) {
      LineChartDataType.cashflow => 0,
      LineChartDataType.expense => 1,
      LineChartDataType.income => 2,
      LineChartDataType.totalAssets => 3,
    };
  }

  static LineChartDataType fromDatabaseValue(int value) {
    return switch (value) {
      0 => LineChartDataType.cashflow,
      1 => LineChartDataType.expense,
      2 => LineChartDataType.income,
      _ => LineChartDataType.totalAssets,
    };
  }
}

enum DashboardType {
  menu(0),
  weeklyReport(1),
  monthlyExpense(2),
  monthlyIncome(3);

  final int databaseValue;

  const DashboardType(this.databaseValue);

  static DashboardType fromDatabaseValue(int value) {
    return DashboardType.values.firstWhere((e) => e.databaseValue == value);
  }

  String get iconPath {
    return switch (this) {
      DashboardType.menu => AppIcons.categories,
      DashboardType.weeklyReport => AppIcons.receiptDollar,
      DashboardType.monthlyExpense => AppIcons.reports,
      DashboardType.monthlyIncome => AppIcons.reports,
    };
  }

  String get name {
    return switch (this) {
      DashboardType.menu => 'Menu'.hardcoded,
      DashboardType.weeklyReport => 'Weekly Report'.hardcoded,
      DashboardType.monthlyExpense => 'Monthly Expense'.hardcoded,
      DashboardType.monthlyIncome => 'Monthly Income'.hardcoded,
    };
  }
}

enum ThemeType { light, dark, system }

////////////////////////////////////////////////////

enum TransactionScreenType { editable, uneditable, installmentToPay }

// TODO: Change 2 format: short and long date time
enum DateTimeFormat {
  ddmmyyyy,
  ddmmmyyyy,
  ddmmmmyyyy,
  mmddyyyy,
  mmmddyyyy,
  mmmmddyyyy,
}

/// https://www.xe.com/symbols/
enum Currency {
  all('ALL', 'Albania Lek', symbol: 'Lek'),
  afn('AFN', 'Afghanistan Afghani'),
  ars('ARS', 'Argentina Peso', symbol: '\$'),
  awg('AWG', 'Aruba Guilder', symbol: 'ƒ'),
  aud('AUD', 'Australia Dollar', symbol: '\$'),
  bsd('BSD', 'Bahamas Dollar', symbol: '\$'),
  bbd('BBD', 'Barbados Dollar', symbol: '\$'),
  byn('BYN', 'Belarus Ruble', symbol: 'Br'),
  bzd('BZD', 'Belize Dollar', symbol: 'BZ\$'),
  bmd('BMD', 'Bermuda Dollar', symbol: '\$'),
  bob('BOB', 'Bolivia Bolíviano', symbol: '\$b'),
  bam('BAM', 'Bosnia and Herzegovina Convertible Mark', symbol: 'KM'),
  bwp('BWP', 'Botswana Pula', symbol: 'P'),
  bgn('BGN', 'Bulgaria Lev', symbol: 'лв'),
  brl('BRL', 'Brazil Real', symbol: 'R\$'),
  bnd('BND', 'Brunei Darussalam Dollar', symbol: '\$'),
  khr('KHR', 'Cambodia Riel', symbol: '៛'),
  cad('CAD', 'Canada Dollar', symbol: '\$'),
  kyd('KYD', 'Cayman Islands Dollar', symbol: '\$'),
  clp('CLP', 'Chile Peso', symbol: '\$'),
  cny('CNY', 'China Yuan Renminbi', symbol: '¥'),
  cop('COP', 'Colombia Peso', symbol: '\$'),
  crc('CRC', 'Costa Rica Colon', symbol: '₡'),
  hrk('HRK', 'Croatia Kuna', symbol: 'kn'),
  cup('CUP', 'Cuba Peso', symbol: '₱'),
  czk('CZK', 'Czech Republic Koruna', symbol: 'Kč'),
  dkk('DKK', 'Denmark Krone', symbol: 'kr'),
  dop('DOP', 'Dominican Republic Peso', symbol: 'RD\$'),
  xcd('XCD', 'East Caribbean Dollar', symbol: '\$'),
  egp('EGP', 'Egypt Pound', symbol: '£'),
  svc('SVC', 'El Savador Colon', symbol: '\$'),
  eur('EUR', 'Euro Member Countries', symbol: '€'),
  fkp('FKP', 'Falkland Islands (Malvinas) Pound', symbol: '£'),
  fjd('FJD', 'Fiji Dollar', symbol: '\$'),
  ghs('GHS', 'Ghana Cedi', symbol: '¢'),
  gip('GIP', 'Gibraltar Pound', symbol: '£'),
  gtq('GTQ', 'Guatemala Quetzal', symbol: 'Q'),
  ggp('GGP', 'Guernsey Pound', symbol: '£'),
  gyd('GYD', 'Guyana Dollar', symbol: '\$'),
  hnl('HNL', 'Honduras Lempira', symbol: 'L'),
  hkd('HKD', 'Hong Kong Dollar', symbol: '\$'),
  huf('HUF', 'Hungary Forint', symbol: 'Ft'),
  isk('ISK', 'Iceland Krona', symbol: 'kr'),
  inr('INR', 'India Rupee'),
  idr('IDR', 'Indonesia Rupiah', symbol: 'Rp'),
  irr('IRR', 'Iran Rial', symbol: '﷼'),
  imp('IMP', 'Isle of Man Pound', symbol: '£'),
  ils('ILS', 'Israel Shekel', symbol: '₪'),
  jmd('JMD', 'Jamaica Dollar', symbol: 'J\$'),
  jpy('JPY', 'Japan Yen', symbol: '¥'),
  jep('JEP', 'Jersey Pound', symbol: '£'),
  kzt('KZT', 'Kazakhstan Tenge', symbol: 'лв'),
  kpw('KPW', 'Korea (North) Won', symbol: '₩'),
  krw('KRW', 'Korea (South) Won', symbol: '₩'),
  kgs('KGS', 'Kyrgyzstan Som', symbol: 'лв'),
  lak('LAK', 'Laos Kip', symbol: '₭'),
  lbp('LBP', 'Lebanon Pound', symbol: '£'),
  lrd('LRD', 'Liberia Dollar', symbol: '\$'),
  mkd('MKD', 'Macedonia Denar', symbol: 'ден'),
  myr('MYR', 'Malaysia Ringgit', symbol: 'RM'),
  mur('MUR', 'Mauritius Rupee', symbol: 'Rs'),
  mxn('MXN', 'Mexico Peso', symbol: '\$'),
  mnt('MNT', 'Mongolia Tughrik', symbol: '₮'),
  mzn('MZN', 'Mozambique Metical', symbol: 'MT'),
  nad('NAD', 'Namibia Dollar', symbol: '\$'),
  npr('NPR', 'Nepal Rupee', symbol: 'Rs'),
  ang('ANG', 'Netherlands Antilles Guilder', symbol: 'ƒ'),
  nzd('NZD', 'New Zealand Dollar', symbol: '\$'),
  nio('NIO', 'Nicaragua Cordoba', symbol: 'C\$'),
  ngn('NGN', 'Nigeria Naira', symbol: '₦'),
  nok('NOK', 'Norway Krone', symbol: 'kr'),
  omr('OMR', 'Oman Rial', symbol: '﷼'),
  pkr('PKR', 'Pakistan Rupee', symbol: 'Rs'),
  pab('PAB', 'Panama Balboa', symbol: 'B/.'),
  pyg('PYG', 'Paraguay Guarani', symbol: 'Gs'),
  pen('PEN', 'Peru Sol', symbol: 'S/.'),
  php('PHP', 'Philippines Peso', symbol: '₱'),
  pln('PLN', 'Poland Zloty', symbol: 'zł'),
  qar('QAR', 'Qatar Riyal', symbol: '﷼'),
  ron('RON', 'Romania Leu', symbol: 'lei'),
  rub('RUB', 'Russia Ruble', symbol: '₽'),
  shp('SHP', 'Saint Helena Pound', symbol: '£'),
  sar('SAR', 'Saudi Arabia Riyal', symbol: '﷼'),
  rsd('RSD', 'Serbia Dinar', symbol: 'Дин.'),
  scr('SCR', 'Seychelles Rupee', symbol: 'Rs'),
  sgd('SGD', 'Singapore Dollar', symbol: '\$'),
  sbd('SBD', 'Solomon Islands Dollar', symbol: '\$'),
  sos('SOS', 'Somalia Shilling', symbol: 'S'),
  zar('ZAR', 'South Africa Rand', symbol: 'R'),
  lkr('LKR', 'Sri Lanka Rupee', symbol: 'Rs'),
  sek('SEK', 'Sweden Krona', symbol: 'kr'),
  chf('CHF', 'Switzerland Franc'),
  srd('SRD', 'Suriname Dollar', symbol: '\$'),
  syp('SYP', 'Syria Pound', symbol: '£'),
  twd('TWD', 'Taiwan New Dollar', symbol: 'NT\$'),
  thb('THB', 'Thailand Baht', symbol: '฿'),
  ttd('TTD', 'Trinidad and Tobago Dollar', symbol: 'TT\$'),
  try0('TRY', 'Turkey Lira'),
  tvd('TVD', 'Tuvalu Dollar', symbol: '\$'),
  uah('UAH', 'Ukraine Hryvnia', symbol: '₴'),
  gbp('GBP', 'United Kingdom Pound', symbol: '£'),
  usd('USD', 'United States Dollar', symbol: '\$'),
  uyu('UYU', 'Uruguay Peso', symbol: '\$U'),
  uzs('UZS', 'Uzbekistan Som', symbol: 'лв'),
  vef('VEF', 'Venezuela Bolívar', symbol: 'Bs'),
  vnd('VND', 'Viet Nam Dong', symbol: '₫'),
  yer('YER', 'Yemen Rial', symbol: '﷼'),
  zwd('ZWD', 'Zimbabwe Dollar', symbol: 'Z\$'),
  ;

  const Currency(this.code, this.name, {this.symbol});

  final String code;
  final String name;
  final String? symbol;
}
