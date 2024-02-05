part of 'transaction_details_modal_screen.dart';

class _SpendingDetails extends ConsumerStatefulWidget {
  const _SpendingDetails(this.screenType, {required this.transaction});

  final CreditSpending transaction;
  final TransactionScreenType screenType;

  @override
  ConsumerState<_SpendingDetails> createState() => _SpendingDetailsState();
}

class _SpendingDetailsState extends ConsumerState<_SpendingDetails> {
  final _installmentPaymentController = TextEditingController();

  bool _isEditMode = false;
  late final bool _canDelete;

  late CreditSpending _transaction = widget.transaction;

  late final _creditAccount =
      ref.read(accountRepositoryProvider).getAccount(_transaction.account!.databaseObject) as CreditAccount;

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

    return CustomSection(
      title: 'Credit Spending'.hardcoded,
      subTitle: _DateTime(
        isEditMode: _isEditMode,
        isEdited: _isDateTimeEdited(stateWatch),
        dateTime: stateWatch.dateTime ?? _transaction.dateTime,
        onEditModeTap: _changeDateTime,
      ),
      subIcons: widget.screenType == TransactionScreenType.editable
          ? [
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
                disableText: 'Can not delete because there are payment(s) after this transaction'.hardcoded,
                onConfirm: _delete,
              )
            ]
          : null,
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _canEditAmount(stateWatch) ? _isEditMode : false,
          isEdited: _isAmountEdited(stateWatch),
          transactionType: TransactionType.creditSpending,
          amount: stateWatch.amount ?? _transaction.amount,
          onEditModeTap: _changeAmount,
        ),
        Gap.h12,
        _InstallmentOfSpendingDetails(
            isEditMode: _canEditAmount(stateWatch) ? _isEditMode : false,
            isEdited: _isInstallmentEdited(stateWatch),
            installmentController: _installmentPaymentController,
            transaction: _transaction,
            initialValues: [
              _transaction.hasInstallment,
              _transaction.paymentAmount,
              _transaction.monthsToPay,
            ],
            onToggle: _onToggleHasInstallment,
            onFormattedInstallmentOutput: _changeInstallmentAmount,
            onMonthOutput: _changeInstallmentPeriod),
        Gap.h8,
        Gap.divider(context, indent: 6),
        _AccountCard(isEditMode: false, account: widget.transaction.account!),
        _CategoryCard(
          isEditMode: _isEditMode,
          isEdited: _isCategoryEdited(stateWatch),
          category: stateWatch.category ?? _transaction.category!,
          categoryTag: stateWatch.tag ?? _transaction.categoryTag,
          onEditModeTap: _changeCategory,
        ),
        _Note(
          isEditMode: _isEditMode,
          isEdited: _isNoteEdited(stateWatch),
          note: stateWatch.note ?? _transaction.note,
          onEditModeChanged: _changeNote,
        ),
        Gap.h16,
      ],
    );
  }
}

extension _SpendingDetailsStateMethod on _SpendingDetailsState {
  CreditSpendingFormState get _stateRead => ref.read(creditSpendingFormNotifierProvider);

  void _changeCategory() async {
    final returnedCategory = await showCustomModalBottomSheet<List<dynamic>>(
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
      initialValue: _stateRead.amount ?? _transaction.amount,
    );

    if (newAmount != null && mounted) {
      _stateController.changeAmount(context, newAmount, initialTransaction: _transaction);
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
    _stateController.changeInstallmentPeriod(context, int.tryParse(value), initialTransaction: _transaction);
    _changeInstallmentControllerText();
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
          .isAfter(_creditAccount.latestStatementDueDate) &&
      (state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay)
          .isAfter(_creditAccount.latestCheckpointDateTime);

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
