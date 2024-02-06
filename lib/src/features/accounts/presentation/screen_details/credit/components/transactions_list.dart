part of '../credit_details.dart';

class _TransactionList extends StatefulWidget {
  const _TransactionList({required this.statement});

  final Statement statement;

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

    DateTime tempDate = statement.startDate;

    bool triggerAddPreviousDueDateHeader = true;
    bool triggerAddPaymentDueDateHeaderAtTheEnd = true;
    bool triggerAddTodayHeaderInBillingCycle = true;
    bool triggerAddTodayHeaderInGracePeriod = true;

    if (statement.transactionsInBillingCycle.isEmpty) {
      _addH0(list, statement, topKey);
      _addH1(list, statement);
      if (_today.isAfter(statement.previousDueDate) && _today.isBefore(statement.statementDate)) {
        _addHToday(list, statement);
      }
    }

    for (int i = 0; i < statement.transactionsInBillingCycle.length; i++) {
      BaseCreditTransaction txn = statement.transactionsInBillingCycle[i];
      DateTime txnDateTime = txn.dateTime.onlyYearMonthDay;

      if (i == 0) {
        _addH0(list, statement, topKey);
      }

      if (triggerAddTodayHeaderInBillingCycle) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isBefore(statement.previousDueDate) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInBillingCycle = false;
          _addHToday(list, statement);
        }
      }

      if (tempDate.isBefore(statement.previousDueDate) && !txnDateTime.isBefore(statement.previousDueDate)) {
        triggerAddPreviousDueDateHeader = false;
        _addH1(list, statement);
      }

      if (triggerAddTodayHeaderInBillingCycle) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isAfter(statement.previousDueDate) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInBillingCycle = false;
          _addHToday(list, statement);
        }
      }

      if (txnDateTime.isAtSameMomentAs(statement.startDate) ||
          txnDateTime.isAtSameMomentAs(statement.previousDueDate) ||
          txnDateTime.isAtSameMomentAs(tempDate) ||
          txnDateTime.isAtSameMomentAs(_today)) {
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: null));
      } else {
        tempDate = txnDateTime;
        list.add(_Transaction(statement: statement, transaction: txn, dateTime: tempDate));
      }

      if (i == statement.transactionsInBillingCycle.length - 1 && triggerAddPreviousDueDateHeader) {
        triggerAddPreviousDueDateHeader = false;
        _addH1(list, statement);
      }

      if (i == statement.transactionsInBillingCycle.length - 1 &&
          triggerAddTodayHeaderInBillingCycle &&
          _today.isBefore(statement.statementDate) &&
          _today.isAfter(statement.previousDueDate)) {
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

      if (triggerAddTodayHeaderInGracePeriod) {
        if (tempDate.isAtSameMomentAs(_today) ||
            _today.isAfter(statement.statementDate) && tempDate.isBefore(_today) && !txnDateTime.isBefore(_today)) {
          triggerAddTodayHeaderInGracePeriod = false;

          _addHToday(list, statement);
        }
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
          triggerAddTodayHeaderInGracePeriod &&
          !_today.isAtSameMomentAs(statement.dueDate) &&
          _today.isAfter(statement.statementDate) &&
          _today.isBefore(statement.dueDate)) {
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
        dateTime: statement.previousDueDate,
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
        color: context.appTheme.primary,
        dateColor: context.appTheme.onPrimary,
      ),
    );
  }

  void _addH3(List<Widget> list, Statement statement, {GlobalKey? bottomKey}) {
    list.add(
      _Header(
        key: bottomKey,
        dateTime: statement.dueDate,
        h1: 'Payment due date'.hardcoded,
        h2: statement.spentToPayAtStartDateWithPrvGracePayment > 0
            ? 'Because of carry-over balance, interest might be added in next statement even if pay-in-full'
            : 'Pay-in-full before this day for interest-free',
      ),
    );
  }

  void _addHToday(List<Widget> list, Statement statement) {
    list.add(
      _Header(
        color: context.appTheme.accent1.addDark(0.1),
        dateBgColor: context.appTheme.accent1,
        dateColor: context.appTheme.onAccent,
        dateTime: _today,
        h1: 'Today',
      ),
    );
  }

  void _addInstallments(List<Widget> list, Statement statement) {
    list.addAll(
      statement.installments.map((instm) => instm.txn).map(
            (txn) => _InstallmentToPayTransaction(
              transaction: txn,
            ),
          ),
    );
  }
}
