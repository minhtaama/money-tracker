import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';

import '../../../../persistent/isar_data_store.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_isar.dart';

class TransactionRepository {
  TransactionRepository(this.isar);

  final Isar isar;

  // No need to run async method because user might not have over 100 account (Obviously!)
  List<TransactionIsar> getAll(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query = isar.transactionIsars
        .filter()
        .dateTimeBetween(lower, upper)
        .sortByDateTime()
        .build();
    return query.findAllSync();
  }

  // Used to watch list changes
  Stream<void> _watchListChanges(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query =
        isar.transactionIsars.filter().dateTimeBetween(lower, upper).build();
    return query.watchLazy(fireImmediately: true);
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
      throw ErrorDescription(
          '`toAccount` must be null if transaction type is Transfer');
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

// class DateTimeRange {
//   const DateTimeRange({required this.upper, required this.lower});
//
//   final DateTime upper;
//   final DateTime lower;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is DateTimeRange &&
//           runtimeType == other.runtimeType &&
//           upper == other.upper &&
//           lower == other.lower;
//
//   @override
//   int get hashCode => upper.hashCode ^ lower.hashCode;
// }

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
