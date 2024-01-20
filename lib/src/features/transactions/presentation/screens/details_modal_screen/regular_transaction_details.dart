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
        isEdited: stateWatch.dateTime != null,
        dateTime: stateWatch.dateTime ?? widget.transaction.dateTime,
        onEditModeTap: _changeDateTime,
      ),
      subIcons: _EditButton(
        isEditMode: _isEditMode,
        onTap: () => setState(() {
          if (_isEditMode) {
            _txnRepo.editRegularTransaction(widget.transaction, state: _stateRead);
          }
          _isEditMode = !_isEditMode;
        }),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
          isEdited: stateWatch.amount != null,
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
                    isEditMode: (widget.transaction is Income &&
                            (widget.transaction as Income).isInitialTransaction)
                        ? false
                        : _isEditMode,
                    isEdited: stateWatch.account != null,
                    account: stateWatch.account ?? widget.transaction.account!,
                    onEditModeTap: _changeAccount,
                  ),
                  switch (widget.transaction) {
                    IBaseTransactionWithCategory() =>
                      widget.transaction is Income && (widget.transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              isEdited: stateWatch.category != null || stateWatch.tag != null,
                              category: stateWatch.category ??
                                  (widget.transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: stateWatch.tag ??
                                  (widget.transaction as IBaseTransactionWithCategory).categoryTag,
                              onEditModeTap: _changeCategory,
                            ),
                    Transfer() => _AccountCard(
                        isEditMode: _isEditMode,
                        isEdited: stateWatch.toAccount != null,
                        account:
                            stateWatch.toAccount ?? (widget.transaction as Transfer).transferAccount!,
                        onEditModeTap: _changeToAccount,
                      ),
                  },
                ],
              ),
            ),
          ],
        ),
        widget.transaction.note != null
            ? _Note(isEditMode: _isEditMode, note: widget.transaction.note!)
            : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

extension _RegularDetailsFunctionsAndGetter on _RegularDetailsState {
  String get _title {
    return switch (widget.transaction) {
      Income() => (widget.transaction as Income).isInitialTransaction
          ? 'Initial Balance'.hardcoded
          : 'Income'.hardcoded,
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
}
