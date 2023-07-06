import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/settings/domain/settings_isar.dart';
import 'package:path_provider/path_provider.dart';
import '../src/features/category/domain/category_isar.dart';

class IsarDataStore {
  late final Directory _dir;
  late final Isar _isar;

  Future<void> init() async {
    _dir = await getApplicationDocumentsDirectory();

    // Init Isar instance
    _isar = await Isar.open(
      [CategoryIsarSchema, SettingsIsarSchema, AccountIsarSchema],
      directory: _dir.path,
    );

    // Init settingsObject
    if (await _isar.settingsIsars.get(0) == null) {
      _isar.writeTxn(() async => await _isar.settingsIsars.put(SettingsIsar()));
    }
  }
}

/// Override this provider in `ProviderScope` value with an instance
/// of `IsarDataStore` after calling asynchronous function `init()`.
final isarDataStoreProvider = Provider<IsarDataStore>((ref) {
  throw UnimplementedError();
});

/// Use this provider to get `isar` instance in widgets
final isarProvider = Provider<Isar>((ref) {
  final isarDataStore = ref.watch(isarDataStoreProvider);
  return isarDataStore._isar;
});
