import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/bottom_app_bar_with_fab.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/custom_fab.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/bottom_app_bar_button.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/scaffold_with_bottom_nav_bar_screen.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';

class AppThemeData {
  /// [BottomAppBarButton] color when selected or outline when not selected
  ///
  /// [CustomFloatingActionButton]'s background
  ///
  /// [IncomeCard]'s background
  final Color primary;

  /// [ExtendedHomeTab]'s circle background
  final Color secondary;

  /// [ExpenseCard]'s background
  final Color accent;

  /// [BottomAppBarButton]'s text when selected
  ///
  /// [CustomFloatingActionButton]'s icon
  ///
  /// [IncomeCard]'s text
  ///
  /// [ExtendedHomeTab]'s text
  final Color primaryNegative;

  /// [ExpandedHomeTab]'s text
  final Color secondaryNegative;

  /// [ExpenseCard]'s text
  ///
  /// [CustomFloatingActionButton]'s icon
  final Color accentNegative;

  /// [ScaffoldWithBottomNavBar]'s color
  ///
  /// [SmallHomeTab]'s background color
  ///
  /// Modals background
  final Color background;

  /// [CardItem]'s default background
  final Color background2;

  ///[BottomAppBarWithFAB]'s background
  final Color background3;

  /// Colors of text on backgrounds
  final Color backgroundNegative;

  ///
  final Color placeholder2;

  ///
  final Color placeholder3;

  ///
  final SystemUiOverlayStyle overlayStyle;

  AppThemeData({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.primaryNegative,
    required this.secondaryNegative,
    required this.accentNegative,
    required this.background,
    required this.background2,
    required this.background3,
    required this.backgroundNegative,
    required this.placeholder2,
    required this.placeholder3,
    required this.overlayStyle,
  });

  // static AppThemeData lerp(AppThemeData a, AppThemeData b, double t) {
  //   final overlayStyle = t < 0.5 ? a.overlayStyle : b.overlayStyle;
  //   return AppThemeData(
  //     primary: Color.lerp(a.primary, b.primary, t)!,
  //     secondary: Color.lerp(a.secondary, b.secondary, t)!,
  //     accent: Color.lerp(a.accent, b.accent, t)!,
  //     primaryNegative: Color.lerp(a.primaryNegative, b.primaryNegative, t)!,
  //     secondaryNegative: Color.lerp(a.secondaryNegative, b.secondaryNegative, t)!,
  //     accentNegative: Color.lerp(a.accentNegative, b.accentNegative, t)!,
  //     background: Color.lerp(a.background, b.background, t)!,
  //     background2: Color.lerp(a.background2, b.background2, t)!,
  //     background3: Color.lerp(a.background3, b.background3, t)!,
  //     backgroundNegative: Color.lerp(a.backgroundNegative, b.backgroundNegative, t)!,
  //     placeholder2: Color.lerp(a.placeholder2, b.placeholder2, t)!,
  //     placeholder3: Color.lerp(a.placeholder3, b.placeholder3, t)!,
  //     overlayStyle: overlayStyle,
  //   );
  // }
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
