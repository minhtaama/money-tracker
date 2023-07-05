import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemeData {
  final bool isDuoColor;
  final bool isDarkTheme;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s background
  /// * [IncomeCard]'s background
  /// * [BottomAppBarButton]'s color when selected
  ///
  /// __Dark Mode:__
  /// *
  /// *
  /// *
  final Color primary;

  /// __Light Mode:__
  /// * [ExtendedHomeTab]'s background
  ///
  /// __Dark Mode:__
  /// * [BottomAppBarButton]'s text when selected
  ///
  final Color secondary;

  /// __Light Mode:__
  /// * [ExpenseCard]'s background
  ///
  /// __Dark Mode:__
  /// * [BottomAppBarButton]'s icons and text color
  final Color accent;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s icon
  /// * [IncomeCard]'s text
  /// * [ExtendedHomeTab]'s text
  ///
  /// __Dark Mode:__
  ///
  final Color primaryNegative;

  /// __Light Mode:__
  ///
  /// __Dark Mode:__
  ///
  final Color secondaryNegative;

  /// __Light Mode:__
  /// * [ExpenseCard]'s text
  /// * [CustomFloatingActionButton]'s icon
  ///
  /// __DarkMode:__
  ///
  final Color accentNegative;

  /// __Light Mode:__
  /// * [ScaffoldWithBottomNavBar]'s color
  /// * [SmallHomeTab]'s background color
  /// * [BottomAppBarWithFAB]'s background
  /// * System nav bar color
  /// * Modals background
  ///
  /// __Dark Mode:__
  /// * [ScaffoldWithBottomNavBar]'s color
  /// * [SmallHomeTab]'s background color
  /// * [BottomAppBarWithFAB]'s background
  /// * System nav bar color
  final Color background;

  /// __Light Mode:__
  ///
  /// __DarkMode:__
  /// * [ExtendedHomeTab]'s background
  /// *
  final Color background2;

  /// __Light Mode:__
  /// * [RoundedIconButton]'s default background
  /// * [CardItem]'s default background
  ///
  /// __DarkMode:__
  /// * [RoundedIconButton]'s default background
  /// * [CardItem]'s default background
  /// * Modals background
  /// *
  final Color background3;

  /// __Both Light Mode and Dark Mode:__
  /// Colors of text on backgrounds
  final Color backgroundNegative;

  ///
  final Color placeholder2;

  ///
  final Color placeholder3;

  ///
  final SystemUiOverlayStyle overlayStyle;

  AppThemeData({
    required this.isDuoColor,
    required this.isDarkTheme,
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
}

/// Class for reading AppThemeData via InheritedWidget
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
