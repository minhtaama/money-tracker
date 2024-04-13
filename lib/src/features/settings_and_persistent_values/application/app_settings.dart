import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/charts_and_carousel/presentation/custom_line_chart.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/bottom_app_bar/custom_fab.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';

import '../../../utils/enums.dart';

// Access this class through `context.currentSettings`
class AppSettingsData {
  final int themeIndex;

  final ThemeType themeType;

  final Currency currency;

  final Locale locale;

  final CurrencyType currencyType;

  final bool showDecimalDigits;

  final LongDateType longDateType;

  final ShortDateType shortDateType;

  factory AppSettingsData.fromDatabase(SettingsDb settingsDb) {
    return AppSettingsData._(
      themeIndex: settingsDb.themeIndex,
      themeType: ThemeType.fromDatabaseValue(settingsDb.themeType),
      currency: Currency.values[settingsDb.currencyIndex],
      locale: Locale(settingsDb.locale),
      currencyType: CurrencyType.fromDatabaseValue(settingsDb.currencyType),
      showDecimalDigits: settingsDb.showDecimalDigits,
      longDateType: LongDateType.fromDatabaseValue(settingsDb.longDateType),
      shortDateType: ShortDateType.fromDatabaseValue(settingsDb.shortDateType),
    );
  }

  SettingsDb toDatabase() {
    int currencyRealmData = Currency.values.indexOf(currency);

    return SettingsDb(
      0,
      themeIndex: themeIndex,
      themeType: themeType.databaseValue,
      currencyIndex: currencyRealmData,
      locale: locale.languageCode,
      currencyType: currencyType.databaseValue,
      showDecimalDigits: showDecimalDigits,
      longDateType: longDateType.databaseValue,
      shortDateType: shortDateType.databaseValue,
    );
  }

  AppSettingsData._({
    required this.themeIndex,
    required this.themeType,
    required this.currency,
    required this.locale,
    required this.currencyType,
    required this.showDecimalDigits,
    required this.longDateType,
    required this.shortDateType,
  });

  AppSettingsData copyWith({
    int? themeIndex,
    ThemeType? themeType,
    Currency? currency,
    Locale? locale,
    CurrencyType? currencyType,
    bool? showDecimalDigits,
    LongDateType? longDateType,
    ShortDateType? shortDateType,
  }) {
    return AppSettingsData._(
      themeIndex: themeIndex ?? this.themeIndex,
      themeType: themeType ?? this.themeType,
      currency: currency ?? this.currency,
      locale: locale ?? this.locale,
      currencyType: currencyType ?? this.currencyType,
      showDecimalDigits: showDecimalDigits ?? this.showDecimalDigits,
      longDateType: longDateType ?? this.longDateType,
      shortDateType: shortDateType ?? this.shortDateType,
    );
  }
}

class AppThemeData {
  final bool isDarkTheme;

  /// __Light Mode:__
  /// * Colors of highlight in [DateTimeSelector] and [DateTimeSelectorCredit]
  ///
  /// __Dark Mode:__
  /// * Colors of highlight in [DateTimeSelector] and [DateTimeSelectorCredit]
  /// *
  /// *
  final Color primary;

  /// __Light Mode:__
  ///
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
  /// * [ExtendedHomeTab]'s background
  ///
  /// __DarkMode:__
  /// * [RoundedIconButton]'s default background
  /// * [CardItem]'s default background
  /// * Modals background
  /// *
  final Color background0;

  /// __Light Mode:__
  /// * DO NOT USE COLOR HAS BRIGHTNESS > 99%
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

/// Class for reading AppSettingsData via InheritedWidget
/// No need to change this class when add property
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
      throw StateError('Could not find ancestor widget of type `AppSettings`');
    }
  }

  @override
  bool updateShouldNotify(AppSettings oldWidget) => data != oldWidget.data;
}
