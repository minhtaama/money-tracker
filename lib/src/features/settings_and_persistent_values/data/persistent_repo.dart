import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/features/settings_and_persistent_values/application/app_persistent.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';

class PersistentController extends Notifier<AppPersistentValues> {
  @override
  AppPersistentValues build() {
    final realm = ref.read(realmProvider);
    return AppPersistentValues.fromDatabase(realm.find<PersistentValuesDb>(0)!);
  }

  Future<void> set({
    ChartDataType? chartDataTypeInHomescreen,
    bool? showAmount,
  }) async {
    final realm = ref.read(realmProvider);

    state = state.copyWith(
      chartDataTypeInHomescreen: chartDataTypeInHomescreen,
      showAmount: showAmount,
    );

    realm.write(() => realm.add<PersistentValuesDb>(state.toDatabase(), update: true));
  }
}

/// This provider should be call only at the root widget to provide data for `AppPersistent`
/// or to use `set()` function or to get `AppPersistentValues` in other repos.
///
/// Use **`context.appPersistentValues`** rather than this provider in child widgets to get
/// current settings state.
final persistentControllerProvider = NotifierProvider<PersistentController, AppPersistentValues>(() {
  return PersistentController();
});