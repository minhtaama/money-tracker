import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/custom_checkbox.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_box.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../accounts/domain/statement/statement.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../selectors/forms.dart';

class AddCreditPaymentModalScreen extends ConsumerStatefulWidget {
  const AddCreditPaymentModalScreen({super.key});

  @override
  ConsumerState<AddCreditPaymentModalScreen> createState() => _AddCreditPaymentModalScreenState();
}

class _AddCreditPaymentModalScreenState extends ConsumerState<AddCreditPaymentModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentInputController = TextEditingController();
  final _remainingInputController = TextEditingController();

  Statement? _statement;

  bool get _hidePayment => _statement == null;

  double get _totalBalanceAmount =>
      _statement == null || _dateTime == null ? 0 : _statement!.getBalanceAmountAt(_dateTime!);

  String get _paymentCalOutputFormattedAmount => _paymentInputController.text;

  double? _userRemainingAmount;

  void _onPaymentInputChange(String value) {
    setState(() {
      _paymentInputController.text = value;
      _remainingInputController.clear();
    });

    _userRemainingAmount = null;

    if (_userPaymentAmount != null && (_userPaymentAmount! > _totalBalanceAmount || _isFullPayment)) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      _adjustment = _totalBalanceAmount - _userPaymentAmount!;
    } else {
      _adjustment = null;
    }
  }

  void _onRemainingInputChange(String value) {
    setState(() {
      _remainingInputController.text = value;
    });

    _userRemainingAmount = CalService.formatToDouble(value);

    // Because: afterAdjustedAmount = userPaymentAmount + adjustment
    // Then: userRemaining = totalBalance - afterAdjustedAmount
    // Then: userRemaining = totalBalance - userPaymentAmount - adjustment
    _adjustment = _totalBalanceAmount - _userPaymentAmount! - _userRemainingAmount!;
  }

  void _onFullPaymentCheckboxChange(bool value) {
    _isFullPayment = value;

    _remainingInputController.clear();
    _userRemainingAmount = null;

    if (_isFullPayment && _userPaymentAmount != null) {
      //Because: afterAdjustedAmount = totalBalance = userPayment + adjustment
      _adjustment = _totalBalanceAmount - _userPaymentAmount!;
    } else {
      _adjustment = null;
    }
  }

  void _onDateTimeChange(DateTime? dateTime, Statement? statement) {
    setState(() {
      if (dateTime != null) {
        _dateTime = dateTime;
      }
      _statement = statement;
    });
  }

  void _onCreditAccountChange(Account? newAccount) {
    setState(() {
      _creditAccount = newAccount as CreditAccount?;
      if (_creditAccount == null) {
        _statement = null;
        _dateTime = null;
      }
    });
  }

  void _onRegularAccountChange(Account? newAccount) {
    setState(() {
      _fromRegularAccount = newAccount != null ? (newAccount as RegularAccount) : null;
    });
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
            dateTime: _dateTime!,
            amount: _userPaymentAmount!,
            account: _creditAccount!,
            fromAccount: _fromRegularAccount!,
            note: _note,
            isFullPayment: _isFullPayment,
            adjustment: _adjustment,
          );
      context.pop();
    }
  }

  ////////////////////// VALUE OUTPUT TO DATABASE /////////////////////////
  double? get _userPaymentAmount => CalService.formatToDouble(_paymentCalOutputFormattedAmount);

  DateTime? _dateTime;
  String? _note;

  CreditAccount? _creditAccount;
  RegularAccount? _fromRegularAccount;

  bool _isFullPayment = false;
  double? _adjustment;
  ///////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Credit Payment',
        crossAxisAlignment: CrossAxisAlignment.start,
        isWrapByCard: false,
        sectionsClipping: false,
        sections: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CreditDateTimeFormSelector(
                  creditAccount: _creditAccount,
                  disableText: 'Choose credit account first'.hardcoded,
                  initialDate: _dateTime,
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
                    TextHeader('Pay to credit account:'.hardcoded),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.credit,
                      validator: (_) => _creditAccountValidator(),
                      onChangedAccount: _onCreditAccountChange,
                    ),
                    Gap.h8,
                    const TextHeader('Payment account:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
                      validator: (_) => _fromRegularAccountValidator(),
                      onChangedAccount: _onRegularAccountChange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          !_hidePayment ? Gap.h16 : Gap.noGap,
          HideableContainer(
            hidden: _hidePayment,
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
                          chosenDateTime: _dateTime?.onlyYearMonthDay,
                          statement: _statement,
                        ),
                      ),
                      Gap.h16,
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          'Payment amount:',
                          style: kHeader3TextStyle.copyWith(
                            fontSize: 14,
                            color: context.appTheme.backgroundNegative.withOpacity(0.8),
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
                                  color: context.appTheme.backgroundNegative,
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
                      Gap.h4,
                    ],
                  ),
                ),
                HelpBox(
                  isShow: _showWarningBox,
                  iconPath: AppIcons.sadFace,
                  margin: const EdgeInsets.only(top: 8),
                  header: 'Too high than balance to pay!'.hardcoded,
                  text:
                      'Maybe there are other spending transactions before this day? If not a full payment, you must specify the balance after payment amount'
                          .hardcoded,
                ),
                HelpBox(
                  isShow: _showFYKBox1,
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'Close to balance to pay!'.hardcoded,
                  text: 'Is this a full payment? If so, please tick "Full Payment" below!'.hardcoded,
                ),
                HelpBox(
                  isShow: _showFYKBox2,
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'Pay amount is quite higher'.hardcoded,
                  text:
                      'Are there some hidden fee or some small transaction you forgot to add? If not a full payment, you must specify the balance after payment amount'
                          .hardcoded,
                ),
                HelpBox(
                  isShow: _showFYKBox3,
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'Exact balance to pay!'.hardcoded,
                ),
                CustomCheckbox(
                  onChanged: _onFullPaymentCheckboxChange,
                  label: 'Full payment',
                  showOptionalWidgetWhenValueIsFalse: true,
                  optionalWidget: Column(
                    children: [
                      InlineTextFormField(
                        prefixText: 'Bal. after payment:'.hardcoded,
                        suffixText: context.currentSettings.currency.code,
                        textSize: 14,
                        widget: CalculatorInput(
                          hintText: _totalBalanceAmount - (_userPaymentAmount ?? 0) > 0 &&
                                  _userPaymentAmount != null
                              ? CalService.formatCurrency(
                                  context, _totalBalanceAmount - (_userPaymentAmount ?? 0))
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

extension _Validators on _AddCreditPaymentModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_paymentCalOutputFormattedAmount) == null ||
      CalService.formatToDouble(_paymentCalOutputFormattedAmount) == 0 ||
      _fromRegularAccount == null;

  bool get _showFYKBox1 => _userPaymentAmount != null
      ? _userPaymentAmount! <= _totalBalanceAmount + (_totalBalanceAmount * 2.5 / 100) &&
          _userPaymentAmount! >= _totalBalanceAmount - (_totalBalanceAmount * 2.5 / 100) &&
          _userPaymentAmount! != _totalBalanceAmount
      : false;

  bool get _showFYKBox2 => _userPaymentAmount != null
      ? _userPaymentAmount! < _totalBalanceAmount + (_totalBalanceAmount * 10 / 100) &&
          _userPaymentAmount! > _totalBalanceAmount + (_totalBalanceAmount * 2.5 / 100)
      : false;

  bool get _showFYKBox3 =>
      _userPaymentAmount != null ? _userPaymentAmount! == _totalBalanceAmount : false;

  bool get _showWarningBox => _userPaymentAmount != null
      ? _userPaymentAmount! >= _totalBalanceAmount + (_totalBalanceAmount * 10 / 100)
      : false;

  String? _dateTimeValidator() {
    if (_dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _paymentInputValidator(BuildContext context) {
    if (_userPaymentAmount == null || _userPaymentAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    return null;
  }

  String? _remainingInputValidator(BuildContext context) {
    if (_statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }

    if (_userRemainingAmount != null && _userRemainingAmount! > _totalBalanceAmount) {
      return 'Invalid amount'.hardcoded;
    }

    // When user is not tick as full payment but not specify a remaining amount
    if (max(0, _totalBalanceAmount - (_userPaymentAmount ?? 0)) == 0) {
      return 'Invalid amount'.hardcoded;
    }

    //TODO: Show 'Balance adjusted icon' if this is not a full payment and user specified a remaining balance
    //TODO: Show 'Full payment icon' if this is a full payment
    //TODO: Change calculation of payment, now using 'afterAdjustedAmount'

    return null;
  }

  String? _creditAccountValidator() {
    if (_creditAccount == null) {
      return 'Must specify a credit account';
    }
    return null;
  }

  String? _fromRegularAccountValidator() {
    if (_fromRegularAccount == null) {
      return 'Must be specify for payment';
    }
    return null;
  }
}
