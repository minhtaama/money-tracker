import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../accounts/domain/account_base.dart';
import '../../../accounts/domain/statement/statement.dart';
import '../../../calculator_input/application/calculator_service.dart';

//TODO: https://pub.dev/documentation/riverpod/latest/riverpod/Notifier-class.html

class CreditPaymentFormState {
  final DateTime? dateTime;
  final String? note;
  final CreditAccount? creditAccount;
  final RegularAccount? fromRegularAccount;
  final bool isFullPayment;
  final double? adjustment;
  final double? userPaymentAmount;

  final double? userRemainingAmount;

  final Statement? _statement;

  double get _totalBalanceAmount =>
      _statement == null || dateTime == null ? 0 : _statement!.getBalanceAmountAt(dateTime!);

  CreditPaymentFormState._(
    this._statement, {
    this.dateTime,
    this.note,
    this.creditAccount,
    this.fromRegularAccount,
    this.userPaymentAmount,
    this.userRemainingAmount,
    this.adjustment,
    this.isFullPayment = false,
  });

  factory CreditPaymentFormState.initial() => CreditPaymentFormState._(null);

  CreditPaymentFormState copyWith({
    Statement? statement,
    DateTime? dateTime,
    String? note,
    CreditAccount? creditAccount,
    RegularAccount? fromRegularAccount,
    bool? isFullPayment,
    double? adjustment,
    double? userPaymentAmount,
    double? userRemainingAmount,
  }) {
    return CreditPaymentFormState._(
      statement,
      dateTime: dateTime ?? this.dateTime,
      note: note ?? this.note,
      creditAccount: creditAccount ?? this.creditAccount,
      fromRegularAccount: fromRegularAccount ?? this.fromRegularAccount,
      isFullPayment: isFullPayment ?? this.isFullPayment,
      adjustment: adjustment ?? this.adjustment,
      userPaymentAmount: userPaymentAmount ?? this.userPaymentAmount,
      userRemainingAmount: userRemainingAmount ?? this.userRemainingAmount,
    );
  }
}

class CreditPaymentFormController extends Notifier<CreditPaymentFormState> {
  @override
  CreditPaymentFormState build() {
    return CreditPaymentFormState.initial();
  }

  void _resetAll() {
    state = CreditPaymentFormState.initial();
  }

  void _resetNumberInput() {
    state = state.copyWith(
      userRemainingAmount: null,
      userPaymentAmount: null,
      adjustment: null,
      isFullPayment: false,
    );
  }

  void _resetDateTime() {
    state = state.copyWith(dateTime: null);
  }

  void changeRemainingInput(String value) {
    state = state.copyWith(
        userRemainingAmount: CalService.formatToDouble(value),
        adjustment: state._totalBalanceAmount - state.userPaymentAmount! - state.userRemainingAmount!);
  }

  void changePaymentInput(BuildContext context, String value) {
    state = state.copyWith(userRemainingAmount: null);

    if (state.userPaymentAmount != null &&
        (state.userPaymentAmount! > state._totalBalanceAmount ||
            state.isFullPayment ||
            state.userPaymentAmount!.roundUsingAppSetting(context) ==
                state._totalBalanceAmount.roundUsingAppSetting(context))) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      state = state.copyWith(adjustment: state._totalBalanceAmount - state.userPaymentAmount!);
    } else {
      state = state.copyWith(adjustment: null);
    }
  }

  void toggleFullPayment(bool value) {
    state = state.copyWith(isFullPayment: value, userRemainingAmount: null);

    if (state.isFullPayment && state.userPaymentAmount != null) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      state.copyWith(adjustment: state._totalBalanceAmount - state.userPaymentAmount!);
    } else {
      state.copyWith(adjustment: null);
    }
  }

  void changeDateTime(DateTime dateTime, Statement statement) {
    _resetNumberInput();
    state = state.copyWith(dateTime: dateTime, statement: statement);
  }

  void changeCreditAccount(CreditAccount creditAccount) {
    _resetNumberInput();
    _resetDateTime();
    state = state.copyWith(creditAccount: creditAccount);
  }

  void changeRegularAccount(RegularAccount regularAccount) {
    state = state.copyWith(fromRegularAccount: regularAccount);
  }
}

final creditPaymentFormNotifierProvider =
    NotifierProvider<CreditPaymentFormController, CreditPaymentFormState>(CreditPaymentFormController.new);
