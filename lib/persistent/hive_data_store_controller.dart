import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// This class is used as a bridge to turn a `Box.listenable()`
/// to a [StateNotifier]. By making the `callback` (which update `state`)
/// listen to the `Box.listenable()`.
///
/// By doing that, the `state` object will be updated by the new value of
/// `Box.values.toList()` when `Box.listenable()` notifies a change.
class HiveBoxValuesController extends StateNotifier<List> {
  HiveBoxValuesController(this.hiveBox) : super(hiveBox.values.toList()) {
    callback = () => state = hiveBox.values.toList();
    hiveBox.listenable().addListener(callback);
  }

  final Box hiveBox;
  late void Function() callback;

  @override
  void dispose() {
    hiveBox.listenable().removeListener(callback);
    super.dispose();
  }
}

/// This provider takes an argument type `Box<dynamic>` and all dependency
/// will be updated when this `Box` changes its value (or we can say when
/// this provider changes its state).
///
/// By giving this provider a `Box`, it will convert this `Box.values` to
/// a `List<dynamic>` and notify its consumer when the values/list changes.
///
/// We can add more logic by watching to this provider inside a [StateProvider],
/// as this provider state will be the state of the parent [StateProvider].
///
/// __For example:__
/// ```
/// final hiveList = ref.watch(hiveBoxValuesControllerProvider(someHiveBox))
/// ```
final hiveBoxValuesControllerProvider =
    StateNotifierProvider.family<HiveBoxValuesController, List, Box>((ref, hiveBox) {
  return HiveBoxValuesController(hiveBox);
});
