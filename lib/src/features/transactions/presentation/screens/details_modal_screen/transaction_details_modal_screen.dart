import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/hideable_container.dart';
import 'package:money_tracker_app/src/common_widgets/modal_screen_components.dart';
import 'package:money_tracker_app/src/common_widgets/money_amount.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/calculator_input/presentation/calculator_input.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/controllers/credit_payment_form_controller.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/card_item.dart';
import '../../../../../common_widgets/custom_checkbox.dart';
import '../../../../../common_widgets/custom_section.dart';
import '../../../../../common_widgets/custom_text_form_field.dart';
import '../../../../../common_widgets/icon_with_text.dart';
import '../../../../../common_widgets/icon_with_text_button.dart';
import '../../../../../common_widgets/inline_text_form_field.dart';
import '../../../../../common_widgets/modal_and_dialog.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../utils/constants.dart';
import '../../../../../utils/enums.dart';
import '../../../../accounts/data/account_repo.dart';
import '../../../../category/domain/category.dart';
import '../../../domain/transaction_base.dart';
import '../../components/base_transaction_components.dart';
import '../../controllers/credit_spending_form_controller.dart';
import '../../controllers/regular_txn_form_controller.dart';

part 'components.dart';
part 'payment_details.dart';
part 'spending_details.dart';
part 'installment_details.dart';
part 'regular_details.dart';

class TransactionDetailsModalScreen extends ConsumerWidget {
  const TransactionDetailsModalScreen(
    this.controller,
    this.isScrollable, {
    super.key,
    required this.objectIdHexString,
    required this.screenType,
  });

  final String objectIdHexString;
  final TransactionScreenType screenType;

  final ScrollController controller;
  final bool isScrollable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnRepo = ref.watch(transactionRepositoryRealmProvider);

    try {
      BaseTransaction transaction = txnRepo.getTransactionFromHex(objectIdHexString);

      ref.watch(transactionStreamProvider(objectIdHexString)).whenData(
            (value) => transaction = value,
          );

      return switch (transaction) {
        BaseRegularTransaction() =>
          _RegularDetails(screenType, controller, isScrollable, transaction: transaction as BaseRegularTransaction),
        CreditSpending() => screenType == TransactionScreenType.installmentToPay
            ? _InstallmentDetails(transaction: transaction as CreditSpending)
            : _SpendingDetails(screenType, controller, isScrollable, transaction: transaction as CreditSpending),
        CreditPayment() =>
          _PaymentDetails(screenType, controller, isScrollable, transaction: transaction as CreditPayment),
        CreditCheckpoint() => const Placeholder(),
      };
    } catch (e) {
      return IconWithText(
        iconPath: AppIcons.delete,
        text: 'Transaction deleted!'.hardcoded,
      );
    }
  }
}
