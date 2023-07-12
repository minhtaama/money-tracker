import '../../../utils/enums.dart';
import 'package:isar/isar.dart';

part 'settings_isar.g.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
@Collection()
class SettingsIsar {
  final Id id = 0;
  int currentThemeIndex = 0;
  @enumerated
  ThemeType themeType = ThemeType.light;
  @enumerated
  Currency currency = Currency.usd;

  SettingsIsar copyWith({
    int? currentThemeIndex,
    ThemeType? themeType,
    Currency? currency,
  }) {
    return SettingsIsar()
      ..currentThemeIndex = currentThemeIndex ?? this.currentThemeIndex
      ..themeType = themeType ?? this.themeType
      ..currency = currency ?? this.currency;
  }
}
