import 'package:flutter/material.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import '../../../../persistent/realm_dto.dart';
import '../../accounts/domain/account_base.dart';
import '../../category/domain/category.dart';
import '../../category/domain/category_tag.dart';

part 'regular_transaction.dart';
part 'credit_transaction.dart';

abstract interface class ITransferable {
  final RegularAccount? transferAccount;

  ITransferable(this.transferAccount);
}

@immutable
abstract interface class IBaseTransactionWithCategory {
  final Category? category;
  final CategoryTag? categoryTag;

  const IBaseTransactionWithCategory(
    this.category,
    this.categoryTag,
  );
}

@immutable
sealed class BaseTransaction extends BaseModel<TransactionDb> {
  final DateTime dateTime;
  final double amount;
  final String? note;
  final Account? account;

  const BaseTransaction(
    super._databaseObject,
    this.dateTime,
    this.amount,
    this.note,
    this.account,
  );

  factory BaseTransaction.fromDatabase(TransactionDb txn) {
    switch (txn.type) {
      case 0:
        return Expense._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
        );

      case 1:
        return Income._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          isInitialTransaction: txn.isInitialTransaction,
        );

      case 2:
        return Transfer._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccount,
          fee: Fee._fromDatabase(txn),
        );

      case 3:
        return CreditSpending._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          Category.fromDatabase(txn.category),
          CategoryTag.fromDatabase(txn.categoryTag),
          //payments: payments,
          monthsToPay: txn.creditInstallmentDetails?.monthsToPay,
          paymentAmount: txn.creditInstallmentDetails?.paymentAmount,
        );

      case 4:
        // CreditPaymentType paymentTypeFromDb(int type) => switch (type) {
        //       0 => CreditPaymentType.underMinimum,
        //       1 => CreditPaymentType.minimumOrHigher,
        //       _ => CreditPaymentType.full,
        //     };

        return CreditPayment._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          transferAccount: Account.fromDatabaseWithNoDetails(txn.transferAccount) as RegularAccount,
          isFullPayment: txn.creditPaymentDetails!.isFullPayment,
          adjustment: txn.creditPaymentDetails!.adjustedBalance,
        );

      default:
        return CreditCheckpoint._(
          txn,
          txn.dateTime.toLocal(),
          txn.amount,
          txn.note,
          Account.fromDatabaseWithNoDetails(txn.account),
          finishedInstallments: [
            for (TransactionDb el in txn.creditCheckpointFinishedInstallments)
              BaseTransaction.fromDatabase(el) as CreditSpending
          ],
        );
    }
  }
}
