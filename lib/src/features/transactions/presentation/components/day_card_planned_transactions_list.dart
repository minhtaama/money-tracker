import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../accounts/domain/account_base.dart';
import '../../../recurrence/domain/recurrence.dart';
import '../../domain/transaction_base.dart';
import 'base_transaction_components.dart';

class DayCardPlannedTransactionsList extends StatelessWidget {
  const DayCardPlannedTransactionsList({
    super.key,
    required this.plannedTransactions,
    this.onPlannedTransactionTap,
  });

  final List<TransactionData> plannedTransactions;
  final void Function(TransactionData)? onPlannedTransactionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(plannedTransactions.length, (index) {
        final transaction = plannedTransactions[index];

        return CustomInkWell(
          inkColor: AppColors.grey(context),
          borderRadius: BorderRadius.circular(12),
          onTap: () => onPlannedTransactionTap?.call(transaction),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Gap.w8,
                    Expanded(
                      child: switch (transaction.type) {
                        TransactionType.transfer => Text(
                            context.loc.transfer,
                            style: kHeader3TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 12),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        _ => Text(
                            transaction.category?.name ?? '',
                            style: kHeader3TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.6), fontSize: 12),
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                      },
                    ),
                    Gap.w16,
                    MoneyAmount(
                      amount: transaction.amount,
                      noAnimation: true,
                      style: kHeader3TextStyle.copyWith(
                        color: transaction.type == TransactionType.expense
                            ? context.appTheme.negative
                            : transaction.type == TransactionType.expense
                                ? context.appTheme.positive
                                : context.appTheme.onBackground,
                        fontSize: 13,
                      ),
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
