import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

class PageHeading extends StatelessWidget {
  const PageHeading({Key? key, required this.title, this.leading, this.trailing, this.secondaryTitle})
      : super(key: key);
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final String? secondaryTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        secondaryTitle != null ? Gap.h8 : const SizedBox(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading ?? const SizedBox(),
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: kHeader1TextStyle,
                ),
              ),
              trailing ?? const SizedBox(),
            ],
          ),
        ),
        secondaryTitle != null
            ? Expanded(
                flex: 1,
                child: Text(
                  secondaryTitle!,
                  style: kHeader2TextStyle.copyWith(
                    color: context.appTheme.backgroundNegative.withOpacity(0.8),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
