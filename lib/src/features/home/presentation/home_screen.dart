import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/small_home_tab.dart';
import 'package:money_tracker_app/src/features/home/presentation/tab_bars/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/transactions//presentation/homepage_card.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_tab_page/custom_tab_page_with_page_view.dart';
import '../../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int mapKey = 1;

  @override
  Widget build(BuildContext context) {
    return CustomTabPageWithPageView(
      extendedTabBar: const ExtendedTabBar(
        innerChild: ExtendedHomeTab(),
        outerChild: DateSelector(),
      ),
      smallTabBar: const SmallTabBar(
        child: SmallHomeTab(),
      ),
      onPageChanged: (index) {
        mapKey = index + 1;
      },
      pageItemCount: _testMap.keys.length,
      listItemCount: _testMap[mapKey]!.length + 1,
      listItemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Expanded(child: IncomeExpenseCard(isIncome: true)),
                Expanded(child: IncomeExpenseCard(isIncome: false)),
              ],
            ),
          );
        } else {
          return _testMap[mapKey]![index - 1];
        }
      },
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

Map<int, List<Widget>> _testMap = {
  1: [
    const HomePageCard(
      header: '1 - 23/3/2023',
      title: '+ 840.000 VND',
      child: SizedBox(
        height: 300,
      ),
    ),
    const HomePageCard(
      header: '1 - 23/3/2023',
      title: '+ 840.000 VND',
      child: SizedBox(
        height: 300,
      ),
    ),
    const HomePageCard(
      header: '1 - 23/3/2023',
      title: '+ 840.000 VND',
      child: SizedBox(
        height: 300,
      ),
    ),
    const HomePageCard(
      header: '1 - 23/3/2023',
      title: '+ 840.000 VND',
      child: SizedBox(
        height: 300,
      ),
    ),
    const HomePageCard(
      header: '1 - 23/3/2023',
      title: '+ 840.000 VND',
      child: SizedBox(
        height: 300,
      ),
    ),
  ],
  2: [
    const HomePageCard(
      header: '2 - 23/3/2023',
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
  ],
  3: [
    const HomePageCard(
      header: '3 23/3/2023',
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
  ],
  4: [
    const HomePageCard(
      header: '4 - 23/3/2023',
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
  ],
};
