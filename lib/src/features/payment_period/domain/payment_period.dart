import 'package:flutter/material.dart';

@immutable
class PaymentPeriod {
  const PaymentPeriod(this.statementDate, this.paymentDueDate);

  final DateTime statementDate;

  final DateTime paymentDueDate;
}

extension Details on PaymentPeriod {
//  List<CreditSpending> spendingTransactions
}
