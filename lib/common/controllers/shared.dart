import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/serializable.dart';
import 'package:hot_list/common/logger.dart';

mixin SharedItemMixin<T extends Serializable> on BaseItemMixin<T> {
  SharedPreferences? backend;
}

mixin SharedListMixin<T extends Serializable>
    on ListController<T>, SharedItemMixin<T> {
  late String key = runtimeType.toString();

  late String listKey = key + '-list';

  @override
  Future<void> onCreated() async {
    backend = await SharedPreferences.getInstance();
  }

  @override
  Future<List<T>> listItems() async {
    String? string = backend!.getString(listKey);
    if (string != null) {
      List list = jsonDecode(string);
      return list.map<T>((e) => decoder(e)).toList();
    }
    return [];
  }
}

mixin SharedPagedListMixin<T extends Serializable>
    on SharedListMixin<T>, PagedListMixin<T> {
  @override
  String get listKey => super.listKey + '-$page';

  @override
  Future<List<T>> loadMoreItems() {
    var objects = super.loadMoreItems();
    haveMore = backend!.containsKey(listKey);
    return objects;
  }
}

mixin SharedItemAddMixin<T extends Serializable>
    on SharedPagedListMixin<T>, ItemAddMixin<T> {
  String get addKey => super.listKey.replaceAll('-$page', '-$initPage');

  @override
  Future<String?> onItemAdd(item) async {
    // 因为这里items已经加上了item， 所以sublist需要+2
    var objects = items.sublist(0, min(items.length, pageSize + 2));
    backend!.setString(addKey, jsonEncode(objects));
    logger.d("$runtimeType add $item to $addKey");
    return null;
  }
}

mixin SharedItemRemoveMixin<T extends Serializable>
    on SharedPagedListMixin<T>, ItemRemoveMixin<T> {
  @override
  Future<String?> onItemRemove(item) async {
    // 因为这里items已经加上了item， 所以sublist需要+2
    int index = items.indexOf(item);
    int atPage = index ~/ pageSize;
    var objects = items.sublist(
        atPage * pageSize, min(items.length, (atPage + 1) * pageSize));
    String key = super.listKey.replaceAll('-$page', '-${atPage + initPage}');
    backend!.setString(key, jsonEncode(objects));
    logger.d("$runtimeType delete $item in $key");
    return null;
  }

  @override
  Future<String?> removeItem(item) async {
    var error = await onItemRemove(item);
    items.remove(item);
    return error;
  }
}

mixin SharedItemUpdateMixin<T extends Serializable>
    on SharedPagedListMixin<T>, ItemUpdateMixin<T> {
  String get updateKey => super.listKey.replaceAll('-$page', '');

  @override
  Future<String?> onItemUpdate(int index, T oldItem, T newItem) async {
    // 因为这里items已经加上了item， 所以sublist需要+2
    int atPage = index ~/ pageSize;
    var objects = items.sublist(
        atPage * pageSize, min(items.length, (atPage + 1) * pageSize));
    String key = super.listKey.replaceAll('-$page', '-${atPage + initPage}');
    backend!.setString(key, jsonEncode(objects));
    logger.d("$runtimeType update $newItem in $key");
    return null;
  }
}

abstract class SharedListController<T extends Serializable>
    extends ListController<T> with SharedItemMixin<T>, SharedListMixin<T> {}

abstract class SharedPagedListController<T extends Serializable>
    extends PagedListController<T>
    with SharedItemMixin<T>, SharedListMixin<T>, SharedPagedListMixin<T> {}

abstract class SharedRichListController<T extends Serializable>
    extends RichListController<T>
    with
        SharedItemMixin<T>,
        SharedListMixin<T>,
        SharedPagedListMixin<T>,
        SharedItemAddMixin<T>,
        SharedItemRemoveMixin<T>,
        SharedItemUpdateMixin<T> {}
