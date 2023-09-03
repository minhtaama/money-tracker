import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/currency_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_section.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../domain/transaction.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Transaction',
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CurrencyIcon(),
            Gap.w16,
            Expanded(
              child: Text(
                CalculatorService.formatCurrency(transaction.amount),
                style: kHeader1TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
