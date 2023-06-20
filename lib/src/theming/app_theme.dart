import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppThemeData {
  final bool isDuoColor;

  /// [BottomAppBarButton] color when selected or outline when not selected
  ///
  /// [CustomFloatingActionButton]'s background
  ///
  /// [IncomeCard]'s background
  final Color primary;

  /// [ExtendedHomeTab]'s background
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
  /// [BottomAppBarWithFAB]'s background
  ///
  /// Modals background
  final Color background;

  /// [CardItem]'s default background
  final Color background2;

  /// [RoundedIconButton]'s default background
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
    required this.isDuoColor,
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
