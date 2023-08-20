import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/credit_transaction_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';
import 'package:async/async.dart';

import '../../../../persistent/isar_data_store.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_isar.dart';

class TransactionRepository {
  TransactionRepository(this.isar);

  final Isar isar;

  List<TransactionIsar> getAll(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query =
        isar.transactionIsars.filter().dateTimeBetween(lower, upper).sortByDateTime().build();
    return query.findAllSync();
  }

  // Used to watch transaction list changes
  Stream<void> _watchListChanges(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query = isar.transactionIsars.filter().dateTimeBetween(lower, upper).build();
    return query.watchLazy(fireImmediately: true);
  }

  Stream<void> _watchDatabaseChanges() {
    Stream<void> s1 = isar.accountIsars.watchLazy(fireImmediately: true);
    Stream<void> s2 = isar.categoryIsars.watchLazy(fireImmediately: true);
    Stream<void> s3 = isar.categoryTagIsars.watchLazy(fireImmediately: true);
    Stream<void> s4 = isar.transactionIsars.watchLazy(fireImmediately: true);
    Stream<void> s5 = isar.creditTransactionIsars.watchLazy(fireImmediately: true);
    return StreamGroup.merge([s1, s2, s3, s4, s5]);
  }

  /// Only add value to __`toAccount`__ parameter if transaction type is __Transfer__
  Future<void> writeNew(
    TransactionType type, {
    required DateTime dateTime,
    required double amount,
    required CategoryIsar? category,
    required AccountIsar account,
    CategoryTagIsar? tag,
    String? note,
    AccountIsar? toAccount,
  }) async {
    // Create a new account
    if (type != TransactionType.transfer && toAccount != null) {
      throw ErrorDescription('`toAccount` must be null if transaction type is Transfer');
    }

    final newTransaction = TransactionIsar()
      ..transactionType = type
      ..dateTime = dateTime
      ..amount = amount
      ..category.value = category
      ..account.value = account
      ..tag.value = tag
      ..note = note
      ..toAccount.value = toAccount;

    await isar.writeTxn(() async {
      // Put the `newTransaction` to the TransactionIsar collection
      await isar.transactionIsars.put(newTransaction);

      // Save the links in the `newTransaction`
      await newTransaction.category.save();
      await newTransaction.tag.save();
      await newTransaction.account.save();
      await newTransaction.toAccount.save();
    });
  }
}

/////////////////// PROVIDERS //////////////////////////

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return TransactionRepository(isar);
  },
);

final transactionChangesProvider = StreamProvider.family<void, DateTimeRange>(
  (ref, range) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    return transactionRepo._watchListChanges(range.start, range.end);
  },
);

final databaseChangesProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    return transactionRepo._watchDatabaseChanges();
  },
);
