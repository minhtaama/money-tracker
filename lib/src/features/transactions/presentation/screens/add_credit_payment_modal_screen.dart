import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../selectors/forms.dart';

class AddCreditPaymentModalScreen extends ConsumerStatefulWidget {
  const AddCreditPaymentModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditPaymentModalScreen> createState() => _AddCreditPaymentModalScreenState();
}

class _AddCreditPaymentModalScreenState extends ConsumerState<AddCreditPaymentModalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  Statement? _statement;

  ////////////////////// OUTPUT TO DATABASE VALUE ///////////////////////
  DateTime? _dateTime;

  String? _note;
  CreditAccount? _creditAccount;
  RegularAccount? _fromRegularAccount;

  double? get _outputAmount => CalService.formatToDouble(_calOutputFormattedAmount);
  ///////////////////////////////////////////////////////////////////////

  String get _calOutputFormattedAmount => _controller.text;

  double get _fullPaymentAmount =>
      _statement == null || _dateTime == null ? 0 : _statement!.getPaymentAmountAt(_dateTime!);

  String get _fullPaymentFormattedAmount => CalService.formatCurrency(_fullPaymentAmount);

  bool get _hidePayment => _statement == null;

  @override
  void dispose() {
    super.dispose();
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
          dateTime: _dateTime!,
          amount: _outputAmount!,
          account: _creditAccount!,
          fromAccount: _fromRegularAccount!,
          note: _note);
      context.pop();
    }
  }

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
                  onChanged: (dateTime, statement) {
                    if (dateTime != null) {
                      _dateTime = dateTime;
                    }
                    _statement = statement;
                    setState(() {});
                  },
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
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _creditAccount = newAccount as CreditAccount?;
                          if (_creditAccount == null) {
                            _statement = null;
                            _dateTime = null;
                          }
                        });
                      },
                    ),
                    Gap.h8,
                    const TextHeader('Payment account:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
                      validator: (_) => _fromRegularAccountValidator(),
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _fromRegularAccount = newAccount as RegularAccount;
                        });
                      },
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
              children: [
                CreditPaymentInfo(
                  chosenDateTime: _dateTime,
                  noBorder: false,
                  statement: _statement,
                ),
                Gap.h16,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CurrencyIcon(),
                    Gap.w16,
                    Expanded(
                      child: CalculatorInput(
                        hintText: 'Payment Amount',
                        controller: _controller,
                        focusColor: context.appTheme.primary,
                        validator: (_) => _calculatorValidator(),
                        formattedResultOutput: (value) {
                          setState(() {
                            _controller.text = value;
                          });
                        },
                      ),
                    ),
                    Gap.w8,
                  ],
                ),
                Gap.h16,
                _PaymentAmountTip(onMinimumPaymentTap: (value) {}, onFullPaymentTap: (value) {}),
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

class _PaymentAmountTip extends StatelessWidget {
  const _PaymentAmountTip({
    required this.onMinimumPaymentTap,
    required this.onFullPaymentTap,
  });
  final ValueSetter<double> onMinimumPaymentTap;
  final ValueSetter<double> onFullPaymentTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: IconWithTextButton(
            iconPath: AppIcons.coins,
            label: 'Full payment',
            labelSize: 12,
            iconSize: 25,
            height: null,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            backgroundColor: context.appTheme.primary,
            color: context.appTheme.primaryNegative,
            onTap: () => onFullPaymentTap(2),
          ),
        ),
        Gap.w8,
        Expanded(
          child: IconWithTextButton(
            iconPath: AppIcons.coins,
            label: 'Min payment',
            labelSize: 12,
            iconSize: 25,
            height: null,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            backgroundColor: AppColors.greyBgr(context),
            color: context.appTheme.backgroundNegative,
            onTap: () => onMinimumPaymentTap(1),
          ),
        ),
      ],
    );
  }
}

extension _Validators on _AddCreditPaymentModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_calOutputFormattedAmount) == null ||
      CalService.formatToDouble(_calOutputFormattedAmount) == 0 ||
      _fromRegularAccount == null;

  String? _dateTimeValidator() {
    if (_dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _calculatorValidator() {
    if (_outputAmount == null || _outputAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    if (_statement!.remainingBalance <= 0) {
      return 'This statement has paid in full'.hardcoded;
    }
    if (_outputAmount! > _fullPaymentAmount) {
      return 'Value is higher than $_fullPaymentFormattedAmount';
    }
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
