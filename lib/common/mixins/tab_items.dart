import 'package:flutter/material.dart';
import 'package:hot_list/common/entities/identifiable.dart';
import 'package:hot_list/common/widgets/list.dart';

mixin TabItemsWidgetMixin<T extends StatefulWidget> on State<T> {
  List<Identifiable> oldTabItemList = [];
  Map<Identifiable, RichListWidget> tabViewMap = {};

  List<Identifiable> get newTabItemList;

  RichListWidget newItemTabView(Identifiable item);

  RichListWidget getItemTabView(Identifiable item) {
    late Identifiable tmp;
    for (var k in tabViewMap.keys) {
      if (k.id == item.id) {
        tmp = k;
        break;
      }
    }
    return tabViewMap[tmp]!;
  }

  bool showUpdateTabViews() {
    bool flag = false;
    if (newTabItemList.length > 0) {
      if (newTabItemList.length != oldTabItemList.length) {
        flag = true;
      } else {
        for (int index in Iterable<int>.generate(newTabItemList.length)) {
          if (oldTabItemList[index].id != newTabItemList[index].id) {
            flag = true;
            break;
          }
        }
      }
    }
    return flag;
  }

  updateTabViews() {
    var tabKeys = tabViewMap.keys.toList();
    tabKeys.forEach((tabItem) {
      if (!newTabItemList.any((element) => element.id == tabItem.id)) {
        tabViewMap.remove(tabItem);
      }
    });

    newTabItemList.forEach((element) {
      if (!tabViewMap.keys.any((tabItem) => element.id == tabItem.id)) {
        tabViewMap[element] = newItemTabView(element);
      }
    });
    oldTabItemList = tabViewMap.keys.toList();
  }
}
