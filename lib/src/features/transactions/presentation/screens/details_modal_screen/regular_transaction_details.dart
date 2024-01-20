part of 'transaction_details_modal_screen.dart';

class _RegularDetails extends ConsumerStatefulWidget {
  const _RegularDetails({super.key, required this.transaction});

  final BaseRegularTransaction transaction;

  @override
  ConsumerState<_RegularDetails> createState() => _RegularDetailsState();
}

class _RegularDetailsState extends ConsumerState<_RegularDetails> {
  bool _isEditMode = false;

  late final _stateController = ref.read(regularTransactionFormNotifierProvider(null).notifier);

  RegularTransactionFormState get _stateRead => ref.read(regularTransactionFormNotifierProvider(null));

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(regularTransactionFormNotifierProvider(null));

    return CustomSection(
      title: _title,
      subTitle: _DateTime(isEditMode: _isEditMode, dateTime: widget.transaction.dateTime),
      subIcons: _EditButton(
        isEditMode: _isEditMode,
        onTap: () => setState(() {
          _isEditMode = !_isEditMode;
        }),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
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
                    isEditMode: _isEditMode,
                    account: stateWatch.account ?? widget.transaction.account!,
                    onEditModeTap: _changeAccount,
                  ),
                  switch (widget.transaction) {
                    IBaseTransactionWithCategory() =>
                      widget.transaction is Income && (widget.transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              category: stateWatch.category ??
                                  (widget.transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: stateWatch.tag ??
                                  (widget.transaction as IBaseTransactionWithCategory).categoryTag,
                              // TODO: user can make tag turn to null
                              onEditModeTap: () => _changeCategory(),
                            ),
                    Transfer() => _AccountCard(
                        isEditMode: _isEditMode,
                        account: (widget.transaction as Transfer).transferAccount!),
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

extension _RegularDetailsExtension on _RegularDetailsState {
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
      child: _ModelWithIconSelector(
        title: 'Change Account',
        selectedItem: _stateRead.account ?? widget.transaction.account,
        list: accountList,
      ),
    );

    _stateController.changeAccount(returnedValue as RegularAccount?);
  }

  void _changeCategory() async {
    final returnedCategory = await showCustomModalBottomSheet<List<dynamic>>(
      context: context,
      child: _CategorySelector(
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
}
