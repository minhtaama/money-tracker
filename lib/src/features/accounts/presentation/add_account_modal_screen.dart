import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../calculator_input/presentation/calculator_input.dart';

class AddAccountModalScreen extends ConsumerStatefulWidget {
  const AddAccountModalScreen({Key? key}) : super(key: key);

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
  String calculatorOutput = '0';

  String statementDay = '';
  String paymentDueDay = '';
  String interestRate = '';

  double? _formatToDouble(String formattedValue) {
    try {
      double value = double.parse(formattedValue.split(',').join());
      if (value == double.infinity || value == double.negativeInfinity) {
        return null;
      } else {
        return value;
      }
    } catch (e) {
      return null;
    }
  }

  String? _dateInputValidator(String date, {String error = ''}) {
    final dateParsed = int.tryParse(date);
    if (dateParsed != null) {
      if (dateParsed > 0 && dateParsed < 31) {
        return null;
      } else {
        return error;
      }
    } else {
      return error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsObject = ref.watch(settingsControllerProvider);

    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Account',
        isWrapByCard: false,
        children: [
          Row(
            children: [
              CardItem(
                height: 50,
                width: 50,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: EdgeInsets.zero,
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(1000),
                child: FittedBox(
                  child: Text(
                    settingsObject.currency.symbol ?? settingsObject.currency.code,
                    style: kHeader1TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative,
                    ),
                  ),
                ),
              ),
              Gap.w16,
              Expanded(
                child: CalculatorInput(
                  hintText: accountType == AccountType.regular ? 'Initial Balance' : 'Credit balance',
                  focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                  validator: (_) {
                    if (_formatToDouble(calculatorOutput) == null) {
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
          Gap.h8,
          ColorSelectListView(
            onColorTap: (index) {
              setState(() {
                colorIndex = index;
              });
            },
          ),
          HideableContainer(
            hidden: accountType != AccountType.credit,
            child: CardItem(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InlineTextFormField(
                    prefixText: 'Statement date:',
                    suffixText: 'of this month',
                    validator: (_) => _dateInputValidator(statementDay),
                    onChanged: (value) => statementDay = value,
                  ),
                  Gap.h8,
                  InlineTextFormField(
                    prefixText: 'Payment date :',
                    suffixText: 'of next month',
                    validator: (_) => _dateInputValidator(paymentDueDay),
                    onChanged: (value) => paymentDueDay = value,
                  ),
                  Gap.h8,
                  InlineTextFormField(
                    prefixText: 'Interest rate:',
                    suffixText: '%',
                    validator: (_) => _formatToDouble(interestRate) == null ? '' : null,
                    onChanged: (value) => interestRate = value,
                  ),
                ],
              ),
            ),
          ),
          Gap.h24,
          Align(
            alignment: Alignment.centerRight,
            child: IconWithTextButton(
              iconPath: AppIcons.add,
              label: 'Create',
              backgroundColor: context.appTheme.accent,
              isDisabled: accountName.isEmpty || _formatToDouble(calculatorOutput) == null,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // By validating, the _formatToDouble(calculatorOutput) must not null
                  final accountRepository = ref.read(accountRepositoryProvider);

                  accountRepository.writeNew(
                    _formatToDouble(calculatorOutput)!,
                    type: accountType,
                    iconCategory: iconCategory,
                    iconIndex: iconIndex,
                    name: accountName,
                    colorIndex: colorIndex,
                    statementDay: int.tryParse(statementDay),
                    paymentDueDay: int.tryParse(paymentDueDay),
                    interestRate: _formatToDouble(interestRate),
                  );
                  context.pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
