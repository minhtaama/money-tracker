part of 'transaction_details_modal_screen.dart';

class _PaymentDetails extends ConsumerStatefulWidget {
  const _PaymentDetails(this.screenType, this.controller, this.isScrollable,
      {required this.transaction});

  final CreditPayment transaction;
  final TransactionScreenType screenType;

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<_PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends ConsumerState<_PaymentDetails> {
  bool _isEditMode = false;

  late CreditPayment _transaction = widget.transaction;

  late final _creditAccount = _transaction.account is DeletedAccount
      ? null
      : ref.read(accountRepositoryProvider).getAccount(_transaction.account.databaseObject)
          as CreditAccount;

  late final _stateController = ref.read(creditPaymentFormNotifierProvider.notifier);

  late final bool _canDelete = _transaction.account is DeletedAccount
      ? true
      : _creditAccount!.latestClosedStatementDueDate.isBefore(_transaction.dateTime.onlyYearMonthDay);

  @override
  void didUpdateWidget(covariant _PaymentDetails oldWidget) {
    setState(() {
      _transaction = widget.transaction;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final stateWatch = ref.watch(creditPaymentFormNotifierProvider);

    return ModalContent(
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      header: ModalHeader(
        title: 'Credit Payment'.hardcoded,
        subTitle: _DateTime(
          isEditMode: _transaction.account is DeletedAccount ? false : _isEditMode,
          isEdited: _isDateTimeEdited(stateWatch),
          dateTime: stateWatch.dateTime ?? _transaction.dateTime,
          onEditModeTap: _changeDateTime,
        ),
        trailing: widget.screenType == TransactionScreenType.editable
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.transaction.isAdjustToAPRChange
                      ? Gap.noGap
                      : _EditButton(
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
                    disableText:
                        'Can not delete payment in the period has been recorded on the statement.'
                            .hardcoded,
                    onConfirm: _delete,
                  )
                ],
              )
            : null,
      ),
      body: [
        _Amount(
          isEditMode: false,
          transactionType: TransactionType.creditPayment,
          amount: widget.transaction.amount,
        ),
        Gap.h8,
        Gap.divider(context, indent: 6),
        Gap.h8,
        Row(
          children: [
            const TxnTransferLine(
              height: 100,
              width: 30,
              strokeWidth: 1.5,
              opacity: 0.5,
            ),
            Gap.w4,
            Expanded(
              child: Column(
                children: [
                  _AccountCard(
                    isEditMode: _isEditMode,
                    isEdited: _isFromAccountEdited(stateWatch),
                    account: stateWatch.fromRegularAccount ?? _transaction.transferAccount,
                    onEditModeTap: _changeFromAccount,
                  ),
                  Gap.h16,
                  _AccountCard(isEditMode: false, account: widget.transaction.account),
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
      footer: Gap.noGap,
    );
  }
}

extension _PaymentDetailsStateMethod on _PaymentDetailsState {
  CreditPaymentFormState get _stateRead => ref.read(creditPaymentFormNotifierProvider);

  void _changeDateTime() async {
    final statement = _creditAccount!.statementAt(_transaction.dateTime, upperGapAtDueDate: true);

    final returnedValue = await showCreditPaymentDateTimeEditDialog(
      context,
      creditAccount: _creditAccount!,
      statement: statement!,
      dbDateTime: _transaction.dateTime,
      selectedDateTime: _stateRead.dateTime,
    );

    if (returnedValue != null) {
      _stateController.changeDateTime(returnedValue[0], returnedValue[1]);
    }
  }

  void _changeFromAccount() async {
    List<Account> accountList = ref.read(accountRepositoryProvider).getList(AccountType.regular);

    final returnedValue = await showCustomModal<Account>(
      context: context,
      child: ModalContent(
        header: ModalHeader(
          title: 'Edit Account'.hardcoded,
        ),
        body: [
          _ModelWithIconEditSelector(
            title: 'Change Origin:',
            selectedItem: _stateRead.fromRegularAccount ?? _transaction.transferAccount,
            list: accountList,
          ),
        ],
        footer: Gap.noGap,
      ),
    );

    _stateController.changeFromAccount(returnedValue as RegularAccount?);
  }

  void _changeNote(String value) => _stateController.changeNote(value);

  bool _isFromAccountEdited(CreditPaymentFormState state) =>
      state.fromRegularAccount != null && state.fromRegularAccount != _transaction.transferAccount;

  bool _isDateTimeEdited(CreditPaymentFormState state) =>
      state.dateTime != null && state.dateTime != _transaction.dateTime;

  bool _isNoteEdited(CreditPaymentFormState state) =>
      state.note != null && state.note != _transaction.note;

  bool _submit() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.editCreditPayment(_transaction, state: _stateRead);

    _stateController.setStateToAllNull();

    return true;
  }

  void _delete() {
    final txnRepo = ref.read(transactionRepositoryRealmProvider);
    txnRepo.deleteTransaction(_transaction);

    context.pop();
  }
}
