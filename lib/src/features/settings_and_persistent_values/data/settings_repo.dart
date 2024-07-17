import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import '../../../../persistent/realm_dto.dart';
import '../application/app_settings.dart';
import '../../../utils/enums.dart';

class SettingsController extends Notifier<AppSettingsData> {
  @override
  AppSettingsData build() {
    final realm = ref.read(realmProvider);
    return AppSettingsData.fromDatabase(realm.find<SettingsDb>(0)!);
  }

  Future<void> set({
    int? themeIndex,
    ThemeType? themeType,
    Currency? currency,
    Locale? locale,
    CurrencyType? currencyType,
    bool? showDecimalDigits,
    LongDateType? longDateType,
    ShortDateType? shortDateType,
    FirstDayOfWeek? firstDayOfWeek,
    HomescreenType? homescreenType,
    LineChartInHomescreen? lineChartInHomescreen,
  }) async {
    final realm = ref.read(realmProvider);

    state = state.copyWith(
      themeIndex: themeIndex,
      themeType: themeType,
      currency: currency,
      locale: locale,
      currencyType: currencyType,
      showDecimalDigits: showDecimalDigits,
      longDateType: longDateType,
      shortDateType: shortDateType,
      firstDayOfWeek: firstDayOfWeek,
      homescreenType: homescreenType,
      lineChartInHomescreen: lineChartInHomescreen,
    );

    realm.write(() => realm.add<SettingsDb>(state.toDatabase(), update: true));
  }
}

/// This provider should be call only at the root widget to provide data for `AppSettings`
/// and to use `set()` function in setting features.
///
/// Use **`context.currentSettings`** rather than this provider in child widgets to get
/// current settings state.
final settingsControllerProvider = NotifierProvider<SettingsController, AppSettingsData>(() {
  return SettingsController();
});
