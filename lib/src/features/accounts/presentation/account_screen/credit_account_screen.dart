import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_page.dart';
import 'package:money_tracker_app/src/common_widgets/empty_info.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/account_screen/extended_account_tab.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/custom_inkwell.dart';
import '../../../../common_widgets/svg_icon.dart';
import '../../../../routing/app_router.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/enums.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../transactions/domain/transaction_base.dart';
import '../../../transactions/presentation/transaction/txn_components.dart';
import '../../domain/account_base.dart';
import '../../domain/statement/statement.dart';

class CreditAccountScreen extends StatefulWidget {
  const CreditAccountScreen({super.key, required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  State<CreditAccountScreen> createState() => _CreditAccountScreenState();
}

class _CreditAccountScreenState extends State<CreditAccountScreen> {
  late final _statementDay = widget.creditAccount.statementDay;

  late final PageController _controller = PageController(initialPage: _initialPageIndex);

  late final DateTime _today = DateTime.now().onlyYearMonthDay;

  late final int _initialPageIndex = _today.getMonthsDifferent(Calendar.minDate);

  late DateTime _displayStatementDate = _today.copyWith(day: _statementDay, month: _today.month + 1);

  bool _showCurrentDateButton = false;

  void _onPageChange(int value) {
    _displayStatementDate = DateTime(_today.year, _today.month + (value - _initialPageIndex) + 1);
    _isShowGoToCurrentDateButton();
    setState(() {});
  }

  void _previousPage() {
    _controller.previousPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _nextPage() {
    _controller.nextPage(duration: k250msDuration, curve: Curves.easeOut);
  }

  void _animatedToPage(int page) {
    _controller.animateToPage(page, duration: k350msDuration, curve: Curves.easeOut);
  }

  void _isShowGoToCurrentDateButton() {
    if (_displayStatementDate.year == _today.year && _displayStatementDate.month - 1 == _today.month) {
      _showCurrentDateButton = false;
    } else {
      _showCurrentDateButton = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background,
      body: CustomTabPageWithPageView(
        controller: _controller,
        smallTabBar: SmallTabBar(
            child: PageHeading(
          title: widget.creditAccount.name,
          hasBackButton: true,
        )),
        extendedTabBar: ExtendedTabBar(
          backgroundColor: widget.creditAccount.backgroundColor,
          innerChild: ExtendedAccountTab(
            account: widget.creditAccount,
          ),
          outerChild: StatementSelector(
            dateDisplay: _displayStatementDate.getFormattedDate(type: DateTimeType.ddmmyyyy),
            onTapLeft: _previousPage,
            onTapRight: _nextPage,
            onTapGoToCurrentDate: () {
              _animatedToPage(_initialPageIndex);
            },
            showGoToCurrentDateButton: _showCurrentDateButton,
          ),
        ),
        onDragLeft: _previousPage,
        onDragRight: _nextPage,
        onPageChanged: _onPageChange,
        itemBuilder: (context, pageIndex) {
          DateTime today = DateTime(Calendar.minDate.year, pageIndex, _today.day);
          Statement? statement = widget.creditAccount.statementAt(today);

          return statement != null
              ? [
                  _Header(
                    dateTime: statement.startDate,
                    verticalPadding: 4,
                    h1: 'Billing cycle start',
                    h2: 'Carry: ${balanceToPay(context, statement)} ${context.currentSettings.currency.code} ${interest(context, statement) != '0.00' ? '+ ${interest(context, statement)} ${context.currentSettings.currency.code} interest' : ''}',
                  ),
                  ...buildTransactionTile(context, txnsInBillingCycleBefore(statement), statement),
                  _Header(
                    dateTime: statement.previousStatement.dueDate,
                    verticalPadding: 4,
                    h1: 'Previous due date'.hardcoded,
                    h2: 'End of last grace period'.hardcoded,
                  ),
                  ...buildInstallmentTransactionTile(context, statement),
                  ...buildTransactionTile(context, txnsInBillingCycleAfterPreviousDueDate(statement), statement),
                  _Header(
                    dateTime: nextStatementDateTime(statement),
                    h1: statement.checkpoint != null
                        ? 'Statement date with checkpoint'.hardcoded
                        : 'Statement date'.hardcoded,
                    h2: 'Begin of grace period'.hardcoded,
                  ),
                  ...buildTransactionTile(context, statement.transactionsInGracePeriod, statement),
                  _Header(
                    dateTime: statement.dueDate,
                    h1: 'Payment due date'.hardcoded,
                    h2: statement.previousStatement.balanceToPay > 0
                        ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
                        : 'Pay-in-full before this day for interest-free',
                  ),
                  ...buildTransactionTile(context, statement.transactionsIn(statement.dueDate), statement),
                  Gap.h48,
                ]
              : [
                  EmptyInfo(
                    iconPath: AppIcons.done,
                    infoText: 'No transactions has made before this day'.hardcoded,
                  ),
                ];
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.dateTime, required this.h1, this.h2, this.verticalPadding = 3});

  final DateTime? dateTime;
  final String h1;
  final String? h2;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: verticalPadding + 4, bottom: verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _DateTime(
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
                  style: kHeader2TextStyle.copyWith(fontSize: 16, color: context.appTheme.backgroundNegative),
                ),
                h2 != null
                    ? Text(
                        h2!,
                        style: kHeader3TextStyle.copyWith(fontSize: 14, color: context.appTheme.backgroundNegative),
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

class _Transaction extends StatelessWidget {
  const _Transaction({required this.statement, required this.transaction, this.dateTime});
  final Statement statement;
  final DateTime? dateTime;
  final BaseCreditTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              _DateTime(
                dateTime: dateTime,
              ),
              Gap.w4,
              Expanded(
                child: _Details(
                  transaction: transaction,
                  statement: statement,
                ),
              ),
              transaction is! CreditCheckpoint ? Gap.w16 : Gap.noGap,
              transaction is CreditSpending && (transaction as CreditSpending).hasInstallment
                  ? const TxnInstallmentIcon(size: 16)
                  : Gap.noGap,
              transaction is! CreditCheckpoint ? Gap.w4 : Gap.noGap,
              transaction is! CreditCheckpoint
                  ? TxnAmount(
                      currencyCode: context.currentSettings.currency.code,
                      transaction: transaction,
                      fontSize: 15,
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

class _InstallmentPayTransaction extends StatelessWidget {
  const _InstallmentPayTransaction({required this.transaction});
  final CreditSpending transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              const _DateTime(),
              Gap.w4,
              TxnCategoryIcon(
                transaction: transaction,
                color: context.appTheme.negative,
              ),
              Gap.w4,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instm. payment of:',
                      style: kHeader3TextStyle.copyWith(fontSize: 12, color: AppColors.grey(context)),
                    ),
                    TxnCategoryName(
                      transaction: transaction,
                      fontSize: 14,
                    )
                  ],
                ),
              ),
              Gap.w4,
              TxnAmount(
                currencyCode: context.currentSettings.currency.code,
                transaction: transaction,
                showPaymentAmount: true,
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
          color: transaction.hasInstallment ? null : context.appTheme.negative,
        ),
        Gap.w4,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TxnCategoryName(
                transaction: transaction,
                fontSize: 14,
              ),
              categoryTag != null
                  ? Text(
                      categoryTag!,
                      style: kHeader3TextStyle.copyWith(
                          fontSize: 13, color: context.appTheme.backgroundNegative.withOpacity(0.7)),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    )
                  : Gap.noGap,
            ],
          ),
        ),
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
            style: kHeader3TextStyle.copyWith(fontSize: 15, color: context.appTheme.backgroundNegative),
          ),
        ),
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
          color: context.appTheme.backgroundNegative,
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
                        'Oustd. balance: ${statement.checkpoint!.unpaidOfInstallments != 0 ? CalService.formatCurrency(context, transaction.amount) : ''} ${statement.checkpoint!.unpaidOfInstallments != 0 ? context.currentSettings.currency.code : ''}'
                            .hardcoded,
                        style: kHeader3TextStyle.copyWith(
                            fontSize: statement.checkpoint!.unpaidOfInstallments != 0 ? 12 : 15,
                            color: context.appTheme.backgroundNegative),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      statement.checkpoint!.unpaidOfInstallments != 0
                          ? Text(
                              'Inst. left: ${CalService.formatCurrency(context, statement.checkpoint!.unpaidOfInstallments)} ${context.currentSettings.currency.code}'
                                  .hardcoded,
                              style:
                                  kHeader3TextStyle.copyWith(fontSize: 12, color: context.appTheme.backgroundNegative),
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
                CalService.formatCurrency(context, statement.checkpoint!.unpaidToPay).hardcoded,
                style: kHeader2TextStyle.copyWith(fontSize: 15, color: context.appTheme.backgroundNegative),
              ),
              Gap.w4,
              Text(
                context.currentSettings.currency.code.hardcoded,
                style: kHeader4TextStyle.copyWith(fontSize: 15, color: context.appTheme.backgroundNegative),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTime extends StatelessWidget {
  const _DateTime({this.dateTime, this.noMonth = true});

  final DateTime? dateTime;
  final bool noMonth;

  @override
  Widget build(BuildContext context) {
    return dateTime != null
        ? Container(
            decoration: BoxDecoration(
              color: AppColors.greyBgr(context),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 25,
            constraints: const BoxConstraints(minHeight: 18),
            padding: const EdgeInsets.all(3),
            child: Center(
              child: Column(
                children: [
                  Text(
                    dateTime!.getFormattedDate(hasMonth: false, hasYear: false),
                    style:
                        kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative, fontSize: 14, height: 1),
                  ),
                  noMonth
                      ? Gap.noGap
                      : Text(
                          dateTime!.getFormattedDate(hasDay: false, hasYear: false),
                          style: kHeader3TextStyle.copyWith(
                              color: context.appTheme.backgroundNegative, fontSize: 14, height: 1),
                        ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.greyBorder(context),
                borderRadius: BorderRadius.circular(1000),
              ),
              height: 10,
              width: 10,
            ),
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
          color: context.appTheme.backgroundNegative,
          size: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            width: 15,
            height: 1.5,
            color: context.appTheme.backgroundNegative,
          ),
        ),
      ],
    );
  }
}

extension _StatementFunctions on _CreditAccountScreenState {
  List<CreditSpending> txnsInstallment(Statement statement) {
    return statement.installments.map((e) => e.txn).toList();
  }

  List<BaseCreditTransaction> txnsInBillingCycleBefore(Statement statement) {
    final list = statement.transactionsInBillingCycle;
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (!list[i].dateTime.isAfter(statement.previousStatement.dueDate)) {
        result.add(list[i]);
      } else {
        break;
      }
    }
    return result;
  }

  List<BaseCreditTransaction> txnsInBillingCycleAfterPreviousDueDate(Statement statement) {
    final list = statement.transactionsInBillingCycle;
    final result = <BaseCreditTransaction>[];

    for (int i = 0; i < list.length; i++) {
      if (list[i].dateTime.isAfter(statement.previousStatement.dueDate)) {
        result.add(list[i]);
      } else {
        continue;
      }
    }
    return result;
  }

  String? interest(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, statement.previousStatement.interest, forceWithDecimalDigits: true);
  }

  String? balanceToPay(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, statement.previousStatement.balanceToPay, forceWithDecimalDigits: true);
  }

  DateTime nextStatementDateTime(Statement statement) =>
      statement.startDate.copyWith(month: statement.startDate.month + 1);

  String? fullPaymentAmount(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, statement.getFullPaymentAmountAt(statement.dueDate),
        forceWithDecimalDigits: true);
  }

  List<_InstallmentPayTransaction> buildInstallmentTransactionTile(BuildContext context, Statement statement) {
    if (txnsInstallment(statement).isEmpty) {
      return <_InstallmentPayTransaction>[];
    }
    final installments = txnsInstallment(statement);
    final list = <_InstallmentPayTransaction>[];
    for (int i = 0; i < installments.length; i++) {
      list.add(_InstallmentPayTransaction(
        transaction: installments[i],
      ));
    }
    return list;
  }

  List<_Transaction> buildTransactionTile(
      BuildContext context, List<BaseCreditTransaction> transactions, Statement statement) {
    final list = <_Transaction>[];

    DateTime temp = Calendar.minDate;

    for (int i = 0; i < transactions.length; i++) {
      BaseCreditTransaction txn = transactions[i];

      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (txnDateTime.isAtSameMomentAs(statement.startDate) ||
          txnDateTime.isAtSameMomentAs(nextStatementDateTime(statement)) ||
          txnDateTime.isAtSameMomentAs(statement.dueDate)) {
        list.add(_Transaction(statement: statement, transaction: transactions[i], dateTime: null));
      } else if (!txnDateTime.isAtSameMomentAs(temp)) {
        temp = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: transactions[i], dateTime: temp));
      } else {
        list.add(_Transaction(statement: statement, transaction: transactions[i], dateTime: null));
      }
    }
    return list;
  }

  // TODO: Modify this to output offset
  List<Widget> buildList(BuildContext context, Statement statement) {
    final list = <Widget>[];

    DateTime tempDateTime = Calendar.minDate;

    bool triggerAddPreviousDueDateHeader = true;
    bool triggerAddPaymentDueDateHeaderAtTheEnd = true;

    for (int i = 0; i < statement.transactionsInBillingCycle.length; i++) {
      BaseCreditTransaction txn = statement.transactionsInBillingCycle[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        list.add(
          _Header(
            dateTime: statement.startDate,
            verticalPadding: 4,
            h1: 'Billing cycle start',
            h2: 'Carry: ${balanceToPay(context, statement)} ${context.currentSettings.currency.code} ${interest(context, statement) != '0.00' ? '+ ${interest(context, statement)} ${context.currentSettings.currency.code} interest' : ''}',
          ),
        );
      }

      if (!txnDateTime.isBefore(tempDateTime) && triggerAddPreviousDueDateHeader) {
        triggerAddPreviousDueDateHeader = false;
        list.add(
          _Header(
            dateTime: statement.previousStatement.dueDate,
            verticalPadding: 4,
            h1: 'Previous due date'.hardcoded,
            h2: 'End of last grace period'.hardcoded,
          ),
        );
      }

      if (txnDateTime.isAtSameMomentAs(statement.startDate) ||
          txnDateTime.isAtSameMomentAs(statement.previousStatement.dueDate)) {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      } else if (!txnDateTime.isAtSameMomentAs(tempDateTime)) {
        tempDateTime = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: tempDateTime));
      } else {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      }
    }

    for (int i = 0; i < statement.transactionsInGracePeriod.length; i++) {
      BaseCreditTransaction txn = statement.transactionsInGracePeriod[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        list.add(
          _Header(
            dateTime: nextStatementDateTime(statement),
            h1: statement.checkpoint != null ? 'Statement date with checkpoint'.hardcoded : 'Statement date'.hardcoded,
            h2: 'Begin of grace period'.hardcoded,
          ),
        );
      }

      if (!txnDateTime.isAtSameMomentAs(statement.dueDate)) {
        triggerAddPaymentDueDateHeaderAtTheEnd = false;

        list.add(
          _Header(
            dateTime: statement.dueDate,
            h1: 'Payment due date'.hardcoded,
            h2: statement.previousStatement.balanceToPay > 0
                ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
                : 'Pay-in-full before this day for interest-free',
          ),
        );
      }

      if (txnDateTime.isAtSameMomentAs(nextStatementDateTime(statement)) ||
          txnDateTime.isAtSameMomentAs(statement.dueDate)) {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      } else if (!txnDateTime.isAtSameMomentAs(tempDateTime)) {
        tempDateTime = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: tempDateTime));
      } else {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      }

      if (i == statement.transactionsInGracePeriod.length - 1 && triggerAddPaymentDueDateHeaderAtTheEnd) {
        list.add(
          _Header(
            dateTime: statement.dueDate,
            h1: 'Payment due date'.hardcoded,
            h2: statement.previousStatement.balanceToPay > 0
                ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
                : 'Pay-in-full before this day for interest-free',
          ),
        );
      }
    }

    return list;
  }
}
