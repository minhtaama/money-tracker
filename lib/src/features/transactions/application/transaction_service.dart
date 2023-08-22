import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';

import '../../../utils/enums.dart';

class TransactionService {
  static double getAccountBalance(AccountIsar accountIsar) {
    double accountBalance = 0;
    final transactionList = accountIsar.txnBacklinks.toList();
    for (TransactionIsar transaction in transactionList) {
      if (transaction.transactionType == TransactionType.income) {
        accountBalance += transaction.amount;
      } else if (transaction.transactionType == TransactionType.expense ||
          transaction.transactionType == TransactionType.transfer) {
        accountBalance -= transaction.amount;
      }
    }
    final transactionsTransferredToThisAccountList = accountIsar.txnTransferredToBacklinks.toList();
    for (TransactionIsar transaction in transactionsTransferredToThisAccountList) {
      accountBalance += transaction.amount;
    }
    return accountBalance;
  }

  static double getTotalBalance(Isar isar, {bool includeCreditAccount = false}) {
    double totalBalance = 0;
    final List<AccountIsar> accountList;
    if (includeCreditAccount) {
      accountList = isar.accountIsars.where().findAllSync();
    } else {
      accountList = isar.accountIsars.filter().typeEqualTo(AccountType.onHand).findAllSync();
    }
    for (AccountIsar account in accountList) {
      totalBalance += TransactionService.getAccountBalance(account);
    }
    return totalBalance;
  }
}
