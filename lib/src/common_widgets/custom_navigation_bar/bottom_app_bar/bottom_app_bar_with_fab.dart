import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../custom_tab_page/provider.dart';
import 'bottom_app_bar_button.dart';

//This class is used as element in `items` list of BottomAppBarWithFAB
class BottomAppBarItem {
  const BottomAppBarItem({
    required this.path,
    required this.iconData,
    required this.text,
  });
  final String path;
  //TODO: Implement Hive icon
  final String iconData;
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
    // Watch to the provider value (represent user scroll direction)
    final isShowAppBar = ref.watch(scrollForwardStateProvider);

    double bottomAppBarHeight = isShowAppBar ? kBottomAppBarHeight : 0;
    bool isBottomAppBarGoUp = bottomAppBarHeight == kBottomAppBarHeight;

    //Generate button from items argument
    List<Widget> buttons = List.generate(widget.items.length, (index) {
      bool isSelected = _selectedIndex == index;
      return BottomAppBarButton(
        backgroundColor:
            context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.primary,
        index: index,
        onTap: _updateIndex,
        isLeft: index < widget.items.length / 2,
        item: widget.items[index],
        isSelected: isSelected,
      );
    });

    return AnimatedContainer(
      duration: k150msDuration,
      height: bottomAppBarHeight,
      child: Theme(
        data: ThemeData(useMaterial3: false),
        child: BottomAppBar(
          color: context.appTheme.background,
          surfaceTintColor: null,
          elevation: 11,
          child: AnimatedOpacity(
            opacity: isBottomAppBarGoUp ? 1 : 0,
            duration: k150msDuration,
            curve: isBottomAppBarGoUp ? Curves.easeInExpo : Curves.easeOutExpo,
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
