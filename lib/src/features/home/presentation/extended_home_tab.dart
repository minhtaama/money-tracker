import 'package:flutter/material.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/icon_extension.dart';
import 'package:money_tracker_app/src/utils/extensions/string_extension.dart';
import 'package:money_tracker_app/src/utils/constants.dart';

class ExtendedHomeTab extends StatelessWidget {
  const ExtendedHomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GestureDetector(
        onTap: () => print('extended child tapped'),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.up,
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                Expanded(
                  flex: 7,
                  child: Row(
                    children: const [
                      Expanded(
                        child: IncomeExpenseCard(isIncome: true),
                      ),
                      Expanded(
                        child: IncomeExpenseCard(isIncome: false),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: TotalMoney(),
                ),
                const Expanded(
                  flex: 2,
                  child: WelcomeText(),
                ),
                Gap.h8,
              ],
            ),
            const Align(alignment: Alignment.bottomCenter, child: DateSelector()),
          ],
        ),
      ),
    );
  }
}

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, Minh Tâm'.hardcoded,
      style: kHeader2TextStyle.copyWith(color: context.appTheme.primaryNegative),
    );
  }
}

class TotalMoney extends StatelessWidget {
  const TotalMoney({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.wallet, size: 28, color: context.appTheme.primaryNegative).temporaryIcon,
        Gap.w8,
        Expanded(
          child: Text(
            '9.000.000 VND'.hardcoded,
            style: kHeader1TextStyle.copyWith(
              color: context.appTheme.primaryNegative,
            ),
          ),
        ),
        Icon(Icons.remove_red_eye, color: context.appTheme.primaryNegative).temporaryIcon
      ],
    );
  }
}

class IncomeExpenseCard extends StatelessWidget {
  const IncomeExpenseCard({
    super.key,
    required this.isIncome,
  });

  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CardItem(
        color: isIncome ? context.appTheme.primary : context.appTheme.accent,
        width: double.infinity,
        height: double.infinity,
        child: Text(
          isIncome ? 'Income' : 'Expense',
          style: kHeader2TextStyle.copyWith(
              color: isIncome ? context.appTheme.primaryNegative : context.appTheme.backgroundNegative,
              fontSize: 20),
        ),
      ),
    );
  }
}

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardItem(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.keyboard_arrow_left).temporaryIcon,
          Gap.w4,
          FittedBox(
            child: Text(
              'December, 2023'.hardcoded,
              style: kHeader4TextStyle.copyWith(color: context.appTheme.backgroundNegative),
            ),
          ),
          Gap.w4,
          const Icon(Icons.keyboard_arrow_right).temporaryIcon,
        ],
      ),
    );
  }
}
