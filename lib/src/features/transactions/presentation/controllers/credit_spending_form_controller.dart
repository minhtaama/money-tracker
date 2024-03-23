import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../utils/constants.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';
import '../../domain/transaction_base.dart';

class CreditSpendingFormState {
  final DateTime? dateTime;
  final double? amount;
  final String? note;
  final CategoryTag? tag;
  final Category? category;
  final CreditAccount? creditAccount;
  final bool? hasInstallment;
  final int? installmentPeriod;
  final double? installmentAmount;

  String? installmentAmountString(BuildContext context) {
    if (installmentAmount != null) {
      return CalService.formatCurrency(context, installmentAmount!);
    }
    return null;
  }

  factory CreditSpendingFormState.initial() => CreditSpendingFormState._();

  CreditSpendingFormState._({
    this.dateTime,
    this.amount,
    this.note,
    this.tag,
    this.category,
    this.creditAccount,
    this.hasInstallment,
    this.installmentPeriod,
    this.installmentAmount,
  });

  CreditSpendingFormState copyWith({
    DateTime? Function()? dateTime,
    double? Function()? amount,
    String? Function()? note,
    CategoryTag? Function()? tag,
    Category? Function()? category,
    CreditAccount? Function()? creditAccount,
    int? Function()? installmentPeriod,
    double? Function()? installmentAmount,
    bool? Function()? hasInstallment,
  }) {
    return CreditSpendingFormState._(
      dateTime: dateTime != null ? dateTime() : this.dateTime,
      amount: amount != null ? amount() : this.amount,
      note: note != null ? note() : this.note,
      tag: tag != null ? tag() : this.tag,
      category: category != null ? category() : this.category,
      creditAccount: creditAccount != null ? creditAccount() : this.creditAccount,
      installmentPeriod: installmentPeriod != null ? installmentPeriod() : this.installmentPeriod,
      installmentAmount: installmentAmount != null ? installmentAmount() : this.installmentAmount,
      hasInstallment: hasInstallment != null ? hasInstallment() : this.hasInstallment,
    );
  }
}

class CreditSpendingFormController extends AutoDisposeNotifier<CreditSpendingFormState> {
  @override
  CreditSpendingFormState build() {
    return CreditSpendingFormState.initial();
  }

  void _resetCategoryTag() {
    state = state.copyWith(tag: () => null);
  }

  void _resetInstallment() {
    state = state.copyWith(
      installmentPeriod: () => null,
      installmentAmount: () => null,
    );
  }

  void setStateToAllNull() {
    Future.delayed(
      k150msDuration,
      () => state = state.copyWith(
        dateTime: () => null,
        amount: () => null,
        note: () => null,
        tag: () => null,
        category: () => null,
        creditAccount: () => null,
        installmentPeriod: () => null,
        installmentAmount: () => null,
      ),
    );
  }

  void changeAmount(String value, {CreditSpending? initialTransaction}) {
    state = state.copyWith(amount: () => CalService.formatToDouble(value));

    if (state.installmentPeriod != null) {
      state = state.copyWith(
        installmentAmount: () => state.amount! / state.installmentPeriod!,
      );
    } else if (initialTransaction != null && state.installmentPeriod != null) {
      state = state.copyWith(
        installmentAmount: () => state.amount! / initialTransaction.monthsToPay!,
      );
    } else {
      _resetInstallment();
    }
  }

  void changeDateTime(DateTime? dateTime) {
    state = state.copyWith(dateTime: () => dateTime);
  }

  void changeCategory(Category? category) {
    _resetCategoryTag();
    state = state.copyWith(category: () => category);
  }

  void changeCategoryTag(CategoryTag? tag) {
    state = state.copyWith(tag: () => tag);
  }

  void changeCreditAccount(CreditAccount? account) {
    state = state.copyWith(creditAccount: () => account);
  }

  void changeInstallmentPeriod(int? period, {CreditSpending? initialTransaction}) {
    state = state.copyWith(installmentPeriod: () => period);

    if (state.installmentPeriod != null) {
      if (state.amount != null) {
        state = state.copyWith(
          installmentAmount: () => state.amount! / state.installmentPeriod!,
        );
      } else if (initialTransaction != null) {
        state = state.copyWith(
          installmentAmount: () => initialTransaction.amount / state.installmentPeriod!,
        );
      }
    } else {
      _resetInstallment();
    }
  }

  void changeInstallmentAmount(String value) {
    state = state.copyWith(installmentAmount: () => CalService.formatToDouble(value));
  }

  void changeNote(String note) {
    state = state.copyWith(note: () => note);
  }

  void changeEditHasInstallment(bool value) {
    if (!value) {
      state = state.copyWith(hasInstallment: () => false);
      _resetInstallment();
    } else {
      state = state.copyWith(hasInstallment: () => true);
    }
  }
}

final creditSpendingFormNotifierProvider =
    AutoDisposeNotifierProvider<CreditSpendingFormController, CreditSpendingFormState>(() {
  return CreditSpendingFormController();
});
