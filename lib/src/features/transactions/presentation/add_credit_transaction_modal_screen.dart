import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_isar.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag_isar.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
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

  final _calController = TextEditingController();

  late DateTime dateTime = DateTime.now();

  String calculatorOutputSpendAmount = '0';
  String calculatorOutputCyclePaymentAmount = '0';
  String? note;
  CategoryTagIsar? tag;
  CategoryIsar? category;
  AccountIsar? account;
  int? paymentCycle = 1;

  @override
  void dispose() {
    _calController.dispose();
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
    if (_formatToDouble(calculatorOutputSpendAmount) != null && paymentCycle != null) {
      return _formatToDouble(calculatorOutputSpendAmount)! / paymentCycle!;
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
                  hintText: 'Spending Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) {
                    if (_formatToDouble(calculatorOutputSpendAmount) == null ||
                        _formatToDouble(calculatorOutputSpendAmount) == 0) {
                      return 'Invalid amount';
                    }
                    return null;
                  },
                  formattedResultOutput: (value) {
                    setState(() {
                      calculatorOutputSpendAmount = value;
                      calculatorOutputCyclePaymentAmount = _getInstallmentPayment().toString();
                      _calController.text = CalculatorService.formatNumberInGroup(calculatorOutputCyclePaymentAmount);
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
                    paymentCycle = null;
                  } else {
                    paymentCycle = 1;
                  }
                  calculatorOutputCyclePaymentAmount = _getInstallmentPayment().toString();
                  _calController.text = CalculatorService.formatNumberInGroup(calculatorOutputCyclePaymentAmount);
                });
              },
              optionalWidget: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Installment Cycle:',
                        style: kHeader4TextStyle,
                      ),
                      Gap.w8,
                      SizedBox(
                        width: 50,
                        child: CustomTextFormField(
                          hintText: '',
                          focusColor: context.appTheme.secondary,
                          autofocus: false,
                          disableErrorText: true,
                          maxLength: 3,
                          contentPadding: EdgeInsets.zero,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.end,
                          validator: (_) => paymentCycle == null ? 'error' : null,
                          onChanged: (value) {
                            setState(() {
                              paymentCycle = int.tryParse(value);
                              calculatorOutputCyclePaymentAmount = _getInstallmentPayment().toString();
                              _calController.text =
                                  CalculatorService.formatNumberInGroup(calculatorOutputCyclePaymentAmount);
                            });
                          },
                        ),
                      ),
                      Gap.w8,
                      const Text(
                        'month(s)',
                        style: kHeader4TextStyle,
                      ),
                    ],
                  ),
                  Gap.h8,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text(
                        'Payment amount:',
                        style: kHeader4TextStyle,
                      ),
                      Gap.w8,
                      Expanded(
                        child: CalculatorInput(
                            controller: _calController,
                            fontSize: 18,
                            isDense: true,
                            textAlign: TextAlign.end,
                            //initialValue: _formatToDouble(calculatorOutputCyclePaymentAmount),
                            validator: (_) {
                              if (_formatToDouble(calculatorOutputCyclePaymentAmount) == null ||
                                  _formatToDouble(calculatorOutputCyclePaymentAmount) == 0) {
                                return 'Invalid Amount';
                              }
                              if (_formatToDouble(calculatorOutputCyclePaymentAmount)! >
                                  _formatToDouble(calculatorOutputSpendAmount)!) {
                                return 'Higher than spending';
                              }
                              return null;
                            },
                            formattedResultOutput: (value) {
                              setState(() {
                                calculatorOutputCyclePaymentAmount = value;
                              });
                            },
                            focusColor: context.appTheme.secondary,
                            hintText: ''),
                      ),
                      Gap.w8,
                      Text(
                        settingsObject.currency.code,
                        style: kHeader4TextStyle,
                      ),
                    ],
                  ),
                ],
              )),
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
                isDisabled: _formatToDouble(calculatorOutputSpendAmount) == null ||
                    _formatToDouble(calculatorOutputSpendAmount) == 0 ||
                    category == null ||
                    account == null,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // By validating, the _formatToDouble(calculatorOutputSpendAmount)
                    // and _formatToDouble(calculatorOutputCyclePaymentAmount) must not null

                    // TODO: Add repo, statement date, payment due date function

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
