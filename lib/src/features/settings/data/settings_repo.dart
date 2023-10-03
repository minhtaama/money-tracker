import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import 'app_settings.dart';
import '../../../utils/enums.dart';

class SettingsController extends StateNotifier<SettingsData> {
  SettingsController(this.realm) : super(SettingsData.fromDatabase(realm.find<SettingsDb>(0)!));

  final Realm realm;

  Future<void> set({ThemeType? themeType, int? themeIndex, Currency? currency}) async {
    state = state.copyWith(
      themeType: themeType,
      themeIndex: themeIndex,
      currency: currency,
    );
    realm.write(() => realm.add<SettingsDb>(state.toDatabase(), update: true));
  }
}

/// This provider should be call only at the root widget to provide data for `AppSettings`
/// and to use `set()` function in setting features.
///
/// Use **`context.currentSettings`** rather than this provider in child widgets to get
/// current settings state.
final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsData>((ref) {
  final realm = ref.watch(realmProvider);
  return SettingsController(realm);
});
