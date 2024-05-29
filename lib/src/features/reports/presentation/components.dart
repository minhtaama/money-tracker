part of 'reports_screen.dart';

///////////////////////////

class ReportWrapper extends StatefulWidget {
  const ReportWrapper({
    super.key,
    required this.svgPath,
    required this.title,
    required this.child,
    this.illustrationSize = 135,
    this.illustrationOffset = 8,
    this.childHeight,
    this.collapsable = false,
  }) : assert(collapsable && childHeight != null || !collapsable);

  final String svgPath;
  final String title;
  final Widget child;

  final double? childHeight;

  final double illustrationSize;

  final double illustrationOffset;

  final bool collapsable;

  @override
  State<ReportWrapper> createState() => _ReportWrapperState();
}

class _ReportWrapperState extends State<ReportWrapper> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.appTheme.accent2;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRect(
            child: Transform.translate(
              offset: Offset(widget.illustrationOffset, 0),
              child: Opacity(
                opacity: 0.9,
                child: BackgroundIllustration(
                  widget.svgPath,
                  size: widget.illustrationSize,
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 80,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: widget.illustrationOffset + widget.illustrationSize + 70,
                  ),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: kHeader1TextStyle.copyWith(
                        color: titleColor,
                        shadows: [
                          Shadow(
                            color: titleColor.withOpacity(context.appTheme.isDarkTheme ? 0.5 : 1),
                            blurRadius: context.appTheme.isDarkTheme ? 20 : 2,
                          ),
                        ],
                        height: 1.1,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  Gap.w24,
                ],
              ),
            ),
            Gap.h12,
            CardItem(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: context.appTheme.background0,
              height: widget.collapsable && widget.childHeight! > 250
                  ? _isCollapsed
                      ? 200
                      : widget.childHeight != null
                          ? widget.childHeight! + 16
                          : null
                  : widget.childHeight,
              child: widget.collapsable && widget.childHeight! > 250
                  ? Stack(
                      children: [
                        SingleChildScrollView(
                          reverse: true,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            height: widget.childHeight,
                            child: widget.child,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: RotatedBox(
                              quarterTurns: _isCollapsed ? 1 : -1,
                              child: RoundedIconButton(
                                iconPath: AppIcons.arrowRight,
                                backgroundColor: context.appTheme.primary,
                                iconColor: context.appTheme.onPrimary,
                                size: 32,
                                iconPadding: 5,
                                onTap: () => setState(() {
                                  _isCollapsed = !_isCollapsed;
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : widget.child,
            )
          ],
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
        title: 'Transactions'.hardcoded,
      ),
      body: _buildDayCards(context, transactions, dayBeginOfMonth, dayEndOfMonth),
      bodyMargin: EdgeInsets.zero,
      footer: Gap.noGap,
    );
  }
}
