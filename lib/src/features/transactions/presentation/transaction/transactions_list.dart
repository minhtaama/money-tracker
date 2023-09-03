import 'package:flutter/material.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../domain/transaction.dart';
import 'components.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    Key? key,
    required this.transactions,
    required this.currencyCode,
    this.onTransactionTap,
  }) : super(key: key);

  final List<Transaction> transactions;
  final String currencyCode;
  final Function(Transaction)? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];

        return CustomInkWell(
          inkColor: AppColors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTransactionTap?.call(transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TxnDot(transaction: transaction),
                    Gap.w8,
                    Expanded(
                      child: switch (transaction) {
                        Transfer() => _TransferDetails(transaction: transaction, currencyCode: currencyCode),
                        TransactionWithCategory() =>
                          _WithCategoryDetails(transaction: transaction, currencyCode: currencyCode),
                        CreditPayment() => const Placeholder(),
                      },
                    ),
                    Gap.w16,
                    TxnAmount(currencyCode: currencyCode, transaction: transaction),
                  ],
                ),
                transaction.note != null ? TxnNote(transaction: transaction) : Gap.noGap,
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _WithCategoryDetails extends StatelessWidget {
  const _WithCategoryDetails({required this.transaction, required this.currencyCode});

  final TransactionWithCategory transaction;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TxnCategoryIcon(transaction: transaction),
              Gap.w4,
              Expanded(child: TxnCategoryName(transaction: transaction)),
            ],
          ),
        ),
        IntrinsicWidth(
          child: Row(
            children: [
              TxnAccountIcon(transaction: transaction),
              Gap.w4,
              Expanded(child: TxnAccountName(transaction: transaction)),
              Gap.w4,
              transaction is CreditSpending ? const TxnCreditIcon() : Gap.noGap,
            ],
          ),
        ),
      ],
    );
  }
}

class _TransferDetails extends StatelessWidget {
  const _TransferDetails({required this.transaction, required this.currencyCode});

  final Transfer transaction;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const TxnTransferLine(),
        Gap.w4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TxnAccountName(transaction: transaction),
              TxnToAccountName(transaction: transaction),
            ],
          ),
        ),
      ],
    );
  }
}
