import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
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

class CreditPaymentInfo extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return !noBorder
        ? CustomBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: _List(
              statement: statement,
              onDateTap: onDateTap,
              chosenDateTime: chosenDateTime,
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

class _List extends StatefulWidget {
  const _List({this.statement, this.onDateTap, this.chosenDateTime});

  final Statement? statement;
  final void Function(DateTime)? onDateTap;
  final DateTime? chosenDateTime;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final _key = GlobalKey();
  double _height = 0;

  List<_InstallmentPayTransaction> buildInstallmentTransactionTile(BuildContext context) {
    if (txnsInstallment.isEmpty) {
      return <_InstallmentPayTransaction>[];
    }
    final list = <_InstallmentPayTransaction>[];
    for (int i = 0; i < txnsInstallment.length; i++) {
      list.add(_InstallmentPayTransaction(
        transaction: txnsInstallment[i],
      ));
    }
    return list;
  }

  List<_Transaction> buildTransactionBeforeTile(
      BuildContext context, List<BaseCreditTransaction> transactions) {
    final list = <_Transaction>[];

    DateTime temp = Calendar.minDate;

    for (int i = 0; i < transactions.length; i++) {
      BaseCreditTransaction txn = transactions[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;
      if (txnDateTime.isAtSameMomentAs(widget.statement!.startDate) ||
          txnDateTime.isAtSameMomentAs(nextStatementDateTime)) {
        list.add(
            _Transaction(transaction: transactions[i], dateTime: null, onDateTap: widget.onDateTap));
      } else if (!txnDateTime.isAtSameMomentAs(temp)) {
        temp = txnDateTime;
        list.add(
            _Transaction(transaction: transactions[i], dateTime: temp, onDateTap: widget.onDateTap));
      } else {
        list.add(
            _Transaction(transaction: transactions[i], dateTime: null, onDateTap: widget.onDateTap));
      }
    }
    return list;
  }

  List<_Transaction> buildTodayTransactionTile(
      BuildContext context, List<BaseCreditTransaction> transactions,
      {bool showList = true, bool showTitle = true, String fullPaymentAmount = ''}) {
    if (!showList) {
      return <_Transaction>[];
    }

    final list = <_Transaction>[];

    if (showTitle) {
      list.add(_Transaction(
        dateTime: widget.chosenDateTime!,
        isSelectedDay: true,
        fullPaymentAmount: fullPaymentAmount,
      ));
    }

    for (int i = 0; i < transactions.length; i++) {
      list.add(_Transaction(
        transaction: transactions[i],
        dateTime: null,
        onDateTap: widget.onDateTap,
        isSelectedDay: true,
      ));
    }
    return list;
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _height = _key.currentContext!.size!.height - 25;
      });
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _List oldWidget) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        _height = _key.currentContext!.size!.height - 30;
      });
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 13),
            color: AppColors.greyBorder(context),
            width: 1,
            height: _height,
          ),
          Column(
            key: _key,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                dateTime: widget.statement!.startDate,
                verticalPadding: 4,
                h1: 'Billing cycle start',
                h2: 'Carry: ${balanceToPay(context)} ${context.currentSettings.currency.code} ${interest(context) != '0.00' ? '+ ${interest(context)} ${context.currentSettings.currency.code} interest' : ''}',
              ),
              ...buildTransactionBeforeTile(context, txnsInBillingCycleBeforePreviousDueDate),
              widget.statement!.previousStatement.dueDate != Calendar.minDate
                  ? _Header(
                      dateTime: widget.statement!.previousStatement.dueDate,
                      verticalPadding: 4,
                      h1: 'Previous due date'.hardcoded,
                      h2: 'End of last grace period'.hardcoded,
                    )
                  : Gap.noGap,
              ...buildInstallmentTransactionTile(context),
              ...buildTransactionBeforeTile(context, txnsInBillingCycleAfterPreviousDueDate),
              !widget.chosenDateTime!.isBefore(nextStatementDateTime)
                  ? _Header(
                      isSelectedDay: widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime),
                      dateTime: nextStatementDateTime,
                      h1: 'Statement date'.hardcoded,
                      h2: 'Begin of grace period'.hardcoded,
                    )
                  : Gap.noGap,
              ...buildTransactionBeforeTile(context, txnsInGracePeriod),
              widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.dueDate)
                  ? _Header(
                      isSelectedDay: widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.dueDate),
                      dateTime: widget.statement!.dueDate,
                      h1: 'Payment due date'.hardcoded,
                      h2: widget.statement!.previousStatement.balanceToPay > 0
                          ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
                          : 'Pay-in-full before this day for interest-free',
                    )
                  : Gap.noGap,
              ...buildTodayTransactionTile(
                context,
                txnsInChosenDateTime,
                showTitle: !widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime) &&
                    !widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.dueDate) &&
                    !widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime),
                fullPaymentAmount: fullPaymentAmount(context)!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction(
      {this.transaction,
      this.dateTime,
      this.isSelectedDay = false,
      this.onDateTap,
      this.fullPaymentAmount});
  final String? fullPaymentAmount;
  final DateTime? dateTime;
  final bool isSelectedDay;
  final BaseCreditTransaction? transaction;
  final void Function(DateTime)? onDateTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap:
            transaction != null ? () => context.push(RoutePath.transaction, extra: transaction) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              _DateTime(
                dateTime: dateTime,
                onDateTap: onDateTap,
                isSelectedDay: isSelectedDay,
              ),
              transaction != null ? Gap.w4 : Gap.w8,
              Expanded(
                child: transaction != null
                    ? _Details(
                        transaction: transaction!,
                        currencyCode: context.currentSettings.currency.code,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected day',
                            style: kHeader2TextStyle.copyWith(
                                fontSize: 12, color: context.appTheme.primary),
                          ),
                          Text(
                            'Payment amount: ${fullPaymentAmount ?? ''} ${context.currentSettings.currency.code}',
                            style: kHeader3TextStyle.copyWith(
                                fontSize: 12, color: context.appTheme.primary),
                          )
                        ],
                      ),
              ),
              Gap.w16,
              transaction != null &&
                      transaction is CreditSpending &&
                      (transaction as CreditSpending).hasInstallment
                  ? TxnInstallmentIcon(transaction: transaction as CreditSpending, size: 16)
                  : Gap.noGap,
              Gap.w4,
              transaction != null
                  ? TxnAmount(
                      currencyCode: context.currentSettings.currency.code,
                      transaction: transaction!,
                      fontSize: 13,
                    )
                  : Gap.noGap,
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallmentPayTransaction extends StatelessWidget {
  const _InstallmentPayTransaction({required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              const _DateTime(),
              Gap.w4,
              TxnCategoryIcon(transaction: transaction),
              Gap.w4,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Installment of:',
                      style: kHeader3TextStyle.copyWith(fontSize: 10, color: AppColors.grey(context)),
                    ),
                    TxnCategoryName(
                      transaction: transaction,
                      fontSize: 12,
                    )
                  ],
                ),
              ),
              Gap.w4,
              TxnAmount(
                currencyCode: context.currentSettings.currency.code,
                transaction: transaction,
                showPaymentAmount: true,
                fontSize: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(
      {this.dateTime, required this.h1, this.h2, this.verticalPadding = 3, this.isSelectedDay = false});

  final bool isSelectedDay;
  final DateTime? dateTime;
  final String h1;
  final String? h2;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4, right: 4, top: verticalPadding + 4, bottom: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _DateTime(
            isSelectedDay: isSelectedDay,
            dateTime: dateTime,
            noMonth: false,
          ),
          Gap.w8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  h1,
                  style: kHeader2TextStyle.copyWith(
                      fontSize: 12,
                      color: isSelectedDay ? context.appTheme.primary : AppColors.grey(context)),
                ),
                h2 != null
                    ? Text(
                        h2!,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: 12,
                            color: isSelectedDay ? context.appTheme.primary : AppColors.grey(context)),
                      )
                    : Gap.noGap,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.transaction, required this.currencyCode});

  final BaseCreditTransaction transaction;
  final String currencyCode;

  String? get _categoryTag {
    final txn = transaction;
    switch (txn) {
      case CreditSpending():
        return txn.categoryTag != null ? '#${txn.categoryTag!.name}' : null;
      case CreditPayment() || CreditCheckpoint():
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return transaction is CreditSpending
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TxnCategoryIcon(transaction: transaction as CreditSpending),
              Gap.w4,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TxnCategoryName(
                      transaction: transaction as CreditSpending,
                      fontSize: 12,
                    ),
                    _categoryTag != null
                        ? Text(
                            _categoryTag!,
                            style: kHeader3TextStyle.copyWith(
                                fontSize: 11,
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
        : transaction is CreditPayment
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgIcon(
                    AppIcons.receiptCheck,
                    color: context.appTheme.positive,
                    size: 20,
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      'Payment'.hardcoded,
                      style: kHeader3TextStyle.copyWith(fontSize: 12, color: AppColors.grey(context)),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgIcon(
                    AppIcons.receiptCheck,
                    color: context.appTheme.positive,
                    size: 20,
                  ),
                  Gap.w4,
                  Expanded(
                    child: Text(
                      'Checkpoint'.hardcoded,
                      style: kHeader3TextStyle.copyWith(fontSize: 12, color: AppColors.grey(context)),
                    ),
                  ),
                ],
              );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({this.dateTime, this.onDateTap, this.noMonth = true, this.isSelectedDay = false});

  final DateTime? dateTime;
  final void Function(DateTime)? onDateTap;
  final bool noMonth;
  final bool isSelectedDay;

  @override
  Widget build(BuildContext context) {
    return dateTime != null
        ? Container(
            decoration: BoxDecoration(
              color: isSelectedDay ? context.appTheme.primary : AppColors.greyBgr(context),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 20,
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.all(3),
            child: Center(
              child: CustomInkWell(
                inkColor: AppColors.grey(context),
                borderRadius: BorderRadius.circular(1000),
                onTap: onDateTap != null ? () => onDateTap!.call(dateTime!.onlyYearMonthDay) : null,
                child: Column(
                  children: [
                    Text(
                      dateTime!.getFormattedDate(hasMonth: false, hasYear: false),
                      style: kHeader2TextStyle.copyWith(
                          color: isSelectedDay
                              ? context.appTheme.primaryNegative
                              : context.appTheme.backgroundNegative,
                          fontSize: 10,
                          height: 1),
                    ),
                    noMonth
                        ? Gap.noGap
                        : Text(
                            dateTime!.getFormattedDate(hasDay: false, hasYear: false),
                            style: kHeader3TextStyle.copyWith(
                                color: isSelectedDay
                                    ? context.appTheme.primaryNegative
                                    : context.appTheme.backgroundNegative,
                                fontSize: 10,
                                height: 1),
                          ),
                  ],
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 6, right: 6),
            child: Container(
              decoration: BoxDecoration(
                color: isSelectedDay ? context.appTheme.primary : AppColors.greyBgr(context),
                borderRadius: BorderRadius.circular(1000),
              ),
              height: 7,
              width: 7,
            ),
          );
  }
}

extension _ListGetters on State<_List> {
  List<CreditSpending> get txnsInstallment {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <CreditSpending>[];
    }
    return widget.statement!.installments.map((e) => e.txn).toList();
  }

  List<BaseCreditTransaction> get txnsInBillingCycle {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return widget.statement!.transactionsInBillingCycleBefore(widget.chosenDateTime!);
  }

  List<BaseCreditTransaction> get txnsInBillingCycleBeforePreviousDueDate {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }

    final list = widget.statement!.transactionsInBillingCycleBefore(widget.chosenDateTime!);
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (!list[i].dateTime.isAfter(widget.statement!.previousStatement.dueDate)) {
        result.add(list[i]);
      } else {
        break;
      }
    }
    return result;
  }

  List<BaseCreditTransaction> get txnsInBillingCycleAfterPreviousDueDate {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }

    final list = widget.statement!.transactionsInBillingCycleBefore(widget.chosenDateTime!);
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (list[i].dateTime.isAfter(widget.statement!.previousStatement.dueDate)) {
        result.add(list[i]);
      } else {
        continue;
      }
    }
    return result;
  }

  List<BaseCreditTransaction> get txnsInGracePeriod {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return widget.statement!.transactionsInGracePeriodBefore(widget.chosenDateTime!);
  }

  List<BaseCreditTransaction> get txnsInChosenDateTime {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return widget.statement!.transactionsIn(widget.chosenDateTime!);
  }

  String? interest(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(context, widget.statement!.previousStatement.interest,
        forceWithDecimalDigits: true);
  }

  String? balanceToPay(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(context, widget.statement!.previousStatement.balanceToPay,
        forceWithDecimalDigits: true);
  }

  DateTime get nextStatementDateTime =>
      widget.statement!.startDate.copyWith(month: widget.statement!.startDate.month + 1);

  String? fullPaymentAmount(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(
        context, widget.statement!.getFullPaymentAmountAt(widget.chosenDateTime!),
        forceWithDecimalDigits: true);
  }
}
