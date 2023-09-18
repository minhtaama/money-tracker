import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/features/transactions/domain/transaction.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/screens/screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/transactions_list.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../accounts/domain/account.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../selectors/forms.dart';

class AddCreditPaymentModalScreen extends ConsumerStatefulWidget {
  const AddCreditPaymentModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddCreditPaymentModalScreen> createState() => _AddCreditPaymentModalScreenState();
}

class _AddCreditPaymentModalScreenState extends ConsumerState<AddCreditPaymentModalScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _dateTime;
  List<CreditSpending> _creditSpendingList = List.empty(growable: true);

  String? _note;
  CreditAccount? _creditAccount;
  Account? _fromRegularAccount;

  String _calOutputSpendAmount = '0';

  @override
  void dispose() {
    super.dispose();
  }

  void _submit() {
    // By validating, no important value can be null
    if (_formKey.currentState!.validate()) {
      // ref.read(transactionRepositoryProvider).writeNewCreditSpendingTxn(
      //       dateTime: dateTime,
      //       amount: _formatToDouble(calOutputSpendAmount)!,
      //       tag: tag,
      //       note: note,
      //       category: category!,
      //       account: account!,
      //       installment: installment,
      //     );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsObject = ref.watch(settingsControllerProvider);

    return Form(
      key: _formKey,
      child: CustomSection(
        title: 'Add Credit Payment',
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
                  hintText: 'Payment Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) => _calculatorValidator(),
                  formattedResultOutput: (value) {
                    setState(() {
                      _calOutputSpendAmount = value;
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
                child: CreditDateTimeFormSelector(
                  creditAccount: _creditAccount,
                  disableText: 'Choose credit account first'.hardcoded,
                  onChanged: (dateTime, creditSpendingsList) {
                    if (dateTime != null) {
                      _dateTime = dateTime;
                    }
                    _creditSpendingList = List.from(creditSpendingsList);
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
                    const TextHeader('Pay to credit account:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.credit,
                      validator: (_) => _creditAccountValidator(),
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _creditAccount = newAccount as CreditAccount?;
                        });
                      },
                    ),
                    Gap.h8,
                    const TextHeader('From:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
                      validator: (_) => _payingAccountValidator(),
                      onChangedAccount: (newAccount) {
                        setState(() {
                          _fromRegularAccount = newAccount;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h8,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Credit Spendings:',
              style:
                  kHeader2TextStyle.copyWith(fontSize: 15, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
            ),
          ),
          Gap.h4,
          //CreditPaymentPeriodSelector(onChangedPeriod: (list) {}),
          TransactionsList(transactions: _creditSpendingList, currencyCode: settingsObject.currency.code),
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
          BottomButtons(isDisabled: _isButtonDisable, onTap: _submit)
        ],
      ),
    );
  }
}

extension _Validators on _AddCreditPaymentModalScreenState {
  bool get _isButtonDisable =>
      CalService.formatToDouble(_calOutputSpendAmount) == null ||
      CalService.formatToDouble(_calOutputSpendAmount) == 0 ||
      _fromRegularAccount == null;

  String? _dateTimeValidator() {
    if (_dateTime == null) {
      return 'Please select a date';
    }
    return null;
  }

  String? _calculatorValidator() {
    if (CalService.formatToDouble(_calOutputSpendAmount) == null ||
        CalService.formatToDouble(_calOutputSpendAmount) == 0) {
      return 'Invalid amount';
    }
    return null;
  }

  String? _creditAccountValidator() {
    if (_creditAccount == null) {
      return 'Must specify a credit account';
    }
    return null;
  }

  String? _payingAccountValidator() {
    if (_fromRegularAccount == null) {
      return 'Must be specify for payment';
    }
    return null;
  }
}
