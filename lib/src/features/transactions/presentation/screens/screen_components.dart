import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/icon_with_text_button.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../../theme_and_ui/colors.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../accounts/domain/account.dart';
import '../../../../utils/constants.dart';
import '../../../settings/data/settings_controller.dart';

class CreditPaymentPeriodSelector extends ConsumerStatefulWidget {
  const CreditPaymentPeriodSelector({
    Key? key,
    required this.onChangedPeriod,
  }) : super(key: key);

  final ValueChanged<List<DateTime>> onChangedPeriod;

  @override
  ConsumerState<CreditPaymentPeriodSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<CreditPaymentPeriodSelector> {
  Account? currentAccount;

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CardItem(
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.transparent,
      height: 50,
      border: currentAccount != null
          ? null
          : Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(0.4),
            ),
      child: PageView(
        children: [Text('hi1'), Text('hi2'), Text('hi3'), Text('hi4')],
      ),
    );
  }
}

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
      color: AppColors.greyBgr(context),
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

class TextHeader extends StatelessWidget {
  const TextHeader(this.text, {super.key, this.fontSize = 15});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:
          kHeader2TextStyle.copyWith(fontSize: fontSize, color: context.appTheme.backgroundNegative.withOpacity(0.5)),
    );
  }
}

class BottomButtons extends StatelessWidget {
  const BottomButtons({super.key, required this.isDisabled, required this.onTap});
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundedIconButton(
          iconPath: AppIcons.back,
          backgroundColor: context.appTheme.primary,
          iconColor: context.appTheme.primaryNegative,
          size: 55,
          onTap: () => context.pop(),
        ),
        const Spacer(),
        IconWithTextButton(
          iconPath: AppIcons.add,
          label: 'Add',
          backgroundColor: context.appTheme.accent,
          isDisabled: isDisabled,
          onTap: onTap,
        ),
      ],
    );
  }
}
