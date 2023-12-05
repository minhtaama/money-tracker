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
        AccountDb.schema,
        CreditDetailsDb.schema,
        CategoryDb.schema,
        CategoryTagDb.schema,
        TransactionDb.schema,
        TransferFeeDb.schema,
        CreditInstallmentDetailsDb.schema,
        CreditPaymentDetailsDb.schema,
        SettingsDb.schema,
      ],
      initialDataCallback: _initialDataCallback,
      shouldDeleteIfMigrationNeeded: true,
    );

    // Get on-disk location of the default Realm
    // Must add android-sdk/platform-tools to PATH environment variables, then run in terminal:
    // $ adb root
    // $ adb pull /data/data/com.minhtaama.money_tracker_app/files/default.realm C:\Users\Admin\OneDrive\Desktop
    if (kDebugMode) {
      print(Configuration.defaultStoragePath);
    }

    _realm = Realm(_config);
  }

  void _initialDataCallback(Realm realm) {
    //add default settings object
    realm.add(SettingsDb(0));

    // objects
    // realm.add(AccountDb(ObjectId(), 0, 'Cash', 6, 'Business', 11, order: 0));
    // realm.add(AccountDb(ObjectId(), 1, 'VPBank Credit', 9, 'Business', 10,
    //     order: 1, creditDetails: CreditDetailsDb(2000, 25, 6, apr: 20)));
    // realm.add(AccountDb(ObjectId(), 1, 'Vietcombank Credit', 14, 'Business', 2,
    //     order: 2, creditDetails: CreditDetailsDb(3000, 1, 15, apr: 20)));
    realm.add(CategoryDb(ObjectId(), 0, 'Food and Beverage', 8, 'Food', 4, order: 0));
    realm.add(CategoryDb(ObjectId(), 1, 'Salary', 8, 'Business', 13, order: 1));
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
