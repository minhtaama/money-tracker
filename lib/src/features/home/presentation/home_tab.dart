import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import '../../../utils/constants.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('child tapped'),
      child: Container(
        color: Color.lerp(context.appTheme.background, context.appTheme.secondary, 0.15)!,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
      ),
    );
  }
}
