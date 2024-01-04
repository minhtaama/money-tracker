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

  Stream<RealmResultsChanges<TransactionDb>> _watchListChanges(DateTime lower, DateTime upper) {
    return realm
        .all<TransactionDb>()
        .query('dateTime >= \$0 AND dateTime <= \$1', [lower, upper]).changes;
  }

  List<BaseTransaction> getTransactions(DateTime lower, DateTime upper) {
    List<TransactionDb> list = realm.all<TransactionDb>().query(
        'dateTime >= \$0 AND dateTime <= \$1 AND TRUEPREDICATE SORT(dateTime ASC)',
        [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  double getCashflow(DateTime lower, DateTime upper) {
    final list = getTransactions(lower, upper);
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

  double getExpenseAmount(DateTime lower, DateTime upper) {
    final list = getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Expense || txn is CreditPayment) {
        result += txn.amount;
      }
    }
    return result;
  }

  double getIncomeAmount(DateTime lower, DateTime upper) {
    final list = getTransactions(lower, upper);
    double result = 0;
    for (BaseTransaction txn in list) {
      if (txn is Income) {
        result += txn.amount;
      }
    }
    return result;
  }

  /// `key` is day (x-axis), `value` is amount (y-axis)
  Map<int, double> getLineChartData(ChartDataType type, DateTime displayDate) {
    final dayBeginOfMonth = DateTime(displayDate.year, displayDate.month);
    final dayEndOfMonth = DateTime(displayDate.year, displayDate.month + 1, 0, 23, 59, 59);

    final days = displayDate.daysInMonth == 31 || displayDate.daysInMonth == 30
        ? [1, 8, 15, 23, dayEndOfMonth.day]
        : [1, 7, 14, 21, dayEndOfMonth.day];

    Map<int, double> result = {for (int day in days) day: 0};

    void updateAmount(int day, BaseTransaction txn) {
      result.updateAll((key, value) {
        if (key >= day) {
          if (type == ChartDataType.cashflow) {
            if (txn is CreditPayment || txn is Expense) {
              return value -= txn.amount;
            }
          }

          return value += txn.amount;
        }

        return value;
      });
    }

    final txns = getTransactions(dayBeginOfMonth, dayEndOfMonth)
        .where(
          (txn) => switch (type) {
            ChartDataType.cashflow => txn is Income || txn is Expense || txn is CreditPayment,
            ChartDataType.expense => txn is Expense || txn is CreditPayment,
            ChartDataType.income => txn is Income,
          },
        )
        .toList();

    if (txns.isEmpty) {
      result.addEntries([
        MapEntry(days[0], 0),
        MapEntry(days[1], 0),
        MapEntry(days[2], 0),
        MapEntry(days[3], 0),
        MapEntry(days[4], 0),
      ]);
      return result;
    }

    for (int i = 0; i <= txns.length - 1; i++) {
      final txn = txns[i];
      final tDay = txn.dateTime.day;

      if (tDay == days[0]) {
        updateAmount(days[0], txn);
      }

      for (int j = 1; j <= days.length - 1; j++) {
        if (tDay > days[j - 1] && tDay <= days[j]) {
          updateAmount(days[j], txn);
          break;
        }
      }
    }

    return result;
  }

  void writeNewIncome({
    required DateTime dateTime,
    required double amount,
    required Category category,
    required CategoryTag? tag,
    required RegularAccount account,
    required String? note,
  }) {
    final newTransaction = TransactionDb(
        ObjectId(), _transactionTypeInDb(TransactionType.income), dateTime, amount,
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
    final newTransaction = TransactionDb(
        ObjectId(), _transactionTypeInDb(TransactionType.expense), dateTime, amount,
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

    final newTransaction = TransactionDb(
        ObjectId(), _transactionTypeInDb(TransactionType.transfer), dateTime, amount,
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
        creditInstallmentDetails:
            monthsToPay != null && paymentAmount != null ? creditInstallmentDb : null);

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

final transactionChangesRealmProvider =
    StreamProvider.autoDispose.family<RealmResultsChanges<TransactionDb>, DateTimeRange>(
  (ref, range) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges(range.start, range.end);
  },
);
