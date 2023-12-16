import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../calculator_input/presentation/calculator_input.dart';
import '../../../category/domain/category.dart';
import '../../../category/domain/category_tag.dart';
import '../selectors/forms.dart';

class AddRegularTxnModalScreen extends ConsumerStatefulWidget {
  const AddRegularTxnModalScreen(this.transactionType, {super.key});
  final TransactionType transactionType;

  @override
  ConsumerState<AddRegularTxnModalScreen> createState() => _AddTransactionModalScreenState();
}

class _AddTransactionModalScreenState extends ConsumerState<AddRegularTxnModalScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TransactionType _type = widget.transactionType;
  late DateTime _dateTime = DateTime.now();
  String _calculatorOutput = '0';
  String? _note;
  CategoryTag? _tag;
  Category? _category;
  RegularAccount? _account;
  RegularAccount? _toAccount;

  String get _title {
    return widget.transactionType == TransactionType.income
        ? 'Add Income'
        : widget.transactionType == TransactionType.expense
            ? 'Add Expense'
            : 'Transfer between accounts';
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transactionRepo = ref.read(transactionRepositoryRealmProvider);

      if (_type == TransactionType.income) {
        transactionRepo.writeNewIncome(
          dateTime: _dateTime,
          amount: CalService.formatToDouble(_calculatorOutput)!,
          category: _category!,
          tag: _tag,
          account: _account!,
          note: _note,
        );
      }
      if (_type == TransactionType.expense) {
        transactionRepo.writeNewExpense(
          dateTime: _dateTime,
          amount: CalService.formatToDouble(_calculatorOutput)!,
          category: _category!,
          tag: _tag,
          account: _account!,
          note: _note,
        );
      }
      if (_type == TransactionType.transfer) {
        transactionRepo.writeNewTransfer(
            dateTime: _dateTime,
            amount: CalService.formatToDouble(_calculatorOutput)!,
            account: _account!,
            toAccount: _toAccount!,
            note: _note,
            fee: null,
            isChargeOnDestinationAccount: null);
        // TODO: add transfer fee logic
      }
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CustomSection(
        title: _title,
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
                  hintText: 'Amount',
                  focusColor: context.appTheme.primary,
                  validator: (_) => _calculatorValidator(),
                  formattedResultOutput: (value) {
                    setState(() {
                      _calculatorOutput = value;
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
                  onChanged: (DateTime value) {
                    _dateTime = value;
                  },
                ),
              ),
              Gap.w24,
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextHeader(widget.transactionType != TransactionType.transfer ? 'Category:' : 'From:'),
                    Gap.h4,
                    widget.transactionType != TransactionType.transfer
                        ? CategoryFormSelector(
                            transactionType: widget.transactionType,
                            validator: (_) => _categoryValidator(),
                            onChangedCategory: (newCategory) {
                              setState(() {
                                _category = newCategory;
                              });
                            })
                        : AccountFormSelector(
                            accountType: AccountType.regular,
                            validator: (_) => _sendingAccountValidator(),
                            onChangedAccount: (newAccount) {
                              setState(() {
                                _account = newAccount as RegularAccount;
                              });
                            },
                            otherSelectedAccount: _toAccount,
                          ),
                    Gap.h16,
                    TextHeader(widget.transactionType != TransactionType.transfer ? 'Account:' : 'To:'),
                    Gap.h4,
                    AccountFormSelector(
                      accountType: AccountType.regular,
                      validator: (_) => _toAccountAndAccountValidator(),
                      onChangedAccount: (newAccount) {
                        if (widget.transactionType != TransactionType.transfer) {
                          setState(() {
                            _account = newAccount as RegularAccount;
                          });
                        } else {
                          setState(() {
                            _toAccount = newAccount as RegularAccount;
                          });
                        }
                      },
                      otherSelectedAccount: widget.transactionType == TransactionType.transfer ? _account : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap.h16,
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: TextHeader('OPTIONAL:', fontSize: 11),
          ),
          Gap.h4,
          widget.transactionType != TransactionType.transfer
              ? CategoryTagSelector(
                  category: _category,
                  onTagSelected: (value) {
                    _tag = value;
                  })
              : Gap.noGap,
          widget.transactionType != TransactionType.transfer ? Gap.h8 : Gap.noGap,
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
          BottomButtons(isBigButtonDisabled: _isButtonDisabled, onBigButtonTap: _submit),
        ],
      ),
    );
  }
}

extension _Validators on _AddTransactionModalScreenState {
  bool get _isButtonDisabled =>
      CalService.formatToDouble(_calculatorOutput) == null ||
      CalService.formatToDouble(_calculatorOutput) == 0 ||
      _category == null && widget.transactionType != TransactionType.transfer ||
      _toAccount == null && widget.transactionType == TransactionType.transfer ||
      _account == null;

  String? _calculatorValidator() {
    if (CalService.formatToDouble(_calculatorOutput) == null || CalService.formatToDouble(_calculatorOutput) == 0) {
      return 'Invalid amount';
    }
    return null;
  }

  String? _categoryValidator() {
    if (_category == null && widget.transactionType != TransactionType.transfer) {
      return 'Must specify a category'.hardcoded;
    }
    return null;
  }

  String? _sendingAccountValidator() {
    if (_account == null) {
      return 'Must specify a sending account'.hardcoded;
    }
    return null;
  }

  String? _toAccountAndAccountValidator() {
    if (widget.transactionType != TransactionType.transfer && _account == null) {
      return 'Must specify an account for payment'.hardcoded;
    }
    if (widget.transactionType == TransactionType.transfer && _toAccount == null) {
      return 'Must specify a destination account'.hardcoded;
    }
    return null;
  }
}
