import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/persistent/hive_data_store.dart';
import '../../category/model/income_category.dart';

class CategoriesListScreen extends ConsumerWidget {
  const CategoriesListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveStore = ref.watch(hiveStoreProvider);
    return ValueListenableBuilder(
      valueListenable: hiveStore.incomeCategoriesBoxListenable(),
      builder: (_, box, __) {
        List<IncomeCategory> categories = box.values.toList();
        return ListView(
          children: List.generate(
            categories.length,
            (index) => Text(
              categories[index].toString(),
            ),
          ),
        );
      },
    );
  }
}
