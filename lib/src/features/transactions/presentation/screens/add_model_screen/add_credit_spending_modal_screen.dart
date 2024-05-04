import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/credit_spending_form_controller.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/inline_text_form_field.dart';
import '../../../../accounts/domain/account_base.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../data/transaction_repo.dart';
import '../../../../selectors/presentation/forms.dart';

class AddCreditSpendingModalScreen extends ConsumerStatefulWidget {
  const AddCreditSpendingModalScreen(this.controller, this.isScrollable, {super.key});

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<AddCreditSpendingModalScreen> createState() => _AddCreditTransactionModalScreenState();
}

class _AddCreditTransactionModalScreenState extends ConsumerState<AddCreditSpendingModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _installmentPaymentController = TextEditingController();

  late final _stateController = ref.read(creditSpendingFormNotifierProvider.notifier);
  CreditSpendingFormState get _stateRead => ref.read(creditSpendingFormNotifierProvider);

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditSpending(
            dateTime: _stateRead.dateTime!,
            amount: _stateRead.amount!,
            tag: _stateRead.tag,
            note: _stateRead.note,
            category: _stateRead.category!,
            account: _stateRead.creditAccount!,
            monthsToPay: _stateRead.installmentPeriod,
            paymentAmount: _stateRead.installmentAmount,
          );
      context.pop();
    }
  }

  void _changeInstallmentControllerText() =>
      _installmentPaymentController.text = _stateRead.installmentAmountString(context) ?? '0';

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _stateController.changeDateTime(DateTime.now());
    });
    super.initState();
  }

  @override
  void dispose() {
    _installmentPaymentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(creditSpendingFormNotifierProvider);

    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Add Spending'.hardcoded,
        secondaryTitle: 'For credit accounts'.hardcoded,
      ),
      footer: ModalFooter(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit),
      body: [
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
                  _stateController.changeAmount(value);
                  _changeInstallmentControllerText();
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
            if (!value) {
              _stateController.changeInstallmentPeriod(null);
            }
            _changeInstallmentControllerText();
          },
          optionalWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InlineTextFormField(
                prefixText: 'Installment Period:',
                suffixText: 'month(s)',
                validator: (_) => stateWatch.installmentPeriod == null ? 'error' : null,
                onChanged: (value) {
                  _stateController.changeInstallmentPeriod(int.tryParse(value));
                  _changeInstallmentControllerText();
                },
              ),
              Gap.h8,
              InlineTextFormField(
                prefixText: 'Payment amount:',
                suffixText: context.appSettings.currency.code,
                widget: CalculatorInput(
                    controller: _installmentPaymentController,
                    fontSize: 18,
                    isDense: true,
                    textAlign: TextAlign.end,
                    validator: (_) => _installmentPaymentValidator(),
                    formattedResultOutput: (value) => _stateController.changeInstallmentAmount(value),
                    focusColor: context.appTheme.secondary1,
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
                creditAccount: stateWatch.creditAccount,
                isForPayment: false,
                disableText: 'Choose credit account first'.hardcoded,
                initialDate: stateWatch.dateTime,
                onChanged: (dateTime, statement) {
                  if (dateTime != null) {
                    _stateController.changeDateTime(dateTime);
                  }
                },
              ),
            ),
            Gap.w24,
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextHeader('Credit Account:'),
                  Gap.h4,
                  AccountFormSelector(
                    accountType: AccountType.credit,
                    validator: (_) => _creditAccountValidator(),
                    onChangedAccount: (newAccount) =>
                        _stateController.changeCreditAccount(newAccount as CreditAccount),
                  ),
                  Gap.h16,
                  const TextHeader('Expense category:'),
                  Gap.h4,
                  CategoryFormSelector(
                    transactionType: TransactionType.expense,
                    validator: (_) => _categoryValidator(),
                    onChangedCategory: (newCategory) => _stateController.changeCategory(newCategory),
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
          category: stateWatch.category,
          onTagSelected: (value) => _stateController.changeCategoryTag(value),
          onTagDeSelected: () => _stateController.changeCategoryTag(null),
        ),
        Gap.h8,
        CustomTextFormField(
          autofocus: false,
          focusColor: context.appTheme.accent1,
          withOutlineBorder: true,
          maxLines: 3,
          hintText: 'Note ...',
          textInputAction: TextInputAction.done,
          onChanged: (value) => _stateController.changeNote(value),
        ),
      ],
    );
  }
}

extension _Validators on _AddCreditTransactionModalScreenState {
  bool get _isButtonDisable =>
      _stateRead.amount == null ||
      _stateRead.amount == 0 ||
      _stateRead.category == null ||
      _stateRead.creditAccount == null;

  String? _calSpendingAmountValidator() {
    if (_stateRead.amount == null || _stateRead.amount == 0) {
      return 'Invalid amount';
    }
    return null;
  }

  String? _installmentPaymentValidator() {
    if (_stateRead.installmentAmount == null || _stateRead.installmentAmount == 0) {
      return 'Invalid Amount';
    }

    if (_stateRead.installmentAmount! > _stateRead.amount!) {
      return 'Too high';
    }
    return null;
  }

  String? _categoryValidator() {
    if (_stateRead.category == null) {
      return 'Must specify a category'.hardcoded;
    }
    return null;
  }

  String? _creditAccountValidator() {
    if (_stateRead.creditAccount == null) {
      return 'Must specify for payment'.hardcoded;
    }
    return null;
  }
}
