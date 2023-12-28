import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/common_widgets/custom_line_chart.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';

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
  /// * Colors of highlight in [DateTimeSelector] and [DateTimeSelectorCredit]
  ///
  /// __Dark Mode:__
  /// * Colors of highlight in [DateTimeSelector] and [DateTimeSelectorCredit]
  /// *
  /// *
  final Color primary;

  /// __Light Mode:__
  /// * [ExtendedHomeTab]'s background
  ///
  /// __Dark Mode:__
  /// * [BottomAppBarButton]'s text
  ///
  final Color secondary500;

  /// __Light Mode:__
  /// * [ExtendedHomeTab]'s background
  ///
  /// __Dark Mode:__
  /// * [BottomAppBarButton]'s text when selected
  ///
  final Color secondary600;

  /// __Light Mode:__
  /// * [ExpenseCard]'s background
  /// * [CustomLineChart]'s color
  /// __Dark Mode:__
  /// * [BottomAppBarButton]'s icons and text color
  /// * [CustomLineChart]'s color
  final Color accent;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s icon
  /// * [IncomeCard]'s text
  /// * [ExtendedHomeTab]'s text
  ///
  /// __Dark Mode:__
  ///
  final Color onPrimary;

  /// __Light Mode:__
  ///
  /// __Dark Mode:__
  ///
  final Color onSecondary;

  /// __Light Mode:__
  /// * [ExpenseCard]'s text
  /// * [CustomFloatingActionButton]'s icon
  ///
  /// __DarkMode:__
  ///
  final Color onAccent;

  /// __Light Mode:__
  /// * [RoundedIconButton]'s default background
  /// * [CardItem]'s default background
  ///
  /// __DarkMode:__
  /// * [RoundedIconButton]'s default background
  /// * [CardItem]'s default background
  /// * Modals background
  /// *
  final Color background400;

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
  final Color background500;

  /// __Light Mode:__
  ///
  /// __DarkMode:__
  /// * [ExtendedHomeTab]'s background
  /// *
  final Color background600;

  /// __Both Light Mode and Dark Mode:__
  /// Colors of text on backgrounds
  final Color onBackground;

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
    required this.secondary500,
    required this.secondary600,
    required this.accent,
    required this.onPrimary,
    required this.onSecondary,
    required this.onAccent,
    required this.background500,
    required this.background600,
    required this.background400,
    required this.onBackground,
    required this.positive,
    required this.onPositive,
    required this.negative,
    required this.onNegative,
    required this.systemIconBrightnessOnExtendedTabBar,
    required this.systemIconBrightnessOnSmallTabBar,
  });
}
