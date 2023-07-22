import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';

class AccountService {
  static double getTotalBalance(AccountIsar accountIsar) {
    double totalBalance = 0;
    final transactionList = accountIsar.transactions.toList();
    for (TransactionIsar transaction in transactionList) {
      totalBalance += transaction.amount;
    }
    return totalBalance;
  }
}
