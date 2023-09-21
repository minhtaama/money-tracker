part of 'transaction_base.dart';

@immutable
class CreditPayment extends Transaction {
  @override
  final Account? creditAccount;
  final CreditAccount? toCreditAccount;

  const CreditPayment._(
    super._isarObject,
    super.dateTime,
    super.amount,
    super.note, {
    required this.creditAccount,
    required this.toCreditAccount,
  });
}
