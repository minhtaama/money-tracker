import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/presentation/screen_details/regular/regular_details.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import '../../../theme_and_ui/icons.dart';
import '../domain/account_base.dart';
import 'screen_details/credit/credit_details.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({
    super.key,
    required this.objectIdHexString,
  });

  final String objectIdHexString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnRepo = ref.watch(accountRepositoryProvider);

    try {
      Account account = txnRepo.getAccountFromHex(objectIdHexString);

      ref.watch(accountStreamProvider(objectIdHexString)).whenData(
            (value) => account = value,
          );

      ref.watch(transactionsChangesStreamProvider).whenData(
            (_) => account = txnRepo.getAccountFromHex(objectIdHexString),
          );

      return switch (account) {
        CreditAccount() => CreditScreenDetails(creditAccount: account as CreditAccount),
        RegularAccount() => RegularScreenDetails(regularAccount: account as RegularAccount),
        SavingAccount() => throw StateError('This screen is not for SavingAccount'),
      };
    } catch (e) {
      return IconWithText(
        iconPath: AppIcons.deleteLight,
        text: 'Account deleted!',
      );
    }
  }
}
