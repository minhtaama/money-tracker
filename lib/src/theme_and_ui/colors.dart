import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/settings/data/app_settings.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class AppColors {
  static List<Map<ThemeType, AppThemeData>> allThemeData = [
    _theme1,
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
      secondary500: const Color(0xFFe5e5e5),
      secondary600: const Color(0xffcccccc),
      accent: const Color(0xFFfca311),
      onPrimary: AppColors.white,
      onSecondary: AppColors.black,
      onAccent: AppColors.black,
      background500: AppColors.white,
      background600: AppColors.white,
      background400: AppColors.white,
      onBackground: AppColors.black,
      positive: const Color(0xFF30A41F),
      negative: const Color(0xFFE76F51),
      onPositive: AppColors.white,
      onNegative: AppColors.white,
      systemIconBrightnessOnExtendedTabBar: Brightness.dark,
      systemIconBrightnessOnSmallTabBar: Brightness.dark,
    ),
    ThemeType.dark: AppThemeData(
      isDuoColor: true,
      isDarkTheme: true,
      primary: const Color(0xffc6cdee),
      secondary500: const Color(0xFFe5e5e5),
      secondary600: const Color(0xffcccccc),
      accent: const Color(0xFFfca311),
      onPrimary: AppColors.black,
      onSecondary: AppColors.black,
      onAccent: AppColors.black,
      background500: AppColors.lighterBlack,
      background600: AppColors.black,
      background400: AppColors.lightestBlack,
      onBackground: AppColors.white,
      positive: const Color(0xFF4BBD3A),
      negative: const Color(0xFFE76F51),
      onPositive: AppColors.black,
      onNegative: AppColors.black,
      systemIconBrightnessOnExtendedTabBar: Brightness.light,
      systemIconBrightnessOnSmallTabBar: Brightness.light,
    ),
  };

  static const white = Color(0xFFFCFCFC);
  static final darkerWhite = Color.lerp(AppColors.white, AppColors.black, 0.05)!;
  static final darkestWhite = Color.lerp(AppColors.white, AppColors.black, 0.12)!;
  static final lightestBlack = Color.lerp(AppColors.black, AppColors.white, 0.09)!;
  static final lighterBlack = Color.lerp(AppColors.black, AppColors.white, 0.05)!;
  static const black = Color(0xFF111111);

  static Color grey(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.5) : AppColors.white.addDark(0.5);
  static Color greyBorder(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.3) : AppColors.white.addDark(0.3);
  static Color greyBgr(BuildContext context) =>
      context.appTheme.isDarkTheme ? AppColors.black.addWhite(0.15) : AppColors.white.addDark(0.1);
}
