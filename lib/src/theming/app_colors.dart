import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';

class AppColors {
  static const white = Color(0xFFFEFEFE);
  static const whiteSmoke = Color(0xFFFAFAFA);
  static const lighterGrey = Color(0xFFD2D2D2);
  static const grey = Color(0xFFA1A1A1);
  static const darkerGrey = Color(0xFF696969);
  static const darkestGrey = Color(0xFF424040);
  static const black = Color(0xFF111111);
  static const lightText = Color(0xFFC4C4C4);
  static const darkText = Color(0xFF313131);

  static final white60 = const Color(0xFFFFFFFF).withOpacity(0.6);
  static final black20 = const Color(0xFF000000).withOpacity(0.2);
  static final black50 = const Color(0xFF000000).withOpacity(0.5);

  static final _theme1 = AppThemeData(
    primary: const Color(0xFF264653),
    secondary: const Color(0xFF2A9D8F),
    accent: const Color(0xFFE9C46A),
    primaryNegative: AppColors.white,
    secondaryNegative: AppColors.white,
    accentNegative: AppColors.darkestGrey,
    background: AppColors.white,
    background2: AppColors.white,
    background3: AppColors.white,
    backgroundNegative: AppColors.darkText,
    placeholder2: const Color(0xFFF4A261),
    placeholder3: const Color(0xFFE76F51),
    overlayStyle: SystemUiOverlayStyle.light,
  );

  static final _theme2 = AppThemeData(
    primary: const Color(0xFF1d3557),
    secondary: const Color(0xFF1d3557),
    accent: const Color(0xFFe63946),
    primaryNegative: AppColors.white,
    secondaryNegative: AppColors.white,
    accentNegative: AppColors.white,
    background: AppColors.white,
    background2: AppColors.white,
    background3: AppColors.lighterGrey,
    backgroundNegative: AppColors.darkText,
    placeholder2: const Color(0xFF457b9d),
    placeholder3: const Color(0xFF1d3557),
    overlayStyle: SystemUiOverlayStyle.light,
  );

  static List<AppThemeData> allThemeData = [
    _theme1,
    _theme2,
  ];
}
