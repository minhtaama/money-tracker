import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_navigation_bar/scaffold_with_navigation_rail_shell.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../routing/custom_app_modal_page.dart';
import '../utils/constants.dart';
import 'icon_with_text.dart';
import 'icon_with_text_button.dart';

Future<T?> showStatefulDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, StateSetter stateSetter) builder,
}) {
  final key = GlobalKey();
  return showCustomDialog<T>(
    context: context,
    child: StatefulBuilder(key: key, builder: builder),
  );
}

Future<void> showErrorDialog(BuildContext context, String text, {bool enable = true}) {
  if (enable) {
    return showCustomDialog(
      context: context,
      child: IconWithText(
        iconPath: AppIcons.sadFaceBulk,
        color: context.appTheme.onBackground,
        header: text,
      ),
    );
  }

  return Future<void>(() => null);
}

/// This is a helper function to show a confirmation of user
Future<T?> showConfirmModal<T>({
  required BuildContext context,
  required String label,
  String? subLabel,
  String confirmLabel = 'Confirm',
  String? confirmIcon,
  required VoidCallback onConfirm,
  bool isOnTopNavigation = false,
}) {
  final aContext = isOnTopNavigation ? navigationRailKey.currentContext! : context;

  return showCustomModal<T>(
    context: aContext,
    child: Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap.h16,
            Text(
              label,
              style: kHeader3TextStyle.copyWith(
                color: aContext.appTheme.onBackground,
              ),
            ),
            subLabel != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      subLabel,
                      style: kNormalTextStyle.copyWith(
                        color: aContext.appTheme.onBackground,
                        fontSize: 14,
                      ),
                    ),
                  )
                : Gap.noGap,
            Gap.h24,
            Row(
              children: [
                Expanded(
                  child: IconWithTextButton(
                    iconPath: AppIcons.backLight,
                    labelSize: 18,
                    label: aContext.loc.goBack,
                    color: aContext.appTheme.onBackground,
                    backgroundColor: AppColors.greyBgr(aContext),
                    onTap: () => context.pop(),
                  ),
                ),
                Gap.w24,
                RoundedIconButton(
                  iconPath: confirmIcon ?? AppIcons.deleteLight,
                  iconColor: aContext.appTheme.onNegative,
                  backgroundColor: aContext.appTheme.negative,
                  onTap: () {
                    context.pop();
                    onConfirm();
                  },
                )
              ],
            ),
            Gap.h16,
          ],
        ),
      ),
    ),
  );
}

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Widget child,
  bool isTopNavigation = false,
}) {
  final NavigatorState navigator = Navigator.of(isTopNavigation ? navigationRailKey.currentContext! : context);
  return navigator.push(
    CustomAppDialogRoute(
      child: Material(
        type: MaterialType.transparency,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// This is a custom helper function to show a modal bottom sheet
/// rather than pushing a new screen.
Future<T?> showCustomModal<T>({
  required BuildContext context,
  Widget? child,
  Widget Function(ScrollController, bool)? builder,
}) {
  final NavigatorState navigator = Navigator.of(context);
  return navigator.push(
    CustomAppModalRoute(
      child: child,
      builder: builder,
    ),
  );
}
