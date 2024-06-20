import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavingScreen extends ConsumerWidget {
  const SavingScreen({
    super.key,
    required this.objectIdHexString,
  });

  final String objectIdHexString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final txnRepo = ref.watch(accountRepositoryProvider);
    // Account account = txnRepo.getAccountFromHex(objectIdHexString);
    //
    // ref.watch(accountStreamProvider(objectIdHexString)).whenData(
    //       (value) => account = value,
    // );
    //
    // ref.watch(transactionsChangesStreamProvider).whenData(
    //       (_) => account = txnRepo.getAccountFromHex(objectIdHexString),
    // );

    return Placeholder();
  }
}
