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

/// This provider takes an argument type `Box<dynamic>`
/// When a variable is assigned by watching to this [StateNotifierProvider],
/// It will be updated when the state of this provider change.
///
/// We can add more logic by watching to this provider inside a [StateProvider],
/// as this provider state will be the state of the parent [StateProvider].
///
/// _FOR EXAMPLE:_
/// ```
/// final hiveModelsList = ref.watch(hiveBoxValuesControllerProvider(categoryRepository._expenseCategoryBox))
/// ```
final hiveBoxValuesControllerProvider =
    StateNotifierProvider.family<HiveBoxValuesController, List, Box>((ref, hiveBox) {
  return HiveBoxValuesController(hiveBox);
});
