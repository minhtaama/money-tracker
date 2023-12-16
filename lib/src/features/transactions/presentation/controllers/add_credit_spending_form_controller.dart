import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';

class CreditSpendingFormState {
  final DateTime dateTime;
  final double? amount;
  final String? note;
  final CategoryTag? tag;
  final Category? category;
  final CreditAccount? account;
  final int? installmentPeriod;

  double? getInstallmentAmount(BuildContext context) {
    if (amount != null && installmentPeriod != null) {
      return (amount! / installmentPeriod!).roundBySetting(context);
    } else {
      return null;
    }
  }

  factory CreditSpendingFormState.initial() => CreditSpendingFormState._(dateTime: DateTime.now());

  CreditSpendingFormState._({
    required this.dateTime,
    this.amount,
    this.note,
    this.tag,
    this.category,
    this.account,
    this.installmentPeriod,
  });

  CreditSpendingFormState copyWith({
    // TransactionType Function()? type,
    DateTime? Function()? dateTime,
    double? Function()? amount,
    String? Function()? note,
    CategoryTag? Function()? tag,
    Category? Function()? category,
    CreditAccount? Function()? account,
    int? Function()? installmentPeriod,
  }) {
    return CreditSpendingFormState._(
      dateTime: dateTime != null ? dateTime()! : this.dateTime,
      amount: amount != null ? amount() : this.amount,
      note: note != null ? note() : this.note,
      tag: tag != null ? tag() : this.tag,
      category: category != null ? category() : this.category,
      account: account != null ? account() : this.account,
      installmentPeriod: installmentPeriod != null ? installmentPeriod() : this.installmentPeriod,
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

  void changeCreditAccount(CreditAccount? account) {
    state = state.copyWith(account: () => account);
  }

  void changeInstallmentPeriod(int? period) {
    state = state.copyWith(installmentPeriod: () => period);
  }

  void changeNote(String note) {
    state = state.copyWith(note: () => note);
  }
}

final regularTransactionFormNotifierProvider =
    AutoDisposeNotifierProvider<CreditSpendingFormController, CreditSpendingFormState>(() {
  return CreditSpendingFormController();
});
