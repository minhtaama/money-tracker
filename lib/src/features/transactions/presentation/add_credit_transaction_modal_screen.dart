import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/currency_icon.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/forms/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/inline_text_form_field.dart';
import '../../accounts/domain/account.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../category/domain/category_tag.dart';
import '../data/transaction_repo.dart';
import '../domain/transaction.dart';
import 'forms/forms.dart';

class AddCreditTransactionModalScreen extends ConsumerStatefulWidget {
  const AddCreditTransactionModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditTransactionModalScreen> createState() =>
      _AddCreditTransactionModalScreenState();
}

class _AddCreditTransactionModalScreenState extends ConsumerState<AddCreditTransactionModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _installmentCalController = TextEditingController();

  late DateTime dateTime = DateTime.now();
  String? note;
  Category? category;
  CategoryTag? tag;
  Account? account;

  String calOutputSpendAmount = '0';

  bool hasInstallmentPayment = false;
  int? paymentPeriod;
  String calOutputInstallmentAmount = '0';
  String interestRate = '0';
  bool rateBasedOnRemainingInstallmentUnpaid = false;

  @override
  void dispose() {
    _installmentCalController.dispose();
    super.dispose();
  }

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

  double _getInstallmentPayment() {
    if (_formatToDouble(calOutputSpendAmount) != null && paymentPeriod != null) {
      return _formatToDouble(calOutputSpendAmount)! / paymentPeriod!;
    } else {
      return 0;
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
              const CurrencyIcon(),
              Gap.w16,
              Expanded(
                child: CalculatorInput(
                  hintText: 'Spending Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) {
                    if (_formatToDouble(calOutputSpendAmount) == null ||
                        _formatToDouble(calOutputSpendAmount) == 0) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  formattedResultOutput: (value) {
                    setState(() {
                      calOutputSpendAmount = value;
                      calOutputInstallmentAmount = _getInstallmentPayment().toString();
                      _installmentCalController.text =
                          CalculatorService.formatNumberInGroup(calOutputInstallmentAmount);
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
          Gap.h4,
          CustomCheckbox(
            label: 'Installment payment',
            onChanged: (boolValue) {
              setState(() {
                if (boolValue) {
                  hasInstallmentPayment = true;
                } else {
                  hasInstallmentPayment = false;
                  paymentPeriod = null;
                  interestRate = '0';
                  rateBasedOnRemainingInstallmentUnpaid = false;
                }
                calOutputInstallmentAmount = _getInstallmentPayment().toString();
                _installmentCalController.text =
                    CalculatorService.formatNumberInGroup(calOutputInstallmentAmount);
              });
            },
            optionalWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineTextFormField(
                  prefixText: 'Installment Period:',
                  suffixText: 'month(s)',
                  validator: (_) => paymentPeriod == null ? 'error' : null,
                  onChanged: (value) {
                    paymentPeriod = int.tryParse(value);
                    calOutputInstallmentAmount = _getInstallmentPayment().toString();
                    _installmentCalController.text =
                        CalculatorService.formatNumberInGroup(calOutputInstallmentAmount);
                  },
                ),
                Gap.h8,
                InlineTextFormField(
                  prefixText: 'Payment amount:',
                  suffixText: settingsObject.currency.code,
                  widget: CalculatorInput(
                      controller: _installmentCalController,
                      fontSize: 18,
                      isDense: true,
                      textAlign: TextAlign.end,
                      validator: (_) {
                        if (_formatToDouble(calOutputInstallmentAmount) == null ||
                            _formatToDouble(calOutputInstallmentAmount) == 0) {
                          return 'Invalid Amount';
                        }
                        if (_formatToDouble(calOutputInstallmentAmount)! >
                            _formatToDouble(calOutputSpendAmount)!) {
                          return 'Too high';
                        }
                        return null;
                      },
                      formattedResultOutput: (value) {
                        calOutputInstallmentAmount = value;
                      },
                      focusColor: context.appTheme.secondary,
                      hintText: ''),
                ),
                Gap.h8,
                InlineTextFormField(
                  prefixText: 'Interest rate:',
                  suffixText: '%',
                  initialValue: '0',
                  width: 40,
                  validator: (_) {
                    if (_formatToDouble(interestRate) == null) {
                      return 'Invalid Amount';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    interestRate = value;
                  },
                ),
                Gap.h8,
                CustomCheckbox(
                  label: 'Rate on remaining payment',
                  labelStyle: kHeader4TextStyle.copyWith(
                      fontSize: 15, color: context.appTheme.backgroundNegative),
                  onChanged: (value) => rateBasedOnRemainingInstallmentUnpaid = value,
                ),
              ],
            ),
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
          CategoryTagSelector(
              category: category,
              onTagSelected: (value) {
                tag = value;
              }),
          Gap.h8,
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
                backgroundColor: context.appTheme.secondary,
                iconColor: context.appTheme.secondaryNegative,
                size: 55,
                onTap: () => context.pop(),
              ),
              const Spacer(),
              IconWithTextButton(
                iconPath: AppIcons.add,
                label: 'Add',
                backgroundColor: context.appTheme.accent,
                isDisabled: _formatToDouble(calOutputSpendAmount) == null ||
                    _formatToDouble(calOutputSpendAmount) == 0 ||
                    category == null ||
                    account == null,
                onTap: () {
                  Installment? installment;

                  // By validating, no important value can be null
                  if (_formKey.currentState!.validate()) {
                    if (hasInstallmentPayment) {
                      installment = Installment(
                        _formatToDouble(calOutputInstallmentAmount)!,
                        _formatToDouble(interestRate)!,
                        rateBasedOnRemainingInstallmentUnpaid,
                      );
                    }
                    ref.read(transactionRepositoryProvider).writeNewCreditSpendingTxn(
                          dateTime: dateTime,
                          amount: _formatToDouble(calOutputSpendAmount)!,
                          tag: tag,
                          note: note,
                          category: category!,
                          account: account!,
                          installment: installment,
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
