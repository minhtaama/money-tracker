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

  final Statement? statement;

  double get totalBalanceAmount =>
      statement == null || dateTime == null ? 0 : statement!.getBalanceAmountAt(dateTime!);

  CreditPaymentFormState._({
    this.statement,
    this.dateTime,
    this.note,
    this.creditAccount,
    this.fromRegularAccount,
    this.userPaymentAmount,
    this.userRemainingAmount,
    this.adjustment,
    this.isFullPayment = false,
  });

  factory CreditPaymentFormState.initial() => CreditPaymentFormState._();

  CreditPaymentFormState copyWith({
    Statement? Function()? statement,
    DateTime? Function()? dateTime,
    String? Function()? note,
    CreditAccount? Function()? creditAccount,
    RegularAccount? Function()? fromRegularAccount,
    bool Function()? isFullPayment,
    double? Function()? adjustment,
    double? Function()? userPaymentAmount,
    double? Function()? userRemainingAmount,
  }) {
    return CreditPaymentFormState._(
      statement: statement != null ? statement() : this.statement,
      dateTime: dateTime != null ? dateTime() : this.dateTime,
      note: note != null ? note() : this.note,
      creditAccount: creditAccount != null ? creditAccount() : this.creditAccount,
      fromRegularAccount: fromRegularAccount != null ? fromRegularAccount() : this.fromRegularAccount,
      isFullPayment: isFullPayment != null ? isFullPayment() : this.isFullPayment,
      adjustment: adjustment != null ? adjustment() : this.adjustment,
      userPaymentAmount: userPaymentAmount != null ? userPaymentAmount() : this.userPaymentAmount,
      userRemainingAmount:
          userRemainingAmount != null ? userRemainingAmount() : this.userRemainingAmount,
    );
  }

  @override
  String toString() {
    return 'CreditPaymentFormState{dateTime: $dateTime, note: $note, creditAccount: $creditAccount, fromRegularAccount: $fromRegularAccount, isFullPayment: $isFullPayment, adjustment: $adjustment, userPaymentAmount: $userPaymentAmount, userRemainingAmount: $userRemainingAmount, statement: $statement}';
  }
}

class CreditPaymentFormController extends AutoDisposeNotifier<CreditPaymentFormState> {
  @override
  CreditPaymentFormState build() {
    return CreditPaymentFormState.initial();
  }

  void _resetNumberInput() {
    state = state.copyWith(
      userRemainingAmount: () => null,
      userPaymentAmount: () => null,
      adjustment: () => null,
      isFullPayment: () => false,
    );
  }

  void _resetDateTime() {
    state = state.copyWith(dateTime: () => null, statement: () => null);
  }

  void changeRemainingInput(String value) {
    state = state.copyWith(userRemainingAmount: () => CalService.formatToDouble(value));

    state = state.copyWith(
        // Because: afterAdjustedAmount = userPaymentAmount + adjustment
        // Then: userRemaining = totalBalance - afterAdjustedAmount
        // Then: userRemaining = totalBalance - userPaymentAmount - adjustment
        adjustment: () =>
            state.totalBalanceAmount - state.userPaymentAmount! - state.userRemainingAmount!);
  }

  void changePaymentInput(BuildContext context, String value) {
    state = state.copyWith(
      userPaymentAmount: () => CalService.formatToDouble(value),
      userRemainingAmount: () => null,
    );

    if (state.userPaymentAmount != null &&
        //(state.userPaymentAmount! > state.totalBalanceAmount ||
        (state.isFullPayment ||
            state.userPaymentAmount!.roundBySetting(context) ==
                state.totalBalanceAmount.roundBySetting(context))) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      state = state.copyWith(adjustment: () => state.totalBalanceAmount - state.userPaymentAmount!);
    } else {
      state = state.copyWith(adjustment: () => null);
    }
  }

  void toggleFullPayment(bool value) {
    state = state.copyWith(isFullPayment: () => value, userRemainingAmount: () => null);

    if (state.isFullPayment && state.userPaymentAmount != null) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      state = state.copyWith(adjustment: () => state.totalBalanceAmount - state.userPaymentAmount!);
    } else {
      state = state.copyWith(adjustment: () => null);
    }
  }

  void changeDateTime(DateTime? dateTime, Statement? statement) {
    state = state.copyWith(dateTime: () => dateTime, statement: () => statement);
  }

  void changeCreditAccount(CreditAccount? creditAccount) {
    _resetNumberInput();
    _resetDateTime();
    state = state.copyWith(creditAccount: () => creditAccount);
  }

  void changeRegularAccount(RegularAccount? regularAccount) {
    state = state.copyWith(fromRegularAccount: () => regularAccount);
  }

  void changeNote(String note) {
    state = state.copyWith(note: () => note);
  }

  bool isPaymentCloseToBalance(BuildContext context) {
    if (state.userPaymentAmount != null) {
      double paymentAmount = state.userPaymentAmount!;
      double balanceAmount = state.totalBalanceAmount.roundBySetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount <= balanceAmount + (balanceAmount * 2.5 / 100) &&
          paymentAmount >= balanceAmount - (balanceAmount * 2.5 / 100) &&
          paymentAmount != balanceAmount;
    } else {
      return false;
    }
  }

  bool isPaymentQuiteHighThanBalance(BuildContext context) {
    if (state.userPaymentAmount != null) {
      double paymentAmount = state.userPaymentAmount!;
      double balanceAmount = state.totalBalanceAmount.roundBySetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount < balanceAmount + (balanceAmount * 10 / 100) &&
          paymentAmount > balanceAmount + (balanceAmount * 2.5 / 100);
    } else {
      return false;
    }
  }

  bool isPaymentEqualBalance(BuildContext context) {
    if (state.userPaymentAmount != null) {
      double paymentAmount = state.userPaymentAmount!;
      double balanceAmount = state.totalBalanceAmount.roundBySetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount == balanceAmount;
    } else {
      return false;
    }
  }

  bool isPaymentTooHighThanBalance(BuildContext context) {
    if (state.userPaymentAmount != null) {
      double paymentAmount = state.userPaymentAmount!;
      double balanceAmount = state.totalBalanceAmount.roundBySetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount >= balanceAmount + (balanceAmount * 10 / 100);
    } else {
      return false;
    }
  }

  bool isNoNeedPayment(BuildContext context) {
    double balanceAmount = state.totalBalanceAmount.roundBySetting(context);

    return balanceAmount == 0;
  }
}

final creditPaymentFormNotifierProvider =
    AutoDisposeNotifierProvider<CreditPaymentFormController, CreditPaymentFormState>(() {
  return CreditPaymentFormController();
});
