part of 'transaction_details_modal_screen.dart';

class _InstallmentDetails extends ConsumerStatefulWidget {
  const _InstallmentDetails({required this.transaction});

  final CreditSpending transaction;

  @override
  ConsumerState<_InstallmentDetails> createState() => _InstallmentDetailsScreenState();
}

class _InstallmentDetailsScreenState extends ConsumerState<_InstallmentDetails> {
  late final CreditSpending _transaction = widget.transaction;

  late final _creditAccount =
      ref.read(accountRepositoryProvider).getAccount(_transaction.account!.databaseObject) as CreditAccount;

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Installment payment of:'.hardcoded,
      subTitle: _Transaction(transaction: _transaction),
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      sections: [
        _Amount(
          isEditMode: false,
          isEdited: false,
          transactionType: TransactionType.installmentToPay,
          amount: _transaction.paymentAmount!,
        ),
        Gap.h12,
        // _InstallmentOfSpendingDetails(
        //     isEditMode: false,
        //     isEdited: false,
        //     transaction: _transaction,
        //     initialValues: [
        //       _transaction.hasInstallment,
        //       _transaction.paymentAmount,
        //       _transaction.monthsToPay,
        //     ],
        //     onToggle: _onToggleHasInstallment,
        //     onFormattedInstallmentOutput: _changeInstallmentAmount,
        //     onMonthOutput: _changeInstallmentPeriod),
        Gap.h8,
      ],
    );
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction({super.key, required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('00');

    return CardItem(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      width: 400,
      // height: 300,
      elevation: 1,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          RoutePath.transaction,
          extra: (
            string: transaction.databaseObject.id.hexString,
            type: TransactionScreenType.uneditable,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${formatter.format(transaction.dateTime.hour)}:${formatter.format(transaction.dateTime.minute)}',
                  style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.onBackground, fontSize: kHeader4TextStyle.fontSize),
                ),
                Gap.w8,
                Text(
                  transaction.dateTime.getFormattedDate(format: DateTimeFormat.mmmmddyyyy),
                  style: kHeader4TextStyle.copyWith(
                    color: context.appTheme.onBackground,
                  ),
                ),
              ],
            ),
            Gap.h8,
            Row(
              children: [
                TxnCategoryIcon(
                  transaction: transaction,
                  color: transaction.hasInstallment ? null : context.appTheme.negative,
                ),
                Gap.w8,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TxnCategoryName(
                        transaction: transaction,
                        fontSize: 14,
                      ),
                      transaction.categoryTag != null
                          ? Text(
                              transaction.categoryTag!.name,
                              style: kHeader3TextStyle.copyWith(
                                  fontSize: 13, color: context.appTheme.onBackground.withOpacity(0.7)),
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Gap.noGap,
                    ],
                  ),
                ),
                transaction.hasInstallment ? const TxnInstallmentIcon() : Gap.noGap,
                Gap.w4,
                TxnAmount(
                  currencyCode: context.appSettings.currency.code,
                  transaction: transaction,
                  fontSize: 15,
                  color: AppColors.grey(context),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
