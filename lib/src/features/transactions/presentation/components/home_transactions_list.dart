import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../accounts/domain/account_base.dart';
import '../../domain/transaction_base.dart';
import 'txn_components.dart';

class HomeTransactionsList extends StatelessWidget {
  const HomeTransactionsList({
    super.key,
    required this.transactions,
    required this.currencyCode,
    this.onTransactionTap,
  });

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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TxnHomeCategoryIcon(transaction: transaction),
                    Gap.w8,
                    Expanded(
                      child: switch (transaction) {
                        Transfer() =>
                          _TransferDetails(transaction: transaction, currencyCode: currencyCode),
                        IBaseTransactionWithCategory() =>
                          _WithCategoryDetails(transaction: transaction, currencyCode: currencyCode),
                        CreditPayment() =>
                          _PaymentDetails(transaction: transaction, currencyCode: currencyCode),
                        CreditCheckpoint() => Gap.noGap,
                        //TODO: styling checkpoint
                      },
                    ),
                    Gap.w16,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TxnAmount(transaction: transaction),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TxnAccountName(transaction: transaction),
                            Gap.w4,
                            TxnAccountIcon(transaction: transaction),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                TxnNote(transaction: transaction),
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
        TxnCategoryName(transaction: transaction as IBaseTransactionWithCategory),
        TxnCategoryTag(transaction: transaction),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer to:'.hardcoded,
          style: kHeader3TextStyle.copyWith(
              color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 12),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        TxnToAccountName(transaction: transaction),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment to:'.hardcoded,
          style: kHeader3TextStyle.copyWith(
              color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 12),
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        Row(
          children: [
            TxnToAccountName(transaction: transaction),
            Gap.w4,
            SvgIcon(
              AppIcons.credit,
              size: 14,
              color: context.appTheme.onBackground
                  .withOpacity(transaction.account is DeletedAccount ? 0.25 : 1),
            ),
          ],
        ),
      ],
    );
  }
}
