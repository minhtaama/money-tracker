// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:money_tracker_app/src/common_widgets/card_item.dart';
// import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
// import 'package:money_tracker_app/src/common_widgets/icon_with_text.dart';
// import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
// import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
// import 'package:money_tracker_app/src/features/calculator_input/application/calculator_service.dart';
// import 'package:money_tracker_app/src/features/transactions/domain/template_transaction.dart';
// import 'package:money_tracker_app/src/routing/app_router.dart';
// import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
// import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
// import '../../../../../utils/constants.dart';
// import '../../../data/template_transaction_repo.dart';
//
// class AddTemplateTransactionModalScreen extends ConsumerWidget {
//   const AddTemplateTransactionModalScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final templateRepository = ref.watch(tempTransactionRepositoryRealmProvider);
//
//     List<TemplateTransaction> templateTransactions = templateRepository.getTransactions();
//
//     ref.watch(tempTransactionsChangesStreamProvider).whenData((_) {
//       templateTransactions = templateRepository.getTransactions();
//     });
//
//     List<Widget> buildTemplateTiles(BuildContext context) {
//       return templateTransactions.isNotEmpty
//           ? List.generate(
//               templateTransactions.length,
//               (index) {
//                 TemplateTransaction model = templateTransactions[index];
//                 return _AccountTile(model: model);
//               },
//             )
//           : [
//               IconWithText(
//                 iconPath: AppIcons.heartOutline,
//                 header: 'No template transaction',
//               ),
//             ];
//     }
//
//     return CustomSection(
//       isWrapByCard: false,
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       onReorder: (oldIndex, newIndex) => templateRepository.reorder(null, oldIndex, newIndex),
//       sections: buildTemplateTiles(context),
//     );
//   }
// }
//
// class _AccountTile extends StatelessWidget {
//   const _AccountTile({required this.model});
//
//   final Account model;
//
//   @override
//   Widget build(BuildContext context) {
//     final fgColor = context.appTheme.onBackground;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: GestureDetector(
//         onTap: () => context.push(RoutePath.accountScreen, extra: model.databaseObject.id.hexString),
//         child: CardItem(
//           margin: EdgeInsets.zero,
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   RoundedIconButton(
//                     iconPath: model.iconPath,
//                     backgroundColor: model.backgroundColor,
//                     iconColor: model.iconColor,
//                     iconPadding: 8,
//                   ),
//                   Gap.w10,
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         model.name,
//                         style: kHeader2TextStyle.copyWith(color: fgColor, fontSize: 20),
//                         overflow: TextOverflow.fade,
//                         softWrap: false,
//                       ),
//                       Text(
//                         model is CreditAccount ? 'Credit account' : 'Regular Account',
//                         style: kNormalTextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 13),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               model is CreditAccount ? _CreditDetails(model: model as CreditAccount) : Gap.h16,
//               Text(
//                 model is RegularAccount ? 'Current Balance:' : 'Outstanding credit:',
//                 style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 13),
//               ),
//               Row(
//                 // Account Current Balance
//                 children: [
//                   Text(
//                     context.appSettings.currency.code,
//                     style: kNormalTextStyle.copyWith(color: fgColor, fontSize: 23),
//                   ),
//                   Gap.w8,
//                   Expanded(
//                     child: Text(
//                       CalService.formatCurrency(context, model.availableAmount),
//                       style: kHeader1TextStyle.copyWith(color: fgColor, fontSize: 23),
//                       overflow: TextOverflow.fade,
//                       softWrap: false,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
