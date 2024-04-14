import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/routing/app_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'card_item.dart';
import 'icon_with_text.dart';
import 'icon_with_text_button.dart';

Future<T?> showStatefulDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, StateSetter stateSetter) builder,
}) {
  return showDialog<T>(
    useRootNavigator: false,
    context: context,
    builder: (_) {
      return StatefulBuilder(builder: builder);
    },
  );
}

Future<T?> showCustomDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return showDialog(
    useRootNavigator: false,
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: AlertDialog(
          surfaceTintColor: Colors.transparent,
          backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
          elevation: 5,
          content: child,
        ),
      );
    },
  );
}

Future<void> showErrorDialog(BuildContext context, String text, {bool enable = true}) {
  if (enable) {
    return showCustomDialog(
      context: context,
      child: IconWithText(
        iconPath: AppIcons.sadFace,
        color: context.appTheme.onBackground,
        header: text,
      ),
    );
  }

  return Future<void>(() => null);
}

/// This is a helper function to show a confirmation of user
Future<T?> showConfirmModalBottomSheet<T>({
  required BuildContext context,
  required String label,
  bool onlyIcon = false,
  String? subLabel,
  String confirmLabel = 'Confirm',
  String? confirmIcon,
  required VoidCallback onConfirm,
}) {
  return showModalBottomSheet<T>(
    context: context,
    elevation: 0,
    enableDrag: false,
    backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
    barrierColor:
        context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey(context).withOpacity(0.6),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.onBackground,
                ),
              ),
              subLabel != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        subLabel,
                        style: kNormalTextStyle.copyWith(
                          color: context.appTheme.onBackground,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : Gap.noGap,
              Gap.h24,
              Row(
                children: onlyIcon
                    ? [
                        Expanded(
                          child: IconWithTextButton(
                            iconPath: AppIcons.back,
                            label: context.localize.goBack,
                            color: context.appTheme.onBackground,
                            backgroundColor: AppColors.greyBgr(context),
                            onTap: () => context.pop(),
                          ),
                        ),
                        Gap.w24,
                        RoundedIconButton(
                          iconPath: confirmIcon ?? AppIcons.delete,
                          iconColor: context.appTheme.onNegative,
                          backgroundColor: context.appTheme.negative,
                          onLongPress: () {
                            context.pop();
                            onConfirm();
                          },
                        )
                      ]
                    : [
                        Expanded(
                          child: IconWithTextButton(
                            iconPath: AppIcons.back,
                            label: context.localize.goBack,
                            color: context.appTheme.onBackground,
                            backgroundColor: AppColors.greyBgr(context),
                            onTap: () => context.pop(),
                          ),
                        ),
                        Gap.w24,
                        RoundedIconButton(
                          iconPath: confirmIcon ?? AppIcons.delete,
                          iconColor: context.appTheme.onNegative,
                          backgroundColor: context.appTheme.negative,
                          onTap: () {
                            context.pop();
                            onConfirm();
                          },
                        )
                      ],
              )
            ],
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
  required Widget child,
}) {
  final NavigatorState navigator = Navigator.of(context);
  return navigator.push(CustomAppModalRoute(context, child: child));
}
