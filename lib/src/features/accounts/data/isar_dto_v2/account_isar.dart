import 'package:isar/isar.dart';
import 'package:money_tracker_app/persistent/isar_model.dart';

// flutter pub run build_runner build --delete-conflicting-outputs

abstract class AccountIsar extends IsarCollectionObject implements IsarCollectionColorAndIcon, IsarCollectionOrderable {
  @override
  late String name;
  @override
  late int colorIndex;
  @override
  late String iconCategory;
  @override
  late int iconIndex;

  @override
  int? order;

  // /// All regular transactions of this account.
  // @Backlink(to: 'accountLink')
  // final txnOfThisAccountBacklinks = IsarLinks<TransactionIsar>();
  //
  // /// Need for calculating total money of this account. Only for [AccountType.regular]
  // @Backlink(to: 'toAccountLink')
  // final txnToThisAccountBacklinks = IsarLinks<TransactionIsar>();
  //
  // /// Only specify this property if type is [AccountType.credit]
  // CreditDetailsIsar? creditDetailsIsar;
}

@Collection()
class RegularAccountIsar extends AccountIsar {}

// @Embedded()
// class CreditDetailsIsar {
//   late double creditBalance;
//
//   /// As in percent. This interestRate is only count
//   /// if payment this month is not finish.
//   double apr = 5;
//
//   late int statementDay;
//
//   late int paymentDueDay;
// }
