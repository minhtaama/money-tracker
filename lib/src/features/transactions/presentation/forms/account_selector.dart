import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_isar.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector({
    Key? key,
    required this.transactionType,
    required this.onChangedAccount,
    this.otherSelectedAccount,
  }) : super(key: key);

  final ValueChanged<AccountIsar?> onChangedAccount;
  final TransactionType transactionType;
  final AccountIsar? otherSelectedAccount;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> {
  AccountIsar? currentAccount;

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      label: currentAccount != null ? currentAccount!.name : 'Add Account',
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: currentAccount != null
          ? AppIcons.fromCategoryAndIndex(currentAccount!.iconCategory, currentAccount!.iconIndex)
          : AppIcons.add,
      backgroundColor:
          currentAccount != null ? AppColors.allColorsUserCanPick[currentAccount!.colorIndex][0] : Colors.transparent,
      color: currentAccount != null
          ? AppColors.allColorsUserCanPick[currentAccount!.colorIndex][1]
          : context.appTheme.backgroundNegative.withOpacity(0.4),
      height: null,
      width: null,
      border: currentAccount != null
          ? null
          : Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(0.4),
            ),
      onTap: () async {
        List<AccountIsar> accountList = ref.read(accountRepositoryProvider).getList();

        final returnedValue = await showCustomModalBottomSheet<AccountIsar>(
          context: context,
          child: accountList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap.h16,
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Choose Account',
                        style: kHeader2TextStyle.copyWith(color: context.appTheme.backgroundNegative),
                      ),
                    ),
                    Gap.h16,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(accountList.length, (index) {
                        final account = accountList[index];
                        return IgnorePointer(
                          ignoring: widget.otherSelectedAccount?.id == account.id,
                          child: IconWithTextButton(
                            iconPath: AppIcons.fromCategoryAndIndex(account.iconCategory, account.iconIndex),
                            label: account.name,
                            isDisabled: widget.otherSelectedAccount?.id == account.id,
                            labelSize: 18,
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: Border.all(
                              color: currentAccount?.id == account.id
                                  ? AppColors.allColorsUserCanPick[account.colorIndex][0]
                                  : context.appTheme.backgroundNegative.withOpacity(0.4),
                            ),
                            backgroundColor: currentAccount?.id == account.id
                                ? AppColors.allColorsUserCanPick[account.colorIndex][0]
                                : Colors.transparent,
                            color: currentAccount?.id == account.id
                                ? AppColors.allColorsUserCanPick[account.colorIndex][1]
                                : context.appTheme.backgroundNegative,
                            onTap: () => context.pop<AccountIsar>(account),
                            height: null,
                            width: null,
                          ),
                        );
                      }),
                    ),
                    Gap.h32,
                  ],
                )
              : Text('NO ACCOUNT'),
          //TODO: Create an empty list widget
        );

        setState(() {
          if (returnedValue != null) {
            if (currentAccount != null && currentAccount!.id == returnedValue.id) {
              currentAccount = null;
              widget.onChangedAccount(currentAccount);
            } else {
              currentAccount = returnedValue;
              widget.onChangedAccount(currentAccount);
            }
          }
        });
      },
    );
  }
}
