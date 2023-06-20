import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';

class AppColors {
  static const white = Color(0xFFFCFCFC);
  static const whiteSmoke = Color(0xFFF2F2F2);
  static const black = Color(0xFF111111);

  static final _theme1 = AppThemeData(
    isDuoColor: true,
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
  );

  static final _theme2 = AppThemeData(
    isDuoColor: true,
    primary: const Color(0xFF1d3557),
    secondary: const Color(0xFF1d3557),
    accent: const Color(0xFFe63946),
    primaryNegative: AppColors.white,
    secondaryNegative: AppColors.white,
    accentNegative: AppColors.white,
    background: AppColors.white,
    background2: AppColors.white,
    background3: AppColors.whiteSmoke,
    backgroundNegative: AppColors.black,
    placeholder2: const Color(0xFF457b9d),
    placeholder3: const Color(0xFF1d3557),
    overlayStyle: SystemUiOverlayStyle.light,
  );

  static final _theme3 = AppThemeData(
    isDuoColor: false,
    primary: const Color(0xFF1d3557),
    secondary: const Color(0xff517a93),
    accent: const Color(0xFF457b9d),
    primaryNegative: AppColors.white,
    secondaryNegative: AppColors.white,
    accentNegative: AppColors.white,
    background: AppColors.white,
    background2: AppColors.white,
    background3: AppColors.whiteSmoke,
    backgroundNegative: AppColors.black,
    placeholder2: const Color(0xFF457b9d),
    placeholder3: const Color(0xFF1d3557),
    overlayStyle: SystemUiOverlayStyle.light,
  );

  static List<AppThemeData> allThemeData = [
    _theme1,
    _theme2,
    _theme3,
  ];
}
