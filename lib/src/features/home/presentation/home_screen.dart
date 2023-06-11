import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/transactions//presentation/homepage_card.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      customTabBar: CustomTabBar(
        extendedTabBar: ExtendedTabBar(
          backgroundColor: context.appTheme.secondary,
          innerChild: const ExtendedHomeTab(),
          outerChild: const DateSelector(),
        ),
        smallTabBar: SmallTabBar(
          backgroundColor: context.appTheme.background,
          child: const SmallHomeTab(),
        ),
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
        color: isIncome ? context.appTheme.primary : context.appTheme.accent,
        isGradient: true,
        width: double.infinity,
        height: 100,
        elevation: 3,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: isIncome ? context.appTheme.primaryNegative : context.appTheme.accentNegative,
              fontSize: 20),
        ),
      ),
    );
  }
}

List<Widget> _testTransactions = [
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
  HomePageCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction1'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction2'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction3'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Transaction4'),
        ),
      ],
    ),
  ),
];
