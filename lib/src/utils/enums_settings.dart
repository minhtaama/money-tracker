part of 'enums.dart';

enum ThemeType {
  light(0),
  dark(1),
  system(2);

  final int databaseValue;

  const ThemeType(this.databaseValue);

  static ThemeType fromDatabaseValue(int value) {
    return ThemeType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum HomescreenType {
  scrollableSheet(0),
  pageView(1);

  final int databaseValue;

  const HomescreenType(this.databaseValue);

  static HomescreenType fromDatabaseValue(int value) {
    return HomescreenType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum LineChartInHomescreen {
  off(0),
  on(1);

  final int databaseValue;

  const LineChartInHomescreen(this.databaseValue);

  static LineChartInHomescreen fromDatabaseValue(int value) {
    return LineChartInHomescreen.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum Currency {
  all('ALL', 'Albania Lek', symbol: 'Lek'),
  afn('AFN', 'Afghanistan Afghani', symbol: '؋'),
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
  inr('INR', 'India Rupee', symbol: 'ir'),
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
  chf('CHF', 'Switzerland Franc', symbol: 'chf'),
  srd('SRD', 'Suriname Dollar', symbol: '\$'),
  syp('SYP', 'Syria Pound', symbol: '£'),
  twd('TWD', 'Taiwan New Dollar', symbol: 'NT\$'),
  thb('THB', 'Thailand Baht', symbol: '฿'),
  ttd('TTD', 'Trinidad and Tobago Dollar', symbol: 'TT\$'),
  try0('TRY', 'Turkey Lira', symbol: '\$tl'),
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

  /// https://www.xe.com/symbols/
  const Currency(this.code, this.name, {required this.symbol});

  final String code;
  final String name;
  final String symbol;
}

enum CurrencyType {
  symbolBefore(0),
  symbolAfter(1);

  final int databaseValue;

  const CurrencyType(this.databaseValue);

  static CurrencyType fromDatabaseValue(int value) {
    return CurrencyType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum LongDateType {
  dmy(0),
  mdy(1),
  ymd(2),
  ydm(3),
  ;

  final int databaseValue;

  const LongDateType(this.databaseValue);

  static LongDateType fromDatabaseValue(int value) {
    return LongDateType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum ShortDateType {
  dmy(0),
  mdy(1),
  ymd(2),
  ydm(3),
  dmmy(4),
  mmdy(5),
  ymmd(6),
  ydmm(7),
  ;

  final int databaseValue;

  const ShortDateType(this.databaseValue);

  static ShortDateType fromDatabaseValue(int value) {
    return ShortDateType.values.firstWhere((e) => e.databaseValue == value);
  }
}

enum FirstDayOfWeek {
  localeDefault(null),
  sunday(0),
  monday(1),
  saturday(6),
  ;

  final int? databaseValue;

  const FirstDayOfWeek(this.databaseValue);

  static FirstDayOfWeek fromDatabaseValue(int? value) {
    return FirstDayOfWeek.values.firstWhere((e) => e.databaseValue == value);
  }

  String getName(BuildContext context) {
    return switch (this) {
      FirstDayOfWeek.localeDefault => context.loc.localeDefault,
      FirstDayOfWeek.sunday => context.loc.sunday,
      FirstDayOfWeek.monday => context.loc.monday,
      FirstDayOfWeek.saturday => context.loc.saturday,
    };
  }
}
