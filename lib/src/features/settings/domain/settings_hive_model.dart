import 'package:hive/hive.dart';
import '../../../utils/enums.dart';

part 'settings_hive_model.g.dart';

@HiveType(typeId: 2)
class SettingsHiveModel {
  SettingsHiveModel({
    required this.currentThemeIndex,
    required this.themeType,
  });

  @HiveField(0)
  final int currentThemeIndex;
  @HiveField(1)
  final ThemeType themeType;

  SettingsHiveModel copyWith({
    int? currentThemeIndex,
    ThemeType? themeType,
  }) {
    return SettingsHiveModel(
      currentThemeIndex: currentThemeIndex ?? this.currentThemeIndex,
      themeType: themeType ?? this.themeType,
    );
  }

  @override
  String toString() {
    return 'SettingsHiveModel{currentThemeIndex: $currentThemeIndex, themeType: $themeType}';
  }
}
