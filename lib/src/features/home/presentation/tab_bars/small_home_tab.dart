import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/features/accounts/application/account_services.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../transactions/data/transaction_repo.dart';

class SmallHomeTab extends ConsumerWidget {
  const SmallHomeTab({
    super.key,
    required this.secondaryTitle,
    required this.showNumber,
    required this.onEyeTap,
  });

  final String secondaryTitle;
  final bool showNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountService = ref.watch(accountServicesProvider);

    double totalBalance = accountService.getTotalBalance();

    ref.watch(transactionsChangesStreamProvider).whenData((_) {
      totalBalance = accountService.getTotalBalance();
    });

    return PageHeading(
      leadingTitle: context.appSettings.currency.code,
      title: CalService.formatCurrency(
        context,
        totalBalance,
      ),
      secondaryTitle: secondaryTitle,
      trailing: RoundedIconButton(
        iconPath: !showNumber ? AppIcons.eyeBulk : AppIcons.eyeSlashBulk,
        backgroundColor: Colors.transparent,
        iconColor: context.appTheme.onBackground,
        onTap: onEyeTap,
      ),
    );
  }
}
