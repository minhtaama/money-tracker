import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../theme_and_ui/icons.dart';
import '../../../utils/enums.dart';
import '../../accounts/domain/account_base.dart';

class AccountSelector extends ConsumerStatefulWidget {
  const AccountSelector({
    super.key,
    required this.accountType,
    this.initialValue,
    required this.onChangedAccount,
    this.otherSelectedAccount,
    required this.withSavingAccount,
  });

  final ValueChanged<Account?> onChangedAccount;
  final AccountType accountType;
  final Account? initialValue;
  final Account? otherSelectedAccount;
  final bool withSavingAccount;

  @override
  ConsumerState<AccountSelector> createState() => _AccountSelectorState();
}

class _AccountSelectorState extends ConsumerState<AccountSelector> {
  Account? _currentAccount;

  @override
  void didUpdateWidget(covariant AccountSelector oldWidget) {
    if (widget.initialValue != oldWidget.initialValue) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        setState(() {
          _currentAccount = widget.initialValue;
        });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    setState(() {});
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return IconWithTextButton(
      label: _currentAccount != null ? _currentAccount!.name : 'Add Account',
      subLabel: _currentAccount is SavingAccount ? context.loc.savings : null,
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: _currentAccount != null ? _currentAccount!.iconPath : AppIcons.add,
      backgroundColor: _currentAccount != null ? _currentAccount!.backgroundColor : Colors.transparent,
      color: _currentAccount != null ? _currentAccount!.iconColor : context.appTheme.onBackground.withOpacity(0.4),
      height: null,
      width: null,
      border: _currentAccount != null
          ? null
          : Border.all(
              color: context.appTheme.onBackground.withOpacity(0.4),
            ),
      onTap: () async {
        List<Account> accountList = ref.read(accountRepositoryProvider).getList([widget.accountType]);

        List<SavingAccount>? savingList = widget.withSavingAccount
            ? ref.read(accountRepositoryProvider).getList([AccountType.saving]).whereType<SavingAccount>().toList()
            : null;

        final returnedValue = await showCustomModal<Account>(
          context: context,
          builder: (controller, isScrollable) => ModalContent(
            header: ModalHeader(
              title: 'Choose Account'.hardcoded,
            ),
            body: accountList.isNotEmpty
                ? [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(accountList.length, (index) {
                        final account = accountList[index];
                        return _accountButton(account);
                      }),
                    ),
                    savingList != null
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 24.0, bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  context.loc.savings,
                                  style: kHeader3TextStyle.copyWith(
                                    color: context.appTheme.onBackground.withOpacity(0.65),
                                    fontSize: 14,
                                  ),
                                ),
                                Gap.w4,
                                Expanded(
                                  child: Gap.divider(context, indent: 6),
                                ),
                              ],
                            ),
                          )
                        : Gap.noGap,
                    savingList != null
                        ? Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: List.generate(savingList.length, (index) {
                              final account = savingList[index];
                              return _accountButton(account);
                            }),
                          )
                        : Gap.noGap,
                    context.isBigScreen ? Gap.noGap : Gap.h32,
                  ]
                : [
                    Gap.h8,
                    IconWithText(
                      header:
                          'No${widget.accountType == AccountType.credit ? ' credit' : ''} account.\n Tap here to create a first one'
                              .hardcoded,
                      headerSize: 14,
                      iconPath: AppIcons.accounts,
                      onTap: () {
                        context.pop();
                        context.push(RoutePath.addAccount);
                      },
                    ),
                    Gap.h48,
                  ],
            footer: Gap.noGap,
          ),
        );

        setState(() {
          if (returnedValue != null) {
            if (_currentAccount != null && _currentAccount!.databaseObject.id == returnedValue.databaseObject.id) {
              _currentAccount = null;
              widget.onChangedAccount(_currentAccount);
            } else {
              _currentAccount = returnedValue;
              widget.onChangedAccount(_currentAccount);
            }
          }
        });
      },
    );
  }

  Widget _accountButton(Account account) => IgnorePointer(
        ignoring: widget.otherSelectedAccount?.databaseObject.id == account.databaseObject.id,
        child: IconWithTextButton(
          iconPath: account.iconPath,
          label: account.name,
          isDisabled: widget.otherSelectedAccount?.databaseObject.id == account.databaseObject.id,
          labelSize: 18,
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          border: Border.all(
            color: _currentAccount?.databaseObject.id == account.databaseObject.id
                ? account.backgroundColor
                : context.appTheme.onBackground.withOpacity(0.4),
          ),
          backgroundColor: _currentAccount?.databaseObject.id == account.databaseObject.id
              ? account.backgroundColor
              : Colors.transparent,
          color: _currentAccount?.databaseObject.id == account.databaseObject.id
              ? account.iconColor
              : context.appTheme.onBackground,
          onTap: () => context.pop<Account>(account),
          height: null,
          width: null,
        ),
      );
}
