import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../common_widgets/rounded_icon_button.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/constants.dart';
import '../../../accounts/data/account_repo.dart';
import '../../../calculator_input/application/calculator_service.dart';
import '../../../transactions/data/transaction_repo.dart';

class SmallHomeTab extends ConsumerWidget {
  const SmallHomeTab({
    Key? key,
    required this.secondaryTitle,
    required this.hideNumber,
    required this.onEyeTap,
  }) : super(key: key);

  final String secondaryTitle;
  final bool hideNumber;
  final VoidCallback onEyeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountRepository = ref.watch(accountRepositoryProvider);

    double totalBalance = accountRepository.getTotalBalance();

    ref
        .watch(transactionChangesRealmProvider(DateTimeRange(start: Calendar.minDate, end: Calendar.maxDate)))
        .whenData((_) {
      totalBalance = accountRepository.getTotalBalance();
    });

    return PageHeading(
      leadingTitle: context.currentSettings.currency.code,
      title: CalService.formatCurrency(
        totalBalance,
        hideNumber: hideNumber,
      ),
      secondaryTitle: secondaryTitle,
      trailing: RoundedIconButton(
        iconPath: hideNumber ? AppIcons.eye : AppIcons.eyeSlash,
        backgroundColor: Colors.transparent,
        iconColor: context.appTheme.backgroundNegative,
        onTap: onEyeTap,
      ),
    );
  }
}
