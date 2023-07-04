import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/settings/domain/settings_isar.dart';
import '../../../../persistent/isar_data_store.dart';
import '../../../utils/enums.dart';

class SettingsController extends StateNotifier<SettingsIsar> {
  SettingsController(this.isar) : super(isar.settingsIsars.getSync(0)!);

  final Isar isar;

  Future<void> set({ThemeType? themeType, int? themeIndex}) async {
    state = state.copyWith(
      themeType: themeType,
      currentThemeIndex: themeIndex,
    );
    isar.writeTxn(() async => await isar.settingsIsars.put(state));
  }
}

final settingsControllerProvider = StateNotifierProvider<SettingsController, SettingsIsar>((ref) {
  final isar = ref.watch(isarProvider);
  return SettingsController(isar);
});
