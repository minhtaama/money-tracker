import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_tile.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../../common_widgets/custom_page/custom_page.dart';
import '../../../../common_widgets/page_heading.dart';
import '../../../../utils/constants.dart';
import '../../data/settings_repo.dart';

class SelectCurrencyScreen extends ConsumerWidget {
  const SelectCurrencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyList = List.from(Currency.values);
    final currentCurrency = context.appSettings.currency;
    currencyList
      ..remove(currentCurrency)
      ..insert(0, currentCurrency);

    return CustomPage(
      smallTabBar: const SmallTabBar(
        firstChild: PageHeading(
          title: 'Set Currency',
        ),
      ),
      children: [
        CustomSection(
          isWrapByCard: true,
          sections: List.generate(
              currencyList.length,
              (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: CustomTile(
                      title: currencyList[index].code,
                      secondaryTitle: currencyList[index].name,
                      trailing: CardItem(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                        width: 50,
                        color: context.appSettings.currency == currencyList[index]
                            ? context.appTheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: context.appSettings.currency == currencyList[index]
                              ? context.appTheme.primary
                              : context.appTheme.onBackground,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currencyList[index].symbol,
                            style: kHeader1TextStyle.copyWith(
                                color: context.appSettings.currency == currencyList[index]
                                    ? context.appTheme.onPrimary
                                    : context.appTheme.onBackground,
                                fontSize: 15),
                          ),
                        ),
                      ),
                      onTap: () {
                        final settingController = ref.read(settingsControllerProvider.notifier);
                        settingController.set(currency: currencyList[index]);
                        context.pop();
                      },
                    ),
                  )),
        ),
      ],
    );
  }
}
