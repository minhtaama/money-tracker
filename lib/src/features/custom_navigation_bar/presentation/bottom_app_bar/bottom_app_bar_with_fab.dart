import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/custom_navigation_bar/presentation/bottom_app_bar/tab_button.dart';
import 'package:money_tracker_app/src/features/custom_tab_page/presentation/custom_tab_page_controller.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

//This class is used as element in `items` list of BottomAppBarWithFAB
class BottomAppBarItem {
  const BottomAppBarItem({required this.path, required this.iconData, required this.text});
  final String path;
  //TODO: Implement Hive icon
  final IconData iconData;
  final String text;
}

// This class is the value of `BottomNavigationBar` argument of Scaffold, returns a
// BottomAppBar which watch to the showBottomAppBarStateProvider. Based on the provider
// value (user scroll direction), the BottomAppBar will be visible or not.

class BottomAppBarWithFAB extends ConsumerStatefulWidget {
  const BottomAppBarWithFAB({Key? key, required this.items, required this.onTabSelected})
      : super(key: key);
  final List<BottomAppBarItem> items;
  final ValueChanged<int> onTabSelected;

  @override
  ConsumerState<BottomAppBarWithFAB> createState() => _BottomAppBarWithFABState();
}

class _BottomAppBarWithFABState extends ConsumerState<BottomAppBarWithFAB> {
  late List<Widget> buttons;
  int _selectedIndex = 0;

  void _updateIndex(int index) {
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
    // Watch to the provider value (represent user scroll direction)
    final isShowAppBar =
        ref.watch(customListViewStateControllerProvider.select((value) => value.isScrollForward));
    double bottomAppBarHeight = isShowAppBar ? 70.0 : 0;
    bool isNavBarGoUp = bottomAppBarHeight == 70;

    //Generate button from items argument
    List<Widget> buttons = List.generate(widget.items.length, (index) {
      bool isSelected = _selectedIndex == index;
      return TabButton(
        backgroundColor: AppTheme.of(context).secondary,
        index: index,
        onTap: _updateIndex,
        isLeft: index < widget.items.length / 2,
        item: widget.items[index],
        isSelected: isSelected,
      );
    });

    return AnimatedContainer(
      duration: kNavBarDuration,
      height: bottomAppBarHeight,
      child: Theme(
        data: ThemeData(useMaterial3: false),
        child: BottomAppBar(
          color: AppTheme.of(context).background3, //TODO: Hardnumber
          surfaceTintColor: null,
          elevation: 0,
          child: AnimatedOpacity(
            opacity: isNavBarGoUp ? 1 : 0,
            duration: kNavBarDuration,
            curve: isNavBarGoUp ? Curves.easeInExpo : Curves.easeOutExpo,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons,
            ),
          ),
        ),
      ),
    );
  }
}
