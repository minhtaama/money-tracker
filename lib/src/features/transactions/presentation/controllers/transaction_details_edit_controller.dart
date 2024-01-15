import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';

class TransactionDetailsEditState {
  final DateTime? dateTime;
  final double? amount;
  final String? note;
  final CategoryTag? tag;
  final Category? category;
  final Account? mainAccount;

  final RegularAccount? transferToRegularAccount;

  final RegularAccount? creditPaymentFromRegularAccount;

  final int? installmentPeriod;
  final double? installmentAmount;

  factory TransactionDetailsEditState.initial() => TransactionDetailsEditState._();

  TransactionDetailsEditState._({
    this.dateTime,
    this.amount,
    this.note,
    this.tag,
    this.category,
    this.mainAccount,
    this.transferToRegularAccount,
    this.creditPaymentFromRegularAccount,
    this.installmentPeriod,
    this.installmentAmount,
  });

  TransactionDetailsEditState copyWith({
    DateTime? Function()? dateTime,
    double? Function()? amount,
    String? Function()? note,
    CategoryTag? Function()? tag,
    Category? Function()? category,
    CreditAccount? Function()? mainAccount,
    int? Function()? installmentPeriod,
    double? Function()? installmentAmount,
  }) {
    return TransactionDetailsEditState._(
      dateTime: dateTime != null ? dateTime()! : this.dateTime,
      amount: amount != null ? amount() : this.amount,
      note: note != null ? note() : this.note,
      tag: tag != null ? tag() : this.tag,
      category: category != null ? category() : this.category,
      mainAccount: mainAccount != null ? mainAccount() : this.mainAccount,
      installmentPeriod: installmentPeriod != null ? installmentPeriod() : this.installmentPeriod,
      installmentAmount: installmentAmount != null ? installmentAmount() : this.installmentAmount,
    );
  }
}

class TransactionDetailsEditController extends AutoDisposeNotifier<TransactionDetailsEditState> {
  @override
  TransactionDetailsEditState build() {
    return TransactionDetailsEditState.initial();
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

  void changeAmount(BuildContext context, String value) {
    state = state.copyWith(amount: () => CalService.formatToDouble(value));
    if (state.installmentPeriod != null) {
      state = state.copyWith(
        installmentAmount: () => (state.amount! / state.installmentPeriod!).roundBySetting(context),
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
    state = state.copyWith(mainAccount: () => account);
  }

  void changeInstallmentPeriod(BuildContext context, int? period) {
    state = state.copyWith(installmentPeriod: () => period);

    if (state.installmentPeriod != null) {
      state = state.copyWith(
        installmentAmount: () => (state.amount! / state.installmentPeriod!).roundBySetting(context),
      );
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
}

final transactionDetailsEditNotifierProvider =
    AutoDisposeNotifierProvider<TransactionDetailsEditController, TransactionDetailsEditState>(() {
  return TransactionDetailsEditController();
});
