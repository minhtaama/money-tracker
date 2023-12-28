import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/settings/data/app_settings.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class AppColors {
  static List<Map<ThemeType, AppThemeData>> allThemeData = [
    _theme1,
    _theme2,
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
      positive: const Color(0xFF03979d),
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
      primary: const Color(0xFF343a40),
      secondary1: const Color(0xFFadb5bd),
      secondary2: const Color(0xFF6c757d),
      accent1: const Color(0xFF03979d),
      accent2: const Color(0xFF03979d),
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
      accent1: const Color(0xff04b2b8),
      accent2: const Color(0xff03a8ad),
      onPrimary: const Color(0xFF212529),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFF212529),
      background0: const Color(0xff262a2e),
      background1: const Color(0xFF1D2025),
      background2: const Color(0xFF14161A),
      onBackground: const Color(0xFFced4da),
      positive: const Color(0xFF03979d),
      negative: const Color(0xffd93664),
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
