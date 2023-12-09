import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../common_widgets/inline_text_form_field.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../../../category/domain/category_tag.dart';
import '../../../category/domain/category.dart';
import '../../data/transaction_repo.dart';
import '../selectors/forms.dart';

class AddCreditSpendingModalScreen extends ConsumerStatefulWidget {
  const AddCreditSpendingModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditSpendingModalScreen> createState() => _AddCreditTransactionModalScreenState();
}

class _AddCreditTransactionModalScreenState extends ConsumerState<AddCreditSpendingModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _installmentPaymentController = TextEditingController();

  int? _installmentPaymentPeriod;

  late DateTime _dateTime = DateTime.now();
  String? _note;
  Category? _category;
  CategoryTag? _tag;
  CreditAccount? _creditAccount;

  String _calOutputSpendAmount = '0';

  String? get _installmentPaymentAmount {
    if (CalService.formatToDouble(_calOutputSpendAmount) != null && _installmentPaymentPeriod != null) {
      return CalService.formatNumberInGroup(
          (CalService.formatToDouble(_calOutputSpendAmount)! / _installmentPaymentPeriod!).toString());
    } else {
      return null;
    }
  }

  void _resetInstallmentDetails() {
    _installmentPaymentPeriod = null;
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditSpending(
            dateTime: _dateTime,
            amount: CalService.formatToDouble(_calOutputSpendAmount)!,
            tag: _tag,
            note: _note,
            category: _category!,
            account: _creditAccount!,
            monthsToPay: _installmentPaymentPeriod,
            paymentAmount: CalService.formatToDouble(_installmentPaymentController.text),
          );
      context.pop();
    }
  }

  @override
  void dispose() {
    _installmentPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Credit Transaction'.hardcoded,
        crossAxisAlignment: CrossAxisAlignment.start,
        isWrapByCard: false,
        sections: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CurrencyIcon(),
              Gap.w16,
              Expanded(
                child: CalculatorInput(
                  hintText: 'Spending Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) => _calSpendingAmountValidator(),
                  formattedResultOutput: (value) {
                    setState(() {
                      _calOutputSpendAmount = value;
                      _installmentPaymentController.text = _installmentPaymentAmount ?? '0';
                    });
                  },
                ),
              ),
              Gap.w16,
              HelpButton(
                text: 'All fees must be included.'.hardcoded,
                yOffset: 4,
              )
            ],
          ),
          Gap.h4,
          CustomCheckbox(
            label: 'Installment payment'.hardcoded,
            labelSuffix: HelpButton(
                title: 'Installment payment'.hardcoded,
                text:
                    'For registered installment credit transactions. Note: All the principal amount, interest, and any installment conversion fee (if applicable) of this installment transactions must be INCLUDED in \'Spending Amount\' (Because installment payment is a fixed amount, see more details in your banking contract).'
                        .hardcoded),
            onChanged: (value) {
              setState(() {
                if (!value) {
                  _resetInstallmentDetails();
                }
                _installmentPaymentController.text = _installmentPaymentAmount ?? '0';
              });
            },
            optionalWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineTextFormField(
                  prefixText: 'Installment Period:',
                  suffixText: 'month(s)',
                  validator: (_) => _installmentPaymentPeriod == null ? 'error' : null,
                  onChanged: (value) {
                    _installmentPaymentPeriod = int.tryParse(value);
                    _installmentPaymentController.text = _installmentPaymentAmount ?? '0';
                  },
                ),
                Gap.h8,
                InlineTextFormField(
                  prefixText: 'Payment amount:',
                  suffixText: context.currentSettings.currency.code,
                  widget: CalculatorInput(
                      controller: _installmentPaymentController,
                      fontSize: 18,
                      isDense: true,
                      textAlign: TextAlign.end,
                      validator: (_) => _installmentPaymentValidator(),
                      formattedResultOutput: (value) => _installmentPaymentController.text = value,
                      focusColor: context.appTheme.secondary,
                      hintText: ''),
                ),
              ],
            ),
          ),
          Gap.h8,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CreditDateTimeFormSelector(
                  creditAccount: _creditAccount,
                  isForPayment: false,
                  disableText: 'Choose credit account first'.hardcoded,
                  initialDate: _dateTime,
                  onChanged: (dateTime, statement) {
                    if (dateTime != null) {
                      _dateTime = dateTime;
                    }
                    setState(() {});
                  },
                ),
              ),
              Gap.w24,
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextHeader('Expense Category:'),
                    Gap.h4,
                    CategoryFormSelector(
                      transactionType: TransactionType.expense,
                      validator: (_) => _categoryValidator(),
                      onChangedCategory: (newCategory) => setState(() {
                        _category = newCategory;
                      }),
                    ),
                    Gap.h16,
                    const TextHeader('Credit Account:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.credit,
                      validator: (_) => _creditAccountValidator(),
                      onChangedAccount: (newAccount) => setState(() {
                        _creditAccount = newAccount as CreditAccount;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h16,
          const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: TextHeader(
                'OPTIONAL:',
                fontSize: 11,
              )),
          Gap.h4,
          CategoryTagSelector(
              category: _category,
              onTagSelected: (value) {
                _tag = value;
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
              _note = value;
            },
          ),
          Gap.h16,
          BottomButtons(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit)
        ],
      ),
    );
  }
}

extension _Validators on _AddCreditTransactionModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_calOutputSpendAmount) == null ||
      CalService.formatToDouble(_calOutputSpendAmount) == 0 ||
      _category == null ||
      _creditAccount == null;

  String? _calSpendingAmountValidator() {
    if (CalService.formatToDouble(_calOutputSpendAmount) == null ||
        CalService.formatToDouble(_calOutputSpendAmount) == 0) {
      return 'Invalid amount';
    }
    return null;
  }

  String? _installmentPaymentValidator() {
    if (CalService.formatToDouble(_installmentPaymentAmount) == null ||
        CalService.formatToDouble(_installmentPaymentAmount) == 0) {
      return 'Invalid Amount';
    }
    if (CalService.formatToDouble(_installmentPaymentAmount)! >
        CalService.formatToDouble(_calOutputSpendAmount)!) {
      return 'Too high';
    }
    return null;
  }

  String? _categoryValidator() {
    if (_category == null) {
      return 'Must specify a category'.hardcoded;
    }
    return null;
  }

  String? _creditAccountValidator() {
    if (_creditAccount == null) {
      return 'Must specify for payment'.hardcoded;
    }
    return null;
  }
}
