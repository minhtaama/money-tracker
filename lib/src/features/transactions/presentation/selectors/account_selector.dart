import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_bottom_sheets.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../../theme_and_ui/icons.dart';
import '../../../../utils/enums.dart';
import '../../../accounts/domain/account_base.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector({
    Key? key,
    required this.accountType,
    required this.onChangedAccount,
    this.otherSelectedAccount,
  }) : super(key: key);

  final ValueChanged<Account?> onChangedAccount;
  final AccountType accountType;
  final Account? otherSelectedAccount;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> {
  Account? currentAccount;

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
      iconPath: currentAccount != null ? currentAccount!.iconPath : AppIcons.add,
      backgroundColor: currentAccount != null ? currentAccount!.backgroundColor : Colors.transparent,
      color: currentAccount != null ? currentAccount!.color : context.appTheme.backgroundNegative.withOpacity(0.4),
      height: null,
      width: null,
      border: currentAccount != null
          ? null
          : Border.all(
              color: context.appTheme.backgroundNegative.withOpacity(0.4),
            ),
      onTap: () async {
        List<Account> accountList = ref.read(accountRepositoryProvider).getList(widget.accountType);

        final returnedValue = await showCustomModalBottomSheet<Account>(
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
                            iconPath: account.iconPath,
                            label: account.name,
                            isDisabled: widget.otherSelectedAccount?.id == account.id,
                            labelSize: 18,
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: Border.all(
                              color: currentAccount?.id == account.id
                                  ? account.backgroundColor
                                  : context.appTheme.backgroundNegative.withOpacity(0.4),
                            ),
                            backgroundColor:
                                currentAccount?.id == account.id ? account.backgroundColor : Colors.transparent,
                            color:
                                currentAccount?.id == account.id ? account.color : context.appTheme.backgroundNegative,
                            onTap: () => context.pop<Account>(account),
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