import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';

class ChildAppBar extends StatelessWidget {
  const ChildAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print('child tapped'),
      child: Container(
        color: Theme.of(context).colorScheme.background,
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
                child: Text(
                  '9.000.000 VND'.hardcoded,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.remove_red_eye).temporaryIcon
            ],
          ),
        ),
      ),
    );
  }
}
