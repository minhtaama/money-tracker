import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import '../domain/statement/base_class/statement.dart';

class CreditAccountServices {
  CreditAccountServices(this.accountRepo, this.creditAccount);

  final AccountRepositoryRealmDb accountRepo;
  final CreditAccount creditAccount;

  void adjustPaymentToFitAPRChanges(double newAPR) {
    for (Statement statement in creditAccount.statementsList) {}
  }
}

/////////////////// PROVIDERS //////////////////////////

final creditAccountServicesProvider = Provider.family<CreditAccountServices, CreditAccount>(
  (ref, creditAccount) {
    final repo = ref.watch(accountRepositoryProvider);

    return CreditAccountServices(repo, creditAccount);
  },
);
