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
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../calculator_input/presentation/calculator_input.dart';
import '../../../common_widgets/modal_screen_components.dart';

class AddAccountModalScreen extends ConsumerStatefulWidget {
  const AddAccountModalScreen(this.controller, this.isScrollable, {super.key});

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<AddAccountModalScreen> createState() => _AddAccountModalScreenState();
}

class _AddAccountModalScreenState extends ConsumerState<AddAccountModalScreen> {
  final _formKey = GlobalKey<FormState>();

  String accountName = '';
  String iconCategory = '';
  int iconIndex = 0;
  int colorIndex = 0;

  AccountType accountType = AccountType.regular;
  StatementType statementType = StatementType.withAverageDailyBalance;

  String calculatorOutput = '0';

  int statementDay = 1;
  int paymentDueDay = 15;
  String apr = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // By validating, the _formatToDouble(calculatorOutput) must not null
      final accountRepository = ref.read(accountRepositoryProvider);

      accountRepository.writeNew(
        CalService.formatToDouble(calculatorOutput)!,
        type: accountType,
        iconCategory: iconCategory,
        iconIndex: iconIndex,
        name: accountName,
        colorIndex: colorIndex,
        statementDay: statementDay,
        paymentDueDay: paymentDueDay,
        statementType: statementType,
        apr: CalService.formatToDouble(apr),
      );
      context.pop();
    }
  }

  String _dateBuilder(DateTime? dateTime) {
    if (dateTime == null) {
      return '--';
    }

    String suffix = 'th';

    if (dateTime.day.toString().endsWith('1')) {
      suffix = 'st';
    } else if (dateTime.day.toString().endsWith('2')) {
      suffix = 'nd';
    } else if (dateTime.day.toString().endsWith('3')) {
      suffix = 'rd';
    }

    return '${dateTime.day.toString()}$suffix';
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Add Account'.hardcoded,
      ),
      body: [
        Row(
          children: [
            const CurrencyIcon(),
            Gap.w16,
            Expanded(
              child: CalculatorInput(
                hintText: accountType == AccountType.regular ? 'Initial Balance' : 'Credit limit',
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                validator: (_) {
                  if (CalService.formatToDouble(calculatorOutput) == null) {
                    return 'Invalid amount';
                  }
                  return null;
                },
                formattedResultOutput: (value) {
                  calculatorOutput = value;
                },
              ),
            ),
          ],
        ),
        Gap.h16,
        CustomSliderToggle<AccountType>(
          values: const [AccountType.regular, AccountType.credit],
          labels: const ['Regular', 'Credit'],
          height: 42,
          onTap: (type) {
            setState(() {
              accountType = type;
            });
          },
        ),
        Gap.h16,
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[colorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[colorIndex][1],
              onTap: (iconC, iconI) {
                iconCategory = iconC;
                iconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                maxLines: 1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Account name must not empty';
                  }
                  return null;
                },
                hintText: 'Account Name',
                onChanged: (value) {
                  setState(() {
                    accountName = value;
                  });
                },
              ),
            ),
          ],
        ),
        Gap.h16,
        ColorSelectListView(
          onColorTap: (index) {
            setState(() {
              colorIndex = index;
            });
          },
        ),
        Gap.h8,
        HideableContainer(
          hide: accountType != AccountType.credit,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder(context)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Credit preferences:',
                    style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Statement day:',
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                    DateSelector(
                      initial: DateTime.now().copyWith(day: statementDay),
                      onChanged: (dateTime) {
                        setState(() {
                          statementDay = dateTime.day;
                        });
                      },
                      labelBuilder: (dateTime) {
                        return '${_dateBuilder(dateTime)} of this month';
                      },
                    ),
                  ],
                ),
                Gap.h8,
                Gap.h4,
                Row(
                  children: [
                    Text(
                      'Payment due day:',
                      style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground),
                    ),
                    DateSelector(
                      initial: DateTime.now().copyWith(day: paymentDueDay),
                      onChanged: (dateTime) {
                        paymentDueDay = dateTime.day;
                      },
                      labelBuilder: (dateTime) {
                        return '${_dateBuilder(dateTime)} of next month';
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
                      CalService.formatToDouble(apr) == null && accountType == AccountType.credit ? '' : null,
                  onChanged: (value) => apr = value,
                ),
              ],
            ),
          ),
        ),
        Gap.h8,
        HideableContainer(
          hide: accountType != AccountType.credit,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greyBorder(context)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    'Payment & Interest preferences:',
                    style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                  ),
                ),
                CustomRadio<StatementType>(
                  label: 'Using Average Daily Balance'.hardcoded,
                  subLabel: 'Can make payment in billing cycle, interest is calculated by ADB method'.hardcoded,
                  value: StatementType.withAverageDailyBalance,
                  groupValue: statementType,
                  onChanged: (value) => setState(() {
                    statementType = value!;
                  }),
                ),
                CustomRadio<StatementType>(
                  label: 'Payment only in grace period',
                  subLabel: 'Can not make payment in billing cycle, interest is calculated by other method.'.hardcoded,
                  value: StatementType.payOnlyInGracePeriod,
                  groupValue: statementType,
                  onChanged: (value) => setState(() {
                    statementType = value!;
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
      footer: ModalFooter(
        isBigButtonDisabled: accountName.isEmpty || CalService.formatToDouble(calculatorOutput) == null,
        onBigButtonTap: _submit,
      ),
    );
  }
}
