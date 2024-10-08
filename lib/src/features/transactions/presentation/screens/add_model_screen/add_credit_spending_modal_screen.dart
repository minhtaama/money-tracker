import 'package:flutter/cupertino.dart';
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
    print('stateWatch.installmentPeriod: ${_stateRead.installmentPeriod}');

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
            paymentStartFromNextStatement: _stateRead.paymentStartFromNextStatement,
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
        title: context.loc.addCreditSpending,
        secondaryTitle: context.loc.forCreditAccount,
      ),
      footer: ModalFooter(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit),
      body: [
        AmountFormSelector(
          transactionType: TransactionType.creditSpending,
          initialValue: stateWatch.amount,
          validator: (_) => _calSpendingAmountValidator(),
          suffix: HelpButton(
            text: context.loc.quoteTransaction8,
            yOffset: 4,
          ),
          onChangedAmount: (value) {
            _stateController.changeAmount(value);
          },
        ),
        CustomCheckbox(
          label: context.loc.installmentPayment,
          labelSuffix: HelpButton(
            title: context.loc.installmentPayment,
            text: context.loc.quoteInstallmentPayment2,
          ),
          onChanged: (value) {
            if (!value) {
              _stateController.changeInstallmentPeriod(null);
            }
            _changeInstallmentControllerText();
          },
          optionalWidget: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineTextFormField(
                  prefixText: context.loc.installmentPeriod,
                  suffixText: context.loc.monthS,
                  validator: (_) => _installmentPeriodValidator(),
                  onChanged: (value) {
                    _stateController.changeInstallmentPeriod(int.tryParse(value));
                    _changeInstallmentControllerText();
                  },
                ),
                Gap.h8,
                InlineTextFormField(
                  prefixText: '${context.loc.paymentAmount}:',
                  suffixText: context.appSettings.currency.code,
                  widget: CalculatorInput(
                      title: context.loc.paymentAmount,
                      controller: _installmentPaymentController,
                      fontSize: 18,
                      isDense: true,
                      textAlign: TextAlign.end,
                      validator: (_) => _installmentPaymentValidator(),
                      formattedResultOutput: (value) => _stateController.changeInstallmentAmount(value),
                      focusColor: context.appTheme.secondary1,
                      hintText: ''),
                ),
                Gap.h12,
                CustomCheckbox(
                  label: context.loc.startPaymentInNextStatement,
                  initialValue: stateWatch.paymentStartFromNextStatement ?? true,
                  onChanged: (value) {
                    _stateController.changePaymentStartFromNextStatement(value);
                  },
                ),
              ],
            ),
          ),
        ),
        Gap.h4,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CreditDateTimeFormSelector(
                creditAccount: stateWatch.creditAccount,
                isForPayment: false,
                disableText: context.loc.chooseCreditAccountFirst,
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
                  TextHeader(context.loc.creditAccount),
                  Gap.h4,
                  AccountFormSelector(
                    accountType: AccountType.credit,
                    validator: (_) => _creditAccountValidator(),
                    onChangedAccount: (newAccount) =>
                        _stateController.changeCreditAccount(newAccount as CreditAccount?),
                  ),
                  Gap.h16,
                  TextHeader(context.loc.expenseCategory),
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
        Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextHeader(
              context.loc.optional.toUpperCase(),
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
      return context.loc.invalidAmount;
    }
    return null;
  }

  String? _installmentPaymentValidator() {
    if (_stateRead.installmentAmount == null || _stateRead.installmentAmount == 0) {
      return context.loc.invalidAmount;
    }

    if (_stateRead.installmentAmount! > _stateRead.amount!) {
      return context.loc.tooHigh;
    }
    return null;
  }

  String? _installmentPeriodValidator() {
    return _stateRead.installmentPeriod == null ? 'error' : null;
  }

  String? _categoryValidator() {
    if (_stateRead.category == null) {
      return context.loc.mustSpecifyCategory;
    }
    return null;
  }

  String? _creditAccountValidator() {
    if (_stateRead.creditAccount == null) {
      return context.loc.mustSpecifyCreditAccount;
    }
    return null;
  }
}
