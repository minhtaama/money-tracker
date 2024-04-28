import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/realm_data_store.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import 'package:realm/realm.dart';
import '../../../../persistent/realm_dto.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';
import '../domain/template_transaction.dart';

class TemplateTransactionRepositoryRealmDb {
  TemplateTransactionRepositoryRealmDb(this.realm);

  final Realm realm;

  Stream<RealmResultsChanges<TemplateTransactionDb>> _watchListChanges() {
    return realm.all<TemplateTransactionDb>().changes;
  }

  List<TemplateTransactionDb> _realmResults() =>
      realm.all<TemplateTransactionDb>().query('TRUEPREDICATE SORT(order ASC)').toList();

  List<TemplateTransaction> getTemplates() {
    List<TemplateTransactionDb> list =
        realm.all<TemplateTransactionDb>().query('TRUEPREDICATE SORT(order ASC)').toList();
    return list.map((txn) => TemplateTransaction.fromDatabase(txn)).toList();
  }

  TemplateTransaction getTemplateFromHex(String objectIdHexString) {
    ObjectId objId = ObjectId.fromHexString(objectIdHexString);
    final txnDb = realm.find<TemplateTransactionDb>(objId);
    if (txnDb != null) {
      return TemplateTransaction.fromDatabase(txnDb);
    }
    throw StateError('TemplateTransactionDb id is not found');
  }

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

extension ModifyTempTransaction on TemplateTransactionRepositoryRealmDb {
  TemplateTransaction writeNew({
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

    final order = getTemplates().length;

    final newTemplateTransaction = TemplateTransactionDb(
      ObjectId(),
      transactionType.databaseValue,
      dateTime: dateTime,
      amount: amount?.roundTo2DP(),
      note: note,
      category: category?.databaseObject,
      categoryTag: tag?.databaseObject,
      account: account?.databaseObject,
      order: order,
    );

    realm.write(() {
      realm.add(newTemplateTransaction);
    });

    return TemplateTransaction.fromDatabase(newTemplateTransaction);
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

final tempTransactionsChangesStreamProvider =
    StreamProvider.autoDispose<RealmResultsChanges<TemplateTransactionDb>>(
  (ref) {
    final transactionRepo = ref.watch(tempTransactionRepositoryRealmProvider);
    return transactionRepo._watchListChanges();
  },
);
