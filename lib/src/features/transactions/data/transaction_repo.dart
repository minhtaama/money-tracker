import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:async/async.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
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
        TransactionType.creditCheckpoint => 5,
      };

  // int _creditPaymentTypeInDb(CreditPaymentType type) => switch (type) {
  //       CreditPaymentType.underMinimum => 0,
  //       CreditPaymentType.minimumOrHigher => 1,
  //       CreditPaymentType.full => 2,
  //     };

  List<BaseTransaction> getAll(DateTime lower, DateTime upper) {
    List<TransactionDb> list =
        realm.all<TransactionDb>().query('dateTime >= \$0 AND dateTime <= \$1', [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  double getNetCashflow(DateTime lower, DateTime upper) {
    final list = getAll(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Income) {
        result += txn.amount;
      }
      if (txn is Expense || txn is CreditPayment) {
        result -= txn.amount;
      }
    }
    return result;
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
    final creditInstallmentDb = CreditInstallmentDetailsDb(
      monthsToPay: monthsToPay,
      paymentAmount: paymentAmount,
    );

    final newTransaction = TransactionDb(
        ObjectId(), _transactionTypeInDb(TransactionType.creditSpending), dateTime, amount,
        note: note,
        category: category.databaseObject,
        categoryTag: tag?.databaseObject,
        account: account.databaseObject,
        creditInstallmentDetails: monthsToPay != null && paymentAmount != null ? creditInstallmentDb : null);

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
    required bool isFullPayment,
    required double? adjustment,
  }) {
    final creditPaymentDetails = CreditPaymentDetailsDb(
      isFullPayment: isFullPayment,
      adjustedBalance: adjustment,
    );

    final newTransaction = TransactionDb(
      ObjectId(),
      _transactionTypeInDb(TransactionType.creditPayment),
      dateTime,
      amount,
      note: note,
      account: account.databaseObject,
      transferAccount: fromAccount.databaseObject,
      creditPaymentDetails: creditPaymentDetails,
    );

    realm.write(() {
      realm.add(newTransaction);
    });
  }

  void writeNewCreditCheckpoint({
    required DateTime dateTime,
    required double amount,
    required CreditAccount account,
    required List<CreditSpending> finishedInstallments,
  }) {
    final newTransaction = TransactionDb(
      ObjectId(),
      _transactionTypeInDb(TransactionType.creditCheckpoint),
      dateTime.onlyYearMonthDay,
      amount,
      account: account.databaseObject,
      creditCheckpointFinishedInstallments: finishedInstallments.map((txn) => txn.databaseObject),
    );

    realm.write(() {
      realm.add(newTransaction);
    });
  }
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
