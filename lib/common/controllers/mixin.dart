import 'package:hot_list/common/caches/json_cache.dart';
import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/common/logger.dart';
import 'package:hot_list/common/utils/json.dart';

mixin PagedListMixin<T> on ListController<T> {
  int initPage = 1;
  int pageSize = 30;
  bool haveMore = true;
  int loadTimes = 0;
  late int page = initPage;

  appendItems(List<T> objects) {
    if (objects.isNotEmpty) items.addAll(objects);
  }

  Future<List<T>> pageItems(int page) async {
    return await listItems();
  }

  @override
  Future<List<T>> refreshItems() async {
    page = initPage;
    var objects = await super.refreshItems();
    page += 1;
    return objects;
  }

  Future<List<T>> loadMoreItems() async {
    List<T> objects = [];
    if (isLoading || !haveMore) {
      logger.d(isLoading
          ? "$runtimeType is loading, load more items ignored"
          : "$runtimeType have no more items");
      return objects;
    }
    // 如果page=initPage说明这时应该刷新而不是加载
    // if (page != initPage)
    isLoading = true;
    try {
      objects = await pageItems(page);
    } catch (e) {
      objects = [];
      logger.e("$runtimeType on page items");
    } finally {
      isLoading = false;
      appendItems(objects);
      loadTimes += 1;
      page += 1;
      haveMore = objects.length == pageSize;
    }
    return objects;
  }
}

mixin ItemAddMixin<T> on ListController<T> {
  Future<String?> onItemAdd(T item);
  Future<String?> onItemsAdd(List<T> objects) async {
    String? error;
    for (var element in objects) {
      error = await onItemAdd(element);
      if (error != null) {
        break;
      }
    }
    return error;
  }

  Future<String?> addItem(T item) async {
    items.insert(0, item);
    return onItemAdd(item);
  }

  Future<String?> addItems(List<T> objects) async {
    items.addAll(objects);
    return onItemsAdd(objects);
  }
}

mixin ItemRemoveMixin<T> on ListController<T> {
  Future<String?> onItemRemove(T item);

  Future<String?> removeItem(T item) async {
    items.remove(item);
    return onItemRemove(item);
  }

  Future<List<String?>> removeItems(List<T> objects) async {
    List<String?> errors = [];
    for (var element in objects) {
      errors.add(await removeItem(element));
    }
    return errors;
  }
}

mixin ItemUpdateMixin<T> on ListController<T> {
  Future<String?> onItemUpdate(int oldIndex, T oldItem, T newItem);

  Future<String?> updateItem(T oldItem, T newItem) async {
    int i = items.indexOf(oldItem);
    items[i] = newItem;
    return onItemUpdate(i, oldItem, newItem);
  }

  Future<List<String?>> updateItems(List<T> oldItems, List<T> newItems) async {
    List<String?> errors = [];
    for (int i = 0; i < oldItems.length; i++) {
      errors.add(await updateItem(oldItems[i], newItems[i]));
    }
    return errors;
  }
}

mixin HttpItemMixin<T> on BaseItemMixin<T> {
  BaseRequests get requests => Requests;

  String getError(dynamic json) {
    if (json is List) {
      return getError(json[0]);
    }
    if (json is Map) {
      return getError(json.values.first);
    }
    return json.toString();
  }
}

// // 添加item到服务端
mixin HttpListMixin<T> on ListController<T>, HttpItemMixin<T> {
  String get listUrl;
  Json get listParams => {};

  List decodeResponse(Response response) {
    var json = response.getJson();
    if (json is List) {
      return json;
    } else if (json is Map) {
      return json['results'];
    }
    throw TypeError();
  }

  Future<List<T>> onHttpList() async {
    var response = await requests.get(listUrl, params: listParams);
    if (response.OK) {
      var objects = decodeResponse(response);
      return objects.map((e) => decoder(e)).toList();
    }
    return [];
  }

  @override
  Future<List<T>> listItems() async {
    return onHttpList();
  }
}

// 添加item到服务端
mixin HttpPagedListMixin<T> on HttpListMixin<T>, PagedListMixin<T> {
  @override
  Json get listParams =>
      {'page': page.toString(), 'page_size': pageSize.toString()};
}

// 添加item到服务端
mixin HttpItemAddMixin<T extends IdSerializable>
    on HttpItemMixin<T>, ItemAddMixin<T> {
  String get postUrl;

  Future<String?> onHttpAdd(T item) async {
    var body = toAddForm(item);
    // return "item does not have any change";
    if (body.isEmpty) return null;
    FormData? form;
    if (isFormData(body)) {
      form = FormData.fromMap(getFormJson(body));
    }
    var response = await requests.post(postUrl, body: form ?? body);
    logger.d("add $item on server: ${response.statusCode}");
    if (response.OK) {
      var o = decoder(response.getJson());
      // ignore: invalid_use_of_protected_member
      // 如果使用更新后覆盖了原来的item 会导致删除异常
      // items[items.value.indexOf(item)] = o;
      item.id = o.id;
      return null;
    }
    return getError(response.getJson());
  }

  @override
  Future<String?> onItemAdd(T item) async {
    return onHttpAdd(item);
  }

  Json toAddForm(T item) => item.toJson();
}

// 删除远程Item
mixin HttpItemRemoveMixin<T extends IdSerializable>
    on HttpItemMixin<T>, ItemRemoveMixin<T> {
  String get removeUrl;

  @override
  Future<String?> onItemRemove(T item) => onHttpRemove(item);

  Future<String?> onHttpRemove(T item) async {
    var response =
        await requests.delete(removeUrl.replaceAll("{id}", item.id.toString()));
    logger.d("remove $item on server: ${response.statusCode}");
    if (response.OK) {
      return null;
    }
    return getError(response.getJson());
  }
}

mixin HttpItemUpdateMixin<T extends IdSerializable>
    on HttpItemMixin<T>, ItemUpdateMixin<T> {
  String get updateUrl;

  @override
  Future<String?> onItemUpdate(int oldIndex, T oldItem, T newItem) =>
      onHttpUpdate(oldIndex, oldItem, newItem);

  Future<String?> onHttpUpdate(int oldIndex, T oldItem, T newItem) async {
    var body = toUpdateForm(oldItem, newItem);
    // return "item does not have any change";
    if (body.isEmpty) return null;
    FormData? form;
    if (isFormData(body)) {
      form = FormData.fromMap(getFormJson(body));
    }
    var response = await requests.patch(
        updateUrl.replaceAll('{id}', oldItem.id.toString()),
        body: form ?? body);
    logger.d("update $oldItem on server: ${response.statusCode}");
    if (response.OK) {
      // 使用value避免再次更新
      // ignore: invalid_use_of_protected_member
      // items.value[oldIndex] = newItem;
      // 没有必要再次更新
      return null;
    }
    return getError(response.getJson());
  }

  Json toUpdateForm(T oldItem, T newItem) {
    return getUpdatedJson(oldItem.toJson(), newItem.toJson());
  }
}

mixin CacheableListMixin<T extends Serializable> on ListController<T> {
  bool enableCache = true;
  List<T> cachedItems = [];

  Future<List<T>> readCachedItems() async {
    var objects = await ListCache(key: key).read() ?? [];
    logger.d("Cache<$key>load ${objects.length} items from cache");
    cachedItems = objects.map<T>((e) => decoder(e)).toList();
    return cachedItems;
  }

  String get key;

  @override
  T decoder(Json json);

  @override
  loadInitItems() async => await readCachedItems();

  writeItemsToCache(List<T> objects) async {
    await ListCache(key: key).write(objects);
    logger.i("write ${items.length} items to Cache<$key>");
  }

  toCahce(List<T> objects) {
    if (objects.isNotEmpty && enableCache) {
      writeItemsToCache(objects);
    }
  }

  @override
  Future<List<T>> refreshItems() async {
    var objects = await super.refreshItems();
    toCahce(objects);
    return objects;
  }
}
