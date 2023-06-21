import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class HomePageCard extends StatelessWidget {
  const HomePageCard({Key? key, this.header, this.title, required this.child}) : super(key: key);
  final String? header;
  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CardItem(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header != null
                ? Text(
                    header!,
                    style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                    textAlign: TextAlign.left,
                  )
                : const SizedBox(),
            title != null
                ? Text(
                    title!,
                    style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                    textAlign: TextAlign.left,
                  )
                : const SizedBox(),
            header != null || title != null ? Gap.divider(context) : const SizedBox(),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
