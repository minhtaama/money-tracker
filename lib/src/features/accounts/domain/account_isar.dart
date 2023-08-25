import 'package:isar/isar.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_isar.dart';
import '../../../utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'account_isar.g.dart';

@Collection()
class AccountIsar {
  Id id = Isar.autoIncrement;

  @enumerated
  late AccountType type;

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;

  /// Only specify this property if type is [AccountType.credit]
  CreditAccountDetails? creditAccountDetails;

  /// All transactions of this account.
  @Backlink(to: 'accountLink')
  final txnOfThisAccountBacklinks = IsarLinks<TransactionIsar>();

  /// Only for on-hand account transfers. Need for calculating total money of this account.
  @Backlink(to: 'toAccountLink')
  final txnToThisAccountBacklinks = IsarLinks<TransactionIsar>();

  double get balance {
    double accountBalance = 0;
    final transactionList = txnOfThisAccountBacklinks.toList();
    for (TransactionIsar transaction in transactionList) {
      if (transaction.transactionType == TransactionType.income) {
        accountBalance += transaction.amount;
      } else if (transaction.transactionType == TransactionType.expense ||
          transaction.transactionType == TransactionType.transfer) {
        accountBalance -= transaction.amount;
      }
    }
    final transactionsTransferredToThisAccountList = txnToThisAccountBacklinks.toList();
    for (TransactionIsar transaction in transactionsTransferredToThisAccountList) {
      accountBalance += transaction.amount;
    }
    return accountBalance;
  }
}

@Embedded()
class CreditAccountDetails {
  late DateTime statementDate;

  late DateTime paymentDueDate;
}
