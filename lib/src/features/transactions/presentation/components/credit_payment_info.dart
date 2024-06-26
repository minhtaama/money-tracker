import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/src/common_widgets/custom_box.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../accounts/domain/statement/base_class/statement.dart';
import '../../domain/transaction_base.dart';
import 'base_transaction_components.dart';

class CreditInfo extends StatelessWidget {
  const CreditInfo({
    super.key,
    required this.showPaymentAmount,
    required this.statement,
    this.noBorder = true,
    this.showList = true,
    this.chosenDateTime,
    this.onDateTap,
  });

  final bool showPaymentAmount;
  final bool showList;
  final Statement? statement;

  final bool noBorder;
  final DateTime? chosenDateTime;
  final void Function(DateTime)? onDateTap;

  @override
  Widget build(BuildContext context) {
    return !noBorder
        ? CustomBox(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _List(
                statement: statement,
                showList: showList,
                showPaymentAmount: showPaymentAmount,
                onDateTap: onDateTap,
                chosenDateTime: chosenDateTime,
              ),
            ),
          )
        : _List(
            statement: statement,
            showList: showList,
            showPaymentAmount: showPaymentAmount,
            onDateTap: onDateTap,
            chosenDateTime: chosenDateTime,
          );
  }
}

class _List extends StatefulWidget {
  const _List(
      {this.statement, required this.showPaymentAmount, this.onDateTap, this.chosenDateTime, this.showList = true});

  final Statement? statement;
  final bool showPaymentAmount;
  final bool showList;
  final void Function(DateTime)? onDateTap;
  final DateTime? chosenDateTime;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final _key = GlobalKey();
  double _height = 0;

  List<_InstallmentToPayTransaction> buildInstallmentTransactionTile() {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <_InstallmentToPayTransaction>[];
    }

    final list = <_InstallmentToPayTransaction>[];

    list.addAll(
      widget.statement!.transactions.installmentsToPay.where((instm) {
        if (instm.txn.paymentStartFromNextStatement) {
          return instm.monthsLeft <= instm.txn.monthsToPay! - 1;
        } else {
          return instm.monthsLeft <= instm.txn.monthsToPay! - 2;
        }
      }).map(
        (instm) => _InstallmentToPayTransaction(
          transaction: instm.txn,
        ),
      ),
    );
    return list;
  }

  void buildInstallmentsOfCurrentTransaction(List<Widget> list, BaseCreditTransaction txn, Statement statement) {
    if (txn is CreditSpending && !txn.paymentStartFromNextStatement && txn.hasInstallment) {
      try {
        final installment = statement.transactions.installmentsToPay.firstWhere((inst) => inst.txn == txn);

        if (installment.monthsLeft == txn.monthsToPay! - 1) {
          list.add(
            _InstallmentToPayTransaction(
              transaction: txn,
            ),
          );
        }
      } catch (_) {}
    }
  }

  List<Widget> buildTransactionBeforeTile(BuildContext context, List<BaseCreditTransaction> transactions) {
    final list = <Widget>[];

    DateTime temp = Calendar.minDate;

    for (int i = 0; i < transactions.length; i++) {
      BaseCreditTransaction txn = transactions[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;
      if (txnDateTime.isAtSameMomentAs(widget.statement!.date.start) ||
          txnDateTime.isAtSameMomentAs(nextStatementDateTime)) {
        list.add(_Transaction(
          statement: widget.statement!,
          transaction: transactions[i],
          dateTime: null,
          onDateTap: widget.onDateTap,
        ));
        buildInstallmentsOfCurrentTransaction(list, txn, widget.statement!);
      } else if (!txnDateTime.isAtSameMomentAs(temp)) {
        temp = txnDateTime;
        list.add(_Transaction(
          statement: widget.statement!,
          transaction: transactions[i],
          dateTime: temp,
          onDateTap: widget.onDateTap,
        ));
        buildInstallmentsOfCurrentTransaction(list, txn, widget.statement!);
      } else {
        list.add(_Transaction(
          statement: widget.statement!,
          transaction: transactions[i],
          dateTime: null,
          onDateTap: widget.onDateTap,
        ));
        buildInstallmentsOfCurrentTransaction(list, txn, widget.statement!);
      }
    }
    return list;
  }

  List<Widget> buildTodayTransactionTile(BuildContext context, List<BaseCreditTransaction> transactions,
      {bool showList = true, bool showTitle = true, String fullPaymentAmount = ''}) {
    if (!showList) {
      return <Widget>[];
    }

    final list = <Widget>[];

    if (showTitle) {
      list.add(
        _Transaction(
          statement: widget.statement!,
          dateTime: widget.chosenDateTime,
          isSelectedDay: true,
          fullPaymentAmount: fullPaymentAmount,
        ),
      );
    }

    for (int i = 0; i < transactions.length; i++) {
      list.add(_Transaction(
        statement: widget.statement!,
        transaction: transactions[i],
        dateTime: null,
        onDateTap: widget.onDateTap,
        isSelectedDay: true,
      ));
      buildInstallmentsOfCurrentTransaction(list, transactions[i], widget.statement!);
    }
    return list;
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && widget.showList) {
        setState(() {
          _height = _key.currentContext!.size!.height - 30;
        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant _List oldWidget) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && widget.showList) {
        setState(() {
          _height = _key.currentContext!.size!.height - 30;
        });
      }
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showList
            ? ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: SingleChildScrollView(
                  reverse: true,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      widget.statement != null
                          ? Container(
                              margin: const EdgeInsets.only(left: 13),
                              color: AppColors.greyBorder(context),
                              width: 1,
                              height: _height,
                            )
                          : Gap.noGap,
                      widget.statement != null
                          ? Column(
                              key: _key,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Header(
                                  dateTime: widget.statement!.date.start,
                                  verticalPadding: 4,
                                  h1: 'Billing cycle start',
                                  h2: 'Carry: ${balanceToPay(context)} ${context.appSettings.currency.code} ${interest > 0 ? '+~ ${interestString(context)} ${context.appSettings.currency.code} interest' : ''}',
                                ),
                                ...buildTransactionBeforeTile(context, txnsInBillingCycleBeforePreviousDueDate),
                                widget.statement!.date.previousDue != Calendar.minDate
                                    ? _Header(
                                        dateTime: widget.statement!.date.previousDue,
                                        verticalPadding: 4,
                                        h1: 'Previous due date'.hardcoded,
                                        h2: 'End of last grace period'.hardcoded,
                                      )
                                    : Gap.noGap,
                                ...buildInstallmentTransactionTile(),
                                ...buildTransactionBeforeTile(context, txnsInBillingCycleAfterPreviousDueDate),
                                widget.chosenDateTime == null || !widget.chosenDateTime!.isBefore(nextStatementDateTime)
                                    ? _Header(
                                        isSelectedDay: widget.chosenDateTime == null
                                            ? false
                                            : widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime),
                                        dateTime: nextStatementDateTime,
                                        h1: widget.statement!.checkpoint != null
                                            ? 'Statement date with checkpoint'.hardcoded
                                            : 'Statement date'.hardcoded,
                                        h2: 'Begin of grace period'.hardcoded,
                                      )
                                    : Gap.noGap,
                                ...buildTransactionBeforeTile(context, txnsInGracePeriod),
                                widget.chosenDateTime == null ||
                                        widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.date.due)
                                    ? _Header(
                                        isSelectedDay: widget.chosenDateTime == null
                                            ? false
                                            : widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.date.due),
                                        dateTime: widget.statement!.date.due,
                                        h1: 'Payment due date'.hardcoded,
                                        h2: widget.statement!.carry.balanceToPay > 0
                                            ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
                                            : 'Pay-in-full before this day for interest-free',
                                      )
                                    : Gap.noGap,
                                ...buildTodayTransactionTile(
                                  context,
                                  txnsInChosenDateTime,
                                  showTitle: widget.chosenDateTime == null
                                      ? false
                                      : !widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime) &&
                                          !widget.chosenDateTime!.isAtSameMomentAs(widget.statement!.date.due) &&
                                          !widget.chosenDateTime!.isAtSameMomentAs(nextStatementDateTime),
                                  fullPaymentAmount: fullPaymentAmount(context)!,
                                ),
                              ],
                            )
                          : IconWithText(
                              key: _key,
                              iconPath: AppIcons.done,
                              header: 'No transactions before this time'.hardcoded,
                            ),
                    ],
                  ),
                ),
              )
            : Gap.noGap,
        widget.showPaymentAmount
            ? Flexible(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: widget.showList ? 8.0 : 0.0,
                      left: widget.showList ? 8.0 : 0.0,
                      right: widget.showList ? 8.0 : 0.0),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    runSpacing: 2,
                    children: [
                      Text(
                        '${interest > 0 ? 'Estimated balance' : 'Balance'} to pay at selected day:',
                        style: kHeader3TextStyle.copyWith(
                            fontSize: widget.showList ? 12 : 13, color: context.appTheme.primary.withOpacity(0.7)),
                      ),
                      Gap.w4,
                      Row(
                        children: [
                          Text(
                            '${interest > 0 ? '~ ' : ''}${fullPaymentAmount(context) ?? ''} ${context.appSettings.currency.code}',
                            style: kHeader2TextStyle.copyWith(
                                fontSize: widget.showList ? 14 : 16, color: context.appTheme.primary),
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                          ),
                          Gap.w8,
                          HelpButton(
                            text: 'For easier tracking, you can only pay for transactions happens before selected day'
                                .hardcoded,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            : Gap.noGap,
      ],
    );
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction(
      {required this.statement,
      this.transaction,
      this.dateTime,
      this.isSelectedDay = false,
      this.onDateTap,
      this.fullPaymentAmount});
  final Statement statement;
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
        onTap: transaction != null
            ? () => context.push(
                  RoutePath.transaction,
                  extra: (
                    string: transaction!.databaseObject.id.hexString,
                    type: TransactionScreenType.uneditable,
                  ),
                )
            : null,
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
                        statement: statement,
                      )
                    : Text(
                        'Selected day',
                        style: kHeader2TextStyle.copyWith(fontSize: 12, color: context.appTheme.primary),
                      ),
              ),
              transaction != null && transaction is! CreditCheckpoint
                  ? TxnAmount(
                      transaction: transaction!,
                      fontSize: 13,
                      color: transaction is CreditSpending
                          ? (transaction as CreditSpending).hasInstallment
                              ? AppColors.grey(context)
                              : context.appTheme.negative
                          : context.appTheme.positive,
                    )
                  : Gap.noGap,
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallmentToPayTransaction extends StatelessWidget {
  const _InstallmentToPayTransaction({required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(
          RoutePath.transaction,
          extra: (
            string: transaction.databaseObject.id.hexString,
            type: TransactionScreenType.installmentToPay,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              const _DateTime(),
              Gap.w4,
              TxnCategoryIcon(
                transaction: transaction,
              ),
              Gap.w4,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instm. payment of:',
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
                transaction: transaction,
                showPaymentAmount: true,
                fontSize: 13,
                color: context.appTheme.negative,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.transaction, required this.statement});

  final BaseCreditTransaction transaction;
  final Statement statement;

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
    return switch (transaction) {
      CreditSpending() => _Spending(
          transaction: transaction as CreditSpending,
          categoryTag: _categoryTag,
        ),
      CreditPayment() => _Payment(transaction: transaction as CreditPayment),
      CreditCheckpoint() => _Checkpoint(
          transaction: transaction as CreditCheckpoint,
          statement: statement,
        ),
    };
  }
}

class _Spending extends StatelessWidget {
  const _Spending({required this.transaction, this.categoryTag});

  final CreditSpending transaction;
  final String? categoryTag;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TxnCategoryIcon(
          transaction: transaction,
        ),
        Gap.w4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TxnCategoryName(
                transaction: transaction,
                fontSize: 12,
              ),
              categoryTag != null
                  ? Text(
                      categoryTag!,
                      style: kHeader3TextStyle.copyWith(
                          fontSize: 11, color: context.appTheme.onBackground.withOpacity(0.7)),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Gap.noGap,
            ],
          ),
        ),
        transaction.hasInstallment ? const TxnInstallmentIcon(size: 16) : Gap.noGap,
        Gap.w4,
      ],
    );
  }
}

class _Payment extends StatelessWidget {
  const _Payment({required this.transaction});

  final CreditPayment transaction;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        TxnAdjustmentIcon(size: 16, transaction: transaction),
        Gap.w4,
      ],
    );
  }
}

class _Checkpoint extends StatelessWidget {
  const _Checkpoint({required this.transaction, required this.statement});

  final CreditCheckpoint transaction;
  final Statement statement;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SvgIcon(
          AppIcons.statementCheckpoint,
          color: context.appTheme.onBackground,
          size: 20,
        ),
        Gap.w4,
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.antiAlias,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oustd. balance: ${statement.checkpoint!.unpaidOfInstallments != 0 ? CalService.formatCurrency(context, transaction.amount) : ''} ${statement.checkpoint!.unpaidOfInstallments != 0 ? context.appSettings.currency.code : ''}'
                            .hardcoded,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: statement.checkpoint!.unpaidOfInstallments != 0 ? 10 : 13,
                            color: context.appTheme.onBackground),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      statement.checkpoint!.unpaidOfInstallments != 0
                          ? Text(
                              'Inst. left: ${CalService.formatCurrency(context, statement.checkpoint!.unpaidOfInstallments)} ${context.appSettings.currency.code}'
                                  .hardcoded,
                              style: kHeader3TextStyle.copyWith(fontSize: 10, color: context.appTheme.onBackground),
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                            )
                          : Gap.noGap,
                    ],
                  ),
                ),
              ),
              const FittedBox(child: _CheckpointArrow()),
              Text(
                ' ${CalService.formatCurrency(context, statement.checkpoint!.unpaidToPay)}'.hardcoded,
                style: kHeader2TextStyle.copyWith(fontSize: 13, color: context.appTheme.onBackground),
              ),
              Text(
                ' ${context.appSettings.currency.code}'.hardcoded,
                style: kNormalTextStyle.copyWith(fontSize: 13, color: context.appTheme.onBackground),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.dateTime, required this.h1, this.h2, this.verticalPadding = 3, this.isSelectedDay = false});

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
                      fontSize: 12, color: isSelectedDay ? context.appTheme.primary : AppColors.grey(context)),
                ),
                h2 != null
                    ? Text(
                        h2!,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: 12, color: isSelectedDay ? context.appTheme.primary : AppColors.grey(context)),
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
                      NumberFormat('00').format(dateTime!.day),
                      style: kHeader1TextStyle.copyWith(
                          color: isSelectedDay ? context.appTheme.onPrimary : context.appTheme.onBackground,
                          fontSize: 12,
                          height: 1),
                    ),
                    noMonth
                        ? Gap.noGap
                        : Text(
                            dateTime!.monthToString(context, short: true).toUpperCase(),
                            style: kHeader3TextStyle.copyWith(
                                color: isSelectedDay ? context.appTheme.onPrimary : context.appTheme.onBackground,
                                fontSize: 7),
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
  List<BaseCreditTransaction> get txnsInBillingCycleBeforePreviousDueDate {
    if (widget.statement == null) {
      return <BaseCreditTransaction>[];
    }

    final list =
        widget.statement!.transactionsInBillingCycleBefore(widget.chosenDateTime ?? widget.statement!.date.due);
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (!list[i].dateTime.isAfter(widget.statement!.date.previousDue)) {
        result.add(list[i]);
      } else {
        break;
      }
    }
    return result;
  }

  List<BaseCreditTransaction> get txnsInBillingCycleAfterPreviousDueDate {
    if (widget.statement == null) {
      return <BaseCreditTransaction>[];
    }

    final list =
        widget.statement!.transactionsInBillingCycleBefore(widget.chosenDateTime ?? widget.statement!.date.due);
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (list[i].dateTime.isAfter(widget.statement!.date.previousDue)) {
        result.add(list[i]);
      } else {
        continue;
      }
    }
    return result;
  }

  List<BaseCreditTransaction> get txnsInGracePeriod {
    if (widget.statement == null) {
      return <BaseCreditTransaction>[];
    }
    return widget.statement!.transactionsInGracePeriodBefore(widget.chosenDateTime ?? widget.statement!.date.due);
  }

  List<BaseCreditTransaction> get txnsInChosenDateTime {
    if (widget.statement == null || widget.chosenDateTime == null) {
      return <BaseCreditTransaction>[];
    }
    return widget.statement!.transactionsIn(widget.chosenDateTime!);
  }

  double get interest {
    if (widget.statement == null) {
      return 0;
    }

    return widget.statement!.carry.interest;
  }

  String? interestString(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(context, widget.statement!.carry.interest, forceWithDecimalDigits: true);
  }

  String? balanceToPay(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(context, widget.statement!.carry.balanceToPay);
  }

  DateTime get nextStatementDateTime =>
      widget.statement!.date.start.copyWith(month: widget.statement!.date.start.month + 1);

  String? fullPaymentAmount(BuildContext context) {
    if (widget.statement == null) {
      return null;
    }
    return CalService.formatCurrency(
      context,
      widget.statement!.balanceToPayAt(widget.chosenDateTime ?? widget.statement!.date.due),
    );
  }
}

class _CheckpointArrow extends StatelessWidget {
  const _CheckpointArrow();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        SvgIcon(
          AppIcons.arrowRight,
          color: context.appTheme.onBackground,
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 15,
            height: 1.5,
            color: context.appTheme.onBackground,
          ),
        ),
      ],
    );
  }
}
