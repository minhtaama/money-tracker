import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import '../../../utils/enums.dart';

class CreditAccountServices {
  CreditAccountServices(this.accountRepo);

  final AccountRepositoryRealmDb accountRepo;

  double getTotalBalance({bool includeCreditAccount = false}) {
    double totalBalance = 0;
    final List<Account> accountList;
    if (includeCreditAccount) {
      accountList = accountRepo.getList(null);
    } else {
      accountList = accountRepo.getList([AccountType.regular]);
    }
    for (Account account in accountList) {
      totalBalance += account.availableAmount;
    }
    return totalBalance;
  }
}

/////////////////// PROVIDERS //////////////////////////

final accountServicesProvider = Provider<CreditAccountServices>(
  (ref) {
    final repo = ref.watch(accountRepositoryProvider);

    return CreditAccountServices(repo);
  },
);
