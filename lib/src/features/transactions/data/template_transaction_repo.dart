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
import '../domain/template_transaction.dart';
import '../domain/transaction_base.dart';
import '../presentation/controllers/credit_payment_form_controller.dart';
import '../presentation/controllers/regular_txn_form_controller.dart';

class TemplateTransactionRepositoryRealmDb {
  TemplateTransactionRepositoryRealmDb(this.realm);

  final Realm realm;

  Stream<RealmResultsChanges<TemplateTransactionDb>> _watchListChanges() {
    return realm.all<TemplateTransactionDb>().changes;
  }

  List<TemplateTransaction> getTransactions() {
    List<TemplateTransactionDb> list =
        realm.all<TemplateTransactionDb>().query('TRUEPREDICATE SORT(dateTime ASC)').toList();
    return list.map((txn) => TemplateTransaction.fromDatabase(txn)).toList();
  }

  TemplateTransaction getTransactionFromHex(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<TemplateTransactionDb>(objId);
    if (txnDb != null) {
      return TemplateTransaction.fromDatabase(txnDb);
    }
    throw StateError('TemplateTransactionDb id is not found');
  }
}

extension ModifyTempTransaction on TemplateTransactionRepositoryRealmDb {
  void writeNew({
    required TransactionType transactionType,
    required DateTime? dateTime,
    required double? amount,
    required Category? category,
    required CategoryTag? tag,
    required RegularAccount? account,
    required RegularAccount? toAccount,
    required String? note,
    required double? fee,
    required bool? isChargeOnDestinationAccount,
  }) {
    TransferFeeDb? transferFee;
    if (fee != null && isChargeOnDestinationAccount != null) {
      transferFee = TransferFeeDb(amount: fee, chargeOnDestination: isChargeOnDestinationAccount);
    }

    final newTemplateTransaction = TemplateTransactionDb(
      ObjectId(),
      TransactionType.income.databaseValue,
      dateTime: dateTime,
      amount: amount?.roundTo2DP(),
      note: note,
      category: category?.databaseObject,
      categoryTag: tag?.databaseObject,
      account: account?.databaseObject,
    );

    realm.write(() {
      realm.add(newTemplateTransaction);
    });
  }

  void delete(TemplateTransaction transaction) {
    realm.write(() {
      realm.delete<TemplateTransactionDb>(transaction.databaseObject);
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
