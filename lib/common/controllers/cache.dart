import 'dart:convert';

import 'package:sqflite/sqlite_api.dart';
import 'package:hot_list/common/controllers/base.dart';
import 'package:hot_list/common/controllers/list.dart';
import 'package:hot_list/common/controllers/mixin.dart';
import 'package:hot_list/common/entities/identifiable.dart';
import 'package:hot_list/common/entities/serializable.dart';
import 'package:hot_list/common/entities/types.dart';
import 'package:hot_list/common/logger.dart';
import 'package:hot_list/common/storage/db.dart';

// class SqlListController extends ListController{

// }

mixin SqlItemMixin<T extends Serializable> on BaseItemMixin<T> {
  String get table;

  Database get db => SqliteDB.db;
}

// // 添加item到服务端
mixin SqlListMixin<T extends Serializable>
    on ListController<T>, SqlItemMixin<T> {
  String orderBy = 'id desc';

  List<String> get defaultWhere;

  String getListQuery(List<String> where) {
    assert(where.isNotEmpty, "where cant be null");
    return "select * from $table where ${where.join(' and ')} order by $orderBy";
  }

  Future<List<T>> queryItems({required List<String> where}) async {
    String query = getListQuery(where);
    var objects = await db.rawQuery(query);
    logger.d("query ${objects.length} items using query: $query");
    return objects.map((e) => decoder(e)).toList();
  }

  @override
  Future<List<T>> listItems() async {
    return queryItems(where: defaultWhere);
  }
}

// 添加item到服务端
mixin SqlPagedListMixin<T extends Serializable>
    on SqlListMixin<T>, PagedListMixin<T> {
  @override
  String getListQuery(List<String> where) {
    String query = super.getListQuery(where);
    int p = page - initPage;
    return "$query limit ${p * pageSize}, ${(p + 1) * pageSize}";
  }
}

// 添加item到服务端
mixin SqlItemAddMixin<T extends IdSerializable>
    on SqlPagedListMixin<T>, ItemAddMixin<T> {
  @override
  Future<String?> onItemAdd(T item) async {
    Json value = item.toJson();
    value.remove('id');
    var id = await db.insert(table, value,
        conflictAlgorithm: ConflictAlgorithm.replace);
    if (id != 0) {
      item.id = id;
    }
    logger.d("$runtimeType add $item to sql: $id");
    return id > 0 ? null : "$runtimeType failed on add $item to sql";
  }
}

// 删除远程Item
mixin SqlItemRemoveMixin<T extends IdSerializable>
    on SqlItemMixin<T>, ItemRemoveMixin<T> {
  @override
  Future<String?> onItemRemove(T item) async {
    var num = await db.delete(table, where: 'id=${item.id}');
    logger.d("$runtimeType delete $item in sql: $num");
    return num > 0 ? null : "$runtimeType failed on delete $item in sql";
  }
}

mixin SqlItemUpdateMixin<T extends IdSerializable>
    on SqlItemMixin<T>, ItemUpdateMixin<T> {
  @override
  Future<String?> onItemUpdate(int oldIndex, T oldItem, T newItem) async {
    Json value = newItem.toJson();
    value.remove('id');
    var num = await db.update(table, value, where: "id=${oldItem.id}");
    logger.d("$runtimeType update $newItem in sql: $num");
    return num > 0 ? null : "$runtimeType failed on update $newItem";
  }
}

// base http controller
abstract class SqlController<T extends Serializable> extends ListController<T>
    with SqlItemMixin<T> {}

// list http controller
abstract class SqlListController<T extends Serializable>
    extends SqlController<T> with SqlListMixin<T> {}

//
abstract class _SqlPagedListController<T extends Serializable>
    extends SqlListController<T> with PagedListMixin<T> {}

abstract class SqlPagedListController<T extends Serializable>
    extends _SqlPagedListController<T> with SqlPagedListMixin<T> {}

abstract class _SqlListCreateController<T extends Serializable>
    extends SqlPagedListController<T> with ItemAddMixin<T> {}

abstract class SqlListCreateController<T extends IdSerializable>
    extends _SqlListCreateController<T> with SqlItemAddMixin<T> {}

abstract class _SqlListCreateRemoveController<T extends IdSerializable>
    extends SqlPagedListController<T> with ItemAddMixin<T>, ItemRemoveMixin {}

abstract class SqlListCreateRemoveController<T extends IdSerializable>
    extends _SqlListCreateRemoveController<T>
    with SqlItemAddMixin<T>, SqlItemRemoveMixin<T> {}

// 这里with HttpItemAddMixin<T>, HttpItemRemoveMixin<T>, HttpItemUpdateMixin<T> 会报错：The class doesn't have a concrete implementation of the super-invoked member 'onItemUpdate'.
// 不知道是不是with有个数限制
abstract class SqlRichListController<T extends IdSerializable>
    extends RichListController<T>
    with
        PagedListMixin<T>,
        ItemAddMixin<T>,
        ItemRemoveMixin<T>,
        ItemUpdateMixin<T>,
        SqlItemMixin<T>,
        SqlListMixin<T>,
        SqlPagedListMixin<T>,
        SqlItemAddMixin<T>,
        SqlItemRemoveMixin<T>,
        SqlItemUpdateMixin<T> {}

mixin CacheableSqlListMixin<T extends IdSerializable> on ListController<T> {
  bool enableCache = true;

  List<T> cachedItems = [];

  Database get db => SqliteDB.db;

  late String cacheType = runtimeType.toString();

  T cacheDecoder(Json json) {
    return decoder(jsonDecode(json['data']));
  }

  late String cacheTable = 'list_cache';

  late String createCommond = '''
    create table if not exists $cacheTable (
      id integer primary key autoincrement,
      type varchar(50) not null,
      data json
    )
  ''';

  Future<void> clearCache() {
    return db.delete(cacheTable, where: 'type=?', whereArgs: [cacheType]);
  }

  Future<List<T>> listCachedItems() async {
    String listCmd =
        "select * from $cacheTable where type='$cacheType' order by id";
    var objects = await db.rawQuery(listCmd);
    cachedItems = objects.map((e) => cacheDecoder(e)).toList();
    logger.i(
        "$runtimeType read ${cachedItems.length} cache items using query $listCmd");
    return cachedItems;
  }

  Future<String?> updateCacheItem(T item) async {
    int num = await db.update(cacheTable, {'data': jsonEncode(item.toJson())},
        where: "json_extract(data, '\$.id')= ? and type = ?",
        whereArgs: [item.id, cacheType]);
    logger.d("$runtimeType update cache<type=$cacheType> $item: $num");
    int index = cachedItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      cachedItems[index] = item;
    }
    return num > 0 ? null : "update cache $item failed";
  }

  Future<String?> addCacheItem(T item) async {
    int num = await db.insert(
        cacheTable, {'type': cacheType, 'data': jsonEncode(item.toJson())},
        conflictAlgorithm: ConflictAlgorithm.replace);
    logger.d("add cache item: $num, type=$cacheType");
    cachedItems.insert(0, item);
    return num > 0 ? null : "add cache $item failed";
  }

  Future<String?> removeCacheItem(T item) async {
    int num = await db.delete(cacheTable,
        where: "json_extract(data, '\$.id')= ? and type = ?",
        whereArgs: [item.id, cacheType]);
    logger.d("remove cache $item");
    cachedItems.removeWhere((element) => element.id == item.id);
    return num > 0 ? null : "remove cache $item failed";
  }

  toCache({List<T>? objects, bool rewrite = true}) async {
    objects ??= items;
    if (enableCache && objects.isNotEmpty) {
      if (rewrite) {
        await clearCache();
      }
      Batch batch = db.batch();
      for (var e in objects) {
        batch.insert(
            cacheTable, {'type': cacheType, 'data': jsonEncode(e.toJson())});
      }
      batch.commit().then((value) => logger.i(
          "$runtimeType write ${value.length} items to cache $cacheTable, type is $cacheType"));
    } else {
      logger.i("cache is $enableCache, objects is ${objects.length}");
    }
  }

  @override
  Future<void> onCreated() async {
    if (enableCache) {
      await SqliteDB.init();
      // await db.execute('drop table $cacheTable');
      // await clearCache();
      await db.execute(createCommond);
    }
    return super.onCreated();
  }

  @override
  Future<List<T>?> loadInitItems() async {
    return enableCache ? await listCachedItems() : [];
  }

  @override
  void setItems(List<T> objects) {
    if (cachedItems.isNotEmpty) {
      for (int i = 0; i < objects.length; i++) {
        T o = objects[i];
        for (var cache in cachedItems) {
          if (cache.id == o.id) {
            objects[i] = cache;
            break;
          }
        }
      }
    }
    super.setItems(objects);
    toCache();
  }
}

mixin CacheableSqlRichMixin<T extends IdSerializable>
    on RichListController<T>, CacheableSqlListMixin<T> {
  @override
  Future<String?> onItemAdd(item) async {
    String? error = await super.onItemAdd(item);
    if (error != null && enableCache) {
      addCacheItem(item);
    }
    return error;
  }

  @override
  Future<String?> onItemUpdate(int oldIndex, oldItem, newItem) async {
    String? error = await super.onItemUpdate(oldIndex, oldItem, newItem);
    if (error != null && enableCache) {
      updateCacheItem(newItem);
    }
    return error;
  }

  @override
  Future<String?> onItemRemove(item) async {
    String? error = await super.onItemRemove(item);
    if (error != null && enableCache) {
      removeCacheItem(item);
    }
    return null;
  }
}
