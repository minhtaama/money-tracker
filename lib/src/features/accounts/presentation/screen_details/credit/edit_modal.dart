import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/modal_and_dialog.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/features/selectors/presentation/date_time_selector/date_time_selector.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../../../../../common_widgets/custom_radio.dart';
import '../../../../../common_widgets/help_button.dart';
import '../../../../../common_widgets/inline_text_form_field.dart';
import '../../../../../routing/app_router.dart';
import '../../../../../utils/enums.dart';
import '../../../../calculator_input/application/calculator_service.dart';
import '../../../../calculator_input/presentation/calculator_input.dart';
import '../../../domain/account_base.dart';

class EditCreditAccountModalScreen extends ConsumerStatefulWidget {
  const EditCreditAccountModalScreen(this.currentCreditAccount, {super.key});
  final CreditAccount currentCreditAccount;

  @override
  ConsumerState<EditCreditAccountModalScreen> createState() => _EditCategoryModalScreenState();
}

class _EditCategoryModalScreenState extends ConsumerState<EditCreditAccountModalScreen> {
  late String newName;
  late String newIconCategory;
  late int newIconIndex;
  late int newColorIndex;

  final _installmentPaymentController = TextEditingController();

  late StatementType statementType = widget.currentCreditAccount.statementType;
  String calculatorOutput = '';
  String apr = '';

  @override
  void initState() {
    newName = widget.currentCreditAccount.name;
    newIconCategory = widget.currentCreditAccount.databaseObject.iconCategory;
    newIconIndex = widget.currentCreditAccount.databaseObject.iconIndex;
    newColorIndex = widget.currentCreditAccount.databaseObject.colorIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSection(
      title: 'Edit credit account'.hardcoded,
      isWrapByCard: false,
      sections: [
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[newColorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[newColorIndex][1],
              initialIconCategory: widget.currentCreditAccount.databaseObject.iconCategory,
              initialIconIndex: widget.currentCreditAccount.databaseObject.iconIndex,
              onTap: (iconC, iconI) {
                newIconCategory = iconC;
                newIconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextFormField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[newColorIndex][0],
                hintText: widget.currentCreditAccount.name,
                onChanged: (value) {
                  newName = value;
                },
              ),
            ),
          ],
        ),
        Gap.h24,
        ColorSelectListView(
          initialColorIndex: widget.currentCreditAccount.databaseObject.colorIndex,
          onColorTap: (index) {
            setState(() {
              newColorIndex = index;
            });
          },
        ),
        Gap.h8,
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyBorder(context)),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap.h8,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InlineTextFormField(
                  prefixText: 'Credit Limit:',
                  suffixText: context.appSettings.currency.code,
                  widget: CalculatorInput(
                      fontSize: 18,
                      isDense: true,
                      textAlign: TextAlign.end,
                      formattedResultOutput: (value) => calculatorOutput = value,
                      focusColor: context.appTheme.secondary1,
                      hintText: CalService.formatNumberInGroup(widget.currentCreditAccount.creditLimit.toString())),
                ),
              ),
              Gap.h12,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: InlineTextFormField(
                  prefixText: 'Account APR:',
                  width: 60,
                  suffixText: '%',
                  hintText: widget.currentCreditAccount.apr.toString(),
                  suffixWidget: HelpButton(
                    title: 'Annual Percentage Rate',
                    text:
                        'A standardized measure to express the total cost of borrowing over a year, includes the interest rate and any associated fees.'
                            .hardcoded,
                    yOffset: 4,
                  ),
                  maxLength: 5,
                  validator: (_) => CalService.formatToDouble(apr) == null ? '' : null,
                  onChanged: (value) => apr = value,
                ),
              ),
              Gap.h8,
              Gap.divider(context, indent: 8),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  'Payment & Interest preferences:',
                  style: kHeader2TextStyle.copyWith(color: context.appTheme.onBackground, fontSize: 14),
                ),
              ),
              CustomRadio<StatementType>(
                label: 'Using Average Daily Balance'.hardcoded,
                subLabel: 'Can make payment in billing cycle, interest is calculated by ADB method'.hardcoded,
                value: StatementType.withAverageDailyBalance,
                groupValue: statementType,
                onChanged: (value) => setState(() {
                  statementType = value!;
                }),
              ),
              CustomRadio<StatementType>(
                label: 'Payment only in grace period',
                subLabel: 'Can not make payment in billing cycle, interest is calculated by other method.'.hardcoded,
                value: StatementType.payOnlyInGracePeriod,
                groupValue: statementType,
                onChanged: (value) => setState(() {
                  statementType = value!;
                }),
              ),
            ],
          ),
        ),
        Gap.h24,
        Row(
          children: [
            RoundedIconButton(
              size: 55,
              iconPath: AppIcons.delete,
              iconPadding: 15,
              backgroundColor: AppColors.greyBgr(context),
              iconColor: context.appTheme.onBackground,
              onTap: () {
                showConfirmModal(
                  context: context,
                  label: 'Are you sure that you want to delete credit account "${widget.currentCreditAccount.name}"?'
                      .hardcoded,
                  subLabel: '1 more confirmation to delete this account'.hardcoded,
                  onConfirm: () {
                    showConfirmModal(
                      context: context,
                      onlyIcon: true,
                      label: 'Are you sure? All transactions (except payments to this account) will be deleted, too.'
                          .hardcoded,
                      subLabel: 'Last warning. The account will be deleted after this confirmation.'.hardcoded,
                      onConfirm: () async {
                        context.go(RoutePath.accounts);
                        final accountRepo = ref.read(accountRepositoryProvider);
                        await Future.delayed(k550msDuration, () => accountRepo.delete(widget.currentCreditAccount));
                      },
                    );
                  },
                );
              },
            ),
            const Spacer(),
            IconWithTextButton(
              iconPath: AppIcons.edit,
              label: 'Done',
              backgroundColor: context.appTheme.accent1,
              onTap: () {
                final accountRepo = ref.read(accountRepositoryProvider);

                accountRepo.editCreditAccount(
                  widget.currentCreditAccount,
                  iconCategory: newIconCategory,
                  iconIndex: newIconIndex,
                  name: newName,
                  colorIndex: newColorIndex,
                  apr: apr == '' ? null : double.tryParse(apr),
                  statementType: statementType,
                  creditLimit: CalService.formatToDouble(calculatorOutput),
                );

                context.pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}
