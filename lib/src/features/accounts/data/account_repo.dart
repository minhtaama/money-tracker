import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_data_store.dart';
import 'package:money_tracker_app/src/features/accounts/data/isar_dto/account_isar.dart';
import 'package:money_tracker_app/src/features/transactions/data/isar_dto/transaction_isar.dart';
import 'package:money_tracker_app/src/utils/enums.dart';

import '../domain/account_base.dart';

class AccountRepository {
  AccountRepository(this.isar);

  final Isar isar;

  // No need to run async method because user might not have over 100 account (Obviously!)
  List<Account> getList(AccountType? type) {
    List<AccountIsar> isarList;
    if (type == null) {
      isarList = isar.accountIsars.where().sortByOrder().build().findAllSync();
    } else {
      isarList = isar.accountIsars.filter().typeEqualTo(type).sortByOrder().build().findAllSync();
    }
    return isarList.map((accountIsar) => Account.fromIsar(accountIsar)!).toList();
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
      totalBalance += account.currentBalance;
    }
    return totalBalance;
  }

  // Used to watch list changes
  Stream<void> _watchListChanges() {
    Query<AccountIsar> query = isar.accountIsars.where().sortByOrder().build();
    return query.watchLazy(fireImmediately: true);
  }

  Future<void> writeNew(
    double balance, {
    required AccountType type,
    required String iconCategory,
    required int iconIndex,
    required String name,
    required int colorIndex,
    required int? statementDay,
    required int? paymentDueDay,
    required double? interestRate,
  }) async {
    TransactionIsar? initialTransaction;
    CreditDetailsIsar? creditAccountDetailsIsar;

    if (type == AccountType.credit) {
      creditAccountDetailsIsar = CreditDetailsIsar()
        ..penaltyInterest = interestRate!
        ..statementDay = statementDay!
        ..paymentDueDay = paymentDueDay!
        ..creditBalance = balance;
    }

    final newAccount = AccountIsar()
      ..type = type
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex
      ..creditDetailsIsar = creditAccountDetailsIsar;

    if (type == AccountType.regular) {
      initialTransaction = TransactionIsar()
        ..transactionType = TransactionType.income
        ..dateTime = DateTime.now()
        ..isInitialTransaction = true
        ..amount = balance
        ..accountLink.value = newAccount;
    }

    await isar.writeTxn(() async {
      await isar.accountIsars.put(newAccount);
      // If this database is user-reorderable, then we must
      // assign `order` value equal to its `Isar.autoIncrementID` at the first time
      // then update it again
      newAccount.order = newAccount.id;
      await isar.accountIsars.put(newAccount);

      if (type == AccountType.regular) {
        await isar.transactionIsars.put(initialTransaction!);
        await initialTransaction.accountLink.save();
      }
    });
  }

  Future<void> edit(Account currentAccount,
      {required String name,
      required String iconCategory,
      required int iconIndex,
      required int colorIndex,
      required double initialBalance}) async {
    // Update current account value
    final accountIsar = currentAccount.isarObject;

    accountIsar
      ..iconCategory = iconCategory
      ..iconIndex = iconIndex
      ..name = name
      ..colorIndex = colorIndex;

    // Query to find the initial transaction of the current editing account
    TransactionIsar? initialTransaction =
        await accountIsar.txnOfThisAccountBacklinks.filter().isInitialTransactionEqualTo(true).findFirst();

    if (initialTransaction != null) {
      // If the initial transaction is found
      initialTransaction.amount = initialBalance;

      await isar.writeTxn(() async {
        await isar.accountIsars.put(accountIsar);
        await isar.transactionIsars.put(initialTransaction!);
      });
    } else {
      // In case user delete the initial transaction of the current editing account
      initialTransaction = TransactionIsar()
        ..transactionType = TransactionType.income
        ..dateTime = DateTime.now()
        ..isInitialTransaction = true
        ..amount = initialBalance
        ..note = 'Initial Balance'
        ..accountLink.value = accountIsar;

      await isar.writeTxn(() async {
        await isar.accountIsars.put(accountIsar);
        await isar.transactionIsars.put(initialTransaction!);

        // Save the link to this account in `initialTransaction`
        await initialTransaction.accountLink.save();
      });
    }
  }

  Future<void> delete(Account account) async {
    await isar.writeTxn(() async => await isar.accountIsars.delete(account.id));
  }

  /// The list must be the same list displayed in the widget (with the same sort order)
  Future<void> reorder(AccountType? type, int oldIndex, int newIndex) async {
    List<AccountIsar> list;
    if (type == null) {
      list = isar.accountIsars.where().sortByOrder().build().findAllSync();
    } else {
      list = isar.accountIsars.filter().typeEqualTo(type).sortByOrder().build().findAllSync();
    }
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

/////////////////////////// PROVIDERS ///////////////////////////

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return AccountRepository(isar);
  },
);

final accountsChangesProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final accountRepo = ref.watch(accountRepositoryProvider);
    return accountRepo._watchListChanges();
  },
);
