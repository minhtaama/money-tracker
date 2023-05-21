import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/tab_page/presentation/tab_home/app_bar.dart';
import 'package:money_tracker_app/src/features/date_time/presentation/day_card.dart';
import 'package:money_tracker_app/src/features/tab_page/presentation/tab_home/extended_app_bar.dart';
import '../custom_tab_page/custom_tab_page.dart';
import '../custom_tab_page/custom_tab_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      customTabBar: const CustomTabBar(
        extendedChild: ExtendedAppBar(),
        child: ChildAppBar(),
      ),
      children: _coloredContainer,
    );
  }
}

List<Widget> _coloredContainer = [
  DayCard(
    header: 'Thứ 2 - 23/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Text('Transaction1'),
        Text('Transaction2'),
        Text('Transaction3'),
        Text('Transaction4'),
      ],
    ),
  ),
  DayCard(
    header: 'Thứ 3 - 24/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Text('Transaction1'),
        Text('Transaction2'),
        Text('Transaction3'),
        Text('Transaction4'),
      ],
    ),
  ),
  DayCard(
    header: 'Thứ 4 - 24/3/2023',
    title: '+ 840.000 VND',
    child: Column(
      children: const [
        Text('Transaction1'),
        Text('Transaction2'),
        Text('Transaction3'),
        Text('Transaction4'),
      ],
    ),
  ),
];
