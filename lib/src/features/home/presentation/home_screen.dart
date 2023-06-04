import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/app_bar.dart';
import 'package:money_tracker_app/src/features/date_time/presentation/homepage_card.dart';
import 'package:money_tracker_app/src/features/home/presentation/extended_app_bar.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';

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
  HomePageCard(
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
  HomePageCard(
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
  HomePageCard(
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
