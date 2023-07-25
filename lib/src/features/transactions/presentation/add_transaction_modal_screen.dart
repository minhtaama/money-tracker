import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/account_selector.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/category_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../calculator_input/presentation/calculator_input.dart';

class AddTransactionModalScreen extends ConsumerStatefulWidget {
  const AddTransactionModalScreen(this.transactionType, {Key? key}) : super(key: key);
  final TransactionType transactionType;

  @override
  ConsumerState<AddTransactionModalScreen> createState() => _AddTransactionModalScreenState();
}

class _AddTransactionModalScreenState extends ConsumerState<AddTransactionModalScreen> {
  final _formKey = GlobalKey<FormState>();

  AccountType accountType = AccountType.onHand;
  String accountName = '';
  String iconCategory = '';
  int iconIndex = 0;
  int colorIndex = 0;
  String calculatorOutput = '0';

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

  @override
  Widget build(BuildContext context) {
    final settingsObject = ref.watch(settingsControllerProvider);

    return Form(
      key: _formKey,
      child: CustomSection(
        title: widget.transactionType == TransactionType.income
            ? 'Add Income'
            : widget.transactionType == TransactionType.expense
                ? 'Add Expense'
                : 'Transfer between accounts',
        crossAxisAlignment: CrossAxisAlignment.start,
        isWrapByCard: false,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  hintText: 'Amount',
                  focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                  validator: (_) {
                    if (_formatToDouble(calculatorOutput) == null) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  formattedResultOutput: (value) {
                    calculatorOutput = value;
                    _formKey.currentState!.validate();
                  },
                ),
              ),
            ],
          ),
          Gap.h16,
          widget.transactionType != TransactionType.transfer
              ? CategorySelector(
                  transactionType: widget.transactionType, onChangedCategory: (newCategory) {})
              : Gap.noGap,
          Gap.h8,
          AccountSelector(transactionType: widget.transactionType, onChangedAccount: (newAccount) {}),
          Gap.h16,
          CustomTextFormField(
            autofocus: false,
            focusColor: context.appTheme.accent,
            isMultiLine: true,
            hintText: 'Note...',
            onChanged: (value) {
              setState(() {
                accountName = value;
              });
            },
          ),
          Gap.h8,
          Align(
            alignment: Alignment.centerRight,
            child: IconWithTextButton(
              iconPath: AppIcons.add,
              label: 'Add',
              backgroundColor: context.appTheme.accent,
              isDisabled: _formatToDouble(calculatorOutput) == null,
              onTap: () {
                if (_formKey.currentState!.validate()) {
                  // By validating, the _formatToDouble(calculatorOutput) must not null
                  // final accountRepository = ref.read(accountRepositoryProvider);
                  // accountRepository.writeNew(_formatToDouble(calculatorOutput)!,
                  //     type: accountType,
                  //     iconCategory: iconCategory,
                  //     iconIndex: iconIndex,
                  //     name: accountName,
                  //     colorIndex: colorIndex);
                  //TODO: Add transaction
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
