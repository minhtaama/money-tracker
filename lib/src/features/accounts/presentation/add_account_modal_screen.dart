import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_radio.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/custom_box.dart';
import '../../../theme_and_ui/icons.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../../common_widgets/modal_screen_components.dart';
import '../domain/account_base.dart';

class AddAccountModalScreen extends ConsumerStatefulWidget {
  const AddAccountModalScreen(this.controller, this.isScrollable, {super.key, this.initialType});

  final ScrollController controller;
  final bool isScrollable;
  final AccountType? initialType;

  @override
  ConsumerState<AddAccountModalScreen> createState() => _AddAccountModalScreenState();
}

class _AddAccountModalScreenState extends ConsumerState<AddAccountModalScreen> {
  final _formKey = GlobalKey<FormState>();

  String _accountName = '';
  String _iconCategory = '';
  int _iconIndex = 0;
  int _colorIndex = 0;

  late AccountType _accountType = widget.initialType ?? AccountType.regular;

  String _calculatorOutput = '0';

  StatementType _statementType = StatementType.withAverageDailyBalance;
  int _statementDay = 1;
  int _paymentDueDay = 15;
  String _apr = '';

  DateTime? _targetSavingDate;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // By validating, the _formatToDouble(calculatorOutput) must not null
      final accountRepository = ref.read(accountRepositoryProvider);

      Account account;

      if (_accountType == AccountType.regular) {
        account = accountRepository.writeNewRegularAccount(
          CalService.formatToDouble(_calculatorOutput)!,
          iconCategory: _iconCategory,
          iconIndex: _iconIndex,
          name: _accountName,
          colorIndex: _colorIndex,
        );
      } else if (_accountType == AccountType.credit) {
        account = accountRepository.writeNewCreditAccount(
          CalService.formatToDouble(_calculatorOutput)!,
          iconCategory: _iconCategory,
          iconIndex: _iconIndex,
          name: _accountName,
          colorIndex: _colorIndex,
          statementDay: _statementDay,
          paymentDueDay: _paymentDueDay,
          statementType: _statementType,
          apr: CalService.formatToDouble(_apr)!,
        );
      } else if (_accountType == AccountType.saving) {
        account = accountRepository.writeNewSavingAccount(
          CalService.formatToDouble(_calculatorOutput)!,
          iconCategory: _iconCategory,
          iconIndex: _iconIndex,
          name: _accountName,
          colorIndex: _colorIndex,
          targetDate: _targetSavingDate,
        );
      } else {
        throw StateError('_accountType is not available');
      }

      context.pop(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: context.loc.addAccount,
      ),
      body: [
        CustomSliderToggle<AccountType>(
          initialValueIndex: widget.initialType == AccountType.regular
              ? 0
              : widget.initialType == AccountType.credit
                  ? 1
                  : 0,
          values: const [AccountType.regular, AccountType.credit, AccountType.saving],
          iconPaths: [AppIcons.walletLight, AppIcons.creditLight, AppIcons.savingsLight],
          labels: [context.loc.regularAdj, context.loc.creditAdj, context.loc.savingAdj],
          height: 42,
          onTap: (type) {
            setState(() {
              _accountType = type;
            });
          },
        ),
        Gap.h24,
        Row(
          children: [
            const CurrencyIcon(),
            Gap.w16,
            Expanded(
              child: CalculatorInput(
                title: _accountType == AccountType.regular
                    ? context.loc.initialBalance
                    : _accountType == AccountType.credit
                        ? context.loc.creditLimit
                        : context.loc.savingTarget,
                hintText: _accountType == AccountType.regular
                    ? context.loc.initialBalance
                    : _accountType == AccountType.credit
                        ? context.loc.creditLimit
                        : context.loc.savingTarget,
                focusColor: AppColors.allColorsUserCanPick[_colorIndex][0],
                validator: (_) {
                  if (CalService.formatToDouble(_calculatorOutput) == null) {
                    return context.loc.invalidAmount;
                  }

                  if (_accountType == AccountType.saving && CalService.formatToDouble(_calculatorOutput)! <= 0) {
                    return context.loc.savingMustHigherThan0;
                  }

                  return null;
                },
                formattedResultOutput: (value) {
                  _calculatorOutput = value;
                },
              ),
            ),
          ],
        ),
        Gap.h16,
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[_colorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[_colorIndex][1],
              onTap: (iconC, iconI) {
                _iconCategory = iconC;
                _iconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[_colorIndex][0],
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return _accountType == AccountType.saving
                        ? 'Target name must not empty'
                        : 'Account name must not empty';
                  }
                  return null;
                },
                hintText: _accountType == AccountType.saving ? 'Saving purpose' : 'Account name',
                onChanged: (value) {
                  setState(() {
                    _accountName = value;
                  });
                },
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        Gap.h12,
        ColorSelectListView(
          onColorTap: (index) {
            setState(() {
              _colorIndex = index;
            });
          },
        ),
        Gap.h8,
        HideableContainer(
          hide: _accountType != AccountType.credit,
          child: Column(
            children: [
              CustomBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: TextHeader(
                        'Credit preferences:',
                        opacity: 1,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${context.loc.statementDate}:",
                          style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                        ),
                        DateSelector(
                          initial: DateTime.now().copyWith(day: _statementDay),
                          onChanged: (dateTime) {
                            setState(() {
                              _statementDay = dateTime.day;
                            });
                          },
                          labelBuilder: (dateTime) {
                            return '${context.loc.dateOrdinal(dateTime!.day.toString())} ${context.loc.ofThisMonth}';
                          },
                        ),
                      ],
                    ),
                    Gap.h8,
                    Gap.h4,
                    Row(
                      children: [
                        Text(
                          "${context.loc.paymentDueDate}:",
                          style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                        ),
                        DateSelector(
                          initial: DateTime.now().copyWith(day: _paymentDueDay),
                          onChanged: (dateTime) {
                            _paymentDueDay = dateTime.day;
                          },
                          labelBuilder: (dateTime) {
                            return '${context.loc.dateOrdinal(dateTime!.day.toString())} ${context.loc.ofNextMonth}';
                          },
                        ),
                      ],
                    ),
                    Gap.h8,
                    InlineTextFormField(
                      prefixText: 'Account APR:',
                      width: 60,
                      suffixText: '%',
                      suffixWidget: HelpButton(
                        title: 'APR (Annual Percentage Rate)',
                        text: 'APR'.hardcoded,
                        yOffset: 4,
                      ),
                      maxLength: 5,
                      validator: (_) =>
                          CalService.formatToDouble(_apr) == null && _accountType == AccountType.credit ? '' : null,
                      onChanged: (value) => _apr = value,
                    ),
                  ],
                ),
              ),
              Gap.h8,
              CustomBox(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 8.0),
                      child: TextHeader(
                        'Payment & Interest preferences:',
                        opacity: 1,
                      ),
                    ),
                    CustomRadio<StatementType>(
                      label: 'Using Average Daily Balance'.hardcoded,
                      subLabel: 'Can make payment in billing cycle, interest is calculated by ADB method'.hardcoded,
                      value: StatementType.withAverageDailyBalance,
                      groupValue: _statementType,
                      onChanged: (value) => setState(() {
                        _statementType = value!;
                      }),
                    ),
                    CustomRadio<StatementType>(
                      label: 'Payment only in grace period',
                      subLabel:
                          'Can not make payment in billing cycle, interest is calculated by other method.'.hardcoded,
                      value: StatementType.payOnlyInGracePeriod,
                      groupValue: _statementType,
                      onChanged: (value) => setState(() {
                        _statementType = value!;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        HideableContainer(
          hide: _accountType != AccountType.saving,
          child: CustomBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: TextHeader(
                    'Saving preferences:',
                    opacity: 1,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Target date:',
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                    DateSelector(
                      initial: _targetSavingDate,
                      selectableDayPredicate: (date) => date.isAfter(DateTime.now()),
                      onChangedNullable: (dateTime) {
                        setState(() {
                          _targetSavingDate = dateTime;
                        });
                      },
                      labelBuilder: (dateTime) {
                        return dateTime != null ? 'Until ${dateTime.toShortDate(context)}' : 'No target date';
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: _accountName.isEmpty || CalService.formatToDouble(_calculatorOutput) == null,
        onBigButtonTap: _submit,
      ),
    );
  }
}
