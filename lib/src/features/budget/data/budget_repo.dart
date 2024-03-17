import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/persistent/realm_dto.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:realm/realm.dart';

import '../domain/budget.dart';

class BudgetsRepositoryRealmDb {
  BudgetsRepositoryRealmDb(this.realm);

  final Realm realm;

  RealmResults<BudgetDb> _realmResults() {
    return realm.all<BudgetDb>().query('SORT(order ASC)');
  }

  List<BaseBudget> getList() {
    return _realmResults().map((budgetDb) => BaseBudget.fromDatabase(budgetDb)).toList();
  }

  Stream<RealmResultsChanges<BudgetDb>> _watchListChanges() {
    return realm.all<BudgetDb>().changes;
  }

  void writeNew({
    required BudgetType type,
    required BudgetPeriodType periodType,
    required String name,
    required double amount,
    required List<BaseAccount> accounts,
    required List<Category> categories,
  }) {
    final order = getList().length;

    final newBudgetDb = BudgetDb(
      ObjectId(),
      type.databaseValue,
      periodType.databaseValue,
      name,
      amount,
      accounts: accounts.map((e) => e.databaseObject).toList(),
      categories: categories.map((e) => e.databaseObject).toList(),
      order: order,
    );

    realm.write(() {
      realm.add(newBudgetDb);
    });
  }

  void edit(
    BaseBudget currentBudget, {
    required BudgetType? type,
    required BudgetPeriodType? periodType,
    required String? name,
    required double? amount,
    required List<BaseAccount>? accounts,
    required List<Category>? categories,
  }) {
    final budgetDb = currentBudget.databaseObject;

    realm.write(() {
      budgetDb
        ..type = type?.databaseValue ?? budgetDb.type
        ..periodType = periodType?.databaseValue ?? budgetDb.periodType
        ..name = name ?? budgetDb.name
        ..amount = amount ?? budgetDb.amount
        ..accounts = RealmList(accounts?.map((e) => e.databaseObject).toList() ?? budgetDb.accounts)
        ..categories =
            RealmList(categories?.map((e) => e.databaseObject).toList() ?? budgetDb.categories);
    });
  }

  void delete(BaseBudget budget) {
    realm.write(() async => realm.delete(budget.databaseObject));
  }

  void reorder(int oldIndex, int newIndex) {
    final list = _realmResults().toList();

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    realm.write(
      () {
        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
      },
    );
  }
}

//////////////////////////// PROVIDERS ////////////////////////

final budgetsRepositoryRealmProvider = Provider<BudgetsRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return BudgetsRepositoryRealmDb(realm);
  },
);

final budgetsChangesRealmProvider = StreamProvider.autoDispose<RealmResultsChanges<BudgetDb>>(
  (ref) {
    final budgetRepo = ref.watch(budgetsRepositoryRealmProvider);
    return budgetRepo._watchListChanges();
  },
);
