import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../calculator_input/presentation/calculator_input.dart';
import '../../../common_widgets/modal_screen_components.dart';

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
  String apr = '';

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
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Account',
        isWrapByCard: false,
        sections: [
          Row(
            children: [
              const CurrencyIcon(),
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.greyBorder(context)),
              ),
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  InlineTextFormField(
                    prefixText: 'Statement date:',
                    width: 30,
                    maxLength: 2,
                    validator: (_) => _dateInputValidator(statementDay),
                    onChanged: (value) => statementDay = value,
                  ),
                  Gap.h8,
                  InlineTextFormField(
                    prefixText: 'Payment due date :',
                    width: 30,
                    maxLength: 2,
                    validator: (_) => _dateInputValidator(paymentDueDay),
                    onChanged: (value) => paymentDueDay = value,
                  ),
                  Gap.h8,
                  InlineTextFormField(
                    prefixText: 'APR:',
                    width: 60,
                    suffixText: '%',
                    suffixWidget: HelpButton(
                      title: 'APR (Annual Percentage Rate)',
                      text: 'APR'.hardcoded,
                      yOffset: 4,
                    ),
                    validator: (_) => _formatToDouble(apr) == null ? '' : null,
                    onChanged: (value) => apr = value,
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
                    apr: _formatToDouble(apr),
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
