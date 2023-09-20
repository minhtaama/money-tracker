import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/empty_info.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../settings/data/settings_controller.dart';
import '../../domain/transaction.dart';
import 'txn_components.dart';

class CreditSpendingsInfoList extends ConsumerWidget {
  const CreditSpendingsInfoList({
    Key? key,
    required this.title,
    this.isSimple = true,
    required this.transactions,
    this.onDateTap,
  }) : super(key: key);

  final String title;
  final bool isSimple;
  final List<CreditSpending> transactions;
  final void Function(DateTime)? onDateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyCode = ref.read(settingsControllerProvider).currency.code;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: Offset(0.0, !isSimple ? 10.0 : 0.0),
          child: Container(
            padding: !isSimple ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10) : EdgeInsets.zero,
            decoration: BoxDecoration(
              color: !isSimple ? AppColors.greyBgr(context) : Colors.transparent,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Transform.translate(
              offset: Offset(!isSimple ? 0.0 : 4, !isSimple ? -3.0 : 0.0),
              child: Text(
                title,
                style: kHeader3TextStyle.copyWith(
                    color: context.appTheme.backgroundNegative.withOpacity(!isSimple ? 1.0 : 0.6), fontSize: 13),
              ),
            ),
          ),
        ),
        !isSimple
            ? AnimatedContainer(
                duration: k150msDuration,
                width: double.infinity,
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
                  border: Border.all(
                    color: context.appTheme.backgroundNegative.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedSize(
                  duration: k150msDuration,
                  child: _List(
                    transactions: transactions,
                    currencyCode: currencyCode,
                    onDateTap: onDateTap,
                  ),
                ),
              )
            : _List(
                transactions: transactions,
                currencyCode: currencyCode,
                onDateTap: onDateTap,
              ),
      ],
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.transactions, required this.currencyCode, this.onDateTap});

  final List<CreditSpending> transactions;
  final String currencyCode;
  final void Function(DateTime)? onDateTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: transactions.isEmpty
                ? [
                    EmptyInfo(
                      infoText: 'Please select a valid date'.hardcoded,
                      iconPath: AppIcons.today,
                      iconSize: 30,
                    )
                  ]
                : List.generate(transactions.length, (index) {
                    final transaction = transactions[index];

                    return Material(
                      color: Colors.transparent,
                      child: CustomInkWell(
                        inkColor: AppColors.grey(context),
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push(RoutePath.transaction, extra: transaction),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: CustomInkWell(
                                  inkColor: AppColors.grey(context),
                                  borderRadius: BorderRadius.circular(1000),
                                  onTap: onDateTap != null
                                      ? () => onDateTap?.call(transaction.dateTime.onlyYearMonthDay)
                                      : null,
                                  child: Text(
                                    transaction.dateTime.getFormattedDate(type: DateTimeType.ddmmyyyy),
                                    style: kHeader2TextStyle.copyWith(
                                        color: context.appTheme.backgroundNegative, fontSize: 12),
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
                      ),
                    );
                  })),
      ),
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
