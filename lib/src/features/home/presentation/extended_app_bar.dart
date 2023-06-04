import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/theming/app_theme.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class ExtendedAppBar extends StatelessWidget {
  const ExtendedAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.of(context).primary, AppTheme.of(context).background],
        stops: [0, 1],
      )),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () => print('extended child tapped'),
  //     child: CardItem(
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             flex: 1,
  //             child: Text(
  //               'Hello, Minh Tâm'.hardcoded,
  //               style: kHeader2TextStyle,
  //             ),
  //           ),
  //           Expanded(
  //             flex: 2,
  //             child: Row(
  //               children: [
  //                 const Icon(Icons.wallet, size: 28).temporaryIcon,
  //                 Gap.w8,
  //                 Expanded(
  //                   child: Text(
  //                     '9.000.000 VND'.hardcoded,
  //                     style: kHeader1TextStyle,
  //                   ),
  //                 ),
  //                 const Icon(Icons.remove_red_eye).temporaryIcon
  //               ],
  //             ),
  //           ),
  //           const Flexible(child: Divider()),
  //           const Expanded(
  //             flex: 3,
  //             child: MonthDetails(),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

class MonthDetails extends StatelessWidget {
  const MonthDetails({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard_arrow_left).temporaryIcon,
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Flexible(child: Text('JAN', style: kHeader2TextStyle)),
                Flexible(
                  child: Text('2023', style: kHeader4TextStyle),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right).temporaryIcon,
          ],
        ),
        Gap.w8,
        Expanded(
          child: Card(
            // key: ValueKey(1),
            color: Colors.green,
            child: SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Center(
                child: Text('Line graphs\nMonthly expense'.hardcoded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
