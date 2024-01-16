part of 'transaction_details_modal_screen.dart';

class _RegularDetails extends ConsumerStatefulWidget {
  const _RegularDetails({super.key, required this.transaction});

  final BaseRegularTransaction transaction;

  @override
  ConsumerState<_RegularDetails> createState() => _RegularDetailsState();
}

class _RegularDetailsState extends ConsumerState<_RegularDetails> {
  bool _isEditMode = false;
  late final _transactionAccount = widget.transaction.account as RegularAccount;

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
          amount: widget.transaction.amount,
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
                    onEditModeTap: () => _changeAccount(stateWatch.account),
                  ),
                  switch (widget.transaction) {
                    IBaseTransactionWithCategory() =>
                      widget.transaction is Income && (widget.transaction as Income).isInitialTransaction
                          ? Gap.noGap
                          : _CategoryCard(
                              isEditMode: _isEditMode,
                              category: (widget.transaction as IBaseTransactionWithCategory).category!,
                              categoryTag: (widget.transaction as IBaseTransactionWithCategory).categoryTag,
                            ),
                    Transfer() =>
                      _AccountCard(isEditMode: _isEditMode, account: (widget.transaction as Transfer).transferAccount!),
                  },
                ],
              ),
            ),
          ],
        ),
        widget.transaction.note != null ? _Note(isEditMode: _isEditMode, note: widget.transaction.note!) : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}

extension _RegularDetailsExtension on _RegularDetailsState {
  String get _title {
    return switch (widget.transaction) {
      Income() =>
        (widget.transaction as Income).isInitialTransaction ? 'Initial Balance'.hardcoded : 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
    };
  }

  void _changeAccount(Account? currentAccount) async {
    List<Account> accountList = ref.read(accountRepositoryProvider).getList(AccountType.regular);

    final returnedValue = await showCustomModalBottomSheet<Account>(
      context: context,
      child: _WrapSelections(
        title: 'ChangeAccount',
        selectedItem: _stateRead.account,
        isDisable: (e) => _transactionAccount.databaseObject.id == e.databaseObject.id,
        list: accountList,
      ),
    );

    _stateController.changeAccount(returnedValue as RegularAccount?);
  }
}
