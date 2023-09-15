import 'package:flutter/cupertino.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'dart:math' as math;
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../accounts/domain/account.dart';
import '../../../category/domain/category.dart';
import 'account_selector.dart';
import 'category_selector.dart';

class CategoryFormSelector extends FormField<Category> {
  CategoryFormSelector(
      {super.key,
      required TransactionType transactionType,
      required ValueChanged<Category?> onChangedCategory,
      FormFieldSetter<Category>? onSaved,
      FormFieldValidator<Category>? validator,
      Category? initialValue,
      AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction})
      : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<Category> state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CategorySelector(
                      transactionType: transactionType,
                      onChangedCategory: (newCategory) {
                        state.didChange(newCategory);
                        onChangedCategory(newCategory);
                      }),
                  AnimatedOpacity(
                    opacity: state.errorText != null ? 1 : 0,
                    duration: k250msDuration,
                    child: state.errorText != null
                        ? _AlertBox(
                            errorText: state.errorText!,
                            yOffset: -35,
                          )
                        : Gap.noGap,
                  ),
                  // state.errorText != null
                  //     ? const AlertBox(offset: Offset(90, -33), errorText: '!')
                  //     : Gap.noGap,
                ],
              );
            });
}

class AccountFormSelector extends FormField<Account> {
  AccountFormSelector({
    super.key,
    required AccountType accountType,
    required ValueChanged<Account?> onChangedAccount,
    Account? otherSelectedAccount,
    FormFieldSetter<Account>? onSaved,
    FormFieldValidator<Account>? validator,
    Account? initialValue,
    AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialValue,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<Account> state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AccountSelector(
                      accountType: accountType,
                      otherSelectedAccount: otherSelectedAccount,
                      onChangedAccount: (newAccount) {
                        state.didChange(newAccount);
                        onChangedAccount(newAccount);
                      }),
                  AnimatedOpacity(
                    opacity: state.errorText != null ? 1 : 0,
                    duration: k250msDuration,
                    child: state.errorText != null
                        ? _AlertBox(
                            errorText: state.errorText!,
                            yOffset: -35,
                          )
                        : Gap.noGap,
                  ),
                ],
              );
            });
}

class CreditDateTimeFormSelector extends FormField<DateTime?> {
  CreditDateTimeFormSelector({
    super.key,
    CreditAccount? creditAccount,
    required ValueChanged<DateTime?> onChanged,
    FormFieldSetter<DateTime>? onSaved,
    FormFieldValidator<DateTime>? validator,
    DateTime? initialDate,
    AutovalidateMode? autovalidateMode = AutovalidateMode.onUserInteraction,
    String? disableText,
  }) : super(
            onSaved: onSaved,
            validator: validator,
            initialValue: initialDate,
            autovalidateMode: autovalidateMode,
            builder: (FormFieldState<DateTime?> state) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CreditDateTimeSelector(
                    creditAccount: creditAccount,
                    disableText: disableText,
                    onChanged: (newDateTime) {
                      state.didChange(newDateTime);
                      onChanged(newDateTime);
                    },
                  ),
                  AnimatedOpacity(
                    opacity: state.errorText != null ? 1 : 0,
                    duration: k250msDuration,
                    child: state.errorText != null
                        ? _AlertBox(
                            errorText: state.errorText!,
                            yOffset: -4,
                          )
                        : Gap.noGap,
                  ),
                ],
              );
            });
}

class _AlertBox extends StatefulWidget {
  const _AlertBox({
    required this.errorText,
    this.yOffset = 0,
  });

  final String errorText;
  final double yOffset;

  @override
  State<_AlertBox> createState() => _AlertBoxState();
}

class _AlertBoxState extends State<_AlertBox> {
  final _key = GlobalKey();
  double _width = 0;
  double _height = 0;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _width = _key.currentContext!.size!.width;
        _height = _key.currentContext!.size!.height;
      });
    });

    return Transform.translate(
      offset: Offset(0, -_height / 2 + widget.yOffset),
      child: Stack(
        children: [
          Transform(
            transform: Matrix4.identity()
              ..translate(_width / 2, _height - 7)
              ..rotateZ(math.pi / 4),
            //origin: const Offset(5, 5),
            child: Container(
              padding: const EdgeInsets.all(2),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: context.appTheme.negative,
              ),
            ),
          ),
          Container(
            key: _key,
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(minWidth: 30, maxWidth: 80),
            decoration: BoxDecoration(
              color: context.appTheme.negative,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.errorText,
              style: widget.errorText.length == 1
                  ? kHeader2TextStyle.copyWith(color: context.appTheme.onNegative, fontSize: 17)
                  : kHeader4TextStyle.copyWith(color: context.appTheme.onNegative, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
