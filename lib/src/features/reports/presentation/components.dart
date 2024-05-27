part of 'reports_screen.dart';

///////////////////////////

class ReportWrapper extends StatelessWidget {
  const ReportWrapper(
      {super.key,
      required this.svgPath,
      required this.title,
      required this.child,
      this.illustrationSize = 135,
      this.illustrationOffset = 8});

  final String svgPath;
  final String title;
  final Widget child;

  final double illustrationSize;

  final double illustrationOffset;

  @override
  Widget build(BuildContext context) {
    final titleColor = context.appTheme.accent2;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: ClipRect(
            child: Transform.translate(
              offset: Offset(illustrationOffset, 0),
              child: Opacity(
                opacity: 0.9,
                child: BackgroundIllustration(
                  svgPath,
                  size: illustrationSize,
                ),
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: illustrationOffset + illustrationSize + 14,
                  ),
                  Expanded(
                    child: Text(
                      title,
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
              child: child,
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
