import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_settings.dart';
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
    [const Color(0xFF117864), AppColors.white],
    [const Color(0xFF1ABC9C), AppColors.white],
    [const Color(0xFF46D0B6), AppColors.black],
    [const Color(0xFF51CC7A), AppColors.black],
    [const Color(0xFF4FC27D), AppColors.black],
    [const Color(0xFF2ECC71), AppColors.white],
    [const Color(0xFF27AE60), AppColors.white],
    [const Color(0xFF1A9854), AppColors.white],
    [const Color(0xFF1A844A), AppColors.white],
    [const Color(0xFF66A3D2), AppColors.black],
    [const Color(0xff318ecc), AppColors.white],
    [const Color(0xFF1F5882), AppColors.white],
    [const Color(0xFF4D6278), AppColors.white],
    [const Color(0xFF3F536B), AppColors.white],
    [const Color(0xFF34495E), AppColors.white],
    [const Color(0xFF2C3E50), AppColors.white],
    [const Color(0xFF1F2F4A), AppColors.white],
    [const Color(0xFF1A2733), AppColors.white],
    [const Color(0xFF6B7678), AppColors.white],
    [const Color(0xFF95A5A6), AppColors.white],
    [const Color(0xFFC0C9CA), AppColors.black],
    [const Color(0xFF9D601A), AppColors.white],
    [const Color(0xFFC27C0E), AppColors.white],
    [const Color(0xFFF39C12), AppColors.white],
    [const Color(0xFFFFBD49), AppColors.black],
    [const Color(0xFFFF9F4A), AppColors.black],
    [const Color(0xFFE67E22), AppColors.white],
    [const Color(0xFFFF6D2A), AppColors.black],
    [const Color(0xFFEF6F66), AppColors.black],
    [const Color(0xFFE74C3C), AppColors.white],
    [const Color(0xFFD35400), AppColors.white],
    [const Color(0xFFA53F00), AppColors.white],
    [const Color(0xFF992C22), AppColors.white],
    [const Color(0xFF663A77), AppColors.white],
    [const Color(0xFF9B59B6), AppColors.white],
    [const Color(0xFFB583C9), AppColors.black],
  ];

  static final _theme1 = <ThemeType, AppThemeData>{
    ThemeType.light: AppThemeData(
      isDarkTheme: false,
      primary: const Color(0xFF495057),
      secondary1: const Color(0xffe6ecf5),
      secondary2: const Color(0xFFced4da),
      accent1: const Color(0xFF495057),
      accent2: const Color(0xFF343a40),
      background0: const Color(0xFFf8f9fa),
      background1: const Color(0xFFe9ecef),
      background2: const Color(0xFFced4da),
      onPrimary: const Color(0xFFf8f9fa),
      onSecondary: AppColors.black,
      onAccent: const Color(0xFFf8f9fa),
      onBackground: AppColors.black,
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
      onBackground: AppColors.white,
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
      onSecondary: AppColors.black,
      onAccent: const Color(0xFFf8f9fa),
      onBackground: AppColors.black,
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
      onBackground: AppColors.white,
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
      secondary1: const Color(0xfffefffa),
      secondary2: const Color(0xffd4e0c5),
      accent1: const Color(0xffb5c99a),
      accent2: const Color(0xFF97a97c),
      background0: const Color(0xfffefffa),
      background1: const Color(0xfff0f2eb),
      background2: const Color(0xffcfe1b9),
      onPrimary: const Color(0xFFf8f9fa),
      onSecondary: const Color(0xFF212529),
      onAccent: const Color(0xFFf8f9fa),
      onBackground: const Color(0xFF212529),
      positive: const Color(0xff718059),
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
      onBackground: AppColors.white,
      positive: const Color(0xFFcfe1b9),
      negative: const Color(0xfff26d93),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      systemIconBrightnessOnExtendedTabBar: Brightness.light,
      systemIconBrightnessOnSmallTabBar: Brightness.light,
    ),
  };

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF111111);
  static const greyConst = Color(0x80666666);

  static Color grey(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.5) : AppColors.white.addDark(0.5);
  static Color greyBorder(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.21) : AppColors.white.addDark(0.21);
  static Color greyBgr(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.14) : AppColors.white.addDark(0.17);
}
