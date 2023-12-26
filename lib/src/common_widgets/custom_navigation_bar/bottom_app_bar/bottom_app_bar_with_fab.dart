import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'bottom_app_bar_button.dart';

//This class is used as element in `items` list of BottomAppBarWithFAB
class BottomAppBarItem {
  const BottomAppBarItem({
    required this.path,
    required this.iconData,
    required this.text,
  });
  final String path;
  final String iconData;
  final String text;
}

// This class is the value of `BottomNavigationBar` argument of Scaffold, returns a
// BottomAppBar which watch to the showBottomAppBarStateProvider. Based on the provider
// value (user scroll direction), the BottomAppBar will be visible or not.

class BottomAppBarWithFAB extends ConsumerStatefulWidget {
  const BottomAppBarWithFAB({Key? key, required this.items, required this.onTabSelected}) : super(key: key);
  final List<BottomAppBarItem> items;
  final ValueChanged<int> onTabSelected;

  @override
  ConsumerState<BottomAppBarWithFAB> createState() => _BottomAppBarWithFABState();
}

class _BottomAppBarWithFABState extends ConsumerState<BottomAppBarWithFAB> {
  late List<Widget> buttons;
  int _selectedIndex = 0;

  void _updateIndex(int index) async {
    // wait for button animation
    await Future.delayed(const Duration(milliseconds: 100));
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Call the callback argument when index is updated. The callback is to
      // call the GoRouter to "go" to the destination  - change tab page.
      widget.onTabSelected(_selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    // // Watch to the provider value (represent user scroll direction)
    // final isShowAppBar = ref.watch(scrollForwardStateProvider);

    // double bottomAppBarHeight = isShowAppBar ? kBottomAppBarHeight : 0;
    // bool isBottomAppBarGoUp = bottomAppBarHeight == kBottomAppBarHeight;

    //Generate button from items argument
    List<Widget> buttons = List.generate(widget.items.length, (index) {
      bool isSelected = _selectedIndex == index;
      return BottomAppBarButton(
        backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background400 : context.appTheme.primary,
        index: index,
        onTap: _updateIndex,
        isLeft: index < widget.items.length / 2,
        item: widget.items[index],
        isSelected: isSelected,
      );
    });

    return Theme(
      data: ThemeData(useMaterial3: false),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  top: context.appTheme.isDarkTheme
                      ? BorderSide.none
                      : BorderSide(color: Colors.grey.shade200, width: 1.5)),
            ),
            child: BottomAppBar(
              height: kBottomAppBarHeight,
              color: context.appTheme.background500.withOpacity(context.appTheme.isDarkTheme ? 0.7 : 0.5),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: buttons,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
