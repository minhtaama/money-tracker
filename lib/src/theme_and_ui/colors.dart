import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/theme_and_ui/app_theme.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';

class AppColors {
  static List<Map<ThemeType, AppThemeData>> allThemeData = [
    _theme1,
    _theme2,
    _theme3,
  ];

  /// Each element has a type of [List<Color>],
  /// where the `0` index is background color,
  /// and the `1` index is icon color
  static List<List<Color>> allColorsUserCanPick = [
    [const Color(0xFFff0000), AppColors.white],
    [const Color(0xFFff4000), AppColors.white],
    [const Color(0xFFff8000), AppColors.white],
    [const Color(0xFFffbf00), AppColors.black],
    [const Color(0xFFffef00), AppColors.black],
    [const Color(0xFFbfff00), AppColors.black],
    [const Color(0xFF80ff00), AppColors.black],
    [const Color(0xFF40ff00), AppColors.white],
    [const Color(0xFF00ff00), AppColors.white],
    [const Color(0xFF00ff40), AppColors.white],
    [const Color(0xFF00ff80), AppColors.black],
    [const Color(0xFF00ffbf), AppColors.black],
    [const Color(0xFF00ffff), AppColors.black],
    [const Color(0xFF00bfff), AppColors.black],
    [const Color(0xFF0080ff), AppColors.white],
    [const Color(0xFF0040ff), AppColors.white],
    [const Color(0xFF0000ff), AppColors.white],
    [const Color(0xFF4000ff), AppColors.white],
    [const Color(0xFF8000ff), AppColors.white],
    [const Color(0xFFbf00ff), AppColors.white],
    [const Color(0xFFff00ff), AppColors.white],
    [const Color(0xFFff00bf), AppColors.black],
    [const Color(0xFFff0080), AppColors.white],
    [const Color(0xFFff0040), AppColors.white],
    [const Color(0xFFff0000), AppColors.white],
  ];

  static final _theme1 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDuoColor: true,
      isDarkTheme: false,
      primary: const Color(0xFF14213d),
      secondary: const Color(0xFFe5e5e5),
      accent: const Color(0xFFfca311),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.black,
      accentNegative: AppColors.black,
      background: AppColors.white,
      background2: AppColors.white,
      background3: AppColors.white,
      backgroundNegative: AppColors.black,
      positive: const Color(0xFFF4A261),
      negative: const Color(0xFFE76F51),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
    ThemeType.dark: AppThemeData(
      isDuoColor: true,
      isDarkTheme: true,
      primary: const Color(0xFF14213d).addWhite(0.16),
      secondary: const Color(0xFFe5e5e5),
      accent: const Color(0xFFfca311),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.white,
      accentNegative: AppColors.black,
      background: AppColors.black,
      background2: AppColors.lighterBlack,
      background3: AppColors.lightestBlack,
      backgroundNegative: AppColors.white,
      positive: const Color(0xFFF4A261),
      negative: const Color(0xFFE76F51),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
  };

  static final _theme2 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDuoColor: true,
      isDarkTheme: false,
      primary: const Color(0xFF14213d),
      secondary: const Color(0xFF1d3557),
      accent: const Color(0xFFe63946),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.white,
      accentNegative: AppColors.black,
      background: AppColors.white,
      background2: AppColors.white,
      background3: AppColors.darkerWhite,
      backgroundNegative: AppColors.black,
      positive: const Color(0xFF457b9d),
      negative: const Color(0xFF1d3557),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
    ThemeType.dark: AppThemeData(
      isDuoColor: true,
      isDarkTheme: true,
      primary: const Color(0xFF14213d).addWhite(0.16),
      secondary: const Color(0xffb7d4e8),
      accent: const Color(0xFFe63946),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.white,
      accentNegative: AppColors.black,
      background: AppColors.black,
      background2: AppColors.lighterBlack,
      background3: AppColors.lightestBlack,
      backgroundNegative: AppColors.white,
      positive: const Color(0xFF457b9d),
      negative: const Color(0xFF1d3557),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
  };

  static final _theme3 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDuoColor: false,
      isDarkTheme: false,
      primary: const Color(0xFF1d3557),
      secondary: AppColors.darkerWhite,
      accent: const Color(0xFF457b9d),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.black,
      accentNegative: AppColors.white,
      background: AppColors.white,
      background2: AppColors.white,
      background3: AppColors.darkerWhite,
      backgroundNegative: AppColors.black,
      positive: const Color(0xFF457b9d),
      negative: const Color(0xFF1d3557),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
    ThemeType.dark: AppThemeData(
      isDuoColor: false,
      isDarkTheme: true,
      primary: const Color(0xff527cb4),
      secondary: const Color(0xff6396c4),
      accent: const Color(0xffa5cae1),
      primaryNegative: AppColors.white,
      secondaryNegative: AppColors.white,
      accentNegative: AppColors.white,
      background: AppColors.black,
      background2: AppColors.lighterBlack,
      background3: AppColors.lightestBlack,
      backgroundNegative: AppColors.white,
      positive: const Color(0xFF457b9d),
      negative: const Color(0xFF1d3557),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      overlayStyle: SystemUiOverlayStyle.light,
    ),
  };

  static const white = Color(0xFFFCFCFC);
  static final darkerWhite = Color.lerp(AppColors.white, AppColors.black, 0.05)!;
  static final darkestWhite = Color.lerp(AppColors.white, AppColors.black, 0.12)!;
  static final grey = const Color(0xFF696969).withOpacity(0.25);
  static final darkerGrey = const Color(0xFF696969).withOpacity(0.3);
  static final lightestBlack = Color.lerp(AppColors.black, AppColors.white, 0.09)!;
  static final lighterBlack = Color.lerp(AppColors.black, AppColors.white, 0.05)!;
  static const black = Color(0xFF111111);
}
