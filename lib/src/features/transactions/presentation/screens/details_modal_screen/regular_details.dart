part of 'transaction_details_modal_screen.dart';

class _RegularDetails extends ConsumerStatefulWidget {
  const _RegularDetails(this.screenType, {required this.transaction});

  final BaseRegularTransaction transaction;
  final TransactionScreenType screenType;

  @override
  ConsumerState<_RegularDetails> createState() => _RegularDetailsState();
}

class _RegularDetailsState extends ConsumerState<_RegularDetails> {
  bool _isEditMode = false;

  late BaseRegularTransaction _transaction = widget.transaction;

  late final _stateController = ref.read(regularTransactionFormNotifierProvider(null).notifier);

  @override
  void didUpdateWidget(covariant _RegularDetails oldWidget) {
    setState(() {
      _transaction = widget.transaction;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(regularTransactionFormNotifierProvider(null));

    return CustomSection(
      title: _title,
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
                onConfirm: _delete,
              ),
            ]
          : null,
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
          isEdited: _isAmountEdited(stateWatch),
          transactionType: _transaction.type,
          amount: stateWatch.amount ?? _transaction.amount,
          onEditModeTap: _changeAmount,
        ),
        Gap.h8,
        Gap.divider(context, indent: 6),
        Gap.h8,
        Row(
          children: [
            _transaction is Transfer
                ? const TxnTransferLine(
                    height: 100,
                    width: 30,
                    strokeWidth: 1.5,
                    opacity: 0.5,
                  )
                : Gap.noGap,
            _transaction is Transfer ? Gap.w4 : Gap.noGap,
            Expanded(
              child: Column(
                children: [
                  _AccountCard(
                    isEditMode: (_transaction is Income && (_transaction as Income).isInitialTransaction)
                        ? false
                        : _isEditMode,
                    isEdited: _isAccountEdited(stateWatch),
                    account: stateWatch.account ?? _transaction.account!,
                    onEditModeTap: _changeAccount,
                  ),
                  Gap.h12,
                  switch (_transaction) {
                    IBaseTransactionWithCategory() =>
                      _transaction is Income && (_transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              isEdited: _isCategoryEdited(stateWatch),
                              category: stateWatch.category ??
                                  (_transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: stateWatch.tag ??
                                  (_transaction as IBaseTransactionWithCategory).categoryTag,
                              onEditModeTap: _changeCategory,
                            ),
                    Transfer() => _AccountCard(
                        isEditMode: _isEditMode,
                        isEdited: _isToAccountEdited(stateWatch),
                        account: stateWatch.toAccount ?? (_transaction as Transfer).transferAccount!,
                        onEditModeTap: _changeToAccount,
                      ),
                  },
                ],
              ),
            ),
          ],
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
    );
  }
}

extension _RegularDetailsStateMethod on _RegularDetailsState {
  RegularTransactionFormState get _stateRead => ref.read(regularTransactionFormNotifierProvider(null));

  String get _title {
    return switch (_transaction) {
      Income() =>
        (_transaction as Income).isInitialTransaction ? 'Initial Balance'.hardcoded : 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
    };
  }

  void _changeAccount() async {
    List<Account> accountList = ref.read(accountRepositoryProvider).getList(AccountType.regular);

    final returnedValue = await showCustomModalBottomSheet<Account>(
      context: context,
      child: _ModelWithIconEditSelector(
        title: 'Change Origin:',
        selectedItem: _stateRead.account ?? _transaction.account,
        list: accountList,
      ),
    );

    _stateController.changeAccount(returnedValue as RegularAccount?);
  }

  void _changeToAccount() async {
    List<Account> accountList = ref.read(accountRepositoryProvider).getList(AccountType.regular);

    final returnedValue = await showCustomModalBottomSheet<Account>(
      context: context,
      child: _ModelWithIconEditSelector(
        title: 'Change Destination:',
        selectedItem: _stateRead.toAccount ?? (_transaction as Transfer).transferAccount,
        list: accountList,
      ),
    );

    _stateController.changeToAccount(returnedValue as RegularAccount?);
  }

  void _changeCategory() async {
    final returnedCategory = await showCustomModalBottomSheet<List<dynamic>>(
      context: context,
      child: _CategoryEditSelector(
          transaction: _transaction,
          category: _stateRead.category ?? (_transaction as IBaseTransactionWithCategory).category,
          tag: _stateRead.tag ?? (_transaction as IBaseTransactionWithCategory).categoryTag),
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

    if (newAmount != null) {
      _stateController.changeAmount(newAmount);
    }
  }

  void _changeDateTime() async {
    final newDateTime = await showRegularDateTimeEditDialog(
      context,
      dbDateTime: _stateRead.dateTime ?? _transaction.dateTime,
      selectedDateTime: _stateRead.dateTime,
    );

    if (newDateTime != null) {
      _stateController.changeDateTime(newDateTime);
    }
  }

  void _changeNote(String value) => _stateController.changeNote(value);

  bool _isAccountEdited(RegularTransactionFormState state) =>
      state.account != null && state.account != _transaction.account;

  bool _isToAccountEdited(RegularTransactionFormState state) =>
      state.toAccount != null && state.toAccount != (_transaction as Transfer).transferAccount;

  bool _isCategoryEdited(RegularTransactionFormState state) =>
      (state.category != null || state.tag != null) &&
      (state.category != (_transaction as IBaseTransactionWithCategory).category ||
          state.tag != (_transaction as IBaseTransactionWithCategory).categoryTag);

  bool _isAmountEdited(RegularTransactionFormState state) =>
      state.amount != null && state.amount != _transaction.amount;

  bool _isDateTimeEdited(RegularTransactionFormState state) =>
      state.dateTime != null && state.dateTime != _transaction.dateTime;

  bool _isNoteEdited(RegularTransactionFormState state) =>
      state.note != null && state.note != _transaction.note;

  bool _submit() {
    final isTransfer = _transaction is Transfer;
    final transferToSameAccount = isTransfer &&
        (_stateRead.account ?? _transaction.account) ==
            (_stateRead.toAccount ?? (_transaction as Transfer).transferAccount);

    if (transferToSameAccount) {
      showErrorDialog(context, 'Oops! Can not transfer in same account!'.hardcoded);

      return false;
    }

    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.editRegularTransaction(_transaction, state: _stateRead);

    _stateController.setStateToAllNull();

    return true;
  }

  void _delete() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.deleteTransaction(_transaction);

    context.pop();
  }
}
