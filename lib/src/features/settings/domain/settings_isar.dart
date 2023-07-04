import '../../../utils/enums.dart';
import 'package:isar/isar.dart';

part 'settings_isar.g.dart';

@Collection()
class SettingsIsar {
  final Id id = 0;
  int currentThemeIndex = 0;
  @enumerated
  ThemeType themeType = ThemeType.light;

  SettingsIsar copyWith({
    int? currentThemeIndex,
    ThemeType? themeType,
  }) {
    return SettingsIsar()
      ..currentThemeIndex = currentThemeIndex ?? this.currentThemeIndex
      ..themeType = themeType ?? this.themeType;
  }
}
