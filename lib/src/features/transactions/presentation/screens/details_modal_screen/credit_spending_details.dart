part of 'transaction_details_modal_screen.dart';

class _SpendingDetails extends ConsumerStatefulWidget {
  const _SpendingDetails({super.key, required this.transaction});

  final CreditSpending transaction;

  @override
  ConsumerState<_SpendingDetails> createState() => _SpendingDetailsState();
}

class _SpendingDetailsState extends ConsumerState<_SpendingDetails> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Credit Spending'.hardcoded,
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
          transactionType: TransactionType.creditSpending,
          amount: widget.transaction.amount,
        ),
        Gap.h16,
        Gap.divider(context, indent: 6),
        _AccountCard(isEditMode: _isEditMode, account: widget.transaction.account!),
        _CategoryCard(
          isEditMode: _isEditMode,
          category: widget.transaction.category!,
          categoryTag: widget.transaction.categoryTag,
        ),
        widget.transaction.note != null ? _Note(isEditMode: _isEditMode, note: widget.transaction.note!) : Gap.noGap,
        Gap.h16,
      ],
    );
  }
}
