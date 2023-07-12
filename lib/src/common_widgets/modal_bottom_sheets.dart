import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/theme_and_ui/colors.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';
import 'icon_with_text_button.dart';

/// This is a helper function to show a confirmation of user
Future<T?> showConfirmModalBottomSheet<T>({
  required BuildContext context,
  required String label,
  String confirmLabel = 'Delete',
  String? confirmIcon,
  required VoidCallback onConfirm,
}) {
  return showModalBottomSheet<T>(
    context: context,
    elevation: 0,
    enableDrag: false,
    backgroundColor:
        context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
    barrierColor: context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                label,
                style: kHeader3TextStyle.copyWith(
                  color: context.appTheme.backgroundNegative,
                ),
              ),
              Gap.h24,
              Row(
                children: [
                  IconWithTextButton(
                    icon: AppIcons.back,
                    label: 'No',
                    color: context.appTheme.backgroundNegative,
                    backgroundColor: AppColors.grey,
                    onTap: () => context.pop(),
                  ),
                  const Expanded(child: SizedBox()),
                  IconWithTextButton(
                    icon: confirmIcon ?? AppIcons.delete,
                    label: confirmLabel,
                    color: context.appTheme.accentNegative,
                    backgroundColor: context.appTheme.accent,
                    onTap: () {
                      onConfirm();
                      context.pop();
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
    backgroundColor:
        context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
    barrierColor: context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey,
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
Page<T> showModalBottomSheetPage<T>(BuildContext context, GoRouterState state, {required Widget child}) {
  return ModalBottomSheetPage(
    backgroundColor:
        context.appTheme.isDarkTheme ? context.appTheme.background3 : context.appTheme.background,
    modalBarrierColor: context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.6) : AppColors.grey,
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
        enableDrag: true,
        useSafeArea: false,
        builder: (context) => Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: hasHandle
              ? Stack(
                  children: [
                    AnimatedPadding(
                      padding:
                          EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
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
  const Handle({Key? key}) : super(key: key);

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
            color: context.appTheme.backgroundNegative.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
