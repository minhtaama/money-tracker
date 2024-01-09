import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../domain/balance_at_date_time.dart';
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

  Stream<RealmResultsChanges<TransactionDb>> _watchListChanges(DateTime lower, DateTime upper) {
    return realm.all<TransactionDb>().query('dateTime >= \$0 AND dateTime <= \$1', [lower, upper]).changes;
  }

  /// Put this inside realm write transaction to update [PersistentValues.balanceAtDateTimes]
  /// as a de-normalization value of total regular balance
  void _updateBalanceAtDateTime(TransactionType type, DateTime dateTime, double amount) {
    amount = switch (type) {
      TransactionType.expense || TransactionType.creditPayment => 0 - amount,
      TransactionType.income => amount,
      _ => 0,
    };

    List<BalanceAtDateTime> balanceAtDateTimes = getBalanceAtDateTimes();
    int index = balanceAtDateTimes.indexWhere((e) => dateTime.isSameMonthAs(e.date.toLocal()));

    if (index != -1) {
      for (int i = index; i < balanceAtDateTimes.length; i++) {
        BalanceAtDateTimeDb db = balanceAtDateTimes[i].databaseObject;
        db.amount = db.amount + amount;
      }
    } else {
      realm.add(BalanceAtDateTimeDb(ObjectId(), dateTime.onlyYearMonth.toUtc(), amount));

      balanceAtDateTimes = getBalanceAtDateTimes();
      index = balanceAtDateTimes.indexWhere((e) => dateTime.isSameMonthAs(e.date.toLocal()));

      for (int i = index + 1; i < balanceAtDateTimes.length; i++) {
        BalanceAtDateTimeDb db = balanceAtDateTimes[i].databaseObject;
        db.amount = db.amount + amount;
      }
    }
  }

  List<BaseTransaction> getTransactions(DateTime lower, DateTime upper) {
    List<TransactionDb> list = realm
        .all<TransactionDb>()
        .query('dateTime >= \$0 AND dateTime <= \$1 AND TRUEPREDICATE SORT(dateTime ASC)', [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  List<BalanceAtDateTime> getBalanceAtDateTimes() {
    List<BalanceAtDateTimeDb> list = realm.all<BalanceAtDateTimeDb>().query('TRUEPREDICATE SORT(date ASC)').toList();

    return list.map((txn) => BalanceAtDateTime.fromDatabase(txn)).toList();
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
      _updateBalanceAtDateTime(TransactionType.income, dateTime, amount);
    });
  }

  /// **Do not call this function in Widgets**
  void writeInitialBalance({
    required double balance,
    required AccountDb newAccount,
  }) {
    final today = DateTime.now();

    final initialTransaction = TransactionDb(
      ObjectId(),
      _transactionTypeInDb(TransactionType.income),
      today,
      balance,
      account: newAccount,
      isInitialTransaction: true,
    ); // transaction type 1 == TransactionType.income

    realm.add(initialTransaction);
    _updateBalanceAtDateTime(TransactionType.income, today, balance);
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
      _updateBalanceAtDateTime(TransactionType.expense, dateTime, amount);
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
      _updateBalanceAtDateTime(TransactionType.creditPayment, dateTime, amount);
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

final transactionChangesRealmProvider =
    StreamProvider.autoDispose.family<RealmResultsChanges<TransactionDb>, DateTimeRange>(
  (ref, range) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges(range.start, range.end);
  },
);
