import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../domain/transaction_base.dart';

class TransactionRepository {
  TransactionRepository(this.realm);

  final Realm realm;

  int _transactionTypeInDb(TransactionType type) => switch (type) {
        TransactionType.expense => 0,
        TransactionType.income => 1,
        TransactionType.transfer => 2,
        TransactionType.creditSpending => 3,
        TransactionType.creditPayment => 4,
      };

  List<BaseTransaction> getAll(DateTime lower, DateTime upper) {
    List<TransactionDb> list =
        realm.all<TransactionDb>().query('dateTime >= \$0 AND dateTime <= \$1', [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  Stream<RealmResultsChanges<TransactionDb>> _watchListChanges(DateTime lower, DateTime upper) {
    return realm.all<TransactionDb>().query('dateTime >= \$0 AND dateTime <= \$1', [lower, upper]).changes;
  }

  Stream<void> _watchDatabaseChanges() {
    Stream<void> s1 = realm.all<CategoryDb>().changes;
    Stream<void> s2 = realm.all<CategoryTagDb>().changes;
    Stream<void> s3 = realm.all<AccountDb>().changes;
    Stream<void> s4 = realm.all<TransactionDb>().changes;
    return StreamGroup.merge([s1, s2, s3, s4]);
  }

  void writeNewIncome({
    required DateTime dateTime,
    required double amount,
    required Category category,
    required CategoryTag? tag,
    required RegularAccount account,
    required String? note,
  }) {
    final newTransaction = TransactionDb(ObjectId(), _transactionTypeInDb(TransactionType.income), dateTime, amount,
        note: note,
        category: category.databaseObject,
        categoryTag: tag?.databaseObject,
        account: account.databaseObject);

    realm.write(() {
      realm.add(newTransaction);
    });
  }

  void writeNewExpense({
    required DateTime dateTime,
    required double amount,
    required Category category,
    required CategoryTag? tag,
    required RegularAccount account,
    required String? note,
  }) {
    final newTransaction = TransactionDb(ObjectId(), _transactionTypeInDb(TransactionType.expense), dateTime, amount,
        note: note,
        category: category.databaseObject,
        categoryTag: tag?.databaseObject,
        account: account.databaseObject);

    realm.write(() {
      realm.add(newTransaction);
    });
  }

  void writeNewTransfer({
    required DateTime dateTime,
    required double amount,
    required RegularAccount account,
    required RegularAccount toAccount,
    required String? note,
    required double? fee,
    required bool? isChargeOnDestinationAccount,
  }) {
    TransferFeeDb? transferFee;
    if (fee != null && isChargeOnDestinationAccount != null) {
      transferFee = TransferFeeDb(amount: fee, chargeOnDestination: isChargeOnDestinationAccount);
    }

    final newTransaction = TransactionDb(ObjectId(), _transactionTypeInDb(TransactionType.transfer), dateTime, amount,
        note: note,
        account: account.databaseObject,
        transferAccount: toAccount.databaseObject,
        transferFee: transferFee);

    realm.write(() {
      realm.add(newTransaction);
    });
  }

  void writeNewCreditSpending({
    required DateTime dateTime,
    required double amount,
    required Category category,
    required CreditAccount account,
    required CategoryTag? tag,
    required String? note,
    required int? monthsToPay,
    required double? paymentAmount,
  }) {
    final creditPaymentDb = CreditPaymentDetails(monthsToPay: monthsToPay, paymentAmount: paymentAmount);

    final newTransaction = TransactionDb(
        ObjectId(), _transactionTypeInDb(TransactionType.creditSpending), dateTime, amount,
        note: note,
        category: category.databaseObject,
        categoryTag: tag?.databaseObject,
        account: account.databaseObject,
        creditPaymentDetails: monthsToPay != null && paymentAmount != null ? creditPaymentDb : null);

    realm.write(() {
      realm.add(newTransaction);
    });
  }

  void writeNewCreditPayment({
    required DateTime dateTime,
    required double amount,
    required CreditAccount account,
    required RegularAccount fromAccount,
    required String? note,
  }) {
    final newTransaction = TransactionDb(
      ObjectId(),
      _transactionTypeInDb(TransactionType.creditPayment),
      dateTime,
      amount,
      note: note,
      account: account.databaseObject,
      transferAccount: fromAccount.databaseObject,
    );

    realm.write(() {
      realm.add(newTransaction);
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

final transactionRepositoryRealmProvider = Provider<TransactionRepository>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return TransactionRepository(realm);
  },
);

final transactionChangesRealmProvider = StreamProvider.family<void, DateTimeRange>(
  (ref, range) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges(range.start, range.end);
  },
);

final databaseChangesRealmProvider = StreamProvider.autoDispose<void>(
  (ref) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchDatabaseChanges();
  },
);
