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
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/add_credit_payment_form_controller.dart';
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
  final _paymentInputController = TextEditingController();
  final _remainingInputController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  late final _stateController = ref.read(creditPaymentFormNotifierProvider.notifier);

  CreditPaymentFormState get _readState => ref.read(creditPaymentFormNotifierProvider);

  bool get _hidePayment => _readState.statement == null;
  String get _paymentCalOutputFormattedAmount => _paymentInputController.text;

  void _onPaymentInputChange(String value) {
    _paymentInputController.text = value;
    _remainingInputController.clear();
    _stateController.changePaymentInput(context, value);
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
    _stateController.changeRegularAccount(newAccount as RegularAccount?);
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate() && !_isNoNeedPayment(context)) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
            dateTime: _readState.dateTime!,
            amount: _readState.userPaymentAmount!,
            account: _readState.creditAccount!,
            fromAccount: _readState.fromRegularAccount!,
            note: _readState.note,
            isFullPayment: _readState.isFullPayment,
            adjustment: _readState.adjustment,
          );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchState = ref.watch(creditPaymentFormNotifierProvider);
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
                  creditAccount: watchState.creditAccount,
                  disableText: 'Choose credit account first'.hardcoded,
                  initialDate: watchState.dateTime,
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
                          chosenDateTime: watchState.dateTime?.onlyYearMonthDay,
                          statement: watchState.statement,
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
                    ],
                  ),
                ),
                Gap.h4,
                HelpBox(
                  isShow: _isPaymentTooHighThanBalance(context),
                  iconPath: AppIcons.sadFace,
                  margin: const EdgeInsets.only(top: 8),
                  header: 'Too high than balance to pay!'.hardcoded,
                  text:
                      'Maybe there are other spending transactions before this day? If not a full payment, you must specify the balance after payment amount'
                          .hardcoded,
                ),
                HelpBox(
                  isShow: _isPaymentQuiteHighThanBalance(context),
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
                  isShow: _isPaymentCloseToBalance(context),
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'Close to balance to pay!'.hardcoded,
                  text: 'Is this a full payment? If so, please tick "Full Payment" below!'.hardcoded,
                ),
                HelpBox(
                  isShow: _isPaymentEqualBalance(context),
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'Exact balance to pay!'.hardcoded,
                ),
                HelpBox(
                  isShow: _isNoNeedPayment(context),
                  iconPath: AppIcons.fykFace,
                  margin: const EdgeInsets.only(top: 8),
                  backgroundColor: context.appTheme.positive,
                  color: context.appTheme.onPositive,
                  header: 'No balance left to pay!'.hardcoded,
                ),
                !_isNoNeedPayment(context)
                    ? CustomCheckbox(
                        onChanged: _onToggleFullPaymentCheckbox,
                        label: 'Full payment',
                        showOptionalWidgetWhenValueIsFalse: true,
                        optionalWidget: Column(
                          children: [
                            InlineTextFormField(
                              prefixText: 'Bal. after payment:'.hardcoded,
                              suffixText: context.currentSettings.currency.code,
                              textSize: 14,
                              widget: CalculatorInput(
                                hintText: watchState.userPaymentAmount != null &&
                                        watchState.totalBalanceAmount.roundUsingAppSetting(context) -
                                                watchState.userPaymentAmount!.roundUsingAppSetting(context) >
                                            0
                                    ? CalService.formatCurrency(
                                        context, watchState.totalBalanceAmount - watchState.userPaymentAmount!)
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
              _stateController.changeNote(value);
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
      _readState.userPaymentAmount == null ||
      _readState.userPaymentAmount == 0 ||
      _readState.userRemainingAmount == 0 ||
      _readState.fromRegularAccount == null;

  bool _isPaymentCloseToBalance(BuildContext context) {
    if (_readState.userPaymentAmount != null) {
      double paymentAmount = _readState.userPaymentAmount!;
      double balanceAmount = _readState.totalBalanceAmount.roundUsingAppSetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount <= balanceAmount + (balanceAmount * 2.5 / 100) &&
          paymentAmount >= balanceAmount - (balanceAmount * 2.5 / 100) &&
          paymentAmount != balanceAmount;
    } else {
      return false;
    }
  }

  bool _isPaymentQuiteHighThanBalance(BuildContext context) {
    if (_readState.userPaymentAmount != null) {
      double paymentAmount = _readState.userPaymentAmount!;
      double balanceAmount = _readState.totalBalanceAmount.roundUsingAppSetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount < balanceAmount + (balanceAmount * 10 / 100) &&
          paymentAmount > balanceAmount + (balanceAmount * 2.5 / 100);
    } else {
      return false;
    }
  }

  bool _isPaymentEqualBalance(BuildContext context) {
    if (_readState.userPaymentAmount != null) {
      double paymentAmount = _readState.userPaymentAmount!;
      double balanceAmount = _readState.totalBalanceAmount.roundUsingAppSetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount == balanceAmount;
    } else {
      return false;
    }
  }

  bool _isPaymentTooHighThanBalance(BuildContext context) {
    if (_readState.userPaymentAmount != null) {
      double paymentAmount = _readState.userPaymentAmount!;
      double balanceAmount = _readState.totalBalanceAmount.roundUsingAppSetting(context);

      if (paymentAmount == 0 || balanceAmount == 0) {
        return false;
      }

      return paymentAmount >= balanceAmount + (balanceAmount * 10 / 100);
    } else {
      return false;
    }
  }

  bool _isNoNeedPayment(BuildContext context) {
    double balanceAmount = _readState.totalBalanceAmount.roundUsingAppSetting(context);

    return balanceAmount == 0;
  }

  String? _dateTimeValidator() {
    if (_readState.dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _paymentInputValidator(BuildContext context) {
    if (_readState.userPaymentAmount == null || _readState.userPaymentAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_readState.statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    return null;
  }

  String? _remainingInputValidator(BuildContext context) {
    if (_readState.statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }

    if (_readState.userRemainingAmount != null &&
        _readState.userRemainingAmount!.roundUsingAppSetting(context) >
            _readState.totalBalanceAmount.roundUsingAppSetting(context)) {
      return 'Higher than balance to pay'.hardcoded;
    }

    if (_readState.userRemainingAmount != null && _readState.userRemainingAmount == 0) {
      return 'Please tick as full payment'.hardcoded;
    }

    // When user is not tick as full payment but not specify a remaining amount
    if (_readState.isFullPayment == false &&
        _readState.userRemainingAmount == null &&
        _readState.userPaymentAmount != null &&
        _readState.totalBalanceAmount.roundUsingAppSetting(context) - _readState.userPaymentAmount! <= 0) {
      return 'Please specify an amount'.hardcoded;
    }

    return null;
  }

  String? _creditAccountValidator() {
    if (_readState.creditAccount == null) {
      return 'Must specify a credit account';
    }
    return null;
  }

  String? _fromRegularAccountValidator() {
    if (_readState.fromRegularAccount == null) {
      return 'Must be specify for payment';
    }
    return null;
  }
}
