import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../../common_widgets/card_item.dart';
import '../../../../common_widgets/custom_section.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../domain/transaction.dart';

class TransactionDetails extends ConsumerWidget {
  const TransactionDetails({super.key, required this.transaction});

  final Transaction transaction;

  String get _title {
    return switch (transaction) {
      Income() => 'Income'.hardcoded,
      Expense() => 'Expense'.hardcoded,
      Transfer() => 'Transfer'.hardcoded,
      CreditSpending() => 'Credit Spending'.hardcoded,
      CreditPayment() => 'Credit Payment'.hardcoded,
    };
  }

  String get _iconPath {
    return switch (transaction) {
      Income() => AppIcons.download,
      Expense() => AppIcons.upload,
      Transfer() => AppIcons.transfer,
      CreditSpending() => 'Credit Spending'.hardcoded,
      CreditPayment() => 'Credit Payment'.hardcoded,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsObject = ref.read(settingsControllerProvider);

    return CustomSection(
      title: _title,
      crossAxisAlignment: CrossAxisAlignment.start,
      isWrapByCard: false,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CardItem(
              height: 50,
              width: 50,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.zero,
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(1000),
              child: FittedBox(
                child: SvgIcon(_iconPath),
              ),
            ),
            Gap.w16,
            Expanded(
              child: Text(
                '${CalculatorService.formatCurrency(transaction.amount)}  ${settingsObject.currency.code}',
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
