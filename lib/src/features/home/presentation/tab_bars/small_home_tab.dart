import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class SmallHomeTab extends StatelessWidget {
  const SmallHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => print('child tapped'),
        child: PageHeading(
          title: 'VND 8.540.000',
          secondaryTitle: 'December, 2023',
          trailing: Icon(
            Icons.remove_red_eye,
            color: context.appTheme.backgroundNegative,
          ),
        ));
  }
}
