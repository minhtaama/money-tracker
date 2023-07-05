import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/select_icon_screen.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../routing/app_router.dart';
import '../../../theme_and_ui/icons.dart';

class IconSelectButton extends StatefulWidget {
  /// This button will push to [SelectIconsScreen]. The returned value
  /// can be used as argument in `onTap` function.
  const IconSelectButton({
    Key? key,
    required this.backGroundColor,
    required this.iconColor,
    required this.onTap,
    this.initialCategory = '',
    this.initialIconIndex = 0,
  }) : super(key: key);
  final Color backGroundColor;
  final Color iconColor;
  final String initialCategory;
  final int initialIconIndex;
  final Function(String, int) onTap;

  @override
  State<IconSelectButton> createState() => _IconSelectButtonState();
}

class _IconSelectButtonState extends State<IconSelectButton> {
  final keyList = AppIcons.iconsWithCategories.keys.toList();

  late String currentCategory;
  late int currentIconIndex;

  @override
  void initState() {
    currentCategory = widget.initialCategory;
    currentIconIndex = widget.initialIconIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RoundedIconButton(
      iconPath: AppIcons.fromCategoryAndIndex(currentCategory, currentIconIndex),
      backgroundColor: widget.backGroundColor,
      iconColor: widget.iconColor,
      iconPadding: 8,
      size: 50,
      onTap: () async {
        List<dynamic> returnedValue = await context.push(RoutePath.selectIcon) as List<dynamic>;
        setState(() {
          currentCategory = returnedValue[0];
          currentIconIndex = returnedValue[1];
        });
        widget.onTap(currentCategory, currentIconIndex);
      },
    );
  }
}
