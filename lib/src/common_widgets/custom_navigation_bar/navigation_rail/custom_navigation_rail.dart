import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'navigation_rail_button.dart';

//This class is used as element in `items` list of BottomAppBarWithFAB
class NavigationRailItem {
  const NavigationRailItem({
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

class CustomNavigationRail extends ConsumerStatefulWidget {
  const CustomNavigationRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.isShow,
  });

  final List<NavigationRailItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final bool isShow;

  @override
  ConsumerState<CustomNavigationRail> createState() => _CustomNavigationRailState();
}

class _CustomNavigationRailState extends ConsumerState<CustomNavigationRail> {
  late int _selectedIndex = widget.selectedIndex;

  @override
  void didUpdateWidget(covariant CustomNavigationRail oldWidget) {
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
    super.didUpdateWidget(oldWidget);
  }

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
    List<Widget> buttons = List.generate(widget.items.length, (index) {
      bool isSelected = _selectedIndex == index;
      return NavigationRailButton(
        index: index,
        onTap: _updateIndex,
        item: widget.items[index],
        isSelected: isSelected,
      );
    });

    return Theme(
      data: ThemeData(useMaterial3: false),
      child: HideableContainer(
        hide: !widget.isShow,
        axis: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: context.appTheme.background1,
            border: Border(
              right: BorderSide(color: context.appTheme.background2, width: 1.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Gap.statusBarHeight(context),
              ),
              ...buttons,
            ],
          ),
        ),
      ),
    );
  }
}
