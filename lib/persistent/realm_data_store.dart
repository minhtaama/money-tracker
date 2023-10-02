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
    );
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
