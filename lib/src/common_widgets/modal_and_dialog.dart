import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/custom_text_form_field.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import 'package:money_tracker_app/src/utils/extensions/string_double_extension.dart';
import '../utils/constants.dart';
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
                        style: kHeader4TextStyle.copyWith(
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
                            label: 'No, go back!'.hardcoded,
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
                        IconWithTextButton(
                          iconPath: AppIcons.back,
                          label: 'Go back'.hardcoded,
                          color: context.appTheme.onBackground,
                          backgroundColor: AppColors.greyBgr(context),
                          onTap: () => context.pop(),
                        ),
                        const Spacer(),
                        IconWithTextButton(
                          iconPath: confirmIcon ?? AppIcons.delete,
                          label: confirmLabel,
                          color: context.appTheme.onNegative,
                          backgroundColor: context.appTheme.negative,
                          onTap: () {
                            context.pop();
                            onConfirm();
                          },
                        ),
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
Future<T?> showCustomModalBottomSheet<T>(
    {required BuildContext context,
    required Widget child,
    bool hasHandle = true,
    bool wrapWithScrollView = true,
    bool enableDrag = true}) {
  return showModalBottomSheet<T>(
    context: context,
    elevation: 0,
    enableDrag: enableDrag,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
    ),
    backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
    barrierColor:
        context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey(context).withOpacity(0.6),
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
      child: hasHandle
          ? Stack(
              children: [
                AnimatedPadding(
                  padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                  duration: const Duration(milliseconds: 0),
                  child: wrapWithScrollView ? SingleChildScrollView(child: child) : child,
                ),
                const Handle(),
              ],
            )
          : AnimatedPadding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              duration: const Duration(milliseconds: 0),
              child: wrapWithScrollView ? SingleChildScrollView(child: child) : child,
            ),
    ),
  );
}

/// This function is used in app_router to show a [ModalBottomSheetPage]
/// as a new screen with its unique path.
Page<T> showModalBottomSheetPage<T>(BuildContext context, GoRouterState state,
    {required Widget child, bool hasHandle = true}) {
  return ModalBottomSheetPage(
    hasHandle: hasHandle,
    backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
    modalBarrierColor:
        context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey(context).withOpacity(0.6),
    child: child,
  );
}

class ModalBottomSheetPage<T> extends Page<T> {
  /// This Page is used with [GoRoute] pageBuilder to build a
  /// ModalBottomSheetPage with a specific path. Remember to
  /// set `parentNavigatorKey` of the [GoRoute] to the root-key
  /// so that this Modal can display on top of the bottom navigation bar.
  ///
  /// > https://stackoverflow.com/questions/75690299/how-do-i-show-a-dialog-in-flutter-using-a-go-router-route
  ///
  /// Note: The ModalBottomSheet animation isn't working when testing on profile mode
  /// with Samsung device when having a accessibility application turned on
  ///
  /// > https://github.com/flutter/flutter/issues/119094
  const ModalBottomSheetPage({
    required this.child,
    this.bottomFrontChild,
    this.shape,
    this.backgroundColor,
    this.modalBarrierColor,
    this.hasHandle = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? modalBarrierColor;
  final Widget child;
  final Widget? bottomFrontChild;
  final bool hasHandle;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute(
        settings: this,
        shape: shape,
        elevation: 0,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
        ),
        backgroundColor: backgroundColor,
        modalBarrierColor: modalBarrierColor,
        isDismissible: true,
        isScrollControlled: true,
        enableDrag: hasHandle,
        useSafeArea: false,
        builder: (context) => Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: hasHandle
              ? Stack(
                  children: [
                    AnimatedPadding(
                      padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                      duration: const Duration(milliseconds: 0),
                      child: SingleChildScrollView(child: child),
                    ),
                    const Handle(),
                  ],
                )
              : AnimatedPadding(
                  padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                  duration: const Duration(milliseconds: 0),
                  child: SingleChildScrollView(child: child),
                ),
        ),
      );
}

class Handle extends StatelessWidget {
  const Handle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        heightFactor: 0,
        child: Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: context.appTheme.onBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
