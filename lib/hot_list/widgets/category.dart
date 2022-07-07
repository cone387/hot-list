import 'package:flutter/material.dart';
import 'package:hot_list/common/widgets/list.dart';
import 'package:hot_list/hot_list/controllers/category.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';

class CategoryDetailWidget extends StatelessWidget {
  final CategoryEntity category;
  late final CategoryDetailController controller =
      CategoryDetailController(category);

  final ScrollController scrollController = ScrollController();

  CategoryDetailWidget({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(context) {
    return RichListWidget<Subscribe>(
        scrollController: scrollController,
        controller: CategoryDetailController(category),
        itemBuilder: (Subscribe subscribe, int index, {arg}) =>
            SubscribeTile(subscribe: subscribe));
  }
}
