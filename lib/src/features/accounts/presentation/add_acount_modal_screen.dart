import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/custom_slider_toggle.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_field.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/features/accounts/data/account_repo.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/color_select_list_view.dart';
import 'package:money_tracker_app/src/features/icons_and_colors/presentation/icon_select_button.dart';
import 'package:money_tracker_app/src/features/settings/data/settings_controller.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/constants.dart';
import 'package:money_tracker_app/src/utils/enums.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../calculator_input/presentation/calculator_input.dart';

class AddAccountModalScreen extends ConsumerStatefulWidget {
  const AddAccountModalScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AddAccountModalScreen> createState() => _AddAccountModalScreenState();
}

class _AddAccountModalScreenState extends ConsumerState<AddAccountModalScreen> {
  AccountType accountType = AccountType.onHand;
  String accountName = '';
  String iconCategory = '';
  int iconIndex = 0;
  int colorIndex = 0;
  double initialBalance = 0;

  @override
  Widget build(BuildContext context) {
    final settingsObject = ref.watch(settingsControllerProvider);

    return CustomSection(
      title: 'Add Account',
      isWrapByCard: false,
      children: [
        Row(
          textBaseline: TextBaseline.alphabetic,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          children: [
            Text(
              settingsObject.currency.code,
              style:
                  kHeader4TextStyle.copyWith(fontSize: 22, color: context.appTheme.backgroundNegative),
            ),
            Gap.w16,
            Expanded(
              child: CalculatorInput(
                hintText: 'Initial Balance',
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                noFormatResultOutput: (value) => initialBalance = double.parse(value),
              ),
            ),
          ],
        ),
        Gap.h24,
        CustomSliderToggle<AccountType>(
          values: const [AccountType.onHand, AccountType.credit],
          labels: const ['On Hand', 'Credit'],
          height: 42,
          onTap: (type) {
            accountType = type;
          },
        ),
        Gap.h24,
        Row(
          children: [
            IconSelectButton(
              backGroundColor: AppColors.allColorsUserCanPick[colorIndex][0],
              iconColor: AppColors.allColorsUserCanPick[colorIndex][1],
              onTap: (iconC, iconI) {
                iconCategory = iconC;
                iconIndex = iconI;
              },
            ),
            Gap.w16,
            Expanded(
              child: CustomTextField(
                autofocus: false,
                focusColor: AppColors.allColorsUserCanPick[colorIndex][0],
                hintText: 'Account Name',
                onChanged: (value) {
                  setState(() {
                    accountName = value;
                  });
                },
              ),
            ),
          ],
        ),
        Gap.h24,
        ColorSelectListView(
          onColorTap: (index) {
            setState(() {
              colorIndex = index;
            });
          },
        ),
        Gap.h24,
        Align(
          alignment: Alignment.centerRight,
          child: IconWithTextButton(
            icon: AppIcons.add,
            label: 'Create',
            backgroundColor: context.appTheme.accent,
            isDisabled: accountName.isEmpty,
            onTap: () {
              final accountRepository = ref.read(accountRepositoryProvider);
              // TODO: Implement add account
              // final categoryRepository = ref.read(categoryRepositoryIsarProvider);
              // categoryRepository.writeNewCategory(
              //   type: categoryType,
              //   iconCategory: iconCategory,
              //   iconIndex: iconIndex,
              //   name: categoryName,
              //   colorIndex: colorIndex,
              // );
              //TODO: implement add account
              context.pop();
            },
          ),
        ),
      ],
    );
  }
}
