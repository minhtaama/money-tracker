part of 'transaction_details_modal_screen.dart';

class _PaymentDetails extends ConsumerStatefulWidget {
  const _PaymentDetails({required this.transaction});

  final CreditPayment transaction;

  @override
  ConsumerState<_PaymentDetails> createState() => _PaymentDetailsState();
}

class _PaymentDetailsState extends ConsumerState<_PaymentDetails> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Credit Payment'.hardcoded,
      subTitle: _DateTime(isEditMode: _isEditMode, dateTime: widget.transaction.dateTime),
      subIcons: [
        _EditButton(
          isEditMode: _isEditMode,
          onTap: () => setState(() {
            _isEditMode = !_isEditMode;
          }),
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: _isEditMode,
          transactionType: TransactionType.creditPayment,
          amount: widget.transaction.amount,
        ),
        Gap.h8,
        Gap.divider(context, indent: 6),
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
                  _AccountCard(isEditMode: _isEditMode, account: widget.transaction.transferAccount!),
                  _AccountCard(isEditMode: _isEditMode, account: widget.transaction.account!),
                ],
              ),
            ),
          ],
        ),
        Gap.noGap,
        _Note(isEditMode: _isEditMode, note: widget.transaction.note),
        Gap.h16,
      ],
    );
  }
}
