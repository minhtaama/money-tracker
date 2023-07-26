import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'dart:math' as math;
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_isar.dart';
import '../../../category/domain/category_isar.dart';
import 'account_selector.dart';
import 'category_selector.dart';

class CategoryFormSelector extends FormField<CategoryIsar> {
  CategoryFormSelector(
      {super.key,
      required TransactionType transactionType,
      required ValueChanged<CategoryIsar> onChangedCategory,
      FormFieldSetter<CategoryIsar>? onSaved,
      FormFieldValidator<CategoryIsar>? validator,
      CategoryIsar? initialValue,
      AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<CategoryIsar> state) {
              return Stack(
                children: [
                  CategorySelector(
                      transactionType: transactionType,
                      onChangedCategory: (newCategory) {
                        state.didChange(newCategory);
                        onChangedCategory(newCategory);
                      }),
                  state.errorText != null
                      ? const AlertBox(offset: Offset(90, -33), errorText: '!')
                      : Gap.noGap,
                ],
              );
            });
}

class AccountFormSelector extends FormField<AccountIsar> {
  AccountFormSelector({
    super.key,
    required TransactionType transactionType,
    required ValueChanged<AccountIsar> onChangedAccount,
    FormFieldSetter<AccountIsar>? onSaved,
    FormFieldValidator<AccountIsar>? validator,
    AccountIsar? initialValue,
    AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<AccountIsar> state) {
              return Stack(
                children: [
                  AccountSelector(
                      transactionType: transactionType,
                      onChangedAccount: (newAccount) {
                        state.didChange(newAccount);
                        onChangedAccount(newAccount);
                      }),
                  state.errorText != null
                      ? AlertBox(offset: const Offset(80, -33), errorText: state.errorText!)
                      : Gap.noGap,
                ],
              );
            });
}

class AlertBox extends StatelessWidget {
  const AlertBox({
    super.key,
    this.offset,
    this.size = 25,
    required this.errorText,
  });

  final Offset? offset;
  final double size;
  final String errorText;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset ?? const Offset(0, 0),
      child: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()
              ..translate(size / 8 * 3, size / 8 * 7)
              ..rotateZ(math.pi / 4),
            origin: Offset(size / 8, size / 8),
            child: Container(
              padding: const EdgeInsets.all(2),
              width: size / 4,
              height: size / 4,
              decoration: BoxDecoration(
                color: context.appTheme.negative,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: context.appTheme.negative,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FittedBox(
              child: Text(
                errorText,
                style: kHeader2TextStyle.copyWith(color: context.appTheme.onNegative),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
