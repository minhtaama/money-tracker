import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/isar_dto/account_isar.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/forms/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../accounts/domain/account.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../category/data/isar_dto/category_isar.dart';
import '../../category/data/isar_dto/category_tag_isar.dart';
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
  CategoryTagIsar? tag;
  CategoryIsar? category;
  Account? account;
  Account? toAccount;

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
                    if (_formatToDouble(calculatorOutput) == null ||
                        _formatToDouble(calculatorOutput) == 0) {
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
                      widget.transactionType != TransactionType.transfer ? 'Category:' : 'From:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    widget.transactionType != TransactionType.transfer
                        ? CategoryFormSelector(
                            transactionType: widget.transactionType,
                            validator: (_) {
                              if (category == null &&
                                  widget.transactionType != TransactionType.transfer) {
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
                            accountType: AccountType.regular,
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
                            otherSelectedAccount: toAccount,
                          ),
                    Gap.h16,
                    Text(
                      widget.transactionType != TransactionType.transfer ? 'Account:' : 'To:',
                      style: kHeader2TextStyle.copyWith(
                          fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
                    ),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
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
                      },
                      otherSelectedAccount:
                          widget.transactionType == TransactionType.transfer ? account : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h16,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'OPTIONAL:',
              style: kHeader2TextStyle.copyWith(
                fontSize: 11,
                color: context.appTheme.backgroundNegative.withOpacity(0.4),
              ),
            ),
          ),
          Gap.h4,
          widget.transactionType != TransactionType.transfer
              ? CategoryTagSelector(
                  category: category,
                  onTagSelected: (value) {
                    tag = value;
                  })
              : Gap.noGap,
          widget.transactionType != TransactionType.transfer ? Gap.h8 : Gap.noGap,
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
                    category == null && widget.transactionType != TransactionType.transfer ||
                    toAccount == null && widget.transactionType == TransactionType.transfer ||
                    account == null,
                onTap: () {
                  // By validating, the _formatToDouble(calculatorOutput), account, category, toAccount must not null
                  if (_formKey.currentState!.validate()) {
                    final transactionRepo = ref.read(transactionRepositoryProvider);

                    if (type == TransactionType.income) {
                      transactionRepo.writeNewIncomeTxn(
                        dateTime: dateTime,
                        amount: _formatToDouble(calculatorOutput)!,
                        category: category!,
                        tag: tag,
                        account: account!,
                        note: note,
                      );
                    }
                    if (type == TransactionType.expense) {
                      transactionRepo.writeNewExpenseTxn(
                        dateTime: dateTime,
                        amount: _formatToDouble(calculatorOutput)!,
                        category: category!,
                        tag: tag,
                        account: account!,
                        note: note,
                      );
                    }
                    if (type == TransactionType.transfer) {
                      transactionRepo.writeNewTransferTxn(
                          dateTime: dateTime,
                          amount: _formatToDouble(calculatorOutput)!,
                          account: account!,
                          toAccount: toAccount!,
                          note: note,
                          fee: null,
                          isChargeOnDestinationAccount: null);
                      // TODO: do something with fee
                    }
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
