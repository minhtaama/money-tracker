import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker_app/persistent/base_model.dart';
import 'package:money_tracker_app/src/common_widgets/custom_inkwell.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/accounts/domain/account_base.dart';
import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
import 'package:money_tracker_app/src/features/calculator_input/presentation/calculator_input.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/features/category/domain/category_tag.dart';
import 'package:money_tracker_app/src/features/category/presentation/category_tag/category_tag_selector.dart';
import 'package:money_tracker_app/src/features/transactions/data/transaction_repo.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/selectors/date_time_selector/date_time_selector_components.dart';
import 'package:money_tracker_app/src/features/transactions/presentation/transaction/txn_components.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/color_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/date_time_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/card_item.dart';
import '../../../../../common_widgets/custom_section.dart';
import '../../../../../common_widgets/custom_text_form_field.dart';
import '../../../../../common_widgets/icon_with_text.dart';
import '../../../../../common_widgets/icon_with_text_button.dart';
import '../../../../../common_widgets/modal_bottom_sheets.dart';
import '../../../../../utils/constants.dart';
import '../../../../../utils/enums.dart';
import '../../../../accounts/data/account_repo.dart';
import '../../../../category/domain/category.dart';
import '../../../domain/transaction_base.dart';
import '../../controllers/credit_spending_form_controller.dart';
import '../../controllers/regular_txn_form_controller.dart';

part 'components.dart';
part 'credit_payment_details.dart';
part 'credit_spending_details.dart';
part 'regular_transaction_details.dart';

class TransactionDetailsModalScreen extends ConsumerWidget {
  const TransactionDetailsModalScreen({super.key, required this.objectIdHexString});

  final String objectIdHexString;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txnRepo = ref.watch(transactionRepositoryRealmProvider);

    try {
      BaseTransaction transaction = txnRepo.getTransaction(objectIdHexString);

      ref.watch(transactionStreamProvider(objectIdHexString)).whenData(
            (value) => transaction = value,
          );
      return switch (transaction) {
        BaseRegularTransaction() => _RegularDetails(transaction: transaction as BaseRegularTransaction),
        CreditSpending() => _SpendingDetails(transaction: transaction as CreditSpending),
        CreditPayment() => _PaymentDetails(transaction: transaction as CreditPayment),
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
