import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'dart:math' as math;
import '../../../common_widgets/hideable_container.dart';
import '../../../utils/constants.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';
import '../../accounts/domain/statement/base_class/statement.dart';
import '../../category/domain/category.dart';
import 'account_selector.dart';
import 'amount_selector.dart';
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategorySelector(
                transactionType: transactionType,
                initialValue: initialValue,
                onChangedCategory: (newCategory) {
                  state.didChange(newCategory);
                  onChangedCategory(newCategory);
                },
              ),
              _Alert(
                errorText: state.errorText,
              ),
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
    bool withSavingAccount = false,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(builder: (FormFieldState<Account> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountSelector(
                accountType: accountType,
                initialValue: initialValue,
                otherSelectedAccount: otherSelectedAccount,
                withSavingAccount: withSavingAccount,
                onChangedAccount: (newAccount) {
                  state.didChange(newAccount);
                  onChangedAccount(newAccount);
                },
              ),
              _Alert(
                errorText: state.errorText,
              ),
            ],
          );
        });
}

class AmountFormSelector extends FormField<double> {
  AmountFormSelector({
    super.key,
    required TransactionType transactionType,
    required ValueChanged<double> onChangedAmount,
    super.onSaved,
    super.validator,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    bool isCentered = true,
    Widget? suffix,
    String? prefix,
  }) : super(
          builder: (FormFieldState<double> state) {
            return AmountSelector(
              transactionType: transactionType,
              initialValue: initialValue,
              isCentered: isCentered,
              suffix: suffix,
              prefix: prefix,
              errorText: state.errorText,
              onChanged: (newAmount) {
                state.didChange(newAmount);
                onChangedAmount(newAmount);
              },
            );
          },
        );
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
                  _AlertBox(
                    triggerShowingAlertBox: state.errorText != null,
                  ),
                ],
              );
            });
}

class _Alert extends StatelessWidget {
  const _Alert({super.key, required this.errorText});

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return HideableContainer(
      hide: errorText == null,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: RichText(
          text: TextSpan(
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SvgIcon(
                    AppIcons.warningBulk,
                    color: context.appTheme.negative,
                    size: 18,
                  ),
                ),
              ),
              TextSpan(
                text: errorText ?? '',
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.negative,
                  fontSize: 13,
                  height: 1,
                ),
              )
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          softWrap: true,
        ),
      ),
    );
  }
}

class _AlertBox extends StatelessWidget {
  const _AlertBox({
    required this.triggerShowingAlertBox,
    this.yOffset = 0,
  });

  final bool triggerShowingAlertBox;
  final double yOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: triggerShowingAlertBox ? 1 : 0,
      duration: k250msDuration,
      child: Transform.translate(
        offset: Offset(0, -40 / 2 + yOffset),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              height: 40,
              width: 40,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: context.appTheme.negative,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SvgIcon(
                AppIcons.warningBulk,
                color: context.appTheme.onNegative,
                size: 20,
              ),
            ),
            Transform(
              transform: Matrix4.identity()
                ..translate(5.0, -8)
                ..rotateZ(math.pi / 4),
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: context.appTheme.negative,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
