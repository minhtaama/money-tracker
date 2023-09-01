import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_isar.dart';
import 'package:money_tracker_app/src/features/category/data/isar_dto/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/transactions/data/isar_dto/transaction_isar.dart';
import 'package:async/async.dart';

import '../../../../persistent/isar_data_store.dart';
import '../../../utils/enums.dart';
import '../../accounts/data/isar_dto/account_isar.dart';

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
    return StreamGroup.merge([s1, s2, s3, s4]);
  }

  Future<void> writeNewIncomeTxn({
    required DateTime dateTime,
    required double amount,
    required CategoryIsar category,
    required CategoryTagIsar? tag,
    required AccountIsar account,
    required String? note,
  }) async {
    final newTransaction = TransactionIsar()
      ..transactionType = TransactionType.income
      ..dateTime = dateTime
      ..amount = amount
      ..categoryLink.value = category
      ..accountLink.value = account
      ..categoryTagLink.value = tag
      ..note = note;

    await isar.writeTxn(() async {
      // Put the `newTransaction` to the TransactionIsar collection
      await isar.transactionIsars.put(newTransaction);

      // Save the links in the `newTransaction`
      await newTransaction.categoryLink.save();
      await newTransaction.categoryTagLink.save();
      await newTransaction.accountLink.save();
    });
  }

  Future<void> writeNewExpenseTxn({
    required DateTime dateTime,
    required double amount,
    required CategoryIsar category,
    required CategoryTagIsar? tag,
    required AccountIsar account,
    required String? note,
  }) async {
    final newTransaction = TransactionIsar()
      ..transactionType = TransactionType.expense
      ..dateTime = dateTime
      ..amount = amount
      ..categoryLink.value = category
      ..accountLink.value = account
      ..categoryTagLink.value = tag
      ..note = note;

    await isar.writeTxn(() async {
      // Put the `newTransaction` to the TransactionIsar collection
      await isar.transactionIsars.put(newTransaction);

      // Save the links in the `newTransaction`
      await newTransaction.categoryLink.save();
      await newTransaction.categoryTagLink.save();
      await newTransaction.accountLink.save();
    });
  }

  Future<void> writeNewTransferTxn(
      {required DateTime dateTime,
      required double amount,
      required AccountIsar account,
      required AccountIsar toAccount,
      required String? note,
      required double? fee,
      required bool? isChargeOnDestinationAccount}) async {
    TransferFeeIsar? feeDetails;
    if (fee != null && isChargeOnDestinationAccount != null) {
      feeDetails = TransferFeeIsar()
        ..amount = fee
        ..onDestination = isChargeOnDestinationAccount;
    }
    final newTransaction = TransactionIsar()
      ..transactionType = TransactionType.transfer
      ..dateTime = dateTime
      ..amount = amount
      ..accountLink.value = account
      ..toAccountLink.value = toAccount
      ..transferFeeIsar = feeDetails
      ..note = note;

    await isar.writeTxn(() async {
      // Put the `newTransaction` to the TransactionIsar collection
      await isar.transactionIsars.put(newTransaction);

      // Save the links in the `newTransaction`
      await newTransaction.accountLink.save();
      await newTransaction.toAccountLink.save();
    });
  }

  Future<void> writeNewCreditSpendingTxn({
    required DateTime dateTime,
    required double amount,
    required CategoryIsar category,
    required AccountIsar account,
    required CategoryTagIsar? tag,
    required String? note,
    required InstallmentIsar? installmentDetails,
  }) async {
    final txn = TransactionIsar()
      ..transactionType = TransactionType.creditSpending
      ..dateTime = dateTime
      ..amount = amount
      ..accountLink.value = account
      ..categoryLink.value = category
      ..categoryTagLink.value = tag
      ..note = note
      ..installmentIsar = installmentDetails;

    await isar.writeTxn(() async {
      // Put the `txn` to the TransactionIsar collection
      await isar.transactionIsars.put(txn);

      // Save the links in the `txn`
      await txn.accountLink.save();
      await txn.categoryLink.save();
      await txn.categoryTagLink.save();
    });
  }

  // Future<void> writeNewCreditPaymentTxn({
  //   required DateTime dateTime,
  //   required double amount,
  // }) async {
  //   final txn = CreditPaymentIsar()
  //     ..dateTime = dateTime
  //     ..amount = amount
  //     ..spendingTxnLinks. = creditSpendingIsar;
  //
  //   await isar.writeTxn(() async {
  //     // Put the `txn` to the TransactionIsar collection
  //     await isar.creditPaymentIsars.put(txn);
  //
  //     // Save the links in the `txn`
  //     await txn.spendingTxnLink.save();
  //   });
  // }
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
