import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/common_widgets/rounded_icon_button.dart';
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

///////////////////////////////

/// Logic to switch between [CustomFloatingSheetRoute] and [CustomModalBottomSheetRoute]
/// ONLY CHANGE THIS
PopupRoute<T> _route<T>(
  BuildContext context, {
  required Widget child,
  required bool hasHandle,
  RouteSettings? settings,
}) {
  final backgroundColor = context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1;
  final modalBarrierColorBottomSheet =
      context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.9) : AppColors.grey(context).withOpacity(0.7);
  final modalBarrierColorFloatingSheet =
      context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.25) : AppColors.grey(context).withOpacity(0.25);

  if (Gap.screenWidth(context) > 500) {
    return CustomFloatingSheetRoute<T>(
      settings: settings,
      backgroundColor: backgroundColor,
      modalBarrierColor: modalBarrierColorFloatingSheet,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.1,
        maxWidth: 400,
        minWidth: 400,
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
        child: child,
      ),
    );
  }

  return CustomModalBottomSheetRoute<T>(
    settings: settings,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
    ),
    backgroundColor: backgroundColor,
    modalBarrierColor: modalBarrierColorBottomSheet,
    enableDrag: hasHandle,
    builder: (context) => child,
  );
}

/// This is a custom helper function to show a modal bottom sheet
/// rather than pushing a new screen.
Future<T?> showCustomModal<T>({
  required BuildContext context,
  required Widget child,
  bool hasHandle = true,
  bool enableDrag = true,
}) {
  final NavigatorState navigator = Navigator.of(context);
  return navigator.push(_route(context, child: child, hasHandle: hasHandle));
}

/// This function is used in app_router to show a [ModalBottomSheetPage]
/// as a new screen with its unique path.
Page<T> showCustomModalPage<T>(
  BuildContext context,
  GoRouterState state, {
  required Widget child,
  bool hasHandle = true,
}) {
  return ModalBottomSheetPage(
    hasHandle: hasHandle,
    backgroundColor: context.appTheme.isDarkTheme ? context.appTheme.background0 : context.appTheme.background1,
    modalBarrierColor:
        context.appTheme.isDarkTheme ? AppColors.black.withOpacity(0.9) : AppColors.grey(context).withOpacity(0.7),
    child: child,
  );
}

////////////////////

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
    this.backgroundColor,
    this.modalBarrierColor,
    this.hasHandle = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Color? backgroundColor;
  final Color? modalBarrierColor;
  final Widget child;
  final Widget? bottomFrontChild;
  final bool hasHandle;

  @override
  Route<T> createRoute(BuildContext context) {
    return _route(context, child: child, hasHandle: hasHandle, settings: this);
  }
}

class CustomFloatingSheetRoute<T> extends PopupRoute<T> {
  /// A modal bottom sheet route.
  CustomFloatingSheetRoute({
    required this.builder,
    this.backgroundColor,
    this.clipBehavior,
    this.constraints,
    this.modalBarrierColor,
    super.settings,
    this.useSafeArea = false,
  });

  /// A builder for the contents of the sheet.
  ///
  /// The bottom sheet will wrap the widget produced by this builder in a
  /// [Material] widget.
  final WidgetBuilder builder;

  final Color? backgroundColor;

  final Clip? clipBehavior;

  final BoxConstraints? constraints;

  final Color? modalBarrierColor;

  final bool useSafeArea;

  final ValueNotifier<EdgeInsets> _clipDetailsNotifier = ValueNotifier<EdgeInsets>(EdgeInsets.zero);

  @override
  void dispose() {
    _clipDetailsNotifier.dispose();
    super.dispose();
  }

  @override
  Duration get transitionDuration => k350msDuration;

  @override
  Duration get reverseTransitionDuration => k250msDuration;

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel = null;

  @override
  Color? get barrierColor => modalBarrierColor;

  @override
  AnimationController createAnimationController() {
    return AnimationController(
      duration: transitionDuration,
      reverseDuration: reverseTransitionDuration,
      vsync: navigator!,
    );
  }

  @override
  Animation<double> createAnimation() {
    return controller!.drive(CurveTween(curve: Curves.fastOutSlowIn));
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget content = Builder(
      builder: (BuildContext context) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Stack(
              children: [
                Positioned(
                  bottom: 0 - 30 * ReverseAnimation(animation).value,
                  left: 0,
                  child: Opacity(
                    opacity: animation.value,
                    child: child!,
                  ),
                ),
              ],
            );
          },
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: CardItem(
                color: backgroundColor,
                constraints: constraints,
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(35),
                elevation: 10,
                child: AnimatedPadding(
                  padding: EdgeInsets.only(
                      top: 16, bottom: (MediaQuery.of(context).viewInsets.bottom).clamp(8, double.infinity)),
                  duration: const Duration(milliseconds: 50),
                  child: SingleChildScrollView(
                    child: builder(context),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    return useSafeArea
        ? SafeArea(bottom: false, child: content)
        : MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: content,
          );
  }
}

class CustomModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  /// A modal bottom sheet route.
  CustomModalBottomSheetRoute({
    required WidgetBuilder builder,
    super.backgroundColor,
    super.clipBehavior,
    super.constraints,
    super.enableDrag,
    super.modalBarrierColor,
    super.settings,
  }) : super(
          useSafeArea: false,
          isDismissible: true,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
              child: enableDrag
                  ? Stack(
                      children: [
                        AnimatedPadding(
                          padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                          duration: const Duration(milliseconds: 0),
                          child: SingleChildScrollView(child: builder(context)),
                        ),
                        const _Handle(),
                      ],
                    )
                  : AnimatedPadding(
                      padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
                      duration: const Duration(milliseconds: 0),
                      child: SingleChildScrollView(child: builder(context)),
                    ),
            );
          },
        );
}

////////////////////

class _Handle extends StatelessWidget {
  const _Handle();

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
