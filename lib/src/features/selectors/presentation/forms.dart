import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'dart:math' as math;
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../accounts/domain/statement/base_class/statement.dart';
import '../../category/domain/category.dart';
import 'account_selector.dart';
import 'category_selector.dart';

class CategoryFormSelector extends FormField<Category> {
  CategoryFormSelector(
      {super.key,
      required TransactionType transactionType,
      required ValueChanged<Category?> onChangedCategory,
      super.onSaved,
      super.validator,
      super.initialValue,
      super.autovalidateMode = AutovalidateMode.onUserInteraction})
      : super(builder: (FormFieldState<Category> state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CategorySelector(
                  transactionType: transactionType,
                  initialValue: initialValue,
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
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(builder: (FormFieldState<Account> state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              AccountSelector(
                  accountType: accountType,
                  initialValue: initialValue,
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
    required Function(DateTime?, Statement?) onChanged,
    super.onSaved,
    super.validator,
    DateTime? initialDate,
    bool isForPayment = false,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    String? disableText,
  }) : super(
            initialValue: initialDate,
            builder: (FormFieldState<DateTime?> state) {
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.passthrough,
                children: [
                  DateTimeSelectorCredit(
                    creditAccount: creditAccount,
                    disableText: disableText,
                    initialDate: initialDate,
                    isForPayment: isForPayment,
                    onChanged: (newDateTime, newStatement) {
                      state.didChange(newDateTime);
                      onChanged(newDateTime, newStatement);
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
      child: Container(
        key: _key,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minWidth: 30, maxWidth: 80),
        decoration: BoxDecoration(
          color: context.appTheme.negative,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Transform(
              transform: Matrix4.identity()
                ..translate(_width / 2 - 12, _height - 7 - 8)
                ..rotateZ(math.pi / 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: context.appTheme.negative,
                ),
              ),
            ),
            Text(
              widget.errorText,
              style: widget.errorText.length == 1
                  ? kHeader2TextStyle.copyWith(color: context.appTheme.onNegative, fontSize: 17)
                  : kNormalTextStyle.copyWith(color: context.appTheme.onNegative, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
