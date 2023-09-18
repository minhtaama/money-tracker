import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/domain/category.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../../common_widgets/inline_text_form_field.dart';
import '../../../accounts/domain/account.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../../../category/domain/category_tag.dart';
import '../../data/transaction_repo.dart';
import '../../domain/transaction.dart';
import '../selectors/forms.dart';

class AddCreditSpendingModalScreen extends ConsumerStatefulWidget {
  const AddCreditSpendingModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditSpendingModalScreen> createState() => _AddCreditTransactionModalScreenState();
}

class _AddCreditTransactionModalScreenState extends ConsumerState<AddCreditSpendingModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _installmentPaymentController = TextEditingController();

  bool _hasInstallmentPayment = false;
  int? _installmentPaymentPeriod;

  late DateTime _dateTime = DateTime.now();
  String? _note;
  Category? _category;
  CategoryTag? _tag;
  Account? _account;

  String _calOutputSpendAmount = '0';

  String _interestRate = '0';
  bool _rateOnRemaining = false;

  String get _installmentPaymentAmount {
    if (CalService.formatToDouble(_calOutputSpendAmount) != null && _installmentPaymentPeriod != null) {
      return CalService.formatNumberInGroup(
          (CalService.formatToDouble(_calOutputSpendAmount)! / _installmentPaymentPeriod!).toString());
    } else {
      return '0';
    }
  }

  void _resetInstallmentDetails() {
    _installmentPaymentPeriod = null;
    _interestRate = '0';
    _rateOnRemaining = false;
  }

  void _submit() {
    Installment? installment;

    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      if (_hasInstallmentPayment) {
        installment = Installment(
          CalService.formatToDouble(_installmentPaymentAmount)!,
          CalService.formatToDouble(_interestRate)!,
          _rateOnRemaining,
        );
      }
      ref.read(transactionRepositoryProvider).writeNewCreditSpendingTxn(
            dateTime: _dateTime,
            amount: CalService.formatToDouble(_calOutputSpendAmount)!,
            tag: _tag,
            note: _note,
            category: _category!,
            account: _account!,
            installment: installment,
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
    final settingsObject = ref.watch(settingsControllerProvider);

    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Credit Transaction'.hardcoded,
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
                  validator: (_) => _calSpendingAmountValidator(),
                  formattedResultOutput: (value) {
                    setState(() {
                      _calOutputSpendAmount = value;
                      _installmentPaymentController.text = _installmentPaymentAmount;
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
                child: DateTimeSelector(
                  onChanged: (DateTime value) => _dateTime = value,
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
                        _account = newAccount;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h4,
          CustomCheckbox(
            label: 'Installment payment',
            onChanged: (value) {
              setState(() {
                if (value) {
                  _hasInstallmentPayment = true;
                } else {
                  _hasInstallmentPayment = false;
                  _resetInstallmentDetails();
                }
                _installmentPaymentController.text = _installmentPaymentAmount;
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
                    _installmentPaymentController.text = _installmentPaymentAmount;
                  },
                ),
                Gap.h8,
                InlineTextFormField(
                  prefixText: 'Payment amount:',
                  suffixText: settingsObject.currency.code,
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
                Gap.h8,
                InlineTextFormField(
                  prefixText: 'Interest rate:',
                  suffixText: '%',
                  initialValue: '0',
                  width: 40,
                  validator: (_) => _interestRateValidator(),
                  onChanged: (value) => _interestRate = value,
                ),
                Gap.h8,
                CustomCheckbox(
                  label: 'Rate on remaining payment',
                  labelStyle: kHeader4TextStyle.copyWith(fontSize: 15, color: context.appTheme.backgroundNegative),
                  onChanged: (value) => _rateOnRemaining = value,
                ),
              ],
            ),
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
          BottomButtons(isDisabled: _isButtonDisable, onTap: _submit)
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
      _account == null;

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
    if (CalService.formatToDouble(_installmentPaymentAmount)! > CalService.formatToDouble(_calOutputSpendAmount)!) {
      return 'Too high';
    }
    return null;
  }

  String? _interestRateValidator() {
    if (CalService.formatToDouble(_interestRate) == null) {
      return 'Invalid Amount';
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
    if (_account == null) {
      return 'Must specify for payment'.hardcoded;
    }
    return null;
  }
}
