import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/transactions//presentation/homepage_card.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tab_page.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      extendedTabBar: const ExtendedTabBar(
        innerChild: ExtendedHomeTab(),
        outerChild: DateSelector(),
      ),
      smallTabBar: const SmallTabBar(
        child: SmallHomeTab(),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: const [
              Expanded(child: IncomeExpenseCard(isIncome: true)),
              Expanded(child: IncomeExpenseCard(isIncome: false)),
            ],
          ),
        ),
        ..._testTransactions,
      ],
    );
  }
}

class IncomeExpenseCard extends StatelessWidget {
  const IncomeExpenseCard({
    super.key,
    required this.isIncome,
  });

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CardItem(
        color: context.appTheme.isDarkTheme
            ? context.appTheme.background3
            : isIncome
                ? context.appTheme.primary
                : context.appTheme.accent,
        isGradient: true,
        width: double.infinity,
        height: 100,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: context.appTheme.isDarkTheme
                  ? context.appTheme.backgroundNegative
                  : isIncome
                      ? context.appTheme.primaryNegative
                      : context.appTheme.accentNegative,
              fontSize: 20),
        ),
      ),
    );
  }
}

List<Widget> _testTransactions = [
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
  const HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: SizedBox(
      height: 300,
    ),
  ),
];
