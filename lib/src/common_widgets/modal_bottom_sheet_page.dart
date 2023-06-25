import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../utils/constants.dart';

/// This function is used in app_router to show a [ModalBottomSheetPage]
Page<T> showModalBottomSheetPage<T>(BuildContext context, GoRouterState state, {required Widget child}) {
  return ModalBottomSheetPage(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.90,
    ),
    backgroundColor: Color.lerp(context.appTheme.background2, context.appTheme.backgroundNegative, 0.09),
    modalBarrierColor: context.appTheme.background.withOpacity(0.9),
    isScrollControlled: true,
    child: Column(
      children: [
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: context.appTheme.backgroundNegative.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Gap.h16,
        child,
      ],
    ),
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
    this.shape,
    this.constraints,
    this.backgroundColor,
    this.modalBarrierColor,
    this.isDismissible = true,
    this.isScrollControlled = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final ShapeBorder? shape;
  final BoxConstraints? constraints;
  final Color? backgroundColor;
  final Color? modalBarrierColor;
  final bool isDismissible;
  final bool isScrollControlled;
  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) => ModalBottomSheetRoute(
        settings: this,
        shape: shape,
        elevation: 0,
        constraints: constraints,
        backgroundColor: backgroundColor,
        modalBarrierColor: modalBarrierColor,
        isDismissible: isDismissible,
        isScrollControlled: isScrollControlled,
        enableDrag: true,
        useSafeArea: false,
        builder: (context) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: kBottomAppBarDuration,
              child: child,
            ),
          ),
        ),
      );
}
