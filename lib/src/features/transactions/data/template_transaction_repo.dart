import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/credit_spending_form_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../domain/transaction_base.dart';
import '../presentation/controllers/credit_payment_form_controller.dart';
import '../presentation/controllers/regular_txn_form_controller.dart';

class TemplateTransactionRepositoryRealmDb {
  TemplateTransactionRepositoryRealmDb(this.realm);

  final Realm realm;

  Stream<RealmResultsChanges<TemplateTransactionDb>> _watchListChanges() {
    return realm.all<TemplateTransactionDb>().changes;
  }

  List<BaseTransaction> getTransactions(DateTime lower, DateTime upper) {
    List<TransactionDb> list = realm
        .all<TransactionDb>()
        .query('dateTime >= \$0 AND dateTime <= \$1 AND TRUEPREDICATE SORT(dateTime ASC)', [lower, upper]).toList();
    return list.map((txn) => BaseTransaction.fromDatabase(txn)).toList();
  }

  BaseTransaction getTransactionFromHex(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<TransactionDb>(objId);
    if (txnDb != null) {
      return BaseTransaction.fromDatabase(txnDb);
    }
    throw StateError('transaction id is not found');
  }

  // Stream<BaseTransaction> _watchTransaction(String objectIdHexString) {
  //   ObjectId objId = ObjectId.fromHexString(objectIdHexString);
  //   final txnDb = realm.find<TransactionDb>(objId)?.changes;
  //   if (txnDb != null) {
  //     return txnDb.map((event) => BaseTransaction.fromDatabase(event.object));
  //   }
  //   throw StateError('transaction id is not found');
  // }
}

extension WriteTempTransaction on TemplateTransactionRepositoryRealmDb {
  void writeNewIncome({
    required DateTime dateTime,
    required double amount,
    required Category category,
    required CategoryTag? tag,
    required RegularAccount account,
    required String? note,
  }) {
    final newTransaction = TransactionDb(
      ObjectId(),
      TransactionType.income.databaseValue,
      dateTime,
      amount.roundTo2DP(),
      note: note,
      category: category.databaseObject,
      categoryTag: tag?.databaseObject,
      account: account.databaseObject,
    );

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
      ObjectId(),
      TransactionType.expense.databaseValue,
      dateTime,
      amount.roundTo2DP(),
      note: note,
      category: category.databaseObject,
      categoryTag: tag?.databaseObject,
      account: account.databaseObject,
    );

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
      ObjectId(),
      TransactionType.transfer.databaseValue,
      dateTime,
      amount.roundTo2DP(),
      note: note,
      account: account.databaseObject,
      transferAccount: toAccount.databaseObject,
      transferFee: transferFee,
    );

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
      paymentAmount: paymentAmount?.roundTo2DP(),
    );

    final newTransaction = TransactionDb(
      ObjectId(),
      TransactionType.creditSpending.databaseValue,
      dateTime,
      amount.roundTo2DP(),
      note: note,
      category: category.databaseObject,
      categoryTag: tag?.databaseObject,
      account: account.databaseObject,
      creditInstallmentDetails: monthsToPay != null && paymentAmount != null ? creditInstallmentDb : null,
    );

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
      adjustment: adjustment ?? 0,
    );

    final newTransaction = TransactionDb(
      ObjectId(),
      TransactionType.creditPayment.databaseValue,
      dateTime,
      amount.roundTo2DP(),
      note: note,
      account: account.databaseObject,
      transferAccount: fromAccount.databaseObject,
      creditPaymentDetails: creditPaymentDetails,
    );

    realm.write(() {
      realm.add(newTransaction);
    });
  }
}

extension EditTempTransaction on TemplateTransactionRepositoryRealmDb {
  void editRegularTransaction(
    BaseRegularTransaction transaction, {
    required RegularTransactionFormState state,
  }) {
    final txnDb = transaction.databaseObject;

    realm.write(() {
      if (state.dateTime != null) {
        txnDb.dateTime = state.dateTime!;
      }

      if (state.amount != null) {
        txnDb.amount = state.amount!.roundTo2DP();
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
    required CreditSpendingFormState state,
  }) {
    final txnDb = transaction.databaseObject;

    realm.write(() {
      if (state.dateTime != null) {
        txnDb.dateTime = state.dateTime!;
      }

      if (state.amount != null) {
        // Modify the adjustment amount of next payment base on amount changes of this spending
        try {
          final nextPaymentDb = (Account.fromDatabase(transaction.account.databaseObject) as CreditAccount)
              .getNextPayment(from: transaction)
              .databaseObject;

          final different = state.amount!.roundTo2DP() - transaction.amount;

          if (nextPaymentDb.creditPaymentDetails != null) {
            nextPaymentDb.creditPaymentDetails!.adjustment += different;
          } else {
            nextPaymentDb.creditPaymentDetails = CreditPaymentDetailsDb(adjustment: different);
          }
        } catch (_) {} // Error means no payment after this spending

        txnDb.amount = state.amount!.roundTo2DP();
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

      if (state.note != null) {
        txnDb.note = state.note;
      }

      if (state.hasInstallment == null || state.hasInstallment!) {
        txnDb.creditInstallmentDetails = CreditInstallmentDetailsDb(
          monthsToPay: state.installmentPeriod ?? transaction.monthsToPay,
          paymentAmount: state.installmentAmount?.roundTo2DP() ?? transaction.paymentAmount,
        );
      } else if (!state.hasInstallment!) {
        txnDb.creditInstallmentDetails = null;
      }
    });
  }

  void editCreditPayment(
    CreditPayment transaction, {
    required CreditPaymentFormState state,
  }) {
    final txnDb = transaction.databaseObject;

    realm.write(() {
      if (state.dateTime != null) {
        txnDb.dateTime = state.dateTime!;
      }

      if (state.fromRegularAccount != null) {
        txnDb.transferAccount = state.fromRegularAccount!.databaseObject;
      }

      if (state.note != null) {
        txnDb.note = state.note;
      }
    });
  }

  void deleteTransaction(BaseTransaction transaction) {
    realm.write(() {
      realm.delete<TransactionDb>(transaction.databaseObject);
    });
  }
}

/////////////////// PROVIDERS //////////////////////////

final tempTransactionRepositoryRealmProvider = Provider<TemplateTransactionRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return TemplateTransactionRepositoryRealmDb(realm);
  },
);

final tempTransactionsChangesStreamProvider = StreamProvider.autoDispose<RealmResultsChanges<TemplateTransactionDb>>(
  (ref) {
    final transactionRepo = ref.watch(tempTransactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges();
  },
);

// final tempTransactionStreamProvider = StreamProvider.autoDispose.family<BaseTransaction, String>(
//   (ref, val) {
//     final transactionRepo = ref.watch(tempTransactionRepositoryRealmProvider);
//     return transactionRepo._watchTransaction(val);
//   },
// );
