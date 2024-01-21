part of 'transaction_details_modal_screen.dart';

class _RegularDetails extends ConsumerStatefulWidget {
  const _RegularDetails({required this.transaction});

  final BaseRegularTransaction transaction;

  @override
  ConsumerState<_RegularDetails> createState() => _RegularDetailsState();
}

class _RegularDetailsState extends ConsumerState<_RegularDetails> {
  bool _isEditMode = false;

  late final _txnRepo = ref.read(transactionRepositoryRealmProvider);
  late final _stateController = ref.read(regularTransactionFormNotifierProvider(null).notifier);

  RegularTransactionFormState get _stateRead => ref.read(regularTransactionFormNotifierProvider(null));

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(regularTransactionFormNotifierProvider(null));

    return CustomSection(
      title: _title,
      subTitle: _DateTime(
        isEditMode: _isEditMode,
        isEdited: _isDateTimeEdited(stateWatch),
        dateTime: stateWatch.dateTime ?? widget.transaction.dateTime,
        onEditModeTap: _changeDateTime,
      ),
      subIcons: _EditButton(
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
          }),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
          isEdited: _isAmountEdited(stateWatch),
          transactionType: widget.transaction.type,
          amount: stateWatch.amount ?? widget.transaction.amount,
          onEditModeTap: _changeAmount,
        ),
        Gap.h8,
        Gap.divider(context, indent: 6),
        Row(
          children: [
            widget.transaction is Transfer
                ? const TxnTransferLine(
                    height: 100,
                    width: 30,
                    strokeWidth: 1.5,
                    opacity: 0.5,
                  )
                : Gap.noGap,
            widget.transaction is Transfer ? Gap.w4 : Gap.noGap,
            Expanded(
              child: Column(
                children: [
                  _AccountCard(
                    isEditMode: (widget.transaction is Income && (widget.transaction as Income).isInitialTransaction)
                        ? false
                        : _isEditMode,
                    isEdited: _isAccountEdited(stateWatch),
                    account: stateWatch.account ?? widget.transaction.account!,
                    onEditModeTap: _changeAccount,
                  ),
                  switch (widget.transaction) {
                    IBaseTransactionWithCategory() =>
                      widget.transaction is Income && (widget.transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              isEdited: _isCategoryEdited(stateWatch),
                              category:
                                  stateWatch.category ?? (widget.transaction as IBaseTransactionWithCategory).category!,
                              categoryTag:
                                  stateWatch.tag ?? (widget.transaction as IBaseTransactionWithCategory).categoryTag,
                              onEditModeTap: _changeCategory,
                            ),
                    Transfer() => _AccountCard(
                        isEditMode: _isEditMode,
                        isEdited: _isToAccountEdited(stateWatch),
                        account: stateWatch.toAccount ?? (widget.transaction as Transfer).transferAccount!,
                        onEditModeTap: _changeToAccount,
                      ),
                  },
                ],
              ),
            ),
          ],
        ),
        widget.transaction.note != null
            ? _Note(
                isEditMode: _isEditMode,
                isEdited: _isNoteEdited(stateWatch),
                note: stateWatch.note ?? widget.transaction.note,
                onEditModeChanged: _changeNote,
              )
            : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

extension _RegularDetailsFunctionsAndGetter on _RegularDetailsState {
  String get _title {
    return switch (widget.transaction) {
      Income() =>
        (widget.transaction as Income).isInitialTransaction ? 'Initial Balance'.hardcoded : 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
    };
  }

  void _changeAccount() async {
    List<Account> accountList = ref.read(accountRepositoryProvider).getList(AccountType.regular);

    final returnedValue = await showCustomModalBottomSheet<Account>(
      context: context,
      child: _ModelWithIconEditSelector(
        title: 'Change Account',
        selectedItem: _stateRead.account ?? widget.transaction.account,
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
        selectedItem: _stateRead.toAccount ?? (widget.transaction as Transfer).transferAccount,
        list: accountList,
      ),
    );

    _stateController.changeToAccount(returnedValue as RegularAccount?);
  }

  void _changeCategory() async {
    final returnedCategory = await showCustomModalBottomSheet<List<dynamic>>(
      context: context,
      child: _CategoryEditSelector(
          transaction: widget.transaction,
          category: _stateRead.category ?? (widget.transaction as IBaseTransactionWithCategory).category,
          tag: _stateRead.tag ?? (widget.transaction as IBaseTransactionWithCategory).categoryTag),
    );

    if (returnedCategory != null) {
      _stateController.changeCategory(returnedCategory[0] as Category?);
      _stateController.changeCategoryTag(returnedCategory[1] as CategoryTag?);
    }
  }

  void _changeAmount() async {
    final newAmount = await showCalculatorModalScreen(
      context,
      initialValue: _stateRead.amount ?? widget.transaction.amount,
    );

    if (newAmount != null) {
      _stateController.changeAmount(newAmount);
    }
  }

  void _changeDateTime() async {
    final newDateTime = await showRegularDateTimeSelectorDialog(
      context,
      current: _stateRead.dateTime ?? widget.transaction.dateTime,
    );

    if (newDateTime != null) {
      _stateController.changeDateTime(newDateTime);
    }
  }

  void _changeNote(String value) => _stateController.changeNote(value);

  bool _isAccountEdited(RegularTransactionFormState state) =>
      state.account != null && state.account != widget.transaction.account;

  bool _isToAccountEdited(RegularTransactionFormState state) =>
      state.toAccount != null && state.toAccount != (widget.transaction as Transfer).transferAccount;

  bool _isCategoryEdited(RegularTransactionFormState state) =>
      (state.category != null || state.tag != null) &&
      (state.category != (widget.transaction as IBaseTransactionWithCategory).category ||
          state.tag != (widget.transaction as IBaseTransactionWithCategory).categoryTag);

  bool _isAmountEdited(RegularTransactionFormState state) =>
      state.amount != null && state.amount != widget.transaction.amount;

  bool _isDateTimeEdited(RegularTransactionFormState state) =>
      state.dateTime != null && state.dateTime != widget.transaction.dateTime;

  bool _isNoteEdited(RegularTransactionFormState state) => state.note != null && state.note != widget.transaction.note;

  bool _submit() {
    if (widget.transaction is Transfer &&
        (_stateRead.account ?? widget.transaction.account) ==
            (_stateRead.toAccount ?? (widget.transaction as Transfer).transferAccount)) {
      showCustomDialog2(
        context: context,
        child: IconWithText(
          iconPath: AppIcons.sadFace,
          color: context.appTheme.onNegative,
          header: 'Oops! Can not transfer in same account!'.hardcoded,
        ),
      );
      return false;
    }

    _txnRepo.editRegularTransaction(widget.transaction, state: _stateRead);
    return true;
  }
}
