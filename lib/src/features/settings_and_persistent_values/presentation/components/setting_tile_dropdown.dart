import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../utils/constants.dart';

class SettingTileDropDown<T> extends StatefulWidget {
  const SettingTileDropDown({
    super.key,
    this.leading,
    required this.title,
    required this.values,
    this.initialValue,
    required this.onChanged,
  });

  final Widget? leading;
  final String title;
  final List<(T, String)> values;
  final T? initialValue;
  final ValueSetter<T> onChanged;

  @override
  State<SettingTileDropDown<T>> createState() => _SettingTileDropDownState();
}

class _SettingTileDropDownState<T> extends State<SettingTileDropDown<T>> {
  final GlobalKey _dropdownButtonKey = GlobalKey();

  void _openDropdown() {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext element) {
      element.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector;
        } else {
          searchForGestureDetector(element);
        }
      });
    }

    searchForGestureDetector(_dropdownButtonKey.currentContext!);
    assert(detector != null);

    detector?.onTap?.call();
  }

  late T? _selectedValue = widget.initialValue;

  late List<DropdownMenuItem<T>> _dropDownItems = widget.values
      .map(
        (value) => DropdownMenuItem(
          value: value.$1,
          child: _menuName(value.$2),
        ),
      )
      .toList();

  Widget _menuName(String name) => Text(
        name,
        style: kNormalTextStyle.copyWith(
          color: context.appTheme.isDarkTheme ? context.appTheme.onAccent : context.appTheme.onBackground,
          fontSize: 13,
        ),
      );

  @override
  void didChangeDependencies() {
    setState(() {
      _dropDownItems = widget.values
          .map(
            (value) => DropdownMenuItem(
              value: value.$1,
              child: _menuName(value.$2),
            ),
          )
          .toList();
    });
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SettingTileDropDown<T> oldWidget) {
    setState(() {
      _selectedValue = widget.initialValue;
      _dropDownItems = widget.values
          .map(
            (value) => DropdownMenuItem(
              value: value.$1,
              child: _menuName(value.$2),
            ),
          )
          .toList();
    });
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      title: widget.title,
      onTap: _openDropdown,
      trailing: CardItem(
        color: context.appTheme.isDarkTheme ? context.appTheme.accent1 : context.appTheme.background2.withOpacity(0.7),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: DropdownButton<T>(
            key: _dropdownButtonKey,
            items: _dropDownItems,
            value: _selectedValue,
            isDense: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            dropdownColor: context.appTheme.isDarkTheme ? context.appTheme.accent1 : context.appTheme.background2,
            focusColor: Colors.blue,
            alignment: Alignment.centerLeft,
            borderRadius: BorderRadius.circular(16),
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgIcon(
                AppIcons.arrowRightLight,
                size: 16,
                color: context.appTheme.isDarkTheme ? context.appTheme.onAccent : context.appTheme.onBackground,
              ),
            ),
            elevation: 0,
            underline: Gap.noGap,
            onChanged: (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onChanged(value as T);
            }),
      ),
    );
  }
}
