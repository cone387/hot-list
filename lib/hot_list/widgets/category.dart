import 'package:flutter/material.dart';
import 'package:hot_list/common/widgets/list.dart';
import 'package:hot_list/hot_list/controllers/category.dart';
import 'package:hot_list/hot_list/entities/subscribe.dart';
import 'package:hot_list/hot_list/widgets/subscribe.dart';

class CategoryDetailWidget extends StatelessWidget {
  final CategoryEntity category;
  late final CategoryDetailController controller =
      CategoryDetailController(category);

  CategoryDetailWidget({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(context) {
    return RichListWidget<Subscribe>(
        controller: CategoryDetailController(category),
        itemBuilder: (Subscribe subscribe, int index, c) =>
            SubscribeTile(subscribe: subscribe));
  }
}
