import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/common_widgets/custom_line_chart.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';

import '../../../utils/enums.dart';

/// Class for reading SettingsData via InheritedWidget
class AppSettings extends InheritedWidget {
  const AppSettings({
    super.key,
    required this.data,
    required super.child,
  });

  final AppSettingsData data;

  static AppSettingsData of(BuildContext context) {
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
class AppSettingsData {
  final int themeIndex;

  final ThemeType themeType;

  final Currency currency;

  final bool showAmount;
  final bool showDecimalDigits;

  factory AppSettingsData.fromDatabase(SettingsDb settingsDb) {
    ThemeType themeType = switch (settingsDb.themeType) {
      0 => ThemeType.light,
      1 => ThemeType.dark,
      _ => ThemeType.system,
    };

    Currency currency = Currency.values[settingsDb.currencyIndex];

    return AppSettingsData._(
      themeIndex: settingsDb.themeIndex,
      themeType: themeType,
      currency: currency,
      showDecimalDigits: settingsDb.showDecimalDigits,
      showAmount: settingsDb.showBalanceInHomeScreen,
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
      showBalanceInHomeScreen: showAmount,
      showDecimalDigits: showDecimalDigits,
    );
  }

  AppSettingsData._({
    required this.themeIndex,
    required this.themeType,
    required this.currency,
    required this.showDecimalDigits,
    required this.showAmount,
  });

  AppSettingsData copyWith({
    int? themeIndex,
    ThemeType? themeType,
    Currency? currency,
    bool? showAmount,
    bool? showDecimalDigits,
  }) {
    return AppSettingsData._(
      themeIndex: themeIndex ?? this.themeIndex,
      themeType: themeType ?? this.themeType,
      currency: currency ?? this.currency,
      showAmount: showAmount ?? this.showAmount,
      showDecimalDigits: showDecimalDigits ?? this.showDecimalDigits,
    );
  }
}

class AppThemeData {
  final bool isDarkTheme;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s background
  /// * [IncomeCard]'s background
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
  ///
  ///
  final Color secondary1;

  /// __Light Mode:__
  /// * [CustomLineChart] tooltip background
  ///
  /// __Dark Mode:__
  ///
  ///
  final Color secondary2;

  /// __Light Mode:__
  /// * [CustomLineChart]'s color
  ///
  /// __Dark Mode:__
  /// * [CustomLineChart]'s color
  final Color accent1;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s background
  ///
  /// __Dark Mode:__
  ///
  ///
  final Color accent2;

  /// __Light Mode:__
  /// * [CustomFloatingActionButton]'s icon
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
  final Color background0;

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
  final Color background1;

  /// __Light Mode:__
  /// * [BottomAppBarButton]'s color when selected
  ///
  /// __DarkMode:__
  /// * [ExtendedHomeTab]'s background
  /// *
  final Color background2;

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
    required this.isDarkTheme,
    required this.primary,
    required this.secondary1,
    required this.secondary2,
    required this.accent1,
    required this.accent2,
    required this.onPrimary,
    required this.onSecondary,
    required this.onAccent,
    required this.background1,
    required this.background2,
    required this.background0,
    required this.onBackground,
    required this.positive,
    required this.onPositive,
    required this.negative,
    required this.onNegative,
    required this.systemIconBrightnessOnExtendedTabBar,
    required this.systemIconBrightnessOnSmallTabBar,
  });
}
