import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/credit_payment_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
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
  final _controller = TextEditingController();
  Statement? _statement;

  ////////////////////// VALUE OUTPUT TO DATABASE /////////////////////////
  DateTime? _dateTime;
  String? _note;

  CreditAccount? _creditAccount;
  RegularAccount? _fromRegularAccount;

  double? get _outputAmount => CalService.formatToDouble(_calOutputFormattedAmount);

  //TODO: CONTINUE HERE!!!!!

  CreditPaymentType _type = CreditPaymentType.underMinimum;
  double? _adjustedBalance;
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
                CreditInfo(
                  isForPayment: true,
                  chosenDateTime: _dateTime?.onlyYearMonthDay,
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
                        validator: (_) => _calculatorValidator(context),
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
              ],
            ),
          ),
          _statement != null
              ? _PaymentAmountInfo(
                  statement: _statement,
                  minimumPayment: 150,
                  // onMinimumPaymentTap: () {},
                  // onFullPaymentTap: () {
                  //   _controller.text = _fullPaymentFormattedAmount(context);
                  // },
                )
              : Gap.noGap,
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

class _PaymentAmountInfo extends StatefulWidget {
  const _PaymentAmountInfo({
    required this.statement,
    required this.minimumPayment,
  });
  final Statement? statement;
  final double minimumPayment;

  @override
  State<_PaymentAmountInfo> createState() => _PaymentAmountInfoState();
}

class _PaymentAmountInfoState extends State<_PaymentAmountInfo> {
  final _key = GlobalKey();
  double _width = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _width = _key.currentContext!.size!.width;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          key: _key,
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.greyBgr(context),
          ),
        ),
        AnimatedContainer(
          duration: k250msDuration,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          height: 6,
          width: _width * 0.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: context.appTheme.primary,
          ),
        ),
      ],
    );
  }
}

extension _FunctionsAndGetters on _AddCreditPaymentModalScreenState {
  bool get _hidePayment => _statement == null;

  String get _calOutputFormattedAmount => _controller.text;

  double get _fullPaymentAmount =>
      _statement == null || _dateTime == null ? 0 : _statement!.getFullPaymentAmountAt(_dateTime!);

  String _fullPaymentFormattedAmount(BuildContext context) =>
      CalService.formatCurrency(context, _fullPaymentAmount, forceWithDecimalDigits: true);

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      ref.read(transactionRepositoryRealmProvider).writeNewCreditPayment(
            dateTime: _dateTime!,
            amount: _outputAmount!,
            account: _creditAccount!,
            fromAccount: _fromRegularAccount!,
            note: _note,
            type: _type,
            adjustedBalance: _adjustedBalance,
          );
      context.pop();
    }
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

  String? _calculatorValidator(BuildContext context) {
    if (_outputAmount == null || _outputAmount == 0) {
      return 'Invalid amount'.hardcoded;
    }
    if (_statement == null) {
      return 'No statement found in selected day'.hardcoded;
    }
    // if (_outputAmount! > CalService.formatToDouble(_fullPaymentFormattedAmount(context))!) {
    //   return 'Value is higher than full payment amount'.hardcoded;
    // }
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
