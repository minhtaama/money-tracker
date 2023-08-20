import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/forms/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../category/domain/category_isar.dart';
import 'forms/forms.dart';

class AddCreditTransactionModalScreen extends ConsumerStatefulWidget {
  const AddCreditTransactionModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditTransactionModalScreen> createState() => _AddCreditTransactionModalScreenState();
}

class _AddCreditTransactionModalScreenState extends ConsumerState<AddCreditTransactionModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime dateTime = DateTime.now();
  String calculatorOutput = '0';
  String? note;
  CategoryTagIsar? tag;
  CategoryIsar? category;
  AccountIsar? account;

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
        title: 'Add Credit Transaction',
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
                  hintText: 'Credit Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) {
                    if (_formatToDouble(calculatorOutput) == null || _formatToDouble(calculatorOutput) == 0) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  formattedResultOutput: (value) {
                    setState(() {
                      calculatorOutput = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Gap.h16,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: DateTimeSelector(
                      onChanged: (DateTime value) {
                        dateTime = value;
                      },
                    ),
                  ),
                ),
              ),
              Gap.w24,
              Expanded(
                flex: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense Category:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    CategoryFormSelector(
                        transactionType: TransactionType.expense,
                        validator: (_) {
                          if (category == null) {
                            return '!';
                          }
                          return null;
                        },
                        onChangedCategory: (newCategory) {
                          setState(() {
                            category = newCategory;
                          });
                        }),
                    Gap.h16,
                    Text(
                      'Credit Account:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.credit,
                      validator: (_) {
                        if (account == null) {
                          return '!';
                        }
                        return null;
                      },
                      onChangedAccount: (newAccount) {
                        setState(() {
                          account = newAccount;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h8,
          CustomCheckbox(
            label: 'Installment payment',
            onChanged: (value) => print(value),
            optionalWidget: Text(
              'e',
            ),
          ),
          Gap.h8,
          CategoryTagSelector(
              category: category,
              onTagSelected: (value) {
                tag = value;
              }),
          Gap.h16,
          CustomTextFormField(
            autofocus: false,
            focusColor: context.appTheme.accent,
            withOutlineBorder: true,
            maxLines: 3,
            hintText: 'Note ...',
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              note = value;
            },
          ),
          Gap.h16,
          Row(
            children: [
              RoundedIconButton(
                iconPath: AppIcons.back,
                backgroundColor: AppColors.darkerGrey,
                iconColor: context.appTheme.backgroundNegative,
                size: 55,
                onTap: () => context.pop(),
              ),
              const Spacer(),
              IconWithTextButton(
                iconPath: AppIcons.add,
                label: 'Add',
                backgroundColor: context.appTheme.accent,
                isDisabled: _formatToDouble(calculatorOutput) == null ||
                    _formatToDouble(calculatorOutput) == 0 ||
                    category == null ||
                    account == null,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // By validating, the _formatToDouble(calculatorOutput) must not null
                    // final transactionRepository = ref.read(transactionRepositoryProvider);
                    // transactionRepository.writeNew(
                    //   type,
                    //   dateTime: dateTime,
                    //   amount: _formatToDouble(calculatorOutput)!,
                    //   tag: tag,
                    //   note: note,
                    //   category: category,
                    //   account: account!,
                    //   toAccount: toAccount,
                    // );
                    context.pop();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
