import 'package:get/get.dart' hide Response;
import 'package:hot_list/common/caches/json_cache.dart';
import 'package:hot_list/common/commont.dart';
import 'package:hot_list/common/http/requests.dart';
import 'package:hot_list/common/utils/json.dart';
import 'package:hot_list/logger.dart';

abstract class ItemController<T> extends GetxController {
  T get initItem;
  late Future isItemInitialized;

  Future<T?> getInitItem() async => null;

  late final Rx<T> item = initItem.obs;

  ItemController() {
    isItemInitialized = getInitItem().then((value) {
      item.value = value ?? initItem;
    });
  }
}

mixin ItemRefreshMixin<T> on ItemController<T> {
  onItemRefreshed() => refresh();

  Future<T?> getItem();

  Future<String?> refreshItem() async {
    T? value = await getItem();
    if (value != null) {
      item.value = value;
      onItemRefreshed();
      return null;
    }
    return "get item failed";
  }
}

mixin ItemUpdateMixin<T> on ItemController<T> {
  onItemUpdated() => refresh();

  Future<String?> getUpdatingItem(T o) async => null;

  Future<String?> updateItem(T o) async {
    String? error = await getUpdatingItem(o);
    if (error != null) {
      item.value = o;
      onItemUpdated();
    }
    return error;
  }
}

enum HttpMethod { GET, POST, PUT, PATCH, DELETE }

mixin HttpItemMixin<T> {
  T decoder(Json json);

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

mixin HttpItemRefreshMixin<T extends IdSerializable>
    on ItemRefreshMixin<T>, HttpItemMixin<T> {
  String get getUrl;
  HttpMethod httpMethod = HttpMethod.GET;

  @override
  Future<T?> getItem() async {
    Response response;
    if (httpMethod == HttpMethod.GET) {
      response = await requests.get(getUrl);
    } else {
      response = await requests.post(getUrl);
    }
    if (response.OK) {
      return decoder(response.getJson());
    }
    return null;
  }
}

mixin HttpItemUpdateMixin<T extends IdSerializable>
    on ItemUpdateMixin<T>, HttpItemMixin<T> {
  String get updateUrl;

  Future<String?> getUpdatingItem(T newItem) async {
    var body = getUpdatedJson(item.value.toJson(), newItem.toJson());
    var response = await requests.patch(updateUrl, body: body);
    if (!response.OK) {
      return getError(response.getJson());
    }
    return null;
  }
}

mixin CacheableItemMixin<T extends Serializable> on ItemController<T> {
  String get key;

  T decoder(Json json);

  Future<T?> readCachedItem() async {
    Json? json = await JsonCache(key: key).read();
    logger.d("Cache<$key>load $json from cache");
    if (json != null) {
      return decoder(json);
    }
    return null;
  }

  @override
  Future<T?> getInitItem() {
    return readCachedItem();
  }

  toCache(T object) async {
    await JsonCache(key: key).write(object.toJson());
    logger.i("write ${item.value} to Cache<$key>");
  }
}

mixin CacheableItemRefreshMixin<T extends Serializable>
    on ItemRefreshMixin<T>, CacheableItemMixin<T> {
  @override
  onItemRefreshed() {
    toCache(item.value);
    return super.onItemRefreshed();
  }
}

mixin CacheableItemUpdateMixin<T extends Serializable>
    on ItemUpdateMixin<T>, CacheableItemMixin<T> {
  @override
  onItemUpdated() {
    toCache(item.value);
    return super.onItemUpdated();
  }
}

mixin CacheableRichItemMixin<T extends Serializable>
    on CacheableItemRefreshMixin<T>, CacheableItemUpdateMixin<T> {}

abstract class CacheableUpdatedItemController<T extends Serializable>
    extends ItemController<T>
    with
        ItemUpdateMixin<T>,
        CacheableItemMixin<T>,
        CacheableItemUpdateMixin<T> {}

abstract class CacheableRichItemController<T extends Serializable>
    extends ItemController<T>
    with
        ItemRefreshMixin<T>,
        ItemUpdateMixin<T>,
        CacheableItemMixin<T>,
        CacheableItemRefreshMixin<T>,
        CacheableItemUpdateMixin<T> {}

abstract class ItemUpdateController<T> extends ItemController<T>
    with ItemUpdateMixin<T> {}

abstract class HttpItemUpdateController<T extends IdSerializable>
    extends ItemUpdateController<T>
    with HttpItemMixin<T>, HttpItemUpdateMixin<T> {}

abstract class HttpItemGetController<T extends IdSerializable>
    extends ItemController<T>
    with ItemRefreshMixin<T>, HttpItemMixin<T>, HttpItemRefreshMixin<T> {}

abstract class HttpCacheableItemGetController<T extends IdSerializable>
    extends HttpItemGetController<T> with CacheableItemMixin<T> {}

abstract class HttpItemGetUpdateController<T extends IdSerializable>
    extends ItemController<T>
    with
        ItemRefreshMixin<T>,
        ItemUpdateMixin<T>,
        HttpItemMixin<T>,
        HttpItemRefreshMixin<T>,
        HttpItemUpdateMixin<T> {}

abstract class HttpCacheableRichItemController<T extends IdSerializable>
    extends HttpItemGetUpdateController<T>
    with
        CacheableItemMixin<T>,
        CacheableItemRefreshMixin<T>,
        CacheableItemUpdateMixin<T>,
        CacheableRichItemMixin<T> {}
