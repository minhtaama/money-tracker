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
  });

  final ValueChanged<Account?> onChangedAccount;
  final AccountType accountType;
  final Account? initialValue;
  final Account? otherSelectedAccount;

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
      labelSize: 15,
      borderRadius: BorderRadius.circular(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      iconPath: _currentAccount != null ? _currentAccount!.iconPath : AppIcons.add,
      backgroundColor: _currentAccount != null ? _currentAccount!.backgroundColor : Colors.transparent,
      color: _currentAccount != null
          ? _currentAccount!.iconColor
          : context.appTheme.onBackground.withOpacity(0.4),
      height: null,
      width: null,
      border: _currentAccount != null
          ? null
          : Border.all(
              color: context.appTheme.onBackground.withOpacity(0.4),
            ),
      onTap: () async {
        List<Account> accountList = ref.read(accountRepositoryProvider).getList(widget.accountType);

        final returnedValue = await showCustomModal<Account>(
          context: context,
          child: accountList.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ModalHeader(
                      withBackButton: false,
                      title: 'Choose Account'.hardcoded,
                    ),
                    Gap.h16,
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(accountList.length, (index) {
                        final account = accountList[index];
                        return IgnorePointer(
                          ignoring: widget.otherSelectedAccount?.databaseObject.id ==
                              account.databaseObject.id,
                          child: IconWithTextButton(
                            iconPath: account.iconPath,
                            label: account.name,
                            isDisabled: widget.otherSelectedAccount?.databaseObject.id ==
                                account.databaseObject.id,
                            labelSize: 18,
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: Border.all(
                              color: _currentAccount?.databaseObject.id == account.databaseObject.id
                                  ? account.backgroundColor
                                  : context.appTheme.onBackground.withOpacity(0.4),
                            ),
                            backgroundColor:
                                _currentAccount?.databaseObject.id == account.databaseObject.id
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
                      }),
                    ),
                    context.isBigScreen ? Gap.noGap : Gap.h32,
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                ),
        );

        setState(() {
          if (returnedValue != null) {
            if (_currentAccount != null &&
                _currentAccount!.databaseObject.id == returnedValue.databaseObject.id) {
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
}
