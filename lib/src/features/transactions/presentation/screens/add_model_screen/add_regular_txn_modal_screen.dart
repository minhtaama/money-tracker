import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/transactions/data/template_transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/components/related_budget.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/regular_txn_form_controller.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../theme_and_ui/icons.dart';
import '../../../../accounts/domain/account_base.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../../selectors/presentation/forms.dart';

class AddRegularTxnModalScreen extends ConsumerStatefulWidget {
  const AddRegularTxnModalScreen(this.controller, this.isScrollable, this.transactionType, {super.key});

  final ScrollController controller;
  final bool isScrollable;
  final TransactionType transactionType;

  @override
  ConsumerState<AddRegularTxnModalScreen> createState() => _AddTransactionModalScreenState();
}

class _AddTransactionModalScreenState extends ConsumerState<AddRegularTxnModalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _stateController = ref.read(regularTransactionFormNotifierProvider(widget.transactionType).notifier);
  RegularTransactionFormState get _stateRead =>
      ref.read(regularTransactionFormNotifierProvider(widget.transactionType));

  bool _isTemplateSubmitted = false;

  TemplateTransaction? _templateTransaction;

  String get _title {
    return widget.transactionType == TransactionType.income
        ? 'Add Income'.hardcoded
        : widget.transactionType == TransactionType.expense
            ? 'Add Expense'.hardcoded
            : 'Add Transfer'.hardcoded;
  }

  String get _secondaryTitle {
    return widget.transactionType == TransactionType.transfer
        ? 'Between regular accounts'.hardcoded
        : 'For regular accounts'.hardcoded;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final transactionRepo = ref.read(transactionRepositoryRealmProvider);

      if (widget.transactionType == TransactionType.income) {
        transactionRepo.writeNewIncome(
          dateTime: _stateRead.dateTime!,
          amount: _stateRead.amount!,
          category: _stateRead.category!,
          tag: _stateRead.tag,
          account: _stateRead.account!,
          note: _stateRead.note,
        );
      }
      if (widget.transactionType == TransactionType.expense) {
        transactionRepo.writeNewExpense(
          dateTime: _stateRead.dateTime!,
          amount: _stateRead.amount!,
          category: _stateRead.category!,
          tag: _stateRead.tag,
          account: _stateRead.account!,
          note: _stateRead.note,
        );
      }
      if (widget.transactionType == TransactionType.transfer) {
        transactionRepo.writeNewTransfer(
            dateTime: _stateRead.dateTime!,
            amount: _stateRead.amount!,
            account: _stateRead.account!,
            toAccount: _stateRead.toAccount!,
            note: _stateRead.note,
            fee: null,
            isChargeOnDestinationAccount: null);
        // TODO: add transfer fee logic
      }

      context.pop();
    }
  }

  void _submitTemplate() {
    final tempTxnRepo = ref.read(tempTransactionRepositoryRealmProvider);
    if (!_stateRead.isAllNull() && !_isTemplateSubmitted) {
      setState(() {
        _isTemplateSubmitted = true;
      });

      _templateTransaction = tempTxnRepo.writeNew(
        transactionType: widget.transactionType,
        dateTime: _stateRead.dateTime,
        amount: _stateRead.amount,
        category: _stateRead.category,
        tag: _stateRead.tag,
        account: _stateRead.account,
        toAccount: _stateRead.toAccount,
        note: _stateRead.note,
        fee: null,
        isChargeOnDestinationAccount: null,
      );
    } else if (_isTemplateSubmitted && _templateTransaction != null) {
      setState(() {
        _isTemplateSubmitted = false;
      });

      tempTxnRepo.delete(_templateTransaction!);
      _templateTransaction = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(regularTransactionFormNotifierProvider(widget.transactionType));

    return ModalContent(
      formKey: _formKey,
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: _title,
        secondaryTitle: _secondaryTitle,
        trailing: RoundedIconButton(
          iconPath: _isTemplateSubmitted ? AppIcons.heartFill : AppIcons.heartOutline,
          withBorder: false,
          backgroundColor: Colors.transparent,
          iconColor: stateWatch.isAllNull() ? AppColors.grey(context) : context.appTheme.primary,
          iconPadding: 10,
          onTap: _submitTemplate,
        ),
      ),
      footer: ModalFooter(
        isBigButtonDisabled: _isButtonDisabled,
        onBigButtonTap: _submit,
      ),
      body: [
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
                    _isTemplateSubmitted = false;
                  });
                  _stateController.changeAmount(value);
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
                onChanged: (DateTime value) => _stateController.changeDateTime(value),
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
                              _isTemplateSubmitted = false;
                            });
                            _stateController.changeCategory(newCategory);
                          },
                        )
                      : AccountFormSelector(
                          accountType: AccountType.regular,
                          validator: (_) => _sendingAccountValidator(),
                          onChangedAccount: (newAccount) {
                            setState(() {
                              _isTemplateSubmitted = false;
                            });
                            _stateController.changeAccount(newAccount as RegularAccount);
                          },
                          otherSelectedAccount: stateWatch.account,
                        ),
                  Gap.h16,
                  TextHeader(widget.transactionType != TransactionType.transfer ? 'Account:' : 'To:'),
                  Gap.h4,
                  AccountFormSelector(
                    accountType: AccountType.regular,
                    validator: (_) => _toAccountAndAccountValidator(),
                    onChangedAccount: (newAccount) {
                      setState(() {
                        _isTemplateSubmitted = false;
                      });
                      if (widget.transactionType != TransactionType.transfer) {
                        _stateController.changeAccount(newAccount as RegularAccount?);
                      } else {
                        _stateController.changeToAccount(newAccount as RegularAccount?);
                      }
                    },
                    otherSelectedAccount:
                        widget.transactionType == TransactionType.transfer ? stateWatch.account : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap.h16,
        // TODO: Show budget service widget here
        widget.transactionType == TransactionType.expense
            ? RelatedBudget(transactionType: widget.transactionType)
            : Gap.noGap,
        Gap.h16,
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: TextHeader('OPTIONAL:', fontSize: 11),
        ),
        Gap.h4,
        widget.transactionType != TransactionType.transfer
            ? CategoryTagSelector(
                category: stateWatch.category,
                onTagSelected: (value) {
                  setState(() {
                    _isTemplateSubmitted = false;
                  });
                  _stateController.changeCategoryTag(value);
                },
              )
            : Gap.noGap,
        widget.transactionType != TransactionType.transfer ? Gap.h8 : Gap.noGap,
        CustomTextFormField(
          autofocus: false,
          focusColor: context.appTheme.accent1,
          withOutlineBorder: true,
          maxLines: 3,
          hintText: 'Note ...',
          textInputAction: TextInputAction.done,
          onChanged: (value) {
            setState(() {
              _isTemplateSubmitted = false;
            });
            _stateController.changeNote(value);
          },
        ),
      ],
    );
  }
}

extension _Validators on _AddTransactionModalScreenState {
  bool get _isButtonDisabled =>
      _stateRead.amount == null ||
      _stateRead.amount == 0 ||
      _stateRead.category == null && widget.transactionType != TransactionType.transfer ||
      _stateRead.toAccount == null && widget.transactionType == TransactionType.transfer ||
      _stateRead.account == null;

  String? _calculatorValidator() {
    if (_stateRead.amount == null || _stateRead.amount == 0) {
      return 'Invalid amount';
    }
    return null;
  }

  String? _categoryValidator() {
    if (_stateRead.category == null && widget.transactionType != TransactionType.transfer) {
      return 'Must specify a category'.hardcoded;
    }
    return null;
  }

  String? _sendingAccountValidator() {
    if (_stateRead.account == null) {
      return 'Must specify a sending account'.hardcoded;
    }
    return null;
  }

  String? _toAccountAndAccountValidator() {
    if (widget.transactionType != TransactionType.transfer && _stateRead.account == null) {
      return 'Must specify an account for payment'.hardcoded;
    }
    if (widget.transactionType == TransactionType.transfer && _stateRead.toAccount == null) {
      return 'Must specify a destination account'.hardcoded;
    }
    return null;
  }
}
