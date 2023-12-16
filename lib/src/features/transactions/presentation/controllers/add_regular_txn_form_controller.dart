import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';

class RegularTransactionFormState {
  final TransactionType type;
  final DateTime? dateTime;
  final double? amount;
  final String? note;
  final CategoryTag? tag;
  final Category? category;
  final RegularAccount? account;
  final RegularAccount? toAccount;

  factory RegularTransactionFormState.initial(TransactionType type) => RegularTransactionFormState._(type: type);

  RegularTransactionFormState._({
    required this.type,
    this.dateTime,
    this.amount,
    this.note,
    this.tag,
    this.category,
    this.account,
    this.toAccount,
  });

  RegularTransactionFormState copyWith({
    // TransactionType Function()? type,
    DateTime? Function()? dateTime,
    double? Function()? amount,
    String? Function()? note,
    CategoryTag? Function()? tag,
    Category? Function()? category,
    RegularAccount? Function()? account,
    RegularAccount? Function()? toAccount,
  }) {
    return RegularTransactionFormState._(
      type: type,
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

class RegularTransactionFormController extends AutoDisposeFamilyNotifier<RegularTransactionFormState, TransactionType> {
  @override
  RegularTransactionFormState build(TransactionType arg) {
    return RegularTransactionFormState.initial(arg);
  }

  void _resetCategoryTag() {
    state = state.copyWith(tag: () => null);
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

final regularTransactionFormNotifierProvider =
    AutoDisposeNotifierProviderFamily<RegularTransactionFormController, RegularTransactionFormState, TransactionType>(
        () {
  return RegularTransactionFormController();
});
