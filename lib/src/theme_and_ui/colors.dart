import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/settings/data/app_settings.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

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
      isDarkTheme: false,
      primary: const Color(0xFF495057),
      secondary1: const Color(0xFFadb5bd),
      secondary2: const Color(0xFFced4da),
      accent1: const Color(0xFF495057),
      accent2: const Color(0xFF343a40),
      background0: const Color(0xFFf8f9fa),
      background1: const Color(0xFFe9ecef),
      background2: const Color(0xFFced4da),
      onPrimary: const Color(0xFFf8f9fa),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFFf8f9fa),
      onBackground: const Color(0xFF212529),
      positive: const Color(0xFF03979d),
      negative: const Color(0xFFc9184a),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      systemIconBrightnessOnExtendedTabBar: Brightness.dark,
      systemIconBrightnessOnSmallTabBar: Brightness.dark,
    ),
    ThemeType.dark: AppThemeData(
      isDarkTheme: true,
      primary: const Color(0xFFced4da),
      secondary1: const Color(0xFFadb5bd),
      secondary2: const Color(0xFF6c757d),
      accent1: const Color(0xFFdee2e6),
      accent2: const Color(0xFFced4da),
      onPrimary: const Color(0xFF212529),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFF212529),
      background0: const Color(0xff262a2e),
      background1: const Color(0xFF1D2025),
      background2: const Color(0xFF14161A),
      onBackground: const Color(0xFFced4da),
      positive: const Color(0xff04cad1),
      negative: const Color(0xffd93664),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      systemIconBrightnessOnExtendedTabBar: Brightness.light,
      systemIconBrightnessOnSmallTabBar: Brightness.light,
    ),
  };

  static final _theme2 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDarkTheme: false,
      primary: const Color(0xFF03979d),
      secondary1: const Color(0xffbddcde),
      secondary2: const Color(0xff8ab5b8),
      accent1: const Color(0xff2ba9ad),
      accent2: const Color(0xFF03979d),
      background0: const Color(0xFFf8f9fa),
      background1: const Color(0xFFe9ecef),
      background2: const Color(0xffbcd0d1),
      onPrimary: const Color(0xFFf8f9fa),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFFf8f9fa),
      onBackground: const Color(0xFF212529),
      positive: const Color(0xFF03979d),
      negative: const Color(0xFFc9184a),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      systemIconBrightnessOnExtendedTabBar: Brightness.dark,
      systemIconBrightnessOnSmallTabBar: Brightness.dark,
    ),
    ThemeType.dark: AppThemeData(
      isDarkTheme: true,
      primary: const Color(0xFF03979d),
      secondary1: const Color(0xFFadb5bd),
      secondary2: const Color(0xFF6c757d),
      accent1: const Color(0xff04b2b8),
      accent2: const Color(0xff03a8ad),
      background0: const Color(0xff262a2e),
      background1: const Color(0xFF1D2025),
      background2: const Color(0xFF14161A),
      onPrimary: const Color(0xFF212529),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFF212529),
      onBackground: const Color(0xFFced4da),
      positive: const Color(0xff04cad1),
      negative: const Color(0xffd93664),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      systemIconBrightnessOnExtendedTabBar: Brightness.light,
      systemIconBrightnessOnSmallTabBar: Brightness.light,
    ),
  };

  static final _theme3 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDarkTheme: false,
      primary: const Color(0xff444d36),
      secondary1: const Color(0xffedf5e4),
      secondary2: const Color(0xffd4e0c5),
      accent1: const Color(0xffb5c99a),
      accent2: const Color(0xFF97a97c),
      background0: const Color(0xfffdfffa),
      background1: const Color(0xfffafcf7),
      background2: const Color(0xffcfe1b9),
      onPrimary: const Color(0xFFf8f9fa),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFFf8f9fa),
      onBackground: const Color(0xFF212529),
      positive: const Color(0xff444d36),
      negative: const Color(0xFFa4133c),
      onPositive: AppColors.black,
      onNegative: AppColors.white,
      systemIconBrightnessOnExtendedTabBar: Brightness.dark,
      systemIconBrightnessOnSmallTabBar: Brightness.dark,
    ),
    ThemeType.dark: AppThemeData(
      isDarkTheme: true,
      primary: const Color(0xFFe9f5db),
      secondary1: const Color(0xFFadb5bd),
      secondary2: const Color(0xFF6c757d),
      accent1: const Color(0xffb5c99a),
      accent2: const Color(0xFFcfe1b9),
      background0: const Color(0xff262a2e),
      background1: const Color(0xFF1D2025),
      background2: const Color(0xFF14161A),
      onPrimary: const Color(0xFF212529),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFF212529),
      onBackground: const Color(0xFFced4da),
      positive: const Color(0xFFcfe1b9),
      negative: const Color(0xfff26d93),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      systemIconBrightnessOnExtendedTabBar: Brightness.light,
      systemIconBrightnessOnSmallTabBar: Brightness.light,
    ),
  };

  static const white = Color(0xFFFCFCFC);
  static const black = Color(0xFF111111);

  static Color grey(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.5) : AppColors.white.addDark(0.5);
  static Color greyBorder(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.3) : AppColors.white.addDark(0.3);
  static Color greyBgr(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.15) : AppColors.white.addDark(0.1);
}
