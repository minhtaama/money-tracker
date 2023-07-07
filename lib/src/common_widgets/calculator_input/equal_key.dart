import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../utils/constants.dart';
import '../card_item.dart';

class EqualKey extends StatelessWidget {
  const EqualKey({
    Key? key,
    required this.onEqual,
  }) : super(key: key);
  final VoidCallback onEqual;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      key: key,
      color: context.appTheme.background3,
      padding: EdgeInsets.zero,
      margin: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(1000),
      elevation: 0,
      isGradient: true,
      child: InkWell(
        onTap: () => onEqual(),
        highlightColor: context.appTheme.backgroundNegative.withAlpha(105),
        borderRadius: BorderRadius.circular(1000),
        child: const Center(
          child: Text('=', style: kHeader2TextStyle),
        ),
      ),
    );
  }
}
