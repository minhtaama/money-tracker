import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../domain/transaction.dart';
import 'txn_components.dart';

class CreditSpendingsInfoList extends StatelessWidget {
  const CreditSpendingsInfoList({
    Key? key,
    required this.transactions,
    required this.currencyCode,
    this.onDateTap,
    this.onTap,
  }) : super(key: key);

  final List<CreditSpending> transactions;
  final String currencyCode;
  final void Function(DateTime)? onDateTap;
  final void Function(CreditSpending)? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(transactions.length, (index) {
        final transaction = transactions[index];

        return CustomInkWell(
          inkColor: AppColors.grey(context),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTap?.call(transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CustomInkWell(
                    inkColor: AppColors.grey(context),
                    borderRadius: BorderRadius.circular(1000),
                    onTap: () => onDateTap?.call(transaction.dateTime.onlyYearMonthDay),
                    child: Text(
                      transaction.dateTime.getFormattedDate(type: DateTimeType.mmmddyyyy),
                      style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 11),
                    ),
                  ),
                ),
                Gap.w8,
                Row(
                  children: [
                    Expanded(
                      child: _Details(transaction: transaction, currencyCode: currencyCode),
                    ),
                    Gap.w16,
                    TxnAmount(
                      currencyCode: currencyCode,
                      transaction: transaction,
                      fontSize: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.transaction, required this.currencyCode});

  final CreditSpending transaction;
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
              Expanded(
                  child: TxnCategoryName(
                transaction: transaction,
                fontSize: 11,
              )),
            ],
          ),
        ),
        IntrinsicWidth(
          child: Row(
            children: [
              TxnAccountIcon(transaction: transaction),
              Gap.w4,
              Expanded(
                  child: TxnAccountName(
                transaction: transaction,
                fontSize: 11,
              )),
              Gap.w4,
              const TxnCreditIcon(),
            ],
          ),
        ),
      ],
    );
  }
}
