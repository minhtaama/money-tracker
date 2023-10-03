import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'realm_dto.dart';

class RealmDataStore {
  late final Configuration _config;
  late final Realm _realm;

  void init() {
    _config = Configuration.local(
      [
        AccountRealm.schema,
        CreditDetailsRealm.schema,
        CategoryRealm.schema,
        CategoryTagRealm.schema,
        TransactionRealm.schema,
        TransferFeeRealm.schema,
        SettingsRealm.schema,
      ],
      initialDataCallback: _initialDataCallback,
      shouldDeleteIfMigrationNeeded: true,
    );

    // Get on-disk location of the default Realm
    // Must add android-sdk/platform-tools to PATH environment variables, then run in terminal:
    // adb root
    // adb pull /data/data/com.minhtaama.money_tracker_app/files/default.realm C:\Users\Admin\OneDrive\Desktop
    if (kDebugMode) {
      print(Configuration.defaultStoragePath);
    }

    _realm = Realm(_config);
  }

  void _initialDataCallback(Realm realm) {
    //TODO: add default settings object
    realm.add(SettingsRealm(0));
  }
}

/// Override this provider in `ProviderScope` value with an instance
/// of `RealmDataStore` to be able to call function `init()` first.
final realmDataStoreProvider = Provider<RealmDataStore>((ref) {
  throw UnimplementedError();
});

/// Use this provider to get `realm` instance in widgets
final realmProvider = Provider<Realm>((ref) {
  final realmDataStore = ref.watch(realmDataStoreProvider);
  return realmDataStore._realm;
});