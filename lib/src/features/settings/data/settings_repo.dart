import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/settings/domain/settings_isar.dart';
import '../../../../persistent/isar_data_store.dart';
import '../../../utils/enums.dart';

class SettingsRepository {
  SettingsRepository(this.isar);
  final Isar isar;

  Stream<SettingsIsar?> _watchSettingsObject() {
    return isar.settingsIsars.watchObject(0, fireImmediately: true);
  }

  Future<void> setThemeType(ThemeType themeType) async {
    final settingsObj = await isar.settingsIsars.get(0);
    settingsObj!.themeType = themeType;
    isar.writeTxn(() async => await isar.settingsIsars.put(settingsObj));
  }

  Future<void> setThemeColor(int index) async {
    final settingsObj = await isar.settingsIsars.get(0);
    settingsObj!.currentThemeIndex = index;
    isar.writeTxn(() async => await isar.settingsIsars.put(settingsObj));
  }
}

/// Read this provider to write settings to Isar
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return SettingsRepository(isar);
});

/// Watch this provider to get settingsObject
final settingsObjectProvider = StreamProvider.autoDispose((ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  return settingsRepository._watchSettingsObject();
});
