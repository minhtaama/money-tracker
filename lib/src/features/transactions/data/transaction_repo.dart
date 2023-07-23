import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';

import '../../../../persistent/isar_data_store.dart';

class TransactionRepository {
  TransactionRepository(this.isar);

  final Isar isar;

  // No need to run async method because user might not have over 100 account (Obviously!)
  List<TransactionIsar> getAll(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query = isar.transactionIsars.filter().dateTimeBetween(lower, upper).build();
    return query.findAllSync();
  }

  // List<TransactionIsar> getTransactionsInDay(DateTime lower, DateTime upper) {
  //   Query<TransactionIsar> query = isar.transactionIsars.filter().date.build();
  //   return query.findAllSync();
  // }

  // Used to watch list changes
  Stream<void> _watchListChanges(DateTime lower, DateTime upper) {
    Query<TransactionIsar> query = isar.transactionIsars.filter().dateTimeBetween(lower, upper).build();
    return query.watchLazy(fireImmediately: true);
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) {
    final isar = ref.watch(isarProvider);
    return TransactionRepository(isar);
  },
);

final transactionChangesProvider = StreamProvider.autoDispose.family<void, List<DateTime>>(
  (ref, list) {
    final transactionRepo = ref.watch(transactionRepositoryProvider);
    return transactionRepo._watchListChanges(list[0], list[1]);
  },
);
