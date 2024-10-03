import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_tracker_app/src/common_widgets/card_item.dart';
import 'package:money_tracker_app/src/common_widgets/svg_icon.dart';
import 'package:money_tracker_app/src/features/category/data/category_repo.dart';
import 'package:money_tracker_app/src/theme_and_ui/icons.dart';
import 'package:money_tracker_app/src/utils/extensions/context_extensions.dart';
import '../../../common_widgets/rounded_icon_button.dart';
import '../../../utils/constants.dart';
import '../domain/category.dart';
import '../domain/category_tag.dart';
import 'category_tag/category_tag_selector.dart';

class CategoryListTile extends ConsumerWidget {
  const CategoryListTile({
    super.key,
    required this.model,
    required this.onMenuTap,
  });

  final Category model;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryRepo = ref.watch(categoryRepositoryRealmProvider);
    final tags = categoryRepo.getTagList(model)!;

    return CardItem(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 35,
                width: 35,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: model.backgroundColor,
                  borderRadius: BorderRadius.circular(1000),
                ),
                child: SvgIcon(
                  model.iconPath,
                  color: model.iconColor,
                ),
              ),
              Gap.w16,
              Expanded(
                child: Text(
                  model.name,
                  style: kHeader3TextStyle.copyWith(color: context.appTheme.onBackground),
                ),
              ),
              Gap.w8,
              RoundedIconButton(
                iconPath: AppIcons.editLight,
                backgroundColor: Colors.transparent,
                iconColor: context.appTheme.onBackground,
                onTap: onMenuTap,
                size: 42,
              ),
            ],
          ),
          tags.isNotEmpty ? Gap.h12 : Gap.noGap,
          CategoryTagSelector2(
            category: model,
            isDisplayingOnly: true,
          ),
        ],
      ),
    );
  }
}
