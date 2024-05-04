import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction_base.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';

class RegularTransactionFormState {
  final DateTime? dateTime;
  final double? amount;
  final String? note;
  final CategoryTag? tag;
  final Category? category;
  final RegularAccount? account;
  final RegularAccount? toAccount;

  factory RegularTransactionFormState.initial(TransactionType? type) {
    if (type != null) {
      return RegularTransactionFormState._(
        dateTime: DateTime.now(),
      );
    }

    return RegularTransactionFormState._();
  }

  bool isAllNull() {
    return amount == null &&
        note == null &&
        tag == null &&
        category == null &&
        account == null &&
        toAccount == null;
  }

  RegularTransactionFormState._({
    this.dateTime,
    this.amount,
    this.note,
    this.tag,
    this.category,
    this.account,
    this.toAccount,
  });

  RegularTransactionFormState copyWith({
    DateTime? Function()? dateTime,
    double? Function()? amount,
    String? Function()? note,
    CategoryTag? Function()? tag,
    Category? Function()? category,
    RegularAccount? Function()? account,
    RegularAccount? Function()? toAccount,
  }) {
    return RegularTransactionFormState._(
      dateTime: dateTime != null ? dateTime() : this.dateTime,
      amount: amount != null ? amount() : this.amount,
      note: note != null ? note() : this.note,
      tag: tag != null ? tag() : this.tag,
      category: category != null ? category() : this.category,
      account: account != null ? account() : this.account,
      toAccount: toAccount != null ? toAccount() : this.toAccount,
    );
  }
}

class RegularTransactionFormController
    extends AutoDisposeFamilyNotifier<RegularTransactionFormState, TransactionType?> {
  @override
  RegularTransactionFormState build(TransactionType? arg) {
    return RegularTransactionFormState.initial(arg);
  }

  void _resetCategoryTag() {
    state = state.copyWith(tag: () => null);
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
        account: () => null,
        toAccount: () => null,
      ),
    );
  }

  void updateStateFromTemplate(TemplateTransaction template) {
    state = state.copyWith(
      dateTime: () => template.dateTime,
      amount: () => template.amount,
      note: () => template.note,
      tag: () => template.categoryTag,
      category: () => template.category,
      account: () => template.account?.toAccount() as RegularAccount?,
      toAccount: () => template.toAccount?.toAccount() as RegularAccount?,
    );
  }

  void changeAmount(String value) {
    state = state.copyWith(amount: () => CalService.formatToDouble(value));
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

  void changeAccount(RegularAccount? account) {
    state = state.copyWith(account: () => account);
  }

  void changeToAccount(RegularAccount? toAccount) {
    state = state.copyWith(toAccount: () => toAccount);
  }

  void changeNote(String note) {
    state = state.copyWith(note: () => note);
  }
}

/// Set arg to `null` if edit mode (initial state has properties all `null`)
final regularTransactionFormNotifierProvider = AutoDisposeNotifierProviderFamily<
    RegularTransactionFormController, RegularTransactionFormState, TransactionType?>(() {
  return RegularTransactionFormController();
});
