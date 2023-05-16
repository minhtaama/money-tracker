import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/localization/extensions/string_extension.dart';
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

class ExtendedAppBar extends StatelessWidget {
  const ExtendedAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('extended child tapped'),
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SizedBox(
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Hello, Minh Tâm'.hardcoded,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wallet,
                        size: 28,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          '9.000.000 VND'.hardcoded,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(Icons.remove_red_eye)
                    ],
                  ),
                ),
                Flexible(
                  child: Center(
                    child: Container(
                      color: Colors.black,
                      width: 300,
                      height: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(Icons.keyboard_arrow_left),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Flexible(
                                  child: Text('JAN',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                              Flexible(
                                child: Text(
                                  '2023',
                                  style: TextStyle(fontSize: 18, height: 0),
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.keyboard_arrow_right),
                        ],
                      ),
                      SizedBox(width: 30),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('+', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                                  SizedBox(width: 3),
                                  Text(
                                    '2.000.000 VND',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('-', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                                  SizedBox(width: 3),
                                  Text(
                                    '3.240.000 VND',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChildAppBar extends StatelessWidget {
  const ChildAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('child tapped'),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Row(
            children: [
              const Icon(
                Icons.wallet,
                size: 28,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  '9.000.000 VND'.hardcoded,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Icon(Icons.remove_red_eye)
            ],
          ),
        ),
      ),
    );
  }
}

List<Widget> _coloredContainer = [
  const Card(
    // key: ValueKey(1),
    margin: EdgeInsets.all(8),
    color: Colors.red,
    child: SizedBox(
      width: 200,
      height: 100,
      child: Center(
        child: Text('Biểu đồ chi tiêu trong tháng'),
      ),
    ),
  ),
  const Card(
    // key: ValueKey(1),
    margin: EdgeInsets.all(8),
    color: Colors.green,
    child: SizedBox(
      width: 200,
      height: 100,
      child: Center(
        child: Text('Biểu đồ thu nhập trong tháng'),
      ),
    ),
  ),
  const Card(
    // key: ValueKey(1),
    margin: EdgeInsets.all(8),
    color: Colors.purple,
    child: SizedBox(
      width: 200,
      height: 200,
      child: Center(
        child: Text('Khoản tiết kiệm'),
      ),
    ),
  ),
  const Card(
    // key: ValueKey(1),
    margin: EdgeInsets.all(8),
    color: Colors.teal,
    child: SizedBox(
      width: 200,
      height: 800,
      child: Center(
        child: Text('Các transaction'),
      ),
    ),
  ),
];
