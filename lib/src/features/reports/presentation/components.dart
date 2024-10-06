part of 'reports_screen.dart';

///////////////////////////

class ReportWrapper extends StatefulWidget {
  const ReportWrapper({
    super.key,
    required this.title,
    required this.child,
    this.childHeight,
    this.collapsable = false,
  }) : assert(collapsable && childHeight != null || !collapsable);

  final String title;
  final Widget child;

  final double? childHeight;

  final bool collapsable;

  @override
  State<ReportWrapper> createState() => _ReportWrapperState();
}

class _ReportWrapperState extends State<ReportWrapper> {
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.appTheme.accent2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, right: 16.0, left: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: kHeader2TextStyle.copyWith(
                    color: titleColor,
                    shadows: [
                      Shadow(
                        color: titleColor.withOpacity(context.appTheme.isDarkTheme ? 0.5 : 0),
                        blurRadius: context.appTheme.isDarkTheme ? 20 : 2,
                      ),
                    ],
                    height: 1.1,
                  ),
                ),
              ),
              widget.collapsable && widget.childHeight! > 250
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: RotatedBox(
                        quarterTurns: _isCollapsed ? 1 : -1,
                        child: RoundedIconButton(
                          iconPath: AppIcons.arrowRightLight,
                          backgroundColor: context.appTheme.primary,
                          iconColor: context.appTheme.onPrimary,
                          size: 28,
                          iconPadding: 4,
                          onTap: () => setState(() {
                            _isCollapsed = !_isCollapsed;
                          }),
                        ),
                      ),
                    )
                  : Gap.noGap,
            ],
          ),
        ),
        Gap.h12,
        CardItem(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          clip: false,
          color: context.appTheme.background0,
          height: widget.collapsable && widget.childHeight! > 250
              ? _isCollapsed
                  ? 200
                  : widget.childHeight != null
                      ? widget.childHeight! + 16
                      : null
              : widget.childHeight,
          child: widget.collapsable && widget.childHeight! > 250
              ? SingleChildScrollView(
                  reverse: true,
                  physics: const NeverScrollableScrollPhysics(),
                  child: SizedBox(
                    height: widget.childHeight,
                    child: widget.child,
                  ),
                )
              : widget.child,
        )
      ],
    );
  }
}

class ReportWrapperSwitcher extends StatefulWidget {
  const ReportWrapperSwitcher({
    super.key,
    required this.title,
    required this.firstChild,
    required this.secondChild,
    this.showButton = true,
  });

  final String title;
  final Widget firstChild;
  final Widget secondChild;
  final bool showButton;

  @override
  State<ReportWrapperSwitcher> createState() => _ReportWrapperSwitcherState();
}

class _ReportWrapperSwitcherState extends State<ReportWrapperSwitcher> {
  bool _showFirstChild = true;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.appTheme.accent2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: kHeader2TextStyle.copyWith(
                    color: titleColor,
                    shadows: [
                      Shadow(
                        color: titleColor.withOpacity(context.appTheme.isDarkTheme ? 0.5 : 0),
                        blurRadius: context.appTheme.isDarkTheme ? 20 : 2,
                      ),
                    ],
                    height: 1.1,
                  ),
                ),
              ),
              widget.showButton
                  ? RotatedBox(
                      quarterTurns: _showFirstChild ? 1 : -1,
                      child: RoundedIconButton(
                        iconPath: AppIcons.arrowRightLight,
                        backgroundColor: context.appTheme.primary,
                        iconColor: context.appTheme.onPrimary,
                        size: 28,
                        iconPadding: 4,
                        onTap: () => setState(() {
                          _showFirstChild = !_showFirstChild;
                        }),
                      ),
                    )
                  : Gap.noGap,
            ],
          ),
        ),
        Gap.h12,
        CardItem(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          clip: false,
          color: context.appTheme.background0,
          child: ModifiedAnimatedCrossFade(
            duration: k350msDuration,
            sizeCurve: Curves.easeInOut,
            firstChild: widget.firstChild,
            secondChild: widget.secondChild,
            crossFadeState: _showFirstChild ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          ),
        )
      ],
    );
  }
}

class TransactionsModalScreen extends StatelessWidget {
  const TransactionsModalScreen(
    this.controller,
    this.isScrollable, {
    super.key,
    required this.transactions,
    required this.dayBeginOfMonth,
    required this.dayEndOfMonth,
  });

  final ScrollController controller;

  final bool isScrollable;

  final List<BaseTransaction> transactions;
  final DateTime dayBeginOfMonth;
  final DateTime dayEndOfMonth;

  List<Widget> _buildDayCards(
    BuildContext context,
    List<BaseTransaction> transactionList,
    DateTime dayBeginOfMonth,
    DateTime dayEndOfMonth,
  ) {
    final List<DayCard> dayCards = [];

    for (int day = dayEndOfMonth.day; day >= dayBeginOfMonth.day; day--) {
      final transactionsInDay = transactionList.where((transaction) => transaction.dateTime.day == day).toList();

      if (transactionsInDay.isNotEmpty) {
        dayCards.add(
          DayCard(
            dateTime: dayBeginOfMonth.copyWith(day: day),
            transactions: transactionsInDay.reversed.toList(),
            plannedTransactions: const [],
            onTransactionTap: (transaction) =>
                context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
            forModal: true,
          ),
        );
      }
    }

    return dayCards;
  }

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      header: ModalHeader(
        title: context.loc.transactions,
      ),
      body: _buildDayCards(context, transactions, dayBeginOfMonth, dayEndOfMonth),
      footer: Gap.noGap,
    );
  }
}
