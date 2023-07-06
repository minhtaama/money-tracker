import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

class AccountRepository {
  AccountRepository(this.isar);

  final Isar isar;

  List<AccountIsar> getList() {
    Query<AccountIsar> query = isar.accountIsars.where().sortByOrder().build();
    return query.findAllSync();
  }

  Stream<void> _watchListChanges() {
    Query<AccountIsar> query = isar.accountIsars.where().sortByOrder().build();
    return query.watchLazy(fireImmediately: true);
  }

  Future<void> writeNew(
    double initialBalance, {
    required AccountType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
  }) async {
    final newAccount = AccountIsar()
      ..type = type
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex
      ..initialBalance = initialBalance;
    await isar.writeTxn(() async {
      await isar.accountIsars.put(newAccount);
      // If this database is user-reorderable, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it
      newAccount.order = newAccount.id;
      await isar.accountIsars.put(newAccount);
    });
  }

  Future<void> edit(AccountIsar currentAccount,
      {required String name,
      required String iconCategory,
      required int iconIndex,
      required int colorIndex,
      required double initialBalance}) async {
    currentAccount
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex
      ..initialBalance = initialBalance;
    await isar.writeTxn(() async => await isar.accountIsars.put(currentAccount));
  }

  Future<void> delete(AccountIsar account) async {
    await isar.writeTxn(() async => await isar.accountIsars.delete(account.id));
  }

  /// The list must be the same list displayed in the widget (with the same sort order)
  Future<void> reorder(List<AccountIsar> list, int oldIndex, int newIndex) async {
    await isar.writeTxn(
      () async {
        if (newIndex < oldIndex) {
          // Move item up the list
          int temp = list[newIndex].order!;
          for (int i = newIndex; i < oldIndex; i++) {
            list[i].order = list[i + 1].order;
            isar.accountIsars.put(list[i]);
          }
          list[oldIndex].order = temp;
          isar.accountIsars.put(list[oldIndex]);
        } else {
          // Move item down the list
          int temp = list[newIndex].order!;
          for (int i = newIndex; i > oldIndex; i--) {
            list[i].order = list[i - 1].order;
            isar.accountIsars.put(list[i]);
          }
          list[oldIndex].order = temp;
          isar.accountIsars.put(list[oldIndex]);
        }
      },
    );
  }
}

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return AccountRepository(isar);
  },
);

final accountsChangesProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final categoryRepo = ref.watch(accountRepositoryProvider);
    return categoryRepo._watchListChanges();
  },
);
