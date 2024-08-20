part of 'transaction_details_modal_screen.dart';

class _SpendingDetails extends ConsumerStatefulWidget {
  const _SpendingDetails(this.screenType, this.controller, this.isScrollable, {required this.transaction});

  final CreditSpending transaction;
  final TransactionScreenType screenType;

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<_SpendingDetails> createState() => _SpendingDetailsState();
}

class _SpendingDetailsState extends ConsumerState<_SpendingDetails> {
  final _installmentPaymentController = TextEditingController();

  bool _isEditMode = false;
  late final bool _canDelete;

  late CreditSpending _transaction = widget.transaction;

  late final _creditAccount =
      ref.read(accountRepositoryProvider).getAccount(_transaction.account.databaseObject) as CreditAccount;

  late final _stateController = ref.read(creditSpendingFormNotifierProvider.notifier);

  @override
  void initState() {
    try {
      _creditAccount.getNextPayment(from: _transaction);
      _canDelete = false;
    } catch (e) {
      _canDelete = true;
    }

    super.initState();
  }

  @override
  void didUpdateWidget(covariant _SpendingDetails oldWidget) {
    setState(() {
      _transaction = widget.transaction;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(creditSpendingFormNotifierProvider);

    return ModalContent(
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: context.loc.creditSpending,
        trailing: widget.screenType == TransactionScreenType.editable
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EditButton(
                    isEditMode: _isEditMode,
                    onTap: () {
                      if (_isEditMode) {
                        if (_submit()) {
                          setState(() {
                            _isEditMode = !_isEditMode;
                          });
                        }
                      } else {
                        setState(() {
                          _isEditMode = !_isEditMode;
                        });
                      }
                    },
                  ),
                  _DeleteButton(
                    isEditMode: _isEditMode,
                    isDisable: !_canDelete,
                    disableText: context.loc.quoteTransaction9,
                    onConfirm: _delete,
                  ),
                ],
              )
            : null,
      ),
      body: [
        _Amount(
          isEditMode: _canEditAmount(stateWatch) ? _isEditMode : false,
          isEdited: _isAmountEdited(stateWatch),
          transactionType: TransactionType.creditSpending,
          amount: stateWatch.amount ?? _transaction.amount,
          onEditModeTap: _changeAmount,
        ),
        _DateTime(
          isEditMode: _isEditMode,
          isEdited: _isDateTimeEdited(stateWatch),
          dateTime: stateWatch.dateTime ?? _transaction.dateTime,
          onEditModeTap: _changeDateTime,
        ),
        Gap.h16,
        _InstallmentOfSpendingDetails(
          isEditMode: _canEditInstallmentDetails(stateWatch) ? _isEditMode : false,
          isEdited: _isInstallmentEdited(stateWatch),
          installmentController: _installmentPaymentController,
          transaction: _transaction,
          initialValues: [
            _transaction.hasInstallment,
            _transaction.paymentAmount,
            _transaction.monthsToPay,
            _transaction.paymentStartFromNextStatement,
          ],
          onToggle: _onToggleHasInstallment,
          onFormattedInstallmentOutput: _changeInstallmentAmount,
          onMonthOutput: _changeInstallmentPeriod,
          onChangePaymentStartFromNextStatement: _changePaymentStartFromNextStatement,
        ),
        Gap.h32,
        _AccountCard(isEditMode: false, account: widget.transaction.account),
        Gap.h12,
        _CategoryCard(
          isEditMode: _isEditMode,
          isEdited: _isCategoryEdited(stateWatch),
          category: stateWatch.category ?? _transaction.category,
          categoryTag: stateWatch.tag ?? _transaction.categoryTag,
          onEditModeTap: _changeCategory,
        ),
        Gap.h12,
        _Note(
          isEditMode: _isEditMode,
          isEdited: _isNoteEdited(stateWatch),
          note: stateWatch.note ?? _transaction.note,
          onEditModeChanged: _changeNote,
        ),
        Gap.h16,
      ],
      footer: Gap.noGap,
    );
  }
}

extension _SpendingDetailsStateMethod on _SpendingDetailsState {
  CreditSpendingFormState get _stateRead => ref.read(creditSpendingFormNotifierProvider);

  void _changeCategory() async {
    final returnedCategory = await showCustomModal<List<dynamic>>(
      context: context,
      child: _CategoryEditSelector(
          transaction: _transaction,
          category: _stateRead.category ?? _transaction.category,
          tag: _stateRead.tag ?? _transaction.categoryTag),
    );

    if (returnedCategory != null) {
      _stateController.changeCategory(returnedCategory[0] as Category?);
      _stateController.changeCategoryTag(returnedCategory[1] as CategoryTag?);
    }
  }

  void _changeAmount() async {
    final newAmount = await showCalculatorModalScreen(
      context,
      title: context.loc.spendingAmount,
      initialValue: _stateRead.amount ?? _transaction.amount,
    );

    if (newAmount != null && mounted) {
      _stateController.changeAmount(newAmount, initialTransaction: _transaction);
      _changeInstallmentControllerText();
    }
  }

  void _onToggleHasInstallment(bool value) {
    _stateController.changeEditHasInstallment(value);
    _changeInstallmentControllerText();
  }

  void _changeInstallmentAmount(String value) {
    _stateController.changeInstallmentAmount(value);
  }

  void _changeInstallmentPeriod(String value) {
    _stateController.changeInstallmentPeriod(int.tryParse(value), initialTransaction: _transaction);
    _changeInstallmentControllerText();
  }

  void _changePaymentStartFromNextStatement(bool value) {
    _stateController.changePaymentStartFromNextStatement(value);
  }

  void _changeInstallmentControllerText() =>
      _installmentPaymentController.text = _stateRead.installmentAmountString(context) ?? '0';

  void _changeDateTime() async {
    final statement = _creditAccount.statementAt(_transaction.dateTime, upperGapAtDueDate: true);

    final newDateTime = await showCreditSpendingDateTimeEditDialog(
      context,
      creditAccount: _creditAccount,
      statement: statement!,
      dbDateTime: _transaction.dateTime,
      selectedDateTime: _stateRead.dateTime,
    );

    if (newDateTime != null) {
      _stateController.changeDateTime(newDateTime);
    }
  }

  void _changeNote(String value) => _stateController.changeNote(value);

  bool _isCategoryEdited(CreditSpendingFormState state) =>
      (state.category != null || state.tag != null) &&
      (state.category != _transaction.category || state.tag != _transaction.categoryTag);

  bool _isAmountEdited(CreditSpendingFormState state) => state.amount != null && state.amount != _transaction.amount;

  bool _isDateTimeEdited(CreditSpendingFormState state) =>
      state.dateTime != null && state.dateTime != _transaction.dateTime;

  bool _isNoteEdited(CreditSpendingFormState state) => state.note != null && state.note != _transaction.note;

  bool _isInstallmentEdited(CreditSpendingFormState state) =>
      state.installmentPeriod != null || state.installmentAmount != null;

  bool _canEditAmount(CreditSpendingFormState state) =>
      (state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay)
          .isAfter(_creditAccount.latestClosedStatementDueDate) &&
      (state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay)
          .isAfter(_creditAccount.latestCheckpointDateTime);

  bool _canEditInstallmentDetails(CreditSpendingFormState state) {
    final currentDateTime = state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay;
    final isAfterLatestPayment = _creditAccount.paymentTransactions.isNotEmpty
        ? currentDateTime.isAfter(_creditAccount.paymentTransactions.last.dateTime)
        : true;

    return currentDateTime.isAfter(_creditAccount.latestClosedStatementDueDate) &&
        currentDateTime.isAfter(_creditAccount.latestCheckpointDateTime) &&
        isAfterLatestPayment;
  }

  bool _submit() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.editCreditSpending(_transaction, state: _stateRead);

    _stateController.setStateToAllNull();

    return true;
  }

  void _delete() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.deleteTransaction(_transaction);

    context.pop();
  }
}
