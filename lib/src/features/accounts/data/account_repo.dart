import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:realm/realm.dart';

import '../../../../persistent/realm_dto.dart';
import '../domain/account_base.dart';

class AccountRepositoryRealmDb {
  AccountRepositoryRealmDb(this.realm);

  final Realm realm;

  int _accountTypeInDb(AccountType type) => switch (type) {
        AccountType.regular => 0,
        AccountType.credit => 1,
      };

  RealmResults<AccountDb> _realmResults(AccountType? type) {
    if (type == null) {
      return realm.all<AccountDb>().query('TRUEPREDICATE SORT(order ASC)');
    }

    return realm.all<AccountDb>().query('type == \$0 SORT(order ASC)', [_accountTypeInDb(type)]);
  }

  List<Account> getList(AccountType? type) {
    return _realmResults(type).map((accountDb) => Account.fromDatabase(accountDb)!).toList();
  }

  // Account? getAccount(ObjectId objectId) {
  //   AccountDb? accountDb = realm.find<AccountDb>(objectId);
  //   return Account.fromDatabase(accountDb);
  // }

  // List<BaseTransaction> getTransactionList(Account account) {
  //   final RealmResults<TransactionDb> transactionListQuery =
  //       account.databaseObject.transactions.query('TRUEPREDICATE SORT(dateTime ASC)');
  //   return switch (account) {
  //     RegularAccount() => transactionListQuery
  //         .map<BaseRegularTransaction>((txn) => BaseTransaction.fromDatabase(txn) as BaseRegularTransaction)
  //         .toList(growable: false),
  //     CreditAccount() => transactionListQuery
  //         .map<BaseCreditTransaction>((txn) => BaseTransaction.fromDatabase(txn) as BaseCreditTransaction)
  //         .toList(),
  //   };
  // }

  Stream<RealmResultsChanges<AccountDb>> _watchListChanges() {
    return realm.all<AccountDb>().changes;
  }

  double getTotalBalance({bool includeCreditAccount = false}) {
    double totalBalance = 0;
    final List<Account> accountList;
    if (includeCreditAccount) {
      accountList = getList(null);
    } else {
      accountList = getList(AccountType.regular);
    }
    for (Account account in accountList) {
      totalBalance += account.availableAmount;
    }
    return totalBalance;
  }

  void writeNew(
    double balance, {
    required AccountType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
    required int? statementDay,
    required int? paymentDueDay,
    required double? apr,
    required DateTime? checkpointDateTime,
    required double? checkpointBalance,
    required bool? checkpointWithInterest,
  }) async {
    TransactionDb? initialTransaction;
    CreditDetailsDb? creditDetailsDb;
    CheckpointDb? checkpointDb;

    if (checkpointDateTime != null && checkpointBalance != null && checkpointWithInterest != null) {
      checkpointDb = CheckpointDb(checkpointDateTime, checkpointBalance, checkpointWithInterest);
    }

    if (type == AccountType.credit) {
      creditDetailsDb = CreditDetailsDb(balance, statementDay!, paymentDueDay!, apr: apr!);
      if (checkpointDb != null) {
        creditDetailsDb.checkpoints.add(checkpointDb);
      }
    }

    final order = getList(null).length;

    final newAccount = AccountDb(ObjectId(), _accountTypeInDb(type), name, colorIndex, iconCategory, iconIndex,
        order: order, creditDetails: creditDetailsDb);

    if (type == AccountType.regular) {
      initialTransaction = TransactionDb(ObjectId(), 1, DateTime.now(), balance,
          account: newAccount, isInitialTransaction: true); // transaction type 1 == TransactionType.income
    }

    realm.write(() {
      realm.add(newAccount);

      if (type == AccountType.regular) {
        realm.add(initialTransaction!);
      }
    });
  }

  void edit(Account currentAccount,
      {required String name,
      required String iconCategory,
      required int iconIndex,
      required int colorIndex,
      required double initialBalance}) async {
    // Update current account value
    final accountDb = currentAccount.databaseObject;

    // Query to find the initial transaction of the current editing account
    TransactionDb? initialTransaction = accountDb.transactions.query('isInitialTransaction == \$0', [true]).firstOrNull;

    if (initialTransaction != null) {
      realm.write(() {
        accountDb
          ..iconCategory = iconCategory
          ..iconIndex = iconIndex
          ..name = name
          ..colorIndex = colorIndex;

        // If the initial transaction is found
        initialTransaction!.amount = initialBalance;
      });
    } else {
      // In case user delete the initial transaction of the current editing account
      initialTransaction = TransactionDb(ObjectId(), 1, DateTime.now(), initialBalance,
          account: currentAccount.databaseObject, isInitialTransaction: true);

      realm.write(() {
        accountDb
          ..iconCategory = iconCategory
          ..iconIndex = iconIndex
          ..name = name
          ..colorIndex = colorIndex;

        realm.add(initialTransaction!);
      });
    }
  }

  void delete(Account account) {
    realm.write(() => realm.delete(account.databaseObject));
  }

  /// The list must be the same list displayed in the widget (with the same sort order)
  void reorder(AccountType? type, int oldIndex, int newIndex) {
    final list = _realmResults(type).toList();

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

/////////////////////////// PROVIDERS ///////////////////////////

final accountRepositoryProvider = Provider<AccountRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return AccountRepositoryRealmDb(realm);
  },
);

final accountsChangesProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    return accountRepo._watchListChanges();
  },
);
