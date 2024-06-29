import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_radio.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/help_button.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/inline_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';

import '../../../common_widgets/card_item.dart';
import '../../../common_widgets/custom_inkwell.dart';
import '../../../common_widgets/icon_with_text.dart';
import '../../../routing/app_router.dart';
import '../../../theme_and_ui/icons.dart';
import '../../calculator_input/presentation/calculator_input.dart';
import '../../../common_widgets/modal_screen_components.dart';
import '../../transactions/data/transaction_repo.dart';
import '../../transactions/domain/transaction_base.dart';
import '../../transactions/presentation/components/base_transaction_components.dart';
import '../domain/account_base.dart';

class SavingModalScreen extends ConsumerWidget {
  const SavingModalScreen(this.controller, this.isScrollable, {super.key, required this.objectIdHexString});

  final ScrollController controller;
  final bool isScrollable;
  final String objectIdHexString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnRepo = ref.watch(accountRepositoryProvider);
    late final transactionRepository = ref.read(transactionRepositoryRealmProvider);

    try {
      Account account = txnRepo.getAccountFromHex(objectIdHexString);

      ref.watch(accountStreamProvider(objectIdHexString)).whenData(
            (value) => account = value,
          );

      List<Transfer> transactions = transactionRepository
          .getTransactionsOfAccount(account, Calendar.minDate, Calendar.maxDate)
          .whereType<Transfer>()
          .toList();

      ref.watch(transactionsChangesStreamProvider).whenData(
        (_) {
          transactions = transactionRepository
              .getTransactionsOfAccount(account, Calendar.minDate, Calendar.maxDate)
              .whereType<Transfer>()
              .toList();
          account = txnRepo.getAccountFromHex(objectIdHexString);
        },
      );

      return _Content(
        controller: controller,
        isScrollable: isScrollable,
        account: account as SavingAccount,
        transactions: transactions,
      );
    } catch (e) {
      return IconWithText(
        iconPath: AppIcons.deleteBulk,
        text: 'Account deleted!',
      );
    }
  }
}

class _Content extends StatelessWidget {
  const _Content({
    super.key,
    required this.controller,
    required this.isScrollable,
    required this.account,
    required this.transactions,
  });

  final ScrollController controller;
  final bool isScrollable;
  final SavingAccount account;
  final List<Transfer> transactions;

  @override
  Widget build(BuildContext context) {
    return ModalContent(
      controller: controller,
      isScrollable: isScrollable,
      header: ModalHeader(
        title: account.name,
      ),
      body: [
        _TransactionsList(transactions: transactions),
      ],
      footer: Gap.noGap,
    );
  }
}

class _TransactionsList extends StatefulWidget {
  const _TransactionsList({required this.transactions});

  final List<Transfer> transactions;

  @override
  State<_TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<_TransactionsList> {
  final GlobalKey _ancestorKey = GlobalKey();
  final GlobalKey _topKey = GlobalKey();
  final GlobalKey _bottomKey = GlobalKey();

  Offset _lineOffset = const Offset(0, 0);
  double _lineHeight = 0;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && widget.transactions.length > 1) {
        // Find RenderBox of the widget using globalKey
        RenderBox ancestorRenderBox = _ancestorKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox topRenderBox = _topKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox bottomRenderBox = _bottomKey.currentContext?.findRenderObject() as RenderBox;

        Offset topOffset = topRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
        Offset bottomOffset = bottomRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);

        setState(() {
          // translateY is padding of _Transaction widget, width of _DateTime widget and width of the line
          _lineOffset = topOffset.translate(topRenderBox.size.height / 2, 16 + 25 / 2 - 1);

          _lineHeight = bottomOffset.dy - topOffset.dy;
        });
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && widget.transactions.length > 1) {
        // Find RenderBox of the widget using globalKey
        RenderBox ancestorRenderBox = _ancestorKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox topRenderBox = _topKey.currentContext?.findRenderObject() as RenderBox;
        RenderBox bottomRenderBox = _bottomKey.currentContext?.findRenderObject() as RenderBox;

        Offset topOffset = topRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);
        Offset bottomOffset = bottomRenderBox.localToGlobal(Offset.zero, ancestor: ancestorRenderBox);

        setState(() {
          // translateY is padding of _Transaction widget, width of _DateTime widget and width of the line
          _lineOffset = topOffset.translate(topRenderBox.size.height / 2, 16 + 25 / 2 - 1);

          _lineHeight = bottomOffset.dy - topOffset.dy;
        });
      }
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: _ancestorKey,
      children: [
        Positioned(
          top: _lineOffset.dx,
          left: _lineOffset.dy,
          child: Container(
            width: 2,
            height: _lineHeight,
            color: AppColors.greyBorder(context),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: Column(
            children: buildList(context, widget.transactions, _topKey, _bottomKey),
          ),
        ),
      ],
    );
  }

  List<Widget> buildList(BuildContext context, List<Transfer> transactions, GlobalKey topKey, GlobalKey bottomKey) {
    final list = <Widget>[];

    for (int i = transactions.length - 1; i >= 0; i--) {
      final transaction = transactions[i];
      if (i == 0) {
        list.add(_Transaction(key: _bottomKey, transaction: transaction));
      } else if (i == transactions.length - 1) {
        list.add(_Transaction(key: _topKey, transaction: transaction));
      } else {
        list.add(_Transaction(transaction: transaction));
      }
    }

    return list;
  }
}

class _Transaction extends StatelessWidget {
  const _Transaction({super.key, required this.transaction});
  final Transfer transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: CustomInkWell(
        inkColor: AppColors.grey(context),
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push(RoutePath.transaction, extra: transaction.databaseObject.id.hexString),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.greyBorder(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                width: 26,
                constraints: const BoxConstraints(minHeight: 18),
                padding: const EdgeInsets.all(3),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        transaction.dateTime.day.toString(),
                        style: kHeader2TextStyle.copyWith(
                          color: context.appTheme.onBackground,
                          fontSize: 14,
                          height: 1,
                        ),
                      ),
                      Text(
                        transaction.dateTime.monthToString(context, short: true),
                        style: kHeader3TextStyle.copyWith(
                          color: context.appTheme.onBackground,
                          fontSize: 7,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gap.w4,
              Expanded(
                child: CardItem(
                  margin: const EdgeInsets.only(left: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  elevation: 0.7,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.isToSavingAccount ? 'Add from'.hardcoded : 'Remove to'.hardcoded,
                              style: kHeader4TextStyle.copyWith(
                                color: context.appTheme.onBackground.withOpacity(0.65),
                                fontSize: 12,
                                height: 1,
                              ),
                            ),
                            Gap.h4,
                            Text(
                              transaction.isToSavingAccount
                                  ? transaction.account.name
                                  : transaction.transferAccount.name,
                              style: kHeader2TextStyle.copyWith(
                                color: context.appTheme.onBackground,
                                fontSize: 14,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TxnAmount(
                        transaction: transaction,
                        fontSize: 15,
                        color: transaction.isFromSavingAccount ? context.appTheme.negative : context.appTheme.positive,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
