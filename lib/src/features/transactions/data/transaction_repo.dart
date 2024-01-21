import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../domain/balance_at_date_time.dart';
import '../domain/transaction_base.dart';
import '../presentation/controllers/regular_txn_form_controller.dart';

class TransactionRepositoryRealmDb {
  TransactionRepositoryRealmDb(this.realm);

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

  /// Put this inside realm write transaction to update [BalanceAtDateTime],
  /// which is a de-normalization value of total regular balance
  void _updateBalanceAtDateTime(DateTime dateTime, double amount) {
    List<BalanceAtDateTime> balanceAtDateTimes = getSortedBalanceAtDateTimeList();
    int index = balanceAtDateTimes.indexWhere((e) => dateTime.isSameMonthAs(e.date.toLocal()));

    if (index != -1) {
      for (int i = index; i < balanceAtDateTimes.length; i++) {
        BalanceAtDateTimeDb db = balanceAtDateTimes[i].databaseObject;
        db.amount = db.amount + amount;
      }
    } else {
      final nearestIndexFromTxnDateTime =
          balanceAtDateTimes.lastIndexWhere((e) => dateTime.isInMonthAfter(e.date.toLocal()));
      final nearestBalance =
          nearestIndexFromTxnDateTime == -1 ? 0 : balanceAtDateTimes[nearestIndexFromTxnDateTime].amount;
      realm.add(BalanceAtDateTimeDb(ObjectId(), dateTime.onlyYearMonth.toUtc(), amount + nearestBalance));

      balanceAtDateTimes = getSortedBalanceAtDateTimeList();
      index = balanceAtDateTimes.indexWhere((e) => dateTime.isSameMonthAs(e.date.toLocal()));

      for (int i = index + 1; i < balanceAtDateTimes.length; i++) {
        BalanceAtDateTimeDb db = balanceAtDateTimes[i].databaseObject;
        db.amount = db.amount + amount;
      }
    }

    // Remove BalanceAtDateTime has amount == 0 to prevent wrong calculation.
    final emptyBalAtDateTime = realm.all<BalanceAtDateTimeDb>().query(r'amount == $0', [0.0]);
    realm.deleteMany(emptyBalAtDateTime);
  }

  List<BaseTransaction> getTransactions(DateTime lower, DateTime upper) {
    List<TransactionDb> list = realm
        .all<TransactionDb>()
        .query('dateTime >= \$0 AND dateTime <= \$1 AND TRUEPREDICATE SORT(dateTime ASC)', [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  BaseTransaction getTransaction(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<TransactionDb>(objId);
    if (txnDb != null) {
      return BaseTransaction.fromDatabase(txnDb);
    }
    throw StateError('transaction id is not found');
  }

  Stream<BaseTransaction> _watchTransaction(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<TransactionDb>(objId)?.changes;
    if (txnDb != null) {
      return txnDb.map((event) => BaseTransaction.fromDatabase(event.object));
    }
    throw StateError('transaction id is not found');
  }

  /// A De-normalization list stores total balance in a month
  List<BalanceAtDateTime> getSortedBalanceAtDateTimeList() {
    List<BalanceAtDateTimeDb> list = realm.all<BalanceAtDateTimeDb>().query('TRUEPREDICATE SORT(date ASC)').toList();

    return list.map((txn) => BalanceAtDateTime.fromDatabase(txn)).toList();
  }
}

extension WriteTransaction on TransactionRepositoryRealmDb {
  /// **Do not call this function in Widgets**
  ///
  /// Only to call in [AccountRepositoryRealmDb]
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
    _updateBalanceAtDateTime(today, balance);
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
      _updateBalanceAtDateTime(dateTime, amount);
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
      _updateBalanceAtDateTime(dateTime, -amount);
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
      _updateBalanceAtDateTime(dateTime, -amount);
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

extension EditTransaction on TransactionRepositoryRealmDb {
  void editRegularTransaction(
    BaseRegularTransaction transaction, {
    required RegularTransactionFormState state,
  }) {
    final txnDb = transaction.databaseObject;

    realm.write(() {
      if (state.dateTime != null) {
        if (transaction.type == TransactionType.income) {
          _updateBalanceAtDateTime(transaction.dateTime, -transaction.amount);
          _updateBalanceAtDateTime(state.dateTime!, transaction.amount);
        }

        if (transaction.type == TransactionType.expense) {
          _updateBalanceAtDateTime(transaction.dateTime, transaction.amount);
          _updateBalanceAtDateTime(state.dateTime!, -transaction.amount);
        }

        txnDb.dateTime = state.dateTime!;
      }

      if (state.amount != null) {
        if (transaction.type == TransactionType.income) {
          _updateBalanceAtDateTime(transaction.dateTime, state.amount! - transaction.amount);
        }

        if (transaction.type == TransactionType.expense) {
          _updateBalanceAtDateTime(transaction.dateTime, -(state.amount! - transaction.amount));
        }

        txnDb.amount = state.amount!;
      }

      if (state.category != null) {
        txnDb.category = state.category!.databaseObject;
      }

      if (state.tag != null) {
        if (state.tag == CategoryTag.noTag) {
          txnDb.categoryTag = null;
        } else {
          txnDb.categoryTag = state.tag!.databaseObject;
        }
      }

      if (state.account != null) {
        txnDb.account = state.account!.databaseObject;
      }

      if (state.toAccount != null) {
        txnDb.transferAccount = state.toAccount!.databaseObject;
      }

      if (state.note != null) {
        txnDb.note = state.note;
      }
    });
  }

  void editCreditSpending(
    CreditSpending transaction, {
    required DateTime? dateTime,
    required double? amount,
    required Category? category,
    required CreditAccount? account,
    required CategoryTag? tag,
    required String? note,
    required int? monthsToPay,
    required double? paymentAmount,
  }) {
    TransactionDb? txnDb = realm.find<TransactionDb>(transaction.databaseObject.id);

    if (txnDb == null) {
      throw StateError('Can not find transaction from ObjectId');
    }

    CreditInstallmentDetailsDb? creditInstallmentDb = txnDb.creditInstallmentDetails;

    realm.write(() {
      if (dateTime != null) {
        txnDb.dateTime = dateTime;
      }
      if (amount != null) {
        txnDb.amount = amount;
      }
      if (category != null) {
        txnDb.category = category.databaseObject;
      }
      if (tag != null) {
        txnDb.categoryTag = tag.databaseObject;
      }
      if (account != null) {
        txnDb.account = account.databaseObject;
      }
      if (note != null) {
        txnDb.note = note;
      }

      //TODO: logic for installment details

      // if (monthsToPay != null) {
      //   creditInstallmentDb?.monthsToPay = monthsToPay;
      // }
      // if (paymentAmount != null) {
      //   creditInstallmentDb?.paymentAmount = paymentAmount;
      // }

      //_updateBalanceAtDateTime(TransactionType.income, dateTime, amount);
    });
  }

  void editCreditPayment(
    CreditPayment transaction, {
    required DateTime? dateTime,
    required double? amount,
    required RegularAccount? fromAccount,
    required String? note,
    required bool? isFullPayment,
    required double? adjustment,
  }) {
    TransactionDb? txnDb = realm.find<TransactionDb>(transaction.databaseObject.id);

    if (txnDb == null) {
      throw StateError('Can not find transaction from ObjectId');
    }

    realm.write(() {
      if (dateTime != null) {
        txnDb.dateTime = dateTime;
      }
      if (amount != null) {
        txnDb.amount = amount;
      }
      if (fromAccount != null) {
        txnDb.transferAccount = fromAccount.databaseObject;
      }
      if (note != null) {
        txnDb.note = note;
      }

      //TODO: logic for adjustment and full payment?

      // if (isFullPayment != null) {

      // }
      // if (adjustment != null) {

      // }

      //_updateBalanceAtDateTime(TransactionType.income, dateTime, amount);
    });
  }

  void editCreditCheckpoint(
    CreditCheckpoint transaction, {
    required DateTime? dateTime,
    required double? amount,
    required CreditAccount? account,
    required List<CreditSpending>? finishedInstallments,
  }) {
    TransactionDb? txnDb = realm.find<TransactionDb>(transaction.databaseObject.id);

    if (txnDb == null) {
      throw StateError('Can not find transaction from ObjectId');
    }

    realm.write(() {
      if (dateTime != null) {
        txnDb.dateTime = dateTime;
      }
      if (amount != null) {
        txnDb.amount = amount;
      }
      if (account != null) {
        txnDb.account = account.databaseObject;
      }

      //TODO: logic for finishedInstallments?

      // if (finishedInstallments != null) {
      //   txnDb.creditCheckpointFinishedInstallments = finishedInstallments;
      // }

      //_updateBalanceAtDateTime(TransactionType.income, dateTime, amount);
    });
  }

  void deleteTransaction(BaseTransaction transaction) {
    final double deleteAmount = switch (transaction) {
      Transfer() || CreditSpending() || CreditCheckpoint() => 0,
      Income() => -transaction.amount,
      Expense() || CreditPayment() => transaction.amount,
    };

    realm.write(() {
      _updateBalanceAtDateTime(transaction.dateTime, deleteAmount);
      realm.delete<TransactionDb>(transaction.databaseObject);
    });
  }
}

/////////////////// PROVIDERS //////////////////////////

final transactionRepositoryRealmProvider = Provider<TransactionRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return TransactionRepositoryRealmDb(realm);
  },
);

final transactionsChangesStreamProvider = StreamProvider.autoDispose<RealmResultsChanges<TransactionDb>>(
  (ref) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges(Calendar.minDate, Calendar.maxDate);
  },
);

final transactionStreamProvider = StreamProvider.autoDispose.family<BaseTransaction, String>(
  (ref, val) {
    final transactionRepo = ref.watch(transactionRepositoryRealmProvider);
    return transactionRepo._watchTransaction(val);
  },
);
