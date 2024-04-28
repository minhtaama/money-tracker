import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_box.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/credit_payment_form_controller.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../accounts/domain/account_base.dart';
import '../../../../accounts/domain/statement/base_class/statement.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../../selectors/presentation/forms.dart';

class AddCreditPaymentModalScreen extends ConsumerStatefulWidget {
  const AddCreditPaymentModalScreen(this.controller, this.isScrollable, {super.key});

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<AddCreditPaymentModalScreen> createState() => _AddCreditPaymentModalScreenState();
}

class _AddCreditPaymentModalScreenState extends ConsumerState<AddCreditPaymentModalScreen> {
  final _paymentInputController = TextEditingController();
  final _remainingInputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _showHelpBox = true;

  late final _stateController = ref.read(creditPaymentFormNotifierProvider.notifier);

  CreditPaymentFormState get _stateRead => ref.read(creditPaymentFormNotifierProvider);

  bool get _hidePayment => _stateRead.statement == null;

  void _onPaymentInputChange(String value) {
    _paymentInputController.text = value;
    _remainingInputController.clear();
    _stateController.changePaymentInput(context, value);
    setState(() {
      _showHelpBox = true;
    });
  }

  void _onRemainingInputChange(String value) {
    _remainingInputController.text = value;
    _stateController.changeRemainingInput(value);
  }

  void _onToggleFullPaymentCheckbox(bool value) {
    _remainingInputController.clear();
    _stateController.toggleFullPayment(value);
  }

  void _onDateTimeChange(DateTime? dateTime, Statement? statement) {
    _stateController.changeDateTime(dateTime, statement);
  }

  void _onCreditAccountChange(Account? newAccount) {
    _stateController.changeCreditAccount(newAccount as CreditAccount?);
  }

  void _onRegularAccountChange(Account? newAccount) {
    _stateController.changeFromAccount(newAccount as RegularAccount?);
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate() && !_stateController.isNoNeedPayment(context)) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
            dateTime: _stateRead.dateTime!,
            amount: _stateRead.userPaymentAmount!,
            account: _stateRead.creditAccount!,
            fromAccount: _stateRead.fromRegularAccount!,
            note: _stateRead.note,
            isFullPayment: _stateRead.isFullPayment,
            adjustment: _stateRead.adjustment,
          );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(creditPaymentFormNotifierProvider);
    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Add Payment',
        secondaryTitle: 'For credit accounts'.hardcoded,
      ),
      footer: ModalFooter(isBigButtonDisabled: _isButtonDisable, onBigButtonTap: _submit),
      body: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CreditDateTimeFormSelector(
                creditAccount: stateWatch.creditAccount,
                disableText: 'Choose credit account first'.hardcoded,
                initialDate: stateWatch.dateTime,
                isForPayment: true,
                onChanged: _onDateTimeChange,
                validator: (_) => _dateTimeValidator(),
              ),
            ),
            Gap.w24,
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextHeader('Payment from:'.hardcoded),
                  Gap.h4,
                  AccountFormSelector(
                    accountType: AccountType.regular,
                    validator: (_) => _fromRegularAccountValidator(),
                    onChangedAccount: _onRegularAccountChange,
                  ),
                  Gap.h8,
                  const TextHeader('Credit account to pay:'),
                  Gap.h4,
                  AccountFormSelector(
                    accountType: AccountType.credit,
                    validator: (_) => _creditAccountValidator(),
                    onChangedAccount: _onCreditAccountChange,
                  ),
                ],
              ),
            ),
          ],
        ),
        !_hidePayment ? Gap.h16 : Gap.noGap,
        HideableContainer(
          hide: _hidePayment,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomBox(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: CreditInfo(
                        showPaymentAmount: true,
                        showList: false,
                        chosenDateTime: stateWatch.dateTime?.onlyYearMonthDay,
                        statement: stateWatch.statement,
                      ),
                    ),
                    Gap.divider(context, indent: 6),
                    Gap.h8,
                    Padding(
                      padding: const EdgeInsets.only(left: 2.0),
                      child: Text(
                        'Payment amount:',
                        style: kHeader3TextStyle.copyWith(
                          fontSize: 14,
                          color: context.appTheme.onBackground.withOpacity(0.8),
                        ),
                      ),
                    ),
                    Gap.h4,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CurrencyIcon(),
                        Gap.w8,
                        Expanded(
                          child: CalculatorInput(
                            suffix: Transform.translate(
                              offset: const Offset(0, 5),
                              child: SvgIcon(
                                AppIcons.receiptCheck,
                                size: 27,
                                color: context.appTheme.onBackground,
                              ),
                            ),
                            hintText: '???',
                            controller: _paymentInputController,
                            focusColor: context.appTheme.primary,
                            fontSize: 25,
                            validator: (_) => _paymentInputValidator(context),
                            formattedResultOutput: _onPaymentInputChange,
                          ),
                        ),
                        Gap.w8,
                      ],
                    ),
                  ],
                ),
              ),
              Gap.h4,
              HelpBox(
                isShow: _showHelpBox && _stateController.isPaymentTooHighThanBalance(context),
                iconPath: AppIcons.sadFace,
                margin: const EdgeInsets.only(top: 8),
                header: 'Too high than balance to pay!'.hardcoded,
                text:
                    'Maybe there are other spending transactions before this day? If not a full payment, you must specify the balance after payment amount'
                        .hardcoded,
                onCloseTap: () => setState(() {
                  _showHelpBox = false;
                }),
              ),
              HelpBox(
                isShow: _showHelpBox && _stateController.isPaymentQuiteHighThanBalance(context),
                iconPath: AppIcons.fykFace,
                margin: const EdgeInsets.only(top: 8),
                backgroundColor: context.appTheme.positive,
                color: context.appTheme.onPositive,
                header: 'Pay amount is quite higher'.hardcoded,
                text:
                    'Are there some hidden fee or some small transaction you forgot to add? If not a full payment, you must specify the balance after payment amount'
                        .hardcoded,
                onCloseTap: () => setState(() {
                  _showHelpBox = false;
                }),
              ),
              HelpBox(
                isShow: _showHelpBox && _stateController.isPaymentCloseToBalance(context),
                iconPath: AppIcons.fykFace,
                margin: const EdgeInsets.only(top: 8),
                backgroundColor: context.appTheme.positive,
                color: context.appTheme.onPositive,
                header: 'Close to balance to pay!'.hardcoded,
                text: 'Is this a full payment? If so, please tick "Full Payment" below!'.hardcoded,
                onCloseTap: () => setState(() {
                  _showHelpBox = false;
                }),
              ),
              HelpBox(
                isShow: _showHelpBox && _stateController.isPaymentEqualBalance(context),
                iconPath: AppIcons.fykFace,
                margin: const EdgeInsets.only(top: 8),
                backgroundColor: context.appTheme.positive,
                color: context.appTheme.onPositive,
                header: 'Exact balance to pay!'.hardcoded,
                onCloseTap: () => setState(() {
                  _showHelpBox = false;
                }),
              ),
              HelpBox(
                isShow: _showHelpBox && _stateController.isNoNeedPayment(context),
                iconPath: AppIcons.fykFace,
                margin: const EdgeInsets.only(top: 8),
                backgroundColor: context.appTheme.positive,
                color: context.appTheme.onPositive,
                header: 'No balance left to pay!'.hardcoded,
                onCloseTap: () => setState(() {
                  _showHelpBox = false;
                }),
              ),
              !_stateController.isNoNeedPayment(context)
                  ? CustomCheckbox(
                      onChanged: _onToggleFullPaymentCheckbox,
                      label: 'Full payment',
                      showOptionalWidgetWhenValueIsFalse: true,
                      optionalWidget: Column(
                        children: [
                          InlineTextFormField(
                            prefixText: 'Bal. after payment:'.hardcoded,
                            suffixText: context.appSettings.currency.code,
                            textSize: 14,
                            widget: CalculatorInput(
                              hintText: stateWatch.userPaymentAmount != null &&
                                      stateWatch.totalBalanceAmount.roundBySetting(context) -
                                              stateWatch.userPaymentAmount!.roundBySetting(context) >
                                          0
                                  ? CalService.formatCurrency(context,
                                      stateWatch.totalBalanceAmount - stateWatch.userPaymentAmount!)
                                  : '???',
                              textAlign: TextAlign.right,
                              controller: _remainingInputController,
                              isDense: true,
                              fontSize: 16,
                              focusColor: context.appTheme.primary,
                              validator: (_) => _remainingInputValidator(context),
                              formattedResultOutput: _onRemainingInputChange,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Gap.noGap,
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
              color: context.appTheme.onBackground.withOpacity(0.4),
            ),
          ),
        ),
        Gap.h4,
        CustomTextFormField(
          autofocus: false,
          focusColor: context.appTheme.accent1,
          withOutlineBorder: true,
          maxLines: 3,
          hintText: 'Note ...',
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            _stateController.changeNote(value);
          },
        ),
      ],
    );
  }
}

extension _Validators on _AddCreditPaymentModalScreenState {
  bool get _isButtonDisable =>
      _stateRead.userPaymentAmount == null ||
      _stateRead.userPaymentAmount == 0 ||
      _stateRead.userRemainingAmount == 0 ||
      _stateRead.userRemainingAmount == null && !_stateRead.isFullPayment ||
      _stateRead.fromRegularAccount == null ||
      _stateRead.totalBalanceAmount.roundBySetting(context) == 0;

  String? _dateTimeValidator() {
    if (_stateRead.dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _paymentInputValidator(BuildContext context) {
    if (_stateRead.userPaymentAmount == null || _stateRead.userPaymentAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_stateRead.statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    return null;
  }

  String? _remainingInputValidator(BuildContext context) {
    if (_stateRead.statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }

    if (_stateRead.userRemainingAmount != null &&
        _stateRead.userRemainingAmount!.roundBySetting(context) >
            _stateRead.totalBalanceAmount.roundBySetting(context)) {
      return 'Higher than balance to pay'.hardcoded;
    }

    if (_stateRead.userRemainingAmount != null && _stateRead.userRemainingAmount == 0) {
      return 'Please tick as full payment'.hardcoded;
    }

    // When user is not tick as full payment but not specify a remaining amount
    if (_stateRead.isFullPayment == false &&
        _stateRead.userRemainingAmount == null &&
        _stateRead.userPaymentAmount != null &&
        _stateRead.totalBalanceAmount.roundBySetting(context) - _stateRead.userPaymentAmount! <= 0) {
      return 'Please specify an amount'.hardcoded;
    }

    return null;
  }

  String? _creditAccountValidator() {
    if (_stateRead.creditAccount == null) {
      return 'Must specify a credit account';
    }
    return null;
  }

  String? _fromRegularAccountValidator() {
    if (_stateRead.fromRegularAccount == null) {
      return 'Must be specify for payment';
    }
    return null;
  }
}
