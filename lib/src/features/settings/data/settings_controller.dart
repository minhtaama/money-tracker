import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import 'package:money_tracker_app/src/features/settings/data/hive_model/settings_hive_model.dart';

class SettingsHiveModelController extends StateNotifier<SettingsHiveModel> {
  SettingsHiveModelController(this._settingsHiveModel) : super(_settingsHiveModel);

  final SettingsHiveModel _settingsHiveModel;

  void changeTheme(int index) {
    final newSettingsHiveModel = HiveDataStore.getSettingsHiveModel.copyWith(currentThemeIndex: index);
    HiveDataStore.setSettingsHiveModel(newSettingsHiveModel);
    state = HiveDataStore.getSettingsHiveModel;
  }
}

final settingsHiveModelControllerProvider =
    StateNotifierProvider<SettingsHiveModelController, SettingsHiveModel>((ref) {
  throw UnimplementedError();
});
