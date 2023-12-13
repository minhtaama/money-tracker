import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';

import '../../../utils/enums.dart';

/// Class for reading SettingsData via InheritedWidget
class AppSettings extends InheritedWidget {
  const AppSettings({
    super.key,
    required this.data,
    required super.child,
  });

  final SettingsData data;

  static SettingsData of(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<AppSettings>();
    if (settings != null) {
      return settings.data;
    } else {
      throw StateError('Could not find ancestor widget of type `AppTheme`');
    }
  }

  @override
  bool updateShouldNotify(AppSettings oldWidget) => data != oldWidget.data;
}

// Access this class through `context.currentSettings`
class SettingsData {
  final int themeIndex;

  final ThemeType themeType;

  final Currency currency;

  final bool showBalanceInHomeScreen;
  final bool showDecimalDigits;

  factory SettingsData.fromDatabase(SettingsDb settingsDb) {
    ThemeType themeType = switch (settingsDb.themeType) {
      0 => ThemeType.light,
      1 => ThemeType.dark,
      _ => ThemeType.system,
    };

    Currency currency = Currency.values[settingsDb.currencyIndex];

    return SettingsData._(
      themeIndex: settingsDb.themeIndex,
      themeType: themeType,
      currency: currency,
      showDecimalDigits: settingsDb.showDecimalDigits,
      showBalanceInHomeScreen: settingsDb.showBalanceInHomeScreen,
    );
  }

  SettingsDb toDatabase() {
    int themeTypeRealmData = switch (themeType) {
      ThemeType.light => 0,
      ThemeType.dark => 1,
      ThemeType.system => 2,
    };

    int currencyRealmData = Currency.values.indexOf(currency);

    return SettingsDb(
      0,
      themeIndex: themeIndex,
      themeType: themeTypeRealmData,
      currencyIndex: currencyRealmData,
      showBalanceInHomeScreen: showBalanceInHomeScreen,
      showDecimalDigits: showDecimalDigits,
    );
  }

  SettingsData._({
    required this.themeIndex,
    required this.themeType,
    required this.currency,
    required this.showDecimalDigits,
    required this.showBalanceInHomeScreen,
  });

  SettingsData copyWith({
    int? themeIndex,
    ThemeType? themeType,
    Currency? currency,
    bool? showBalanceInHomeScreen,
    bool? showDecimalDigits,
  }) {
    return SettingsData._(
      themeIndex: themeIndex ?? this.themeIndex,
      themeType: themeType ?? this.themeType,
      currency: currency ?? this.currency,
      showBalanceInHomeScreen: showBalanceInHomeScreen ?? this.showBalanceInHomeScreen,
      showDecimalDigits: showDecimalDigits ?? this.showDecimalDigits,
    );
  }
}

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
  final Color positive;

  ///
  final Color negative;

  ///
  final Color onPositive;

  ///
  final Color onNegative;

  ///
  final Brightness systemIconBrightnessOnExtendedTabBar;
  final Brightness systemIconBrightnessOnSmallTabBar;

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
    required this.positive,
    required this.onPositive,
    required this.negative,
    required this.onNegative,
    required this.systemIconBrightnessOnExtendedTabBar,
    required this.systemIconBrightnessOnSmallTabBar,
  });
}
