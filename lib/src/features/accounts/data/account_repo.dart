import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:realm/realm.dart';

import '../../../../persistent/realm_dto.dart';
import '../domain/account_base.dart';
import '../domain/statement/base_class/statement.dart';

class AccountRepositoryRealmDb {
  AccountRepositoryRealmDb(this.realm, this.ref);

  final Realm realm;
  final ProviderRef ref;

  RealmResults<AccountDb> _realmResults(AccountType? type) {
    if (type == null) {
      return realm.all<AccountDb>().query('TRUEPREDICATE SORT(order ASC)');
    }

    return realm.all<AccountDb>().query('type == \$0 SORT(order ASC)', [type.databaseValue]);
  }

  Stream<RealmResultsChanges<AccountDb>> _watchListChanges() {
    return realm.all<AccountDb>().changes;
  }

  Stream<Account> _watchAccount(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<AccountDb>(objId)?.changes;
    if (txnDb != null) {
      return txnDb.map((event) => Account.fromDatabase(event.object)!);
    }
    throw StateError('transaction id is not found');
  }

  List<Account> getList(AccountType? type) {
    return _realmResults(type).map((accountDb) => Account.fromDatabase(accountDb)!).toList();
  }

  List<AccountInfo> getListInfo(AccountType? type) {
    return _realmResults(type).map((accountDb) => Account.fromDatabaseInfoOnly(accountDb)!).toList();
  }

  Account? getAccount(AccountDb accountDb) {
    return Account.fromDatabase(accountDb);
  }

  Account getAccountFromHex(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<AccountDb>(objId);
    if (txnDb != null) {
      return Account.fromDatabase(txnDb)!;
    }
    throw StateError('Account id is not found');
  }

  /// Must be in [realm.write()]
  void _adjustPaymentToFitAPRChanges({
    required CreditAccount oldCreditAccount,
    required AccountDb newAccountDb,
  }) {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);

    final oldBalanceList = oldCreditAccount.closedStatementsList.map((e) => e.balance).toList();

    final newCreditAccount = Account.fromDatabase(newAccountDb)! as CreditAccount;

    for (int i = 0; i < newCreditAccount.closedStatementsList.length; i++) {
      final newStm = newCreditAccount.closedStatementsList[i];

      final adjustment = newStm.balance - oldBalanceList[i];

      if (adjustment != 0) {
        try {
          // CreditPaymentDetails is not null if type is CreditPayment
          final firstPaymentDetailsDb = newStm.firstPayment.databaseObject.creditPaymentDetails!;

          firstPaymentDetailsDb.adjustment += adjustment;
        } catch (_) {
          // Create a new adjustPayment at end date of statement
          txnRepo.addNewAdjustToAPRChanges(
            dateTime: newStm.date.start,
            account: newAccountDb,
            adjustment: adjustment,
          );
        }
      }
    }

    txnRepo.removeEmptyAdjustToAPRChanges();
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
    required StatementType? statementType,
  }) async {
    CreditDetailsDb? creditDetailsDb;

    final order = getList(null).length;

    if (type == AccountType.credit) {
      final statementTypeDb = switch (statementType!) {
        StatementType.withAverageDailyBalance => 0,
        StatementType.payOnlyInGracePeriod => 1,
      };

      creditDetailsDb =
          CreditDetailsDb(balance, statementDay!, paymentDueDay!, statementTypeDb, apr: apr!);
    }

    final newAccount = AccountDb(
        ObjectId(), type.databaseValue, name, colorIndex, iconCategory, iconIndex,
        order: order, creditDetails: creditDetailsDb);

    realm.write(() {
      realm.add(newAccount);

      if (type == AccountType.regular) {
        ref
            .read(transactionRepositoryRealmProvider)
            .addInitialBalance(balance: balance, newAccount: newAccount);
      }
    });
  }

  void editRegularAccount(
    RegularAccount currentAccount, {
    required String name,
    required String iconCategory,
    required int iconIndex,
    required int colorIndex,
  }) async {
    // Update current account value
    final accountDb = currentAccount.databaseObject;

    realm.write(() {
      accountDb
        ..iconCategory = iconCategory
        ..iconIndex = iconIndex
        ..name = name
        ..colorIndex = colorIndex;
    });
  }

  void editCreditAccount(
    CreditAccount currentAccount, {
    required String name,
    required String iconCategory,
    required int iconIndex,
    required int colorIndex,
    required double? apr,
    required StatementType statementType,
    required double? creditLimit,
  }) async {
    // Update current account value
    final accountDb = currentAccount.databaseObject;

    realm.write(() {
      accountDb
        ..iconCategory = iconCategory
        ..iconIndex = iconIndex
        ..name = name
        ..colorIndex = colorIndex
        ..creditDetails!.statementType = statementType.databaseValue;

      if (creditLimit != null) {
        accountDb.creditDetails!.creditBalance = creditLimit;
      }

      if (apr != null) {
        accountDb.creditDetails!.apr = apr;
        _adjustPaymentToFitAPRChanges(oldCreditAccount: currentAccount, newAccountDb: accountDb);
      }
    });
  }

  void delete(Account account) {
    realm.write(() {
      if (account is CreditAccount) {
        final txnsDbToDelete = account.transactionsList
            .where((txn) => txn is! CreditPayment)
            .map((txn) => txn.databaseObject);
        realm.deleteMany<TransactionDb>(txnsDbToDelete);
      }
      realm.delete<AccountDb>(account.databaseObject);
    });
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
    return AccountRepositoryRealmDb(realm, ref);
  },
);

final accountsChangesProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    return accountRepo._watchListChanges();
  },
);

final accountStreamProvider = StreamProvider.autoDispose.family<Account, String>(
  (ref, val) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    return accountRepo._watchAccount(val);
  },
);
