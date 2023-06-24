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

  static List<Color> allColorsUserCanPick = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.orangeAccent,
    Colors.yellow,
    Colors.pinkAccent,
    Colors.purpleAccent,
  ];

  static final _theme1 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDuoColor: true,
      isDarkTheme: false,
      primary: const Color(0xFF14213d),
      secondary: const Color(0xFFe5e5e5),
      accent: const Color(0xFFfca311),
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._black,
      accentNegative: AppColors._black,
      background: AppColors._white,
      background2: AppColors._white,
      background3: AppColors._white,
      backgroundNegative: AppColors._black,
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
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._white,
      accentNegative: AppColors._white,
      background: AppColors._black,
      background2: AppColors._lighterBlack,
      background3: AppColors._lightestBlack,
      backgroundNegative: AppColors._white,
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
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._white,
      accentNegative: AppColors._black,
      background: AppColors._white,
      background2: AppColors._white,
      background3: AppColors._darkerWhite,
      backgroundNegative: AppColors._black,
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
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._white,
      accentNegative: AppColors._black,
      background: AppColors._black,
      background2: AppColors._lighterBlack,
      background3: AppColors._lightestBlack,
      backgroundNegative: AppColors._white,
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
      secondary: AppColors._darkerWhite,
      accent: const Color(0xFF457b9d),
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._black,
      accentNegative: AppColors._white,
      background: AppColors._white,
      background2: AppColors._white,
      background3: AppColors._darkerWhite,
      backgroundNegative: AppColors._black,
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
      primaryNegative: AppColors._white,
      secondaryNegative: AppColors._white,
      accentNegative: AppColors._white,
      background: AppColors._black,
      background2: AppColors._lighterBlack,
      background3: AppColors._lightestBlack,
      backgroundNegative: AppColors._white,
      placeholder2: const Color(0xFF457b9d),
      placeholder3: const Color(0xFF1d3557),
      overlayStyle: SystemUiOverlayStyle.light,
    ),
  };

  static const _white = Color(0xFFFCFCFC);
  static final _darkerWhite = Color.lerp(AppColors._white, AppColors._black, 0.05)!;
  static final _lightestBlack = Color.lerp(AppColors._black, AppColors._white, 0.09)!;
  static final _lighterBlack = Color.lerp(AppColors._black, AppColors._white, 0.05)!;
  static const _black = Color(0xFF111111);
}
