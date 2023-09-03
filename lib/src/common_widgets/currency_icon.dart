import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../features/settings/data/settings_controller.dart';
import '../theme_and_ui/colors.dart';
import '../utils/constants.dart';
import 'card_item.dart';

class CurrencyIcon extends ConsumerWidget {
  const CurrencyIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsObject = ref.watch(settingsControllerProvider);

    return CardItem(
      height: 50,
      width: 50,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: EdgeInsets.zero,
      color: AppColors.grey,
      borderRadius: BorderRadius.circular(1000),
      child: FittedBox(
        child: Text(
          settingsObject.currency.symbol ?? settingsObject.currency.code,
          style: kHeader1TextStyle.copyWith(
            color: context.appTheme.backgroundNegative,
          ),
        ),
      ),
    );
  }
}
