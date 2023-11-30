import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_bar.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page/custom_tab_page.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/account_screen/extended_account_tab.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

import '../../../../common_widgets/card_item.dart';
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

part 'credit_account_screen_components.dart';

class CreditAccountScreen extends StatefulWidget {
  const CreditAccountScreen({super.key, required this.creditAccount});

  final CreditAccount creditAccount;

  @override
  State<CreditAccountScreen> createState() => _CreditAccountScreenState();
}

class _CreditAccountScreenState extends State<CreditAccountScreen> {
  late final PageController _controller = PageController(initialPage: _initialPageIndex);

  late final _statementDay = widget.creditAccount.statementDay;
  late final _dueDay = widget.creditAccount.paymentDueDay;

  late final _today = DateTime.now().onlyYearMonthDay;

  int get _initialStatementMonth {
    if (_statementDay > _dueDay) {
      return _today.day > _dueDay ? _today.month : _today.month - 1;
    } else {
      return _today.day > _dueDay ? _today.month + 1 : _today.month;
    }
  }

  late DateTime _displayStatementDate = _today.copyWith(day: _statementDay, month: _initialStatementMonth);

  late final int _initialPageIndex = _displayStatementDate.getMonthsDifferent(Calendar.minDate);

  bool _showCurrentDateButton = false;

  void _onPageChange(int value) {
    _displayStatementDate = DateTime(_today.year, _initialStatementMonth + (value - _initialPageIndex), _statementDay);
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
    if (_displayStatementDate.year == _today.year && _displayStatementDate.month == _initialStatementMonth) {
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
          Statement? statement = widget.creditAccount.statementAt(today, upperGapAtDueDate: true);
          return statement != null
              ? [
                  _SummaryCard(statement: statement),
                  _List(statement: statement),
                ]
              : [
                  IconWithText(
                    iconPath: AppIcons.done,
                    text: 'No transactions has made before this day'.hardcoded,
                  ),
                ];
        },
      ),
    );
  }
}

class _List extends StatefulWidget {
  const _List({required this.statement});

  final Statement statement;

  @override
  State<_List> createState() => _ListState();
}

class _ListState extends State<_List> {
  final _today = DateTime.now().onlyYearMonthDay;

  final GlobalKey _ancestorKey = GlobalKey();
  final GlobalKey _topKey = GlobalKey();
  final GlobalKey _bottomKey = GlobalKey();

  Offset _lineOffset = const Offset(0, 0);
  double _lineHeight = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        // Find RenderBox of the widget using globalKey
        RenderBox ancestorRenderBox = _ancestorKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox topRenderBox = _topKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox bottomRenderBox = _bottomKey.currentContext?.findRenderObject() as RenderBox;

        Offset topOffset = topRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
        Offset bottomOffset = bottomRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);

        setState(() {
          // translateY is padding of _Transaction widget, width of _DateTime widget and width of the line
          _lineOffset = topOffset.translate(topRenderBox.size.height / 2, 16 + 25 / 2 - 1);

          _lineHeight = bottomOffset.dy - topOffset.dy;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _ancestorKey,
      children: [
        Positioned(
          top: _lineOffset.dx,
          left: _lineOffset.dy,
          child: Container(
            width: 2,
            height: _lineHeight,
            color: AppColors.greyBorder(context),
          ),
        ),
        Column(
          children: buildList(context, widget.statement, _topKey, _bottomKey),
        ),
      ],
    );
  }

  List<Widget> buildList(BuildContext context, Statement statement, GlobalKey topKey, GlobalKey bottomKey) {
    final list = <Widget>[];

    DateTime tempDate = Calendar.minDate;

    bool triggerAddPreviousDueDateHeader = true;
    bool triggerAddPaymentDueDateHeaderAtTheEnd = true;
    bool triggerAddTodayHeaderAtTheEndOfBillingCycle = true;
    bool triggerAddTodayHeaderAtTheEndOfGracePeriod = true;

    if (statement.transactionsInBillingCycle.isEmpty) {
      _addH0(list, statement, topKey);
      _addH1(list, statement);
      if (_today.isAfter(statement.previousStatement.dueDate) && _today.isBefore(statement.statementDate)) {
        _addHToday(list, statement);
      }
    }

    for (int i = 0; i < statement.transactionsInBillingCycle.length; i++) {
      BaseCreditTransaction txn = statement.transactionsInBillingCycle[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        _addH0(list, statement, topKey);
      }

      if (!txnDateTime.isBefore(tempDate) && triggerAddPreviousDueDateHeader) {
        triggerAddPreviousDueDateHeader = false;
        _addH1(list, statement);
      }

      if (tempDate.isAtSameMomentAs(_today) ||
          _today.isAfter(statement.previousStatement.dueDate) &&
              tempDate.isBefore(_today) &&
              !txnDateTime.isBefore(_today)) {
        triggerAddTodayHeaderAtTheEndOfBillingCycle = false;

        _addHToday(list, statement);
      }

      if (txnDateTime.isAtSameMomentAs(statement.startDate) ||
          txnDateTime.isAtSameMomentAs(statement.previousStatement.dueDate) ||
          txnDateTime.isAtSameMomentAs(tempDate) ||
          txnDateTime.isAtSameMomentAs(_today)) {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      } else {
        tempDate = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: tempDate));
      }

      if (i == statement.transactionsInBillingCycle.length - 1 &&
          triggerAddTodayHeaderAtTheEndOfBillingCycle &&
          _today.isBefore(statement.statementDate) &&
          _today.isAfter(statement.previousStatement.dueDate)) {
        _addHToday(list, statement);
      }
    }

    if (statement.transactionsInGracePeriod.isEmpty) {
      _addH2(list, statement);
      if (_today.isAfter(statement.statementDate) && _today.isBefore(statement.dueDate)) {
        _addHToday(list, statement);
      }
      _addH3(list, statement, bottomKey: bottomKey);
    }

    for (int i = 0; i < statement.transactionsInGracePeriod.length; i++) {
      BaseCreditTransaction txn = statement.transactionsInGracePeriod[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        _addH2(list, statement);
      }

      if (txnDateTime.isAtSameMomentAs(statement.dueDate)) {
        triggerAddPaymentDueDateHeaderAtTheEnd = false;

        _addH3(list, statement);
      }

      if (tempDate.isAtSameMomentAs(_today) ||
          _today.isAfter(statement.statementDate) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
        triggerAddTodayHeaderAtTheEndOfGracePeriod = false;

        _addHToday(list, statement);
      }

      if (txnDateTime.isAtSameMomentAs(statement.statementDate) ||
          txnDateTime.isAtSameMomentAs(statement.dueDate) ||
          txnDateTime.isAtSameMomentAs(tempDate) ||
          txnDateTime.isAtSameMomentAs(_today)) {
        list.add(_Transaction(
            key: i == statement.transactionsInGracePeriod.length - 1 && txnDateTime.isAtSameMomentAs(statement.dueDate)
                ? bottomKey
                : null,
            statement: statement,
            transaction: txn,
            dateTime: null));
      } else {
        tempDate = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: tempDate));
      }

      if (i == statement.transactionsInGracePeriod.length - 1 &&
          triggerAddTodayHeaderAtTheEndOfGracePeriod &&
          !_today.isAtSameMomentAs(statement.dueDate) &&
          _today.isAfter(statement.statementDate)) {
        _addHToday(list, statement);
      }

      if (i == statement.transactionsInGracePeriod.length - 1 && triggerAddPaymentDueDateHeaderAtTheEnd) {
        _addH3(list, statement, bottomKey: bottomKey);
      }
    }

    return list;
  }

  void _addH0(List<Widget> list, Statement statement, GlobalKey topKey) {
    list.add(
      _Header(
        key: topKey,
        dateTime: statement.startDate,
        h1: 'Billing cycle start',
      ),
    );
  }

  void _addH1(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        dateTime: statement.previousStatement.dueDate,
        h1: 'Previous due date'.hardcoded,
        h2: 'End of last grace period'.hardcoded,
      ),
    );
    _addInstallments(list, statement);
  }

  void _addH2(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        dateTime: statement.statementDate,
        h1: statement.checkpoint != null ? 'Statement date with checkpoint'.hardcoded : 'Statement date'.hardcoded,
        h2: 'Begin of grace period'.hardcoded,
      ),
    );
  }

  void _addH3(List<Widget> list, Statement statement, {GlobalKey? bottomKey}) {
    list.add(
      _Header(
        key: bottomKey,
        dateTime: statement.dueDate,
        h1: 'Payment due date'.hardcoded,
        h2: statement.previousStatement.balanceToPay > 0
            ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
            : 'Pay-in-full before this day for interest-free',
      ),
    );
  }

  void _addHToday(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        backgroundColor: context.appTheme.primary,
        color: context.appTheme.primaryNegative,
        dateTime: _today,
        h1: 'Today',
      ),
    );
  }

  void _addInstallments(List<Widget> list, Statement statement) {
    list.addAll(
      statement.installments.map((instm) => instm.txn).map(
            (txn) => _InstallmentPayTransaction(
              transaction: txn,
            ),
          ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.statement});

  final Statement statement;

  Widget _buildText(BuildContext context, {String? text, String? richText, int color = 0}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          text != null
              ? Expanded(
                  child: Text(
                    text,
                    style: kHeader3TextStyle.copyWith(
                      color: context.appTheme.isDarkTheme
                          ? context.appTheme.backgroundNegative
                          : context.appTheme.secondaryNegative,
                      fontSize: 15,
                    ),
                  ),
                )
              : Gap.noGap,
          richText != null
              ? EasyRichText(
                  richText,
                  defaultStyle: kHeader3TextStyle.copyWith(
                    color: color < 0
                        ? context.appTheme.negative
                        : color > 0
                            ? context.appTheme.positive
                            : context.appTheme.isDarkTheme
                                ? context.appTheme.backgroundNegative
                                : context.appTheme.secondaryNegative,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.right,
                  patternList: [
                    EasyRichTextPattern(
                      targetString: '.',
                      hasSpecialCharacters: true,
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.backgroundNegative
                                    : context.appTheme.secondaryNegative,
                        fontSize: 15,
                      ),
                    ),
                    EasyRichTextPattern(
                      targetString: ',',
                      hasSpecialCharacters: true,
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.backgroundNegative
                                    : context.appTheme.secondaryNegative,
                        fontSize: 15,
                      ),
                    ),
                    EasyRichTextPattern(
                      targetString: '[0-9]+',
                      style: kHeader1TextStyle.copyWith(
                        color: color < 0
                            ? context.appTheme.negative
                            : color > 0
                                ? context.appTheme.positive
                                : context.appTheme.isDarkTheme
                                    ? context.appTheme.backgroundNegative
                                    : context.appTheme.secondaryNegative,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              : Gap.noGap,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8),
      child: CardItem(
        width: double.infinity,
        child: statement.checkpoint == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildText(
                    context,
                    text: 'Carrying-over:',
                    richText: '${carryString(context, statement)} ${context.currentSettings.currency.code}',
                    color: carry <= 0 ? 0 : -1,
                  ),
                  statement.previousStatement.interest > 0
                      ? _buildText(
                          context,
                          text: 'Interest:',
                          richText: '~ ${interestString(context, statement)} ${context.currentSettings.currency.code}',
                          color: interest <= 0 ? 0 : -1,
                        )
                      : Gap.noGap,
                  _buildText(
                    context,
                    text: 'Spent in billing cycle:',
                    richText: '${spentString(context, statement)} ${context.currentSettings.currency.code}',
                    color: spent <= 0 ? 0 : -1,
                  ),
                  _buildText(
                    context,
                    text: 'Paid for this statement:',
                    richText: '${paidString(context, statement)} ${context.currentSettings.currency.code}',
                    color: paid <= 0 ? 0 : 1,
                  ),
                  Gap.divider(context, indent: 0),
                  _buildText(
                    context,
                    text: 'Statement balance:',
                    richText: '${remainingString(context, statement)} ${context.currentSettings.currency.code}',
                    color: remaining <= 0 ? 0 : -1,
                  ),
                ],
              )
            : Column(
                children: [
                  IconWithText(
                    iconPath: AppIcons.statementCheckpoint,
                    iconSize: 30,
                    text: 'This statement has checkpoint',
                  ),
                  Gap.divider(context, indent: 0),
                  _buildText(
                    context,
                    text: 'Spent at checkpoint:',
                    richText: '${spentString(context, statement)} ${context.currentSettings.currency.code}',
                    color: spent <= 0 ? 0 : -1,
                  ),
                  _buildText(
                    context,
                    text: 'Paid in grace period:',
                    richText: '${paidString(context, statement)} ${context.currentSettings.currency.code}',
                    color: paid <= 0 ? 0 : 1,
                  ),
                  Gap.divider(context, indent: 0),
                  _buildText(
                    context,
                    text: 'Statement balance:',
                    richText: '${remainingString(context, statement)} ${context.currentSettings.currency.code}',
                    color: remaining <= 0 ? 0 : -1,
                  ),
                ],
              ),
      ),
    );
  }
}

extension _StatementDetails on _SummaryCard {
  double get interest => statement.previousStatement.interest;
  double get carry => statement.previousStatement.balanceToPay;
  double get spent => statement.spentInBillingCycleExcludeInstallments + statement.installmentsAmountToPay;
  double get paid => statement.paidForThisStatement;
  double get remaining => statement.checkpoint == null
      ? (statement.previousStatement.interest +
              statement.previousStatement.balanceToPay +
              statement.spentInBillingCycleExcludeInstallments +
              statement.installmentsAmountToPay) -
          statement.paidForThisStatement
      : statement.spentInBillingCycleExcludeInstallments - statement.paidForThisStatement;

  String? interestString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, interest, forceWithDecimalDigits: true);
  }

  String? carryString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, carry, forceWithDecimalDigits: true);
  }

  String? spentString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, spent, forceWithDecimalDigits: true);
  }

  String? paidString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, paid, forceWithDecimalDigits: true);
  }

  String? remainingString(BuildContext context, Statement statement) {
    return CalService.formatCurrency(context, remaining, forceWithDecimalDigits: true);
  }
}
