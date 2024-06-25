import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/recurrence/domain/recurrence.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../transactions/presentation/controllers/regular_txn_form_controller.dart';

class RecurrenceRepositoryRealmDb {
  RecurrenceRepositoryRealmDb(this.realm);

  final Realm realm;

  Stream<RealmResultsChanges<RecurrenceDb>> _watchListChanges() {
    return realm.all<RecurrenceDb>().changes;
  }

  List<RecurrenceDb> _realmResults() => realm.all<RecurrenceDb>().query('TRUEPREDICATE SORT(order ASC)').toList();

  List<Recurrence> getRecurrences() {
    List<RecurrenceDb> list = realm.all<RecurrenceDb>().query('TRUEPREDICATE SORT(order ASC)').toList();
    return list.map((recurrence) => Recurrence.fromDatabase(recurrence)!).toList();
  }

  // TemplateTransaction getTemplateFromHex(String objectIdHexString) {
  //   ObjectId objId = ObjectId.fromHexString(objectIdHexString);
  //   final txnDb = realm.find<TemplateTransactionDb>(objId);
  //   if (txnDb != null) {
  //     return TemplateTransaction.fromDatabase(txnDb);
  //   }
  //   throw StateError('TemplateTransactionDb id is not found');
  // }

  /// The list must be the same list displayed in the widget (with the same sort order)
  void reorder(int oldIndex, int newIndex) {
    final list = _realmResults().toList();

    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    realm.write(
      () {
        // Recreate order to query sort by this property
        for (int i = 0; i < list.length; i++) {
          list[i].order = i;
        }
      },
    );
  }
}

extension ModifyRecurrenceData on RecurrenceRepositoryRealmDb {
  Recurrence writeNew({
    required RepeatEvery type,
    required int interval,
    required List<DateTime> patterns,
    required DateTime startOn,
    required DateTime? endOn,
    required bool autoCreateTransaction,
    required TransactionType transactionType,
    required RegularTransactionFormState transactionForm,
  }) {
    final order = getRecurrences().length;

    final newTransactionData = TransactionDataDb(
      transactionType.databaseValue,
      amount: transactionForm.amount,
      note: transactionForm.note,
      account: transactionForm.account?.databaseObject,
      category: transactionForm.category?.databaseObject,
      categoryTag: transactionForm.tag?.databaseObject,
      transferAccount: transactionForm.toAccount?.databaseObject,
      transferFee: null,
      //TODO: Implement transfer fee
    );

    final newRecurrence = RecurrenceDb(
      ObjectId(),
      type.databaseValue,
      interval,
      startOn,
      patterns: patterns.map((e) => e.onlyYearMonthDay),
      endOn: endOn?.onlyYearMonthDay,
      autoCreateTransaction: autoCreateTransaction,
      transactionData: newTransactionData,
      order: order,
    );

    realm.write(() {
      realm.add(newRecurrence);
    });

    return Recurrence.fromDatabase(newRecurrence)!;
  }

  /// This function evaluates the [_patterns] and returns [TransactionData] objects
  /// which has its [TransactionData.dateTime] correctly aligned with the [_patterns] in the
  /// current month (and only contains year, month and day values) of each recurrence.
  List<TransactionData> getPlannedTransactionsInMonth(BuildContext context, DateTime dateTime) {
    final results = <TransactionData>[];

    final allRecurrences = getRecurrences();

    for (Recurrence recurrence in allRecurrences) {
      results.addAll(recurrence.getAllPlannedTransactionsInMonth(context, dateTime));
      results.sort(
        (a, b) => a.dateTime!.compareTo(b.dateTime!),
      );
    }

    return results;
  }

  void addTransaction(WidgetRef ref, TransactionData transactionData) {
    if (transactionData.dateTime == null) {
      throw StateError('TransactionData.dateTime is null');
    }

    final transactionRepo = ref.read(transactionRepositoryRealmProvider);

    BaseRegularTransaction transaction = switch (transactionData.type) {
      TransactionType.expense => transactionRepo.writeNewExpense(
          dateTime: transactionData.dateTime!,
          amount: transactionData.amount!,
          category: transactionData.category!,
          tag: transactionData.categoryTag,
          account: transactionData.account!.toAccount() as RegularAccount,
          note: transactionData.note,
          recurrence: transactionData.recurrence,
        ),
      TransactionType.income => transactionRepo.writeNewIncome(
          dateTime: transactionData.dateTime!,
          amount: transactionData.amount!,
          category: transactionData.category!,
          tag: transactionData.categoryTag,
          account: transactionData.account!.toAccount() as RegularAccount,
          note: transactionData.note,
          recurrence: transactionData.recurrence,
        ),
      TransactionType.transfer => transactionRepo.writeNewTransfer(
          dateTime: transactionData.dateTime!,
          amount: transactionData.amount!,
          account: transactionData.account!.toAccount(),
          toAccount: transactionData.toAccount!.toAccount(),
          note: transactionData.note,
          recurrence: transactionData.recurrence,
          fee: null,
          isChargeOnDestinationAccount: null,
        ),
      TransactionType.creditSpending ||
      TransactionType.creditPayment ||
      TransactionType.creditCheckpoint ||
      TransactionType.installmentToPay =>
        throw StateError('Wrong transaction type'),
    };

    realm.write(() {
      transactionData.recurrence.databaseObject.addedOn[transaction.databaseObject.id.hexString] =
          transactionData.dateTime!;
    });
  }

  void addSkipped(TransactionData transactionData) {
    if (transactionData.dateTime == null) {
      throw StateError('TransactionData.dateTime is null');
    }

    realm.write(() {
      transactionData.recurrence.databaseObject.skippedOn.add(transactionData.dateTime!);
    });
  }

  void removeSkipped(TransactionData transactionData) {
    if (transactionData.dateTime == null) {
      throw StateError('TransactionData.dateTime is null');
    }

    realm.write(() {
      transactionData.recurrence.databaseObject.skippedOn.remove(transactionData.dateTime!);
    });
  }

  void delete(Recurrence recurrence) {
    realm.write(() {
      realm.delete<RecurrenceDb>(recurrence.databaseObject);
    });
  }
}

/////////////////// PROVIDERS //////////////////////////

final recurrenceRepositoryRealmProvider = Provider<RecurrenceRepositoryRealmDb>(
  (ref) {
    final realm = ref.watch(realmProvider);
    return RecurrenceRepositoryRealmDb(realm);
  },
);

final recurrenceChangesStreamProvider = StreamProvider.autoDispose<RealmResultsChanges<RecurrenceDb>>(
  (ref) {
    final recurrenceRepo = ref.watch(recurrenceRepositoryRealmProvider);
    return recurrenceRepo._watchListChanges();
  },
);
