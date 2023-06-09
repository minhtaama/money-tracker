import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/modal_bottom_sheet_page.dart';

class AddTransactionModalScreen extends StatelessWidget {
  const AddTransactionModalScreen(this.transactionType, {Key? key}) : super(key: key);
  final TransactionType transactionType;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
    //TODO: Implement this screen
  }
}

/// This function is used in app_router to show a [ModalBottomSheetPage]
Page<T> showAddTransactionModalPage<T>(BuildContext context, GoRouterState state,
    {required Widget child}) {
  return ModalBottomSheetPage(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.92,
    ),
    backgroundColor: context.appTheme.background,
    modalBarrierColor: context.appTheme.background.withOpacity(kModalBarrierOpacity - 0.3),
    child: child,
    isScrollControlled: true,
  );
}
