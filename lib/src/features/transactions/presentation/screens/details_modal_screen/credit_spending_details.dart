part of 'transaction_details_modal_screen.dart';

class _SpendingDetails extends ConsumerStatefulWidget {
  const _SpendingDetails({required this.transaction});

  final CreditSpending transaction;

  @override
  ConsumerState<_SpendingDetails> createState() => _SpendingDetailsState();
}

class _SpendingDetailsState extends ConsumerState<_SpendingDetails> {
  bool _isEditMode = false;

  late CreditSpending _transaction = widget.transaction;

  late final _creditAccount =
      ref.read(accountRepositoryProvider).getAccount(_transaction.account!.databaseObject) as CreditAccount;

  late final _stateController = ref.read(creditSpendingFormNotifierProvider.notifier);

  late final bool _canDelete;

  @override
  void initState() {
    try {
      _creditAccount.paymentTransactions
          .map((e) => e.dateTime.onlyYearMonthDay)
          .firstWhere((dateTime) => dateTime.isAfter(_transaction.dateTime.onlyYearMonthDay));
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
      subIcons: [
        _EditButton(
          isEditMode: _isEditMode,
          onTap: () => setState(() {
            _isEditMode = !_isEditMode;
          }),
        ),
        _DeleteButton(
          isEditMode: _isEditMode,
          isDisable: !_canDelete,
          disableText: 'Can not delete because there are payment(s) after this transaction'.hardcoded,
          onConfirm: _delete,
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
          isEdited: _isAmountEdited(stateWatch),
          transactionType: TransactionType.creditSpending,
          amount: stateWatch.amount ?? _transaction.amount,
          onEditModeTap: _changeAmount,
        ),
        Gap.h16,
        Gap.divider(context, indent: 6),
        _AccountCard(isEditMode: false, account: widget.transaction.account!),
        _CategoryCard(
          isEditMode: _isEditMode,
          isEdited: _isCategoryEdited(stateWatch),
          category: stateWatch.category ?? _transaction.category!,
          categoryTag: stateWatch.tag ?? _transaction.categoryTag,
          onEditModeTap: _changeCategory,
        ),
        widget.transaction.note != null
            ? _Note(
                isEditMode: _isEditMode,
                isEdited: _isNoteEdited(stateWatch),
                note: stateWatch.note ?? _transaction.note,
                onEditModeChanged: _changeNote,
              )
            : Gap.noGap,
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
      _stateController.changeAmount(context, newAmount);
    }
  }

  void _changeDateTime() async {
    final newDateTime = await showCreditDateTimeEditDialog(
      context,
      creditAccount: _creditAccount,
      current: _transaction.dateTime,
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

  // bool _submit() {
  //   if (_transaction is Transfer &&
  //       (_stateRead.account ?? _transaction.account) ==
  //           (_stateRead.toAccount ?? (_transaction as Transfer).transferAccount)) {
  //     showCustomDialog2(
  //       context: context,
  //       child: IconWithText(
  //         iconPath: AppIcons.sadFace,
  //         color: context.appTheme.onNegative,
  //         header: 'Oops! Can not transfer in same account!'.hardcoded,
  //       ),
  //     );
  //     return false;
  //   }
  //
  //   final txnRepo = ref.read(transactionRepositoryRealmProvider);
  //   txnRepo.editRegularTransaction(_transaction, state: _stateRead);
  //
  //   _stateController.setStateToAllNull();
  //
  //   return true;
  // }

  void _delete() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.deleteTransaction(_transaction);

    context.pop();
  }
}
