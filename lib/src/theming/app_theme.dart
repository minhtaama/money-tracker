import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppThemeData {
  final Color primary;
  final Color secondary; // TabButton, FAB-Background
  final Color accent;
  final Color accentNegative; // TabButton Text, FAB Icon
  final Color background; // Scaffold, ChildAppBar
  final Color background2; // CardItem
  final Color background3; // BottomAppBar
  final Color placeholder2;
  final Color placeholder3;
  final SystemUiOverlayStyle overlayStyle;

  AppThemeData({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.accentNegative,
    required this.background,
    required this.background2,
    required this.background3,
    required this.placeholder2,
    required this.placeholder3,
    required this.overlayStyle,
  });

  factory AppThemeData.defaultWithSwatch(List<Color> swatch) {
    return AppThemeData(
      primary: swatch[0],
      secondary: swatch[1],
      accent: AppColors.darkestGrey,
      accentNegative: AppColors.white,
      background: AppColors.lightestGrey,
      background2: AppColors.white,
      background3: AppColors.white,
      placeholder2: AppColors.white60,
      placeholder3: swatch[3],
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static AppThemeData lerp(AppThemeData a, AppThemeData b, double t) {
    final overlayStyle = t < 0.5 ? a.overlayStyle : b.overlayStyle;
    return AppThemeData(
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      accent: Color.lerp(a.accent, b.accent, t)!,
      accentNegative: Color.lerp(a.accentNegative, b.accentNegative, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      background2: Color.lerp(a.background2, b.background2, t)!,
      background3: Color.lerp(a.background3, b.background3, t)!,
      placeholder2: Color.lerp(a.placeholder2, b.placeholder2, t)!,
      placeholder3: Color.lerp(a.placeholder3, b.placeholder3, t)!,
      overlayStyle: overlayStyle,
    );
  }
}

// Class for reading AppThemeData via InheritedWidget
class AppTheme extends InheritedWidget {
  const AppTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final AppThemeData data;

  static AppThemeData of(BuildContext context) {
    final theme = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    if (theme != null) {
      return theme.data;
    } else {
      throw StateError('Could not find ancestor widget of type `AppTheme`');
    }
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => data != oldWidget.data;
}

// class AppThemeVariants {
//   AppThemeVariants(List<Color> swatch)
//       : themes = [
//           AppThemeData(
//             primary: AppColors.white,
//             secondary: AppColors.lightestGrey,
//             accent: swatch[0],
//             accentNegative: AppColors.white,
//             background: AppColors.lighterGrey,
//             background2: AppColors.white,
//             primaryNegative: swatch[0],
//             placeholder2: swatch[0],
//             placeholder3: AppColors.darkText,
//             overlayStyle: SystemUiOverlayStyle.dark,
//           ),
//           AppThemeData(
//             primary: AppColors.black,
//             secondary: AppColors.darkestGrey,
//             accent: swatch[0],
//             accentNegative: AppColors.white,
//             background: AppColors.darkerGrey,
//             background2: AppColors.white,
//             primaryNegative: AppColors.white,
//             placeholder2: AppColors.white,
//             placeholder3: AppColors.lightText,
//             overlayStyle: SystemUiOverlayStyle.light,
//           ),
//         ];
//
//   final List<AppThemeData> themes;
// }
