import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../theme_and_ui/icons.dart';
import '../../card_item.dart';
import '../../svg_icon.dart';

class BackspaceKey extends StatelessWidget {
  const BackspaceKey({
    Key? key,
    required this.onBackspace,
  }) : super(key: key);
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.background3,
      width: 70,
      height: 70,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(3),
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: InkWell(
        onTap: onBackspace,
        highlightColor: context.appTheme.backgroundNegative.withAlpha(105),
        borderRadius: BorderRadius.circular(1000),
        child: Center(
          child: SvgIcon(AppIcons.backspace),
        ),
      ),
    );
  }
}
