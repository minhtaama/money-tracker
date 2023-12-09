import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../accounts/domain/account_base.dart';

class CreditPaymentForm {
  final DateTime? dateTime;
  final String? note;

  final CreditAccount? creditAccount;
  final RegularAccount? fromRegularAccount;

  final bool isFullPayment = false;
  final double? adjustment;
  final double? userPaymentAmount;

  //TODO: https://pub.dev/documentation/riverpod/latest/riverpod/Notifier-class.html

  final double? _userRemainingAmount;

  CreditPaymentForm._(
    this.dateTime,
    this.note,
    this.creditAccount,
    this.fromRegularAccount,
    this.userPaymentAmount,
    this._userRemainingAmount,
    this.adjustment,
  );
}

class CreditPaymentFormController extends Notifier<CreditPaymentForm> {
  @override
  CreditPaymentForm build() {
    // TODO: implement build
    throw UnimplementedError();
  }
}
