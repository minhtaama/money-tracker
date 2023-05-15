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
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Thu nhập',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Chi tiêu',
                        style: TextStyle(fontSize: 18),
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
    margin: EdgeInsets.all(8),
    color: Colors.red,
    child: SizedBox(
      width: 200,
      height: 100,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.green,
    child: SizedBox(
      width: 200,
      height: 200,
    ),
  ),
  Container(
    color: Colors.blue,
    width: 200,
    height: 300,
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.purple,
    child: SizedBox(
      width: 200,
      height: 150,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.teal,
    child: SizedBox(
      width: 200,
      height: 100,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.red,
    child: SizedBox(
      width: 200,
      height: 100,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.green,
    child: SizedBox(
      width: 200,
      height: 200,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.purple,
    child: SizedBox(
      width: 200,
      height: 150,
    ),
  ),
  const Card(
    margin: EdgeInsets.all(8),
    color: Colors.teal,
    child: SizedBox(
      width: 200,
      height: 100,
    ),
  ),
];
