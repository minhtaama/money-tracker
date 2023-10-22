import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../accounts/domain/statement/statement.dart';
import '../../domain/transaction_base.dart';
import 'txn_components.dart';

class CreditPaymentInfo extends ConsumerWidget {
  const CreditPaymentInfo({
    Key? key,
    required this.statement,
    this.noBorder = true,
    this.chosenDateTime,
    this.onDateTap,
  }) : super(key: key);

  final Statement? statement;

  final bool noBorder;
  final DateTime? chosenDateTime;
  final void Function(DateTime)? onDateTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return !noBorder
        ? AnimatedContainer(
            duration: k150msDuration,
            width: double.infinity,
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.background3
                  : context.appTheme.background,
              border: Border.all(
                color: context.appTheme.backgroundNegative.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AnimatedSize(
              duration: k150msDuration,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: _List(
                  statement: statement,
                  onDateTap: onDateTap,
                  chosenDateTime: chosenDateTime,
                ),
              ),
            ),
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: _List(
              statement: statement,
              onDateTap: onDateTap,
              chosenDateTime: chosenDateTime,
            ),
          );
  }
}

class _List extends StatelessWidget {
  const _List({this.statement, this.onDateTap, this.chosenDateTime});

  final Statement? statement;
  final void Function(DateTime)? onDateTap;
  final DateTime? chosenDateTime;

  Widget buildHeader(BuildContext context, {String? h1, String? h2, String? h3}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          h1 != null
              ? Text(
                  h1,
                  style: kHeader4TextStyle.copyWith(color: AppColors.grey(context), fontSize: 12),
                  textAlign: TextAlign.center,
                )
              : Gap.noGap,
          h2 != null
              ? Text(
                  h2,
                  style: kHeader2TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              : Gap.noGap,
          h3 != null
              ? Text(
                  h3,
                  style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.backgroundNegative, fontSize: 12),
                  textAlign: TextAlign.center,
                )
              : Gap.noGap,
        ],
      ),
    );
  }

  Widget buildTransactionTile(BuildContext context, BaseCreditTransaction transaction) {
    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: _Details(
                  transaction: transaction,
                  currencyCode: context.currentSettings.currency.code,
                  onDateTap: onDateTap,
                ),
              ),
              Gap.w16,
              TxnAmount(
                currencyCode: context.currentSettings.currency.code,
                transaction: transaction,
                fontSize: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(context,
              h1: 'Last statement carry over:'.hardcoded,
              h2: '$carryingOver ${context.currentSettings.currency.code}',
              h3: statement?.previousStatement.interest == 0
                  ? null
                  : '(included $lastInterest ${context.currentSettings.currency.code} interest)'
                      .hardcoded),
          Gap.h8,
          buildHeader(
            context,
            h1: 'Start of billing cycle:',
            h3: statement!.startDate.getFormattedDate(),
          ),
          statement?.currentInterest != 0
              ? buildHeader(context,
                  h3: '(+$currentInterest ${context.currentSettings.currency.code} interest)'.hardcoded)
              : Gap.noGap,
          ...List.generate(txnsInBillingCycle.length,
              (index) => buildTransactionTile(context, txnsInBillingCycle[index])),
          txnsInGracePeriod.isNotEmpty ? Gap.h8 : Gap.noGap,
          txnsInGracePeriod.isNotEmpty
              ? buildHeader(
                  context,
                  h1: 'Grace period:'.hardcoded,
                  h3: nextStatementDateTime.getFormattedDate(),
                )
              : Gap.noGap,
          ...List.generate(txnsInGracePeriod.length,
              (index) => buildTransactionTile(context, txnsInGracePeriod[index])),
          txnsInChosenDateTime.isNotEmpty ? Gap.h8 : Gap.noGap,
          txnsInChosenDateTime.isNotEmpty
              ? buildHeader(
                  context,
                  h1: 'Selected day:',
                  h3: chosenDateTime!.getFormattedDate(),
                )
              : Gap.noGap,
          ...List.generate(txnsInChosenDateTime.length,
              (index) => buildTransactionTile(context, txnsInChosenDateTime[index])),
        ],
      ),
    );
  }
}

extension _ListGetters on _List {
  List<BaseCreditTransaction> get txnsInBillingCycle {
    if (statement == null || chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return statement!.transactionsInBillingCycleBefore(chosenDateTime!);
  }

  List<BaseCreditTransaction> get txnsInGracePeriod {
    if (statement == null || chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return statement!.transactionsInGracePeriodBefore(chosenDateTime!);
  }

  List<BaseCreditTransaction> get txnsInChosenDateTime {
    if (statement == null || chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return statement!.transactionsIn(chosenDateTime!);
  }

  String? get lastInterest {
    if (statement == null) {
      return null;
    }
    return CalService.formatCurrency(statement!.previousStatement.interest, enableDecimalDigits: true);
  }

  String? get currentInterest {
    if (statement == null) {
      return null;
    }
    return CalService.formatCurrency(statement!.currentInterest, enableDecimalDigits: true);
  }

  String? get carryingOver {
    if (statement == null) {
      return null;
    }
    return CalService.formatCurrency(statement!.previousStatement.carryOverWithInterest,
        enableDecimalDigits: true);
  }

  DateTime get nextStatementDateTime =>
      statement!.startDate.copyWith(month: statement!.startDate.month + 1);
}

class _Details extends StatelessWidget {
  const _Details({required this.transaction, required this.currencyCode, this.onDateTap});

  final BaseCreditTransaction transaction;
  final String currencyCode;
  final void Function(DateTime)? onDateTap;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case CreditSpending():
        return txn.categoryTag != null ? '#${txn.categoryTag!.name}' : null;
      case CreditPayment():
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return transaction is CreditSpending
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TxnDateTime(
                transaction: transaction,
                onDateTap: onDateTap,
              ),
              Gap.w4,
              TxnCategoryIcon(transaction: transaction as CreditSpending),
              Gap.w4,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxnCategoryName(
                      transaction: transaction as CreditSpending,
                      fontSize: 11,
                    ),
                    _categoryTag != null
                        ? Text(
                            _categoryTag!,
                            style: kHeader3TextStyle.copyWith(
                                fontSize: 10,
                                color: context.appTheme.backgroundNegative.withOpacity(0.7)),
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Gap.noGap,
                  ],
                ),
              ),
            ],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TxnDateTime(
                transaction: transaction,
                onDateTap: onDateTap,
              ),
              Gap.w4,
              SvgIcon(
                AppIcons.receiptCheck,
                color: context.appTheme.positive,
                size: 20,
              ),
              Gap.w4,
              Expanded(
                child: Text(
                  'Payment'.hardcoded,
                  style: kHeader3TextStyle.copyWith(fontSize: 11, color: AppColors.grey(context)),
                ),
              ),
            ],
          );
  }
}
