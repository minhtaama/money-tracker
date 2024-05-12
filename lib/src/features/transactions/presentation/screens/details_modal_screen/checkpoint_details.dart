part of 'transaction_details_modal_screen.dart';

class _CheckpointDetails extends ConsumerStatefulWidget {
  const _CheckpointDetails(this.screenType, this.controller, this.isScrollable, {required this.transaction});

  final CreditCheckpoint transaction;
  final TransactionScreenType screenType;

  final ScrollController controller;
  final bool isScrollable;

  @override
  ConsumerState<_CheckpointDetails> createState() => _CheckpointDetailsState();
}

class _CheckpointDetailsState extends ConsumerState<_CheckpointDetails> {
  final _installmentPaymentController = TextEditingController();

  bool _isEditMode = false;

  // late final bool _canDelete;

  late CreditCheckpoint _transaction = widget.transaction;

  @override
  void didUpdateWidget(covariant _CheckpointDetails oldWidget) {
    setState(() {
      _transaction = widget.transaction;
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      header: ModalHeader(
        title: 'Credit Spending'.hardcoded,
        subTitle: _DateTime(
          isEditMode: _isEditMode,
          isEdited: false,
          dateTime: _transaction.dateTime,
          onEditModeTap: () {},
        ),
        trailing: widget.screenType == TransactionScreenType.editable
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EditButton(
                    isEditMode: _isEditMode,
                    onTap: () {
                      // if (_isEditMode) {
                      //   if (_submit()) {
                      //     setState(() {
                      //       _isEditMode = !_isEditMode;
                      //     });
                      //   }
                      // } else {
                      //   setState(() {
                      //     _isEditMode = !_isEditMode;
                      //   });
                      // }
                    },
                  ),
                  _DeleteButton(
                    isEditMode: _isEditMode,
                    isDisable: false,
                    disableText: 'Can not delete because there are payment(s) after this transaction'.hardcoded,
                    onConfirm: () {
                      final transactionRepo = ref.read(transactionRepositoryRealmProvider);
                      transactionRepo.deleteTransaction(_transaction);
                    },
                  )
                ],
              )
            : null,
      ),
      body: [
        _Amount(
          isEditMode: false,
          isEdited: false,
          transactionType: TransactionType.creditSpending,
          amount: _transaction.amount,
          onEditModeTap: () {},
        ),
        _AccountCard(isEditMode: false, account: widget.transaction.account),
      ],
      footer: Gap.noGap,
    );
  }
}

// extension _CheckpointDetailsStateMethod on _CheckpointDetailsState {
//   CreditSpendingFormState get _stateRead => ref.read(creditSpendingFormNotifierProvider);
//
//
//   void _changeAmount() async {
//     final newAmount = await showCalculatorModalScreen(
//       context,
//       initialValue: _stateRead.amount ?? _transaction.amount,
//     );
//
//     if (newAmount != null && mounted) {
//       _stateController.changeAmount(newAmount, initialTransaction: _transaction);
//       _changeInstallmentControllerText();
//     }
//   }
//
//   void _onToggleHasInstallment(bool value) {
//     _stateController.changeEditHasInstallment(value);
//     _changeInstallmentControllerText();
//   }
//
//   void _changeInstallmentAmount(String value) {
//     _stateController.changeInstallmentAmount(value);
//   }
//
//   void _changeInstallmentPeriod(String value) {
//     _stateController.changeInstallmentPeriod(int.tryParse(value), initialTransaction: _transaction);
//     _changeInstallmentControllerText();
//   }
//
//   void _changeInstallmentControllerText() =>
//       _installmentPaymentController.text = _stateRead.installmentAmountString(context) ?? '0';
//
//   void _changeDateTime() async {
//     final statement = _creditAccount.statementAt(_transaction.dateTime, upperGapAtDueDate: true);
//
//     final newDateTime = await showCreditSpendingDateTimeEditDialog(
//       context,
//       creditAccount: _creditAccount,
//       statement: statement!,
//       dbDateTime: _transaction.dateTime,
//       selectedDateTime: _stateRead.dateTime,
//     );
//
//     if (newDateTime != null) {
//       _stateController.changeDateTime(newDateTime);
//     }
//   }
//
//   void _changeNote(String value) => _stateController.changeNote(value);
//
//   bool _isCategoryEdited(CreditSpendingFormState state) =>
//       (state.category != null || state.tag != null) &&
//       (state.category != _transaction.category || state.tag != _transaction.categoryTag);
//
//   bool _isAmountEdited(CreditSpendingFormState state) => state.amount != null && state.amount != _transaction.amount;
//
//   bool _isDateTimeEdited(CreditSpendingFormState state) =>
//       state.dateTime != null && state.dateTime != _transaction.dateTime;
//
//   bool _isNoteEdited(CreditSpendingFormState state) => state.note != null && state.note != _transaction.note;
//
//   bool _isInstallmentEdited(CreditSpendingFormState state) =>
//       state.installmentPeriod != null || state.installmentAmount != null;
//
//   bool _canEditAmount(CreditSpendingFormState state) =>
//       (state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay)
//           .isAfter(_creditAccount.latestClosedStatementDueDate) &&
//       (state.dateTime?.onlyYearMonthDay ?? _transaction.dateTime.onlyYearMonthDay)
//           .isAfter(_creditAccount.latestCheckpointDateTime);
//
//   bool _submit() {
//     final txnRepo = ref.read(transactionRepositoryRealmProvider);
//     txnRepo.editCreditSpending(_transaction, state: _stateRead);
//
//     _stateController.setStateToAllNull();
//
//     return true;
//   }
//
//   void _delete() {
//     final txnRepo = ref.read(transactionRepositoryRealmProvider);
//     txnRepo.deleteTransaction(_transaction);
//
//     context.pop();
//   }
// }
