import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/features/home/presentation/home_tab.dart';
import 'package:money_tracker_app/src/features/transactions//presentation/homepage_card.dart';
import 'package:money_tracker_app/src/features/home/presentation/extended_home_tab.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_bar.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTabPage(
      customTabBar: CustomTabBar(
        extendedTabBar: ExtendedTabBar(
          backgroundColor: context.appTheme.secondary,
          child: const ExtendedHomeTab(),
        ),
        childTabBar: ChildTabBar(
          backgroundColor: context.appTheme.background,
          child: const HomeTab(),
        ),
      ),
      children: _testTransactions,
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
