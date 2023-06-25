import 'package:flutter/material.dart';
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
    [Colors.redAccent, AppColors.white],
    [Colors.blueAccent, AppColors.white],
    [Colors.orangeAccent, AppColors.white],
    [Colors.yellow, AppColors.black],
    [Colors.pinkAccent, AppColors.white],
    [Colors.purpleAccent, AppColors.white],
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
      placeholder2: const Color(0xFFF4A261),
      placeholder3: const Color(0xFFE76F51),
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
      placeholder2: const Color(0xFFF4A261),
      placeholder3: const Color(0xFFE76F51),
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
      placeholder2: const Color(0xFF457b9d),
      placeholder3: const Color(0xFF1d3557),
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
      placeholder2: const Color(0xFF457b9d),
      placeholder3: const Color(0xFF1d3557),
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
      placeholder2: const Color(0xFF457b9d),
      placeholder3: const Color(0xFF1d3557),
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
      placeholder2: const Color(0xFF457b9d),
      placeholder3: const Color(0xFF1d3557),
      overlayStyle: SystemUiOverlayStyle.light,
    ),
  };

  static const white = Color(0xFFFCFCFC);
  static final darkerWhite = Color.lerp(AppColors.white, AppColors.black, 0.05)!;
  static final darkestWhite = Color.lerp(AppColors.white, AppColors.black, 0.12)!;
  static final grey = const Color(0xFF696969).withOpacity(0.25);
  static final lightestBlack = Color.lerp(AppColors.black, AppColors.white, 0.09)!;
  static final lighterBlack = Color.lerp(AppColors.black, AppColors.white, 0.05)!;
  static const black = Color(0xFF111111);
}
