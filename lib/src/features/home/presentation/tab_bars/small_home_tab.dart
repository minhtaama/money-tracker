import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../../utils/constants.dart';

class SmallHomeTab extends StatelessWidget {
  const SmallHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('child tapped'),
      child: SizedBox(
        height: double.infinity,
        child: Row(
          children: [
            const Icon(
              Icons.wallet,
              size: 28,
            ).temporaryIcon,
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text('9.000.000 VND'.hardcoded, style: kHeader2TextStyle),
            ),
            const Icon(Icons.remove_red_eye).temporaryIcon
          ],
        ),
      ),
    );
  }
}
