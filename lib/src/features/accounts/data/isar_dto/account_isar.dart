import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';
import 'package:money_tracker_app/src/features/transactions/data/isar_dto/transaction_isar.dart';
import '../../../../utils/enums.dart';

// flutter pub run build_runner build --delete-conflicting-outputs
// https://www.hsbc.com.vn/en-vn/credit-cards/understanding-your-credit-card-statement/
part 'account_isar.g.dart';

@Collection()
class AccountIsar extends IsarCollectionObject {
  @enumerated
  late AccountType type;

  late String name;
  late int colorIndex;
  late String iconCategory;
  late int iconIndex;

  int? order;

  /// All regular transactions of this account.
  @Backlink(to: 'accountLink')
  final txnOfThisAccountBacklinks = IsarLinks<TransactionIsar>();

  /// Need for calculating total money of this account. Only for [AccountType.regular]
  @Backlink(to: 'toAccountLink')
  final txnToThisAccountBacklinks = IsarLinks<TransactionIsar>();

  /// Only specify this property if type is [AccountType.credit]
  CreditDetailsIsar? creditDetailsIsar;
}

@Embedded()
class CreditDetailsIsar {
  late double creditBalance;

  /// As in percent. This interestRate is only count
  /// if payment this month is not finish.
  double interestRate = 5;

  late int statementDay;

  late int paymentDueDay;
}

extension AccountBalance on AccountIsar {
  double get currentBalance {
    if (type == AccountType.regular) {
      double balance = 0;
      final txnList = txnOfThisAccountBacklinks.toList();
      for (TransactionIsar txn in txnList) {
        if (txn.transactionType == TransactionType.income) {
          balance += txn.amount;
        } else {
          balance -= txn.amount;
        }
      }
      final txnToThisAccountList = txnToThisAccountBacklinks.toList();
      for (TransactionIsar txn in txnToThisAccountList) {
        balance += txn.amount;
      }
      return balance;
    } else {
      double balance = creditDetailsIsar!.creditBalance;
      final txnList = txnOfThisAccountBacklinks.toList();
      for (TransactionIsar txn in txnList) {
        if (!txn.isDone) {
          balance -= txn.amount - txn.paidAmount;
        }
      }
      return balance;
    }
  }
}
