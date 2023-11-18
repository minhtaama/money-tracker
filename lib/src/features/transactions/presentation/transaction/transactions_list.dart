import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../domain/transaction_base.dart';
import 'txn_components.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    Key? key,
    required this.transactions,
    required this.currencyCode,
    this.onTransactionTap,
  }) : super(key: key);

  final List<BaseTransaction> transactions;
  final String currencyCode;
  final void Function(BaseTransaction)? onTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];

        return CustomInkWell(
          inkColor: AppColors.grey(context),
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
                        Transfer() =>
                          _TransferDetails(transaction: transaction, currencyCode: currencyCode),
                        BaseTransactionWithCategory() =>
                          _WithCategoryDetails(transaction: transaction, currencyCode: currencyCode),
                        CreditPayment() =>
                          _PaymentDetails(transaction: transaction, currencyCode: currencyCode),
                        CreditCheckpoint() => Gap.noGap,
                        //TODO: styling checkpoint
                      },
                    ),
                    Gap.w16,
                    TxnAmount(currencyCode: currencyCode, transaction: transaction),
                  ],
                ),
                transaction.note != null ||
                        transaction is BaseTransactionWithCategory &&
                            (transaction as BaseTransactionWithCategory).categoryTag != null
                    ? TxnNote(transaction: transaction)
                    : Gap.noGap,
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

  final BaseTransaction transaction;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TxnCategoryIcon(transaction: transaction as BaseTransactionWithCategory),
            Gap.w4,
            Expanded(child: TxnCategoryName(transaction: transaction as BaseTransactionWithCategory)),
          ],
        ),
        IntrinsicWidth(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
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
              Row(
                children: [
                  TxnAccountName(transaction: transaction),
                  Gap.w4,
                  TxnInfo('Transfer'.hardcoded),
                ],
              ),
              Gap.h4,
              TxnTransferAccountName(transaction: transaction),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentDetails extends StatelessWidget {
  const _PaymentDetails({required this.transaction, required this.currencyCode});

  final CreditPayment transaction;
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
              Row(
                children: [
                  TxnTransferAccountName(transaction: transaction),
                  Gap.w4,
                  TxnInfo('Payment'.hardcoded),
                ],
              ),
              Gap.h4,
              Row(
                children: [
                  TxnAccountName(transaction: transaction),
                  Gap.w4,
                  const TxnCreditIcon(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
