part of '../credit_details.dart';

class _TransactionList extends StatefulWidget {
  const _TransactionList({
    required this.account,
    required this.statement,
    required this.isInMultiSelectionMode,
    required this.selectedTransactions,
    required this.onTransactionTap,
    required this.onTransactionLongPress,
    this.onStatementDateTap,
  });

  final CreditAccount account;
  final Statement statement;
  final VoidCallback? onStatementDateTap;

  final bool isInMultiSelectionMode;
  final List<BaseCreditTransaction> selectedTransactions;
  final void Function(BaseCreditTransaction) onTransactionTap;
  final void Function(BaseCreditTransaction) onTransactionLongPress;

  @override
  State<_TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<_TransactionList> {
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
        Material(
          color: Colors.transparent,
          child: Column(
            children: buildList(context, widget.statement, _topKey, _bottomKey),
          ),
        ),
      ],
    );
  }

  List<Widget> buildList(BuildContext context, Statement statement, GlobalKey topKey, GlobalKey bottomKey) {
    final list = <Widget>[];

    DateTime tempDate = statement.date.start;

    bool triggerAddPreviousDueDateHeader = true;
    bool triggerAddPaymentDueDateHeaderAtTheEnd = true;
    bool triggerAddTodayHeaderInBillingCycle = true;
    bool triggerAddTodayHeaderInGracePeriod = true;

    if (statement.transactions.inBillingCycle.isEmpty) {
      _addH0(list, statement, topKey);
      _addH1(list, statement);
      if (_today.isAfter(statement.date.previousDue) && _today.isBefore(statement.date.statement)) {
        _addHToday(list, statement);
      }
    }

    for (int i = 0; i < statement.transactions.inBillingCycle.length; i++) {
      BaseCreditTransaction txn = statement.transactions.inBillingCycle[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        _addH0(list, statement, topKey);
      }

      if (triggerAddTodayHeaderInBillingCycle) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isBefore(statement.date.previousDue) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInBillingCycle = false;
          _addHToday(list, statement);
        }
      }

      if (tempDate.isBefore(statement.date.previousDue) && !txnDateTime.isBefore(statement.date.previousDue)) {
        triggerAddPreviousDueDateHeader = false;
        _addH1(list, statement);
      }

      if (triggerAddTodayHeaderInBillingCycle) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isAfter(statement.date.previousDue) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInBillingCycle = false;
          _addHToday(list, statement);
        }
      }

      if (txnDateTime.isAtSameMomentAs(statement.date.start) ||
          txnDateTime.isAtSameMomentAs(statement.date.previousDue) ||
          txnDateTime.isAtSameMomentAs(tempDate) ||
          txnDateTime.isAtSameMomentAs(_today)) {
        list.add(
          _Transaction(
            statement: statement,
            transaction: txn,
            dateTime: null,
            isInMultiSelectionMode: widget.isInMultiSelectionMode,
            selectedTransactions: widget.selectedTransactions,
            onTap: () => widget.onTransactionTap(txn),
            onLongPress: () => widget.onTransactionLongPress(txn),
          ),
        );
        _addInstallmentsOfCurrentTransaction(list, txn, statement);
      } else {
        tempDate = txnDateTime;
        list.add(
          _Transaction(
            statement: statement,
            transaction: txn,
            dateTime: tempDate,
            isInMultiSelectionMode: widget.isInMultiSelectionMode,
            selectedTransactions: widget.selectedTransactions,
            onTap: () => widget.onTransactionTap(txn),
            onLongPress: () => widget.onTransactionLongPress(txn),
          ),
        );
        _addInstallmentsOfCurrentTransaction(list, txn, statement);
      }

      if (i == statement.transactions.inBillingCycle.length - 1 && triggerAddPreviousDueDateHeader) {
        triggerAddPreviousDueDateHeader = false;
        _addH1(list, statement);
      }

      if (i == statement.transactions.inBillingCycle.length - 1 &&
          triggerAddTodayHeaderInBillingCycle &&
          _today.isBefore(statement.date.statement) &&
          _today.isAfter(statement.date.previousDue)) {
        _addHToday(list, statement);
      }
    }

    if (statement.transactions.inGracePeriod.isEmpty) {
      _addH2(list, statement);
      if (_today.isAfter(statement.date.statement) && _today.isBefore(statement.date.due)) {
        _addHToday(list, statement);
      }
      _addH3(list, statement, bottomKey: bottomKey);
    }

    for (int i = 0; i < statement.transactions.inGracePeriod.length; i++) {
      BaseCreditTransaction txn = statement.transactions.inGracePeriod[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        _addH2(list, statement);
      }

      if (txnDateTime.isAtSameMomentAs(statement.date.due)) {
        triggerAddPaymentDueDateHeaderAtTheEnd = false;

        _addH3(list, statement);
      }

      if (triggerAddTodayHeaderInGracePeriod) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isAfter(statement.date.statement) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInGracePeriod = false;

          _addHToday(list, statement);
        }
      }

      if (txnDateTime.isAtSameMomentAs(statement.date.statement) ||
          txnDateTime.isAtSameMomentAs(statement.date.due) ||
          txnDateTime.isAtSameMomentAs(tempDate) ||
          txnDateTime.isAtSameMomentAs(_today)) {
        list.add(
          _Transaction(
            key:
                i == statement.transactions.inGracePeriod.length - 1 && txnDateTime.isAtSameMomentAs(statement.date.due)
                    ? bottomKey
                    : null,
            statement: statement,
            transaction: txn,
            dateTime: null,
            isInMultiSelectionMode: widget.isInMultiSelectionMode,
            selectedTransactions: widget.selectedTransactions,
            onTap: () => widget.onTransactionTap(txn),
            onLongPress: () => widget.onTransactionLongPress(txn),
          ),
        );
      } else {
        tempDate = txnDateTime;
        list.add(
          _Transaction(
            statement: statement,
            transaction: txn,
            dateTime: tempDate,
            isInMultiSelectionMode: widget.isInMultiSelectionMode,
            selectedTransactions: widget.selectedTransactions,
            onTap: () => widget.onTransactionTap(txn),
            onLongPress: () => widget.onTransactionLongPress(txn),
          ),
        );
      }

      if (i == statement.transactions.inGracePeriod.length - 1 &&
          triggerAddTodayHeaderInGracePeriod &&
          !_today.isAtSameMomentAs(statement.date.due) &&
          _today.isAfter(statement.date.statement) &&
          _today.isBefore(statement.date.due)) {
        _addHToday(list, statement);
      }

      if (i == statement.transactions.inGracePeriod.length - 1 && triggerAddPaymentDueDateHeaderAtTheEnd) {
        _addH3(list, statement, bottomKey: bottomKey);
      }
    }

    return list;
  }

  void _addH0(List<Widget> list, Statement statement, GlobalKey topKey) {
    list.add(
      _Header(
        key: topKey,
        dateTime: statement.date.start,
        h1: 'Billing cycle start',
      ),
    );
  }

  void _addH1(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        dateTime: statement.date.previousDue,
        h1: context.loc.previousDueDate,
        h2: context.loc.endOfLastGrace,
      ),
    );

    _addInstallmentsFromPreviousStatementTransactions(list, statement);
  }

  void _addH2(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        dateTime: statement.date.statement,
        h1: context.loc.statementDate,
        h2: statement.checkpoint != null
            ? context.loc.withAdjustmentCheckpoint
            : widget.onStatementDateTap == null
                ? null
                : context.loc.tapToAddBalanceCheckpoint,
        color: context.appTheme.onBackground,
        dateColor: widget.account.iconColor,
        dateBgColor: widget.account.backgroundColor,
        onTap: statement.checkpoint != null ? null : widget.onStatementDateTap,
      ),
    );
  }

  void _addH3(List<Widget> list, Statement statement, {GlobalKey? bottomKey}) {
    list.add(
      _Header(
        key: bottomKey,
        dateTime: statement.date.due,
        h1: context.loc.paymentDueDate,
        h2: statement.carry.balanceToPay > 0
            ? context.loc.quoteCreditAccountComponent3
            : context.loc.quoteCreditAccountComponent4,
      ),
    );
  }

  void _addHToday(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        color: context.appTheme.onBackground,
        dateBgColor: AppColors.greyBgr(context),
        dateTime: _today,
        h1: context.loc.today,
        h2: _today.isBefore(statement.date.statement)
            ? context.loc.daysLeftUntilStatementDate(_today.getDaysDifferent(statement.date.statement))
            : context.loc.daysLeftUntilPaymentDueDate(_today.getDaysDifferent(statement.date.due)),
      ),
    );
  }

  void _addInstallmentsFromPreviousStatementTransactions(List<Widget> list, Statement statement) {
    list.addAll(
      statement.transactions.installmentsToPay.where((instm) {
        if (instm.txn.paymentStartFromNextStatement) {
          return instm.monthsLeft <= instm.txn.monthsToPay! - 1;
        } else {
          return instm.monthsLeft <= instm.txn.monthsToPay! - 2;
        }
      }).map(
        (instm) => _InstallmentToPayTransaction(
          transaction: instm.txn,
          isInMultiSelectionMode: widget.isInMultiSelectionMode,
        ),
      ),
    );
  }

  void _addInstallmentsOfCurrentTransaction(List<Widget> list, BaseCreditTransaction txn, Statement statement) {
    if (txn is CreditSpending && !txn.paymentStartFromNextStatement && txn.hasInstallment) {
      final installment = statement.transactions.installmentsToPay.firstWhere((inst) => inst.txn == txn);

      if (installment.monthsLeft == txn.monthsToPay! - 1) {
        list.add(
          _InstallmentToPayTransaction(
            transaction: txn,
            isInMultiSelectionMode: widget.isInMultiSelectionMode,
          ),
        );
      }
    }
  }
}
