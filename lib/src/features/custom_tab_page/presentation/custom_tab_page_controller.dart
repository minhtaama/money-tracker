import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomListViewState {
  CustomListViewState(
      {required this.pixelsOffset, required this.isIdling, required this.isScrollForward});

  final bool isScrollForward;
  final bool isIdling;
  final double pixelsOffset;

  CustomListViewState copyWith({
    bool? isScrollForward,
    bool? isIdling,
    double? pixelsOffset,
  }) {
    return CustomListViewState(
      isScrollForward: isScrollForward ?? this.isScrollForward,
      isIdling: isIdling ?? this.isIdling,
      pixelsOffset: pixelsOffset ?? this.pixelsOffset,
    );
  }
}

class CustomListViewStateController extends StateNotifier<CustomListViewState> {
  CustomListViewStateController()
      : super(CustomListViewState(isScrollForward: true, isIdling: true, pixelsOffset: 0));

  bool get getScrollForwardState => state.isScrollForward;
  bool get getIsIdlingState => state.isIdling;

  void setScrollForwardState(bool isForward) {
    state = state.copyWith(
      isScrollForward: isForward,
    );
  }

  void setIsIdlingState(bool value) {
    if (value) {
      state = state.copyWith(
        isIdling: true,
      );
    } else {
      state = state.copyWith(
        isIdling: false,
      );
    }
  }

  void setPixelsOffset(double value) {
    state = state.copyWith(pixelsOffset: value);
  }
}

final customListViewStateControllerProvider =
    StateNotifierProvider<CustomListViewStateController, CustomListViewState>(
  (ref) => CustomListViewStateController(),
);
