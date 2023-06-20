import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class CustomSection extends StatelessWidget {
  const CustomSection({
    Key? key,
    required this.title,
    required this.children,
  }) : super(key: key);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              title,
              style: kHeader2TextStyle.copyWith(
                color: context.appTheme.backgroundNegative.withOpacity(0.7),
              ),
            ),
          ),
          Gap.h4,
          CardItem(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //children: children,
              children: List.generate(children.length, (index) {
                if (index != children.length - 1) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      children[index],
                      Gap.h8,
                      Gap.divider,
                      Gap.h4,
                    ],
                  );
                } else {
                  return children[index];
                }
              }),
            ),
          )
        ],
      ),
    );
  }
}
