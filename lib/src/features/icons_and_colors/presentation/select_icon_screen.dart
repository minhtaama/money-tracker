import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_section.dart';
import 'package:money_tracker_app/src/common_widgets/icon_with_text_button.dart';
import 'package:money_tracker_app/src/common_widgets/page_heading.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';

import '../../../common_widgets/custom_page/custom_tab_bar.dart';
import '../../../common_widgets/custom_page/custom_page.dart';
import '../../../utils/constants.dart';

class SelectIconsScreen extends StatefulWidget {
  /// When this screen is popped, the returned value has type of List<dynamic>,
  /// where the first element is the category name, the second element is
  /// the icon index.
  ///
  /// Take these two argument and assign like below:
  ///
  /// [AppIcons.iconsWithCategories[category-name]][[icon-index]]
  const SelectIconsScreen({super.key});

  @override
  State<SelectIconsScreen> createState() => _SelectIconsScreenState();
}

class _SelectIconsScreenState extends State<SelectIconsScreen> {
  final keyList = AppIcons.iconsWithCategories.keys.toList();

  String currentCategory = '';
  int currentIconIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appTheme.background1,
      floatingActionButton: IconWithTextButton(
        height: 60,
        iconPath: AppIcons.done,
        label: 'Choose',
        backgroundColor: context.appTheme.accent1,
        color: context.appTheme.onAccent,
        // Returned value is here
        onTap: () => context.pop([currentCategory, currentIconIndex]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: CustomPage(
        smallTabBar: const SmallTabBar(
          child: PageHeading(
            title: 'Choose Icon',
          ),
        ),
        children: List.generate(
          keyList.length,
          (keyIndex) {
            return CustomSection(
              title: keyList[keyIndex],
              sections: [
                Wrap(
                  spacing: 13,
                  runSpacing: 13,
                  children: List.generate(
                    AppIcons.iconsWithCategories[keyList[keyIndex]]!.length,
                    (iconIndex) {
                      return CircleIcon(
                        isSelected: currentCategory == keyList[keyIndex] && currentIconIndex == iconIndex,
                        onTap: (newIconCategory, newIconIndex) {
                          setState(
                            () {
                              currentCategory = newIconCategory;
                              currentIconIndex = newIconIndex;
                            },
                          );
                        },
                        iconCategory: keyList[keyIndex],
                        iconIndex: iconIndex,
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon(
      {Key? key, required this.isSelected, required this.onTap, required this.iconCategory, required this.iconIndex})
      : super(key: key);
  final String iconCategory;
  final int iconIndex;
  final bool isSelected;
  final Function(String, int) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: GestureDetector(
        onTap: () => onTap(iconCategory, iconIndex),
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.appTheme.background0,
                borderRadius: BorderRadius.circular(1000),
                border: Border.all(width: 2, color: AppColors.grey(context)),
              ),
            ),
            AnimatedOpacity(
              duration: k150msDuration,
              opacity: isSelected ? 1 : 0,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1000),
                  color: context.appTheme.primary,
                ),
              ),
            ),
            Center(
              child: SvgIcon(
                AppIcons.fromCategoryAndIndex(iconCategory, iconIndex),
                color: isSelected ? context.appTheme.onPrimary : context.appTheme.onBackground,
              ),
            )
          ],
        ),
      ),
    );
  }
}
