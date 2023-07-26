import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/forms/account_selector.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/forms/category_selector.dart';
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

class AddTransactionModalScreen extends ConsumerStatefulWidget {
  const AddTransactionModalScreen(this.transactionType, {Key? key}) : super(key: key);
  final TransactionType transactionType;

  @override
  ConsumerState<AddTransactionModalScreen> createState() => _AddTransactionModalScreenState();
}

class _AddTransactionModalScreenState extends ConsumerState<AddTransactionModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TransactionType type = widget.transactionType;
  late DateTime dateTime = DateTime.now();
  String calculatorOutput = '0';
  String? note;
  CategoryIsar? category;
  AccountIsar? account;
  AccountIsar? toAccount;

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
                  focusColor: context.appTheme.primary,
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
              Gap.w16,
              Expanded(
                flex: 13,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.transactionType != TransactionType.transfer ? 'Category:' : 'From:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    widget.transactionType != TransactionType.transfer
                        ? CategoryFormSelector(
                            transactionType: widget.transactionType,
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
                            })
                        : AccountFormSelector(
                            transactionType: widget.transactionType,
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
                            }),
                    Gap.h16,
                    Text(
                      widget.transactionType != TransactionType.transfer ? 'Account:' : 'To:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    AccountFormSelector(
                        transactionType: widget.transactionType,
                        validator: (_) {
                          if (widget.transactionType != TransactionType.transfer && account == null) {
                            return '!';
                          }
                          if (widget.transactionType == TransactionType.transfer && toAccount == null) {
                            return '!';
                          }
                          return null;
                        },
                        onChangedAccount: (newAccount) {
                          if (widget.transactionType != TransactionType.transfer) {
                            setState(() {
                              account = newAccount;
                            });
                          } else {
                            setState(() {
                              toAccount = newAccount;
                            });
                          }
                        }),
                  ],
                ),
              ),
            ],
          ),
          Gap.h16,
          CustomTextFormField(
            autofocus: false,
            focusColor: context.appTheme.accent,
            isMultiLine: true,
            hintText: 'Note...',
            onChanged: (value) {
              note = value;
              print(note);
            },
          ),
          Gap.h16,
          Row(
            children: [
              RoundedIconButton(
                iconPath: AppIcons.back,
                backgroundColor: AppColors.darkerGrey,
                size: 55,
                onTap: () => context.pop(),
              ),
              const Spacer(),
              IconWithTextButton(
                iconPath: AppIcons.add,
                label: 'Add',
                backgroundColor: context.appTheme.accent,
                isDisabled:
                    _formatToDouble(calculatorOutput) == null || category == null || account == null,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // By validating, the _formatToDouble(calculatorOutput) must not null
                    final transactionRepository = ref.read(transactionRepositoryProvider);
                    transactionRepository.writeNew(
                      type,
                      dateTime: dateTime,
                      amount: _formatToDouble(calculatorOutput)!,
                      note: note,
                      category: category!,
                      account: account!,
                      toAccount: toAccount,
                    );
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
